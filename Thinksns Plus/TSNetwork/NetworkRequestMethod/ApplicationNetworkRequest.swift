//
//  ApplicationNetworkRequest.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  应用相关的网络请求

import UIKit

struct ApplicationNetworkRequest {
    /// 图片上传前检查
    ///
    /// - RouteParameter:
    ///    - hash: 上传文件md5 hash 值
    /// - RequestParameter: None
    let checkFile = Request<Empty>(method: .get, path: "files/uploaded/:hash", replacers: [":hash"])
}
