//
//  TSSendCommentObject.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSSendCommentObject: Object {

    /// 动态的ID
    dynamic var feedId = 0
    /// 评论标识
    dynamic var commentIdentity = 0
    /// 圈子ID
    dynamic var groupId = -1
    /// 创建时间
    dynamic var create: NSDate? = nil
    /// 内容
    dynamic var content = ""
    /// 评论者id
    dynamic var userIdentity = 0
    /// 动态作者id
    dynamic var toUserIdentity = 0
    /// 被回复者id
    dynamic var replayToUserIdentity = 0
    /// 发送状态 0为成功或者发送中， 1为失败
    dynamic var status = 0
    /// 唯一的id
    dynamic var commentMark: Int64 = 0

    /// 设置主键
    override static func primaryKey() -> String? {
        return "commentMark"
    }

}
