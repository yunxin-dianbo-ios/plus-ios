//
//  TSMessagePopNewChatVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/9.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSMessagePopNewChatVC: TSChatFriendListViewController {

    var messageModel: TSmessagePopModel? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        title = "选择好友"
        self.rightButtonTitle = "发送"
        // Do any additional setup after loading the view.
    }
    override func rightButtonClick() {
        var showPopTitle = ""
        var sendUserIDs: [Int] = []
        if choosedDataSource.count == 1 {
            let model: TSUserInfoModel = choosedDataSource[0] as! TSUserInfoModel
            sendUserIDs.append(model.userIdentity)
            showPopTitle = model.name
        } else {
            var groupname = ""
            for (index, _) in choosedDataSource.enumerated() {
                let model: TSUserInfoModel = choosedDataSource[index] as! TSUserInfoModel
                if groupname == "" {
                    groupname = "\(model.name)"
                } else {
                    groupname = "\(groupname)、\(model.name)"
                }
                sendUserIDs.append(model.userIdentity)
            }
            showPopTitle = groupname
        }
        messageModel?.titleSecond = showPopTitle
        let messagePopVC = TSMessagePopoutVC()
        messagePopVC.show(vc: messagePopVC)
        messagePopVC.setInfo(model: messageModel!)
        messagePopVC.sendBlock = { (sendModel) in
            let topIndicator = TSIndicatorWindowTop(state: .loading, title: "发送中..")
            topIndicator.show()
            for (index, item) in sendUserIDs.enumerated() {
                TSIMMessageManager.sendShareCardMessage(model: sendModel, conversationId: String(item), conversationType: EMConversationTypeChat, UpProgress: { (progress) in
                }, complete: { (aMessage, aError) in
                    topIndicator.dismiss()
                    if aError == nil {
                        if index == sendUserIDs.count - 1 {
                            TSIndicatorWindowTop.showDefaultTime(state: .success, title: "分享成功")
                        }
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension TSMessagePopNewChatVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        keyword = searchBar.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        view.endEditing(true)
        TSUserNetworkingManager().friendList(offset: nil, keyWordString: keyword, complete: { (userModels, networkError) in
            self.processRefresh(datas: userModels, message: networkError)
        })
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            keyword = searchBar.text ?? ""
            keyword = keyword.replacingOccurrences(of: " ", with: "")
            view.endEditing(true)
            TSUserNetworkingManager().friendList(offset: nil, keyWordString: keyword, complete: { (userModels, networkError) in
                self.processRefresh(datas: userModels, message: networkError)
            })
        }
    }
}
