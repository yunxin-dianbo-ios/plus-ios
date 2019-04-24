//
//  TSContributedNewsDetailVC.swift
//  ThinkSNS +
//
//  Created by 小唐 on 10/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  已投稿(已发布)的资讯详情模型
//
//  注：该文件主要用来测试如何使用TSNewsDetailView的normal状态，作为优化TSNewsDetailViewController的参考

import Foundation
import UIKit

class TSContributedNewsDetailVC: TSViewController {
    // MARK: - Internal Property
    let newsId: Int
    // MARK: - Internal Function
    // MARK: - Private Property

    fileprivate weak var tableView: UITableView!
    /// 资讯详情视图
    fileprivate weak var newsDetailView: TSNewsDetailView!

    /// 资讯详情 模型
    fileprivate var newsDetail: NewsDetailModel?

    // MARK: - Initialize Function

    init(newsId: Int) {
        self.newsId = newsId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }

}

// MARK: - UI

extension TSContributedNewsDetailVC {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        self.view.backgroundColor = UIColor.white
        // 1. navigation bar
        self.navigationItem.title = "资讯详情"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backItemClick))
        // 2. tableView
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_footer.isHidden = true
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.tableView = tableView
        // 3. newsDetailView
        let newsDetailView = TSNewsDetailView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenWidth), type: .normal)
        tableView.tableHeaderView = newsDetailView
        newsDetailView.delegate = self
        self.newsDetailView = newsDetailView
    }
}

// MARK: - 数据处理与加载

extension TSContributedNewsDetailVC {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        self.requestData(.initial)
    }
    /// 下拉刷新
    @objc fileprivate func refresh() -> Void {
        self.requestData(.refresh)
    }
    /// 上拉加载更多
    @objc fileprivate func loadMore() -> Void {
        self.requestData(.loadmore)
    }
    /// 请求数据
    fileprivate func requestData(_ type: TSListDataLoadType) -> Void {
        switch type {
        case .initial:
            self.loading()
            fallthrough
        case .refresh:
            // 请求点赞列表、请求打赏列表、请求打赏总数
            self.newsDetailView.loadExtraData(with: self.newsId)
            // 请求详情页数据
            TSNewsNetworkManager().requesetNews(newsID: self.newsId) { [weak self](newsDetailModel, _, code) in
                if code == 404 {
                    self?.loadFaild(type: .delete)
                    return
                }
                guard let newsDetailModel = newsDetailModel else {
                    switch type {
                    case .initial:
                        self?.endLoading()
                        self?.loadFaild(type: .network)
                    case .refresh:
                        self?.tableView.mj_header.endRefreshing()
                    default:
                        break
                    }
                    return
                }
                // 加载markdown
                newsDetailModel.title = newsDetailModel.title + "这是一个最好的时代，也是一个最坏的时代！"
                self?.newsDetail = newsDetailModel
                self?.newsDetailView.loadModel(newsDetailModel, complete: { (height) in
                    switch type {
                    case .initial:
                        self?.endLoading()
                    case .refresh:
                        self?.tableView.mj_header.endRefreshing()
                    default:
                        break
                    }
                    self?.newsDetailView.bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: height)
                    self?.tableView.reloadData()
                })
            }
        case .loadmore:
            self.tableView.mj_footer.endRefreshing()
        }
    }

}

// MARK: - 事件响应

extension TSContributedNewsDetailVC {
    @objc fileprivate func backItemClick() -> Void {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - TSNewsDetailViewProtocol

// 答案详情页的视图响应回调
extension TSContributedNewsDetailVC: TSNewsDetailViewProtocol {
    // 打赏按钮点击响应
    func newsDetailView(_ newsDetailView: TSNewsDetailView, didClickRewardBtn rewardBtn: UIButton) -> Void {
        // 进入打赏界面
        let rewardVC = TSChoosePriceVCViewController(type: .news)
        rewardVC.sourceId = self.newsId
        self.navigationController?.pushViewController(rewardVC, animated: true)
    }
    // 打赏列表点击响应
    func didClickRewardListIn(newsDetailView: TSNewsDetailView) -> Void {
        let rewardListVC = TSRewardListVC.list(type: .news)
        rewardListVC.rewardId = self.newsId
        self.navigationController?.pushViewController(rewardListVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension TSContributedNewsDetailVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }

        cell?.textLabel?.text = "Just Test"
        //cell?.selectionStyle = .none

        return cell!
    }
}

// MARK: - UITableViewDelegate

extension TSContributedNewsDetailVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt\(indexPath.row)")
    }

}
