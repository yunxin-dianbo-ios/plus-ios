//
//  TSQuestionWebEditorController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  问答-问题 web编辑器
//  注1：问题详情页上传的图片有数量限制，限制方案采用每次上传图片时判断图片数量，而不是记录当前图片数，因为后者需要对每次的删除输入进行判断。

import UIKit
import PKHUD
import Kingfisher

typealias TSQuestionDetailEditController = TSQuestionWebEditorController

/// 问题的web编辑器
class TSQuestionWebEditorController: TSWebEditorBaseController {

    // MARK: - Internal Property
    /// 编辑类型
    let type: TSQuoraEditType
    /// 当前编辑模型
    var contributeModel: TSQuestionContributeModel?

    // MARK: - Internal Function
    // MARK: - Private Property

    /// 匿名设置工具视图
    fileprivate let anonymousSettingView = TSEditorAnonymousSettingView()

    /// 图片上传的最大数
    fileprivate let picMaxCount: Int = 9

    // MARK: - Initialize Function

    init(type: TSQuoraEditType) {
        self.type = type
        super.init(editType: .normal)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - UI加载

extension TSQuestionWebEditorController {

    /// 界面布局
    override func initialUI() -> Void {
        self.view.backgroundColor = UIColor.white
        // 1. navigation bar
        self.navigationItem.title = "标题_问题详情".localized
//        let backItem = UIButton(type: .custom)
//        backItem.addTarget(self, action: #selector(leftItemClick), for: .touchUpInside)
//        self.setupNavigationTitleItem(backItem, title: "显示_导航栏_返回".localized)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backItem)
        let nextItem = UIButton(type: .custom)
        nextItem.addTarget(self, action: #selector(rightItemClick), for: .touchUpInside)
        nextItem.setTitleColor(UIColor.lightGray, for: .disabled)
        self.setupNavigationTitleItem(nextItem, title: "显示_下一步".localized)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextItem)
//        self.leftItem = backItem
        self.rightItem = nextItem
        // 2. editorView
        self.view.addSubview(editorView)
        editorView.delegate = self
        editorView.setFooterHeight(10)
        editorView.scrollView.delegate = self
        editorView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(0)
            make.top.equalTo(self.view).offset(0)
        }
        // 3. toolbar
        let toolbar = TSEditorToolBar(showSetting: (TSAppConfig.share.launchInfo?.anonymousStatus)!)
        self.view.addSubview(toolbar)
        toolbar.delegate = self
        toolbar.inputEnable = false  // 默认选项都不可使用，避免标题键盘弹窗时再处理
        anonymousSettingView.switchView.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        toolbar.settingExtensionView = self.anonymousSettingView
        toolbar.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(toolbar.currentHeight)
        }
        self.editorToolbar = toolbar
    }
}

// MARK: - 数据处理与加载
extension TSQuestionWebEditorController {

    override func initialDataSource() {
        super.initialDataSource()
    }

    override func loadDataNoMarkdown() {
        guard let contributeModel = self.contributeModel else {
            return
        }
        // 匿名状态展示
        self.anonymousSettingView.switchView.isOn = contributeModel.isAnonymous
    }
    override func loadDataForMarkdownContent() {
        guard let content = self.contributeModel?.content else {
            return
        }
        super.loadDataWithMarkdown(content)
    }
}

extension TSQuestionWebEditorController {

    override func couldNext() -> Bool {
        var couldFlag: Bool = true
        guard let markdown = self.editorView.getContentMarkdown(), let content = self.editorView.getContentText() else {
            return false
        }
        if markdown.isEmpty || content.isEmpty {
            couldFlag = false
        }
        return couldFlag
    }

    override func nextProcess() {
        guard let markdown = self.editorView.getContentMarkdown(), let content = self.editorView.getContentText() else {
            return
        }
        // 发布模型更新
        self.contributeModel?.content = markdown
        self.contributeModel?.content_text = content
        // 进入话题选择界面
        let topicSelecVC = TSQuestionTopicSelectController()
        topicSelecVC.contributeModel = self.contributeModel
        topicSelecVC.type = self.type
        self.navigationController?.pushViewController(topicSelecVC, animated: true)
    }
}

extension TSQuestionWebEditorController {

}

// MARK: - 事件响应
extension TSQuestionWebEditorController {
    /// 导航栏 取消按钮 点击响应
    override func leftItemClick() {
        self.view.endEditing(true)
        self.contributeModel?.content = self.editorView.getContentMarkdown()
        self.contributeModel?.content_text = self.editorView.getContentText()
        _ = self.navigationController?.popViewController(animated: true)
    }

    /// 匿名的switch值改变响应
    @objc fileprivate func switchValueChanged(_ switchView: UISwitch) -> Void {
        if switchView.isOn {
            self.view.endEditing(true)
            // 匿名弹窗提示 并 选择
            let popView = TSAnonymousPromptPopView()
            guard let window = UIApplication.shared.keyWindow else {
                return
            }
            window.addSubview(popView)
            window.bringSubview(toFront: popView)
            popView.delegate = self
            popView.snp.makeConstraints { (make) in
                make.edges.equalTo(window)
            }
        } else {
            // 不使用匿名
            self.contributeModel?.isAnonymous = false
        }
    }
}

// MARK: - Nofication
extension TSQuestionWebEditorController {

}

/// MARK: - WebEditor相关的js回调，用于子类重写
extension TSQuestionWebEditorController {

}

// MARK: - TSAnonymousPromptPopViewProtocol

/// 匿名弹窗提示视图的回调响应
extension TSQuestionWebEditorController: TSAnonymousPromptPopViewProtocol {
    /// 确定按钮点击响应
    func didConfirmBtnClick() {
        self.contributeModel?.isAnonymous = true
        self.anonymousSettingView.switchView.isOn = true
    }
    /// 取消按钮点击响应
    func didCancelBtnClick() {
        self.contributeModel?.isAnonymous = false
        self.anonymousSettingView.switchView.isOn = false
    }
}
