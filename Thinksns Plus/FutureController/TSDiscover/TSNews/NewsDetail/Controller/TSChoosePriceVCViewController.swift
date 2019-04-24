//
//  TSChoosePriceVCViewController.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  价格选择控制器
//  打赏操作时的价格选择界面
//  打赏界面。使用时需传入：打赏类型 + 打赏目标
//  注1：请求需优化
//  注3：关于回调，回调方案1：打赏成功是没有打赏模型的返回的，因此可自行构造回调，但回调id为0；
//               回调方案2：部分页面的打赏是单独的请求，直接在打赏成功后回调中重新请求即可。这也是dissMiss方法的来由。用于动态打赏更新
//              注：不是所有的打赏都需要回调——用户打赏。

import UIKit
import SnapKit

protocol TSChoosePriceVCDelegate: class {
    func disMiss()
    /// 打赏成功的回调
    func didRewardSuccess(_ rewardModel: TSNewsRewardModel) -> Void
}
extension TSChoosePriceVCDelegate {
    func disMiss() {
    }
    /// 打赏成功的回调
    func didRewardSuccess(_ rewardModel: TSNewsRewardModel) -> Void {
    }
}

/// 打赏类型
enum TSRewardType {
    /// 动态打赏
    case moment
    /// 资讯打赏
    case news
    /// 用户打赏
    case user
    /// 问答答案
    case answer
    /// 帖子
    case post
}

class TSChoosePriceVCViewController: TSViewController, btnTapDelegate, userInputDelegate {
    /// 打赏类型
    let type: TSRewardType
    /// 选择价格视图
    var choosePriceView: TSToApplicationSelectDayOrPriceView!
    /// 自定义金额视图
    var customMoneyView: TSUserCustomizeTheAmountView!
    /// 提交按钮
    var submitButtion: TSButton = TSButton(type: .custom)
    /// 用户选择打赏价格 单位是人民币分
    var inputPrice: Int? {
        didSet {
            var enableFlag: Bool = false
            if let inputPrice = inputPrice {
                if inputPrice > 0 {
                    enableFlag = true
                }
            }
            //self.rightButton?.isEnabled = enableFlag      // 注：应该使用下面方法，该方案无效
            self.rightButtonEnable(enable: enableFlag)
            self.submitButtion.isEnabled = enableFlag
            self.submitButtion.backgroundColor = enableFlag ? TSColor.button.normal : TSColor.button.disabled
        }
    }
    /// 打赏金额 单位人民币分
    var inputPrices: [Int] = [100, 500, 1_000]
    /// 打赏的目标Id
    var sourceId: Int?
    weak var delegate: TSChoosePriceVCDelegate?
    var rewardSuccessAction: ((_ rewadModel: TSNewsRewardModel) -> Void)?

    init(type: TSRewardType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setRightButton(title: "重置", img: nil)
        self.setRightButtonTextColor(color: TSColor.main.theme)
        self.rightButton?.frame = CGRect(x: 0, y: 0, width: TSViewRightCustomViewUX.MaxWidth, height: 44)
        self.rightButton?.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        self.setRightCustomViewWidth(Max: false)
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setRightButton(title: "重置", img: nil)
    }

    // MARK: set ui
    func setUI() {
        self.view.backgroundColor = TSColor.inconspicuous.background
        self.title = "打赏"

        if TSAppConfig.share.localInfo.rewardAmounts.isEmpty == false {
            inputPrices = TSAppConfig.share.localInfo.rewardAmounts
        }
        var btnName: Array<String> = []
        for amount in inputPrices {
            btnName.append("\(amount)")
        }

        choosePriceView = TSToApplicationSelectDayOrPriceView(frame: CGRect.zero, tipsLabelStr: "显示_选择打赏金额".localized, btnName: btnName)
        choosePriceView.btnTapDelegate = self
        self.view.addSubview(choosePriceView)
        choosePriceView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.right.equalTo(self.view)
            make.height.equalTo(101.5)
        }
        let goldName = TSAppConfig.share.localInfo.goldName
        customMoneyView = TSUserCustomizeTheAmountView(frame: CGRect.zero, moneyTitle: "显示_自定义金额".localized, lumpSum: false, moneyUnit: goldName)
        customMoneyView.userInputDelegate = self
        self.view.addSubview(customMoneyView)
        customMoneyView.snp.makeConstraints { (make) in
            make.top.equalTo(choosePriceView.snp.bottom).offset(10)
            make.left.right.equalTo(choosePriceView)
            make.height.equalTo(50)
        }
        setSubmitBnt(bntName: "显示_确定".localized, distance: 58)

        self.inputPrice = 0
    }

    func setSubmitBnt(bntName: String, distance: CGFloat) {
        submitButtion.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        submitButtion.setTitle(bntName, for: .normal)
        submitButtion.setTitleColor(UIColor.white, for: .normal)
        submitButtion.backgroundColor = TSColor.button.disabled
        submitButtion.clipsToBounds = true
        submitButtion.layer.cornerRadius = 6
        submitButtion.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        self.view.addSubview(submitButtion)

        submitButtion.snp.makeConstraints { (make) in
            make.top.equalTo(customMoneyView.snp.bottom).offset(distance)
            make.left.equalTo(customMoneyView).offset(15)
            make.height.equalTo(45)
            make.right.equalTo(customMoneyView).offset(-15)
        }
        submitButtion.isEnabled = false
    }

    // MARK: delegate
    func btnTap(returnedInt: Int?) {
        guard let returnedInt = returnedInt else {
            inputPrice = nil
            return
        }
        // 兼容旧的代码 returnedInt = 1 标示下标0； = 5 表示下标 1； = 10 标示下标2；
        var userInputMoney = 0
        switch returnedInt {
        case 1:
           userInputMoney = inputPrices[0]
        case 5:
            userInputMoney = inputPrices[1]
        case 10:
            userInputMoney = inputPrices[2]
        default:
            return
        }
        customMoneyView.userInputMoney.resignFirstResponder()
        customMoneyView.userInputMoney.text = ""
        inputPrice = userInputMoney
    }

    func userInput(input: String?) {
        guard let input = input, let number = Double(input) else {
            if !choosePriceView.hasItemChoosed {
                   inputPrice = nil
            }
            return
        }
        choosePriceView.resetAll()
//        inputPrice = TSWalletConfigModel.convertToFen(number)
        inputPrice = Int(number)
    }

    /// rightButton点击方法（重置页面）
    override func rightButtonClicked() {
        customMoneyView.userInputMoney.resignFirstResponder()
        customMoneyView.userInputMoney.text = nil
        choosePriceView.resetAll()  // 会在其代理里回调btnTap，所以无需再单独设置inputPrice
    }

    func submitAction() {
        guard let sourceId = sourceId, let realInputPrice = inputPrice else {
            return
        }
        let loadingShow = TSIndicatorWindowTop(state: .loading, title: "正在打赏")
        loadingShow.show()
        self.view.isUserInteractionEnabled = false

        TSCurrentUserInfo.share.getCurrentUserJifen { (status, jifen, message) in
            loadingShow.dismiss()
            self.view.isUserInteractionEnabled = true
            // 用户积分信息获取成功
            if status == true {
                var interaction: Int = 0
                if jifen != nil {
                    interaction = jifen!
                }
                if realInputPrice > interaction {
                    self.toRechargeVC()
                } else {
                    if TSAppConfig.share.localInfo.shouldShowPayAlert {
                        self.view.endEditing(true)
                        /// 当前用户没有设置密码，需要先行设置
                        if TSCurrentUserInfo.share.isInitPwd == false {
                            NotificationCenter.default.post(name: NSNotification.Name.Setting.setPassword, object: nil)
                            return
                        }
                        TSUtil.showPwdVC(complete: { (inputCode) in
                            self.requestReward(realInputPrice: realInputPrice, sourceId: sourceId, loadingShow: loadingShow)
                        })
                    } else {
                        self.requestReward(realInputPrice: realInputPrice, sourceId: sourceId, loadingShow: loadingShow)
                    }
            }
            } else {
                let topShow = TSIndicatorWindowTop(state: .faild, title: message)
                topShow.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }
    private func requestReward(realInputPrice: Int, sourceId: Int, loadingShow: TSIndicatorWindowTop) {
        let user = TSCurrentUserInfo.share.userInfo!.convert()
        let rewardModel = TSNewsRewardModel(userId: user.userIdentity, amount: realInputPrice, user: user)
        switch self.type {
        case .moment:
            // MARK: - TODO 打赏 和 打赏列表  应该使用打赏统一的请求
            TSMomentNetworkManager().reward(price: realInputPrice, momentId: sourceId, complete: { [weak self] (message, result) in
                loadingShow.dismiss()
                guard let `self` = self else {
                    return
                }
                /// 支付需要密码弹窗
                if TSAppConfig.share.localInfo.shouldShowPayAlert {
                    if result {
                        TSUtil.dismissPwdVC()
                    } else {
                        NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                        return
                    }
                }
                if result == true {
                    let topShow = TSIndicatorWindowTop(state: .success, title: "打赏成功")
                    topShow.show()
                    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                        DispatchQueue.main.async {
                            topShow.dismiss()
                            self.view.isUserInteractionEnabled = true
                            self.rewardSuccessAction?(rewardModel)
                            self.delegate?.didRewardSuccess(rewardModel)
                            self.delegate?.disMiss()
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    })
                    return
                }
                let topShow = TSIndicatorWindowTop(state: .faild, title: message)
                topShow.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            })
        case .news:
            TSNewsNetworkManager().reward(price: realInputPrice, newsId: sourceId) { [weak self] (message, result) in
                loadingShow.dismiss()
                guard let `self` = self else {
                    return
                }
                /// 支付需要密码弹窗
                if TSAppConfig.share.localInfo.shouldShowPayAlert {
                    if result {
                        TSUtil.dismissPwdVC()
                    } else {
                        NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                        return
                    }
                }
                if result == true {
                    let topShow = TSIndicatorWindowTop(state: .success, title: "打赏成功")
                    topShow.show()
                    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                        DispatchQueue.main.async {
                            topShow.dismiss()
                            self.view.isUserInteractionEnabled = true
                        }
                    })
                    self.delegate?.disMiss()
                    _ = self.navigationController?.popViewController(animated: true)
                    return
                }
                let topShow = TSIndicatorWindowTop(state: .faild, title: message)
                topShow.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        case .user:
            TSUserNetworkingManager().reward(userId: sourceId, amount: realInputPrice, complete: { [weak self](message, status) in
                loadingShow.dismiss()
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
                    let topShow = TSIndicatorWindowTop(state: .success, title: "打赏成功")
                    topShow.show()
                    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                        DispatchQueue.main.async {
                            topShow.dismiss()
                            self?.view.isUserInteractionEnabled = true
                            self?.delegate?.disMiss()
                            _ = self?.navigationController?.popViewController(animated: true)
                        }
                    })
                } else {
                    let topShow = TSIndicatorWindowTop(state: .faild, title: message)
                    topShow.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            })
        case .answer:
            TSQuoraNetworkManager.rewardAnswer(sourceId, amount: realInputPrice, complete: { [weak self] (message, status) in
                loadingShow.dismiss()
                /// 支付需要密码弹窗
                if TSAppConfig.share.localInfo.shouldShowPayAlert {
                    if status {
                        TSUtil.dismissPwdVC()
                    } else {
                        NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                        return
                    }
                }
                if status == true {
                    let topShow = TSIndicatorWindowTop(state: .success, title: "打赏成功")
                    topShow.show()
                    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                        DispatchQueue.main.async {
                            topShow.dismiss()
                            self?.view.isUserInteractionEnabled = true
                            self?.rewardSuccessAction?(rewardModel)
                            self?.delegate?.didRewardSuccess(rewardModel)
                            _ = self?.navigationController?.popViewController(animated: true)
                        }
                    })
                } else {
                    let topShow = TSIndicatorWindowTop(state: .faild, title: message)
                    topShow.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            })
        case .post:
            TSRewardNetworkManger.reward(type: .post, sourceId: sourceId, amount: realInputPrice, complete: { [weak self](message, status) in
                loadingShow.dismiss()
                /// 支付需要密码弹窗
                if TSAppConfig.share.localInfo.shouldShowPayAlert {
                    if status {
                        TSUtil.dismissPwdVC()
                    } else {
                        NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                        return
                    }
                }
                if status == true {
                    let topShow = TSIndicatorWindowTop(state: .success, title: "打赏成功")
                    topShow.show()
                    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                        DispatchQueue.main.async {
                            topShow.dismiss()
                            self?.view.isUserInteractionEnabled = true
                            self?.rewardSuccessAction?(rewardModel)
                            self?.delegate?.didRewardSuccess(rewardModel)
                            _ = self?.navigationController?.popViewController(animated: true)
                        }
                    })
                } else {
                    let topShow = TSIndicatorWindowTop(state: .faild, title: message)
                    topShow.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            })
        }
    }
    /// 跳转到钱包页面
    func toWalletVC(msg: String?) {
        guard msg == "余额不足" else {
            return
        }
        let wallet = WalletHomeController.vc()
        navigationController?.pushViewController(wallet, animated: true)
    }
    /// 跳转到积分首页
    func toRechargeVC() {
        let integrationHomeVC = IntegrationHomeController.vc()
        self.navigationController?.pushViewController(integrationHomeVC, animated: true)
    }
}
