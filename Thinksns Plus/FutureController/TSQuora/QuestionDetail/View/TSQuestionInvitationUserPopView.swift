//
//  TSQuestionInvitationUserPopView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 30/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题详情页 - 邀请用户弹窗

import UIKit

protocol TSQuestionInvitationUserPopViewProtocol: class {
    /// 用户点击的回调
    func didClickUser(in popView: TSQuestionInvitationUserPopView) -> Void
}

class TSQuestionInvitationUserPopView: UIView {

    // MARK: - Internal Property
    /// 回调
    weak var delegate: TSQuestionInvitationUserPopViewProtocol?
    var userClickAction: ((_ popView: TSQuestionInvitationUserPopView) -> Void)?
    /// 头像
    private(set) weak var iconView: AvatarView!
    /// 名字
    private(set) weak var nameLabel: UILabel!
    // MARK: - Private Property
    /// 用户按钮的顶部间距
    private let topMargin: CGFloat
    private weak var coverBtn: UIButton!

    // MARK: - Internal Function

    // MARK: - Initialize Function
    init(topMargin: CGFloat) {
        self.topMargin = topMargin
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        let iconWH: CGFloat = 26
        let leftMargin: CGFloat = 20
        let rightMargin: CGFloat = 20
        let centerMargin: CGFloat = 10
        let controlH: CGFloat = 40
        // 1. coverBtn
        let coverBtn = UIButton(type: .custom)
        self.addSubview(coverBtn)
        coverBtn.addTarget(self, action: #selector(coverBtnClick(_:)), for: .touchUpInside)
        coverBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        self.coverBtn = coverBtn
        // 2. userControl
        let userControl = UIControl()
        coverBtn.addSubview(userControl)
        userControl.addTarget(self, action: #selector(userControlClick(_:)), for: .touchUpInside)
        userControl.layer.masksToBounds = true
        userControl.layer.cornerRadius = 5
        userControl.layer.borderWidth = 1
        userControl.layer.borderColor = TSColor.inconspicuous.disabled.cgColor
        userControl.backgroundColor = UIColor.white
        userControl.snp.makeConstraints { (make) in
            make.top.equalTo(coverBtn).offset(topMargin)
            make.height.equalTo(controlH)
            // centerX暂时这样使用，也可以在构造时传入centerX和maxW
            make.centerX.equalTo(coverBtn.snp.leading).offset(ScreenWidth * 0.25)
            // 给最大宽度，避免名字过长时因上面的居中方式导致头像被挤到屏幕外
            make.width.lessThanOrEqualTo(ScreenWidth * 0.5 - 20.0 * 2.0)
            // 给最小宽度，避免名字过短如一个字时不好看
            make.width.greaterThanOrEqualTo(110)
        }
        // 2.1 iconView
        let iconView = AvatarView(type: AvatarType.width26(showBorderLine: false))
        userControl.addSubview(iconView)
        iconView.isUserInteractionEnabled = false
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(iconWH)
            make.centerY.equalTo(userControl)
            make.leading.equalTo(userControl).offset(leftMargin)
        }
        self.iconView = iconView
        // 2.2 nameLabel
        let nameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.content)
        userControl.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(iconView.snp.trailing).offset(centerMargin)
            make.trailing.equalTo(userControl).offset(-rightMargin)
            make.centerY.equalTo(userControl)
        }
        self.nameLabel = nameLabel
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

    /// 遮罩点击响应
    @objc private func coverBtnClick(_ button: UIButton) -> Void {
        button.removeFromSuperview()
        self.removeFromSuperview()
    }
    /// 用户点击响应
    @objc private func userControlClick(_ control: UIControl) -> Void {
        self.removeFromSuperview()
        self.delegate?.didClickUser(in: self)
        self.userClickAction?(self)
    }
}
