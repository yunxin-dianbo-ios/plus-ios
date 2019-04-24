//
//  TSMusicTaskManager+comment.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import Foundation

extension TSMusicTaskManager {

    /// 获取音乐评论列表的队列
    /// PS:
    ///    1.下拉刷新获取到的数据是从数据库中读取，请求网络接口的作用是为了更新本地数据库
    ///    2.上拉加载获取到的数据是从接口获取 不保存到数据库
    ///    3.根据MaxID是否为0来判断上拉加载和下拉刷新操作
    ///
    /// - Parameters:
    ///   - id: 专辑或音乐的id
    ///   - type: 专辑或音乐
    ///   - maxID: 分页标记
    ///   - limit: 每页数据量
    ///   - need: 是否需要从网络更新本地数据库
    ///   - compate: 结果
    func star(musicCommentWithSourceID id: Int, commentType type: TSMusicCommentVC.commentType, maxID: Int, limit: Int?, needUploadDataBaseFromNet need: Bool, compate:@escaping(_ info: String?, _ data: [TSSimpleCommentModel]?, _ error: Error?) -> Void) {
        if !need {
            /// 不需要请求接口，直接读数据库中的数据
            database(musicCommentWithSourceID: id, commentType: type, compate: { (datas) in
                compate(nil, datas, nil)
            })
        } else {
            /// 请求接口 更新数据库或直接返回接口数据
            netWork(musicCommentWithSourceID: id, commentType: type, maxID: maxID, limit: limit, compate: { (info, datas, _) in
                if datas.isEmpty {
                    self.database(musicCommentWithSourceID: id, commentType: type, compate: { (datas) in
                        compate(nil, datas, nil)
                    })
                    return
                }
                compate(info, datas, nil)
            })
        }
    }

    /// 从接口获取评论数据
    ///
    /// - Parameters:
    ///   - id: 专辑或歌曲id
    ///   - type: 专辑或歌曲
    ///   - maxID: 分页标记
    ///   - limit: 每页条数
    ///   - compate: 结果
    func netWork(musicCommentWithSourceID id: Int, commentType type: TSMusicCommentVC.commentType, maxID: Int, limit: Int?, compate:@escaping(_ info: String?, _ data: [TSSimpleCommentModel], _ error: Error?) -> Void) {

        // TODO: MusicUpdate - 音乐模块更新中，To be removed
//        TSMusicNetworkManager().musicComment(CommentType: type, sourceID: id, maxID: maxID, limit: limit) { (info, data, error) in
//            if let error = error {
//                /// 接口请求错误，返回空数组
//                compate(info, [], error)
//                return
//            }
//
//            /// 下拉刷新更新数据库数据，不返回接口获取的数据
//            if maxID == 0 {
//                /// 保存评论到数据库
//                TSDatabaseMusic().save(MusicComments: data!, sending: 0, successed: 1)
//                /// 回调结果
//                compate(info, [], nil)
//                return
//            }
//
//            /// 上拉加载 不更新数据库 直接返回接口数据
//            var simpleCommentModelArray: [TSSimpleCommentModel] = []
//            for model in data! {
//                let simpleModel = self.makeSimpleMusicCommentModel(musicCommentModel: model)
//                simpleCommentModelArray.append(simpleModel)
//            }
//            compate(info, simpleCommentModelArray, nil)
//        }

        // 使用新版的网络请求接口
        let commentType: TSMusicCommentType = (type == .album) ? .special : .song
        TSMusicNetworkManager().getMusicCommentList(commentType: commentType, sourceId: id, maxId: maxID, limit: limit) { (_, _, _) in
            // TODO: MusicUpdate - 音乐模块更新中，To be done
        }
    }

    /// 从数据库中查找评论
    ///
    /// - Parameters:
    ///   - id: 专辑或歌曲id
    ///   - type: 专辑或歌曲
    ///   - compate: 结果
    func database(musicCommentWithSourceID id: Int, commentType type: TSMusicCommentVC.commentType, compate:@escaping(_ data: [TSSimpleCommentModel]?) -> Void) {
        var simpleCommentModelArray: [TSSimpleCommentModel] = []
        switch type {
        case .album:
            TSDatabaseMusic().selectAlbumComments(albumID: id, complate: { (datas) in
                for object in datas {
                    let simpleModel = self.makeSimpleMusicCommentModel(musicCommentObjetc: object)
                    simpleCommentModelArray.append(simpleModel)
                }
                compate(simpleCommentModelArray)
            })
            break
        case .song:
            let objects = TSDatabaseMusic().selectSongComments(songID: id)
            for object in objects {
                let simpleModel = self.makeSimpleMusicCommentModel(musicCommentObjetc: object)
                simpleCommentModelArray.append(simpleModel)
            }
            compate(simpleCommentModelArray)
            break
        }
    }

    /// 合成评论cell所用的数据模型
    ///
    /// - Parameter model: 接口返回的数据
    /// - Returns: 结果
    private func makeSimpleMusicCommentModel(musicCommentModel model: TSMusicCommentModel) -> TSSimpleCommentModel {
        /// 从数据库获取用户信息
        let commentUserInfo = TSDatabaseManager().user.get(model.userId)
        var replyUserInfo: TSUserInfoObject?
        if model.replyUserId != 0 {
            replyUserInfo = TSDatabaseManager().user.get(model.replyUserId)
        }
        // TODO: MusicUpdate - 音乐模块更新中，To be done
//        /// 合成cellModel status为0 是发布成功
//        let commentModel = TSSimpleCommentModel(userInfo: commentUserInfo, replyUserInfo: replyUserInfo, content: model.body, createdAt: model.createDate.convertToDate(), id: model.id, commentMark: model.commentMark, status: 0, isTop: false)
//        return commentModel
        let commentModel = TSSimpleCommentModel()
        return commentModel
    }

    /// 合成评论cell所用的数据模型
    ///
    /// - Parameter object: 数据库中的评论数据
    /// - Returns: 结果
    private func makeSimpleMusicCommentModel(musicCommentObjetc object: TSMusicCommentObject) -> TSSimpleCommentModel {
        /// 从数据库获取用户信息
        let commentUserInfo = TSDatabaseManager().user.get(object.userId)
        var replyUserInfo: TSUserInfoObject?
        if object.replyUserId != 0 {
            replyUserInfo = TSDatabaseManager().user.get(object.replyUserId)
        }

        var status = 0
        if object.sending == 0 {
            status = object.successed == 0 ? 1 : 0
        }

        // TODO: MusicUpdate - 音乐模块更新中，To be done
//        /// 合成cellModel status为0 是发布成功
//        let commentModel = TSSimpleCommentModel(userInfo: commentUserInfo, replyUserInfo: replyUserInfo, content: object.body, createdAt: object.createDate, id: object.id, commentMark: object.commentMark, status: status, isTop: false)
//
//        return commentModel
        let commentModel = TSSimpleCommentModel()
        return commentModel
    }

    /// 发送评论的队列
    ///
    /// - Parameters:
    ///   - id: 专辑或音乐id
    ///   - type: 专辑或音乐
    ///   - comment: 评论内容
    ///   - replyUserID: 被回复人的id
    /// - Returns: 假数据
    func sendMusicComment(sourceID id: Int, commentType type: TSMusicCommentVC.commentType, comment: String, replyUserID: Int?) -> TSSimpleCommentModel {

        let model = makeMuiscCommentModel(sourceID: id, commentType: type, comment: comment, replyUserID: replyUserID)
        TSDatabaseMusic().save(MusicComments: [model], sending: 1, successed: 0)

        let commentModel = makeSimpleCommentModel(musicModel: model)
        networkSendMusicComment(sourceID: id, commentType: type, commentSimplModel: commentModel)
        return commentModel
    }

    func makeMuiscCommentModel(sourceID id: Int, commentType type: TSMusicCommentVC.commentType, comment: String, replyUserID: Int?) -> TSMusicCommentModel {

        let model = TSMusicCommentModel()
        model.body = comment
        // TODO: MusicUpdate - 音乐模块更新中，To be done
//        model.commentMark = TSReleasePulseTool.getFeedMark()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let stringDate = dateFormatter.string(from: NSDate() as Date)
        model.createDate = stringDate

        model.commentTableId = id
        type == .album ? (model.commentTableType = TSMusicCommentType.special.rawValue) : (model.commentTableType = TSMusicCommentType.song.rawValue)

        if let userInfo = TSCurrentUserInfo.share.userInfo {
            model.userId = userInfo.userIdentity
        }
        if let replyUserID = replyUserID {
            model.replyUserId = replyUserID
        }

        return model
    }

    func makeSimpleCommentModel(musicModel: TSMusicCommentModel) -> TSSimpleCommentModel {
        /// 注意：这个时候是没有评论id的！！
        var model = TSSimpleCommentModel()
        model.content = musicModel.body
        model.createdAt = musicModel.createDate.convertToDate()
        // TODO: MusicUpdate - 音乐模块更新中，To be done
//        model.commentMark = musicModel.commentMark

        /// 假装这条发送成功了
        model.status = 0

        model.userInfo = TSCurrentUserInfo.share.userInfo?.convert().object()
        if musicModel.replyUserId != 0 {
            model.replyUserInfo = TSDatabaseManager().user.get(musicModel.replyUserId)
        }
        return model
    }

    /// 发送评论的网络请求
    ///
    /// - Parameters:
    ///   - id: 专辑或歌曲id
    ///   - type: 专辑或歌曲
    ///   - model: TSSimpleCommentModel
    func networkSendMusicComment(sourceID id: Int, commentType type: TSMusicCommentVC.commentType, commentSimplModel model: TSSimpleCommentModel) {
        // TODO: MusicUpdate - 音乐模块更新中，To be done
//        TSMusicNetworkManager().sendMusicComment(sourceID: id, commentType: type, commentSimplModel: model) { (_, successed, data, _) in
//            /// 发布成功，修改数据库
//            if successed {
//                TSDatabaseMusic().uploadMusicCommentStatus(commentMark: model.commentMark, successed: 1, commentID: data as? Int)
//                return
//            }
//            /// 错误数达到最大允许数量，则此条评论发布失败
//            if self.errorCount == self.maxErrorRequest {
//                TSDatabaseMusic().uploadMusicCommentStatus(commentMark: model.commentMark, successed: 0, commentID: nil)
//                return
//            }
//            /// 错误数未小于最大允许数，重启发布队列
//            if self.errorCount <= self.maxErrorRequest {
//                self.errorCount += 1
//                let waitTime: Int = self.errorCount * 2
//                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(waitTime), execute: {
//                    DispatchQueue.main.async {
//                        self.networkSendMusicComment(sourceID: id, commentType: type, commentSimplModel: model)
//                    }
//                })
//            }
//        }
        // 使用升级后的网络请求接口
        let commentType: TSMusicCommentType = (type == .album) ? .special : .song
        TSMusicNetworkManager().addMusicComment(commentType: commentType, sourceId: id, content: model.content, replyUserId: model.replyUserInfo?.userIdentity) { (commentModel, _, status) in
            // 发布成功，修改数据库
            if status, let commentModel = commentModel {

            } else {

            }
        }

    }

    /// 删除评论
    ///
    /// - Parameter model: 评论的cell数据模型
    func deleteMusicComment(commentModel model: TSSimpleCommentModel) {
        TSDatabaseMusic().deleteMusicComment(WithCommentMark: model.commentMark) { (shouldNetwork, object) in
            if shouldNetwork {
                self.network(deleteMusicComment: object!)
            }
        }
    }

    /// 删除评论的网络请求
    ///
    /// - Parameter commentObject: 评论数据
    func network(deleteMusicComment commentObject: TSMusicCommentObject) {
        // TODO: MusicUpdate - 音乐模块更新中，To be done
//        TSMusicNetworkManager().deleteMusicComment(commentID: commentObject.id) { (successed, _) in
//            if successed {
//                /// 删除数据库里的对应数据
//                // TODO: MusicUpdate - 音乐模块更新中，To be done
////                TSDatabaseMusic().deleteComment(commentMark: commentObject.commentMark)
//                return
//            }
//
//            if self.errorCount == self.maxErrorRequest {
//                /// 接口删除失败 不作处理了
//                /// 失败和未完成的任务 在程序下一次启动时统一调用接口删除
//                return
//            }
//
//            if self.errorCount < self.maxErrorRequest {
//                self.errorCount += 1
//                let waitTime: Int = self.errorCount * 2
//                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(waitTime), execute: {
//                    DispatchQueue.main.async {
//                        self.network(deleteMusicComment: commentObject)
//                    }
//                })
//            }
//        }

        // 使用升级后的网络请求接口
//        let commentType: TSMusicCommentType = (type == .album) ? .special : .song
        let commentType: TSMusicCommentType = TSMusicCommentType(rawValue: commentObject.commentTableType)!
        TSMusicNetworkManager().deleteMusicComment(commentType: commentType, sourceId: commentObject.commentTableId, commentId: commentObject.id) { (_, status) in
            if status {
                // 删除数据库里对应数据
                // 待完成
            } else {

            }
        }
    }

}
