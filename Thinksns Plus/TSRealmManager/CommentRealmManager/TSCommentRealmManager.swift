//
//  TSCommentRealmManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  评论数据库管理

import Foundation
import RealmSwift

class TSCommentRealmManager {
    fileprivate let realm: Realm!

    // MARK: - Lifecycle
    init() {
        let realm = try! Realm()
        self.realm = realm
    }

    /// 删除整个表
    func deleteAll() {
        self.deleteAllComments()
        self.deleteAllFailedComments()
    }
}

// MARK: - 通用评论数据库管理(网络请求下来的，正常展示的)
extension TSCommentRealmManager {

    /// 获取评论列表
    ///
    /// - Parameters:
    ///   - type: 评论的类型/场景(必填)
    ///   - sourceId: 评论的对象的id(必填)
    /// - Note: 
    ///   - 置顶评论全部获取，如果置顶后超过15条则不再获取，否则获取凑够15条或剩余全部获取。
    ///   - 关于排序问题，默认id自增时间靠后，这里按照默认的存取。
    ///   - 关于置顶问题：置顶的既要单独置顶状态展示，也要在普通列表中作为正常的评论展示。但他们其实是同一个，因为id一样。
    func get(type: TSCommentType, sourceId: Int) -> [TSCommentModel] {
        var commentList: [TSCommentModel] = [TSCommentModel]()
        var topList: [TSCommentModel] = [TSCommentModel]()
        var normalList: [TSCommentModel] = [TSCommentModel]()
        // 0. 获取指定条件下的所有相关评论
        let allFilter = String(format: "commentTableId == \(sourceId) AND commentTableType == '%@'", type.rawValue)
        // id 降序，时间降序
        let allObjects = realm.objects(TSCommentObject.self).filter(allFilter).sorted(byKeyPath: "id", ascending: false)
        // 1. 获取置顶状态的评论
        let topFilter = String(format: "isTop == true")
        let topObjects = allObjects.filter(topFilter)
        for object in topObjects {
            topList.append(TSCommentModel(object: object))
        }
        // 2. 获取正常状态的评论
        let count: Int = TSAppConfig.share.localInfo.limit
        let limit = topList.count >= count ? 0 : count - topList.count
        var i: Int = 0
        for object in allObjects {
            if i < limit {
                let normalModel = TSCommentModel(object: object)
                normalModel.isTop = false  // 取消置顶状态
                normalList.append(normalModel)
                i += 1
            } else {
                break
            }
        }
        commentList = topList + normalList
        // 3. 评论模型中的用户获取
        for commentModel in commentList {
            commentModel.user = TSDatabaseManager().user.getUserInfo(userId: commentModel.userId)
            if let replyUserId = commentModel.replyUserId {
                commentModel.replyUser = TSDatabaseManager().user.getUserInfo(userId: replyUserId)
            }
        }
        return commentList
    }
    /// 获取普通评论列表，不含置顶标识的(置顶评论设置为正常评论返回)
    ///
    /// - Parameters:
    ///   - type: 评论的类型/场景(必填)
    ///   - sourceId: 评论的对象的id(必填)
    ///   - afterId: 翻页获取时传入上一页的最后id，如果没有则传入nil。(必填，以避免都使用默认参数同上面重载)
    ///   - limit: 最大限制(可选)
    /// - Note:
    ///   - 关于afterId的传入问题，采用上面的获取后，需要判断最后一个是否为置顶标识。为置顶则传nil。
    func get(type: TSCommentType, sourceId: Int, afterId: Int?, limit: Int = TSAppConfig.share.localInfo.limit) -> [TSCommentModel] {
        let filter = String(format: "commentTableId == \(sourceId) AND commentTableType == '%@'", type.rawValue)
        // id 降序，时间降序
        var objects = realm.objects(TSCommentObject.self).filter(filter).sorted(byKeyPath: "id", ascending: false)
        if let afterId = afterId {
            if afterId > 0 {
                objects = objects.filter("id < \(afterId)")
            }
        }
        // 2. LimitResult
        var modelList = [TSCommentModel]()
        var i: Int = 0
        for object in objects {
            if i < limit {
                let commentModel = TSCommentModel(object: object)
                modelList.append(commentModel)
            }
            i += 1
        }
        // 3. 评论模型中的用户获取
        for commentModel in modelList {
            commentModel.user = TSDatabaseManager().user.getUserInfo(userId: commentModel.userId)
            if let replyUserId = commentModel.replyUserId {
                commentModel.replyUser = TSDatabaseManager().user.getUserInfo(userId: replyUserId)
            }
        }
        return modelList
    }

    /// 保存评论列表
    func save(_ list: [TSCommentModel]) -> Void {
        for model in list {
            realm.beginWrite()
            realm.add(model.object(), update: true)
            try! realm.commitWrite()
        }
    }
    fileprivate func save(_ list: [TSCommentObject]) -> Void {
        realm.beginWrite()
        realm.add(list, update: true)
        try! realm.commitWrite()
    }

    /// 保存指定的评论
    func save(_ comment: TSCommentModel) -> Void {
        self.save(comment.object())
    }
    fileprivate func save(_ comment: TSCommentObject) -> Void {
        realm.beginWrite()
        realm.add(comment, update: true)
        try! realm.commitWrite()
    }

    /// 删除指定的评论
    func deleteComment(commentId: Int) -> Void {
        guard let object = realm.object(ofType: TSCommentObject.self, forPrimaryKey: commentId) else {
            return
        }
        try! realm.write {
            realm.delete(object)
        }
    }
    fileprivate func delete(_ comment: TSCommentModel) -> Void {
        self.deleteComment(commentId: comment.id)
    }
    fileprivate func delete(_ comment: TSCommentObject) -> Void {
        self.deleteComment(commentId: comment.id)
    }

    /// 删除指定资源下的所有的评论(如指定专辑、指定歌曲、指定资讯、指定动态、指定问答等等)
    func deleteAllComment(type: TSCommentType, sourceId: Int) -> Void {
        let filter = String(format: "commentTableId == \(sourceId) AND commentTableType == '%@'", type.rawValue)
        let objects = realm.objects(TSCommentObject.self).filter(filter)
        try! realm.write {
            realm.delete(objects)
        }
    }

    /// 删除所有的评论
    func deleteAllComments() -> Void {
        let objects = realm.objects(TSCommentObject.self)
        try! realm.write {
            realm.delete(objects)
        }
    }
}

// MARK: - 发送失败的评论数据库管理(仅存于本地)
extension TSCommentRealmManager {
    /// 获取全部发送失败的评论列表
    func getAllFailedComments(type: TSCommentType, sourceId: Int) -> [TSFailedCommentModel] {
        let filter = String(format: "commentTableId == \(sourceId) AND commentTableType == '%@'", type.rawValue)
        // id 降序，时间降序
        let objects = realm.objects(TSFailedCommentObject.self).filter(filter).sorted(byKeyPath: "id", ascending: false)
        var modelList = [TSFailedCommentModel]()
        for object in objects {
            let faildModel = TSFailedCommentModel(object: object)
            modelList.append(faildModel)
        }
        // 评论模型中的用户获取
        for commentModel in modelList {
            commentModel.user = TSDatabaseManager().user.getUserInfo(userId: commentModel.userId)
            if let replyUserId = commentModel.replyUserId {
                commentModel.replyUser = TSDatabaseManager().user.getUserInfo(userId: replyUserId)
            }
        }
        return modelList
    }

    /// 保存指定的失败的评论
    func save(_ comment: TSFailedCommentModel) -> Void {
        self.save(comment.object())
    }
    fileprivate func save(_ comment: TSFailedCommentObject) -> Void {
        realm.beginWrite()
        realm.add(comment, update: true)
        try! realm.commitWrite()
    }

    /// 删除指定的失败的评论
    func deleteFaildComment(commentId: Int) -> Void {
        guard let object = realm.object(ofType: TSFailedCommentObject.self, forPrimaryKey: commentId) else {
            return
        }
        try! realm.write {
            realm.delete(object)
        }
    }
    fileprivate func delete(_ comment: TSFailedCommentModel) -> Void {
        self.deleteFaildComment(commentId: comment.id)
    }
    fileprivate func delte(_ comment: TSFailedCommentObject) -> Void {
        self.deleteFaildComment(commentId: comment.id)
    }

    /// 删除指定资源下所有失败的评论(如指定专辑、指定歌曲、指定资讯、指定动态、指定问答等等)
    func deleteAllFailedComments(type: TSCommentType, sourceId: Int) -> Void {
        let filter = String(format: "commentTableId == \(sourceId) AND commentTableType == '%@'", type.rawValue)
        let objects = realm.objects(TSFailedCommentObject.self).filter(filter)
        try! realm.write {
            realm.delete(objects)
        }
    }

    /// 删除失败的所有的评论
    func deleteAllFailedComments() -> Void {
        let failedObjects = realm.objects(TSFailedCommentObject.self)
        try! realm.write {
            realm.delete(failedObjects)
        }
    }
}

// MARK: - TSSimpleCommentModel

extension TSCommentRealmManager {
    /// 根据TSSimpleCommentModel进行删除
    func deleteComment(_ comment: TSSimpleCommentModel) -> Void {
        // 正在发送中
        if 2 == comment.status {
        }
        // 发送失败，本地保存
        else if 1 == comment.status {
            self.deleteFaildComment(commentId: comment.id)
        }
        // 发送成功的
        else if 0 == comment.status {
            self.deleteComment(commentId: comment.id)
        }
    }
}

// MARK: - TSCommentViewModel

extension TSCommentRealmManager {
    /// 根据TSCommentViewModel直接删除数据库中对应的评论
    func deleteComment(_ comment: TSCommentViewModel) -> Void {
        switch comment.status {
        case .sending:
            break
        case .normal:
            self.deleteComment(commentId: comment.id)
        case .faild:
            self.deleteFaildComment(commentId: comment.id)
        }
    }
}
