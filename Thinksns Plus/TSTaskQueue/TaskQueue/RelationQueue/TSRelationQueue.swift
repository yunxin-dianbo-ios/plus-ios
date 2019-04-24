//
//  TSRelationQueue.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 用户关系队列

import UIKit
import RealmSwift
import Kingfisher

class TSRelationQueue: NSObject {

    enum FollowAndFansKey: String {
        case fans = "followeds"
        case follow = "follows"
    }

    static let netWorkCount = 5
    /// 关注状态类型
    enum RelationState {
        case follow
        case unfollow
        case bothFollow
    }

    /// 用户关系网络请求次数记录
    var relationNetCountArray: [Int: Int] = [:]

    // MARK: - Public

    /// 点赞榜的取消和关注按钮
    ///
    /// - Parameters:
    ///   - model: 数据模型
    ///   - status: 按钮状态
    func followOrCancel(model: TSFollowFansListModel, status: PraiseButtonImageName, complete: @escaping (Bool, NSError?) -> Void) {
        let userRelation = TSDatabaseManager().user.get(relation: (TSCurrentUserInfo.share.accountToken?.userIdentity)!, between: model.userId)
        let relation = TSUserRelationObject()
        relation.followedIdentity = (userRelation?.followedIdentity)!
        relation.followingIdentity = (userRelation?.followingIdentity)!
        relation.id = (userRelation?.id)!
        relation.maxId = (userRelation?.maxId)!

        switch status {
        case .eachother:
            relation.state = 0
        case .unfollow:
            relation.state = 1
        case .follow:
            relation.state = 0
        }

        TSDatabaseManager().user.save(relations: [relation])
        // 关注取关队列
        self.cancelFollowQueue(userId: model.userId, type: relation.state == 0 ? .cancel : .follow, maxRequestCount: 3) { (isSuccess, error) in
            complete(isSuccess, error)
        }
    }

    /// 关注或取关队列
    ///
    /// - Parameters:
    ///   - userId: 对方的id
    ///   - type: 类型
    ///   - maxRequestCount: 最大错误请求次数
    ///   - complete: 完成后回调
    func cancelFollowQueue(userId: Int, type: TSUserIsCancelFollow, maxRequestCount: Int, complete: @escaping (Bool, NSError?) -> Void) {
        // 数据库
        TSDatabaseManager().user.change(currentUserFollowNumber: type == .follow ? true : false)
        // 先保存任务
        TSDataQueueManager.share.relationQueue.followOrCancelTask(userId: userId, isFollow: type)
        // 请求
        TSRelationQueueHandle().isCancelFollowRquestHandle(userId: userId, type: type, maxRequestCount: maxRequestCount) { (isSuccess, error) in
            complete(isSuccess, error)
        }
    }

    /// 获取用户粉丝关注列表
    ///
    /// - Parameters:
    ///   - relationType: 关注类型
    ///   - userId: 用户id
    ///   - max_id: 上页最大ID
    ///   - isQueryDB: 是否需要展示数据库的数据
    func getList(reloadType: TSFollowFansListDetailVC.ReloadType, relationType: TSUserRelationType, userId: Int, max_id: Int?, complete: @escaping (Bool, NSError?) -> Void) {

        // 网络请求
        TSRelationQueueHandle().dataRequestHandle(userId: userId, maxId: max_id, relationType: relationType, maxRequestCount: 3) { (_, responseData, error) in
            if let error = error {
                // 出错
                complete(false, error)
                return
            }

            guard let dataDic = responseData else {
                complete(false, nil)
                return
            }

            var followsId: [Dictionary<String, Int>]?
            switch relationType {
            case .follow:
                if reloadType == TSFollowFansListDetailVC.ReloadType.refresh {
                    TSDatabaseManager().user.delete(followListUserId: userId)
                }
                followsId = dataDic[FollowAndFansKey.follow.rawValue] as? [Dictionary<String, Int>]
            case .fans:
                if reloadType == TSFollowFansListDetailVC.ReloadType.refresh {
                    TSDatabaseManager().user.delete(fasListUserId: userId)
                }
                followsId = dataDic[FollowAndFansKey.fans.rawValue] as? [Dictionary<String, Int>]
            }

            if let followsId = followsId {
                if followsId.isEmpty {
                    complete(false, nil)
                    return
                }
                let objects = TSRelationTool.relationCombination(followAndFans: followsId, relationType: relationType)
                if !objects.isEmpty {
                    TSRelationQueryWriteDB().writeFollowAndFans(relations: objects)
                    TSRelationQueryWriteDB().writeFollowAndFansID(relationType: relationType, userId: userId, followAndFansId: followsId)
                     complete(true, nil)
                }
            }
        }
    }

    /// 保存关注或取关任务
    ///
    /// - Parameters:
    ///   - userId: 用户id
    ///   - isFollow: 是否关注 0取关， 1关注
    func followOrCancelTask(userId: Int, isFollow: TSUserIsCancelFollow) {
        let task = TSFollowOrCancelObject()
        task.userId = userId
        task.isFollow = isFollow == .follow ? 1 : 0
        TSDatabaseManager().user.save(followOrCancelTask: task)
    }

    /// 检查关注或取关的未完成任务
    func checkFollowOrCancelTask(isOpenApp: Bool) {
        if isOpenApp {
            let arr = TSDatabaseManager().user.getFollowOrCancel()
            guard let tasks = arr else {
                return
            }

            for item in tasks {
                let type = item.isFollow == 0 ? TSUserIsCancelFollow.cancel : TSUserIsCancelFollow.follow
                TSRelationQueueHandle().isCancelFollowRquestHandle(userId: item.userId, type: type, maxRequestCount: 0) { (_, _) in
                }
            }
        }
    }

    /// 获取点赞榜的显示数据
    ///
    /// - Parameters:
    ///   - feedId: 动态id
    ///   - feedDiggId: 翻页id (获取第一页数据传-1)
    ///   - isQueryUserInfoDB: 是否读取数据库信息
    ///   - complete: 返回的结果
    func getLikeListShowModel(feedId: Int, feedDiggId: Int, isQueryDB: Bool, complete: @escaping ([TSFollowFansListModel]?, NSError?) -> Void) {
        if isQueryDB {
            // 先从本地找数据
            var userIds: [Int] = Array()
            let listDatas = TSDatabaseManager().moment.getLikeList(feedId: feedId)
            guard let datas = listDatas else {
                /// 数据库没有数据就从网络请求
                getNetWorkLikeListDatas(feedId: feedId, feedDiggId: feedDiggId, isQueryDB: isQueryDB, complete: { (listModels, error) in
                    if let gollowFansListModels = listModels {
                        complete(gollowFansListModels, nil)
                        return
                    }
                    complete(nil, error)
                })
                return
            }

            /// 遍历所有用户ID拼接到数组中
            for item in datas.userInfos {
                userIds.append(item.userId)
            }

            /// 获取所有userId的关系，可能在极限情况下会出现数据不统一的情况，一旦不统一就请求网络数据
            for item in userIds {
                let relation = TSDatabaseManager().user.get(relation: (TSCurrentUserInfo.share.accountToken?.userIdentity)!, between: item)
                if relation == nil {
                    /// 这里是返回网络请求的结果
                    getNetWorkLikeListDatas(feedId: feedId, feedDiggId: feedDiggId, isQueryDB: isQueryDB, complete: { (listModels, error) in
                        if let gollowFansListModels = listModels {
                            complete(gollowFansListModels, nil)
                            return
                        }
                        complete(nil, error)
                        return
                    })
                    break
                }
            }

            /// 这里是返回数据库里的结果（能走到这里理论上必然会有数据）
            self.getUserInfo(dataList: Array((listDatas?.userInfos)!), isQueryDB: isQueryDB, complete: { (userInfos) in
                 complete(userInfos, nil)
            })
            return
        }

        /// 这里是不查询数据库直接请求网络
        getNetWorkLikeListDatas(feedId: feedId, feedDiggId: feedDiggId, isQueryDB: isQueryDB, complete: { (listModels, error) in
            if let gollowFansListModels = listModels {
                complete(gollowFansListModels, nil)
                return
            }
            complete(nil, error)
        })
    }

    // MARK: - Private

    /// 通过网络获取点赞榜的用户信息
    ///
    /// - Parameters:
    ///   - feedId: 动态id
    ///   - isQueryDB: 是否查询数据库
    ///   - complete: 返回的数据
    private func getNetWorkLikeListDatas(feedId: Int, feedDiggId: Int, isQueryDB: Bool, complete: @escaping ([TSFollowFansListModel]?, NSError?) -> Void) {
        var success = false
        var userIds: [Int] = Array()
        var dataList: TSLikeListObject?
        var listInfo: [ TSLikeListUserInfoObject] = Array()
        TSMomentNetworkManager().getLikeListAndSaveDataBase(feedId: feedId, feedDiggId: feedDiggId) { (isSuccess, error) in
            if isSuccess {
                let queue = DispatchQueue(label: "Queue")
                let group = DispatchGroup()
                queue.async(group: group, qos: .utility, flags: .assignCurrentContext) {
                    group.enter()
                    dataList = TSDatabaseManager().moment.getLikeList(feedId: feedId)
                    for item in (dataList?.userInfos)! {
                        let object = TSLikeListUserInfoObject()
                        object.feedDiggId = item.feedDiggId
                        object.userId = item.userId
                        listInfo.append(object)
                    }

                    if let datas = dataList {
                        for item in datas.userInfos {
                            userIds.append(item.userId)
                        }
                        /// 储存用户关系
                        TSUserNetworkingManager().getRelation(with: userIds, complete: { (relationModels, _) in
                            guard let relationModels = relationModels else {
                                group.leave()
                                return
                            }
                            for item in relationModels {
                                let object = item.convertToObject()
                                TSDatabaseManager().user.save(relations: object)
                            }
                            success = true
                            group.leave()
                        })
                    }
                }
                /// 获取用户信息
                group.notify(queue: .main) {
                    if success {
                        self.getUserInfo(dataList: listInfo, isQueryDB: isQueryDB, complete: { (userInfos) in
                            complete(userInfos, nil)
                        })
                    }
                    return
                }
            } else {
                complete(nil, error)
            }
        }
    }

    /// 获取用户信息
    ///
    /// - Parameters:
    ///   - userIds: 用户id
    ///   - complete: 完成后返回的用户信息
    private func getUserInfo(dataList: [TSLikeListUserInfoObject], isQueryDB: Bool, complete: @escaping ([TSFollowFansListModel]) -> Void) {
        var userDatas:[((userId: Int, maxId: Int))] = Array()
        for item in dataList {
            userDatas.append((item.userId, item.feedDiggId))
        }

        TSFollowFansListTool.synthesisUserInfo(userDatas: userDatas, isQueryDB: isQueryDB) { models in
            complete(models)
        }
    }

    // MARK: - 圈子相关

    // [长期注释] 时间紧迫，圈子相关代码直接复制动态的代码进行修改，请后面有时间的时候进行优化

    /// 获取帖子点赞榜的用户信息
    ///
    /// - Parameters:
    ///   - feedId: 动态id
    ///   - isQueryDB: 是否查询数据库
    ///   - complete: 返回的数据
    private func getNetWorkLikeListDatasForPost(groupId: Int, postId: Int, postMark: Int64, after: Int?, isQueryDB: Bool, complete: @escaping ([TSFollowFansListModel]?, NSError?) -> Void) {
        var success = false
        var userIds: [Int] = Array()
        var dataList: TSLikeListPostObject?
        var listInfo: [ TSLikeListUserInfoObject] = Array()
        TSMomentNetworkManager().getLikeListAndSaveDataBaseForPost(groupId: groupId, postId: postId, postMark: postMark, after: after) { (isSuccess, error) in
            if isSuccess {
                let queue = DispatchQueue(label: "Queue")
                let group = DispatchGroup()
                queue.async(group: group, qos: .utility, flags: .assignCurrentContext) {
                    group.enter()
                    dataList = TSDatabaseManager().moment.getLikeListForPost(postMark: postMark)
                    for item in (dataList?.userInfos)! {
                        let object = TSLikeListUserInfoObject()
                        object.feedDiggId = item.feedDiggId
                        object.userId = item.userId
                        listInfo.append(object)
                    }
                    if let datas = dataList {
                        for item in datas.userInfos {
                            userIds.append(item.userId)
                        }
                        /// 储存用户关系
                        TSUserNetworkingManager().getRelation(with: userIds, complete: { (relationModels, _) in
                            guard let relationModels = relationModels else {
                                group.leave()
                                return
                            }
                            for item in relationModels {
                                let object = item.convertToObject()
                                TSDatabaseManager().user.save(relations: object)
                            }
                            success = true
                            group.leave()
                        })
                    }
                }
                /// 获取用户信息
                group.notify(queue: .main) {
                    if success {
                        self.getUserInfo(dataList: listInfo, isQueryDB: isQueryDB, complete: { (userInfos) in
                            complete(userInfos, nil)
                        })
                    }
                    return
                }
            } else {
                complete(nil, error)
            }
        }
    }

    /// 获取点赞榜的显示数据
    ///
    /// - Parameters:
    ///   - feedId: 动态id
    ///   - feedDiggId: 翻页id (获取第一页数据传-1)
    ///   - isQueryUserInfoDB: 是否读取数据库信息
    ///   - complete: 返回的结果
    func getLikeListShowModelForPost(postMark: Int64, groupId: Int, postId: Int, after: Int?, isQueryDB: Bool, complete: @escaping ([TSFollowFansListModel]?, NSError?) -> Void) {
        if isQueryDB {
            // 先从本地找数据
            var userIds: [Int] = Array()
            let listDatas = TSDatabaseManager().moment.getLikeListForPost(postMark: postMark)
            guard let datas = listDatas else {
                /// 数据库没有数据就从网络请求
                getNetWorkLikeListDatasForPost(groupId: groupId, postId: postId, postMark: postMark, after: after, isQueryDB: isQueryDB, complete: { (listModels, error) in
                    if let gollowFansListModels = listModels {
                        complete(gollowFansListModels, nil)
                        return
                    }
                    complete(nil, error)
                })
                return
            }

            /// 遍历所有用户ID拼接到数组中
            for item in datas.userInfos {
                userIds.append(item.userId)
            }

            /// 获取所有userId的关系，可能在极限情况下会出现数据不统一的情况，一旦不统一就请求网络数据
            for item in userIds {
                let relation = TSDatabaseManager().user.get(relation: (TSCurrentUserInfo.share.accountToken?.userIdentity)!, between: item)
                if relation == nil {
                    /// 这里是返回网络请求的结果
                    getNetWorkLikeListDatasForPost(groupId: groupId, postId: postId, postMark: postMark, after: after, isQueryDB: isQueryDB, complete: { (listModels, error) in
                        if let gollowFansListModels = listModels {
                            complete(gollowFansListModels, nil)
                            return
                        }
                        complete(nil, error)
                        return
                    })
                    break
                }
            }

            /// 这里是返回数据库里的结果（能走到这里理论上必然会有数据）
            self.getUserInfo(dataList: Array((listDatas?.userInfos)!), isQueryDB: isQueryDB, complete: { (userInfos) in
                complete(userInfos, nil)
            })
            return
        }

        /// 这里是不查询数据库直接请求网络
        getNetWorkLikeListDatasForPost(groupId: groupId, postId: postId, postMark: postMark, after: after, isQueryDB: isQueryDB, complete: { (listModels, error) in
            if let gollowFansListModels = listModels {
                complete(gollowFansListModels, nil)
                return
            }
            complete(nil, error)
        })
    }
}
