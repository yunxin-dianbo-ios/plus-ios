//
//  TSNewFriendsSearchVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

private let HeaderIndentifier = "RecommendResableView"

class TSNewFriendsSearchVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    /// 搜索框
    @IBOutlet weak var searchbarView: TSSearchBarView!
    ///列表
    @IBOutlet weak var collectionView: UICollectionView!
    /// 占位图
    let occupiedView = UIImageView()
    ///列表tableView
    @IBOutlet weak var tableView: UITableView!
    /// 数据源
    var dataSource: [TSUserInfoModel] = []
    /// 搜索关键词
    var keyword = ""
    /// 是否是第一次自动搜索（增加这个属性的原因：参见#1418 后台若没有推荐用户，刚进入搜索页时应该显示空白页，不应该显示缺省图）
    var firstLoad = true
    /// 只搜索好友
    var isJustSearchFriends: Bool?
    // MARK: - Lifecycle

    class func vc() -> TSNewFriendsSearchVC {
        let vc = UIStoryboard(name: "TSNewFriendsSearchVC", bundle: nil).instantiateInitialViewController() as! TSNewFriendsSearchVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()

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
        // collectionView
        collectionView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        collectionView.mj_header = nil
        collectionView.register(TSRecommendResableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderIndentifier)
         //tableview
        tableView.rowHeight = 77.5
        tableView.separatorStyle = .none
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_header = nil
        tableView.register(UINib(nibName: "TSNewFriendsCell", bundle: nil), forCellReuseIdentifier: TSNewFriendsCell.identifier)
        // 搜索框
        searchbarView.rightButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        searchbarView.searchTextFiled.placeholder = "搜索"
        searchbarView.searchTextFiled.returnKeyType = .search
        searchbarView.searchTextFiled.delegate = self
        searchbarView.searchTextFiled.becomeFirstResponder()

        // 占位图
        occupiedView.backgroundColor = UIColor.white
        occupiedView.contentMode = .center
        if self.isJustSearchFriends == true {
            searchbarView.searchTextFiled.becomeFirstResponder()
        } else {
            // 让搜索框加载后台推荐用户，让用户一进这个页面就有东西看
            textFieldShouldReturn(searchbarView.searchTextFiled)
        }
    }

    func dismissVC() {
        self.navigationController?.popViewController(animated: true)
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
            occupiedView.frame = collectionView.bounds
            collectionView.addSubview(occupiedView)
        }
    }

    // MARK: - Data

    /// 查询用户信息
    /// 搜索框传值，附带交互
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyword = searchbarView.searchTextFiled.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        self.view.bringSubview(toFront: tableView)
        if keyword.isEmpty {
            self.view.bringSubview(toFront: collectionView)
        }
        view.endEditing(true)
        if isJustSearchFriends == true {
            return self.searchFriends()
        } else {
            return self.searchUser()
        }
    }

    func processRefresh(datas: [TSUserInfoModel]?, message: String?) {
        collectionView.mj_footer.resetNoMoreData()
        // 获取数据成功
        if let datas = datas {
            dataSource = datas
            if dataSource.isEmpty {
                showOccupiedView(type: .empty)
            }
        }
        // 获取数据失败
        if message != nil {
            dataSource = []
            showOccupiedView(type: .network)
        }
        collectionView.reloadData()
        tableView.reloadData()
    }

    func loadMore() {
        if isJustSearchFriends == true {
            self.loadMoreSearchFriends()
        } else {
            self.loadMoreSearchUser()
        }
    }

    func loadMoreSearchUser() {
        guard keyword != "" else {
            // 1.不输入搜索内容，显示的是后台推荐用户，后台推荐用户没有分页
            collectionView.mj_footer.endRefreshingWithNoMoreData()
            return
        }
        TSNewFriendsNetworkManager.searchUsers(keyword: keyword, offset: dataSource.count) { [weak self] (datas: [TSUserInfoModel]?, _, _) in
            guard let weakSelf = self else {
                return
            }
            guard let datas = datas else {
                weakSelf.collectionView.mj_footer.endRefreshing()
                weakSelf.tableView.mj_footer.endRefreshing()
                return
            }
            if datas.count < TSNewFriendsNetworkManager.limit {
                weakSelf.collectionView.mj_footer.endRefreshingWithNoMoreData()
                weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                weakSelf.collectionView.mj_footer.endRefreshing()
                weakSelf.tableView.mj_footer.endRefreshing()
            }
            weakSelf.dataSource = weakSelf.dataSource + datas
            weakSelf.collectionView.reloadData()
            weakSelf.tableView.reloadData()
        }
    }

    func loadMoreSearchFriends() {
        TSUserNetworkingManager().friendList(offset: dataSource.count, keyWordString: keyword, complete: {(datas: [TSUserInfoModel]?, _) in
            guard let datas = datas else {
                self.collectionView.mj_footer.endRefreshing()
                return
            }
            if datas.count < TSNewFriendsNetworkManager.limit {
                self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.collectionView.mj_footer.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            }
            self.dataSource = self.dataSource + datas
            self.collectionView.reloadData()
            self.tableView.reloadData()
        })
    }

    func searchUser() -> Bool {
        // 1.不输入搜索内容，点击“搜索”，显示后台推荐用户
        guard keyword != "" else {
            TSNewFriendsNetworkManager.getRecommendsUsers(complete: { [weak self] (datas: [TSUserInfoModel]?, message: String?, _) in
                // 如果是第一次进入
                if self?.firstLoad == true {
                    self?.firstLoad = false
                    // 需求：如果第一次进入（自动刷新），获取后台推荐用户是空的，就显示空白页，不显示缺省图
                    if datas?.isEmpty == true {
                        return
                    }
                }
                self?.processRefresh(datas: datas, message: message)
            })
            return false
        }
        // 2.有搜索内容，展示与搜索内容相关的用户
        TSNewFriendsNetworkManager.searchUsers(keyword: keyword, offset: 0) { [weak self] (datas: [TSUserInfoModel]?, message: String?, _) in
            self?.processRefresh(datas: datas, message: message)
        }
        return true
    }
    func searchFriends() -> Bool {
        TSUserNetworkingManager().friendList(offset: nil, keyWordString: keyword, complete: { (userModels, networkError) in
            self.processRefresh(datas: userModels, message: nil)
        })
        return true
    }
    // MARK: - Delegate
    // MARK: UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.mj_footer.isHidden = dataSource.count < TSNewFriendsNetworkManager.limit
        if !dataSource.isEmpty {
            occupiedView.removeFromSuperview()
        }
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderIndentifier, for: indexPath) as! TSRecommendResableView
        return headerView
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TSNewFriendsCollectionViewCell", for: indexPath) as! TSNewFriendsCollectionViewCell
        if isJustSearchFriends == true {
            cell.setFriendInfo(model: dataSource[indexPath.row])
        } else {
            cell.setInfo(model: dataSource[indexPath.row])
        }
        return cell
    }
    /// MARK:UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(ScreenWidth / 2) - CGFloat(5), height: 70)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: ScreenSize.ScreenWidth, height: 40)
    }
      // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        // 头像默认点击事件
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": model.userIdentity])
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let model = dataSource[indexPath.row]
//        // 头像默认点击事件
//        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": model.userIdentity])
//    }

    // MARK: - TSMyFriendListCellDelegate
    func chatWithUserId(userId: Int, chatName: String) {
        if !EMClient.shared().isLoggedIn {
            let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
            appDeleguate.getHyPassword()
            return
        }
        let idSt: String = String(userId)
        let vc = ChatDetailViewController(conversationChatter: idSt, conversationType:EMConversationTypeChat)
        vc?.chatTitle = chatName
        navigationController?.pushViewController(vc!, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension TSNewFriendsSearchVC: UITableViewDelegate, UITableViewDataSource, TSNewFriendsCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       self.tableView.mj_footer.isHidden = dataSource.count < TSNewFriendsNetworkManager.limit
        if !dataSource.isEmpty {
            occupiedView.removeFromSuperview()
        }
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSNewFriendsCell.identifier, for: indexPath) as! TSNewFriendsCell
        cell.delegate = (self as TSNewFriendsCellDelegate)
        if isJustSearchFriends == true {
            cell.setFriendInfo(model: dataSource[indexPath.row])
        } else {
            cell.setInfo(model: dataSource[indexPath.row])
        }
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        // 头像默认点击事件
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": model.userIdentity])
    }
     //MARK: TSNewFriendsCellDelegate
        func cell(_ cell: TSNewFriendsCell, didSelectedFollowButton button: UIButton) {
            // 判断当前搜索的内容
            if self.isJustSearchFriends == true {
                let indexPath = self.tableView.indexPath(for: cell)!
                let userInfo = dataSource[indexPath.row]
                self.chatWithUserId(userId: userInfo.userIdentity, chatName: userInfo.name)
            } else {
                // 1.判断是否为游客模式
                if !TSCurrentUserInfo.share.isLogin {
                    // 如果是游客模式，拦截操作显示登录界面
                    TSRootViewController.share.guestJoinLoginVC()
                    return
                }
                // 2.进行关注操作
                let indexPath = self.tableView.indexPath(for: cell)!
                let userInfo = dataSource[indexPath.row]
                userInfo.follower = !userInfo.follower
                dataSource[indexPath.row] = userInfo
                self.tableView.reloadRows(at: [indexPath], with: .none)
                TSUserNetworkingManager().operate(userInfo.follower == true ? .follow : .unfollow, userID: userInfo.userIdentity)
            }
        }
}
