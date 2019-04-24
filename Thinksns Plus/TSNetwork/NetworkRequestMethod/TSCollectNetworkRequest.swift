//
//  TSCollectNetworkRequest.swift
//  ThinkSNS +
//
//  Created by 小唐 on 08/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  所所有收藏相关的网络请求

import Foundation

struct TSCollectNetworkRequest {

    /// 帖子
    struct Post {
        /// 收藏
        static let collect = Request<Empty>(method: .post, path: "plus-group/group-posts/:post/collections", replacers: [":post"])
        /// 取消收藏
        static let uncollect = Request<Empty>(method: .delete, path: "plus-group/group-posts/:post/uncollect", replacers: [":post"])

//        plus-group/group-posts/:post/collections
//        plus-group/group-posts/:post/uncollect      // 注：帖子取消收藏的接口文档上确实是uncollect
    }

}
