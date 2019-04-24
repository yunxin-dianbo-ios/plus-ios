//
//  TopicSearchVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/24.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Alamofire

class TopicSearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    /// 搜索框
    @IBOutlet weak var searchbarView: TSSearchBarView!
    /// 列表
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchBarTC: NSLayoutConstraint!
    /// 占位图
    let occupiedView = UIImageView()
    /// 上一个联想请求
    private var lastRequest: DataRequest?
    /// 当前搜索页面是正常的搜索话题还是发布动态时候搜索话题：正常搜索点击话题跳转话题详情页，发布时候搜索是发通知返回对应话题信息（TopicListModel）
    var jumpType = "normal"
    /// 数据源
    var dataSource: [TopicListModel] = []
    /// 搜索关键词
    var keyword = ""
    /// 是否是第一次自动搜索（增加这个属性的原因：参见#1418 后台若没有推荐用户，刚进入搜索页时应该显示空白页，不应该显示缺省图）
    var firstLoad = true

    // MARK: - Lifecycle
    class func vc() -> TopicSearchVC {
        let vc = UIStoryboard(name: "TopicSearchVC", bundle: nil).instantiateInitialViewController() as! TopicSearchVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldValueChanged(notice:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        setUI()
        // 更新搜索框到顶部的约束
        self.searchBarTC.constant = TSUserInterfacePrinciples.share.getTSLiuhaiHeight()
        self.updateViewConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    // MARK: - Custom user interface
    func setUI() {
        // table
        tableview.rowHeight = 50
        tableview.separatorStyle = .none
        tableview.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableview.mj_header = nil
        tableview.register(UINib(nibName: "TopicSearchCell", bundle: nil), forCellReuseIdentifier: TopicSearchCell.identifier)
        // 搜索框
        searchbarView.rightButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        searchbarView.searchTextFiled.placeholder = "搜索"
        searchbarView.searchTextFiled.returnKeyType = .search
        searchbarView.searchTextFiled.delegate = self
        // 占位图
        occupiedView.backgroundColor = UIColor.white
        occupiedView.contentMode = .center

        // 让搜索框加载后台推荐用户，让用户一进这个页面就有东西看
       let _ = textFieldShouldReturn(searchbarView.searchTextFiled)
    }

    func dismissVC() {
        navigationController?.popViewController(animated: true)
    }

    /// 显示占位图
    func showOccupiedView(type: TSTableViewController.OccupiedType) {
        var image = ""
        switch type {
        case .empty:
            image = "IMG_img_default_search"
        case .network:
            image = "IMG_img_default_internet"
        }
        occupiedView.image = UIImage(named: image)
        if occupiedView.superview == nil {
            occupiedView.frame = tableview.bounds
            tableview.addSubview(occupiedView)
        }
    }

    func textFieldValueChanged(notice: Notification) {
        guard let textField = notice.object as? UITextField else {
            return
        }
        guard textField.markedTextRange == nil else {
            return
        }

        keyword = textField.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        lastRequest?.cancel()
        lastRequest = TSUserNetworkingManager().getTopicListThink(index: nil, keyWordString: keyword, limit: TSAppConfig.share.localInfo.limit, direction: nil, only: keyword == "" ? "hot" : nil) { (topicModel, networkError) in
            // 如果是第一次进入
            if self.firstLoad == true {
                self.firstLoad = false
                // 需求：如果第一次进入（自动刷新），获取后台推荐用户是空的，就显示空白页，不显示缺省图
                if topicModel?.isEmpty == true {
                    return
                }
            }
            self.processRefresh(datas: topicModel, message: networkError)
        }
    }

    // MARK: - Data
    /// 查询用户信息
    /// 搜索框传值，附带交互
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyword = searchbarView.searchTextFiled.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        view.endEditing(true)
        lastRequest?.cancel()
        lastRequest = TSUserNetworkingManager().getTopicListThink(index: nil, keyWordString: keyword, limit: TSAppConfig.share.localInfo.limit, direction: nil, only: keyword == "" ? "hot" : nil) { (topicModel, networkError) in
            // 如果是第一次进入
            if self.firstLoad == true {
                self.firstLoad = false
                // 需求：如果第一次进入（自动刷新），获取后台推荐用户是空的，就显示空白页，不显示缺省图
                if topicModel?.isEmpty == true {
                    return
                }
            }
            self.processRefresh(datas: topicModel, message: networkError)
        }
        return true
    }

    func processRefresh(datas: [TopicListModel]?, message: NetworkError?) {
        tableview.mj_footer.resetNoMoreData()
        // 获取数据成功
        if let datas = datas {
            dataSource = datas
            if dataSource.isEmpty {
                showOccupiedView(type: .empty)
            }
        }
        // 获取数据失败
        if message != nil && message != NetworkError.requestCanceled {
            dataSource = []
            showOccupiedView(type: .network)
        }
        tableview.reloadData()
    }

    func loadMore() {
        guard keyword != "", dataSource.count != 0 else {
            // 1.不输入搜索内容，显示的是后台推荐用户，后台推荐用户没有分页
            tableview.mj_footer.endRefreshingWithNoMoreData()
            return
        }

        TSUserNetworkingManager().getTopicList(index: dataSource.last?.topicId, keyWordString: keyword, limit: TSAppConfig.share.localInfo.limit, direction: nil, only: nil) { (topicModel, networkError) in
            guard let datas = topicModel else {
                self.tableview.mj_footer.endRefreshing()
                return
            }
            if datas.count < TSAppConfig.share.localInfo.limit {
                self.tableview.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.tableview.mj_footer.endRefreshing()
            }
            self.dataSource = self.dataSource + datas
            self.tableview.reloadData()
        }
    }

    // MARK: - Delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if keyword == "" {
            let headerViewBg = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 40))
            headerViewBg.backgroundColor = UIColor(hex: 0xf4f5f5)
            let sectionTitleL = UILabel(frame: CGRect(x: 15, y: 0, width: ScreenWidth - 15, height: 39))
            sectionTitleL.font = UIFont.systemFont(ofSize: 13)
            sectionTitleL.textColor = UIColor(hex: 0x999999)
            sectionTitleL.text = "热门话题"
            headerViewBg.addSubview(sectionTitleL)
            let lineView = UIView(frame: CGRect(x: 0, y: 39, width: ScreenWidth, height: 1))
            lineView.backgroundColor = TSColor.inconspicuous.disabled
            headerViewBg.addSubview(lineView)
            return headerViewBg
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if keyword == "" {
            return 40
        } else {
            return 0.001
        }
    }

    // MARK: UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableview.mj_footer.isHidden = dataSource.count < TSAppConfig.share.localInfo.limit
        if !dataSource.isEmpty {
            occupiedView.removeFromSuperview()
        }
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TopicSearchCell.identifier, for: indexPath) as! TopicSearchCell
        cell.setInfo(model: dataSource[indexPath.row], keyword: keyword)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if jumpType == "normal" {
            let postListVC = TopicPostListVC(groupId: dataSource[indexPath.row].topicId)
            navigationController?.pushViewController(postListVC, animated: true)
        } else {
            let model = dataSource[indexPath.row]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "passPublishTopicData"), object: nil, userInfo: ["topic": model])
            dismissVC()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
