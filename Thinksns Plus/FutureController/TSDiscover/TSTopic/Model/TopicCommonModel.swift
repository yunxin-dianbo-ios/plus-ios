//
//  TopicCommonModel.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/30.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TopicCommonModel {
    /// 话题 id
    var id = 0
    /// 话题名称
    var name = ""

    init() {
    }

    /// 从话题信息 model 初始化
    init(topicModel model: TopicModel) {
        id = model.id
        name = model.name
    }

    /// 话题列表 model 初始化
    init(topicListModel model: TopicListModel) {
        id = model.topicId
        name = model.topicTitle
    }
}
