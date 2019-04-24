//
//  TSFollowFansListModel.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  展示关系的模型

import UIKit

struct TSFollowFansListModel {
    // 姓名
    var name: String?
    // 简介
    var intro: String?
    // 点赞数
    var likeCount: Int = 0
    // 用于显示的用户id
    var userId: Int = 0
    // 索引Id
    var maxId: Int = 0
//    // 显示头像的Id
//    var avatar: Int = 0
}
