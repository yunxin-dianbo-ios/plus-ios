//
//  TSMessagePopGroupVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/9.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSMessagePopGroupVC: JoinedGroupListVC {

    var messageModel: TSmessagePopModel? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let infoModel = self.showDataArray[indexPath.row]
        let groupName = infoModel.name
        let groupID = infoModel.groupId
        messageModel?.titleSecond = groupName
        let messagePopVC = TSMessagePopoutVC()
        messagePopVC.show(vc: messagePopVC)
        messagePopVC.setInfo(model: messageModel!)
        messagePopVC.sendBlock = { (sendModel) in
            let topIndicator = TSIndicatorWindowTop(state: .loading, title: "发送中..")
            topIndicator.show()
            TSIMMessageManager.sendShareCardMessage(model: sendModel, conversationId: groupID, conversationType: EMConversationTypeGroupChat, UpProgress: { (progress) in
            }, complete: { (aMessage, aError) in
                topIndicator.dismiss()
                if aError == nil {
                    TSIndicatorWindowTop.showDefaultTime(state: .success, title: "分享成功")
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "sendMessageReloadChatListVc")))
                    /// 需求：返回进入私信分享的页面
                    if let nav = self.navigationController, nav.viewControllers.count > 2 {
                        let vc = nav.viewControllers[nav.viewControllers.count - 3]
                        nav.popToViewController(vc, animated: true)
                    }
                } else {
                    TSIndicatorWindowTop.showDefaultTime(state: .faild, title: "分享失败")
                }
            })
        }
    }
}
