//
//  TSSectionForCAPATCHA.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  发送验证码UI,类似于下面,左边文字，中间用户输入，右边发送按钮和动画，下边底线。
//  外部还需要实现代理和配置对验证码是否可以点击的判断。比如：TSBindingPhoneOrEmailView：93-98行
//  看做 Tabelview Cell For Section
//  -------------------------------------------
//  |                                         |
//  | label     textfeild      btnAndAnimate  |
//  |_________________________________________|
//  |                                         |
//  -------------------------------------------

import UIKit

protocol TSSectionForCapatchaDelegate: NSObjectProtocol {
    /// 显示验证码网络请求返回信息
    ///
    func showCapatchaMsg(msg: String)
}

class TSSectionForCAPATCHA: UIView {
    /// label显示的字符串
    var labelText = ""
    /// 用户提示占位符的字符串
    var userInputPlaceholder = ""
    /// 底线是否显示
    var lineIsHidden = false
    /// 左边的label
    let leftLabel: TSAccountLabel = TSAccountLabel()
    /// 用户输入
    let userInput: TSAccountTextField = TSAccountTextField()
    /// 底线
    let line: TSSeparatorView = TSSeparatorView()
    /// 倒计时
    let timeLabel: TSCutDownLabel = TSCutDownLabel()
    /// 验证码按钮
    let timeBtn: TSSendCAPTCHAButton = TSSendCAPTCHAButton(type: .system)
    /// 发送验证码按钮计时器
    var timer: Timer? = Timer()
    /// 当前倒计时
    var cutDownNumber = 0
    /// 总倒计时
    let cutDownNumberMax = 60
    /// 旋转的花
    let flowerImage: TSIndicatorFlowerView = TSIndicatorFlowerView()
    /// 代理
    weak var delegate: TSSectionForCapatchaDelegate?

    /// 注册or非注册
    var channel: TSAccountNetworkManager.CAPTCHAChannel = .phone
    /// 电话号码还是邮箱
    var type: TSAccountNetworkManager.CAPTCHAType = .register

    ///  页面构造方法
    ///
    /// - Parameters:
    ///   - frame: 该页面的大小
    ///   - labelText: 左边label显示什么字符串
    ///   - userInputPlaceholder: 用户输入提示
    ///   - lineIsHidden: 底线是否显示
    ///   - theType: 验证码网络请求判断之。验证码类型：注册or非注册
    ///   - theChannel: 验证码网络请求判断之。验证码渠道：电话号码、邮箱
    init(frame: CGRect, labelText: String!, userInputPlaceholder: String!, lineIsHidden: Bool?, theType: TSAccountNetworkManager.CAPTCHAType, theChannel: TSAccountNetworkManager.CAPTCHAChannel) {
        super.init(frame: frame)
        self.labelText = labelText
        self.userInputPlaceholder = userInputPlaceholder
        self.lineIsHidden = lineIsHidden ?? false
        self.channel = theChannel
        self.type = theType
        self.backgroundColor = TSColor.main.white
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.stopTimer()
    }

    func setUI() {
        leftLabel.text = labelText
        userInput.placeholder = userInputPlaceholder
        timeLabel.textAlignment = .right
        flowerImage.contentMode = .center
        timeBtn.setTitle("获取验证码", for: .normal)
        timeBtn.addTarget(self, action: #selector(CAPATCHAisSuccess), for: .touchUpInside)

        self.addSubview(leftLabel)
        self.addSubview(userInput)
        self.addSubview(timeLabel)
        self.addSubview(flowerImage)
        self.addSubview(timeBtn)
        self.addSubview(line)

        leftLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.bottom.equalTo(self).offset(-0.5)
            make.left.equalTo(self).offset(13.5)
            make.width.equalTo(TSBindingLeftLabel.Width.rawValue)
        }
        userInput.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(leftLabel)
            make.right.equalTo(timeLabel.snp.left).offset(-10)
            make.left.equalTo(leftLabel.snp.right).offset(15)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(leftLabel)
            make.right.equalTo(self).offset(-13.5)
            make.width.equalTo(78)
        }
        flowerImage.snp.makeConstraints { (make) in
            make.centerY.equalTo(timeLabel)
            make.right.equalTo(timeLabel)
            make.width.height.equalTo(30)

        }
        timeBtn.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(timeLabel)
        }
        line.snp.makeConstraints { (make) in
            make.top.equalTo(leftLabel.snp.bottom)
            make.left.right.bottom.equalTo(self)
        }
        line.isHidden = lineIsHidden
        timeBtn.isEnabled = false
    }

    /// 验证码旋转的花，动画
    ///
    /// - Parameter isHidden: 是否开启，附带验证码按钮是否消失buff
    func setFlowerHidden(isHidden: Bool) {
        if isHidden {
            self.timeBtn.isHidden = true
            self.flowerImage.starAnimationForFlowerGrey()
        } else {
            self.flowerImage.dismiss()
        }
    }

    /// 计时器启动
    /// - 附带倒计时label显示
    func timerFired() {
        self.timeLabel.isHidden = false
        self.cutDownNumber += 1
        self.timeLabel.text = "\(self.cutDownNumberMax - self.cutDownNumber)s"
        if self.cutDownNumber == self.cutDownNumberMax {
            self.stopTimer()
        }
    }

    /// 停止定时器
    /// - 附带倒计时label隐藏
    private func stopTimer() -> Void {
        self.timeLabel.isHidden = true
        self.timeBtn.isHidden = false
        self.timer?.invalidate()
        self.timer = nil
        self.cutDownNumber = 0
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(timerFired), object: nil)
    }

    /// 验证码按钮方法
    func CAPATCHAisSuccess() {
        let str = userInput.text
        setFlowerHidden(isHidden: true)
        TSAccountNetworkManager().sendCaptcha(channel: channel, type: type, account: str!) { (msg, status) in
            self.setFlowerHidden(isHidden: false)
            guard status else {
                self.timeBtn.isHidden = false
                self.delegate?.showCapatchaMsg(msg: msg ?? errorNetworkInfo)
                return
            }
            self.delegate?.showCapatchaMsg(msg: "验证码发送成功")
            // 开启倒计时
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.timerFired), object: nil)
            self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
            if let timer = self.timer {
                RunLoop.main.add(timer, forMode: .commonModes)
            }
        }
    }
}
