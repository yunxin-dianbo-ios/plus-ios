//
//  PostPublishNetworkModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 07/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子帖子发布的网络请求结果模型，也适用于圈子帖子修改的网络请求结果模型
//  含message字段

import Foundation
import ObjectMapper

class PostPublishNetworkModel: Mappable {

    var message: String?
    var postModel: PostListModel?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        message <- map["message"]
        postModel <- map["post"]
    }

}
