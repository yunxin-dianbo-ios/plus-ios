//
//  BindingNetworkManager.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/26.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

import ObjectMapper

class BindingNetworkManager: NSObject {

    /// 解绑当前用户邮箱
    ///
    /// - Parameters:
    ///   - password: 密码
    ///   - code: 验证码
    ///   - complete: 回调
    func unbindEmail(password: String, code: String, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) {
        var request = BindingNetworkRequest().unbindAuthUserEmail
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["password": password, "verifiable_code": code]
        RequestNetworkData.share.text(request: request) { (result) in
            var message = "网络请求超时，请稍后再试"
            var tempResult = false
            switch result {
            case .error(let error):
                if error == NetworkError.networkTimedOut {
                    message = "网络请求超时,请稍后再试"
                }
            case .failure(let response):
                if let info = response.message {
                    message = info
                }
            case .success(let response):
                if let info = response.message {
                    message = info
                }
                tempResult = true
            }
            complete(message, tempResult)
        }
    }

    /// 解绑当前用户手机
    ///
    /// - Parameters:
    ///   - password: 密码
    ///   - code: 验证码
    ///   - complete: 回调
    func unbindPhone(password: String, code: String, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) {
        var request = BindingNetworkRequest().unbindAuthUserPhone
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["password": password, "verifiable_code": code]
        RequestNetworkData.share.text(request: request) { (result) in
            var message = "网络请求超时，请稍后再试"
            var tempResult = false
            switch result {
            case .error(let error):
                if error == NetworkError.networkTimedOut {
                    message = "网络请求超时,请稍后再试"
                }
            case .failure(let response):
                if let info = response.message {
                    message = info
                }
            case .success(let response):
                if let info = response.message {
                    message = info
                }
                tempResult = true
            }
            complete(message, tempResult)
        }
    }

    /// 检查注册信息
    ///
    /// - Parameters:
    ///   - provider: 那一个三方（eg:wechat）
    ///   - name: 用户输入的/wechat的nickName
    ///   - token: access_token(wechat的access_token)
    ///   - complete:
    ///     - flase 表示name没有通过，给用户看msg信息
    ///     - true 没有msg,表示name通过
    func checkUserName(provider: ProviderType, name: String, token: String, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) {
        let requestMethod = BindingNetworkRequest().checkName
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: provider.rawValue), parameter: ["name": name, "access_token": token, "check": 1], complete: { (response, status) in
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: response)
                complete(message, false)
                return
            }
            complete(nil, true)
        })
    }

    /// 注册用户
    /// - 【检查注册信息 - 通过】
    ///
    /// - Parameters:
    ///   - provider: 那一个三方（eg:wechat）
    ///   - name: 用户输入的/wechat的nickName
    ///   - token: access_token(wechat的access_token)
    ///   - complete:   外抛闭包
    ///     - token:   服务器创建的新用户的token
    ///     - model:   服务器创建的新用户的资料
    ///     - msg:     错误信息
    ///     - status:
    ///       - true:   有token、model，没有错误信息
    ///       - false:  只有错误信息
    func checkUserNameIsOk(provider: ProviderType, name: String, token: String, complete: @escaping ((_ token: TSAccountTokenModel?, _ userModel: TSCurrentUserInfoModel?, _ msg: String?, _ status: Bool) -> Void)) {
        let requestMethod = BindingNetworkRequest().checkName
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: provider.rawValue), parameter: ["name": name, "access_token": token], complete: { (response, status) in
            var message: String?
            guard status else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: response)
                complete(nil, nil, message, false)
                return
            }
            guard let data = response as? [String: Any], let token = Mapper<TSAccountTokenModel>().map(JSONObject: data), let user = Mapper<TSCurrentUserInfoModel>().map(JSONObject: data["user"]) else {
                message = "服务器返回数据错误"
                complete(nil, nil, message, false)
                return
            }
            complete(token, user, nil, true)
        })
    }

    /// 检查绑定并获取用户授权
    ///
    /// - Parameters:
    ///   - provider: 那一个三方（eg:wechat）
    ///   - token: access_token(wechat的access_token)
    ///   - complete:
    ///     - token:   服务器返回的已绑定用户的token
    ///     - model:   服务器返回的已绑定用户的资料
    ///     - msg:     错误信息
    ///     - status:
    ///       - true:   走登录
    ///       - false:  表示走三方注册/绑定流程
    func isSocialited(provider: ProviderType, token: String, complete: @escaping ((_ token: TSAccountTokenModel?, _ userModel: TSCurrentUserInfoModel?, _ msg: String?, _ status: Bool) -> Void)) {
        let requestMethod = BindingNetworkRequest().checkbinding
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: provider.rawValue), parameter: ["access_token": token], complete: { (response, status) in
            var message: String?
            guard status else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: response)
                complete(nil, nil, message, false)
                return
            }
            guard let data = response as? [String: Any], let token = Mapper<TSAccountTokenModel>().map(JSONObject: data), let user = Mapper<TSCurrentUserInfoModel>().map(JSONObject: data["user"]) else {
                message = "服务器返回数据错误"
                complete(nil, nil, message, false)
                return
            }
            complete(token, user, nil, true)
        })
    }

    /// 输入账号密码绑定
    ///
    /// - Parameters:
    ///   - provider: 那一个三方（eg:wechat）
    ///   - token: access_token(wechat的access_token)
    ///   - account: 输入的账户
    ///   - PW: 输入的密码
    ///   - complete:   外抛闭包
    ///     - token:   服务器返回绑定用户的token
    ///     - model:   服务器返回绑定用户的资料
    ///     - msg:     错误信息
    ///     - status:
    ///       - true:   有token、model，没有错误信息
    ///       - false:  只有错误信息
    func accountPWBinding(provider: ProviderType, token: String, account: String, PW: String, complete: @escaping ((_ token: TSAccountTokenModel?, _ userModel: TSCurrentUserInfoModel?, _ msg: String?, _ status: Bool) -> Void)) {
        let requestMethod = BindingNetworkRequest().inputAccountPWBinding
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: provider.rawValue), parameter: ["access_token": token, "login": account, "password": PW], complete: { (response, status) in
            var message: String?
            guard status else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: response)
                complete(nil, nil, message, false)
                return
            }
            guard let data = response as? [String: Any], let token = Mapper<TSAccountTokenModel>().map(JSONObject: data), let user = Mapper<TSCurrentUserInfoModel>().map(JSONObject: data["user"]) else {
                message = "服务器返回数据错误"
                complete(nil, nil, message, false)
                return
            }
            complete(token, user, nil, true)
        })
    }

    /// 三方绑定公用保存用户数据方法
    ///
    /// - Parameters:
    ///   - token: 保存用户的token
    ///   - model: 保存用户的资料
    ///   - isRegister:
    ///       - true:   完善资料相当于注册，注册时不应该发送用户登录通知，会崩溃
    ///       - false:  非完善【资料页面】
    func saveUserInfo(token: TSAccountTokenModel, model: TSCurrentUserInfoModel, isRegister: Bool) {
        let createDate = Date()
        // 保存token 和 用户信息
        token.createInterval = Int(createDate.timeIntervalSince1970)
        token.save()
        TSCurrentUserInfo.share.accountToken = token
        RequestNetworkData.share.configAuthorization(token.token)
        if isRegister {
            // 发布用户登录成功的通知
            NotificationCenter.default.post(name: NSNotification.Name.User.login, object: nil)
        }
        // 注册推送别名
        let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
        appDeleguate.registerJPushAlias()
        // 将当前用户信息存入数据库
        TSCurrentUserInfo.share.userInfo = model
        TSCurrentUserInfo.share.isInitPwd = model.isInitPwd
        TSDatabaseManager().user.saveCurrentUser(model)
        // 请求用户认证信息
        TSDataQueueManager.share.userInfoQueue.getCertificateInfo()
        /// 获取用户管理权限信息
        TSUserNetworkingManager.currentUserManagerInfo { (_, _) in
        }
    }

    /// 解绑当前用户三方
    ///
    /// - Parameters:
    ///   - provider: 类型
    ///     -  qq
    ///     -  weichat
    ///     -  weibo
    ///   - complete: 回调
    func deleteUserProvider(provider: ProviderType, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) {
        let requestMethod = BindingNetworkRequest().deletUserProvider
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: provider.rawValue), parameter: nil, complete: { (response, status) in
            var message: String?
            guard status else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: response)
                complete(message, false)
                return
            }
            complete(nil, true)
        })
    }

    /// 获取当前用户绑定的三方
    ///
    /// - Parameter complete: ["qq","wechat"] or []
    func getUserSocialite(complete: @escaping ((_ socialite: Array<String>, _ status: Bool) -> Void)) {
        let requestMethod = BindingNetworkRequest().getUserSocialite
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: nil, complete: { (response, status) in
            var array: Array<String> = []
            guard status else {
                complete(array, false)
                return
            }
            array = response as! Array<String>
            complete(array, true)
        })
    }

    /// 解析服务器返回数据
    ///
    /// - Parameter response: 服务器返回数据
    /// - Returns: 返回一句话展示给用户
    func serverMessage(response: NetworkResponse?) -> String {
        var message = "网络请求失败"
        if let serverMsg = TSCommonNetworkManager.getNetworkErrorMessage(with: response) {
            message = serverMsg
        }
        return message
    }
}
