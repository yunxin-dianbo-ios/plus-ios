//
//  TSSocialite.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

/// 三方的名称
/// - 为了方便外额外带了最后两个属于三方type
///
/// - qq
/// - weibo
/// - wechat
/// - phone
/// - email
enum ProviderType: String {
    /// 扣扣
    case qq
    /// 微博
    case weibo
    /// 微信
    case wechat
    /// 电话
    case phone
    /// 邮箱
    case email
}
/// 三方数据结构体
struct TSSocialite {
    /// - 接口
    ///     - 调用变量
    /// - 判断
    ///     - 名称
    var provider: ProviderType
    /// 接口
    /// - token
    var token: String
    /// 三方昵称
    var name: String
    /// 是否是游客模式
    var isLogin: Bool
}
