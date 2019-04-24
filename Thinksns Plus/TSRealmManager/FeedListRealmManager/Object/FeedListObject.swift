//
//  FeedListObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

/// 热门列表
class HotFeedsListObject: FeedListObject {
}
/// 关注列表
class FollowFeedListObject: FeedListObject {
}
/// 最新列表
class NewFeedListObject: FeedListObject {
}

class FeedListObject: Object {

    // 排序标识
    dynamic var sortId = 0
    /// 动态 id
    dynamic var feedId = 0
    /// 用户 id
    dynamic var userId = 0
    /// 用户 性别
    dynamic var sex = 0
    /// 用户名，为空则不显示
    dynamic var userName = ""
    /// 头像信息，为 nil 则不显示头像
    dynamic var avatarInfo: AvatarObject?
    /// 文字内容，为空则不显示
    dynamic var content = ""
    /// 图片，为空则不显示
    let pictures = List<PaidPictureObject>()
    /// 工具栏信息，为 nil 则不显示工具栏
    dynamic var toolModel: FeedListToolObject?
    /// 评论，为空则不显示评论
    let comments = List<FeedListCommentObject>()
    /// 左边时间，为空则不显示
    dynamic var leftTime = ""
    /// 右边时间，为空则不显示
    dynamic var rightTime = ""
    /// 付费信息
    dynamic var paidInfo: PiadInfoObject?

    /// 是否显示模糊文字
    dynamic var shouldAddFuzzyString = false
    /// 发送状态
    dynamic var sendStatus = 0
    /// 是否显示置顶标签 
    dynamic var showTopIcon = false
    /// 是否显示帖子置顶标签
    dynamic var showPostTopIcon = false
    /// 视频地址
    dynamic var videoURl = ""
    /// 本地视频地址
    dynamic var localVideoFileURL: String?
    /// 热门标识
    dynamic var hot = 0
    /// 加精标识
    dynamic var excellent: String?
    /// 转发的类型
    dynamic var repostType: String? = nil
    /// 转发的ID
    dynamic var repostId = 0
    /// 转发信息
    dynamic var repostModel: TSRepostModel? = nil
}

class FeedListToolObject: Object {
    /// 是否点赞
    dynamic var isDigg = false
    /// 是否收藏
    dynamic var isCollect = false
    /// 点赞数
    dynamic var diggCount = 0
    /// 评论数
    dynamic var commentCount = 0
    /// 浏览数
    dynamic var viewCount = 0
}

class AvatarObject: Object {
    /// 头像 url
    dynamic var avatarURL: String?
    /// 认证类型
    dynamic var verifiedType = ""
    /// 认证图标
    dynamic var verifiedIcon = ""
}
