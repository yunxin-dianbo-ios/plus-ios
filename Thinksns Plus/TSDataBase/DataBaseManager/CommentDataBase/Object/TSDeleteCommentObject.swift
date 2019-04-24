//
//  TSDeleteCommentObject.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  删除评论

import UIKit
import RealmSwift

class TSDeleteCommentObject: Object {

    /// 动态的ID
    /// 列表用户ID
    let feedId = RealmOptional<Int>()
    /// 评论标识
    let commentIdentity = RealmOptional<Int>()
    /// 唯一标识
    let commentMark = RealmOptional<Int64>()
    /// 圈子ID
    let groupId = RealmOptional<Int>()

    /// 设置主键
    override static func primaryKey() -> String? {
        return "commentMark"
    }
}
