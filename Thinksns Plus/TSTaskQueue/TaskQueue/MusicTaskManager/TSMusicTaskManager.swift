//
//  TSMusicTaskManager.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  音乐模块任务队列管理类
//  TODO: - 评论模块重构中，该页面需要修正。

import UIKit
import RealmSwift
import ReachabilitySwift

class TSMusicTaskManager {

}

// 音乐相关

extension TSMusicTaskManager {
    /// 获取音乐评论列表页的数据 - 刷新的复合请求
    func getMusicCommentData(type: TSMusicCommentType, sourceId: Int, isNeedRequestDetail: Bool, limit: Int, complete: @escaping((_ introModel: TSMusicCommentIntroModel?, _ commentList: [TSSimpleCommentModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        let commentType: TSCommentType = (type == .album) ? .album : .song
        // 根据isNeedRequestDetail来确定是否需要请求详情信息来构造评论页的介绍信息
        if !isNeedRequestDetail {
            TSCommentTaskQueue.getCommentList(type: commentType, sourceId: sourceId, afterId: nil, limit: limit, complete: { (commentList, msg, status) in
                guard status, let commentList = commentList else {
                    complete(nil, nil, msg, false)
                    return
                }
                complete(nil, commentList, msg, true)
            })
            return
        }
        // 网络嵌套或并行 来 请求详情信息 + 评论列表
        TSMusicNetworkManager.getMusicCommentIntro(type: type, sourceId: sourceId) { (introModel, msg, status) in
            guard status, let introModel = introModel else {
                complete(nil, nil, msg, false)
                return
            }
            TSCommentTaskQueue.getCommentList(type: commentType, sourceId: sourceId, afterId: nil, limit: limit, complete: { (commentList, msg, status) in
                guard status, let commentList = commentList else {
                    complete(nil, nil, msg, false)
                    return
                }
                complete(introModel, commentList, msg, true)
            })
        }
    }

}

// MARK: - 专辑相关
extension TSMusicTaskManager {
    // MARK: - 专辑列表

    // 数据库查询专辑列表
    func dbQueryAlbumList(maxId: Int, limit: Int = 20) -> [TSAlbumListModel] {
        return TSDatabaseManager().music.getAlbumList(maxId: maxId, limit: limit)
    }
    // 网络请求专辑列表
    func networkRequestAlbumList(maxId: Int, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ((_ albumList: [TSAlbumListModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        TSMusicNetworkManager().getAlbumList(maxId: maxId, limit: limit) { (msg, albumList, status) in
            if status, let albumList = albumList {
                // 数据库存储
                if 0 == maxId && !albumList.isEmpty {
                    TSDatabaseManager().music.deleteAllAlbumList()
                }
                TSDatabaseManager().music.saveAlbumList(albumList)
                complete(albumList, msg, status)
            } else {
                complete(nil, msg, status)
            }
        }
    }

    // 网络请求收藏的专辑列表
    func networkCollectAlbumList(maxId: Int, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ((_ albumList: [TSAlbumListModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 收藏的专辑列表 暂时不保存数据库
        TSMusicNetworkManager().getCollectionAlbumList(maxId: maxId, limit: limit, complete: complete)
    }

    // MARK: - 专辑详情

    /// 数据库查询指定的专辑详情
    func dbQueryAlbumDetail(with albumId: Int) -> TSAlbumDetailModel? {
        return TSDatabaseManager().music.getAlbumDetail(with: albumId)
    }
    /// 网络请求指定的专辑详情
    func networkRequestAlbumDetail(albumId: Int, complete: @escaping (_ albumDetail: TSAlbumDetailModel?, _ msg: String?, _ status: Bool) -> Void ) -> Void {
        TSMusicNetworkManager().getAlbumDetail(albumID: albumId) { (albumDetail, msg, status) in
            if status, let albumDetail = albumDetail {
                // 数据库存储
                TSDatabaseManager().music.addAlbumDetail(albumDetail)
                complete(albumDetail, msg, status)
            } else {
                complete(nil, msg, status)
            }
        }
    }

    // MARK: - 专辑收藏: 添加收藏/取消收藏

    // 网络请求添加收藏与取消收藏
    func networkAlbumCollection(albumModel: TSAlbumListModel, albumDetail: TSAlbumDetailModel?, albumId: Int, complete: @escaping((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        let currentCollect = albumModel.isCollectd
        TSMusicNetworkManager().albumCollection(currentCollect: currentCollect, albumId: albumId) { (msg, status) in
            if status {
                // 操作成功，则修改数据库
                albumModel.isCollectd = !albumModel.isCollectd
                albumDetail?.isCollectd = !albumModel.isCollectd
                TSDatabaseManager().music.updateAlbumList(wtih: albumModel)
                if let albumDetail = albumDetail {
                    TSDatabaseManager().music.updateAlbumDetail(albumDetail)
                }
            }
            complete(msg, status)
        }
    }
}

// MARK: - 歌曲相关
extension TSMusicTaskManager {

    /// 获取指定的歌曲 
    // Remark: 暂时似乎并不需要，就不作处理吧

    /// 本地获取指定的歌曲
    /// 网络获取指定的歌曲

}
