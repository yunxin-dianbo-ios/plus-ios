//
//  TSMarkdownController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 29/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  加载markdown内容的控制器
//  当前主要用来显示注册协议

import UIKit
import MarkdownView

class TSMarkdownController: TSViewController {
    // MARK: - Internal Property
    // MARK: - Internal Function
    // MARK: - Private Property

    fileprivate weak var markdownView: MarkdownView!
    fileprivate var markdownContent: String

    // MARK: - Initialize Function
    init(markdown: String) {
        self.markdownContent = markdown
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }

}

// MARK: - UI

extension TSMarkdownController {
    /// 页面布局
    fileprivate func initialUI() -> Void {

        let markdownView = MarkdownView()
        self.view.addSubview(markdownView)
        markdownView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.markdownView = markdownView
    }
}

// MARK: - 数据处理与加载

extension TSMarkdownController {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        self.loading()
        self.markdownView.load(markdown: self.markdownContent, enableImage: true)
        self.markdownView.onRendered = { [weak self] (_) in
            self?.endLoading()
        }
    }
}

// MARK: - 事件响应

extension TSMarkdownController {

}

// MARK: - Notification

extension TSMarkdownController {

}

// MARK: - Delegate Function

// MARK: - LoadingViewDelegate: loading view 的代理事件
extension TSMarkdownController {
    override func reloadingButtonTaped() {
        self.initialDataSource()
    }
}
