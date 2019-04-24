//
//  TSContactsVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  通讯录视图控制器

import UIKit

class TSContactsVC: TSTableViewController, TSNewFriendsCellDelegate, TSContactsCellDelegate {

    /// 已加入的好友信息
    var joinedDataSouce: [TSUserInfoModel] = []
    /// 未加入的好友信息
    var unjoinedDataSource: [TSContactModel] = []

    /// 通讯录管理类
    let contactsManager = TSContacts()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loadData()
    }

    // MARK: - Custom user interface
    func setUI() {
        title = "通讯录"
        // table view
        tableView.mj_footer = nil
        tableView.mj_header = nil
        tableView.rowHeight = 77.5
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "TSNewFriendsCell", bundle: nil), forCellReuseIdentifier: TSNewFriendsCell.identifier)
        tableView.register(UINib(nibName: "TSContactsCell", bundle: nil), forCellReuseIdentifier: TSContactsCell.identifier)
    }

    // MARK: - Data
    func loadData() {
        // 1.获取所有联系人
        let allContacts = contactsManager.getContactsInfo()
        // 2.通过所有联系人的电话号码，向后台获取已经加入 TS+ 的好友
        let phones = allContacts.map { $0.phone }
        TSNewFriendsNetworkManager.getJoinedContactsInfo(phones: phones) { [weak self] (datas: [TSUserInfoModel]?, message: String?, _) in
            // 获取数据失败
            guard let datas = datas, let weakSelf = self, message == nil else {
                return
            }
            // 3.获取“已加入”数据成功，计算“未加入”数据
            weakSelf.process(datas: datas, allContacts: allContacts)
            // 4.刷新界面
            weakSelf.tableView.reloadData()
        }
    }

    /// 处理后台返回的已加入 TS+ 的信息，计算出未加入的用户数据
    ///
    /// - Parameters:
    ///   - datas: 加入 TS+ 的好友
    ///   - allContacts: 通讯录所有的联系人
    func process(datas: [TSUserInfoModel], allContacts: [TSContactModel]) {
        // 1.取出已加入的所有用户的电话号码
        let joinedPhones = datas.filter({ (userInfo) -> Bool in
            return userInfo.userIdentity != TSCurrentUserInfo.share.userInfo?.userIdentity
        }).flatMap { $0.mobi }
        // 2.检查所有联系人
        var joinedDatas: [TSUserInfoModel] = []
        var unjoinedDataSource: [TSContactModel] = []
        for contact in allContacts {
            // 2.1 如果没有 joinedPhones 中相同的号码，那么就认为此人没有加入 TS+
            let isJoinedTs = joinedPhones.contains(contact.phone)
            if !isJoinedTs {
                unjoinedDataSource.append(contact)
                continue
            }
            // 如果此人加入了 TS+，匹配一下此人的真实姓名和用户名
            /*
             这里偷了下懒，"已加入 TS+ 好友"用的是的 TSNewFriendsCell
             
             "已加入 TS+ 好友"的 UI 和这个 cell 很像，只不过显示的是用户真名和用户昵称，位置分别对应 TSNewFriendsCell 的用户名name 和用户简介 introl
             
             */
            // 2.2 找出对应的 userModel
            if let userModel = datas.first(where: { $0.mobi == contact.phone }) {
                let name = userModel.name
                userModel.name = contact.name
                userModel.bio = "用户名：" + name
                joinedDatas.append(userModel)
            }
        }
        joinedDataSouce = joinedDatas
        self.unjoinedDataSource = unjoinedDataSource
    }

    // MARK: - Delegate

    // MARK: UITableViewDelegate, UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return min(joinedDataSouce.count, 5)
        }
        if section == 1 {
            return min(unjoinedDataSource.count, 5)
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = TSContactsSectionView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 35)))
        view.label.text = [String(format: "已加入的好友".localized, "APP_SIMPLE_NAME".localized), String(format: "通讯录未加入好友".localized, "APP_SIMPLE_NAME".localized)][section]
        // “已加入 TS+ 的好友”的 section view 设置
        if section == 0 {
            // 如果 section 中的数据数量小于 5，就不显示更多按钮
            view.button.isHidden = joinedDataSouce.count < 5
            view.arrowsImageView.isHidden = joinedDataSouce.count < 5
            // 设置更多按钮点击时间
            view.moreButtonOperation = { (title) in
                let vc = TSContactsDetailVC(joinedDataSouce: self.joinedDataSouce)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        if section == 1 {
            // ”未加入的好友“的 section view 设置
            view.button.isHidden = unjoinedDataSource.count < 5
            view.moreButtonOperation = { (title) in
                let vc = TSContactsDetailVC(unjoinedDataSouce: self.unjoinedDataSource)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return view
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        // 已加入的好友 cell
        if indexPath.section == 0 {
            let joinCell = tableView.dequeueReusableCell(withIdentifier: TSNewFriendsCell.identifier, for: indexPath) as! TSNewFriendsCell
            joinCell.setInfo(model: joinedDataSouce[indexPath.row])
            joinCell.delegate = self
            cell = joinCell
        }
        // 通讯录未加入的好友 cell
        if indexPath.section == 1 {
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
