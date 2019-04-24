//
//  TSTagSettingVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  标签视图 VC
//
//  copy "TSNewsTagSettingVC.swift" 的代码，将其中的 obejct 改为 model

import UIKit

class ATagModel {
    /// 栏目id
    dynamic var tagID = 1
    /// 栏目名
    dynamic var name = ""
    /// 排序 （只有已订阅的栏目才有这个值）
    dynamic var index = -1

    init() {
    }

    init(categoriesModel model: GroupCategoriesModel) {
        tagID = model.id
        name = model.name
    }

    class func recommend() -> ATagModel {
        let model = ATagModel()
        model.tagID = -9999
        model.name = "推荐"
        model.index = 0
        return model
    }
}
