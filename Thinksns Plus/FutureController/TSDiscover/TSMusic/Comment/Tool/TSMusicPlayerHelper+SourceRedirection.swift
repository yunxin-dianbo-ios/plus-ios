//
//  TSMusicPlayerHelper+SourceRedirection.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/12.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  音乐资源地址重定向
//  Remark:
//  收费歌曲请求时需要添加对应的token，即使添加token但没有付费时，请求返回的结果为json，并提示付费相关信息

import Foundation
import Regex

extension TSMusicPlayerHelper: NSURLConnectionDataDelegate {

    func getRedirectionURLPath(musicSourceID id: Int) {
        TSDatabaseMusic().select(musicRedirectionURLPathWithMusicID: id) { (urlStr) in
            if let str = urlStr {
                self.player.replaceItem(WithUrl: URL(string: str)!)
                return
            }
            self.sendRequset(url: TSURLPath.imageV2URLPath(storageIdentity: id, compressionRatio: nil, size: nil)!, musicSourceID: id)
        }
    }

    func sendRequset(url: URL, musicSourceID id: Int) {
        redirictionID = id

        let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10)
        // 收费歌曲需要添加token
        if TSCurrentUserInfo.share.isLogin {
            let authorization = TSCurrentUserInfo.share.accountToken!.token
            let token = "Bearer " + authorization
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }
        _ = NSURLConnection(request: request as URLRequest, delegate: self)

    }

    func connection(_ connection: NSURLConnection, willSend request: URLRequest, redirectResponse response: URLResponse?) -> URLRequest? {
        // 由于解析规则变更，之前实际链接是后缀".mp3"，现在变更为其他各种格式".mp3/.mpga/..."，另url可能添加别的参数如token或其他
        // 若修改此处，请先参考Git上之前的写法。
        self.player.replaceItem(WithUrl: request.url!)
        TSDatabaseMusic().save(musicRedirectionURLPath: (request.url?.absoluteString)!, musicID: redirictionID)
        return request
    }
    func connectionDidFinishLoading(_ connection: NSURLConnection) {

    }
}
