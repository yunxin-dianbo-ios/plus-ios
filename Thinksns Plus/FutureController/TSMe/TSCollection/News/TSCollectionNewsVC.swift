//
//  TSCollectionNewsVC.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSCollectionNewsVC: TSViewController, UITableViewDelegate, UITableViewDataSource {

    /// 缺省图
    private enum OccupiedType {
        case network
        case empty
    }

    /// 父控制器 （用于获取navigationBar的高度）
    var rootViewController: TSCollectionVC? = nil
    /// 列表
    let listTableView = UITableView()
    /// 缺省图
    private var occupiedView: UIImageView? = nil
    /*---------数据相关--------*/
    /// 栏目id
    var tagID: Int = -1
    /// 列表数据
    var newsDataArray: [NewsModel] = []
    /// 分页标记（最后一条资讯的id）
    var maxID: Int = 0
    var limit: Int = TSAppConfig.share.localInfo.limit
    var isRefreshing: Bool = false

    // MARK: - lifeCycle
    init(rootViewController: TSCollectionVC) {
        super.init(nibName: nil, bundle: nil)
        self.rootViewController = rootViewController
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TSColor.inconspicuous.background
        self.layoutBaseControlls()
        self.listTableView.mj_header.beginRefreshing()
    }

    // MARK: - UI

    /// 对主要的控件做基本布局
    func layoutBaseControlls() {
        self.listTableView.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: ScreenSize.ScreenHeight - TSNewsTagButtonUX.buttonHeight - TSNavigationBarHeight)
        self.listTableView.backgroundColor = .clear
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        self.listTableView.tableFooterView = UIView()
        self.listTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.listTableView.showsVerticalScrollIndicator = false
        self.listTableView.estimatedRowHeight = 95
        self.listTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.listTableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.view.addSubview(self.listTableView)
        /// 缺省图
        self.occupiedView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.listTableView.frame.width, height: self.listTableView.frame.height))
        self.occupiedView?.contentMode = UIViewContentMode.center
        self.occupiedView?.backgroundColor = .clear
    }

    /// 显示缺省图
    ///
    /// - Parameter type: 缺省图显示类型
    private func showOccupiedView(_ type: OccupiedType) {
        switch type {
        case .network:
            self.occupiedView?.image = UIImage(named: "IMG_img_default_internet")
        case .empty:
            self.occupiedView?.image = UIImage(named: "IMG_img_default_nothing")
        }
        if self.occupiedView?.superview == nil {
            self.listTableView.addSubview(self.occupiedView!)
        }
        if !self.newsDataArray.isEmpty && self.occupiedView?.superview != nil {
            self.occupiedView?.removeFromSuperview()
        }
    }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsDataArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ListCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? TSNewsListCell
        if cell == nil {
            cell = TSNewsListCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        cell?.showCategoryFlag = false
        let model = newsDataArray[indexPath.row]
        cell!.cellData = model
        let isRead = TSCurrentUserInfo.share.newsViewStatus.isContains(newsId: model.id)
        cell!.updateCellStyle(isSelected: isRead)
        return cell!
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let newsObject = self.newsDataArray[indexPath.row]
        let newsDetailVC = TSNewsDetailViewController(newsId: newsObject.id)
        TSCurrentUserInfo.share.newsViewStatus.addViewed(newsId: newsObject.id)
        self.listTableView.reloadRows(at: [indexPath], with: .none)
        self.navigationController?.pushViewController(newsDetailVC, animated: true)
    }

    // MARK: - refreshDelegate
    func refresh() {
        self.maxID = 0
        TSNewsNetworkManager().request(conllectionNews: self.maxID, limit: self.limit) { [weak self] (newsModel, error) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.isRefreshing = false
            weakSelf.listTableView.mj_header.endRefreshing()
            // 网络失败
            if error != nil {
                weakSelf.showOccupiedView(.network)
                return
            }
            weakSelf.newsDataArray = newsModel!
            // 没有数据
            if (newsModel?.isEmpty)! {
                weakSelf.showOccupiedView(.empty)
                weakSelf.listTableView.mj_footer.isHidden = true
            } else {
                // 有数据
                weakSelf.listTableView.reloadData()
                // 更换页数
                weakSelf.maxID = weakSelf.newsDataArray.last!.id
                weakSelf.listTableView.mj_footer.isHidden = newsModel!.count >= weakSelf.limit ? false : true
            }
            if weakSelf.listTableView.mj_header.isRefreshing() {
                weakSelf.listTableView.mj_header.endRefreshing()
            }
            weakSelf.listTableView.reloadData()
        }
    }

    func loadMore() {
        if newsDataArray.isEmpty {
            listTableView.mj_footer.endRefreshing()
            return
        }

        TSNewsNetworkManager().request(conllectionNews: self.maxID, limit: self.limit) { [weak self] (newsModel, error) in
            guard let weakSelf = self else {
                return
            }
            // 网络失败
            if error != nil {
                weakSelf.listTableView.mj_footer.endRefreshingWithWeakNetwork()
                return
            }
            // 没有数据
            if newsModel!.count < weakSelf.limit {
                weakSelf.listTableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            // 有数据
            weakSelf.newsDataArray = weakSelf.newsDataArray + newsModel!
            weakSelf.listTableView.reloadData()
            weakSelf.listTableView.mj_footer.endRefreshing()
            // 更换页数
            weakSelf.maxID = weakSelf.newsDataArray.last!.id
        }
    }

    // MARK: - other
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
