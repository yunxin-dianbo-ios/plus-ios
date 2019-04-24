//
//  TSQuoraAnswerNetworkAnalysisModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/9.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import ObjectMapper

class TSQuoraAnswerNetworkAnalysisModel: Mappable {

    /// 信息
    var message = ""
    /// 数据
    var answer: TSAnswerListModel?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        message <- map["message"]
        answer <- map["answer"]
    }

}
