//
//  TSPopMessageFriendList.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/8.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSPopMessageFriendList: TSViewController {
    /// IM第二版聊天列表页面(新构造的)
    var chatListNewVC: TSPopMessageVC
    var messageModel: TSmessagePopModel? = nil

    init(model: TSmessagePopModel) {
        self.chatListNewVC = TSPopMessageVC()
        super.init(nibName: nil, bundle: nil)
        self.chatListNewVC.messageModel = model
        self.chatListNewVC.superMessagePop = self
        self.addChildViewController(self.chatListNewVC)
        self.view.addSubview(self.chatListNewVC.view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "选择好友"
        let cancelButton = TSTextButton.initWith(putAreaType: .top)
        cancelButton.setTitle("选择_取消".localized, for: .normal)
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.addTarget(self, action: #selector(tapCancelButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
    }

    func tapCancelButton() {
        let _ = self.navigationController?.dismiss(animated: true, completion: {})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
