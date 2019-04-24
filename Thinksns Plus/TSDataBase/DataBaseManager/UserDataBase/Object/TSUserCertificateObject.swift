//
//  TSUserCertificateObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/9.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import RealmSwift
import UIKit

class TSUserCertificateObject: Object {

    /// 主键
    dynamic var id = 1
    /// 认证类型
    dynamic var type = ""
    /// 认证状态: 0 - 待审核, 1 - 通过, 2 - 拒绝
    dynamic var status = -1
    /// 姓名
    dynamic var name = ""
    /// 电话
    dynamic var phone = ""
    /// 数字
    dynamic var number = ""
    /// 描述
    dynamic var desc = ""
    /// 图片
    let files = List<TSImageObject>()
    /// 企业名称
    dynamic var orgName = ""
    /// 企业地址
    dynamic var orgAddress = ""

    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }
}
