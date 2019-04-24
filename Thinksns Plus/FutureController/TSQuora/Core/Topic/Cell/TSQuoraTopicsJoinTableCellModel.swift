//
//  TSQuoraTopicsJoinTableCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  话题加入列表的 cell model

import UIKit

class TSQuoraTopicsJoinTableCellModel: NSObject {

    /// 话题 id
    var id: Int = -1
    /// 话题图片 URL
    var imageURL: String?
    /// 话题标题
    var title: String = ""
    /// 话题关注数
    var followCount: Int = 0
    /// 话题问题数
    var questionCount: Int = 0
    /// 当前用户是否关注此话题
    var isFollowed: Bool = false
}

extension TSQuoraTopicsJoinTableCellModel {

    convenience init(model: TSQuoraTopicModel) {
        self.init()
        id = model.id
        imageURL = TSUtil.praseTSNetFileUrl(netFile: model.avatar)
        title = model.name
        followCount = model.followsCount
        questionCount = model.questionsCount
        isFollowed = model.isFollow
    }
}
