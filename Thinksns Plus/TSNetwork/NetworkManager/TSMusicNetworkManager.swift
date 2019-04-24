//
//  TSMusicNetworkManager.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/19.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  音乐模块的网络数据请求管理类

import UIKit

import ObjectMapper

class TSMusicNetworkManager: NSObject {

}

// MARK: - V2版本的接口

// MARK: - 音乐相关

extension TSMusicNetworkManager {
    /// 获取音乐评论列表页的介绍信息，即根据type获取专辑信息或歌曲信息并转换成介绍信息
    class func getMusicCommentIntro(type: TSMusicCommentType, sourceId: Int, complete: @escaping(_ introModel: TSMusicCommentIntroModel?, _ msg: String?, _ status: Bool) -> Void) -> Void {
        switch type {
        case .album:
            // 请求专辑详情
            TSMusicNetworkManager().getAlbumDetail(albumID: sourceId, complete: { (albumDetail, msg, status) in
                guard status, let albumDetail = albumDetail else {
                    complete(nil, msg, false)
                    return
                }
                let introModel = TSMusicCommentIntroModel(album: albumDetail)
                complete(introModel, msg, true)
                return
            })
        case .song:
            // 请求歌曲详情
            TSMusicNetworkManager().getSongDetail(songId: sourceId, complete: { (songDetail, msg, status) in
                guard status, let songModel = songDetail else {
                    complete(nil, msg, false)
                    return
                }
                let introModel = TSMusicCommentIntroModel(song: songModel)
                complete(introModel, msg, true)
                return
            })
        }
    }

}

// MARK: - 专辑相关(不含专辑评论)

extension TSMusicNetworkManager {

    /// 获取专辑列表
    ///
    /// - Parameters:
    ///   - maxId: 分页标记（列表最后一个元素的id），可选
    ///   - limit: 获取条数，默认值 20 ，可选
    func getAlbumList(maxId: Int?, limit: Int = TSAppConfig.share.localInfo.limit, complete:@escaping(_ msg: String?, _ modelList: [TSAlbumListModel]?, _ status: Bool) -> Void) {
        let requestMethod = TSMusicNetworkRequest().specialList
        // 请求参数
        var parameter: [String: Any] = [String: Any]()
        if let maxId = maxId {
            parameter["max_id"] = maxId
        }
        parameter["limit"] = limit
        // 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: parameter, complete: { (data, status) in
            var message: String?
            if status {
                // 数据解析
                let modelList = Mapper<TSAlbumListModel>().mapArray(JSONObject: data)
                complete(message, modelList, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(message, nil, status)
            }
        })
    }

    /// 专辑详情
    // MARK: - 专辑详情--单个专辑的详细信息
    func getAlbumDetail(albumID id: Int, complete:@escaping(_ data: TSAlbumDetailModel?, _ msg: String?, _ status: Bool) -> Void) {
        let requestMethod = TSMusicNetworkRequest().specialDetailInfo
        // 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(id)"), parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                // 数据解析
                let model = Mapper<TSAlbumDetailModel>().map(JSONObject: data)
                complete(model, message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, status)
            }
        })
    }

    /// 获取收藏的专辑列表
    ///
    /// - Parameters:
    ///   - maxId: 分页标记（列表最后一个元素的id），可选
    ///   - limit: 获取条数，默认值 20 ，可选
    func getCollectionAlbumList(maxId: Int?, limit: Int = TSAppConfig.share.localInfo.limit, complete:@escaping(_ data: [TSAlbumListModel]?, _ msg: String?, _ status: Bool) -> Void) {
        let requestMethod = TSMusicNetworkRequest().specialStoreList
        // 请求参数
        var parameter: [String: Any] = [String: Any]()
        if let maxId = maxId {
            parameter["max_id"] = maxId
        }
        parameter["limit"] = limit
        // 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: parameter, complete: { (data, status) in
            var message: String?
            if status {
                // 数据解析
                let modelList = Mapper<TSAlbumListModel>().mapArray(JSONObject: data)
                // 收藏列表的数据模型中不再返回收藏状态，需手动添加
                if let modelList = modelList {
                    for model in modelList {
                        model.isCollectd = true
                    }
                }
                complete(modelList, message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, status)
            }
        })
    }

    /// 专辑 收藏/取消收藏
    ///
    /// - Parameters:
    ///   - state: 收藏：1， 取消收藏： 0
    ///   - albumId: 专辑id
    ///   - complete: 请求结果回调
    /// - Remark: state参数应设计为更合理的，待完成
    func albumCollection(currentCollect: Bool, albumId: Int, complete: @escaping((_ msg: String?, _ status: Bool) -> Void)) {
        // 当前已收藏，则取消收藏；当前未收藏，则添加收藏
        let requestMethod = currentCollect ? TSMusicNetworkRequest().specialCancelCollection : TSMusicNetworkRequest().specialAddCollection
        // 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(albumId)"), parameter: nil, complete: { (data, status) in
            var message: String?
            if !status {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

}

// MARK: - 歌曲相关(不含歌曲评论)

extension TSMusicNetworkManager {
    /// 获取音乐详情
    func getSongDetail(songId: Int, complete:@escaping(_ musicModel: TSAlbumMusicModel?, _ msg: String?, _ status: Bool) -> Void) {
        let requestMethod = TSMusicNetworkRequest().musicInfo
        // 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(songId)"), parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                let music = Mapper<TSAlbumMusicModel>().map(JSONObject: data)
                complete(music, message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, status)
            }
        })
    }

    /// 歌曲 点赞/取消点赞
    ///
    /// - Parameters:
    ///   - songId: 歌曲id (不是歌曲的附件id)
    ///   - currentDigg: 当前是否点赞
    ///   - complete: 结果
    func songDigg(songId: Int, currentDigg: Bool, complete: @escaping((_ message: String?, _ status: Bool) -> Void)) {
        // 请求url 
        var requestMethod: TSNetworkRequestMethod = TSMusicNetworkRequest().musicAddDigg
        if currentDigg {
            requestMethod = TSMusicNetworkRequest().musicCancelDigg
        }
        // 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(songId)"), parameter: nil, complete: { (data, status) in
            var message: String?
            if !status {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

}
