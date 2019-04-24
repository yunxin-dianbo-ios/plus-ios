//
// Created by lip on 2017/9/21.
// Copyright (c) 2017 ZhiYiCX. All rights reserved.
//
// 未知用户数据模型
// - Note: 当服务端返回用户标识,移动端根据该标识查询用户详情,查询不到时,使用该模型给需要用户信息的部分继续处理,当用户针对该未知用户进行任意操作时,弹窗显示 "该用户已被删除"

import Foundation
import ObjectMapper

class TSUnknownUserInfoModel: TSUserInfoModel {
    override init() {
        super.init()
        self.userIdentity = 0
        self.name = "未知用户"
        self.avatar = nil
    }
    required init?(map: Map) {
        super.init(map: map)
    }
}
