//
//  TSTopicApplyController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 19/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  话题申请界面
//  用途：话题搜索时若搜索结果为空，可申请创建话题

import Foundation

class TSTopicApplyController: TSViewController {
    // MARK: - Internal Property
    // MARK: - Internal Function
    // MARK: - Private Property
    fileprivate weak var rightItem: UIButton!

    fileprivate weak var titleField: UITextField!
    fileprivate weak var contentView: UIView!
    fileprivate weak var contentTextView: UITextView!
    fileprivate weak var contentPlaceLabel: UILabel!

    fileprivate let leftMargin: CGFloat = 20
    fileprivate let rightMargin: CGFloat = 20
    fileprivate var contentTextW: CGFloat = ScreenWidth

    fileprivate let titleMaxLen: Int = 20
    fileprivate let contentMaxLen: Int = Int(MAX_INPUT)

    // MARK: - Initialize Function

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
        // 键盘的通知处理
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    deinit {
        // 通知移除
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 输入控件内容变更的通知处理
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChanged(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

}

// MARK: - UI

extension TSTopicApplyController {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        let lrMargin: CGFloat = self.leftMargin
        let titleH: CGFloat = 50
        let font: UIFont = UIFont.systemFont(ofSize: 15)
        let textColor = TSColor.main.content
        let placeColor = TSColor.normal.secondary
        // place表示textView中的占位，text表示textView
        let placeLeftMargin: CGFloat = self.leftMargin
        let textLeftMargin: CGFloat = lrMargin - 5
        let placeTopMargin: CGFloat = 15
        let textTopMargin: CGFloat = placeTopMargin - 7
        self.view.backgroundColor = TSColor.normal.background
        // 1. navigationbar
        self.navigationItem.title = "标题_建议创建话题".localized
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backItemClick))
        let rightItem = UIButton(type: .custom)
        rightItem.addTarget(self, action: #selector(rightItemClick), for: .touchUpInside)
        self.setupNavigationTitleItem(rightItem, title: "显示_提交".localized)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightItem)
        rightItem.setTitleColor(UIColor.lightGray, for: .disabled)
        self.rightItem = rightItem
        // 2. topicTitle
        let textField = UITextField()
        self.view.addSubview(textField)
        textField.font = font
        textField.textColor = textColor
        textField.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: lrMargin, margin2: lrMargin)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: lrMargin, height: lrMargin))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: lrMargin, height: lrMargin))
        textField.rightViewMode = .always
        textField.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.view)
            make.height.equalTo(titleH)
        }
        self.titleField = textField
        // 3. topicDesc
        // 3.1 contentView
        let contentView = UIView()
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self.view)
            make.top.equalTo(titleField.snp.bottom)
        }
        self.contentView = contentView
        // 3.2 contentTextView
        let textView = UITextView()
        contentView.addSubview(textView)
        textView.font = font
        textView.textColor = textColor
        textView.snp.makeConstraints { (make) in
            make.leading.equalTo(contentView).offset(textLeftMargin)
            make.trailing.equalTo(contentView).offset(-textLeftMargin)
            make.top.equalTo(contentView).offset(textTopMargin)
            make.bottom.equalTo(contentView).offset(-textTopMargin)
        }
        self.contentTextW = ScreenWidth - CGFloat(textLeftMargin * 2.0)
        self.contentTextView = textView
        // 3.3 contentPlaceLabel
        let placeLabel = UILabel(text: "", font: font, textColor: placeColor)
        contentView.addSubview(placeLabel)
        placeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(contentView).offset(placeLeftMargin)
            make.top.equalTo(contentView).offset(placeTopMargin)
        }
        self.contentPlaceLabel = placeLabel
        // 4. Localized
        textField.attributedPlaceholder = NSMutableAttributedString.attString(str: "占位符_请输入话题名称".localized, font: font, color: placeColor)
        placeLabel.text = "占位符_请输入话题相关描述信息".localized
    }

}

// MARK: - 数据处理与加载

extension TSTopicApplyController {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        self.couldNextProcess()
    }

    /// 按钮是否可用
    private func couldNext() -> Bool {
        var couldFlag: Bool = true
        guard let title = self.titleField.text, let content = self.contentTextView.text else {
            return false
        }
        // 1. 标题判断
        if title.isEmpty {
            couldFlag = false
        }
        // 2. 正文判断
        else if content.isEmpty {
            couldFlag = false
        }
        // 待完成：标题和正文是否有最小值
        return couldFlag
    }

    /// 按钮是否可用的判断与处理
    fileprivate func couldNextProcess() -> Void {
        self.rightItem.isEnabled = self.couldNext()
    }

    /// 判断是否显示输入框的提示语
    fileprivate func isHiddenPlaceHolder() -> Bool {
        let text = self.contentTextView.text
        var hiddenFlag: Bool = true
        if text == nil || text == "" {
            hiddenFlag = false
        }
        return hiddenFlag
    }
}

// MARK: - 事件响应

extension TSTopicApplyController {
    // MARK: - Private  事件响应

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)  // 键盘关闭
    }
    /// 导航栏 取消按钮 点击响应
    @objc fileprivate func backItemClick() -> Void {
        self.view.endEditing(true)  // 键盘关闭
        // 判断是直接返回 还是 弹窗确认是否编辑过
        let title = self.titleField.text
        let content = self.contentTextView.text
        var popFlag: Bool = false   // 是否弹窗标记
        // 先判断当前输入框内是否有值
        if (nil != title && !title!.isEmpty) || (content != nil && !content!.isEmpty) {
            popFlag = true
        }
        if popFlag {
            // 弹窗提示 是否放弃编辑
            let customAction = TSCustomActionsheetView(titles: ["选择_放弃编辑".localized])
            customAction.tag = 250
            customAction.delegate = self
            customAction.show()
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    /// 导航栏 提交按钮 点击响应
    @objc fileprivate func rightItemClick() -> Void {
        self.view.endEditing(true)  // 键盘关闭
        guard let title = self.titleField.text, let content = self.contentTextView.text else {
            return
        }
        // 输入内容判断处理，暂无
        // 网络请求
        self.rightItem.isEnabled = false
        TSQuoraNetworkManager.applyTopic(title: title, content: content) { [weak self](msg, status) in
            self?.rightItem.isEnabled = true
            if status {
                let alert = TSIndicatorWindowTop(state: .success, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                    _ = self?.navigationController?.popViewController(animated: true)
                })
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }
}

// MARK: - Notification

extension TSTopicApplyController {
    // MARK: - 输入框通知

    /// UITextField输入的通知处理
    @objc fileprivate func textFiledDidChanged(notification: Notification) {
        // 非titleField判断
        guard let textField = notification.object as? UITextField else {
            return
        }
        if textField != self.titleField {
            return
        }
        // 输入框输入文字上限
        let maxLen = self.titleMaxLen
        if textField.text == nil || textField.text == "" {
        } else {
            // 长度限定
            TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: maxLen)
        }
        // 下一步按钮的可用性判断
        self.couldNextProcess()
    }
    /// UITextView输入的通知处理
    @objc fileprivate func textViewDidChanged(notification: Notification) -> Void {
        // textView判断
        guard let textView = notification.object as? UITextView else {
            return
        }
        if textView != self.contentTextView {
            return
        }
        // 输入内容处理
        let maxLen = self.contentMaxLen
        let text = textView.text
        if text == nil || text == "" {
            self.contentPlaceLabel.isHidden = false
        } else {
            self.contentPlaceLabel.isHidden = true
            TSAccountRegex.checkAndUplodTextFieldText(textField: textView, stringCountLimit: maxLen)
        }
        // 下一步按钮的可用性判断
        self.couldNextProcess()
    }

    // MARK: - 键盘通知

    // 键盘弹出通知处理
    @objc fileprivate func keyboardWillShowNotificationProcess(_ notification: Notification) -> Void {
        guard let userInfo = notification.userInfo else {
            return
        }
        let kbBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let kbH: CGFloat = kbBounds.size.height + 10
        UIView.animate(withDuration: duration) {
            self.contentTextView.snp.updateConstraints({ (make) in
                make.bottom.equalTo(self.contentView).offset(-kbH)
            })
            self.contentTextView.layoutIfNeeded()
        }
    }
    // 键盘隐藏通知处理
    @objc fileprivate func keyboardWillHideNotificationProcess(_ notification: Notification) -> Void {
        guard let userInfo = notification.userInfo else {
            return
        }
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        UIView.animate(withDuration: duration) {
            self.contentTextView.snp.updateConstraints({ (make) in
                make.bottom.equalTo(self.contentView).offset(-10)
            })
            self.contentTextView.layoutIfNeeded()
        }
    }
}

// MARK: - Delegate Function

extension TSTopicApplyController: TSCustomAcionSheetDelegate {
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        switch index {
        case 0:
            _ = self.navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
}
