//
//  ReportViewController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 14/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  举报界面(所有的举报都在这里)

import UIKit
import IQKeyboardManagerSwift

class ReportViewController: TSViewController {
    // MARK: - Internal Property

    let model: ReportTargetModel

    // MARK: - Internal Function
    // MARK: - Private Property

    fileprivate weak var topView: UIView!
    fileprivate weak var reportBtn: UIButton!

    fileprivate let lrMargin: CGFloat = 10
    fileprivate let inputMargin: CGFloat = 10

    fileprivate weak var reportPromptLabel: UILabel!
    fileprivate weak var reportedUserNameBtn: UIButton!
    fileprivate weak var reportedTargetPromptLabel: UILabel!

    fileprivate weak var reportTargetView: ReportTargetControl!

    fileprivate weak var reportTextView: UITextView!
    fileprivate weak var reportInputNumLabel: UILabel!
    fileprivate weak var inputPlaceHolder: UILabel!

    /// 输入最大字数限制
    fileprivate let inputMaxNum: Int = 255

    // MARK: - Initialize Function

    init(reportTarget: ReportTargetModel) {
//        if reportTarget.type == ReportTargetType.Comment(commentType: commentType, sourceId: _, groupId: groupId) {
//            if commentType == .post && groupId == nil {
//                fatalError("帖子的评论举报需要传入圈子id")
//            }
//        }
        self.model = reportTarget
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 输入控件内容变更的通知处理
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChangeNotificationProcess(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        IQKeyboardManager.sharedManager().enable = true
         IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 40.0
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        IQKeyboardManager.sharedManager().enable = false
    }

}

// MARK: - UI

extension ReportViewController {
    /// 页面布局
    fileprivate func initialUI() -> Void {

        let reportBtnH: CGFloat = 45
        let reportLrMargin: CGFloat = 15
        let reportTopMargin: CGFloat = 30

        // 1. navigationbar
        self.navigationItem.title = "标题_举报".localized
        // 2. topView
        let topView = UIView(bgColor: UIColor.white)
        self.view.addSubview(topView)
        self.initialTopView(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self.view)
        }
        self.topView = topView
        // 3. retportBtn
        let reportBtn = UIButton(cornerRadius: 5)
        self.view.addSubview(reportBtn)
        reportBtn.addTarget(self, action: #selector(reportBtnClick(_:)), for: .touchUpInside)
        reportBtn.setTitle("显示_举报".localized, for: .normal)
        reportBtn.setTitleColor(UIColor.white, for: .normal)
        reportBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        reportBtn.setBackgroundImage(UIImage(color: TSColor.main.theme), for: .normal)
        reportBtn.setBackgroundImage(UIImage(color: TSColor.button.disabled), for: .disabled)
        reportBtn.snp.makeConstraints { (make) in
            make.height.equalTo(reportBtnH)
            make.leading.equalTo(self.view).offset(reportLrMargin)
            make.trailing.equalTo(self.view).offset(-reportLrMargin)
            make.top.equalTo(topView.snp.bottom).offset(reportTopMargin)
        }
        self.reportBtn = reportBtn
    }
    /// topView布局
    fileprivate func initialTopView(_ topView: UIView) -> Void {
        let promptTopMargin: CGFloat = 25
        let targetTopMargin: CGFloat = 15
        let inputTopMargin: CGFloat = 15
        let inputBottomMargin: CGFloat = 20
        let reportTargetH: CGFloat = 50
        let reportInputH: CGFloat = 150
        // 1. reportPromtView
        let promptView = UIView()
        topView.addSubview(promptView)
        self.initialReportPromptView(promptView)
        promptView.snp.makeConstraints { (make) in
            make.leading.equalTo(topView).offset(self.lrMargin)
            make.trailing.equalTo(topView).offset(-self.lrMargin)
            make.top.equalTo(topView).offset(promptTopMargin)
        }
        // 2. reportTargetView
        let targetView = ReportTargetControl()
        topView.addSubview(targetView)
        targetView.backgroundColor = TSColor.inconspicuous.background
        //targetView.addTarget(self, action: #selector(reportedTargetClick), for: .touchUpInside)
        targetView.isEnabled = false
        targetView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(promptView)
            make.top.equalTo(promptView.snp.bottom).offset(targetTopMargin)
            make.height.equalTo(reportTargetH)
        }
        self.reportTargetView = targetView
        // 3. reportInputView
        let inputView = UIView(bgColor: TSColor.inconspicuous.background)
        topView.addSubview(inputView)
        self.initialReportInputView(inputView)
        inputView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(promptView)
            make.top.equalTo(targetView.snp.bottom).offset(inputTopMargin)
            make.bottom.equalTo(topView).offset(-inputBottomMargin)
            make.height.equalTo(reportInputH)
        }
    }
    /// 举报提示视图布局
    fileprivate func initialReportPromptView(_ promptView: UIView) -> Void {
        // 方案一：label + button + label
        // 方案二：yyLabel

        // 1. reportPromptLabel
        let reportPromptLabel = UILabel(text: "显示_举报".localized, font: UIFont.systemFont(ofSize: 15), textColor: TSColor.main.content)
        promptView.addSubview(reportPromptLabel)
        reportPromptLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(promptView)
            make.leading.equalTo(promptView)
        }
        self.reportPromptLabel = reportPromptLabel
        // 2. reportedUserNameBtn
        let userNameBtn = UIButton(type: .custom)
        promptView.addSubview(userNameBtn)
        userNameBtn.setTitleColor(TSColor.main.theme, for: .normal)
        userNameBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        userNameBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        userNameBtn.addTarget(self, action: #selector(reportedUserNameClick), for: .touchUpInside)
        userNameBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(promptView)
            make.leading.equalTo(reportPromptLabel.snp.trailing)
        }
        self.reportedUserNameBtn = userNameBtn
        // 3. reportTargetPromtLabel
        let targetPromptLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15), textColor: TSColor.main.content)
        promptView.addSubview(targetPromptLabel)
        targetPromptLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(promptView)
            make.leading.equalTo(userNameBtn.snp.trailing)
            //make.trailing.equalTo(promptView)
        }
        self.reportedTargetPromptLabel = targetPromptLabel
    }
    fileprivate func initialReportInputView(_ inputView: UIView) -> Void {
        // 1. 提取输入框控件
        // 2. 输入框控件的间距设置问题
        // 3. 多上输入框placeHolder设置的间距问题

        let inputLrMargin: CGFloat = inputMargin - 5

        // 1. textView
        let textView = UITextView()
        inputView.addSubview(textView)
        textView.contentInset = UIEdgeInsets.zero
        textView.textContainerInset = UIEdgeInsets.zero
      //  textView.delegate = self
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = TSColor.main.content
        textView.snp.makeConstraints { (make) in
            make.leading.equalTo(inputView).offset(inputLrMargin)
            make.top.equalTo(inputView).offset(inputMargin)
            make.trailing.equalTo(inputView).offset(-inputLrMargin)
        }
        self.reportTextView = textView
        // 2. placeHolder
        let placeHolder = UILabel(text: "占位符_填写举报原因".localized, font: UIFont.systemFont(ofSize: 15), textColor: TSColor.normal.secondary)
        textView.addSubview(placeHolder)
        placeHolder.snp.makeConstraints { (make) in
            make.leading.equalTo(textView).offset(inputMargin - inputLrMargin)
            make.top.equalTo(textView)
        }
        self.inputPlaceHolder = placeHolder
        // 3. inputNumLabel
        let inputNumLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 10), textColor: TSColor.normal.minor)
        inputView.addSubview(inputNumLabel)
        inputNumLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textView.snp.bottom).offset(inputMargin)
            make.bottom.equalTo(inputView).offset(-inputMargin)
            make.trailing.equalTo(inputView).offset(-inputMargin)
        }
        self.reportInputNumLabel = inputNumLabel
    }
//    func animateTextField(textField: UITextView, up: Bool) {
//        let movementDistance:CGFloat = -210
//        let movementDuration: Double = 0.3
//
//        var movement:CGFloat = 0
//        if up {
//            movement = movementDistance
//        }
//        else {
//            movement = -movementDistance
//        }
//
//        UIView.beginAnimations("animateTextField", context: nil)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        UIView.setAnimationDuration(movementDuration)
//
//        self.view.frame = self.view.bounds.insetBy(dx: 0, dy: movement)
//        UIView.commitAnimations()
//    }

}



// MARK: - 数据处理与加载

extension ReportViewController {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        // 根据举报类型分别加载
        var reportPromptTitle: String = "举报"
        var reportedUserName: String? = self.model.user?.name
        var reportedTargetPromptTitle: String = ""
        switch self.model.type {
        case .Comment(commentType: _):
            reportedTargetPromptTitle = "的评论"
        case .Post:
            reportedTargetPromptTitle = "的帖子"
        case .Moment:
            reportedTargetPromptTitle = "的动态"
        case .News:
            reportedTargetPromptTitle = "的文章"
        case .Group:
            if reportedUserName == nil {
              reportPromptTitle = "举报圈子:"
            } else {
                reportedTargetPromptTitle = "的圈子"
            }
        case .User:
            reportPromptTitle = "举报用户:"
            reportedUserName = nil
        case .Answer:
            reportedTargetPromptTitle = "的答案"
        case .Question:
            reportedTargetPromptTitle = "的问题"
        case .Topic:
            reportedTargetPromptTitle = "的话题"
        }
        self.reportPromptLabel.text = reportPromptTitle
        self.reportedUserNameBtn.setTitle(reportedUserName, for: .normal)
        self.reportedTargetPromptLabel.text = reportedTargetPromptTitle
        self.reportTargetView.model = self.model
        self.reportInputNumLabel.text = "0/\(self.inputMaxNum)"
        self.reportBtn.isEnabled = false
    }

    /// report按钮是否可用的判断与处理
    fileprivate func couldReportProcess() -> Void {
        self.reportBtn.isEnabled = self.couldReport()
    }
    /// report按钮是否可用/report操作是否可执行
    private func couldReport() -> Bool {
        var couldFlag: Bool = true
        // 输入内容判断
        guard let text = self.reportTextView.text else {
            return false
        }
        if text.isEmpty {
            couldFlag = false
        }
        return couldFlag
    }

    /// 举报
    fileprivate func report() -> Void {
        guard let content = self.reportTextView.text else {
            return
        }
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "请求中...")
        loadingAlert.show()
        TSReportNetworkManager.report(type: self.model.type, reportTargetId: self.model.targetId, reason: content) { (msg, status) in
            loadingAlert.dismiss()
            var tipMsg = msg ?? (status ? "显示_举报成功".localized : "显示_举报失败".localized)
            if tipMsg == "" {
                tipMsg = status ? "显示_举报成功".localized : "显示_举报失败".localized
            }
            let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: tipMsg )
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                if status {
                _ = self.navigationController?.popViewController(animated: true)
                }
            })
        }

    }
}

// MARK: - 事件响应

extension ReportViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /// 举报按钮点击响应
    @objc fileprivate func reportBtnClick(_ button: UIButton) -> Void {
        self.view.endEditing(true)
        self.report()
    }
    /// 被举报的用户姓名点击响应
    @objc fileprivate func reportedUserNameClick() -> Void {
        self.view.endEditing(true)
        // 注：userId==-1 表示问答中的匿名用户
        guard let userId = self.model.user?.userIdentity, userId != -1 else {
            return
        }
        let userHomeVC = TSHomepageVC(userId)
        self.navigationController?.pushViewController(userHomeVC, animated: true)
    }
    /// 被举报的对象点击响应
    @objc fileprivate func reportedTargetClick() -> Void {
        self.view.endEditing(true)
        let sourceId = self.model.targetId
        var detailVC = UIViewController()
        switch self.model.type {
        case .Comment(commentType: let commentType, sourceId: let sourceId, groupId: let groupId):
            switch commentType {
            case .momment:
                detailVC = TSCommetDetailTableView(feedId: sourceId)
            case .news:
                detailVC = TSNewsDetailViewController(newsId: sourceId)
            case .album:
                detailVC = TSMusicCommentVC(musicType: .album, sourceId: sourceId)
            case .song:
                detailVC = TSMusicCommentVC(musicType: .song, sourceId: sourceId)
            case .question:
                let questionDetailVC = TSQuoraDetailController()
                questionDetailVC.questionId = sourceId
                detailVC = questionDetailVC
            case .answer:
                detailVC = TSAnswerDetailController(answerId: sourceId)
            case .post:
                if let groupId = groupId {
                    detailVC = PostDetailController(groupId: groupId, postId: sourceId)
                }
            }
        case .Post(groupId: let groupId):
            detailVC = PostDetailController(groupId: groupId, postId: sourceId)
        case .Moment:
            detailVC = TSCommetDetailTableView(feedId: sourceId)
        case .News:
            detailVC = TSNewsDetailViewController(newsId: sourceId)
        case .Group:
            detailVC = GroupDetailVC(groupId: sourceId)
        case .User:
            detailVC = TSHomepageVC(sourceId)
        case .Answer:
            detailVC = TSAnswerDetailController(answerId: sourceId)
        case .Question:
            let questionDetailVC = TSQuoraDetailController()
            questionDetailVC.questionId = sourceId
            detailVC = questionDetailVC
        case .Topic:
            detailVC = TopicPostListVC(groupId: sourceId)
        }
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Notification

extension ReportViewController {
    /// UITextView输入的通知处理
    @objc fileprivate func textViewDidChangeNotificationProcess(notification: Notification) -> Void {
        // textView判断
        guard let textView = notification.object as? UITextView else {
            return
        }
        if textView != self.reportTextView {
            return
        }
        // 输入内容处理
        let maxLen = self.inputMaxNum
        if textView.text == nil || textView.text.isEmpty {
            self.inputPlaceHolder.isHidden = false
        } else {
            self.inputPlaceHolder.isHidden = true
            TSAccountRegex.checkAndUplodTextFieldText(textField: textView, stringCountLimit: maxLen)
            let currentNum = textView.text!.count
            self.reportInputNumLabel.text = "\(currentNum)/\(self.inputMaxNum)"
        }
        // 举报按钮的可用性判断
        self.couldReportProcess()
    }
}

//extension ReportViewController: UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        self.animateTextField(textField: textView, up: true)
//    }
//}

// MARK: - Delegate Function
