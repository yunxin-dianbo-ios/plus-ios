//
//  TSAnswerWebEditorController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  问答-答案 web编辑器

import UIKit
import PKHUD
import Kingfisher

typealias TSAnswerEditControllerProtocol = TSAnswerWebEditorControllerProtocol
typealias TSPublishAnswerControllerProtocol = TSAnswerWebEditorControllerProtocol

typealias TSAnswerEditController = TSAnswerWebEditorController
typealias TSPublishAnswerController = TSAnswerWebEditorController

protocol TSAnswerWebEditorControllerProtocol: class {
    /// 首次发布答案成功的回调
    func answerEditVC(_ answerEditVC: TSAnswerWebEditorController, didPublishAnswerSuccess answer: TSAnswerListModel) -> Void
    /// 编辑答案成功后的回调
    func answerEditVC(_ answerEditVC: TSAnswerWebEditorController, didEditAnswerSuccess newAnswer: String) -> Void
    /// 保存草稿的回调(含：新建草稿的回调 + 修改草稿的回调)
    func answerEditVC(_ answerEditVC: TSAnswerWebEditorController, didSaveDraft draft: TSAnswerDraftModel) -> Void
}
extension TSAnswerWebEditorControllerProtocol {
    /// 首次发布答案成功的回调
    func answerEditVC(_ answerEditVC: TSAnswerWebEditorController, didPublishAnswerSuccess answer: TSAnswerListModel) -> Void {
    }
    /// 编辑答案成功后的回调
    func answerEditVC(_ answerEditVC: TSAnswerWebEditorController, didEditAnswerSuccess newAnswer: String) -> Void {
    }
    /// 保存草稿的回调
    func answerEditVC(_ answerEditVC: TSAnswerWebEditorController, didSaveDraft draft: TSAnswerDraftModel) -> Void {
    }
}

/// 答案web编辑器
class TSAnswerWebEditorController: TSWebEditorBaseController {

    // MARK: - Internal Property

    /// 回调
    weak var delegate: TSAnswerWebEditorControllerProtocol?
    /// 保存草稿的回调
    var saveDraftAction: ((_ draftModel: TSAnswerDraftModel) -> Void)?
    /// 发布答案成功的回调
    var publishAnswerSuccessAction: ((_ answer: TSAnswerListModel) -> Void)?
    /// 答案编辑成功后的回调
    var editAnswerSuccessAction: ((_ answer: String) -> Void)?

    /// 待回答的问题Id
    var questionId: Int?
    /// 待回答的问题的title
    var questionTitle: String?
    /// 待编辑的答案 - 某些情况下可以编辑已发布的答案
    var editedAnswer: TSAnswerDetailModel?
    /// 待编辑的答案草稿
    var editedDraft: TSAnswerDraftModel?

    // MARK: - Internal Function
    // MARK: - Private Property

    /// 匿名设置工具视图
    fileprivate let anonymousSettingView = TSEditorAnonymousSettingView()

    /// 图片上传的最大数
    fileprivate let picMaxCount: Int = 9

    /// 是否匿名发布
    fileprivate var isAnonymous: Bool = false

    // MARK: - Initialize Function

    /// 草稿箱构造
    init(draft: TSAnswerDraftModel) {
        super.init(editType: .draft)
        self.editedDraft = draft
        self.isEditDraft = true
    }
    /// 答案编辑/修改
    init(answer: TSAnswerDetailModel) {
        self.editedAnswer = answer
        super.init(editType: .update)
    }
    /// 添加答案
    init(questionId: Int, questionTitle: String?) {
        self.questionId = questionId
        self.questionTitle = questionTitle
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

extension TSAnswerWebEditorController {

    /// 界面布局
    override func initialUI() -> Void {
        self.view.backgroundColor = UIColor.white
        // 1. navigation bar
        self.navigationItem.title = "标题_添加回答".localized
        let backItem = UIButton(type: .custom)
        backItem.addTarget(self, action: #selector(leftItemClick), for: .touchUpInside)
        self.setupNavigationTitleItem(backItem, title: "显示_导航栏_返回".localized)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backItem)
        let nextItem = UIButton(type: .custom)
        nextItem.addTarget(self, action: #selector(rightItemClick), for: .touchUpInside)
        nextItem.setTitleColor(UIColor.lightGray, for: .disabled)
        self.setupNavigationTitleItem(nextItem, title: "显示_发布".localized)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextItem)
        self.leftItem = backItem
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
        anonymousSettingView.title = "显示_匿名回答".localized
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
extension TSAnswerWebEditorController {

    override func initialDataSource() {
        super.initialDataSource()
    }

    override func loadDataNoMarkdown() {
        // 匿名的默认配置
        self.anonymousSettingView.switchView.isOn = false
        self.isAnonymous = false
        switch self.editType {
        case .normal:
            break
        case .draft:
            guard let answerDraft = self.editedDraft else {
                return
            }
            self.anonymousSettingView.switchView.isOn = answerDraft.isAnonymity
            self.isAnonymous = answerDraft.isAnonymity
        case .update:
            guard let editAnswer = self.editedAnswer else {
                return
            }
            self.anonymousSettingView.switchView.isOn = editAnswer.isAnonymity
            self.isAnonymous = editAnswer.isAnonymity
        }
    }

    override func loadDataForMarkdownContent() {
        switch self.editType {
        case .normal:
            break
        case .draft:
            guard let answerDraft = self.editedDraft else {
                return
            }
            super.loadDataWithMarkdown(answerDraft.markdown)
        case .update:
            guard let editAnswer = self.editedAnswer else {
                return
            }
            super.loadDataWithMarkdown(editAnswer.body)
        }
    }

}

extension TSAnswerWebEditorController {

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
        self.view.endEditing(true)  // 键盘关闭
        guard let markdown = self.editorView.getContentMarkdown(), let content = self.editorView.getContentText() else {
            return
        }
        switch self.editType {
        case .normal:
            // 提交答案的请求
            guard let questionId = self.questionId else {
                return
            }
            self.publishAnswer(questionId: questionId, markdown: markdown, content: content)
        case .update:
            // 编辑答案的请求
            guard let answer = self.editedAnswer else {
                return
            }
            self.updateAnswer(answerId: answer.id, markdown: markdown, content: content)
        case .draft:
            guard let draftModel = self.editedDraft else {
                return
            }
            if let answerId = draftModel.answerId {
                self.updateAnswer(answerId: answerId, markdown: markdown, content: content)
            } else {
                self.publishAnswer(questionId: draftModel.questionId, markdown: markdown, content: content)
            }
        }
    }
}

extension TSAnswerWebEditorController {
    override func couldSaveDraft() -> Bool {
        return self.couldNext()
    }
    override func saveDraft() {
        guard let markdown = self.editorView.getContentMarkdown(), let content = self.editorView.getContentText() else {
            return
        }
        // 保存至草稿箱 - 草稿模型的构建可以优化，不用在这里进行每个属性赋值
        switch self.editType {
        case .normal:
            guard let questionId = self.questionId else {
                return
            }
            let draftModel = TSAnswerDraftModel()
            draftModel.questionId = questionId
            draftModel.questionTitle = self.questionTitle
            draftModel.markdown = markdown
            draftModel.content = content
            draftModel.isAnonymity = self.isAnonymous
            TSDatabaseManager().draft.addAnswerDraft(draftModel)
            self.delegate?.answerEditVC(self, didSaveDraft: draftModel)
            self.saveDraftAction?(draftModel)
        case .draft:
            guard let draftModel = self.editedDraft else {
                return
            }
            draftModel.updateDate = Date()
            draftModel.markdown = markdown
            draftModel.content = content
            draftModel.isAnonymity = self.isAnonymous
            TSDatabaseManager().draft.updateAnswerDraft(draftModel)
            self.delegate?.answerEditVC(self, didSaveDraft: draftModel)
            self.saveDraftAction?(draftModel)
        case .update:
            guard let draftModel = self.editedDraft else {
                return
            }
            draftModel.updateDate = Date()
            draftModel.markdown = markdown
            draftModel.content = content
            draftModel.isAnonymity = self.isAnonymous
            TSDatabaseManager().draft.updateAnswerDraft(draftModel)
            self.delegate?.answerEditVC(self, didSaveDraft: draftModel)
            self.saveDraftAction?(draftModel)
        }
    }
}

// MARK: - 事件响应
extension TSAnswerWebEditorController {
    /// 导航栏 取消按钮 点击响应
    override func leftItemClick() {
        super.leftItemClick()
    }

    /// 匿名的switch值改变响应
    @objc fileprivate func switchValueChanged(_ switchView: UISwitch) -> Void {
        if switchView.isOn {
            self.view.endEditing(true)
            // 匿名弹窗提示 并 选择 - 匿名弹窗应提取出一个方法来
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
            self.isAnonymous = false
        }
    }
}

// MARK: - 响应扩展

extension TSAnswerWebEditorController {
    // 发布答案 markdown答案详情的markdown描述，content答案详情的纯文字描述
    fileprivate func publishAnswer(questionId: Int, markdown: String, content: String) -> Void {
        self.rightItem.isEnabled = false
        let loadingAlert = TSIndicatorWindowTop(state: .success, title: "提示信息_发布中".localized)
        loadingAlert.show()
        TSQuoraNetworkManager.answer(question: questionId, markdown: markdown, content: content, isAnonymity: self.isAnonymous) { [weak self] (answer, msg, status) in
            loadingAlert.dismiss()
            guard let WeakSelf = self else {
                return
            }
            self?.rightItem.isEnabled = true
            if status {
                let alert = TSIndicatorWindowTop(state: .success, title: "提示信息_发布成功".localized)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                    // 移除缓存中的图片
                    self?.removeImageCaches(fileIds: WeakSelf.getImageIds())
                    if let publishAnswer = answer {
                        self?.delegate?.answerEditVC(WeakSelf, didPublishAnswerSuccess: publishAnswer)
                        self?.publishAnswerSuccessAction?(publishAnswer)
                    }
                    _ = self?.navigationController?.popViewController(animated: true)
                })
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: String(format: "%@: %@", "提示信息_发布失败".localized, msg ?? ""))
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }

    // 编辑答案 markdown答案详情的markdown描述，content答案详情的纯文字描述
    fileprivate func updateAnswer(answerId: Int, markdown: String, content: String) -> Void {
        self.rightItem.isEnabled = false
        let loadingAlert = TSIndicatorWindowTop(state: .success, title: "提示信息_更新中".localized)
        loadingAlert.show()
        TSQuoraNetworkManager.updateAnswer(answerId, markdown: markdown, content: content, isAnonymity: self.isAnonymous, complete: { [weak self] (msg, status) in
            loadingAlert.dismiss()
            guard let WeakSelf = self else {
                return
            }
            self?.rightItem.isEnabled = true
            if status {
                let alert = TSIndicatorWindowTop(state: .success, title: "提示信息_更新成功".localized)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                    // 移除缓存中的图片
                    self?.removeImageCaches(fileIds: WeakSelf.getImageIds())
                    self?.delegate?.answerEditVC(WeakSelf, didEditAnswerSuccess: content)
                    self?.editAnswerSuccessAction?(content)
                    _ = self?.navigationController?.popViewController(animated: true)
                })
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: String(format: "%@: %@", "提示信息_更新失败".localized, msg ?? ""))
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        })
    }
}

// MARK: - Nofication
extension TSAnswerWebEditorController {

}

/// MARK: - WebEditor相关的js回调，用于子类重写
extension TSAnswerWebEditorController {

}

// MARK: - TSAnonymousPromptPopViewProtocol
/// 匿名弹窗提示视图的回调响应
extension TSAnswerWebEditorController: TSAnonymousPromptPopViewProtocol {
    /// 确定按钮点击响应
    func didConfirmBtnClick() {
        self.isAnonymous = true
        self.anonymousSettingView.switchView.isOn = true
    }
    /// 取消按钮点击响应
    func didCancelBtnClick() {
        self.isAnonymous = false
        self.anonymousSettingView.switchView.isOn = false
    }
}
