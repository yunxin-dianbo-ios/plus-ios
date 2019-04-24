//
//  TSSigninShowView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 09/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  签到显示视图
//  签到视图TSSigninView的容器，便于以后的扩展(如显示和消失时的动画)

import Foundation

class TSSigninShowView: UIView {

    // MARK: - Internal Property
    // MARK: - Private Property
    private weak var signinView: TSSigninView!

    // MARK: - Internal Function

    // MARK: - Initialize Function
    init() {
        super.init(frame: UIScreen.main.bounds)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // 1.背景遮罩
        let coverBtn = TSButton(type: .custom)
        self.addSubview(coverBtn)
        coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        coverBtn.addTarget(self, action: #selector(didCoverBtnClick(_:)), for: .touchUpInside)
        coverBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        // 2. singinView
        let signinView = TSSigninView()
        self.addSubview(signinView)
        signinView.delegate = self
        signinView.snp.makeConstraints { (make) in
            make.width.equalTo(250)
            make.height.equalTo(320)
            make.center.equalTo(self)
        }
        self.signinView = signinView
    }

    // MARK: - Private  数据加载
    /// 获取数据加载UI（外部）
    ///
    /// - Parameter data: 用户签到数据
    public func loadObtainedData(data: TSCheckinModel) -> Void {
        self.signinView.getData(data: data)
    }

    // MARK: - Private  事件响应

    /// 背景遮罩点击响应
    @objc private func didCoverBtnClick(_ button: UIButton) -> Void {
        self.remove()
    }
}

// MARK: - 显示 与 移除

extension TSSigninShowView {

    /// 显示
    func show() -> Void {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.edges.equalTo(window)
        }
        // 显示动画添加位置
    }

    /// 移除
    func remove() -> Void {
        // 移除动画添加位置
        self.removeFromSuperview()
    }
}

// MARK: - TSSigninViewProtocol

extension TSSigninShowView: TSSigninViewProtocol {
    /// 退出按钮点击回调
    func didClickExitBtnInSigninView(_ signinView: TSSigninView) {
        self.remove()
    }
    /// 签到按钮点击回调
    func signinView(_ signinView: TSSigninView, didClickSigninBtn signinBtn: UIButton) {
        signinView.disableSigninBtn()
    }
    /// 签到用户列表中用户头像点击
    func signinView(_ signinView: TSSigninView, didClickSigninedUser userId: Int) -> Void {
        self.remove()
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": userId])
    }
}
