//
//  TSDatabaseMoment.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  数据库 - 动态相关

import UIKit
import RealmSwift
import Kingfisher

// MARK: - 当动态详情页和动态发布页重写后，这个类就该删除了
class TSDatabaseMoment {

    private let realm: Realm!
    // MARK: - Lifecycle
    convenience init() {
        let realm = try! Realm()
        self.init(realm)
    }

    /// 可以替换掉内部数据的初始化方法,用于测试
    ///
    /// - Parameter realm: 数据库
    init(_ realm: Realm) {
        self.realm = realm
    }

    // MARK: - 删除

    /// 退出登录时清除信息
    func deleteAll() {
        deleteList()

        let paid = realm.objects(TSPaidFeedObject.self)
        try! realm.write {
            realm.delete(paid)
        }
    }

    // MARK: - 动态列表

    // MARK: 获取信息

    /// 获取发送失败的动态
    func getFaildSendMoments() -> [TSMomentListObject] {
        // sendState = 0 发送中， sendState = 1 发送成功 sendState  = 2 发送失败
        let faildMoments = realm.objects(TSMomentListObject.self).filter("now == 1 AND sendState != 1").sorted(byKeyPath: "localCreate", ascending: true).reversed()
        return Array(faildMoments)
    }

    /// 获取发送失败的动态
    func getFaildSendMomentsByTopicId(topicId: Int) -> [TSMomentListObject] {
        // sendState = 0 发送中， sendState = 1 发送成功 sendState  = 2 发送失败
        let faildMoments = realm.objects(TSMomentListObject.self).filter("now == 1 AND sendState != 1").sorted(byKeyPath: "localCreate", ascending: true).reversed().filter({ (moment) -> Bool in
            var topics: List<TopicListObject> = moment.topics
            var hasTopic = false
            let topicsIsNil = moment.topics == nil
            if !topicsIsNil {
                for topic in topics {
                    if topic.topicId == topicId {
                       hasTopic = true
                       break
                    }
                }
            }
            return hasTopic
        })
        return Array(faildMoments)
    }
    /// 获取单条动态
    ///
    /// - Parameter type: 列表类型
    /// - Returns: 结果
    func getList(_ feedIdentity: Int) -> TSMomentListObject? {
        let momentList = realm.objects(TSMomentListObject.self).filter("\(feedIdentity) == feedIdentity")
        if momentList.isEmpty {
            return nil
        }
        return momentList.first
    }

    // MARK: 写入信息

    /// 写入置顶动态
    func saveTop(moment objects: [TSMomentListObject]) {
        save(moments: objects) { (object, result) in
            if !result.isEmpty {
                // 保持最新列表的顺序
                object.localCreate = result.first!.localCreate
                object.isTop = true
            }
        }
    }

    /// 写入用户的动态信息
    ///
    /// - Parameters:
    ///   - objects: 用户动态数据模型数组
    func save(userMoments userIdentitys: Int, objects: [TSMomentListObject]) {
        save(moments: objects)
    }

    /// 写入普通动态信息
    ///
    /// - Parameter objects: 动态模型
    func save(moments objects: [TSMomentListObject]) {
        save(moments: objects) { (object, result) in
            if !result.isEmpty {
                // 保持最新列表的顺序
                object.localCreate = result.first!.localCreate
            }
        }
    }

    /// 写入动态
    ///
    /// - Parameters:
    ///   - objects: 动态数组
    ///   - operation: 写入时进行的操作（方法内已经处理 hot/follow/new/channelsIdentity 标签）
    func save(moments objects: [TSMomentListObject], operation: ((_ object: TSMomentListObject, _ oldObject: Results<TSMomentListObject>) -> Void)?) {
        for object in objects {
            realm.beginWrite()
            let result = realm.objects(TSMomentListObject.self).filter("feedIdentity == \(object.feedIdentity)")
            if !result.isEmpty {
                object.hot = result.first!.hot
                object.follow = result.first!.follow
                object.now = result.first!.now
                object.isTop = result.first!.isTop
                object.channelsIdentity.value = result.first!.channelsIdentity.value
            }
            if let operation = operation {
                operation(object, result)
            }
            realm.add(object, update: true)
            try! realm.commitWrite()
        }
    }

    // MARK: 删除
    /// 删除某条动态
    func delete(moment feedIdentity: Int) {
        let moment = realm.objects(TSMomentListObject.self).filter("feedIdentity == \(feedIdentity)")
        if let momentObject = moment.first {
            try! realm.write {
                realm.delete(momentObject.comments)
                realm.delete(momentObject)
            }
        }
    }

    /// 退出登录时清空动态列表
    func deleteList() {
        let listObjects = realm.objects(TSMomentListObject.self)
        let imageObjects = realm.objects(TSImageObject.self)
        try!  realm.write {
            realm.delete(listObjects)
            // 清除所有图片
            realm.delete(imageObjects)
        }
    }

    /// 删除某个用户的动态列表
    func delete(listWithUserIdentity userIdentity: Int) {
        let oldLists = realm.objects(TSMomentListObject.self).filter("userIdentity == \(userIdentity)")
        for oldObject in oldLists {
            realm.beginWrite()
            let isBelongHomaPageMoments = oldObject.hot == 1 || oldObject.now == 1 || oldObject.follow == 1
            if !isBelongHomaPageMoments { // 如果该动态也属于主页列表，就不删除
                // 删除
                realm.delete(oldObject)
            }
            try! realm.commitWrite()
        }
    }

    // MARK: - 发布

    // MARK: 删除
    /// 删除一行发布成功的动态
    func deleteRelease(feedMark: Int64) {
        try! realm.write {
            let moments = realm.objects(TSMomentListObject.self).filter("feedMark == \(feedMark)")
            realm.delete(moments)
        }
    }

    // MARK: 写入信息
    /// 储存发布动态任务
    ///
    /// - Parameter momentList: 任务模型
    func save(momentRelease: TSMomentListObject) {
        try! realm.write {
            realm.add(momentRelease, update: true)
            try! realm.commitWrite()
        }
    }

    /// app启动时更改未发布的状态
    ///
    /// - Parameter momentRelease: 返回更改后的模型
    func replace(momentRelease: [TSMomentListObject]) {
        for item in momentRelease {
            if item.sendState == 0 {
                realm.beginWrite()
                item.sendState = 2
                try! realm.commitWrite()
            }
        }
    }

    // 动态发布 参数 转成 object
    func save(feedID: Int?, shortVideoOutputUrl: String, feedContent: String, feedTitle: String?, coordinate:(latitude: String, longtitude: String)?, imageCacheKeys: [String], imageSizes: [CGSize], imageMimeTypes: [String], userId: Int, nsDate: NSDate, textPrice: Int? = nil, imagePrice: [TSImgPrice]? = nil, topicsInfo: [TopicCommonModel]? = []) -> TSMomentListObject {
        let momentListObject = save(feedID: feedID, feedContent: feedContent, feedTitle: feedTitle, coordinate: coordinate, imageCacheKeys: imageCacheKeys, imageSizes: imageSizes, imageMimeTypes: imageMimeTypes, userId: userId, nsDate: nsDate, textPrice: textPrice, imagePrice: imagePrice, topicsInfo: topicsInfo)
        momentListObject.shortVideoOutputUrl = shortVideoOutputUrl
        return momentListObject
    }

    func save(feedID: Int?, feedContent: String, feedTitle: String?, repostModel: TSRepostModel? = nil, coordinate: (latitude: String, longtitude: String)?, imageCacheKeys: [String], imageSizes: [CGSize], imageMimeTypes: [String], userId: Int, nsDate: NSDate, textPrice: Int? = nil, imagePrice: [TSImgPrice]? = nil, topicsInfo: [TopicCommonModel]? = []) -> TSMomentListObject {
        let momentListObject = TSMomentListObject()
        if let feedid = feedID {
            momentListObject.feedIdentity = feedid
        } else {
            momentListObject.feedIdentity = TSCurrentUserInfo.share.createResourceID()
        }
        momentListObject.primaryKey = momentListObject.feedIdentity
        momentListObject.userIdentity = userId
        momentListObject.now = 1
        momentListObject.follow = 1
        momentListObject.sendState = 0
        momentListObject.title = feedTitle ?? ""
        momentListObject.content = feedContent
        momentListObject.from = 3
        momentListObject.isDigg = 0
        momentListObject.commentCount = 0
        momentListObject.view = 0
        momentListObject.digg = 0
        momentListObject.isCollect = 0
        momentListObject.create = nsDate
        if let repostModel = repostModel {
            momentListObject.repostID = repostModel.id
            /// 由于model的tyle不能存储，所以用一个等效的string字段保存
            repostModel.typeStr = repostModel.type.rawValue
            momentListObject.repostModel = repostModel
            if repostModel.type == .postWord || repostModel.type == .postImage || repostModel.type == .postVideo {
                momentListObject.repostType = "feeds"
            } else if repostModel.type == .group {
                momentListObject.repostType = "groups"
            } else if repostModel.type == .groupPost {
                momentListObject.repostType = "group-posts"
            } else if repostModel.type == .question {
                momentListObject.repostType = "questions"
            } else if repostModel.type == .questionAnswer {
                momentListObject.repostType = "question-answers"
            } else if repostModel.type == .news {
                momentListObject.repostType = "news"
            }
        }
        if let coordinate = coordinate {
            momentListObject.latitude = coordinate.latitude
            momentListObject.longtitude = coordinate.latitude
        }

        if imageCacheKeys.isEmpty == false {
            for (index, cacheKey) in imageCacheKeys.enumerated() {
                let picture = TSImageObject()
                picture.height = imageSizes[index].height
                picture.width = imageSizes[index].width
                picture.mimeType = imageMimeTypes[index]
                picture.cacheKey = cacheKey
                picture.storageIdentity = TSCurrentUserInfo.share.createResourceID()
                momentListObject.pictures.append(picture)
            }
        }

        if let textPrice = textPrice {
            if textPrice > 0 {
                momentListObject.textPrice = textPrice
            }
        }
        if let imagePrice = imagePrice {
            for (index, picture) in momentListObject.pictures.enumerated() {
                picture.price = imagePrice[index].sellingPrice
                picture.payType = imagePrice[index].paymentType.rawValue
            }
        }
        if topicsInfo?.isEmpty == true || topicsInfo == nil {
         } else {
            for item in topicsInfo! {
                let topicObj = TopicListObject()
                topicObj.topicId = item.id
                topicObj.topicTitle = item.name
                momentListObject.topics.append(topicObj)
            }
        }
        return momentListObject
    }

    // MARK: - 动态操作

    // MARK: Count
    /// 更新浏览数量
    func change(view object: TSMomentListObject) {
        try! realm.write {
            object.view += 1
        }
    }

    /// 更新收藏数量
    func change(collect object: TSMomentListObject) {
        try! realm.write {
            object.isCollect = object.isCollect == 0 ? 1 : 0
        }
    }

    /// 更新赞状态
    func change(digg object: TSMomentListObject) {
        try! realm.write {
            object.isDigg = object.isDigg == 0 ? 1 : 0
            object.digg = object.isDigg == 0 ? object.digg - 1 : object.digg + 1
        }
    }

    /// 更新图片付费状态
    func change(paidImage image: TSImageObject) {
        try! realm.write {
            image.paid.value = true
        }
    }

}
