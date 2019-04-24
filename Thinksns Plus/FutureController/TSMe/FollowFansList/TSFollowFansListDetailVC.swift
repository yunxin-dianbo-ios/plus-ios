//
//  TSFollowFansListDetailVC.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/26.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  关注粉丝类

import UIKit
import RealmSwift

protocol ChangeVCStateDelegate: NSObjectProtocol {
    /// 改变两张列表状态的逻辑
    ///
    /// - Parameters:
    ///   - data: 数据
    ///   - row: 行
    ///   - controller: 当前的controller
    ///   - isCancel: 是否是取消关注
    func changeState(data: TSFollowFansListModel, row: Int, controller: TSFollowFansListDetailVC, isCancel: TSUserIsCancelFollow)
}

class TSFollowFansListDetailVC: TSRankingListTableViewController {

    /// 数据类型
    ///
    /// - fans: 粉丝列表
    /// - follow: 关注列表
    enum dataSourceType {
        case fans
        case follow
    }

    /// 类型
    var type: TSUserRelationType = .fans
    /// 代理
    weak var changeVCStateDelegate: ChangeVCStateDelegate?
    /// 用户ID
    var userId: Int = 0

    // MARK: - Lifecycle
    init(type: TSUserRelationType, userId: Int) {
        super.init(cellType: .concernCell)
        self.useUserId = userId
        self.type = type
        self.userId = userId
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    func setUI() {
        occupiedView.contentMode = .center
        occupiedView.backgroundColor = TSColor.inconspicuous.background
        self.view.backgroundColor = TSColor.inconspicuous.background
        self.isEnabledHeaderButton = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.mj_header.beginRefreshing()
        //因为视图结构导致这儿拿不到当前页面的userID
    }

    // MARK: - process refresh
    override func refresh() {
        let isAuth: Bool = TSCurrentUserInfo.share.userInfo?.userIdentity == self.userId
        if isAuth == true && self.type == .fans {
            // 只有进入自己的粉丝列表才上传已读
            var request = UserNetworkRequest().readCounts
            request.urlPath = request.fullPathWith(replacers: [])
            request.parameter = ["type": "following"]
            RequestNetworkData.share.text(request: request) { (_) in
            }
        }

        TSUserNetworkingManager().user(identity: self.userId, fansOrFollowList: type, offset: nil, isAuth: isAuth) { [weak self] (userModels, networkError) in
            self?.occupiedView.removeFromSuperview()
            if networkError == nil {
                self?.tableView.mj_header.endRefreshing()
                if let userModels = userModels {
                    if userModels.isEmpty {
                        self?.showOccupiedView(type: .empty)
                        return
                    }
                    self?.listData = userModels
                    self?.tableView.reloadData()
                }
            } else {
                self?.showOccupiedView(type: .network)
                self?.tableView.mj_header.endRefreshing()
            }
        }
    }

    override func loadMore() {
        let isAuth: Bool = TSCurrentUserInfo.share.userInfo?.userIdentity == self.userId
        let offset = self.listData.count
        TSUserNetworkingManager().user(identity: self.userId, fansOrFollowList: type, offset: offset, isAuth: isAuth) { [weak self] (userModels, networkError) in
            if networkError == nil {
                if let userModels = userModels {
                    if userModels.isEmpty {
                        self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                        return
                    }
                    if let weakSelf = self {
                        weakSelf.listData = weakSelf.listData + userModels
                        weakSelf.tableView.reloadData()
                        self?.tableView.mj_footer.endRefreshing()
                    }
                }
            } else {
                self?.tableView.mj_footer.endRefreshingWithWeakNetwork()
            }
        }
    }

    /// 显示占位图
    private func showOccupiedView(type: OccupiedType) {
        switch type {
        case .network:
            occupiedView.image = UIImage(named: "IMG_img_default_internet")
        case .empty:
            occupiedView.image = UIImage(named: "IMG_img_default_nobody")
        }
        if occupiedView.superview == nil {
            tableView.addSubview(occupiedView)
        }
    }

    // MARK: - tableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userId = self.listData[indexPath.row].userIdentity
        let userHomPage = TSHomepageVC(userId)
        navigationController?.pushViewController(userHomPage, animated: true)
    }

    // MAKR: - cell delegate
    override func cell(_ cell: TSTableViewCell, operateBtn: TSButton, indexPathRow: NSInteger) {
        let userInfo = self.listData[indexPathRow]
        userInfo.follower = !userInfo.follower
        self.listData[indexPathRow] = userInfo
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .none)
        TSUserNetworkingManager().operate(userInfo.follower == true ? .follow : .unfollow, userID: userInfo.userIdentity)
    }
}
