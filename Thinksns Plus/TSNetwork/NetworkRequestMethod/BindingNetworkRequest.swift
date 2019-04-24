//
//  BindingNetworkRequest.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/26.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  绑定和解绑网络请求

import UIKit

struct BindingNetworkRequest {
    /// 当前用户绑定电话号码/邮箱
    ///
    /// - RequestParameter:
    ///    - phone          : String.         如果 email 不存在则**必须**，用户新的手机号码。
    ///    - email          : String.         如果 phone 不存在则**必须**，用户新的邮箱地址
    ///    - verifiable_code: String/Integer. **必须**验证码。
    let bindingAuthUserPhoneOrEmail = Request<Empty>(method: .put, path: "user", replacers: [])
    /// 更新用户密码
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - old_password: 字符串,用户已设置密码时必须，用户密码。
    ///    - password: 字符串,必须，用户的新密码
    ///    - password_confirmation:	字符串, 必须，用户的新密码，必须和 password 一致。
    let updatePassword = Request<Empty>(method: .put, path: "user/password", replacers: [])
    /// 解绑当前用户电话号码
    /// - RequestParameter:
    ///    - password: String.                  **必须**用户的密码
    ///    - verifiable_code: String/Integer.   **必须**通过手机号获得的验证码。
    let unbindAuthUserPhone = Request<Empty>(method: .delete, path: "user/phone", replacers: [])

    /// 解绑当前用户邮箱
    /// - RequestParameter:
    ///    - password: String.                  **必须**用户的密码
    ///    - verifiable_code: String/Integer.   **必须**通过邮箱获得的验证码。
    let unbindAuthUserEmail = Request<Empty>(method: .delete, path: "user/email", replacers: [])

    /// 检查是否绑定
    let checkbinding = TSNetworkRequestMethod(method: .post, path: "socialite/:provider", replace: ":provider")

    /// 检查绑定并获取用户授权
    let checkName = TSNetworkRequestMethod(method: .patch, path: "socialite/:provider", replace: ":provider")

    /// 输入帐号密码绑定
    /// - RouteParameter:
    ///    - qq
    ///    - wecaht
    ///    - weibo
    /// - RequestParameter:
    ///    - ac:    账户
    ///    - pw:    密码
    ///    - token: access_token
    let inputAccountPWBinding = TSNetworkRequestMethod(method: .put, path: "socialite/:provider", replace: ":provider")

    /// 获取已经绑定的三方
    /// - RouteParameter:   None
    /// - RequestParameter: None
    let getUserSocialite = TSNetworkRequestMethod(method: .get, path: "user/socialite", replace: nil)

    /// 解除用户的某一个三方绑定
    /// - RouteParameter: 
    ///    - qq
    ///    - wecaht
    ///    - weibo
    /// - RequestParameter:
    ///    - token: access_token
    let deletUserProvider = TSNetworkRequestMethod(method: .delete, path: "user/socialite/:provider", replace: ":provider")

    /// 已登录用户绑定三方
    ///
    /// - RouteParameter:
    ///    - provider: provider字符串变量
    /// - RequestParameter:
    ///    - access_token: String,获取的 Provider Access Token
    let loginUserProvider = Request<Empty>(method: .patch, path: "user/socialite/:provider", replacers: [":provider"])
}
