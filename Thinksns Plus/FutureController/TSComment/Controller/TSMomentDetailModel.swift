//
//  TSMomentDetailModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 14/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  动态详情页的数据模型

import Foundation
import RealmSwift
import ObjectMapper

class TSMomentDetailModel: Mappable {

    /// 动态id
    var id: Int = 0
    /// 用户标识
    var userId: Int = 0
    /// 纬度
    var latitude: String?
    /// 经度
    var longtitude: String?
    /// GeoHash
    var geohash: String?
    /// 审核状态
    var status: Int?
    /// 动态收费信息
    var paid: TSPaidFeedModel?
    /// 打赏统计
    var rewardCount: TSNewsRewardCountModel?
    /// 点赞列表
    var diggs: [Int]?

    required init?(map: Map) {

    }
    func mapping(map: Map) {

    }
}

/**
{
    "id": 2698,
    "created_at": "2017-11-07 01:50:48",
    "updated_at": "2017-11-14 02:16:41",
    "deleted_at": null,
    "user_id": 29,
    "feed_title": "",
    "feed_content": "\u91c7\u8d2d\u5b98\u65b9\u53c2\u4e0e\u6d3b\u52a8\u4ea7\u54c1\u4efb\u610f\u7248\u672c\u539f\u4ef7\u6ee12\u4e07\u5143\u7acb\u51cf1\u4e07\uff0c\u518d\u90011\u4e07\u5143\u5b9a\u5236\u5f00\u53d1\u8d39http:\/\/tsplus.zhibocloud.cn\/news\/214",
    "feed_from": 1,
    "like_count": 8,
    "feed_view_count": 203,
    "feed_comment_count": 44,
    "feed_latitude": "",
    "feed_longtitude": "",
    "feed_geohash": "",
    "audit_status": 1,
    "feed_mark": 1510019412831,
    "pinned": 0,
    "pinned_amount": 0,
    "has_collect": false,
    "has_like": false,
    "reward": {
        "count": 4,
        "amount": "10100"
    },
    "images": [{
    "file": 4635,
    "size": "700x330"
    }],
    "paid_node": null,
    "likes": [{
    "id": 2387,
    "user_id": 950,
    "target_user": 29,
    "likeable_id": 2698,
    "likeable_type": "feeds",
    "created_at": "2017-11-10 05:38:04",
    "updated_at": "2017-11-10 05:38:04"
    }, {
    "id": 2376,
    "user_id": 246,
    "target_user": 29,
    "likeable_id": 2698,
    "likeable_type": "feeds",
    "created_at": "2017-11-09 14:47:07",
    "updated_at": "2017-11-09 14:47:07"
    }, {
    "id": 2352,
    "user_id": 1071,
    "target_user": 29,
    "likeable_id": 2698,
    "likeable_type": "feeds",
    "created_at": "2017-11-09 04:40:55",
    "updated_at": "2017-11-09 04:40:55"
    }, {
    "id": 2346,
    "user_id": 29,
    "target_user": 29,
    "likeable_id": 2698,
    "likeable_type": "feeds",
    "created_at": "2017-11-09 02:46:01",
    "updated_at": "2017-11-09 02:46:01"
    }, {
    "id": 2335,
    "user_id": 941,
    "target_user": 29,
    "likeable_id": 2698,
    "likeable_type": "feeds",
    "created_at": "2017-11-08 07:35:50",
    "updated_at": "2017-11-08 07:35:50"
    }, {
    "id": 2328,
    "user_id": 227,
    "target_user": 29,
    "likeable_id": 2698,
    "likeable_type": "feeds",
    "created_at": "2017-11-08 03:36:08",
    "updated_at": "2017-11-08 03:36:08"
    }, {
    "id": 2324,
    "user_id": 20,
    "target_user": 29,
    "likeable_id": 2698,
    "likeable_type": "feeds",
    "created_at": "2017-11-08 03:10:31",
    "updated_at": "2017-11-08 03:10:31"
    }, {
    "id": 2318,
    "user_id": 178,
    "target_user": 29,
    "likeable_id": 2698,
    "likeable_type": "feeds",
    "created_at": "2017-11-07 19:17:19",
    "updated_at": "2017-11-07 19:17:19"
    }]
}
 
*/
