//
//  TSCollectionAnswerModel.swift
//  ThinkSNSPlus
//
//  Created by 小唐 on 20/03/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  收藏答案的数据模型
//  如果收藏的数据模型开始统一时，则考虑使用基类+子类的方式来处理

import Foundation
import ObjectMapper

class TSCollectionAnswerModel: Mappable {

    /// 收藏记录id 用于翻页
    var id: Int = 0
    /// 收藏记录id 用于翻页
    var userId: Int = 0
    /// 收藏对象的id
    var collectible_id: Int = 0
    /// 收藏对象的类型:
    var collectible_type: String = ""
    /// 收藏时间
    var created_at: String = ""
    var updated_at: String = ""
    /// 回答的数据模型
    var answer: TSAnswerListModel?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        collectible_id <- map["collectible_id"]
        collectible_type <- map["collectible_type"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        answer <- map["collectible"]
    }

}
