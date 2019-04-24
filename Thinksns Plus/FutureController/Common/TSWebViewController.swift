//
//  TSWebViewController.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/6.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  网页浏览器

import UIKit
import WebKit

private struct TSWebViewControllerUX {
    static let timeoutInterval = 10
}

class TSWebViewController: TSViewController, WKNavigationDelegate {

    /// 网页地址
    var url: URL? = nil
    /// 网页视图
    let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - TSNavigationBarHeight))
    /// 返回按钮
    let buttonForBack = TSButton(type: .custom)
    /// 关闭按钮
    let buttonForClose = TSButton(type: .custom)
    /// 进度条
    open let progressView = UIProgressView(progressViewStyle: .bar)
    /// 缺省图
    let occupiedView = TSButton(type: .custom)
    /// 是否开启请求网页时,携带口令在请求头中
    var haveToken: Bool = true

    // MARK: - Lifecycle
    /// 自定义初始化方法
    ///
    /// - Parameter url: 链接
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
        if let token = RequestNetworkData.share.authorization, url.absoluteString.contains("__token__") {
            var tokenUrl = url.absoluteString
            tokenUrl.replaceAll(matching: "__token__", with: token)
            self.url = URL(string: tokenUrl)!
        }
    }

    deinit {
        progressView.removeFromSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 添加观察者观察 webView 加载进度
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 移除观察者
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        // 隐藏进度条
        progressView.isHidden = true
    }

    // MARK: - Custom user interface 
    /// 视图相关
    func setUI() {
        // set let navbar item
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        buttonForBack.setImage(UIImage(named: "IMG_topbar_back"), for: .normal)
        buttonForBack.frame = CGRect(x: -11, y: -1, width: 44, height: 44)
        buttonForBack.addTarget(self, action: #selector(backButtonTaped), for: .touchUpInside)
        buttonForClose.setTitle("关闭", for: .normal)
        buttonForClose.setTitleColor(.black, for: .normal)
        buttonForClose.frame = CGRect(x: 44, y: 0, width: 44, height: 44)
        buttonForClose.addTarget(self, action: #selector(closeButtonTaped), for: .touchUpInside)
        buttonForClose.isHidden = true
        backView.addSubview(buttonForBack)
        backView.addSubview(buttonForClose)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backView)
        // 在右方放置了一个同样大小的 view，可以将 title view 顶在正中间
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: UIView(frame: CGRect(x: 0, y: 0, width: 88, height: 44)))

        // progress view
        progressView.frame = CGRect(x: 0, y: TSNavigationBarHeight, width: UIScreen.main.bounds.width, height: progressView.frame.height)
        progressView.tintColor = TSColor.main.theme
        navigationController?.view.addSubview(progressView)

        // webview
        self.view.addSubview(webView)
        webView.navigationDelegate = self
        var request = URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: TimeInterval(TSWebViewControllerUX.timeoutInterval))

        if let authorization = TSCurrentUserInfo.share.accountToken?.token, haveToken {
            request.addValue("Bearer \(authorization)", forHTTPHeaderField: "Authorization")
        }
        webView.load(request)

        // occupied view
        occupiedView.frame = UIScreen.main.bounds
        occupiedView.backgroundColor = UIColor.clear
        view.addSubview(occupiedView)
        self.view.bringSubview(toFront: occupiedView)
    }

    // MARK: - Button click
    /// 点击了返回按钮
    func backButtonTaped() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            closeButtonTaped()
        }
    }

    /// 点击了关闭按钮
    func closeButtonTaped() {
        let popVC = navigationController?.popViewController(animated: true)
        if popVC == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    /// 点击了占位图
    @IBAction func occupiedViewTaped() {
        updateWebView()
    }

    // MARK: - Private
    /// 刷新网页
    func updateWebView() {
        webView.reload()
    }

    // MARK: - Delegate
    // MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 这里为了让用户感觉到进度，设置了一个假进度
        progressView.progress = 0.2
        progressView.isHidden = false
        // 隐藏占位图
        occupiedView.isHidden = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 更新网页标题
        self.title = webView.title
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // 显示占位图，再次点击可重新刷新
        occupiedView.isHidden = false
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
        decisionHandler( .allow)
    }

    // MARK: - Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            switch Float(self.webView.estimatedProgress) {
            case 1.0: // 隐藏进度条
                UIView.animate(withDuration: 0.1, animations: {
                    self.progressView.alpha = 0
                }, completion: nil)
            default:  // 显示进度条
                self.progressView.alpha = 1
            }
            progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
        }
    }
}
