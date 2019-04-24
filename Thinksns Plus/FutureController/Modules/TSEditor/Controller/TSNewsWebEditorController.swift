//
//  TSNewsWebEditorController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  资讯编辑器界面

import UIKit
import PKHUD

typealias TSNewsEditController = TSNewsWebEditorController

/// 资讯web编辑器界面
class TSNewsWebEditorController: TSWebEditorBaseController {

    // MARK: - Internal Property

    /// 我的投稿的数据模型
    var editedNewsDetail: NewsDetailModel?
    // 发布模型，可以考虑外界传入，也可以考虑使用本地数据库
    var contributeModel: TSNewsContributeModel?

    // MARK: - Private Property

    /// 标题输入框的最小高度
    fileprivate let titleMinH: CGFloat = 50
    /// 标题长度最大值
    fileprivate let titleMaxLen: Int = 20       // 标题的最大长度
    /// 图片上传的最大数
    fileprivate let picMaxCount: Int = 9

    //fileprivate weak var nextBtn: UIButton!
    /// 标题输入框
    fileprivate weak var titleInputView: TSOriginalCenterOneInputView!

    /// 正文部分
    fileprivate var contentTextW: CGFloat = ScreenWidth

    // MARK: - Initialize Function

    /// 修改
    init(updateModel: NewsDetailModel) {
        self.editedNewsDetail = updateModel
        super.init(editType: .update)
    }
    /// 发布
    init() {
        super.init(editType: .normal)
    }
    // 屏蔽父类构造器
    fileprivate override init(editType: TSEditType) {
        super.init(editType: editType)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal Function
    // MARK: - Override Function

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}

// MARK: - UI
extension TSNewsWebEditorController {
    override func initialUI() {
        self.view.backgroundColor = UIColor.white
        // 1. navigation bar
        self.navigationItem.title = "标题_编辑文章".localized
        let backItem = UIButton(type: .custom)
        backItem.addTarget(self, action: #selector(leftItemClick), for: .touchUpInside)
        self.setupNavigationTitleItem(backItem, title: "显示_导航栏_返回".localized)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backItem)
        let nextItem = UIButton(type: .custom)
        nextItem.addTarget(self, action: #selector(rightItemClick), for: .touchUpInside)
        self.setupNavigationTitleItem(nextItem, title: "显示_下一步".localized)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextItem)
        nextItem.setTitleColor(UIColor.lightGray, for: .disabled)
        self.leftItem = backItem
        self.rightItem = nextItem
        // 2. titleView
        let lrMargin: Float = 15
        let font = UIFont.systemFont(ofSize: 15)
        let titleInputView = TSOriginalCenterOneInputView(viewWidth: ScreenWidth - CGFloat(lrMargin) * 2.0, font: font, maxLine: 2, showTextMinCount: 15, maxTextCount: 20, lrMargin: CGFloat(5), tbMargin: (self.titleMinH - font.lineHeight) / 2.0)
        self.view.addSubview(titleInputView)
        titleInputView.delegate = self
        titleInputView.snp.makeConstraints { (make) in
            make.leading.equalTo(self.view).offset(lrMargin)
            make.trailing.equalTo(self.view).offset(-lrMargin)
            make.top.equalTo(self.view)
            make.height.equalTo(titleMinH)
        }
        titleInputView.addLineWithSide(.inBottom, color: UIColor(hex: 0xdedede), thickness: 0.5, margin1: 0, margin2: 0)
        self.titleInputView = titleInputView
        // 2. editorView
        self.view.addSubview(editorView)
        editorView.delegate = self
        editorView.setFooterHeight(10)
        editorView.scrollView.delegate = self
        editorView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(0)
            make.top.equalTo(titleInputView.snp.bottom).offset(0)
        }
        // 3. toolbar
        let toolbar = TSEditorToolBar()
        self.view.addSubview(toolbar)
        toolbar.delegate = self
        toolbar.inputEnable = false  // 默认选项都不可使用，避免标题键盘弹窗时再处理
        toolbar.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(toolbar.currentHeight)
        }
        self.editorToolbar = toolbar

        titleInputView.placeHolder = "占位符_请输入资讯标题".localized
    }
}

// MARK: - 数据处理与加载
extension TSNewsWebEditorController {

    override func initialDataSource() {
        self.contributeModel = TSNewsContributeModel()
        if let newsDetail = self.editedNewsDetail {
            self.contributeModel = TSNewsContributeModel(news: newsDetail)
        }
        super.initialDataSource()
    }

    /// 加载数据 非markdown部分
    override func loadDataNoMarkdown() {
        switch self.editType {
        case .update:
            guard let model = self.contributeModel else {
                return
            }
            self.titleInputView.text = model.title
        default:
            break
        }
    }
    /// 加载数据 markdown部分
    override func loadDataForMarkdownContent() {
        switch self.editType {
        case .update:
            guard let content = self.contributeModel?.content_markdown else {
                return
            }
            self.loadDataWithMarkdown(content)
        default:
            break
        }
    }

}

extension TSNewsWebEditorController {
    override func couldNext() -> Bool {
        var couldFlag: Bool = true
        guard let title = self.titleInputView.text, let markdown = self.editorView.getContentMarkdown(), let content = self.editorView.getContentText() else {
            return false
        }
        if title.isEmpty {
            couldFlag = false
        } else if markdown.isEmpty {
            couldFlag = false
        } else if content.isEmpty {
            couldFlag = false
        }
        return couldFlag
    }
}

extension TSNewsWebEditorController {

    /// 是否展示 放弃发布提示弹窗
    func couldShowGiveupPublishDialog() -> Bool {
        var couldFlag: Bool = false
        let title = self.titleInputView.text
        let markdown = self.editorView.getContentMarkdown()
        // 投稿模型判断 - 是否是编辑类型
        if let model = self.contributeModel {
            if !model.isEmpty() {
                couldFlag = true
            }
        }
        // 投稿模型为空，则判断当前页面输入(未点击下一步时，投稿模型内部没有赋值)
        if !couldFlag {
            if nil != title && !title!.isEmpty {
                couldFlag = true
            } else if nil != markdown && !markdown!.isEmpty {
                couldFlag = true
            }
        }
        return couldFlag
    }
    /// 显示 放弃发布提示弹窗
    func showGiveupPublishDialog() -> Void {
        let alertVC = TSAlertController(title: nil, message: "提示信息_你还有没发布的内容,是否放弃发布?".localized, style: .actionsheet)
        alertVC.addAction(TSAlertAction(title: "选择_确定".localized, style: .default, handler: { (action) in
            if self.editedNewsDetail?.verifyState != NewsVerifyState.rejected {
                super.removeImageCaches(fileIds: self.getImageIds()) // 缓存图片移除
            }
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alertVC, animated: false, completion: nil)
    }

}

extension TSNewsWebEditorController {

    override func nextProcess() {
        // 获取输入控件中的内容
        guard let title = self.titleInputView.text, let markdown = self.editorView.getContentMarkdown(), let content = self.editorView.getContentText() else {
            return
        }
        let imageIds = self.getImageIds()
        // 发布模型更新
        self.contributeModel?.content_markdown = markdown
        self.contributeModel?.content_text = content
        self.contributeModel?.title = title
        self.contributeModel?.firstImageId = imageIds.first
        // 进入资讯完善界面
        let perfectVC = TSNewsPerfectController()
        perfectVC.contributeModel = self.contributeModel
        self.navigationController?.pushViewController(perfectVC, animated: true)
    }
}

// MARK: - 事件响应
extension TSNewsWebEditorController {
    /// 导航栏 取消按钮 点击响应
    override func leftItemClick() {
        self.view.endEditing(true)
        // 注：资讯没有草稿箱
        if self.couldShowGiveupPublishDialog() {
            self.showGiveupPublishDialog()
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

    /// 导航栏 右侧按钮 点击响应
    override func rightItemClick() {
        super.rightItemClick()
    }
}

// MARK: - Nofication
extension TSNewsWebEditorController {

}

/// MARK: - WebEditor相关的js回调，用于子类重写
extension TSNewsWebEditorController {

    override func editorContentFocus() -> Void {
        super.editorContentFocus()

        UIView.animate(withDuration: 0.25, animations: {
            self.editorView.snp.updateConstraints({ (make) in
                make.top.equalTo(self.titleInputView.snp.bottom).offset(-self.titleInputView.currentHeight)
            })
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    override func editorContentBlur() -> Void {
        super.editorContentBlur()

        UIView.animate(withDuration: 0.25, animations: {
            self.editorView.snp.updateConstraints({ (make) in
                make.top.equalTo(self.titleInputView.snp.bottom).offset(0)
            })
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

// MARK: - TSOriginalCenterOneInputViewProtocol
/// title输入框的回调
extension TSNewsWebEditorController: TSOriginalCenterOneInputViewProtocol {

    func inputView(_ inputView: TSOriginalCenterOneInputView, didLoadedWith minHeight: CGFloat) {
        if minHeight > self.titleMinH {
            inputView.snp.updateConstraints({ (make) in
                make.height.equalTo(minHeight)
            })
        } else {
            inputView.snp.updateConstraints({ (make) in
                make.height.equalTo(self.titleMinH)
            })
        }
        self.view.layoutIfNeeded()
    }
    func inputView(_ inputView: TSOriginalCenterOneInputView, didTextValueChanged newText: String) {
        self.couldNextProcess()
    }
    func inputView(_ inputView: TSOriginalCenterOneInputView, didHeightChanged newHeight: CGFloat) {
        if newHeight > self.titleMinH {
            inputView.snp.updateConstraints({ (make) in
                make.height.equalTo(newHeight)
            })
        } else {
            inputView.snp.updateConstraints({ (make) in
                make.height.equalTo(self.titleMinH)
            })
        }
        self.view.layoutIfNeeded()
    }
}
