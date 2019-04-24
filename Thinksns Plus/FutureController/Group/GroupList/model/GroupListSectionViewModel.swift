//
//  GroupListSectionViewModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子列表 section model

import UIKit

class GroupListSectionViewModel: NSObject {

    /// 右方按钮类型
    enum RightType {
        /// 换一换按钮
        case change
        /// 查看全部按钮
        case seeAll
    }

    /// 每个 section 中 cell 的最大显示个数
    var maxCount = 5
    /// 右边按钮类型
    var rightType = RightType.seeAll
    /// 左边 label 标题
    var title = ""

    var cellModels: [GroupListCellModel] = []
}
