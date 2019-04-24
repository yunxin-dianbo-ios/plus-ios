//
//  TSOtherRegisterdChooseView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SnapKit

protocol TSOtherRegisterdChooseViewDelegate: NSObjectProtocol {
    /// 只是表示点了那个按钮
    /// - 点了注册按钮
    ///
    func didRegisnterdBtnInTSOtherRegisterdChooseView(_ ChooseView: TSOtherRegisterdChooseView)
    /// 只是表示点了那个按钮
    /// - 点了绑定按钮
    ///
    func didBindBtnInTSOtherRegisterdChooseView(_ ChooseView: TSOtherRegisterdChooseView)
}

class TSOtherRegisterdChooseView: UIView {
    /// 注册新用户btn
    let registerdNewBtn = TSButton(type: .system)
    /// 绑定已有账号btn
    let bindHasAnAccountBtn = TSButton(type: .system)
    /// 分割线
    let separatorView = TSSeparatorView()
    let bgView: UIView = UIView()
    /// 代理
    weak var delegate: TSOtherRegisterdChooseViewDelegate? = nil

    init() {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        self.isUserInteractionEnabled = false
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() -> Void {
        bgView.backgroundColor = TSColor.main.white
        bgView.layer.cornerRadius = 5
        bgView.layer.masksToBounds = true
        registerdNewBtn.backgroundColor = UIColor.clear
        registerdNewBtn.setTitle("注册新用户", for: .normal)
        registerdNewBtn.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.navigation.rawValue)
        registerdNewBtn.setTitleColor(TSColor.inconspicuous.navTitle, for: .normal)
        registerdNewBtn.addTarget(self, action: #selector(regisnterd), for: .touchUpInside)
        bindHasAnAccountBtn.backgroundColor = UIColor.clear
        bindHasAnAccountBtn.setTitle("绑定已有账号", for: .normal)
        bindHasAnAccountBtn.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.navigation.rawValue)
        bindHasAnAccountBtn.setTitleColor(TSColor.inconspicuous.navTitle, for: .normal)
        bindHasAnAccountBtn.addTarget(self, action: #selector(bind), for: .touchUpInside)

        bgView.addSubview(registerdNewBtn)
        bgView.addSubview(bindHasAnAccountBtn)
        bgView.addSubview(separatorView)

    }

    func regisnterd() {
        self.delegate?.didRegisnterdBtnInTSOtherRegisterdChooseView(self)
    }

    func bind() {
        self.delegate?.didBindBtnInTSOtherRegisterdChooseView(self)
    }

    /// 显示
    func show() -> Void {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.edges.equalTo(window)
        }
        window.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.center.equalTo(window.snp.center)
            make.width.equalTo(150)
            make.height.equalTo(100)
        }
        registerdNewBtn.snp.makeConstraints { (make) in
            make.top.right.left.equalTo(bgView)
            make.height.equalTo(49.75)
        }
        bindHasAnAccountBtn.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(bgView)
            make.height.equalTo(registerdNewBtn)
        }
        separatorView.snp.makeConstraints { (make) in
            make.left.right.equalTo(bgView)
            make.top.equalTo(registerdNewBtn.snp.bottom)
            make.bottom.equalTo(bindHasAnAccountBtn.snp.top)
        }
    }

    /// 移除
    func remove() -> Void {
        self.removeFromSuperview()
        bgView.removeFromSuperview()
    }
}
