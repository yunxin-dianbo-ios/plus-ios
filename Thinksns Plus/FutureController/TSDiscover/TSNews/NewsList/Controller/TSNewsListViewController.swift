//
//  TSNewsListViewController.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  资讯列表界面

import UIKit
import RealmSwift

typealias NewsModels = [NewsModel]

class TSNewsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    /// 父控制器 （用于获取navigationBar的高度）
    ///
    /// 列表内广告的广告数据也记录在父控制器
    weak var rootViewController: TSNewsRootViewController!
    /// 列表
    let listTableView = UITableView()
    /// 缺省图
    private var occupiedView: UIImageView? = nil
    /// 栏目id 等于-1时是自定义的推荐
    var tagID: Int = -2
    /// 轮播控件
    var banner: TSAdvertBanners?
    /// 数据源
    ///
    /// - Note: 第一个元素是 置顶数据,第二个元素是资讯数据
    var dataSource: [NewsModels] = []
    /// 分页标记（最后一条资讯的id）
    var maxID: Int = 0
    /// 缺省图
    enum OccupiedType {
        case network
        case empty
    }

    // MARK: - lifeCycle
    init(rootViewController: TSNewsRootViewController) {
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
        listTableView.mj_header.beginRefreshing()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        banner?.startAnimation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        banner?.stopAnimation()
    }

    // MARK: - AD
    func setupTopBannerAD() {
        // 1.只有推荐才有广告
        if tagID != -1 {
            return
        }
        /// 广告 Banner
        let banner = TSAdvertBanners(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 2))
        // 2.获取 banner 的广告
        let bannerAdverts = TSDatabaseManager().advert.getObjects(type: .newsListTop)
        if bannerAdverts.isEmpty {
            return
        }
        banner.setModels(models: bannerAdverts.map { TSAdvertBannerModel(object: $0) })
        listTableView.tableHeaderView = banner
        self.banner = banner
    }

    // MARK: - UI
    /// 对主要的控件做基本布局
    func layoutBaseControlls() {
        let navigationBarHeight = (self.rootViewController?.navigationController?.navigationBar.frame.height)! + 20
        self.listTableView.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: ScreenSize.ScreenHeight - TSNewsTagButtonUX.buttonHeight - navigationBarHeight)
        self.listTableView.backgroundColor = .clear
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        self.listTableView.tableFooterView = UIView()
        self.listTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.listTableView.showsVerticalScrollIndicator = false
        self.listTableView.estimatedRowHeight = 95
        self.listTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.listTableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.listTableView.mj_footer.isHidden = true
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
        if !dataSource.isEmpty {
            let count = dataSource[0].count + dataSource[1].count
            if !count.isEqualZero {
                occupiedView?.removeFromSuperview()
            }
        }
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
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
        let model = dataSource[indexPath.section][indexPath.row]
        // 判断是否是推荐资讯：推荐资讯，则显示栏目标签；不是推荐类是自己的栏目类，则不需显示栏目标签
        // 注：应先配置showCategoryFlag，再加载数据cellData
        cell?.showCategoryFlag = (-1 == self.tagID) ? true : false
        cell!.cellData = model
        if model.isAd == false {
            let isRead = TSCurrentUserInfo.share.newsViewStatus.isContains(newsId: model.id)
            cell!.updateCellStyle(isSelected: isRead)
        }
        return cell!
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isLogin = TSCurrentUserInfo.share.isLogin
        if isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        let newsModel = dataSource[indexPath.section][indexPath.row]
        if newsModel.isAd {
            // 广告
            TSAdvertTaskQueue.showDetailVC(urlString: newsModel.adUrl)
        } else {
            // 资讯
            let newsDetailVC = TSNewsDetailViewController(newsId: newsModel.id)
            TSCurrentUserInfo.share.newsViewStatus.addViewed(newsId: newsModel.id)
            self.listTableView.reloadRows(at: [indexPath], with: .none)
            self.navigationController?.pushViewController(newsDetailVC, animated: true)
        }
    }

    // MARK: - add ad
    /// 在动态数据最后添加广告
    func addListAdverts() {
        // 非推荐栏目不显示广告
        if self.tagID != -1 {
            return
        }
        // 2.过滤 dataSource 为空的情况
        if dataSource.isEmpty {
            return
        }
        // 3.判断还有没有“没有显示的”广告
        if rootViewController.advertObjects.isEmpty {
            return
        }
        // 4.如果有，取出第一个广告,再更换广告的顺序
        let removeAdvertObject = rootViewController.advertObjects.removeFirst()
        rootViewController.advertObjects.append(removeAdvertObject)
        // 5.将广告 object 转换成动态的 cellModel，并设置其分页标识和最后一条动态相等
        let newsADModel = NewsModel(advertObject: removeAdvertObject)
        newsADModel.id = dataSource[1].last?.id ?? 0
        // 6.将广告添加到动态中
        dataSource[1].append(newsADModel)
    }

    // MARK: - refreshDelegate
    func refresh() {
        let isLogin = TSCurrentUserInfo.share.isLogin
        if isLogin == false && !dataSource.isEmpty {
            TSRootViewController.share.guestJoinLoginVC()
            self.listTableView.mj_header.endRefreshing()
            return
        }
        TSNewsTaskManager().refreshNewsListData(tagID: tagID) { [weak self] (news, _) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.listTableView.mj_header.endRefreshing()
            guard let news = news else {
                // [长期注释] 查询数据库,数据库来决定是否显示空页面
                weakSelf.showOccupiedView(.network)
                return
            }
            weakSelf.dataSource = news
            let newsCount = news[0].count + news[1].count
            if newsCount <= 0 {
                weakSelf.showOccupiedView(OccupiedType.empty)
            } else {
                // 添加一条广告
                weakSelf.setupTopBannerAD()
                weakSelf.addListAdverts()
            }
            weakSelf.listTableView.mj_footer.isHidden = newsCount >= TSAppConfig.share.localInfo.limit ? false : true
            weakSelf.listTableView.mj_footer.resetNoMoreData()
            if newsCount > 0 {
                // [长期注释] 更新数据库
            }
            /// 刷新列表数据
            weakSelf.listTableView.reloadData()
        }
    }

    func loadMore() {
        let isLogin = TSCurrentUserInfo.share.isLogin
        if isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            self.listTableView.mj_footer.endRefreshing()
            return
        }
        // 能上拉刷新一定是有资讯信息和数据的
        self.maxID = dataSource[1].last!.id
        /// 获取更多的资讯信息加入到列表
        TSNewsTaskManager().loadMoreNewsListData(tagID: tagID, maxID: maxID) { [weak self] (newsModels, _) in
            guard let weakSelf = self else {
                return
            }
            guard let newsModels = newsModels else {
                weakSelf.showOccupiedView( .network)
                return
            }
            if newsModels.count >= 15 {
                weakSelf.listTableView.mj_footer.endRefreshing()
            } else {
                weakSelf.listTableView.mj_footer.endRefreshingWithNoMoreData()
            }
            weakSelf.dataSource[1] += newsModels
            if newsModels.isEmpty == false {
                // 添加一条广告
                weakSelf.addListAdverts()
            }
            /// 刷新列表数据
            weakSelf.listTableView.reloadData()
        }
    }
}
