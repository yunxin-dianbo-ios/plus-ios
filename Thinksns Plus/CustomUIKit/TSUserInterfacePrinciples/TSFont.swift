//
//  TSFont.swift
//  Thinksns Plus
//
//  Created by lip on 2016/12/29.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  应用字体
//设置/修改资料/修改密码/意见反馈页面文字; 动态详情页正文/聊天详情页聊天内容 收到的赞列表的用户昵称; 发布动态编辑标题和内容文字;活动列表标题; 歌曲列表歌曲标题
import UIKit

enum TSFont: CGFloat {
    /// 默认参数避免编译器报错
    case tsDefault = 1
    /// 标题
    enum Title: CGFloat {
        /// 导航栏大标题
        ///
        /// - 标题栏标题、动态详情页标题
        case headline = 18
        /// 动态标题
        ///
        /// - 消息/相册/点赞/粉丝/关注 列表标题
        case pulse = 16
        /// 弹窗标题
        ///
        /// - 窗口上部弹窗
        case indicator = 15
    }
    /// 按钮
    enum Button: CGFloat {
        /// 导航栏
        case navigation = 16
        /// 工具栏按钮标题(图片在上面)
        case toolbarTop = 10
        /// 工具栏按钮标题(图片在左边)
        case toolbarLeft = 12
        /// 键盘工具栏按钮/标签视图的按钮
        case keyboardRight = 14
    }
    enum Navigation: CGFloat {
        /// 导航栏按钮
        case subTitle = 16
        /// 导航栏大标题
        ///
        /// - 标题栏标题、动态详情页标题
        case headline = 18
    }

    /// 内容
    enum ContentText: CGFloat {
        /// 正文内容
        ///
        /// 聊天.设置.动态.发布动态.广告介绍 等
        case text = 15
        /// 评论内容,副内容
        ///
        /// - 消息/相册/点赞/粉丝/关注 列表中标题下文字
        case comment
        /// 个人主页 section 的标题
        ///
        /// - 个人主页 section 的标题
        case sectionTitle = 13
        /// 购买弹窗价格数字的大小
        case price = 30
    }

    // 评论
    enum SubText: CGFloat {
        /// 评论内容,副内容
        ///
        /// - 消息/相册/点赞/粉丝/关注 列表中标题下文字
        case subContent = 14
    }
    /// 用户名
    enum UserName: CGFloat {
        /// 导航栏用户名 个人主页用户用户名
        case navigation = 16
        /// 普通列表用户用户名
        case list = 15
        /// 动态列表用户名
        case listPulse = 13
        /// 评论的用户名 / 歌曲列表中,歌手名的文字
        case comment = 12
    }
    enum SubUserName: CGFloat {
        /// 导航栏用户名 个人主页用户用户名
        case home = 16
        /// 评论的用户名 / 歌曲列表中,歌手名的文字
        case singer = 12
    }

    /// 输入框
    enum TextField: CGFloat {
        /// 账户信息
        case account = 15
    }
    /// 时间
    enum Time: CGFloat {
        /// 常规时间
        case normal = 12
        /// 主页
        ///
        /// - 主页 左侧时间
        case home = 22
        // 消息事件
        ///
        /// - 即时聊天消息时间
        case message = 10
    }
    /// 附属信息
    enum SubInfo: CGFloat {
        /// 杂项
        ///
        /// - util: 图标标签等辅助信息/分享弹窗图标下文字/详情页底部操作栏/点击登录按钮的提示信息 等
        /// - mini: 底部导航栏下边小字/输入评论字数限制提示 等
        case mini = 12
        /// 页脚标题
        ///
        /// - 粉丝数/详情页点赞人数
        case footnote = 14
        /// 字数统计大小
        case statisticsNumberOfWords = 10
        /// 特例纯文字动态缩略排列
        case special = 11
    }
}
