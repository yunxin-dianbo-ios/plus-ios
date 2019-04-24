//
//  TSOtherRegisteredVC.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SnapKit

class TSOtherRegisteredVC: TSViewController, TSOtherRegisterdChooseViewDelegate {

    /// 三方注册选择弹窗
    let registerdChooseView = TSOtherRegisterdChooseView()
    var socialite: TSSocialite!

    init(socialite: TSSocialite) {
        super.init(nibName: nil, bundle: nil)
        self.socialite = socialite
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "绑定账号"
        setUI()
    }

    func setUI() -> Void {
        registerdChooseView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerdChooseView.show()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        registerdChooseView.remove()
    }

    /// 隐藏导航栏左边按钮
    func hiddenLeftButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationItem.hidesBackButton = true
    }

    func didRegisnterdBtnInTSOtherRegisterdChooseView(_ ChooseView: TSOtherRegisterdChooseView) {
        registerdChooseView.remove()
        let fillVC = ThreeUserFillInfoVC()
        fillVC.socialite = socialite
        fillVC.title = "完善资料"
        let completeMaterialView = TSCompleteMaterialView(frame: CGRect.zero, superVC: fillVC)
        fillVC.view.addSubview(completeMaterialView)
        completeMaterialView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        navigationController?.pushViewController(fillVC, animated: true)
    }

    func didBindBtnInTSOtherRegisterdChooseView(_ ChooseView: TSOtherRegisterdChooseView) {
        registerdChooseView.remove()
        let fillVC = ThreeUserFillInfoVC()
        fillVC.socialite = socialite
        fillVC.title = "已有账号"
        let hasAccountView = TSHasAccountView()
        fillVC.hasAccountView = hasAccountView
        hasAccountView.delegate = fillVC
        fillVC.view.addSubview(hasAccountView)
        hasAccountView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        navigationController?.pushViewController(fillVC, animated: true)
    }
}
