//
//  TSContactsDetailVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import MessageUI

class TSContactsDetailVC: TSTableViewController, TSNewFriendsCellDelegate, TSContactsCellDelegate {

    /// 已加入的好友信息
    var joinedDataSouce: [TSUserInfoModel] = []
    /// 未加入的好友信息
    var unjoinedDataSource: [TSContactModel] = []

    /// 通讯录管理类
    let contactsManager = TSContacts()

    // MARK: - Lifecycle

    /// 初始化 已加入TS+的好友 视图控制器
    init(joinedDataSouce datas: [TSUserInfoModel]) {
        super.init(nibName: nil, bundle: nil)
        joinedDataSouce = datas
        title = String(format: "已加入的好友".localized, "APP_SIMPLE_NAME".localized)
    }

    /// 初始化 未加入TS+的好友 视图控制器
    init(unjoinedDataSouce datas: [TSContactModel]) {
        super.init(nibName: nil, bundle: nil)
        unjoinedDataSource = datas
        title = String(format: "未加入的好友".localized, "APP_SIMPLE_NAME".localized)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    // MARK: - Custom user interface
    func setUI() {
        // table view
        tableView.mj_footer = nil
        tableView.mj_header = nil
        tableView.rowHeight = 77.5
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "TSNewFriendsCell", bundle: nil), forCellReuseIdentifier: TSNewFriendsCell.identifier)
        tableView.register(UINib(nibName: "TSContactsCell", bundle: nil), forCellReuseIdentifier: TSContactsCell.identifier)
        tableView.reloadData()
    }

    // MARK: - Delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(joinedDataSouce.count, unjoinedDataSource.count)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        // 已加入的好友 cell
        if !joinedDataSouce.isEmpty {
            let joinCell = tableView.dequeueReusableCell(withIdentifier: TSNewFriendsCell.identifier, for: indexPath) as! TSNewFriendsCell
            joinCell.setInfo(model: joinedDataSouce[indexPath.row])
            joinCell.delegate = self
            cell = joinCell
        }
        // 通讯录未加入的好友 cell
        if !unjoinedDataSource.isEmpty {
            let unjoinCell = tableView.dequeueReusableCell(withIdentifier: TSContactsCell.identifier, for: indexPath) as! TSContactsCell
            unjoinCell.setInfo(model: unjoinedDataSource[indexPath.row])
            unjoinCell.delegate = self
            cell = unjoinCell
        }
        cell.selectionStyle = .none
        return cell
    }

    // MARK: TSNewFriendsCellDelegate

    /// 点击了关注按钮
    func cell(_ cell: TSNewFriendsCell, didSelectedFollowButton button: UIButton) {
        // 1.判断是否为游客模式
        if !TSCurrentUserInfo.share.isLogin {
            // 如果是游客模式，拦截操作显示登录界面
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 2.进行关注操作
        let indexPath = tableView.indexPath(for: cell)!
        let userInfo = joinedDataSouce[indexPath.row]
        userInfo.follower = !userInfo.follower
        joinedDataSouce[indexPath.row] = userInfo
        self.tableView.reloadRows(at: [indexPath], with: .none)
        TSUserNetworkingManager().operate(userInfo.follower == true ? .follow : .unfollow, userID: userInfo.userIdentity)
        cell.setInfo(model: userInfo)
    }

    // MARK: TSContactsCellDelegate

    /// 点击了邀请按钮
    func cell(_ cell: TSContactsCell, didSelectedInviteButton: UIButton) {
        let indexPath = tableView.indexPath(for: cell)!
        let data = unjoinedDataSource[indexPath.row]
        guard contactsManager.canSendText() else {
            return
        }
        let message = TSAppConfig.share.localInfo.inviteUserInfo
        let vc = contactsManager.getMessageVC(message: message, phones: [data.phone])
        present(vc, animated: true, completion: nil)
    }
}
