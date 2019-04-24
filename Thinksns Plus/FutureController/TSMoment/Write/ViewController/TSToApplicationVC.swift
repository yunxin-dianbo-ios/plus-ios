//
//  TSToApplicationVC.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/12.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 动态置顶、评论置顶UI

import UIKit

/// 置顶类型
enum TSTopType {
    /// 帖子置顶
    case post
    /// 动态置顶
    case moment
    /// 资讯置顶
    case news
    /// 问答置顶
    case QA
    /// 帖子评论置顶
    case postComment
    /// 动态评论置顶
    case feedComment
    /// 资讯评论置顶
    case newsComment
    // 注：评论又可分为动态评论、资讯评论、音乐评论、问答评论等，这里暂时不继续细分，之后根据情况需要，可考虑细分
}

/// 置顶控制器
class TSToApplicationVC: UIViewController, btnTapDelegate, userInputDelegate {
    // MARK: - 初始化这个页面必须要的值
    /// 置顶类型
    var type: TSTopType
    /// 选择的天数
    var dayArray: Array<String> = []
    // MARK: - 加载的视图
    var selectDayOrPriceView: TSToApplicationSelectDayOrPriceView!
    var customMoneyView: TSUserCustomizeTheAmountView!
    /// 提交按钮
    var submitButtion: TSButton = TSButton(type: .custom)
    // MARK: - 一些必须要的值
    /// 积分
    var userPoints: Int = 0

    /// 选择的天数or价格
    var userChooseDay: Int? = nil
    /// 用户输入的价格
    var userInputPrice: Int? = 0
    /// 置顶的总金额
    var sumPrice: Int? = 0
    /// 按钮点击事件
    var finishOpration: ((Int, Int) -> Void)?

    let tipuser = TSLabel()

    init(type: TSTopType, days: Array<String>) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
        self.dayArray = days
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        selectDayOrPriceView.buttonTaped(selectDayOrPriceView.btnFirst)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let goldName = TSAppConfig.share.localInfo.goldName
        TSCurrentUserInfo.share.getCurrentUserJifen { [weak self] (status, points, message) in
            guard let `self` = self else {
                return
            }
            if status == true, let points = points {
                self.userPoints = points
                self.setSbmitTitle()
                switch self.type {
                case .moment, .feedComment:
                    var request = TopNetworkRequest().feedPrice
                    request.urlPath = request.fullPathWith(replacers: [])
                    RequestNetworkData.share.text(request: request, complete: { [weak self] (result) in
                        guard let `self` = self else {
                            return
                        }
                        switch result {
                        case .error(_), .failure(_):
                            self.tipuser.text = "最近置顶平均" + "100" + TSAppConfig.share.localInfo.goldName + "/天，可用\(goldName)" + "\(points)"
                        case .success(let response):
                            if let model = response.model, self.type == .moment, model.feed > 2 {
                                self.tipuser.text = "最近置顶平均" + "\(model.feed)" + TSAppConfig.share.localInfo.goldName + "/天，可用\(goldName)" + "\(points)"
                                return
                            }
                            if let model = response.model, self.type == .feedComment, model.feedComment > 2 {
                                self.tipuser.text = "最近置顶平均" + "\(model.feedComment)" + TSAppConfig.share.localInfo.goldName + "/天，可用\(goldName)" + "\(points)"
                                return
                            }
                            self.tipuser.text = "最近置顶平均" + "100" + TSAppConfig.share.localInfo.goldName + "/天，可用\(goldName)" + "\(points)"
                        }
                    })
                case .news, .newsComment:
                    var request = TopNetworkRequest().newsPrice
                    request.urlPath = request.fullPathWith(replacers: [])
                    RequestNetworkData.share.text(request: request, complete: { [weak self] (result) in
                        guard let `self` = self else {
                            return
                        }
                        switch result {
                        case .error(_), .failure(_):
                            self.tipuser.text = "最近置顶平均" + "100" + TSAppConfig.share.localInfo.goldName + "/天，可用\(goldName)" + "\(points)"
                        case .success(let response):
                            if let model = response.model, self.type == .news, model.news > 2 {
                                self.tipuser.text = "最近置顶平均" + "\(model.news)" + TSAppConfig.share.localInfo.goldName + "/天，可用\(goldName)" + "\(points)"
                                return
                            }
                            if let model = response.model, self.type == .newsComment, model.newsComment > 2 {
                                self.tipuser.text = "最近置顶平均" + "\(model.newsComment)" + TSAppConfig.share.localInfo.goldName + "/天，可用\(goldName)" + "\(points)"
                                return
                            }
                            self.tipuser.text = "最近置顶平均" + "100" + TSAppConfig.share.localInfo.goldName + "/天，可用\(goldName)" + "\(points)"
                        }
                    })
                case .post, .postComment:
                    var request = TopNetworkRequest().groupPrice
                    request.urlPath = request.fullPathWith(replacers: [])
                    RequestNetworkData.share.text(request: request, complete: { [weak self] (result) in
                        guard let `self` = self else {
                            return
                        }
                        switch result {
                        case .error(_), .failure(_):
                            self.tipuser.text = "最近置顶平均" + "100" + TSAppConfig.share.localInfo.goldName + "/天，可用\(goldName)" + "\(points)"
                        case .success(let response):
                            if let model = response.model, self.type == .post, model.post > 2 {
                                self.tipuser.text = "最近置顶平均" + "\(model.post)" + TSAppConfig.share.localInfo.goldName + "/天，可用\(goldName)" + "\(points)"
                                return
                            }
                            if let model = response.model, self.type == .postComment, model.postComment > 2 {
                                self.tipuser.text = "最近置顶平均" + "\(model.postComment)" + TSAppConfig.share.localInfo.goldName + "/天，可用\(goldName)" + "\(points)"
                                return
                            }
                            self.tipuser.text = "最近置顶平均" + "100" + TSAppConfig.share.localInfo.goldName + "/天，可用\(goldName)" + "\(points)"
                        }
                    })
                default:
                    self.tipuser.text = "最近置顶平均" + "100" + TSAppConfig.share.localInfo.goldName + "/天，可用\(goldName)" + "\(points)"
                }
            } else {
                let finalAlert = TSIndicatorWindowTop(state: .faild, title: message)
                finalAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                })
            }
        }
    }

    // MARK: - UI
    func setUI() {
        self.view.backgroundColor = TSColor.inconspicuous.background
        self.title = "标题_申请置顶".localized
        setToApplicationDayAndPriceUI()
        setSubmitBnt(bntName: "标题_申请置顶".localized, distance: 58)
    }

    /// 加载动态置顶UI
    func setToApplicationDayAndPriceUI() {
        let btnName: Array<String> = ["显示_1天".localized, "显示_5天".localized, "显示_10d".localized]
        selectDayOrPriceView = TSToApplicationSelectDayOrPriceView(frame: CGRect.zero, tipsLabelStr: "显示_选择置顶天数".localized, btnName: btnName)
        selectDayOrPriceView.btnTapDelegate = self
        self.view.addSubview(selectDayOrPriceView)
        selectDayOrPriceView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.right.equalTo(self.view)
            make.height.equalTo(101.5)
        }

        customMoneyView = TSUserCustomizeTheAmountView(frame: CGRect.zero, moneyTitle: "显示_每天支付".localized, lumpSum: true)
        customMoneyView.userInputDelegate = self
        self.view.addSubview(customMoneyView)
        customMoneyView.snp.makeConstraints { (make) in
            make.top.equalTo(selectDayOrPriceView.snp.bottom).offset(10)
            make.left.right.equalTo(selectDayOrPriceView)
            make.height.equalTo(100)
        }

        tipuser.textColor = TSColor.normal.minor
        tipuser.adjustsFontSizeToFitWidth = true
        tipuser.font = UIFont.systemFont(ofSize: TSFont.ContentText.sectionTitle.rawValue)
        self.view.addSubview(tipuser)
        tipuser.snp.makeConstraints { (make) in
            make.top.equalTo(customMoneyView.snp.bottom).offset(15)
            make.left.equalTo(customMoneyView).offset(15)
            make.height.equalTo(13.5)
            make.right.equalTo(customMoneyView).offset(-65)
        }
    }

    func setSubmitBnt(bntName: String, distance: CGFloat) {
        submitButtion.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        submitButtion.setTitle(bntName, for: .normal)
        submitButtion.setTitleColor(UIColor.white, for: .normal)
        submitButtion.backgroundColor = TSColor.button.normal
        submitButtion.clipsToBounds = true
        submitButtion.layer.cornerRadius = 6
        submitButtion.addTarget(self, action: #selector(submitBtnAction), for: .touchUpInside)
        submitButtion.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.view.addSubview(submitButtion)

        submitButtion.snp.makeConstraints { (make) in
            make.top.equalTo(customMoneyView.snp.bottom).offset(distance)
            make.left.equalTo(customMoneyView).offset(15)
            make.height.equalTo(45)
            make.right.equalTo(customMoneyView).offset(-15)
        }
        submitButtion.isEnabled = false
    }

    func submitBtnAction() {
        // - 根据btnTitle调用不同的方法
        let submitTitle = (submitButtion.titleLabel?.text)!
        let goldName = TSAppConfig.share.localInfo.goldName
        let subtitle = String(format: "显示_积分不足,去充值".localized, goldName)
        if submitTitle == "标题_申请置顶".localized {
            if TSAppConfig.share.localInfo.shouldShowPayAlert {
                self.view.endEditing(true)
                /// 当前用户没有设置密码，需要先行设置
                if TSCurrentUserInfo.share.isInitPwd == false {
                    NotificationCenter.default.post(name: NSNotification.Name.Setting.setPassword, object: nil)
                    return
                }
                TSUtil.showPwdVC(complete: { (inputCode) in
                    self.finishOpration?(self.userChooseDay!, self.sumPrice!)
                })
            } else {
                finishOpration?(userChooseDay!, sumPrice!)
            }
        } else if submitTitle == subtitle {
            pushToRecharge()
        }
    }

    // 积分不足->跳转到积分首页(需求是积分首页，不是充值页面)
    func pushToRecharge() {
        // 充值积分
        let integrationHomeVC = IntegrationHomeController.vc()
        self.navigationController?.pushViewController(integrationHomeVC, animated: true)
    }

    /// 请求当前用户信息
    func requestCurrentUserInfo() -> Void {
    }

    /// 提交是否可以点击？并且返回一个bool
    func setSubmitEnabled(userChooseDay: Int?, userInputPrice: Int?) -> Bool {
        // 判断。选择天数和用户输入金额是否存在，存在时按钮开启
        if userChooseDay != nil && userInputPrice != nil {
            submitButtion.isEnabled = true
            submitButtion.backgroundColor = TSColor.button.normal
            return true
        } else {
            submitButtion.isEnabled = false
            submitButtion.backgroundColor = TSColor.button.disabled
            return false
        }
    }

    /// 比较用户余额和总金额，更改btnTitle
    func setSbmitTitle() {
        if self.userPoints >= sumPrice! {
            submitButtion.setTitle("标题_申请置顶".localized, for: .normal)
        } else {
            let goldName = TSAppConfig.share.localInfo.goldName
            let subtitle = String(format: "显示_积分不足,去充值".localized, goldName)
            submitButtion.setTitle(subtitle, for: .normal)
        }
    }
    func textResignFirstResponder() {
        customMoneyView.userInputMoney.resignFirstResponder()
    }
    /// 计算并且显示总金额
    func calculateTheTotalAmount() {
        // 1.setSubmitEnabled的返回值做判断
        // 2.为false。那么显示的总金额只是placeholder
        // 2.为true，计算显示总金额
        // 2.1调用比较余额和总金额的方法
        if setSubmitEnabled(userChooseDay: userChooseDay, userInputPrice: userInputPrice) {
            sumPrice = userChooseDay! * userInputPrice!
            customMoneyView.lumpSumLabel.text = String(format:"\(sumPrice!)")
            customMoneyView.lumpSumLabel.textColor = TSColor.normal.blackTitle
            setSbmitTitle()
        } else {
            customMoneyView.lumpSumLabel.text = "0"
            customMoneyView.lumpSumLabel.textColor = TSColor.normal.disabled
        }
    }

    // MARK: - 加载视图的代理
    func btnTap(returnedInt: Int?) {
        // 1.只要点击天数就取消键盘响应
        // 2.赋值
        // 3.计算总金额
            textResignFirstResponder()
        if returnedInt != nil {
            userChooseDay = returnedInt!
        } else {
            userChooseDay = nil
        }
        calculateTheTotalAmount()
    }

    func userInput(input: String?) {
        if input != nil {
            userInputPrice = Int(input!)
        } else {
            userInputPrice = nil
        }
        calculateTheTotalAmount()
    }

    // MARK: - Public
    func setFinish(operation: @escaping ((Int, Int) -> Void)) {
        finishOpration = operation
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
