//
//  TSAdvertTaskQueue.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  广告任务队列

import UIKit
import Kingfisher

/// 广告位类型
enum AdvertSpaceType: String {
    /// 启动页广告
    case launch = "boot"
    /// 动态列表顶部广告
    case feedListTop = "feed:list:top"
    /// 动态详情页广告
    case feedDetail = "feed:single"
    /// 动态列表中广告
    case feedListIn = "feed:list:analog"
    /// 资讯列表顶部广告
    case newsListTop = "news:list:top"
    /// 资讯详情页广告
    case newsDetail = "news:single"
    /// 资讯列表中广告
    case newsListIn = "news:list:analog"
    /// 圈子首页顶部广告
    case groupHomeTop = "group:index:top"
    /// 圈子帖子详情广告
    case postDetail = "group:single"
    /// 积分广告
    case currency = "currency"
}

class TSAdvertTaskQueue {

    /// 显示点击广告后台跳转的页面
    class func showDetailVC(urlString: String?) {
        guard let url = urlString else {
            return
        }
        let topVC = UIApplication.topViewController()
        TSUtil.pushURLDetail(url: URL(string: url)!, currentVC: topVC!)
//        if let nav = TSRootViewController.share.tabbarVC?.selectedViewController as? UINavigationController {
//            TSUtil.pushURLDetail(url: URL(string: url)!, currentVC: nav)
//        } else {
//
//        }
    }

    /// 获取所有的广告
    func getAllAd() {
        // 1.创建后台任务
        let taskId = TaskIdPrefix.Advert.update.rawValue
        let task = TSDatabaseManager().task.addTask(id: taskId, operation: nil)
        // 2.启动任务
        start(task: task)
    }

    /// 启动任务
    func start(task: TaskObject) {
        BasicTaskQueue.start(task: task) { (finish: @escaping (Bool) -> Void) in
            self.networkAllAd(complete: finish)
        }
    }

    /// 继续未完成的任务
    func continueTask() {
        // 1. 获取未完成的任务
        let tasks = BasicTaskQueue.unFinishedTask(isOpenApp: false, idPrefix: TaskIdPrefix.Advert.update.rawValue)
        // 2. 遍历任务
        for task in tasks {
            start(task: task)
        }
    }

    // MARK: - Private
    internal func networkAllAd(complete: @escaping (Bool) -> Void) {
        // 1.获取所有的广告位信息
        TSAdvertNetworkManager().getAllAdPositionId { (positionObject: [TSAdSpaceObject]?) in
            guard let spaceObjects = positionObject else {
                TSLogCenter.log.debug("没有广告位")
                complete(false)
                return
            }
            // 2.过滤掉移动端不需要的广告位
            // 因为返回的所有广告位，不全是移动端的广告位，也有 PC 端特有而移动端不用的广告位，这里把移动端可用的广告过滤出来
            let availableObjects = spaceObjects.flatMap { AdvertSpaceType(rawValue: $0.space) == nil ? nil : $0 }
            // 3.过滤一下广告位为空的情况
            if availableObjects.isEmpty {
                // 清空所有本地的广告信息
                TSDatabaseManager().advert.deleteAll()
                TSLogCenter.log.debug("广告位为空")
                complete(true)
                return
            }
            // 4.根据广告位信息获取所有的广告信息
            let spaceIds = availableObjects.map { $0.id }
            TSAdvertNetworkManager().getAd(spaceIds: spaceIds, complete: { (advertObjects: [TSAdvertObject]?) in
                guard let adObjects = advertObjects else {
                    TSLogCenter.log.debug("没有广告信息")
                    complete(false)
                    return
                }
                // 5.处理广告位和广告数据
                self.process(spaceObjects: spaceObjects, adObjects: adObjects, complete: { (newDatas: ([TSAdSpaceObject], [TSAdvertObject])?) in
                    // 处理失败
                    guard let (newSpaceObjects, newAdObjects) = newDatas else {
                        TSLogCenter.log.debug("处理广告数据失败")
                        complete(false)
                        return
                    }
                    // 处理成功
                    TSDatabaseManager().advert.save(spaceObjects: newSpaceObjects, update: true)
                    TSDatabaseManager().advert.save(objects: newAdObjects, update: true)
                    TSLogCenter.log.debug("更新广告信息成功")
                    complete(true)
                })
            })
        }
    }

    /// 处理广告位数据和广告数据
    ///
    /// - Note: 该方法有以下两个步骤 1.下载启动页广告的图片 2.图片下载完成后，再将广告位数据和广告数据保存到数据库
    internal func process(spaceObjects: [TSAdSpaceObject], adObjects: [TSAdvertObject], complete: @escaping (([TSAdSpaceObject], [TSAdvertObject])?) -> Void) {
        // 1.分开启动页数据和非启动页的数据
        let launchSpaceId = spaceObjects.flatMap { $0.space == AdvertSpaceType.launch.rawValue ? $0 : nil }.first?.id
        let launchAdObjects = adObjects.flatMap { $0.spaceId == launchSpaceId ? $0 : nil }
        let otherAdObjects = adObjects.flatMap { $0.spaceId != launchSpaceId ? $0 : nil }
        // 2.下载启动页广告中的所有图片
        let launchImageURLs = launchAdObjects.flatMap { $0.normalImage?.imageImage }
        downloadAllImages(urlStrings: launchImageURLs) { (imageDatas: [(String, UIImage)]?) in
            // 下载失败，结束
            guard let datas = imageDatas else {
                complete(nil)
                return
            }
            // 将图片转换成 data，保存在 object 中
            var newLauchAdObjects: [TSAdvertObject] = []
            for (urlString, image) in datas {
                let imageObjects = adObjects.flatMap { $0.normalImage?.imageImage == urlString ? $0 : nil }
                for imageObject in imageObjects {
                    imageObject.normalImage?.imageData = UIImagePNGRepresentation(image)! as NSData
                    newLauchAdObjects.append(imageObject)
                }
            }
            complete((spaceObjects, otherAdObjects + newLauchAdObjects))
        }
    }

    /// 下载所有图片
    func downloadAllImages(urlStrings: [String], complete: @escaping ([(String, UIImage)]?) -> Void) {
        // 1.将 urlString 转换成 url
        let urls = urlStrings.flatMap { URL(string: $0) }
        if urls.count < urlStrings.count {
            complete(nil) // 有无效链接，结束
            return
        }
        // 2.下载所有图片
        var imageDatas: [(String, UIImage)] = []
        let group = DispatchGroup()
        for url in urls {
            group.enter()
            ImageDownloader.default.downloadImage(with: url, options: nil, progressBlock: nil) { (image: Image?, _, url: URL?, _) in
                if let image = image, let url = url {
                    imageDatas.append(url.absoluteString, image)
                }
                group.leave()
            }
        }
        group.notify (queue: DispatchQueue.main) {
            if imageDatas.count == urls.count {
                complete(imageDatas)
            } else {
                complete(nil)
            }
        }
    }
}
