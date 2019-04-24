//
//  RankListDetailController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  排行榜详情列表
//  注1：默认仅展示100名。在RankListDetailView中进行数据处理，即数量限定。

import UIKit

class RankListDetailController: TSViewController {

    /// 排行榜列表
    var rankListView: RankListDetailView!
    /// 排行榜类型
    var rankType: RankListManager.RankType!

    // MARK: - Lifecycle
    init(type: RankListManager.RankType) {
        super.init(nibName: nil, bundle: nil)
        rankType = type
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    // MARK: - UI
    func setUI() {
        title = rankType.rawValue
        // 排行榜列表
        rankListView = RankListDetailView(frame: view.bounds, tableIdentifier: rankType.rawValue)
        rankListView.interactionDelegate = self
        rankListView.refreshDelegate = self
        rankListView.rankNumberSpecialColors = [0: TSColor.main.theme, 1: TSColor.main.theme, 2: TSColor.main.theme]
        view = rankListView
    }
}

// MARK: - RankListDetailViewRefreshDelegate: 排行榜刷新代理事件
extension RankListDetailController: RankListDetailViewRefreshDelegate {
    /// 下拉刷新
    func rankDetailTable(_ table: RankListDetailView, refreshingDataOf tableIdentifier: String) {
        RankListManager.getRankList(rankType: rankType, offset: 0) { [weak self] (datas: [TSUserInfoModel]?, message: String?, status: Bool) in
            guard self != nil else {
                return
            }
            let newDatas = self?.process(userInfos: datas)
            table.processRefresh(data: newDatas, message: message, status: status)
        }
    }

    /// 上拉加载
    func rankDetailTable(_ table: RankListDetailView, loadMoreDataOf tableIdentifier: String) {
        RankListManager.getRankList(rankType: rankType, offset: table.datas.count) { [weak self] (datas: [TSUserInfoModel]?, message: String?, status: Bool) in
            guard self != nil else {
                return
            }
            let newDatas = self?.process(userInfos: datas)
            table.processloadMore(data: newDatas, message: message, status: status)
        }
    }

    /// 将 [TSUserInfoModel] 处理成 rankListView 可用的 datas
    func process(userInfos: [TSUserInfoModel]?) -> [Any]? {
        var datas: [Any]?
        guard let userInfos = userInfos else {
            return nil
        }

        // 1.如果是 财富达人/收入达人/社区专家 排行榜，使用 normal cell model 做为 datas
        let normalRankType: [RankListManager.RankType] = [.wealth, .income, .communityExperts]
        if normalRankType.contains(rankType) {
            datas = userInfos.map { RankListCellModel(userInfo: $0) }
        }

        // 除了上述 normalCellRankType 中包含的排行榜，其他排行榜使用 detail cell model 作为 datas

        // 2.如果是 今日/一周/本月 解答排行榜
        let answerRankTypes: [RankListManager.RankType] = [.answerToday, .answerWeek, .answerMonth]
        if answerRankTypes.contains(rankType) {
            datas = userInfos.map { RankListDetailCellModel(userInfo: $0, detailInfo: "回答量：\($0.extra?.count ?? 0)") }
        }

        // 3.如果是 今日/一周/本月 动态排行榜
        let feedsRankTypes: [RankListManager.RankType] = [.feedToday, .feedWeek, .feedMonth]
        if feedsRankTypes.contains(rankType) {
            datas = userInfos.map { RankListDetailCellModel(userInfo: $0, detailInfo: "点赞量：\($0.extra?.count ?? 0)") }
        }

        // 4.如果是 今日/一周/本月 资讯排行榜
        let newsRankTypes: [RankListManager.RankType] = [.newsToday, .newsWeek, .newsMonth]
        if newsRankTypes.contains(rankType) {
            datas = userInfos.map { RankListDetailCellModel(userInfo: $0, detailInfo: "浏览量：" + TSAppConfig.share.pageViewsString(number: ($0.extra?.count)!)) }
        }

        // 5.如果是全站粉丝排行榜
        if rankType == .fans {
            datas = userInfos.map { RankListDetailCellModel(userInfo: $0, detailInfo: "粉丝：\($0.extra?.count ?? 0)") }
        }

        // 6.如果是社区签到排行榜
        if rankType == .attendance {
            datas = userInfos.map { RankListDetailCellModel(userInfo: $0, detailInfo: "累计签到：\($0.extra?.checkinCount ?? 0)") }
        }

        // 7.如果是问答达人排行榜
        if rankType == .quoraExperts {
            datas = userInfos.map { RankListDetailCellModel(userInfo: $0, detailInfo: "问答点赞量：\($0.extra?.count ?? 0)") }
        }

        return datas
    }
}

// MARK: - RankListDetailViewDelegate: 排行榜交互代理事件
extension RankListDetailController: RankListDetailViewDelegate {
    /// 点击了 normal cell 上的关注按钮
    func rankDetailTable(_ table: RankListDetailView, didSelectedNormal cell: RankListCell, at indexPath: IndexPath) {
        // 1.判断是不是游客，如果是，跳转到登录界面
        guard TSCurrentUserInfo.share.isLogin == true else {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 2.发起关注操作
        guard let data = table.datas[indexPath.row] as? RankListCellModel else {
            return
        }
        data.userInfo.follower = !data.userInfo.follower
        table.datas[indexPath.row] = data
        table.reloadRows(at: [indexPath], with: .none)
        TSUserNetworkingManager().operate(data.userInfo.follower == true ? .follow : .unfollow, userID: data.userInfo.userIdentity)
    }

    /// 点击了 detail cell 上的关注按钮
    func rankDetailTable(_ table: RankListDetailView, didSelectedDetail cell: RankListDetailCell, at indexPath: IndexPath) {
        // 1.判断是不是游客，如果是，跳转到登录界面
        guard TSCurrentUserInfo.share.isLogin == true else {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 2.发起关注操作
        guard let data = table.datas[indexPath.row] as? RankListDetailCellModel else {
            return
        }
        data.userInfo.follower = !data.userInfo.follower
        table.datas[indexPath.row] = data
        table.reloadRows(at: [indexPath], with: .none)
        TSUserNetworkingManager().operate(data.userInfo.follower == true ? .follow : .unfollow, userID: data.userInfo.userIdentity)
    }

    /// 点击了cell的响应
    func rankDetailTable(_ table: RankListDetailView, didSelectedRankListCell cell: RankListCell, at indexPath: IndexPath) {
        // 1.判断是不是游客，如果是，跳转到登录界面
        guard TSCurrentUserInfo.share.isLogin == true else {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 进入用户详情界面
        guard let data = table.datas[indexPath.row] as? RankListDetailCellModel else {
            return
        }
        let userHomPage = TSHomepageVC(data.userInfo.userIdentity)
        self.navigationController?.pushViewController(userHomPage, animated: true)
    }
    func rankDetailTable(_ table: RankListDetailView, didSelectedRankListDetailCell cell: RankListDetailCell, at indexPath: IndexPath) {
        // 1.判断是不是游客，如果是，跳转到登录界面
        guard TSCurrentUserInfo.share.isLogin == true else {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 进入用户详情界面
        guard let data = table.datas[indexPath.row] as? RankListDetailCellModel else {
            return
        }
        let userHomPage = TSHomepageVC(data.userInfo.userIdentity)
        self.navigationController?.pushViewController(userHomPage, animated: true)
    }
}
