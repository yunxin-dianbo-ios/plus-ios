//
//  TSShareProtocol.swift
//  Thinksns Plus
//
//  Created by GorCat on 16/12/21.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  分享内部实现

import UIKit
import MonkeyKing

// MARK: - ShareManager 分享账号管理
class ShareManager: NSObject {

    enum ThirdType {
        case qq
        case wechat
        case weibo
    }

    /// 获取封装号的三方账号信息
    ///
    /// - Parameter type: 三方账号类型，目前有 qq、wechat、weibo 三种类型
    /// - Returns: 封装成 MonkeyKing.Account 类型的三方账号信息
    class func thirdAccout(type: ThirdType) -> MonkeyKing.Account {
        // 解析 ShareConfig.plist 文件
        let path = Bundle.main.path(forResource: "ShareConfig", ofType: "plist")
        let shareInfoDic = (NSDictionary(contentsOfFile: path!) as? [String: Any])!
        let weiboInfo = (shareInfoDic["Weibo"] as? [String: String])!
        let wechatInfo = (shareInfoDic["WeChat"] as? [String: String])!
        let qqInfo = (shareInfoDic["QQ"] as? [String: String])!
        // 返回对应的账号信息
        var accountMessage: MonkeyKing.Account? = nil

        switch type {
        case .qq:
            accountMessage = MonkeyKing.Account.qq(appID: qqInfo["appID"]!)
        case .wechat:
            accountMessage = MonkeyKing.Account.weChat(appID: wechatInfo["appID"]!, appKey: wechatInfo["appKey"]!)
        case .weibo:
            accountMessage = MonkeyKing.Account.weibo(appID: weiboInfo["appID"]!, appKey: weiboInfo["appKey"]!, redirectURL: weiboInfo["redirectURL"]!)
        }
        if accountMessage == nil {
            TSLogCenter.log.debug("TSShareProtocol 45 行，type = \(type)时，账号信息为空，请检查关于此种类型的账号信息配置无误")
        }
        return accountMessage!
    }
}

// MARK: - Share Protocol 分享协议
var accessTokenForWeibo: String? // aceesToken 是和网页登录相关的东西
protocol Sharable {

}

extension Sharable where Self: UIView {

    func shareURLToWeiboWith(URLString: String?, image: UIImage?, description: String?, title: String?, complete: @escaping(_ result: Bool) -> Void) {
        if !ShareManager.thirdAccout(type: .weibo).isAppInstalled {
            MonkeyKing.oauth(for: .weibo) { (info, _, error) in
                if let accessToken = info?["access_token"] as? String {
                    accessTokenForWeibo = accessToken
                    self.shareToWeibo(URLString: URLString, image: image, description: description, title: title, complete: complete)
                } else {
                    complete(false)
                }
                TSLogCenter.log.debug("MonkeyKing.oauth info: \(info), error: \(error)")
            }
        } else {
            shareToWeibo(URLString: URLString, image: image, description: description, title: title, complete: complete)
        }
    }

    func shareURLToQQ(URLString: String?, image: UIImage?, description: String?, title: String?, complete: @escaping(_ result: Bool) -> Void) {
        if !ShareManager.thirdAccout(type: .qq).isAppInstalled {
            MonkeyKing.oauth(for: .qq) { (info, _, error) in
                if let accessToken = info?["access_token"] as? String {
                    accessTokenForWeibo = accessToken
                    self.shareToQQ(URLString: URLString, image: image, description: description, title: title, complete: complete)
                } else {
                    complete(false)
                }
                TSLogCenter.log.debug("MonkeyKing.oauth info: \(info), error: \(error)")
            }
        } else {
            shareToQQ(URLString: URLString, image: image, description: description, title: title, complete: complete)
        }
    }

    func shareURLToQQZone(URLString: String?, image: UIImage?, description: String?, title: String?, complete: @escaping(_ result: Bool) -> Void) {
        let info = MonkeyKing.Info(
            title: title,
            description: description,
            thumbnail: image,
            media: .url(URL(string: URLString!)!)
        )
        MonkeyKing.deliver(MonkeyKing.Message.qq(.zone(info: info))) { result in
            let bool: Bool
            switch result {
            case .success(_):
                bool = true
            case .failure(_):
                bool = false
            }
            complete(bool)
            TSLogCenter.log.debug("zone result: \(result)")
        }
    }

    func shareURLToWeChatWith(URLString: String?, image: UIImage?, description: String?, title: String?, complete: @escaping(_ result: Bool) -> Void) {
        let info = MonkeyKing.Info(
            title: title,
            description: description,
            thumbnail: image,
            media: .url(URL(string: URLString!)!)
        )
        MonkeyKing.deliver(MonkeyKing.Message.weChat(.session(info: info))) { result in
            let bool: Bool
            switch result {
            case .success(_):
                bool = true
            case .failure(_):
                bool = false
            }
            complete(bool)
            TSLogCenter.log.debug("wechat result: \(result)")
        }
    }

    func shareURLToWeChatMomentsWith(URLString: String?, image: UIImage?, description: String?, title: String?, complete: @escaping(_ result: Bool) -> Void) {
        let info = MonkeyKing.Info(
            title: title,
            description: description,
            thumbnail: image,
            media: .url(URL(string: URLString!)!)
        )
        MonkeyKing.deliver(MonkeyKing.Message.weChat(.timeline(info: info))) { result in
            let bool: Bool
            switch result {
            case .success(_):
                bool = true
            case .failure(_):
                bool = false
            }
            complete(bool)
            TSLogCenter.log.debug("moment result: \(result)")
        }
    }

    // MARL: - Private
    private func shareToQQ(URLString: String?, image: UIImage?, description: String?, title: String?, complete: @escaping(_ result: Bool) -> Void) {
        let info = MonkeyKing.Info(
            title: title,
            description: description,
            thumbnail: image,
            media: .url(URL(string: URLString!)!)
        )
        MonkeyKing.deliver(MonkeyKing.Message.qq(.friends(info: info))) { result in
            let bool: Bool
            switch result {
            case .success(_):
                bool = true
            case .failure(_):
                bool = false
            }
            complete(bool)
            TSLogCenter.log.debug("qq result: \(result)")
        }
    }

    private func shareToWeibo(URLString: String?, image: UIImage?, description: String?, title: String?, complete: @escaping(_ result: Bool) -> Void) {
        let message = MonkeyKing.Message.weibo(.default(info: (title: title, description: description, thumbnail: image, media: .url(URL(string: URLString!)!)), accessToken: nil))
        MonkeyKing.deliver(message) { result in
            let bool: Bool
            switch result {
            case .success(_):
                bool = true
            case .failure(_):
                bool = false
            }
            complete(bool)
            TSLogCenter.log.debug("weibo result: \(result)")
        }
    }
}
