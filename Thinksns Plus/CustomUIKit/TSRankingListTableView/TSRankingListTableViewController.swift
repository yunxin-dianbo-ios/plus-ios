//
//  TSRankingListTableViewController.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSRankingListTableViewController: TSTableViewController, AbstractRankingListTableViewCellDelegate {

    private let identifier = "cell"
    enum AllKindsOfCell {
        /// 个人中心关注列表
        case concernCell
        /// 个人中心点赞排行列表
        case likeCell
        /// 动态点赞榜
        case momentLikeCell
        /// 黑名单列表
        case blackListCell
    }

    /// cell的高度
    enum CellHeight: CGFloat {
        case shortCellHeight = 70.0
        case highCellHeight = 90.0
    }
    /// 展示底部视图的数量
    let showFootDataCount = 15

    var listData: Array<TSUserInfoModel> = Array()
    var cellHeight: CGFloat!
    var cellType: AllKindsOfCell = .concernCell
    var useUserId = 0
    var isEnabledHeaderButton: Bool = true
    init(cellType: AllKindsOfCell) {
        super.init(style: .plain)
        self.cellType = cellType
        self.tableView.register(AbstractRankingListTableViewCell.self, forCellReuseIdentifier: identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        switch cellType {
        case .momentLikeCell, .concernCell:
            self.cellHeight = CellHeight.shortCellHeight.rawValue
        case .blackListCell:
            self.cellHeight = 70
        default:
            self.cellHeight = CellHeight.highCellHeight.rawValue
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - tableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.mj_footer != nil {
            tableView.mj_footer.isHidden = self.listData.count < showFootDataCount
        }
        return listData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AbstractRankingListTableViewCell!
        switch cellType {
        case .concernCell:
            cell = ConcernRankingListTableViewCellTableViewCell(style: .default, reuseIdentifier: identifier, userInfo: listData[indexPath.row])
        case .likeCell:
            cell = LikeRankingListTableViewCell(style: .default, reuseIdentifier: identifier, userInfo: listData[indexPath.row])
        case .momentLikeCell:
            cell = MomentLikeCell(style: .default, reuseIdentifier: identifier, userInfo: listData[indexPath.row])
        case .blackListCell:
            cell = BlackListCell(style: .default, reuseIdentifier: identifier, userInfo: listData[indexPath.row])
        }
        if useUserId != (TSCurrentUserInfo.share.userInfo?.userIdentity)! {
            cell.praiseButton?.isHidden = true
        }
        cell.isEnabledHeaderButton(isEnabled: isEnabledHeaderButton)
        cell.delegate = self
        cell.userInfo = listData[indexPath.row]
        cell.indexPathRow = indexPath.row

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight!
    }

    // MARK: - didSelectRow
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    // MARK: delegate
    // 抽象方法需要子类实现
    func cell(_ cell: TSTableViewCell, operateBtn: TSButton, indexPathRow: NSInteger) {
    }
    // 抽象方法需要子类实现
    override func refresh() {
    }
    // 抽象方法需要子类实现
    override func loadMore() {
    }
}
