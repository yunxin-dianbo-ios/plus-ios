//
//  TSUnbindVC.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

/// 解绑页面
/// - phone
/// - email
class TSUnbindVC: UIViewController, TSUnbindPhoneOrEmailViewDeleagte {
    var socialite: TSSocialite!
    weak var unbindPhoneOrEmailView: TSUnbindPhoneOrEmailView!

    init(socialite: TSSocialite) {
        super.init(nibName: nil, bundle: nil)
        self.socialite = socialite
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TSColor.inconspicuous.background
        var title = ""
        switch self.socialite.provider {
        case .phone:
            title = "解绑手机号"
        case .email:
            title = "解绑邮箱"
        default:
            break
        }
        self.title = title
        setUI()
    }

    func setUI() {
        let unbindPhoneOrEmailView = TSUnbindPhoneOrEmailView(frame: self.view.frame, provider: self.socialite.provider)
        unbindPhoneOrEmailView.delegate = self
        self.unbindPhoneOrEmailView = unbindPhoneOrEmailView

        self.view.addSubview(unbindPhoneOrEmailView)
    }

    // MARK: - 代理回调
    func clickUnbind(pw: String, code: String) {
        switch self.socialite.provider {
        case .phone:
            BindingNetworkManager().unbindPhone(password: pw, code: code) { (msg, status) in
                guard status else {
                    self.unbindPhoneOrEmailView.btnForLogin.isUserInteractionEnabled = true
                    self.unbindPhoneOrEmailView.msgLabel.text = msg
                    self.unbindPhoneOrEmailView.msgLabel.isHidden = false
                    return
                }
                _ = self.navigationController?.popViewController(animated: true)
            }
        case .email:
            BindingNetworkManager().unbindEmail(password: pw, code: code) { (msg, status) in
                guard status else {
                    self.unbindPhoneOrEmailView.btnForLogin.isUserInteractionEnabled = true
                    self.unbindPhoneOrEmailView.msgLabel.text = msg
                    self.unbindPhoneOrEmailView.msgLabel.isHidden = false
                    return
                }
                _ = self.navigationController?.popViewController(animated: true)

            }
        default:
            assert(false, "页面传输provider出错")
            break
        }
    }

}
