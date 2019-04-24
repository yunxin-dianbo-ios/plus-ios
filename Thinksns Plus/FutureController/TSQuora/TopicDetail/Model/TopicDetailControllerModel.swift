//
//  TopicDetailControllerModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
class TopicDetailControllerModel: NSObject {

    /// 话题基础信息
    var basicInfoModel: TSQuoraTopicsJoinTableCellModel!
    /// 话题简介
    var introModel: QuoraTopicDetailIntroLabelCellModel!
    /// 专家列表
    var expertsModel: QuoraTopicDetailExpertsCellModel?
    /// 分割线
    var seperator: StackSeperatorCellModel = {
        let seperator = StackSeperatorCellModel()
        seperator.height = 5
        seperator.lineColor = TSColor.inconspicuous.disabled
        return seperator
    }()

    /// 按展示顺序排列的数据模型数组
    var dataArrays: [AnyObject] {
        let datas: [AnyObject?] = [basicInfoModel, introModel, expertsModel, seperator]
        return datas.flatMap { $0 }
    }

    override init() {
        super.init()
    }

    init(model: TSQuoraTopicModel) {
        super.init()
        // 1.话题基础信息
        basicInfoModel = TSQuoraTopicsJoinTableCellModel(model: model)
        // 2.话题简介
        introModel = QuoraTopicDetailIntroLabelCellModel()
        introModel.introl = model.description
        // 3.专家列表
        if !model.experts.isEmpty {
            expertsModel = QuoraTopicDetailExpertsCellModel()
            expertsModel?.experts = model.experts
            expertsModel?.expertsCount = model.expertsCount
        }
    }
}
