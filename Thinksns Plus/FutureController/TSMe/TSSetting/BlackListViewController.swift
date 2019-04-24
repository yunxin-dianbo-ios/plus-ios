//
//  BlackListViewController.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/4/19.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
//  黑名单

import UIKit

class BlackListViewController: TSRankingListTableViewController {

    // MARK: - Lifecycle
    init() {
        super.init(cellType: .blackListCell)
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
        self.title = "黑名单"
        self.tableView.mj_header.beginRefreshing()
    }

    // MARK: - process refresh
    override func refresh() {
        var request = UserNetworkRequest().blackList
        request.urlPath = request.fullPathWith(replacers: [])
        RequestNetworkData.share.text(request: request) { [weak self] (result) in
            self?.occupiedView.removeFromSuperview()
            switch result {
            case .error(_), .failure(_):
                self?.showOccupiedView(type: .network)
                self?.tableView.mj_header.endRefreshing()
            case .success(let response):
                self?.tableView.mj_header.endRefreshing()
                if response.models.isEmpty {
                    self?.showOccupiedView(type: .empty)
                    return
                }
                self?.listData = response.models
                self?.tableView.reloadData()
            }
        }
    }

    override func loadMore() {
        if self.listData.count <= 0 {
            self.tableView.mj_footer.endRefreshing()
            return
        }
        var request = UserNetworkRequest().blackList
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["offset": self.listData.count]
        RequestNetworkData.share.text(request: request) { [weak self] (result) in
            guard let `self` = self else {
                return
            }
            self.occupiedView.removeFromSuperview()
            switch result {
            case .error(_), .failure(_):
                self.tableView.mj_footer.endRefreshingWithWeakNetwork()
            case .success(let response):
                self.tableView.mj_footer.endRefreshing()
                if response.models.isEmpty {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    return
                }
                if response.models.count < self.showFootDataCount {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                self.listData = self.listData + response.models
                self.tableView.reloadData()
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
        let id = self.listData[indexPathRow].userIdentity
        self.listData.remove(at: indexPathRow)
        self.tableView.reloadData()
        var request = UserNetworkRequest().deleteBlackList
        request.urlPath = request.fullPathWith(replacers: ["\(id)"])
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                let indicator = TSIndicatorWindowTop(state: .faild, title: "网络错误，请稍后再试")
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .failure(let response):
                var errorMessage = "网络错误，请稍后再试"
                if let message = response.message {
                    errorMessage = message
                }
                let indicator = TSIndicatorWindowTop(state: .faild, title: errorMessage)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .success(_):
                break
            }
        }
    }
}
