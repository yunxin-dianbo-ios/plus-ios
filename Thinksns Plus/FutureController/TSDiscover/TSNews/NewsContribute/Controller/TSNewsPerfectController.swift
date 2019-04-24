//
//  TSNewsPerfectController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 11/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯完善界面 Perfect-使完善

import UIKit
import IQKeyboardManagerSwift

class TSNewsPerfectController: TSViewController {

    // MARK: - Internal Property
    // 发布模型
    var contributeModel: TSNewsContributeModel?

    // MARK: - Private Property

    private let sourceMaxLen: Int = 8       // 来源的最大长度
    private let authorMaxLen: Int = 8       // 作者的最大长度
    private let abstractMaxLen: Int = 200   // 摘要的最大长度

    fileprivate let normalViewH: Float = 55     // 每个选项正常的高度
    private let leftMargin: Float = 15
    private let leftWidth: Float = 70
    private let rightMargin: Float = 10
    private let arrowWidth: Float = 20      // 右侧箭头图标的宽度
    private let absctactFont: UIFont = UIFont.systemFont(ofSize: 15)    // 摘要输入框字体
    private let abstractTBmargin: Float = 10    // 摘要输入框的上下间距
    private let abstractMaxH: Float = 200       // 摘要输入框的最大高度
    private var abstractMinH: Float             // 摘要输入框最小高度
    {
        return self.normalViewH - self.abstractTBmargin * 2
    }

    private weak var nextBtn: UIButton!             // 导航栏右侧按钮
    fileprivate weak var categoryFiled: UITextField!    // 栏目输入框
    fileprivate weak var selectedTagView: TSNewsSelectedTagView!    // 标签选中视图(不含左侧标记、不含右侧箭头)

    private weak var sourceField: UITextField!      // 文章来源输入框
    private weak var authorField: UITextField!      // 作者输入框

    fileprivate weak var abstractInputView: TSOriginalCenterOneInputView!   // 摘要输入框
    fileprivate weak var abstractView: UIView!   // 摘要视图

    /// 当前选中的栏目数据
    fileprivate var selectedCategory: TSNewsCategoryModel?
    /// 当前选中的标签数据
    fileprivate var selectedTagList: [TSTagModel]?
    fileprivate let selectedTagMaxCount: Int = 5

    /// 当前键盘的高度
    fileprivate var currentKbH: CGFloat = 0

    // MARK: - Initialize Function
    // MARK: - Internal Function
    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 输入控件内容变更的通知处理
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledDidChanged(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChanged(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        // 键盘通知
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHideNotificationProcess(_:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbChangedNotificationProcess(_:)), name: Notification.Name.UIKeyboardDidChangeFrame, object: nil)
        IQKeyboardManager.sharedManager().enable = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        IQKeyboardManager.sharedManager().enable = false
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    // MARK: - Private  UI

    private func initialUI() -> Void {
//        self.view.backgroundColor = UIColor.white
        // 1. navigation bar
        self.navigationItem.title = "完善文章信息"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backItemClick))
//        let backItem = UIButton(type: .custom)
//        backItem.addTarget(self, action: #selector(backItemClick), for: .touchUpInside)
//        self.setupNavigationTitleItem(backItem, title: "显示_导航栏_返回".localized)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backItem)
        let nextItem = UIButton(type: .custom)
        nextItem.addTarget(self, action: #selector(nextItemClick), for: .touchUpInside)
        self.setupNavigationTitleItem(nextItem, title: "显示_下一步".localized)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextItem)
        nextItem.setTitleColor(UIColor.lightGray, for: .disabled)
        self.nextBtn = nextItem
        // 2. category 类别/栏目
        let categoryControl = UIControl()
        categoryControl.backgroundColor = UIColor.white
        self.view.addSubview(categoryControl)
        self.initialCategorView(categoryControl)
        categoryControl.addTarget(self, action: #selector(categoryControlClick(_:)), for: .touchUpInside)
        categoryControl.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.view)
            make.height.equalTo(normalViewH)
        }
        // 3. tag 标签
        let tagControl = UIControl()
        tagControl.backgroundColor = UIColor.white
        self.view.addSubview(tagControl)
        self.initialTagView(tagControl)
        tagControl.addTarget(self, action: #selector(tagControlClick(_:)), for: .touchUpInside)
        tagControl.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(categoryControl.snp.bottom)
            make.height.greaterThanOrEqualTo(normalViewH)
        }
        // 4. source 来源
        let sourceView = UIView()
        sourceView.backgroundColor = UIColor.white
        self.view.addSubview(sourceView)
        self.initialSoureView(sourceView)
        sourceView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(normalViewH)
            make.top.equalTo(tagControl.snp.bottom)
        }
        // 5. Author 作者
        let authorView = UIView()
        authorView.backgroundColor = UIColor.white
        self.view.addSubview(authorView)
        self.initialAuthorView(authorView)
        authorView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(normalViewH)
            make.top.equalTo(sourceView.snp.bottom)
        }
        // 6. Abstract 摘要
        let abstractView = UIView()
        abstractView.backgroundColor = UIColor.white
        self.view.addSubview(abstractView)
        self.initialAbstractView(abstractView)
        abstractView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(authorView.snp.bottom)
            make.height.equalTo(normalViewH)
        }
        self.abstractView = abstractView
    }
    /// 左侧标签栏通用布局
    private func genericInitialLeftTitleIn(view: UIView, leftWidth: Float, leftMargin: Float, text: String) -> Void {
        let titleLabel = UILabel(text: text, font: UIFont.systemFont(ofSize: 15), textColor: UIColor(hex: 0x333333))
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(view)
            make.leading.equalTo(view).offset(leftMargin)
            make.width.equalTo(leftWidth)
        }
    }
    /// categoryControl 布局
    private func initialCategorView(_ categoryView: UIView) -> Void {
        // 1. 左侧标签栏
        let text = "显示_选择栏目".localized
        self.genericInitialLeftTitleIn(view: categoryView, leftWidth: leftWidth, leftMargin: leftMargin, text: text)
        // 2. 右侧输入框
        let textField = UITextField()
        categoryView.addSubview(textField)
        let rightView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        rightView.image = UIImage(named: "IMG_ic_arrow_smallgrey")
        rightView.contentMode = .right
        textField.rightView = rightView
        textField.rightViewMode = .always
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.textColor = UIColor(hex: 0x333333)
        textField.textAlignment = .right
        textField.isUserInteractionEnabled = false
        textField.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(categoryView)
            make.trailing.equalTo(categoryView).offset(-rightMargin)
            make.leading.equalTo(categoryView).offset(leftMargin + leftWidth)
        }
        textField.placeholder = "占位符_请选择栏目".localized
        self.categoryFiled = textField
        // 3.separeLine
        categoryView.addLineWithSide(.inBottom, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: 0, margin2: 0)
    }
    /// tagView 布局
    private func initialTagView(_ tagView: UIView) -> Void {
        // 1. 左侧标签栏
        let text = "显示_选择标签".localized
        self.genericInitialLeftTitleIn(view: tagView, leftWidth: leftWidth, leftMargin: leftMargin, text: text)
        // 2. 右侧标签选择
        // 2.1 arrowView
        let arrowView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        tagView.addSubview(arrowView)
        arrowView.image = UIImage(named: "IMG_ic_arrow_smallgrey")
        arrowView.contentMode = .right
        arrowView.snp.makeConstraints { (make) in
            make.centerY.equalTo(tagView)
            make.width.equalTo(arrowWidth)
            make.trailing.equalTo(tagView).offset(-rightMargin)
        }
        // 2.2 tagView
        let tagW: Float = Float(ScreenSize.ScreenWidth) - self.leftMargin - self.leftWidth - self.rightMargin - self.arrowWidth
        let selectedTagView = TSNewsSelectedTagView(width: tagW, minHeight: self.normalViewH)
        tagView.addSubview(selectedTagView)
        selectedTagView.placeHolder = "占位符_请选择标签".localized
        selectedTagView.isUserInteractionEnabled = false
        selectedTagView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(tagView)
            make.leading.equalTo(tagView).offset(leftMargin + leftWidth)
            make.trailing.equalTo(arrowView.snp.leading)
        }
        self.selectedTagView = selectedTagView
        // 3.separeLine
        tagView.addLineWithSide(.inBottom, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: 0, margin2: 0)
    }
    /// sourveView 布局
    private func initialSoureView(_ sourceView: UIView) -> Void {
        /// 1. 左侧标签栏
        let text = "显示_文章来源".localized
        self.genericInitialLeftTitleIn(view: sourceView, leftWidth: leftWidth, leftMargin: leftMargin, text: text)
        /// 2. 右侧文章来源输入框
        let textField = UITextField()
        sourceView.addSubview(textField)
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.textColor = UIColor(hex: 0x333333)
        textField.textAlignment = .right
        textField.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(sourceView)
            make.trailing.equalTo(sourceView).offset(-rightMargin)
            make.leading.equalTo(sourceView).offset(leftMargin + leftWidth)
        }
        textField.placeholder = "占位符_请输入文章来源".localized
        self.sourceField = textField
        // 3.separeLine
        sourceView.addLineWithSide(.inBottom, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: 0, margin2: 0)
    }
    /// authorView 布局
    private func initialAuthorView(_ authoView: UIView) -> Void {
        /// 1. 左侧标签栏
        let text = "显示_作者".localized
        self.genericInitialLeftTitleIn(view: authoView, leftWidth: leftWidth, leftMargin: leftMargin, text: text)
        /// 2. 右侧作者输入框
        let textField = UITextField()
        authoView.addSubview(textField)
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.textColor = UIColor(hex: 0x333333)
        textField.textAlignment = .right
        textField.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(authoView)
            make.trailing.equalTo(authoView).offset(-rightMargin)
            make.leading.equalTo(authoView).offset(leftMargin + leftWidth)
        }
        textField.placeholder = "占位符_请输入作者名字".localized
        self.authorField = textField
        // 3.separeLine
        authoView.addLineWithSide(.inBottom, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: 0, margin2: 0)
    }
    /// abstractView 布局
    private func initialAbstractView(_ abstractView: UIView) -> Void {
        let topMargin: Float = 20
        let font = UIFont.systemFont(ofSize: 15)
        // 1. 左侧标签栏
        let titleLabel = UILabel(text: "", font: font, textColor: UIColor(hex: 0x333333))
        abstractView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(abstractView).offset(leftMargin)
            make.width.equalTo(leftWidth)
            make.top.equalTo(abstractView).offset(topMargin)
        }
        // 2. 右侧文章摘要视图
        let abstractInputView = TSOriginalCenterOneInputView(viewWidth: ScreenWidth - CGFloat(self.leftMargin) - CGFloat(self.leftWidth), font: font, maxLine: 5, showTextMinCount: 25, maxTextCount: self.abstractMaxLen, lrMargin: CGFloat(self.rightMargin), tbMargin: (CGFloat(self.normalViewH) - font.lineHeight) / 2.0 )
        abstractView.addSubview(abstractInputView)
        abstractInputView.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalTo(abstractView)
            make.leading.equalTo(abstractView).offset(leftMargin + leftWidth)
        }
        abstractInputView.showTextMinCount = 150
        abstractInputView.placeHolderLabel.textAlignment = .right
        abstractInputView.delegate = self
        self.abstractInputView = abstractInputView
        // 3. Localized
        titleLabel.text = "显示_摘要".localized
        abstractInputView.placeHolder = "占位符_请输入文章摘要".localized
    }

    // MARK: - Private  数据处理与加载

    private func initialDataSource() -> Void {
        // 数据加载
        if nil != self.contributeModel {
            self.setupWithContributeModel(self.contributeModel!)
        }
        // next标记的默认处理
        self.couldNextProcess()
    }

    // 数据加载
    private func setupWithContributeModel(_ model: TSNewsContributeModel) -> Void {
        // 原创，则不展示
        if model.author != TSCurrentUserInfo.share.userInfo?.name {
            self.authorField.text = model.author
        }
        // 原创，则不展示
        if model.source != "原创" {
            self.sourceField.text = model.source
        }

//        // 摘要部分， 注：摘要应考虑根据内容更新控件高度，待完成
//        self.abstractPlaceLabel.isHidden = (nil != model.abstract && !model.abstract!.isEmpty)
//        self.abstractTextView.text = model.abstract
        self.abstractInputView.text = model.abstract
        // 选择栏目
        self.selectedCategory = model.selectedCategory
        self.categoryFiled.text = model.selectedCategory?.name
        // 选择标签
        if let selectedTagList = model.selectedTagList {
            self.selectedTagList = selectedTagList
            self.selectedTagView.selectedTagList = selectedTagList
        }
    }

    /// 下一步是否可用判断
    private func couldNext() -> Bool {
        // 注：文章来源、作者、摘要可以为空
        var nextFlag: Bool = true
        if nil == self.selectedCategory {   // 没有选择栏目
            nextFlag = false
        } else if nil == self.selectedTagList || self.selectedTagList!.isEmpty { // 没有选择标签
            nextFlag = false
        }
        return nextFlag
    }
    /// 下一步判断处理
    fileprivate func couldNextProcess() -> Void {
        self.nextBtn.isEnabled = self.couldNext()
    }

    // MARK: - Private  事件响应

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /// 导航栏 取消按钮 点击响应
    @objc private func backItemClick() -> Void {
        // 数据保存
        self.contributeModel?.author = self.authorField.text
        self.contributeModel?.source = self.sourceField.text
        self.contributeModel?.abstract = self.abstractInputView.text
        self.contributeModel?.selectedCategory = self.selectedCategory
        self.contributeModel?.selectedTagList = self.selectedTagList
        self.view.endEditing(true)  // 键盘关闭
        _ = self.navigationController?.popViewController(animated: true)
    }
    /// 导航栏右侧按钮点击响应
    @objc private func nextItemClick() -> Void {
        self.view.endEditing(true)
        // 数据保存
        self.contributeModel?.author = self.authorField.text
        self.contributeModel?.source = self.sourceField.text
        self.contributeModel?.abstract = self.abstractInputView.text
        self.contributeModel?.selectedCategory = self.selectedCategory
        self.contributeModel?.selectedTagList = self.selectedTagList
        // 上传封面界面
        let contributeVC = TSNewsContributeController()
        contributeVC.contributeModel = self.contributeModel
        self.navigationController?.pushViewController(contributeVC, animated: true)
    }

    /// 栏目选择点击响应
    @objc private func categoryControlClick(_ control: UIControl) -> Void {
        self.view.endEditing(true)
        // 进入栏目选择界面
        let categorySelectVC = TSNewsCategorySelectController()
        categorySelectVC.selectedId = self.selectedCategory?.id
        categorySelectVC.delegate = self
        self.navigationController?.pushViewController(categorySelectVC, animated: true)
    }
    /// 标签选择点击响应
    @objc private func tagControlClick(_ control: UIControl) -> Void {
        self.view.endEditing(true)
        // 进入标签选择界面
        let tagSelectVC = TSNewsTagSelectController(type: .newsContribute, defaultTagList: self.selectedTagList)
        tagSelectVC.delegate = self
        self.navigationController?.pushViewController(tagSelectVC, animated: true)
    }

    // MARK: - Delegate Function

    // MARK: - Notification

    // MARK: - 输入框通知

    /// UITextField输入的通知处理
    @objc private func textFiledDidChanged(_ notification: Notification) {
        // 非titleField判断
        guard let textField = notification.object as? UITextField else {
            return
        }
        // 输入框输入文字上限
        var maxLen: Int = Int(MAX_INPUT)
        switch textField {
        case self.sourceField:
            maxLen = self.sourceMaxLen
        case self.authorField:
            maxLen = self.authorMaxLen
        default:
            return
        }
        if textField.text == nil || textField.text == "" {
        } else {
            // 长度限定
            TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: maxLen)
        }
        // 下一步按钮的可用性判断
        self.couldNextProcess()
    }

}

// MARK: - Notification

extension TSNewsPerfectController {
    // 键盘通知
    @objc fileprivate func kbWillShowNotificationProcess(_ notification: Notification) -> Void {
        guard let userInfo = notification.userInfo, let kbFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        self.currentKbH = kbFrame.size.height
//        let bottomH: CGFloat = ScreenHeight - abstractInputView.currentMinH - CGFloat(self.normalViewH) * 4.0 - 64.0
//        if bottomH < self.currentKbH {
//            UIView.animate(withDuration: 0.25, animations: {
//                let moveH: CGFloat = -abs(bottomH - self.currentKbH)
//                self.view.transform = CGAffineTransform(translationX: 0, y: moveH)
//            })
//        }
    }
    @objc fileprivate func kbWillHideNotificationProcess(_ notification: Notification) -> Void {

    }
    @objc fileprivate func kbChangedNotificationProcess(_ notification: Notification) -> Void {
        guard let userInfo = notification.userInfo, let kbFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        self.currentKbH = kbFrame.size.height
    }

    // 高度复位
    fileprivate func highReset() -> Void {
        UIView.animate(withDuration: 0.25) {
            self.view.transform = CGAffineTransform.identity
        }
    }

}

// MARK: - TSOriginalCenterOneInputViewProtocol

extension TSNewsPerfectController: TSOriginalCenterOneInputViewProtocol {
    func inputView(_ inputView: TSOriginalCenterOneInputView, didLoadedWith minHeight: CGFloat) {

    }
    func inputView(_ inputView: TSOriginalCenterOneInputView, didHeightChanged newHeight: CGFloat) {
        let height: CGFloat = max(newHeight, CGFloat(self.normalViewH))
        self.abstractView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        self.view.layoutIfNeeded()
        // 输入框移动判断处理
        let bottomH: CGFloat = ScreenHeight - height - CGFloat(self.normalViewH) * 4.0 - 64.0
        if bottomH < self.currentKbH {
            UIView.animate(withDuration: 0.25, animations: {
                let moveH: CGFloat = -abs(bottomH - self.currentKbH)
                self.view.transform = CGAffineTransform(translationX: 0, y: moveH)
            })
        }
    }
    func inputView(_ inputView: TSOriginalCenterOneInputView, didTextValueChanged newText: String) {
        self.couldNextProcess()
    }
    /// 开始编辑回调 - 成为第一响应者时
    func beiginEditing(in inputView: TSOriginalCenterOneInputView) -> Void {
        // 输入框与键盘判断处理
        let bottomH: CGFloat = ScreenHeight - inputView.currentMinH - CGFloat(self.normalViewH) * 4.0 - 64.0
        if bottomH < self.currentKbH {
            UIView.animate(withDuration: 0.25, animations: {
                let moveH: CGFloat = -abs(bottomH - self.currentKbH)
                self.view.transform = CGAffineTransform(translationX: 0, y: moveH)
            })
        }
    }
    /// 结束编辑 - 失去第一响应者时
    func endEditing(in inputView: TSOriginalCenterOneInputView) -> Void {
        self.highReset()
    }
}

// MARK: - TSNewsCategorySelectControllerProtocol

extension TSNewsPerfectController: TSNewsCategorySelectControllerProtocol {
    func didSelectCategory(_ category: TSNewsCategoryModel) {
        self.selectedCategory = category
        self.categoryFiled.text = category.name
        self.couldNextProcess()
    }
}

// MARK: - TSNewsTagSelectControllerProtocol

extension TSNewsPerfectController: TSNewsTagSelectControllerProtocol {
    func didClickBackItem(selectedTagList: [TSTagModel]?) {
        self.selectedTagList = selectedTagList
        self.selectedTagView.selectedTagList = selectedTagList
        self.couldNextProcess()
    }
}
