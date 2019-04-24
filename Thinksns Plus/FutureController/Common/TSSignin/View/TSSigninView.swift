//
//  TSSigninView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 09/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  签到视图

import Foundation
import UIKit

/// 签到视图协议
protocol TSSigninViewProtocol: class {
    /// 退出按钮点击回调
    func didClickExitBtnInSigninView(_ signinView: TSSigninView) -> Void
    /// 签到按钮点击回调
    func signinView(_ signinView: TSSigninView, didClickSigninBtn signinBtn: UIButton) -> Void
    /// 签到用户列表中用户头像点击
    func signinView(_ signinView: TSSigninView, didClickSigninedUser userId: Int) -> Void
}

class TSSigninView: UIView {

    // MARK: - Internal Property
    /// 回调
    weak var delegate: TSSigninViewProtocol?
    var exitBtnClickAction: ((_ signinView: TSSigninView) -> Void)?
    var signinBtnClickAction: ((_ signinView: TSSigninView, _ signinBtn: UIButton) -> Void)?

    // MARK: - Private Property
    /// 签到天数统计
    private weak var signinDayBtn: TSButton!
    /// 签到总金额
    private weak var signinMoneyLabel: TSLabel!
    /// 签到奖励金额提示
    private weak var signinPromptMoneyLabel: TSLabel!
    /// 签到按钮
    private weak var signinBtn: TSButton!
    /// 签到前几名用户头像视图
    private weak var signinUserIconView: UIView!
    private let userIconWH: Float = 20
    /// 签到按钮的渐变色背景，已签到的时候不显示
    private weak var signinBtnGradientLayer: CAGradientLayer?
    var isRefresh: Bool = true

    /// 已签到用户列表
    fileprivate var signinedUsers: [TSUserInfoModel] = []

    // MARK: - Internal Function

    /// 签到按钮不可用状态设置
    func disableSigninBtn() -> Void {
        self.signinBtnGradientLayer?.removeFromSuperlayer()
        self.signinBtn.isEnabled = false
    }

    // MARK: - Initialize Function
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // 0. self
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        // 1. topView
        let topView = UIView()
        self.addSubview(topView)
        self.initialTopView(topView)
        topView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self)
            make.height.equalTo(100)
        }
        // 2. bottomView
        let bottomView = UIView()
        self.addSubview(bottomView)
        self.initialBotomView(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(topView.snp.bottom)
        }
    }
    // topView布局
    private func initialTopView(_ topView: UIView) -> Void {
        // 0. 渐变色背景 添加渐变色视图
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: 0, width: 250, height: 100)
        layer.colors = [UIColor(hex: 0xefb946).cgColor, UIColor(hex: 0xef8a46).cgColor]
        // 起点和终点表示的坐标系位置，(0,0)表示左上角，(1,1)表示右下角
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        topView.layer.insertSublayer(layer, at: 0)
        // 1. 签到提示Label
        let promptLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 22), textColor: UIColor.white, alignment: .center)
        topView.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(topView)
            make.top.equalTo(topView).offset(22)
        }
        // 2. 累计签到 - 注：这里使用嵌套方式可以很好的兼容文字过长，若需响应将外层改成UIControl即可
        let signinDayBtn = TSButton(cornerRadius: 22 * 0.5)
        topView.addSubview(signinDayBtn)
        signinDayBtn.isUserInteractionEnabled = false
        signinDayBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        signinDayBtn.setTitleColor(UIColor(hex: 0xd46c28), for: .normal)
        signinDayBtn.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        signinDayBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(topView)
            make.top.equalTo(promptLabel.snp.bottom).offset(10)
            make.height.equalTo(22)
            make.width.equalTo(120)
        }
        self.signinDayBtn = signinDayBtn
        // 3. 退出按钮
        let exitBtn = UIButton(type: .custom)
        topView.addSubview(exitBtn)
        exitBtn.layer.masksToBounds = true
        exitBtn.contentMode = .scaleAspectFill
        exitBtn.setImage(UIImage(named: "IMG_ico_signin_close"), for: .normal)
        exitBtn.addTarget(self, action: #selector(didExitBtnClick(_:)), for: .touchUpInside)
        exitBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(18)
            make.trailing.equalTo(topView).offset(-10)
            make.top.equalTo(topView).offset(10)
        }
        // 4. Localize
        promptLabel.text = "每日签到"
    }
    // bottomView 布局
    private func initialBotomView(_ bottomView: UIView) -> Void {
        // 0. background
        bottomView.backgroundColor = UIColor.white
        // 1. 签到累计金币Label
        let signinMoneyLabel = TSLabel(text: "", font: UIFont.systemFont(ofSize: 30), textColor: UIColor(hex: 0xff9400), alignment: .center)
        bottomView.addSubview(signinMoneyLabel)
        signinMoneyLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(bottomView)
            make.top.equalTo(bottomView).offset(25)
        }
        self.signinMoneyLabel = signinMoneyLabel
        // 2. 签到获得金币提示Label
        let signinMoneyPromptLabel = TSLabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: UIColor(hex: 0x999999), alignment: .center)
        bottomView.addSubview(signinMoneyPromptLabel)
        signinMoneyPromptLabel.snp.makeConstraints { (make) in
            make.top.equalTo(signinMoneyLabel.snp.bottom).offset(10)
            make.centerX.equalTo(bottomView)
        }
        self.signinPromptMoneyLabel = signinMoneyPromptLabel
        // 3.1 签到Btn
        let signinBtn = TSButton(cornerRadius: 3)
        bottomView.addSubview(signinBtn)
        signinBtn.addTarget(self, action: #selector(didSigninBtnClick(_:)), for: .touchUpInside)
        signinBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        signinBtn.setTitleColor(UIColor.white, for: .normal)
        signinBtn.setBackgroundImage(UIImage.colorImage(color: UIColor(hex: 0xcccccc)), for: .disabled)
        // 签到按钮额渐变色背景
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: 0, width: 200, height: 35)
        layer.colors = [UIColor(hex: 0xefaa46).cgColor, UIColor(hex: 0xef8a46).cgColor]
        // 起点和终点表示的坐标系位置，(0,0)表示左上角，(1,1)表示右下角
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        signinBtn.layer.insertSublayer(layer, at: 0)
        self.signinBtnGradientLayer = layer
        signinBtn.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(35)
            make.centerX.equalTo(bottomView)
            make.top.equalTo(signinMoneyPromptLabel.snp.bottom).offset(25)
        }
        self.signinBtn = signinBtn
        // 4. 签到前5名头像视图
        let signinUserIconView = UIView()
        bottomView.addSubview(signinUserIconView)
        signinUserIconView.snp.makeConstraints { (make) in
            make.top.equalTo(signinBtn.snp.bottom).offset(15)
            make.trailing.leading.equalTo(bottomView)
        }
        self.signinUserIconView = signinUserIconView
        // 6. Localize
        signinMoneyPromptLabel.text = "每日签到得" + TSAppConfig.share.localInfo.goldName
        signinBtn.setTitle("签到", for: .normal)
        signinBtn.setTitle("已签到", for: .disabled)
    }

    // MARK: - Private  数据加载
    /// 获取数据（外部），更改UI
    ///
    /// - Parameter data: 用户签到数据
    public func getData(data: TSCheckinModel) -> Void {
        /// 总天数
        let dayCount = data.checkinCount
        /// 是否已经签过
        let isCheckin = data.checkedIn
        /// 签到排行榜
        let arry = data.rankUsers
        /// 服务器配置的签到奖励（增加的积分）
        let reward = "\(data.attachBalance)"

        self.signinMoneyLabel.text = "+" + reward
        self.signinDayBtn.setTitle("累计签到"+"\(dayCount)"+"天", for: .normal)
        self.setupSigninUserIcons(arry!)
        self.signinedUsers = arry!
        guard !isCheckin else {
            self.disableSigninBtn()
            return
        }
    }

    // 加载签到前几名的用户头像
    private func setupSigninUserIcons(_ users: Array<TSUserInfoModel>) -> Void {
        self.signinUserIconView.removeAllSubViews()
        if users.isEmpty {
            return
        }
        guard let rankView = self.signinUserIconView else {
            return
        }
        // 最多加载5个用户，注意排列方式
        let max = 5
        isRefresh = (users.count > max) ? false : true
        let width: Float = self.userIconWH
        let hormargin: Float = 10
        // 排列
        let count = users.count >= max ? max : users.count
        for (index, _) in users.enumerated() {
            if index >= max {
                break
            }
            let itemView = self.createIconItemView(index: index, user: users[index])
            rankView.addSubview(itemView)
            itemView.snp.makeConstraints({ (make) in
                make.top.equalTo(rankView)
                let centerXoffset = ( -(Float(count - 1) * 0.5) + Float(index) ) * (width + hormargin)
                make.centerX.equalTo(rankView).offset(centerXoffset)
                make.bottom.equalTo(rankView)
            })
            //itemView.backgroundColor = UIColor.green
        }
        //rankView.backgroundColor = UIColor.lightGray
    }
    // 构建头像视图
    private func createIconItemView(index: Int, user: TSUserInfoModel) -> UIView {
        let itemView = UIView()
        // 1. iconView
        let iconView = AvatarView(type: AvatarType.width20(showBorderLine: false))
        let avatarInfo = AvatarInfo(userModel: user)
        avatarInfo.type = AvatarInfo.UserAvatarType.normal(userId: nil)
        iconView.avatarInfo = avatarInfo
        iconView.buttonForAvatar.tag = 250 + index
        iconView.buttonForAvatar.addTarget(self, action: #selector(signUserBtnClick(_:)), for: .touchUpInside)
        itemView.addSubview(iconView)
        //iconView.backgroundColor = UIColor.red
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(self.userIconWH)
            make.top.leading.trailing.equalTo(itemView)
        }
        // 2. label
        let indexLabel = UILabel(text: "\(index + 1)", font: UIFont.systemFont(ofSize: 10), textColor: UIColor(hex: 0x999999), alignment: .center)
        itemView.addSubview(indexLabel)
        indexLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(itemView)
            make.top.equalTo(iconView.snp.bottom).offset(5)
            make.bottom.equalTo(itemView)
        }
        return itemView
    }

    // MARK: - Private  事件响应

    /// 退出按钮点击响应
    @objc private func didExitBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickExitBtnInSigninView(self)
        self.exitBtnClickAction?(self)
    }
    /// 签到按钮点击响应
    @objc private func didSigninBtnClick(_ button: UIButton) -> Void {
        TSCheckinNetworkManager().putCheckin { (msg, status) in
            guard status else {
                TSLogCenter.log.verbose(msg)
                 return
            }
            TSCheckinNetworkManager().getCheckinInformation(compelet: { (model, status) in
                guard status, let model = model, let modelRank = model.rankUsers else {
                    return
                }
                // 头像列表刷新
                if self.isRefresh {
                    self.setupSigninUserIcons(modelRank)
                }
                self.signinedUsers = modelRank
                // 签到累计天数修正
                self.getData(data: model)
            })
            // 签到状态修正
            self.disableSigninBtn()
            // 回调
            self.delegate?.signinView(self, didClickSigninBtn: button)
            self.signinBtnClickAction?(self, button)
        }
    }

    func signUserBtnClick(_ button: UIButton) -> Void {
        let index = button.tag - 250
        let user = self.signinedUsers[index]
        self.delegate?.signinView(self, didClickSigninedUser: user.userIdentity)
    }

}
