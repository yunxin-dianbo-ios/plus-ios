//
//  TSTripartiteAuthorizationManager.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  三方登录的授权管理
//  注：三方管理其实应该独立出来，而不仅仅是分享和登录，且将三方的模型也可统一(appId/appKey/reservedField)，方便使用。待完成
//      不过若这样的话，变动较大，可以考虑。

import UIKit
import MonkeyKing

/// 三方授权管理
class TSTripartiteAuthorizationManager: NSObject {

    func qqForAuthorization(complete: @escaping ((_ name: String?, _ token: String?, _ status: Bool) -> Void)) {
        // 解析 ShareConfig.plist 文件，获取 appId 或 appKey
        guard let path = Bundle.main.path(forResource: "ShareConfig", ofType: "plist"), let dicInfo = NSDictionary(contentsOfFile: path) as? [String: Any], let qqInfo = dicInfo["QQ"] as? [String: String], let qqAppId = qqInfo["appID"]  else {
            complete(nil, nil, false)
            return
        }
        MonkeyKing.oauth(for: .qq, scope: "get_simple_userinfo") { (info, _, _) in
            guard
                let unwrappedInfo = info,
                let accessToken = unwrappedInfo["access_token"] as? String,
                let openID = unwrappedInfo["openid"] as? String else {
                    complete(nil, nil, false)
                    return
            }
            let query = "get_simple_userinfo"
            let userInfoAPI = "https://graph.qq.com/user/\(query)" // 拼接访问用户资料路径
            let parameters = [
                "openid": openID,                   // 服务器返回数据
                "access_token": accessToken,        // 服务器返回数据
                "oauth_consumer_key": qqAppId       // 扣扣开发者平台上应用的key
            ]
            SimpleNetworking.sharedInstance.request(userInfoAPI, method: .get, parameters: parameters) { (userInfo, _, _) in
                DispatchQueue.main.sync {
                    guard let nickName = userInfo?["nickname"] as? String else {
                        complete(nil, nil, false)
                        return
                    }
                    complete(nickName, accessToken, true)
                }
            }
        }
    }

    func weichatForAuthorization(complete: @escaping ((_ name: String?, _ token: String?, _ status: Bool) -> Void)) {
        // 解析 ShareConfig.plist 文件，获取 appId 或 appKey
        guard let path = Bundle.main.path(forResource: "ShareConfig", ofType: "plist"), let dicInfo = NSDictionary(contentsOfFile: path) as? [String: Any], let wcInfo = dicInfo["WeChat"] as? [String: String], let wcAppId = wcInfo["appID"], let wcAppKey = wcInfo["appKey"] else {
            complete(nil, nil, false)
            return
        }
        let accountWithoutAppKey = MonkeyKing.Account.weChat(appID: wcAppId, appKey: nil)
        MonkeyKing.registerAccount(accountWithoutAppKey)
        MonkeyKing.oauth(for: .weChat) { (dictionary, response, error) in
            guard let code = dictionary?["code"] as? String else {
                complete(nil, nil, false)
                return
            }
            // MARK: - 获得微信临时code
            // 拼接访问获得token等数据的链接
            var accessTokenAPI = "https://api.weixin.qq.com/sns/oauth2/access_token?"
            accessTokenAPI += "appid=" + wcAppId
            accessTokenAPI += "&secret=" + wcAppKey
            accessTokenAPI += "&code=" + code + "&grant_type=authorization_code"
            SimpleNetworking.sharedInstance.request(accessTokenAPI, method: .get) { (OAuthJSON, _, _) in
                guard let accessToken = OAuthJSON?["access_token"] as? String else {
                    complete(nil, nil, false)
                    return
                }
                guard let openID = OAuthJSON?["openid"] as? String else {
                    complete(nil, nil, false)
                    return
                }
                // 拼接访问用户资料路径
                var api = "https://api.weixin.qq.com/sns/userinfo?"
                api += "access_token=" + accessToken
                api += "&openid=" + openID
                SimpleNetworking.sharedInstance.request(api, method: .get) { (result, _, _) in
                    DispatchQueue.main.sync {
                        guard let nickName = result?["nickname"] as? String else {
                            complete(nil, nil, false)
                            return
                        }
                        complete(nickName, accessToken, true)
                    }
                }
            }
        }

    }

    func weiboForAuthorization(complete: @escaping ((_ name: String?, _ token: String?, _ status: Bool) -> Void)) {
        MonkeyKing.oauth(for: .weibo) { (info, _, _) in
            guard
                let unwrappedInfo = info,
                let accessToken = (unwrappedInfo["access_token"] as? String) ?? (unwrappedInfo["accessToken"] as? String),
                let userID = (unwrappedInfo["uid"] as? String) ?? (unwrappedInfo["userID"] as? String) else {
                    complete(nil, nil, false)
                    return
            }
            let userInfoAPI = "https://api.weibo.com/2/users/show.json" // 拼接访问用户资料路径
            let parameters = [
                "uid": userID,                  // 服务器返回数据
                "access_token": accessToken     // 服务器返回数据
            ]
            SimpleNetworking.sharedInstance.request(userInfoAPI, method: .get, parameters: parameters) { (userInfo, _, _) in
                DispatchQueue.main.sync {
                    guard let nickName = userInfo?["screen_name"] as? String else {
                        complete(nil, nil, false)
                        return
                    }
                    complete(nickName, accessToken, true)
                }
            }
        }
    }
}
