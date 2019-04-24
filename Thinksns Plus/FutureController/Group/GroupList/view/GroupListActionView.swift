//
//  GroupListActionView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子交互列表视图

import UIKit

class GroupListActionView: GroupListView, TSCustomAcionSheetDelegate {

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Group.joined, object: nil)
    }

    override func setUI() {
        super.setUI()
        actionDelegate = self
        setNotification()
    }

    // MARK: - Notification

    /// 增加通知
    func setNotification() {
        // 1.用户在其他页面，加入或退出了某个圈子
        NotificationCenter.default.addObserver(self, selector: #selector(processJoinedNotification(_:)), name: NSNotification.Name.Group.joined, object: nil)
    }

    /// 收到通知，处理用户加入或退出某个圈子
    func processJoinedNotification(_ noti: Notification) {
        // 1.解析通知中的数据
        guard let userInfo = noti.userInfo as? [String: Any], let isJoin = userInfo["isJoin"] as? Bool, let groupInfo = userInfo["groupInfo"] as? GroupListCellModel else {
            return
        }

        // 2.检索数据中有没有对应的圈子
        if let changeCellModel = datas.first(where: { $0.id == groupInfo.id }) {
            changeCellModel.role = isJoin ? .member : .unjoined
        }

        // 刷新列表
        reloadData()
    }
}

// MARK: - GroupListView 交互代理事件
extension GroupListActionView: GroupListViewActionDelegate {

    /// 点击了加入按钮
    func groupListView(_ view: GroupListView, didSelectedJoinButtonAt cell: GroupListCell) {

        // 如果是游客模式，触发登录注册操作
        if TSCurrentUserInfo.share.isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }

        let groupIndexPath = view.indexPath(for: cell)!
        let cellModel = view.datas[groupIndexPath.row]
        let groupId = cellModel.id

        // 1.如果是加入圈子，先判断是否是付费圈子，如果是，显示付费弹窗
        let mode = cellModel.mode
        if mode == "paid" {
            PaidManager.showPaidGroupAlert(price: Double(cellModel.joinMoney), groupId: groupId, groupMode: mode) {
                // 付费的圈子有审核时间，所以不需要立刻通知列表刷新界面
            }
            return
        }

        // 2.如果不是付费圈子，直接发起加入申请
        let alert = TSIndicatorWindowTop(state: .loading, title: "正在加入圈子")
        alert.show()
        cell.joinButton.isEnabled = false
        GroupNetworkManager.joinGroup(groupId: groupId, complete: { [weak self] (isSuccess, message) in
            alert.dismiss()
            cell.joinButton.isEnabled = true
            guard self != nil else {
                return
            }
            // 成功加入
            if isSuccess {
                let successAlert = TSIndicatorWindowTop(state: .success, title: message)
                successAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                // 非公开的圈子，需要审核时间，所以不能马上改变加入状态
                if cellModel.mode == "public" {
                    view.datas[groupIndexPath.row].role = .member
                    view.datas[groupIndexPath.row].joined = GroupJoinModel(JSON: ["id": 0, "group_id": view.datas[groupIndexPath.row].id, "audit": 1])
                    view.datas[groupIndexPath.row].shouldPushDetail = true
                    // 发送通知
                    NotificationCenter.default.post(name: NSNotification.Name.Group.joined, object: nil, userInfo: ["isJoin": true, "groupInfo": view.datas[groupIndexPath.row]])
                    view.reloadData()
                }
            } else {
                // 加入失败
                let faildAlert = TSIndicatorWindowTop(state: .faild, title: message ?? "加入失败")
                faildAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        })
    }

    /// 点击了 cell
    func groupListView(_ view: GroupListView, didSelectedCellAt indexPath: IndexPath) {

        if self.tableIdentifier == "audit" {
            // 审核中不允许进入
            let actionsheetView = TSCustomActionsheetView(titles: ["提示", "圈子还在审核中"])
            actionsheetView.setColor(color: TSColor.normal.minor, index: 1)
            actionsheetView.delegate = self
            actionsheetView.tag = 2
            actionsheetView.cancelText = "知道了"
            actionsheetView.notClickIndexs = [0, 0]
            actionsheetView.show()
            return
        }
        // 如果是没有加入的圈子，是不能进入帖子列表的
        let cellModel = view.datas[indexPath.row]
        if cellModel.shouldPushDetail == false {
            let previewVC = GroupPreviewVC()
            previewVC.groupId = cellModel.id
            parentViewController?.navigationController?.pushViewController(previewVC, animated: true)
            return
        }
        let postListVC = GroupDetailVC(groupId: cellModel.id)
        parentViewController?.navigationController?.pushViewController(postListVC, animated: true)
    }
    // MARK: TSCustomAcionSheetDelegate
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
    }
}
