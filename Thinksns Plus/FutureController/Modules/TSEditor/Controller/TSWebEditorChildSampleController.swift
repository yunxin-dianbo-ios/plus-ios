//
//  TSWebEditorChildController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 24/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  web编辑器继承自TSWebEditorBaseController的示例

import UIKit

class TSWebEditorChildSampleController: TSWebEditorBaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}

// MARK: - UI
extension TSWebEditorChildSampleController {
    /// 页面布局
    override func initialUI() -> Void {
        // navigationbar
        self.navigationItem.title = "WebChild编辑器"
        let backItem = UIButton(type: .custom)
        backItem.addTarget(self, action: #selector(leftItemClick), for: .touchUpInside)
        self.setupNavigationTitleItem(backItem, title: "显示_导航栏_返回".localized)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backItem)
        let nextItem = UIButton(type: .custom)
        nextItem.addTarget(self, action: #selector(rightItemClick), for: .touchUpInside)
        self.setupNavigationTitleItem(nextItem, title: "显示_发布".localized)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextItem)
        nextItem.setTitleColor(UIColor.lightGray, for: .disabled)
        self.rightItem = nextItem
        // editorView
        let editorView = TSWebEidtorView()
        self.view.addSubview(editorView)
        editorView.delegate = self
        editorView.setFooterHeight(10)
        editorView.scrollView.delegate = self
        editorView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(0)
            make.top.equalTo(self.view)
        }
        // toolbar
        let toolbar = TSEditorToolBar()
        self.view.addSubview(toolbar)
        toolbar.delegate = self
        toolbar.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(toolbar.currentHeight)
        }
        self.editorToolbar = toolbar
    }
}

extension TSWebEditorChildSampleController {

}
