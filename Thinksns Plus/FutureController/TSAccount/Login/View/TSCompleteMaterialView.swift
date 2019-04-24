//
//  TSCompleteMaterialView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  完善资料

import UIKit

class TSCompleteMaterialView: UIView, UITextFieldDelegate {
    var checkNameView: TSSectionNormal!
    let image = UIImageView(image: #imageLiteral(resourceName: "confirmButton"))
    let msgLabel = TSAccountMessagelabel()
    let btnForLgoin = TSColorLumpButton(type: .custom)

    weak var superVC: ThreeUserFillInfoVC!

    init(frame: CGRect, superVC: ThreeUserFillInfoVC) {
        super.init(frame: frame)
        self.superVC = superVC
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() -> Void {
        let checkNameView = TSSectionNormal(frame: CGRect.zero, labelText: "用户名", userInputPlaceholder: "", lineIsHidden: true)
        self.checkNameView = checkNameView
        self.checkNameView.userInput.addTarget(self, action: #selector(check), for: .allEditingEvents)
        image.contentMode = .scaleAspectFit
        btnForLgoin.sizeType = .large
        btnForLgoin.setTitle("下一步", for: .normal)
        btnForLgoin.addTarget(self, action: #selector(submitRegister), for: .touchUpInside)
        // 注册协议(根据配置确定是否显示 - 默认隐藏)
        let agreementView = UIView()
        let agreementLeftLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 10), textColor: TSColor.normal.secondary)
        let agreementRightBtn = UIButton(type: .custom)
        agreementRightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        agreementRightBtn.setTitleColor(TSColor.normal.secondary, for: .normal)
        agreementRightBtn.setTitleColor(TSColor.normal.secondary, for: .highlighted)
        agreementRightBtn.addTarget(self, action: #selector(registerAgreementBtnClick), for: .touchUpInside)
        agreementRightBtn.contentHorizontalAlignment = .left

        self.addSubview(checkNameView)
        checkNameView.addSubview(image)
        self.addSubview(msgLabel)
        self.addSubview(btnForLgoin)
        agreementView.addSubview(agreementLeftLabel)
        agreementView.addSubview(agreementRightBtn)
        self.addSubview(agreementView)

        checkNameView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(54)
        }
        image.snp.makeConstraints { (make) in
            make.centerY.equalTo(checkNameView)
            make.height.equalTo(15)
            make.width.equalTo(30)
            make.right.equalTo(checkNameView).offset(-13.5)
        }
        msgLabel.snp.makeConstraints { (make) in
            make.top.equalTo(checkNameView.snp.bottom).offset(20)
            make.left.equalTo(self).offset(15.5)
        }
        btnForLgoin.snp.makeConstraints { (make) in
            make.top.equalTo(msgLabel.snp.bottom).offset(23)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo(45)
        }
        image.isHidden = true
        btnForLgoin.isEnabled = false

        agreementLeftLabel.snp.makeConstraints { (make) in
            make.leading.centerY.equalTo(agreementView)
        }
        agreementRightBtn.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalTo(agreementView)
            make.leading.equalTo(agreementLeftLabel.snp.trailing)
        }
        agreementView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-20)
            make.centerX.equalTo(self)
        }

        let str = self.superVC.socialite.name
        if str != "" {
            self.checkNameView.userInput.text = str
            checkName(name: str)
        }

        agreementLeftLabel.text = "显示_注册_协议提示".localized
        let agreementTitle = String(format: "注册_协议名".localized, TSAppSettingInfoModel().appDisplayName)
        agreementRightBtn.setTitle(agreementTitle, for: .normal)
        agreementView.isHidden = !TSAppConfig.share.localInfo.registerShowTerms
    }

    func check(_ textField: UITextField) -> Void {
        btnForLgoin.isEnabled = false
        image.isHidden = true
        msgLabel.isHidden = true
        let str = textField.text
        guard str != "" && str?.first != " " else {
            return
        }
        btnForLgoin.isEnabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }

    func checkName(name: String) {
        let str = self.checkNameView.userInput.text
        if TSAccountRegex.countShortFor(userName: str) || TSAccountRegex.countTooLongFor(userName: str, count: 16) {
            self.msgLabel.text = "提示信息_昵称长度错误".localized
            self.msgLabel.isHidden = false
            return
        } else if TSAccountRegex.isUserNameStartWithNumber(str) {
            self.msgLabel.text = "提示信息_昵称以数字开头".localized
            self.msgLabel.isHidden = false
            return
        } else if !TSAccountRegex.isUserNameFormat(str) {
            self.msgLabel.text = "提示信息_昵称含有不合法字符".localized
            self.msgLabel.isHidden = false
            return
        }
        BindingNetworkManager().checkUserName(provider: self.superVC.socialite.provider, name: name, token: self.superVC.socialite.token) { (msg, status) in
            guard status else {
                self.msgLabel.text = msg
                self.msgLabel.isHidden = false
                return
            }
            self.image.isHidden = false
            self.btnForLgoin.isEnabled = true
        }
    }

    func showLableVC() {
        // 跳转到标签选择页面
        let labelVC = TSUserLabelSetting(type: .register)
        self.superVC.navigationController?.pushViewController(labelVC, animated: true)
    }

    /// 注册协议点击响应
    func registerAgreementBtnClick() -> Void {
        let content: String = TSAppConfig.share.localInfo.content
        let markdownVC = TSMarkdownController(markdown: content)
        markdownVC.title = "注册协议"
        self.superVC.navigationController?.pushViewController(markdownVC, animated: true)
    }

    func submitRegister() {
        let str = self.checkNameView.userInput.text
        if TSAccountRegex.countShortFor(userName: str) || TSAccountRegex.countTooLongFor(userName: str, count: 16) {
            self.msgLabel.text = "提示信息_昵称长度错误".localized
            self.msgLabel.isHidden = false
            return
        } else if TSAccountRegex.isUserNameStartWithNumber(str) {
            self.msgLabel.text = "提示信息_昵称以数字开头".localized
            self.msgLabel.isHidden = false
            return
        } else if !TSAccountRegex.isUserNameFormat(str) {
            self.msgLabel.text = "提示信息_昵称含有不合法字符".localized
            self.msgLabel.isHidden = false
            return
        }
        self.btnForLgoin.isUserInteractionEnabled = false
        BindingNetworkManager().checkUserName(provider: self.superVC.socialite.provider, name: str!, token: self.superVC.socialite.token) { (msg, status) in
            guard status else {
                self.msgLabel.text = msg
                self.msgLabel.isHidden = false
                self.btnForLgoin.isEnabled = false
                self.btnForLgoin.isUserInteractionEnabled = true
                return
            }
            self.image.isHidden = false
            BindingNetworkManager().checkUserNameIsOk(provider: self.superVC.socialite.provider, name: str!, token: self.superVC.socialite.token) { (userToken, model, _, status) in
            self.btnForLgoin.isUserInteractionEnabled = true
                guard status else {
                    return
                }
                BindingNetworkManager().saveUserInfo(token: userToken!, model: model!, isRegister: true)
                self.showLableVC()
            }
        }
    }
}
