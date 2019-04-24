//
//  TSLikeListTableVCTableViewController.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  点赞列表控制器
//  注：该界面应完全自定义，而不是考虑继承。那边写的乱七八糟的，反而不利于维护和自定义扩展。

import UIKit

typealias TSLikeListType = TSFavorTargetType

class TSLikeListTableVC: TSRankingListTableViewController {
    /// 点赞用户列表
    var likeUserModels: [TSLikeUserModel] = []
    /// 是否是下拉刷新
    var isRefresh = false
    /// 点赞列表类型
    let type: TSLikeListType
    /// 点赞资源id
    let sourceId: Int
    /// 请求列表中最后一个的id
    var lastId: Int = 0
    /// 请求条数限制
    let limit: Int = TSAppConfig.share.localInfo.limit

    // MARK: - Lifecycle
    /// 注：圈子的点赞列表需传入groupId
    init(type: TSLikeListType, sourceId: Int) {
        self.type = type
        self.sourceId = sourceId
        super.init(cellType: .momentLikeCell)
        self.isEnabledHeaderButton = false
        self.useUserId = (TSCurrentUserInfo.share.userInfo?.userIdentity)!
        self.title = "点赞列表"
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.mj_header.beginRefreshing()
    }

    // MARK: - refresh
    override func refresh() {
        self.requestData(.refresh)
    }

    override func loadMore() {
        self.requestData(.loadmore)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userId = self.listData[indexPath.row].userIdentity
        let userHomPage = TSHomepageVC(userId)
        navigationController?.pushViewController(userHomPage, animated: true)
    }

    override func cell(_ cell: TSTableViewCell, operateBtn: TSButton, indexPathRow: NSInteger) {
        let userModel = listData[indexPathRow]
        userModel.follower = !userModel.follower
        listData[indexPathRow] = userModel
        var followStatus = FollowStatus.follow
        if userModel.follower == true {
            followStatus = .follow
        } else {
            followStatus = .unfollow
        }
        TSUserNetworkingManager().operate(followStatus, userID: userModel.userIdentity)
        self.tableView.reloadData()
        // 用这个来改变用户按钮的样式
        self.tableView.setNeedsLayout()
    }

}

extension TSLikeListTableVC {
    func requestData(_ loadType: TSListDataLoadType) -> Void {
        switch loadType {
        case .initial:
            fallthrough
        case .refresh:
            self.lastId = 0
            TSFavorNetworkManager.favorList(targetId: self.sourceId, targetType: self.type, afterId: 0, limit: self.limit, complete: { [weak self](likeList, msg, status) in
                switch loadType {
                case .refresh:
                    self?.tableView.mj_header.endRefreshing()
                default:
                    break
                }
                // 网络请求失败处理
                guard status, let likeList = likeList else {
                    self?.showOccupiedView(.network, isDataSourceEmpty: false)
                    return
                }
                // 列表为空处理
                if likeList.isEmpty {
                    self?.showOccupiedView(.empty, isDataSourceEmpty: true)
                    return
                } else {
                    self?.lastId = likeList.last!.id
                    self?.occupiedView.removeFromSuperview()
                }
                /// 正常数据处理
                self?.likeUserModels = likeList
                var userList = [TSUserInfoModel]()
                for likeUser in likeList {
                    userList.append(likeUser.userDetail)
                }
                self?.listData = userList
                //self?.dismissIndicatorA()
                self?.tableView.reloadData()
            })
        case .loadmore:
            TSFavorNetworkManager.favorList(targetId: self.sourceId, targetType: self.type, afterId: self.lastId, limit: self.limit, complete: { [weak self](likeList, _, status) in
                guard let WeakSelf = self else {
                    return
                }
                switch loadType {
                case .refresh:
                    self?.tableView.mj_footer.endRefreshing()
                default:
                    break
                }
                // 网络请求失败处理
                guard status, let likeList = likeList else {
                    self?.showOccupiedView(.network, isDataSourceEmpty: false)
                    return
                }
                // 列表为空处理
                if likeList.isEmpty {
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                    return
                } else {
                    self?.lastId = likeList.last!.id
                }
                /// 正常数据处理
                WeakSelf.likeUserModels += likeList
                var userList = [TSUserInfoModel]()
                for likeUser in WeakSelf.likeUserModels {
                    userList.append(likeUser.userDetail)
                }
                self?.listData = userList
                self?.tableView.reloadData()
            })
        }
    }
}
