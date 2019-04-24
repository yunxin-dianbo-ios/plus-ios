//
//  TSFeedBackViewController.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class TSFeedBackViewController: TSViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UINavigationBarDelegate, feedBackUserInputAvailabilityDelegate, TSCustomAcionSheetDelegate {
    // 屏幕宽度
    let width = UIScreen.main.bounds.width
    // 高度
    let height: CGFloat = 736
    // 内容string
    var content: String! = ""
    // 邮箱电话string
    var information: String! = ""
    /// 最大字数限定
    fileprivate let limit: Int = 200

    // 内容view
    let feedBackUserInputView = TSFeedBackUserInputTextView()
    // 邮箱电话textfield
    let feedinformation = UITextField()
    // 背景滚动
    let backgroundScrollView = UIScrollView()
    // 提交按钮
    let submitButton: TSButton = TSTextButton.initWith(putAreaType: .top)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "标题_意见反馈".localized
        self.setRightButton(title: "提交", img: nil)
        self.setRightButtonTextColor(color: TSColor.main.theme)
        self.rightButton?.frame = CGRect(x: 0, y: 0, width: TSViewRightCustomViewUX.MaxWidth, height: 44)
        self.rightButton?.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        self.rightButtonEnable(enable: false)
        self.setRightCustomViewWidth(Max: false)
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setRightButton(title: "提交", img: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChangeNotificationProcess(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    func setUI() {
        setButton()
        setbackgroundScrollView()
        setFeedBackUserInputView()
//          [长期注释] 注释理由：隐藏0.8.0版本 时间：2017年07月08日
//        setFeedBackUserInfo()
//        setQuestion()
    }

    func setbackgroundScrollView() {
        backgroundScrollView.frame = self.view.frame
        backgroundScrollView.backgroundColor = TSColor.inconspicuous.background
        backgroundScrollView.contentSize = CGSize(width: width, height: height)
        backgroundScrollView.alwaysBounceVertical = true
        backgroundScrollView.delegate = self
        self.view.addSubview(backgroundScrollView)
        let tap = UITapGestureRecognizer(target:self, action:#selector(textViewResignFirstResponder))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        backgroundScrollView.addGestureRecognizer(tap)
    }

    // MARK: - navigationItem
    func setButton() {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "IMG_topbar_back"), style: .plain, target: self, action: #selector(didpop))
        navigationItem.leftBarButtonItem = backButton
    }

    // MARK: - feedBackUserInputView
    func setFeedBackUserInputView() {
        backgroundScrollView.addSubview(feedBackUserInputView)
        feedBackUserInputView.feedBackUserInputAvailabilityDelegate = self
        feedBackUserInputView.snp.makeConstraints { (make) in
            make.top.equalTo(backgroundScrollView)
            make.left.right.equalTo(self.view)
            make.height.equalTo(209.5)
        }
    }
    // MARK: - user input phone or email
    func setFeedBackUserInfo() {
        let feedContentbackgroundView = UIView()
        feedContentbackgroundView.backgroundColor = TSColor.main.white
        backgroundScrollView.addSubview(feedContentbackgroundView)
        feedContentbackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(feedBackUserInputView.snp.bottom).offset(5)
            make.left.right.equalTo(feedBackUserInputView)
            make.height.equalTo(45)
        }
        feedinformation.placeholder = "请输入电话或邮箱，方便我们与你联系".localized
        feedinformation.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        feedinformation.addTarget(self, action: #selector(informationChange(_:)), for: .allEditingEvents)
        feedContentbackgroundView.addSubview(feedinformation)
        feedinformation.snp.makeConstraints { (make) in
            make.top.equalTo(feedContentbackgroundView).offset(15)
            make.left.equalTo(feedContentbackgroundView).offset(14)
            make.height.equalTo(15)
            make.right.equalTo(feedContentbackgroundView).offset(-14)
        }
    }
    // MARK: - table
    func  setQuestion() {
        let questionTable = TSFeedBackTableview()
        backgroundScrollView.addSubview(questionTable)
        questionTable.snp.makeConstraints { (make) in
            make.top.equalTo(feedBackUserInputView.snp.bottom).offset(45)
            make.left.right.equalTo(self.view)
            make.height.equalTo(171.5)
        }
    }
    // MARK: - Network request
    func theSubmit() {
        submitButton.isEnabled = false // 防止手速过快点多次
        let str = "\(TSCurrentUserInfo.share.userInfo!.userIdentity)" + "\(Int(Date().timeIntervalSince1970 * 1_000))"
        let systeMark = Int(str)!

        var request = UserNetworkRequest().ideaFeedback
        let param = ["content": content, "system_mark": systeMark] as [String : Any]
        request.parameter = param
        request.urlPath = request.fullPathWith(replacers: [])
        RequestNetworkData.share.text(request: request) { [unowned self] (networkResult) in
            let alert: TSIndicatorWindowTop
            let networkStatus: Bool
            switch networkResult {
            case .error(_):
                alert = TSIndicatorWindowTop(state: .faild, title: "显示_意见反馈发送失败".localized)
                networkStatus = false
            case .failure(let response):
                alert = TSIndicatorWindowTop(state: .faild, title: response.message ?? "显示_意见反馈发送失败".localized)
                networkStatus = false
            case .success(let response):
                alert = TSIndicatorWindowTop(state: .success, title: response.message ?? "显示_意见反馈发送成功".localized)
                networkStatus = true
            }

            alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            if networkStatus == true {
                _ = self.navigationController?.popViewController(animated: true)
            }
            self.submitButton.isEnabled = !networkStatus
        }
    }
    // MARK: - textfield void
    func informationChange(_ change: UITextField) {
        information = change.text
        settapsubmitButtonIsEnabled()
    }

    /// rightButton点击方法（提交意见反馈）
    override func rightButtonClicked() {
        textViewResignFirstResponder()
        // [长期注释] 注释理由是：隐藏0.8.0版本
//        let number = information
//        let phonebool = TSAccountRegex.isPhoneNnumberFormat(number)
//        let emailbool = TSAccountRegex.isEmailFormat(number)
//        if !phonebool && !emailbool {
//            let actionsheetView = TSCustomActionsheetView(titles: ["提示信息".localized, "格式输入错误，手机号码或邮箱仅支持字母或数字".localized])
//            actionsheetView.delegate = self
//            actionsheetView.notClickIndexs = [1]
//            actionsheetView.setColor(color: TSColor.normal.minor, index: 1)
//            actionsheetView.show()
//            return
//        }
        theSubmit()
    }
    func settapsubmitButtonIsEnabled() {
//         [长期注释] 注释理由是：隐藏0.8.0版本
//                if (!content.characters.isEmpty) && (!information.characters.isEmpty) && TSAccountRegex.isContentAllwhitespaces(content) && TSAccountRegex.isContentAllwhitespaces(information) {
//                    submitButton.isEnabled = true
//                } else {
//                    submitButton.isEnabled = false
//                }

        if !content.isEmpty && TSAccountRegex.isContentAllwhitespaces(content) {
            self.rightButtonEnable(enable: true)
        } else {
            self.rightButtonEnable(enable: false)
        }
    }

    func textViewResignFirstResponder() {
        feedBackUserInputView.feedcontent.resignFirstResponder()
        feedinformation.resignFirstResponder()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        textViewResignFirstResponder()
    }

    func didpop() {
        if !content.isEmpty || !information.isEmpty {
            textViewResignFirstResponder()
            let actionsheetView = TSCustomActionsheetView(titles: ["提示信息_你的内容还没发送,是否放弃?".localized, "选择_确定".localized])
            actionsheetView.delegate = self
            actionsheetView.tag = 2
            actionsheetView.setColor(color: TSColor.normal.minor, index: 1)
            actionsheetView.show()
        } else {
            let _ = self.navigationController?.popViewController(animated: true)
        }

    }

    func feedBackUserInputAvailability(inputStr: String) {
        content = inputStr
        settapsubmitButtonIsEnabled()
    }
    // MARK: - TSCustomActionsheetView delegate
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if view.tag == 2 {
            let _ = self.navigationController?.popViewController(animated: true)
        }
        return
    }

    func ifViewHiden() {
        guard let count = navigationItem.rightBarButtonItems?.count else {
            return
        }
        if count > 1 {
            navigationItem.rightBarButtonItems?.remove(at: 0)
        }
    }
}

// MARK: - Notification

extension TSFeedBackViewController {
    /// UITextView输入的通知处理
    @objc fileprivate func textViewDidChangeNotificationProcess(notification: Notification) -> Void {
        // textView判断
        guard let textView = notification.object as? UITextView else {
            return
        }
        if textView != self.feedBackUserInputView.feedcontent {
            return
        }
        // 输入内容处理
        let maxLen = self.limit
        if textView.text == nil || textView.text.isEmpty {
        } else {
            TSAccountRegex.checkAndUplodTextFieldText(textField: textView, stringCountLimit: maxLen)
        }
    }
}
