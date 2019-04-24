//
//  TSNewsTaskManager.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  资讯模块的网络请求管理类

import UIKit
import RealmSwift
import ReachabilitySwift

typealias NewsFullModel = (newsDetail: NewsDetailModel, comment: [TSSimpleCommentModel], advert: [TSAdvertObject], newsCorrelative: [NewsModel])

class TSNewsTaskManager: NSObject {
    /// 资讯列表每页请求的最大条数
    static let limit: Int = TSAppConfig.share.localInfo.limit
    /*----------评论相关-------------*/
    /// 最大错误请求次数
    let maxErrorRequest = 3
    /// 错误请求次数
    var errorCount = 0
    /// 收藏队列记录
    var collectNetCountArray: [Int: Int] = [:]
    /// 点赞网络请求次数记录
    var diggNetCountArray: [Int: Int] = [:]
    /// 收藏的网络请求次数
    let networkCountMax = 1

    // MARK: - Public
    // MARK: 资讯栏目
    /// 资讯栏目队列 获取所有栏目数据
    ///
    /// - Parameters:
    ///   - complate: 结果
    func star(complate: @escaping(_ success: TSNewsAllTagsModel?, _ result: Bool?) -> Void) {
        // 更新所有的栏目标记
        self.networkForAllTags(complete: complate)
    }

    /// 从接口获取栏目数据
    ///
    /// - Parameter complete: TSNewsAllTagsModel
    private func networkForAllTags(complete: @escaping(_ success: TSNewsAllTagsModel?, _ result: Bool?) -> Void) {
        TSNewsNetworkManager().getNewsAllTags { (data, result) in
            if data == nil {
                complete(nil, result)
                return
            }
            // 添加默认的订阅栏目
            let defaultObject = TSNewsTagObject()
            defaultObject.index = 0
            defaultObject.isMarked = 1
            defaultObject.name = "推荐"
            defaultObject.tagID = -1
            data?.markedTags.insert(defaultObject, at: 0)

            var DatasForSave: [TSNewsTagObject] = []
            for model in data!.markedTags {
                DatasForSave.append(model)
            }
            for model in data!.unmarkedTags {
                DatasForSave.append(model)
            }
            /// 更新数据库
            TSDatabaseNews().save(allNewsTags: DatasForSave)
            /// 返回数据
            complete(data, nil)
        }
    }

    /// 从数据库获取栏目数据
    ///
    /// - Parameter complete: 结果
    private func databaseForAllTags(complete: @escaping(_ success: TSNewsAllTagsModel?, _ faild: Error?) -> Void) {
        let model = TSNewsAllTagsModel()
        model.markedTags = TSDatabaseNews().selectTagsFromDataBase(WithCriteriaString: "isMarked = 1", sortKey: "index")
        model.unmarkedTags = TSDatabaseNews().selectTagsFromDataBase(WithCriteriaString: "isMarked = 0", sortKey: "tagID")
        complete(model, nil)
    }

    /// 栏目订阅队列
    ///
    /// - Parameters:
    ///   - tags: 订阅栏目数组 <TSNewsTagObject>
    ///   - unTags: 未订阅的栏目 <TSNewsTagObject>
    ///   - complate: 结果
    func star(collectionTags tags: [TSNewsTagObject], unCollectionTags unTags: [TSNewsTagObject], complete: @escaping(_ msg: String?, _ status: Bool) -> Void) {
        network(collectionTags: tags, uncollectionTags: unTags, complete: complete)
    }

    /// 订阅栏目的网络请求
    ///
    /// - Parameters:
    ///   - tags: 订阅的栏目
    ///   - unTags: 未订阅的栏目
    ///   - complate: 结果
    private func network(collectionTags tags: [TSNewsTagObject], uncollectionTags unTags: [TSNewsTagObject], complete: @escaping(_ msg: String?, _ status: Bool) -> Void) {
        if tags.isEmpty {
            return
        }
        var ids = ""
        for i in 1..<tags.count {
            let object = tags[i]
            if i == 1 {
                ids.append("\(object.tagID)")
            } else {
                ids.append(",\(object.tagID)")
            }
        }
        TSNewsNetworkManager().markTags(tagids: ids) { (msg, status) in
            complete(msg, status)
            if status {
                /// 更新数据库数据
                TSDatabaseNews().uploadTagInfo(tags: tags, isMarked: true)
                TSDatabaseNews().uploadTagInfo(tags: unTags, isMarked: false)
            }
        }
    }

    // MARK: - 资讯列表
    /// 获取最新的资讯置顶信息和资讯信息组成列表
    func refreshNewsListData(tagID: Int, complete: @escaping((_ info: [NewsModels]?, _ error: Error?) -> Void)) {
        // 如果 tagID == -1 表示需要抓取推荐数据
        if tagID == -1 {
            var news: [NewsModels] = []
            news.append([])
            news.append([])
            TSNewsNetworkManager.getNewsListData(tagID: -1, maxID: nil, limit: TSAppConfig.share.localInfo.limit, isCheckCommend: true) { (newsModels, error) in
                if error == nil {
                    news[1] = newsModels!
                    complete(news, nil)
                } else {
                    complete(nil, TSErrorCenter.create(With: .networkError))
                }
            }
        } else {
            getNewsListData(tagID: tagID, complete: complete)
        }
    }

    func getNewsListData(tagID: Int, complete: @escaping((_ info: [NewsModels]?, _ error: Error?) -> Void)) {
        let group = DispatchGroup()
        var news: [NewsModels] = []
        news.append([])
        news.append([])
        var networkError = [true, true]
        group.enter()
        TSNewsNetworkManager.getTopNewsListData(tagID: tagID) { (TopNewsModels, error) in
            if error == nil {
                news[0] = TopNewsModels!
            } else {
                networkError[0] = false
            }
            group.leave()
        }

        group.enter()
        TSNewsNetworkManager.getNewsListData(tagID: tagID, maxID: nil, limit: TSAppConfig.share.localInfo.limit, isCheckCommend: false) { (newsModels, error) in
            if error == nil {
                news[1] = newsModels!
            } else {
                networkError[1] = false
            }
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            if networkError[0] == false || networkError[1] == false {
                complete(nil, TSErrorCenter.create(With: .networkError))
                return
            }
            complete(news, nil)
        }
    }

    /// 获取更多的资讯信息加入到列表
    func loadMoreNewsListData(tagID: Int, maxID: Int, complete: @escaping((_ info: [NewsModel]?, _ error: Error?) -> Void)) {
        // 如果 tagID == -1 表示需要抓取推荐数据
        if tagID == -1 {
            TSNewsNetworkManager.getNewsListData(tagID: tagID, maxID: maxID, limit: TSAppConfig.share.localInfo.limit, isCheckCommend: true) { (newsModels, error) in
                if error == nil {
                    complete(newsModels, nil)
                } else {
                    complete(nil, error)
                }
            }
        } else {
            TSNewsNetworkManager.getNewsListData(tagID: tagID, maxID: maxID, limit: TSAppConfig.share.localInfo.limit, isCheckCommend: false) { (newsModels, error) in
                if error == nil {
                    complete(newsModels, nil)
                } else {
                    complete(nil, error)
                }
            }
        }
    }

    /// 获取数据库存储的置顶信息和资讯信息组成的列表
    func getNewsListDataFromRealm() {
    }

    /// 更新置顶信息和资讯信息组成的列表到数据库
    func updateNewsListDataInRealm() {
    }

    // MARK: - 资讯详情
    /// 资讯详情页面数据载入
    func refreshNewsData(newsID: Int, limit: Int, complete: @escaping((_ data: NewsFullModel?, _ error: Error?, _ code: Int?) -> Void)) {
        var serverData = (newsDetail: NewsDetailModel(), comment: [TSSimpleCommentModel](), advert: [TSAdvertObject](), newsCorrelative: [NewsModel]())
        TSNewsNetworkManager().requesetNews(newsID: newsID) { (newsDetailModel, _, code) in
            guard let newsDetailModel = newsDetailModel else {
                complete(nil, TSErrorCenter.create(With: .networkError), code)
                return
            }
            serverData.newsDetail = newsDetailModel
            serverData.advert = TSDatabaseManager().advert.getObjects(type: .newsDetail)

            let remainTaskGroup = DispatchGroup()
            remainTaskGroup.enter()
            TSCommentTaskQueue.getCommentList(type: .news, sourceId: newsID, afterId: nil, limit: limit, complete: { (commentList, msg, status) in
                if status, let commentList = commentList {
                    serverData.comment = commentList
                }
                remainTaskGroup.leave()
            })

            remainTaskGroup.enter()
            TSNewsNetworkManager().requestCorrelative(newsID: newsID, limit: 3, complete: { (newsModel, _) in
                if let newsModel = newsModel {
                    serverData.newsCorrelative = newsModel
                }
                remainTaskGroup.leave()
            })

            remainTaskGroup.notify(queue: DispatchQueue.main, execute: {
                complete(serverData, nil, code)
            })
        }
    }
}
