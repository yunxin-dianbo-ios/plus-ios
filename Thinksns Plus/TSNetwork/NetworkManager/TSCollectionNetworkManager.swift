//
//  TSCollectionNetworkManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 08/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  收藏相关的请求
// 目前可收藏的对象：用户、问答话题...

import Foundation

/// 收藏操作
enum TSCollectOperate {
    /// 关注
    case collect
    /// 取消关注
    case uncollect
}

/// 收藏对象 de 类型
enum TSCollectTargetType {
    /// 帖子(新版的圈子中的帖子)
    case post
}

class TSCollectNetworkManager {

    /// 获取收藏列表
    class func collectList(targetId: Int, targetType: TSCollectTargetType, complete: @escaping((_ msg: String?, _ status: Bool) -> Void)) -> Void {

    }

    /// 收藏相关操作
    ///
    /// - Parameters:
    ///   - targetId: 收藏对象的id
    ///   - targetType: 收藏对象的类型
    ///   - collectOperate: 操作(搜藏/取消收藏)
    ///   - complete: 请求结果回调
    class func collectOperate(targetId: Int, targetType: TSCollectTargetType, collectOperate: TSCollectOperate, complete: @escaping((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request: Request<Empty>
        switch collectOperate {
        case .collect:
            switch targetType {
            case .post:
                request = TSCollectNetworkRequest.Post.collect
            }
        case .uncollect:
            switch targetType {
            case .post:
                request = TSCollectNetworkRequest.Post.uncollect
            }
        }
        request.urlPath = request.fullPathWith(replacers: ["\(targetId)"])
        // 2.配置参数
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(let data):
                complete(data.message, true)
            }
        }
    }

}
