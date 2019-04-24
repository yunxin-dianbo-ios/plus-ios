//
//  TSWebViewControllerMock.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  网页浏览器的 mock 

@testable import Thinksns_Plus
import WebKit

class TSWebViewControllerMock: TSWebViewController {

    /// 检测是否执行了关闭网页的操作
    var shouldReturn = false
    override func closeButtonTaped() {
        super.closeButtonTaped()
        shouldReturn = true
    }

    /// 检测是否执行了刷新网页的操作
    var hasUploadWebView = false
    override func updateWebView() {
        super.updateWebView()
        hasUploadWebView = true
    }
}
