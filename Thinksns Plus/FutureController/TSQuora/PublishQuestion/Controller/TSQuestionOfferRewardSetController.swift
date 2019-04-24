//
//  TSQuestionOfferRewardSetController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 04/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问答发布 - 悬赏设置界面
//  两种类型: 悬赏设置 + 公开悬赏设置
//  注1：公开悬赏设置是没有邀请相关的
//  注2：修改问题时，若没有悬赏，则可以设置悬赏，但不能设置邀请。即此时 类似于公开悬赏设置，悬赏数据开关无效。

import UIKit

/// 悬赏设置的类型
enum TSQuestionOfferRewardType {
    /// 正常状态下的设置——公开悬赏设置
    case normal
    /// 发布状态下的设置
    case publish
    /// 修改问题详情时设置——类似于公开悬赏设置，不可设置悬赏邀请，但标题又类似于发布设置，且可以不设置悬赏
    case update
}

class TSQuestionOfferRewardSetController: TSViewController {
    // MARK: - Internal Property
    /// 编辑类型
    var editType: TSQuoraEditType = .normalPublish
    /// 当前编辑模型
    var contributeModel: TSQuestionContributeModel?
    /// 悬赏设置的类型
    var rewardType: TSQuestionOfferRewardType = .normal
    /// type == .normal状态下需要传入的问题id
    var questionId: Int?
    // MARK: - Internal Function
    // MARK: - Private Property

    /// 重置按钮
    fileprivate var resetBtn: UIButton!
    /// 确定按钮
    fileprivate var doneBtn: UIButton!

    fileprivate let leftMargin: CGFloat = 15
    fileprivate let rightMargin: CGFloat = 15

    /// 价格选择列表
//    fileprivate let priceSelectList: [Float] = [1.0, 5.0, 10.0]
    /// 价格选择视图
    fileprivate weak var choosePriceView: TSToApplicationSelectDayOrPriceView!
    /// 自定义金额输入视图
    fileprivate weak var customMoneyView: TSUserCustomizeTheAmountView!

    /// 用户设置的悬赏金额(按钮选择/控件输入)
    fileprivate var offerRewardPrice: Int?

    /// 邀请开关
    fileprivate weak var invitationSwitch: UISwitch!
    /// 围观开关
    fileprivate weak var outlookSwitch: UISwitch!
    /// 邀请专家名字Label
    fileprivate weak var expertNameLabel: UILabel!
    /// 邀请的附加视图 - 根据邀请开关的状态会隐藏和高度修正
    fileprivate weak var invitationExtraView: UIView!

    // MARK: - Initialize Function

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }

}

// MARK: - UI

extension TSQuestionOfferRewardSetController {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        let offerTopMargin: CGFloat = 10
        // 0. self
        self.view.backgroundColor = TSColor.inconspicuous.background
        // 1. navigationbar
        var title: String
        var doneBtnTitle: String
        switch self.rewardType {
        case .normal:
            title = "标题_公开悬赏".localized
            doneBtnTitle = "显示_确定".localized
        case .update:
            fallthrough
        case .publish:
            title = "标题_悬赏(可跳过)".localized
            doneBtnTitle = "显示_发布".localized
        }
        self.navigationItem.title = title
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backItemClick))
        let resetItem = UIButton(type: .custom)
        resetItem.addTarget(self, action: #selector(resetItemClick), for: .touchUpInside)
        self.setupNavigationTitleItem(resetItem, title: "显示_重置".localized)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: resetItem)
        resetItem.setTitleColor(UIColor.lightGray, for: .disabled)
        self.resetBtn = resetItem
        // 2. 悬赏金额
        let priceView = UIView()
        self.view.addSubview(priceView)
        self.initialOfferRewardPriceView(priceView)
        priceView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.view)
        }
        // 3. 悬赏邀请
        let invitationView = UIView()
        self.view.addSubview(invitationView)
        self.initialOfferRewardInvitationView(invitationView)
        invitationView.isHidden = self.rewardType != .publish
        invitationView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(priceView.snp.bottom).offset(10)
        }
        // 4. 悬赏规则
        let offerRuleBtn = UIButton(type: .custom)
        self.view.addSubview(offerRuleBtn)
        offerRuleBtn.contentHorizontalAlignment = .left
        offerRuleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        offerRuleBtn.addTarget(self, action: #selector(offerRuleBtnClick(_:)), for: .touchUpInside)
        offerRuleBtn.setImage(UIImage(named: "IMG_ico_quora_hint"), for: .normal)
        offerRuleBtn.setTitle("显示_悬赏规则".localized, for: .normal)
        offerRuleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        offerRuleBtn.setTitleColor(TSColor.normal.minor, for: .normal)
        offerRuleBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(self.view).offset(leftMargin)
            switch self.rewardType {
            case .update:
                fallthrough
            case .normal:
                make.top.equalTo(priceView.snp.bottom).offset(offerTopMargin)
            case .publish:
                make.top.equalTo(invitationView.snp.bottom).offset(offerTopMargin)
            }
        }
        // 5. 确定按钮
        let doneBtn = UIButton(type: .custom)
        self.view.addSubview(doneBtn)
        doneBtn.addTarget(self, action: #selector(doneBtnClick(_:)), for: .touchUpInside)
        doneBtn.clipsToBounds = true
        doneBtn.layer.cornerRadius = 5
        doneBtn.setBackgroundImage(UIImage.imageWithColor(TSColor.main.theme, cornerRadius: 1), for: .normal)
        doneBtn.setBackgroundImage(UIImage.imageWithColor(TSColor.normal.disabled, cornerRadius: 1), for: .disabled)
        doneBtn.setTitleColor(UIColor.white, for: .normal)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneBtn.setTitle(doneBtnTitle, for: .normal)
        doneBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(self.view).offset(leftMargin)
            make.trailing.equalTo(self.view).offset(-rightMargin)
            make.height.equalTo(45)
            make.top.equalTo(offerRuleBtn.snp.bottom).offset(33)
        }
        self.doneBtn = doneBtn
    }

    // 悬赏金额视图
    fileprivate func initialOfferRewardPriceView(_ priceView: UIView) -> Void {
        // 1. 金额选择视图
        var btnName = [String]()
        for amount in [100, 500, 1_000] {
            btnName.append("\(amount)")
        }
        let choosePriceView = TSToApplicationSelectDayOrPriceView(frame: CGRect.zero, tipsLabelStr: "显示_设置悬赏金额".localized, btnName: btnName)
        choosePriceView.btnTapDelegate = self
        self.view.addSubview(choosePriceView)
        choosePriceView.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: leftMargin, margin2: rightMargin)
        choosePriceView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(priceView)
            make.height.equalTo(101.5)
        }
        self.choosePriceView = choosePriceView
        // 2. 自定义金额视图
        let customMoneyView = TSUserCustomizeTheAmountView(frame: CGRect.zero, moneyTitle: "显示_自定义金额".localized, lumpSum: false)
        customMoneyView.userInputDelegate = self
        self.view.addSubview(customMoneyView)
        customMoneyView.snp.makeConstraints { (make) in
            make.top.equalTo(choosePriceView.snp.bottom)
            make.leading.trailing.equalTo(priceView)
            make.height.equalTo(50)
            make.bottom.equalTo(priceView)
        }
        self.customMoneyView = customMoneyView
    }

    /// 悬赏邀请视图
    fileprivate func initialOfferRewardInvitationView(_ invitationView: UIView) -> Void {
        invitationView.backgroundColor = UIColor.white
        // TODO: - 这种类似Cell的应提取出来
        let normalH: CGFloat = 50
        // 1. 邀请开关
        let invitationSwithView = UIView()
        invitationView.addSubview(invitationSwithView)
        invitationSwithView.snp.makeConstraints { (make) in
            make.height.equalTo(normalH)
            make.leading.trailing.equalTo(invitationView)
            make.top.equalTo(invitationView)
        }
        // 1.1 invitationSwitchLabel
        let invitationSwitchLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15), textColor: TSColor.main.content)
        invitationSwithView.addSubview(invitationSwitchLabel)
        invitationSwitchLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(invitationSwithView)
            make.leading.equalTo(invitationSwithView).offset(leftMargin)
        }
        // 1.2 invitationSwitch
        let invitationSwitch = UISwitch()
        invitationSwithView.addSubview(invitationSwitch)
        invitationSwitch.addTarget(self, action: #selector(invitationSwitchValueChanged(_:)), for: .valueChanged)
        invitationSwitch.isOn = true
        invitationSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(invitationSwithView)
            make.trailing.equalTo(invitationSwithView).offset(-rightMargin)
        }
        self.invitationSwitch = invitationSwitch
        // 2. 邀请的附加视图
        let invitationExtraView = UIView()
        invitationView.addSubview(invitationExtraView)
        invitationExtraView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(invitationView)
            make.top.equalTo(invitationSwithView.snp.bottom)
            make.height.equalTo(100)
        }
        self.invitationExtraView = invitationExtraView
        // 2.1 邀请专家
        let invitationExpertControl = UIControl()
        invitationExtraView.addSubview(invitationExpertControl)
        invitationExpertControl.addLineWithSide(.inTop, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
        invitationExpertControl.addTarget(self, action: #selector(invitationExpertControlClick(_:)), for: .touchUpInside)
        invitationExpertControl.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(invitationExtraView)
            make.height.equalTo(invitationExtraView).multipliedBy(0.5)
        }
        // 2.1.1 expertPromptLabel
        let expertPromptLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15), textColor: TSColor.main.content)
        invitationExpertControl.addSubview(expertPromptLabel)
        expertPromptLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(invitationExpertControl)
            make.leading.equalTo(invitationExpertControl).offset(leftMargin)
        }
        // 2.1.2 expertIcon
        let expertIcon = UIImageView(image: UIImage(named: "IMG_ic_arrow_smallgrey"))
        invitationExpertControl.addSubview(expertIcon)
        expertIcon.contentMode = .right
        expertIcon.snp.makeConstraints { (make) in
            make.trailing.equalTo(invitationExpertControl).offset(-rightMargin)
            make.centerY.equalTo(invitationExpertControl)
            make.width.height.equalTo(15)
        }
        // 2.2.3 expertNameLabel
        let expertNameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15), textColor: TSColor.normal.minor, alignment: .right)
        invitationExpertControl.addSubview(expertNameLabel)
        expertNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(invitationExpertControl)
            // 因为expertIcon的宽度设置过宽，这里要达到标记的效果
            make.trailing.equalTo(expertIcon.snp.leading).offset(-10)
        }
        self.expertNameLabel = expertNameLabel
        // 2.2 围观开关
        let invitationOutlookView = UIView()
        invitationExtraView.addSubview(invitationOutlookView)
        invitationOutlookView.addLineWithSide(.inTop, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
        invitationOutlookView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(invitationExtraView)
            make.height.equalTo(invitationExtraView).multipliedBy(0.5)
        }
        // 2.2.1 outlookSwitchLabel
        let outlookSwitchLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15), textColor: TSColor.main.content)
        invitationOutlookView.addSubview(outlookSwitchLabel)
        outlookSwitchLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(invitationOutlookView)
            make.leading.equalTo(invitationOutlookView).offset(leftMargin)
        }
        // 2.2.2 outlookSwitch
        let outlookSwitch = UISwitch()
        invitationOutlookView.addSubview(outlookSwitch)
        outlookSwitch.addTarget(self, action: #selector(outlookSwtichValueChanged(_:)), for: .valueChanged)
        outlookSwitch.isOn = true
        outlookSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(invitationOutlookView)
            make.trailing.equalTo(invitationOutlookView).offset(-rightMargin)
        }
        self.outlookSwitch = outlookSwitch
        // 3. Localized
        invitationSwitchLabel.text = "显示_悬赏邀请".localized
        expertPromptLabel.text = "显示_邀请".localized
        outlookSwitchLabel.text = "显示_围观".localized
    }

}

// MARK: - 数据处理与加载

extension TSQuestionOfferRewardSetController {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        // 有 contributeModel 说明是问答发布
        guard let contributeModel = self.contributeModel else {
            self.doneBtnEnableProcess()
            return
        }
        if let price = contributeModel.offerRewardPrice {
            self.offerRewardPrice = price
            self.customMoneyView.userInputMoney.text = String(format: "%d", price)
        }
        self.invitationExtraView.isHidden = !contributeModel.isOpenOfferRewardInvitation
        self.invitationSwitch.isOn = contributeModel.isOpenOfferRewardInvitation
        self.expertNameLabel.text = contributeModel.invitationExpert?.name
        self.outlookSwitch.isOn = contributeModel.isOpenOutlook
        self.invitationExtraView.snp.updateConstraints({ (make) in
            let height = contributeModel.isOpenOfferRewardInvitation ? 100 : 0
            make.height.equalTo(height)
        })
        self.doneBtnEnableProcess()
    }
    /// doneBtn的可用性判断处理
    fileprivate func doneBtnEnableProcess() -> Void {
        self.doneBtn.isEnabled = self.couldDone()
    }
    /// doneBtn的可用性判断
    private func couldDone() -> Bool {
        var doneFlag: Bool = false
        // 判断当前页面的类型
        switch self.rewardType {
        case .normal:
            // 悬赏设置
            if nil != self.offerRewardPrice && self.offerRewardPrice! > 0 {
                doneFlag = true
            }
        case .update:
            // 问题修改，悬赏非必须
            doneFlag = true
        case .publish:
            // 发布 - 判断是否开启悬赏邀请
            guard let contributeModel = self.contributeModel else {
                return false
            }
            if contributeModel.isOpenOfferRewardInvitation {
                // 开启悬赏邀请，则必须设置 悬赏金额 + 悬赏邀请人
                if nil != self.offerRewardPrice && self.offerRewardPrice! > 0 && nil != contributeModel.invitationExpert {
                    doneFlag = true
                }
            } else {
                // 未开启悬赏邀请，可发布(无论是否输入悬赏金额)
                doneFlag = true
            }
        }
        return doneFlag
    }
}

// MARK: - 事件响应

extension TSQuestionOfferRewardSetController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /// 导航栏返回按钮点击响应
    @objc fileprivate func backItemClick() -> Void {
        self.view.endEditing(true)
        // 保存当前内容
        self.contributeModel?.offerRewardPrice = self.offerRewardPrice
        _ = self.navigationController?.popViewController(animated: true)
    }
    /// 导航栏重置按钮点击响应
    @objc fileprivate func resetItemClick() -> Void {
        self.view.endEditing(true)
        // 输入框重置 - 非发布状态
        self.customMoneyView.userInputMoney.text = nil
        self.choosePriceView.resetAll()
        self.offerRewardPrice = nil
        // 发布状态下的数据重置 并 重新加载数据
        self.contributeModel?.offerRewardPrice = nil
        self.contributeModel?.isOpenOfferRewardInvitation = false
        self.contributeModel?.isOpenOutlook = false
        self.contributeModel?.invitationExpert = nil
        self.initialDataSource()
    }
    /// 邀请开关值改变响应
    @objc fileprivate func invitationSwitchValueChanged(_ switchView: UISwitch) -> Void {
        self.view.endEditing(true)
        self.invitationExtraView.isHidden = !switchView.isOn
        self.contributeModel?.isOpenOfferRewardInvitation = switchView.isOn
        if switchView.isOn {
            self.invitationExtraView.snp.updateConstraints({ (make) in
                make.height.equalTo(100)
            })
        } else {
            self.invitationExtraView.snp.updateConstraints({ (make) in
                make.height.equalTo(0)
            })
            self.expertNameLabel.text = nil
            self.outlookSwitch.isOn = false
            self.contributeModel?.isOpenOutlook = false
            self.contributeModel?.invitationExpert = nil
        }
        self.doneBtnEnableProcess()
    }
    /// 围观开关值改变响应
    @objc fileprivate func outlookSwtichValueChanged(_ switchView: UISwitch) -> Void {
        self.view.endEditing(true)
        self.contributeModel?.isOpenOutlook = switchView.isOn
    }
    /// 邀请专家control点击响应
    @objc fileprivate func invitationExpertControlClick(_ control: UIControl) -> Void {
        self.view.endEditing(true)
        let expertSearchVC = TSQuestionInvitationSearchController()
        expertSearchVC.topics = self.contributeModel?.topics
        expertSearchVC.delegate = self
        self.navigationController?.pushViewController(expertSearchVC, animated: true)
    }
    /// 悬赏规则按钮点击响应
    @objc fileprivate func offerRuleBtnClick(_ button: UIButton) -> Void {
        self.view.endEditing(true)
        // 显示悬赏规则弹窗
        let popView = TSOfferRewardRulePopView()
        self.view.addSubview(popView)
        popView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    /// 确定按钮点击响应
    @objc fileprivate func doneBtnClick(_ button: UIButton) -> Void {
        self.view.endEditing(true)
        // 金额处理
        // 注：涉及支付时需先对余额拉取验证处理
        self.contributeModel?.offerRewardPrice = self.offerRewardPrice
        switch self.rewardType {
        case .normal:
            // 问题悬赏设置
            guard let questionId = self.questionId, let amount = self.offerRewardPrice else {
                return
            }
            self.doneBtn.isEnabled = false
            let setOfferRewardAction = {
                self.amountJudgeProcess(payPrice: amount, payAction: {
                let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_悬赏设置中".localized)
                loadingAlert.show()
                TSQuoraNetworkManager.setOfferRewardAmount(amount, forQuestion: questionId, complete: { [weak self](message, status) in
                    loadingAlert.dismiss()
                    self?.doneBtn.isEnabled = true
                    /// 支付需要密码弹窗
                    if TSAppConfig.share.localInfo.shouldShowPayAlert {
                        if status {
                            TSUtil.dismissPwdVC()
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                            return
                        }
                    }
                    if status {
                        let alert = TSIndicatorWindowTop(state: .success, title: "提示信息_悬赏设置成功".localized)
                        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloaddataquestiondetail"), object: nil)
                            _ = self?.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        let alert = TSIndicatorWindowTop(state: .faild, title: String(format: "%@: %@", "提示信息_悬赏设置失败".localized, message ?? ""))
                        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    }
                })
            })
            }
            if TSAppConfig.share.localInfo.shouldShowPayAlert {
                self.view.endEditing(true)
                /// 当前用户没有设置密码，需要先行设置
                if TSCurrentUserInfo.share.isInitPwd == false {
                    NotificationCenter.default.post(name: NSNotification.Name.Setting.setPassword, object: nil)
                    return
                }
                TSUtil.showPwdVC(complete: { (inputCode) in
                    setOfferRewardAction()
                })
            } else {
                setOfferRewardAction()
            }
        case .publish:
            // 发布
            guard let contributeModel = self.contributeModel else {
                return
            }
            self.doneBtn.isEnabled = false
            let publishAction: (() -> Void) = { () -> Void in
                let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_发布中".localized)
                loadingAlert.show()
                TSQuoraNetworkManager.publishQuora(contributeModel, complete: { [weak self](questionModel, message, status) in
                    loadingAlert.dismiss()
                    self?.doneBtn.isEnabled = true
                    /// 支付需要密码弹窗
                    if TSAppConfig.share.localInfo.shouldShowPayAlert {
                        if status {
                            TSUtil.dismissPwdVC()
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                            return
                        }
                    }
                    guard status, let questionModel = questionModel else {
                        let alert = TSIndicatorWindowTop(state: .faild, title: (message?.isEmpty)! ? message : "提示信息_发布失败".localized)
                        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                        return
                    }
                    // 发布成功，移除缓存图片
                    if let fileIds = contributeModel.content?.ts_getCustomMarkdownImageId() {
                        TSWebEditorImageManager.default.deleteImages(fileIds: fileIds)
                    }
                    // 提示，跳转到详情页，并对中间发布的页面删除
                    let alert = TSIndicatorWindowTop(state: .success, title: "提示信息_发布成功".localized)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                        self?.gotoQuestionDetail(questionId: questionModel.id)
                    })
                })
            }
            if let amount = self.offerRewardPrice {
                if TSAppConfig.share.localInfo.shouldShowPayAlert {
                    self.view.endEditing(true)
                    /// 当前用户没有设置密码，需要先行设置
                    if TSCurrentUserInfo.share.isInitPwd == false {
                        NotificationCenter.default.post(name: NSNotification.Name.Setting.setPassword, object: nil)
                        return
                    }
                    // 获取当前用户信息 - 提取当前余额，确认是否可以花费
                    TSUserNetworkingManager().getCurrentUserInfo { [weak self] (currentUser, msg, status) in
                        guard status, let currentUser = currentUser else {
                            TSUtil.showPwdVC(complete: { (inputCode) in
                                self?.amountJudgeProcess(payPrice: amount, payAction: publishAction)
                            })
                            return
                        }
                        let goldName = TSAppConfig.share.localInfo.goldName
                        // 判断余额 是否 足够支付
                        guard let integrationSum = currentUser.integration?.sum else {
                            TSUtil.showPwdVC(complete: { (inputCode) in
                                self?.amountJudgeProcess(payPrice: amount, payAction: publishAction)
                            })
                            return
                        }
                        if integrationSum < Int(amount) {
                            self?.doneBtn.isEnabled = true
                            // 余额不足，跳转进入钱包界面
                            let alert = TSIndicatorWindowTop(state: .faild, title: "\(goldName)余额不足，请充值")
                            alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                                self?.navigationController?.pushViewController(IntegrationHomeController.vc(), animated: true)
                            })
                        } else {
                            TSUtil.showPwdVC(complete: { (inputCode) in
                                self?.amountJudgeProcess(payPrice: amount, payAction: publishAction)
                            })
                        }
                    }
                } else {
                    self.amountJudgeProcess(payPrice: amount, payAction: publishAction)
                }
            } else {
                publishAction()
            }
        case .update:
            // 问题编辑，则修改问题
            guard let contributeModel = self.contributeModel, let questionId = self.contributeModel?.updatedQuestionId else {
                return
            }
            self.doneBtn.isEnabled = false
            let updateAction: (() -> Void) = { () -> Void in
                let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_更新中".localized)
                loadingAlert.show()
                TSQuoraNetworkManager.updateQuestion(questionId, isUpdateRewardPrice: true, newQuestion: contributeModel, complete: { [weak self](message, status) in
                    loadingAlert.dismiss()
                    self?.doneBtn.isEnabled = true
                    /// 支付需要密码弹窗
                    if TSAppConfig.share.localInfo.shouldShowPayAlert {
                        if status {
                            TSUtil.dismissPwdVC()
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                            return
                        }
                    }
                    if status {
                        // 修改成功，移除缓存图片
                        if let fileIds = contributeModel.content?.ts_getCustomMarkdownImageId() {
                            TSWebEditorImageManager.default.deleteImages(fileIds: fileIds)
                        }
                        let alert = TSIndicatorWindowTop(state: .success, title: "提示信息_更新成功".localized)
                        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                            self?.gotoQuestionDetail(questionId: questionId)
                        })
                    } else {
                        let alert = TSIndicatorWindowTop(state: .faild, title: String(format: "%@: %@", "提示信息_更新失败".localized, message ?? ""))
                        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    }
                })
            }
            if let amount = self.offerRewardPrice {
                if TSAppConfig.share.localInfo.shouldShowPayAlert {
                    self.view.endEditing(true)
                    TSUtil.showPwdVC(complete: { (inputCode) in
                        self.amountJudgeProcess(payPrice: amount, payAction: updateAction)
                    })
                } else {
                    self.amountJudgeProcess(payPrice: amount, payAction: updateAction)
                }
            } else {
                updateAction()
            }
        }
    }

}

// 扩展
extension TSQuestionOfferRewardSetController {
    /// 跳转进入问题详情页
    fileprivate func gotoQuestionDetail(questionId: Int) -> Void {
        if var childVCList = self.navigationController?.childViewControllers {
            // 发布过程中的页面删除
            for (index, childVC) in childVCList.enumerated() {
                if childVC is TSQuestionTitleEditController {
                    // 注，这种方案会导致questionDetailVC的左侧有返回字样，需要再questionDetailVC里自定义返回按钮
                    childVCList.replaceSubrange(Range<Int>(uncheckedBounds: (lower: index, upper: childVCList.count)), with: [])
                    break
                }
            }
            // 如果是从问题详情页进入的，则移除该问题详情页
            if childVCList.last is TSQuestionDetailController {
                childVCList.removeLast()
            }
            // 进入问题详情页
            let questionDetailVC = TSQuoraDetailController()
            questionDetailVC.questionId = questionId
            questionDetailVC.type = (self.editType == .addPublish) ? .addPublish : .normal
            childVCList.append(questionDetailVC)
            self.navigationController?.setViewControllers(childVCList, animated: true)
        }
    }
    /// 当前用户余额判断处理
    fileprivate func amountJudgeProcess(payPrice: Int, payAction: (() -> Void)?) -> Void {
        // 获取当前用户信息 - 提取当前余额，确认是否可以花费
        TSUserNetworkingManager().getCurrentUserInfo { [weak self] (currentUser, msg, status) in
            guard status, let currentUser = currentUser else {
                self?.doneBtn.isEnabled = true
                // 提示
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            let goldName = TSAppConfig.share.localInfo.goldName
            // 判断余额 是否 足够支付
            guard let integrationSum = currentUser.integration?.sum else {
                let alert = TSIndicatorWindowTop(state: .faild, title: "获取\(goldName)信息失败")
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            if integrationSum < Int(payPrice) {
                self?.doneBtn.isEnabled = true
                // 余额不足，跳转进入钱包界面
                let alert = TSIndicatorWindowTop(state: .faild, title: "\(goldName)余额不足，请充值")
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                self?.navigationController?.pushViewController(IntegrationHomeController.vc(), animated: true)
                })
            } else {
                payAction?()
            }
        }
    }
}

// MARK: - Notification

// MARK: - Delegate Function

// MARK: - TSQuestionInvitationSearchControllerProtocol

/// 专家搜索页的代理
extension TSQuestionOfferRewardSetController: TSQuestionInvitationSearchControllerProtocol {
    /// 专家选中回调
    func expertSearchVC(_ expertSearchVC: TSQuestionInvitationSearchController, didSelectedExpert expert: TSUserInfoModel) {
        self.expertNameLabel.text = expert.name
        self.contributeModel?.invitationExpert = expert
        self.doneBtnEnableProcess()
    }
}

// MARK: - btnTapDelegate

/// 价格选择的代理回调
extension TSQuestionOfferRewardSetController: btnTapDelegate {
    /// 返回点击的btn上数字文字
    func btnTap(returnedInt: Int?) {
        guard let returnedValue = returnedInt else {
            self.offerRewardPrice = nil
            self.doneBtnEnableProcess()
            return
        }
        // 注：键盘处理应放在guard之后，因为choosePriceView.resetAll()里会回调btnTap方法并返回nil
        self.view.endEditing(true)
        self.customMoneyView.userInputMoney.text = nil
        // 选择使用的tag tag和值的比例是1：100 故 x100
        self.offerRewardPrice = returnedValue * 100
        self.doneBtnEnableProcess()
    }
}

// MARK: - userInputDelegate

/// 自定义金额输入的回调
extension TSQuestionOfferRewardSetController: userInputDelegate {
    /// 返回用户输入字符串
    func userInput(input: String?) {
        guard let input = input else {
            self.choosePriceView.resetAll()
            self.offerRewardPrice = nil
            self.doneBtnEnableProcess()
            return
        }
        self.choosePriceView.resetAll()
        self.offerRewardPrice = Int(input)
        self.doneBtnEnableProcess()
    }
}
