//
//  GroupListController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子列表页

import UIKit

class GroupHomeController: UIViewController {

    /// 广告视图
    var advertView: TSAdvertNormal!
    /// 列表
    let table = UITableView(frame: UIScreen.main.bounds, style: .plain)
    /// 导航栏右边视图
    let rightNavView = GroupListRightNavView()

    /// 数据
    var datas: [GroupListSectionViewModel] = []
    /// 圈子总数
    var groupsCount = 0

    /// 左上角的返回按钮是否返回到root界面。首页+号进入的发帖中选择加入圈子进入该页返回时该标记为true
    var popToRoot: Bool = false
    /// 广告内容
    var advertViewModels: [TSAdvertViewModel]!

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Group.joined, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loadData()
        setNotification()
    }

    init(popToRoot: Bool = false) {
        self.popToRoot = popToRoot
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    func setUI() {
        title = "圈子"

        // 1.广告视图
        loadAdvertView()

        // 2.列表
        view = table
        table.backgroundColor = TSColor.inconspicuous.background
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.register(GroupListCell.self, forCellReuseIdentifier: GroupListCell.identifier)
        table.register(UINib(nibName: "GroupHomeCountCell", bundle: nil), forCellReuseIdentifier: "GroupHomeCountCell")
        table.register(GroupListSectionView.self, forHeaderFooterViewReuseIdentifier: GroupListSectionView.identifier)

        // 2.1导航栏右边视图
        rightNavView.searchButton.addTarget(self, action: #selector(searchButtonTaped), for: .touchUpInside)
        rightNavView.buildButton.addTarget(self, action: #selector(buildButtonTaped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
        // 2.2 导航栏左侧按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backItemClick))
    }

    /// 加载广告视图
    func loadAdvertView() {
        // 1.从数据库获取广告数据
        let adverts = TSDatabaseManager().advert.getObjects(type: .groupHomeTop)
        if adverts.isEmpty {
            return
        }
        // 2.获取广告视图的 view model
        advertViewModels = adverts.map { TSAdvertViewModel(object: $0) }
        // 3.限制广告的显示数量
        let count = min(advertViewModels.count, 4)
        advertViewModels = Array(advertViewModels[0..<count])
        // 4.设置广告视图
        advertView = TSAdvertNormal(itemCount: count)
        advertView.set(models: advertViewModels)
        table.tableHeaderView = advertView
    }

    // MARK: - Action

    /// 点击了创建圈子按钮
    func buildButtonTaped() {
        // 游客触发登录
        if TSCurrentUserInfo.share.isLogin == false {
           TSRootViewController.share.guestJoinLoginVC()
           return
        }
        // 判断配置是否需要认证才可创建圈子，如果需要，检查用户是否已经经过了身份验证
        let verified = TSCurrentUserInfo.share.userInfo?.verified
        // 更新后台配置权限
        // 去认证
        let loadingAlertVC = TSIndicatorWindowTop(state: .loading, title: "提示信息_获取后台配置信息".localized)
        loadingAlertVC.show()
        TSRootViewController.share.updateLaunchConfigInfo { (status) in
            loadingAlertVC.dismiss()
            if status == true {
                let groupBuildNeedVerified = TSAppConfig.share.launchInfo?.groupBuildNeedVerified
                // 创建圈子需要认证，且还没有认证
                if groupBuildNeedVerified == true && nil == verified {
                    // 去认证
                    let alertVC = TSVerifyAlertController(title: "显示_提示".localized, message: "认证用户才能创建圈子，去认证？")
                    TSRootViewController.share.currentShowViewcontroller?.present(alertVC, animated: false, completion: nil)
                } else {
                    // 去创建圈子
                    let createVC = CreateGroupController.vc()
                    TSLogCenter.log.debug(createVC)
                    self.navigationController?.pushViewController(createVC, animated: true)
                }
            } else {
                // 网络不可用
                let resultAlert = TSIndicatorWindowTop(state: .faild, title: "提示信息_网络错误".localized)
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }

    /// 点击了搜索按钮
    func searchButtonTaped() {
        let searchVC = GroupSearchController()
        navigationController?.pushViewController(searchVC, animated: true)
    }

    /// 点击了左侧返回按钮
    @objc fileprivate func backItemClick() -> Void {
        if self.popToRoot {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Data
    func loadData() {
        let group = DispatchGroup()
        var results: (GroupsInfoModel?, [GroupListCellModel]?, [GroupListCellModel]?) = (nil, nil, nil)
        // 1.获取总的圈子数
        group.enter()
        GroupNetworkManager.getGroupsCount { (model, message, status) in
            results.0 = model
            group.leave()
        }

        // 2.获取我加入的圈子
        if TSCurrentUserInfo.share.isLogin {
            group.enter()
            GroupNetworkManager.getMyGroups(offset: 0) { (models, message, status) in
                var cellModels: [GroupListCellModel]?
                if let models = models {
                    cellModels = []
                    cellModels = models.map { GroupListCellModel(model: $0) }
                }
                results.1 = cellModels
                group.leave()
            }
        } else {
            results.1 = []
        }
        // 3.获取推荐的圈子
        group.enter()
        GroupNetworkManager.getRecommendGroups(offset: 0) { (models, message, status) in
            var cellModels: [GroupListCellModel]?
            if let models = models {
                cellModels = []
                cellModels = models.map { GroupListCellModel(model: $0) }
            }
            results.2 = cellModels
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            let (countInfo, mys, recommends) = results
            guard let count = countInfo?.count, let myGroups = mys, let recommendGroups = recommends else {
                return
            }
            self?.groupsCount = count
            // 处理我加入的圈子
            if !myGroups.isEmpty {
                let model = GroupListSectionViewModel()
                model.maxCount = 5
                model.rightType = .seeAll
                model.title = "我加入的"
                model.cellModels = myGroups
                self?.datas.append(model)
            } else {
                let model = GroupListSectionViewModel()
                model.maxCount = 5
                model.rightType = .seeAll
                model.title = "我加入的"
                model.cellModels = []
                self?.datas.append(model)
            }
            if !recommendGroups.isEmpty {
                let model = GroupListSectionViewModel()
                model.maxCount = 5
                model.rightType = .change
                model.title = "热门推荐"
                model.cellModels = recommendGroups
                self?.datas.append(model)
            }
            self?.table.reloadData()
        }
    }

    // MARK: - Notification
    func setNotification() {
        // 1.用户在其他页面，加入或退出了某个圈子
        NotificationCenter.default.addObserver(self, selector: #selector(processJoinedNotification(_:)), name: NSNotification.Name.Group.joined, object: nil)
    }

    /// 收到通知，处理用户加入或退出某个圈子
    func processJoinedNotification(_ noti: Notification) {
        // 1.解析通知中的数据
        guard let userInfo = noti.userInfo as? [String: Any], let isJoin = userInfo["isJoin"] as? Bool, let groupInfo = userInfo["groupInfo"] as? GroupListCellModel else {
            return
        }

        // 2.处理 "我加入的" 列表
        if isJoin {
            // 2.1 如果是加入了某个圈子，将该圈子增加在到"我加入的圈子"
            if let model = datas.first(where: { $0.title == "我加入的" }) {
                if let changeCellModel = model.cellModels.first(where: { $0.id == groupInfo.id }) {
                    changeCellModel.role = .member
                } else {
                    model.cellModels.insert(groupInfo, at: 0)
                }
            } else {
                let model = GroupListSectionViewModel()
                model.maxCount = 5
                model.rightType = .seeAll
                model.title = "我加入的"
                model.cellModels = [groupInfo]
                datas.insert(model, at: 0)
            }
        } else {
            // 2.2 如果退出了某个圈子，将该圈子从"我加入的圈子"中移除
            if let model = datas.first(where: { $0.title == "我加入的" }) {
                for (index, cellModel) in model.cellModels.enumerated() {
                    guard cellModel.id == groupInfo.id else {
                        continue
                    }
                    model.cellModels.remove(at: index)
                }
            }
        }

        // 3. 处理 "热门推荐" 列表
        if let model = datas.first(where: { $0.title == "热门推荐" }), let changeCellModel = model.cellModels.first(where: { $0.id == groupInfo.id }) {
            changeCellModel.role = isJoin ? .member : .unjoined
        }

        // 4.刷新列表
        table.reloadData()
    }
}

extension GroupHomeController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count + 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return min(5, datas[section - 1].cellModels.count)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 36
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        }
        return 91
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 5.0
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: GroupListSectionView.identifier) as! GroupListSectionView
        sectionView.delegate = self
        return sectionView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            return UIView()
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard section > 0, let sectionView = view as? GroupListSectionView else {
            return
        }
        sectionView.model = datas[section - 1]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupHomeCountCell", for: indexPath) as! GroupHomeCountCell
            cell.titleLabel.attributedText = NSMutableAttributedString.attributeStringWith(strings: ["\(groupsCount)", "个兴趣小组，等待你的加入！"], colors: [UIColor(hex: 0xf4504d), UIColor(hex: 0x999999)], fonts: [20, 12])
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupListCell.identifier, for: indexPath) as! GroupListCell
        cell.delegate = self
        let model = datas[indexPath.section - 1].cellModels[indexPath.row]
        cell.model = model
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // 1.点击了兴趣小组 cell，跳转到全部圈子
        if indexPath.section == 0 {
            let allGroupVC = AllGroupController()
            navigationController?.pushViewController(allGroupVC, animated: true)
            return
        }

        // 2.点击了某个圈子
        // 如果是没有加入的圈子，是不能进入帖子列表的
        let cellModel = datas[indexPath.section - 1].cellModels[indexPath.row]
        if cellModel.shouldPushDetail == false {
            if cellModel.role == .black {
                let alert = TSIndicatorWindowTop(state: .faild, title: "提示信息_圈子黑名单".localized)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            let previewVC = GroupPreviewVC()
            previewVC.groupId = cellModel.id
            navigationController?.pushViewController(previewVC, animated: true)

//            let alert = TSIndicatorWindowTop(state: .faild, title: "提示信息_圈子未加入不可查看".localized)
//            alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            return
        }

        let postListVC = GroupDetailVC(groupId: cellModel.id)
        navigationController?.pushViewController(postListVC, animated: true)
    }

}

// MARK: - section view 代理事件
extension GroupHomeController: GroupListSectionViewDelegate {

    /// 点击了 section view 最右边的按钮
    func groupListSectionView(_ view: GroupListSectionView, didSelectedRightButton type: GroupListSectionViewModel.RightType) {
        switch type {
        case .change:
            GroupNetworkManager.getRecommendGroups(type: "random", limit: TSAppConfig.share.localInfo.limit, offset: 0, complete: { [weak self] (models, message, status) in
                guard let models = models, let weakself = self else {
                    return
                }
                let cellModel = models.map { GroupListCellModel(model: $0) }
                for data in weakself.datas {
                    if data.title == "热门推荐" {
                        data.cellModels = cellModel
                        weakself.table.reloadData()
                    }
                }
            })
        case .seeAll:
            // 2.点击了“查看全部”，跳转到“我加入的圈子”视图
            // 如果没有关注的圈子，跳转到全部圈子
            // 如果有关注的圈子，跳转到关注的圈子
            if datas[0].cellModels.count > 0 {
                let jionGroupVC = JoinedGroupsController()
                navigationController?.pushViewController(jionGroupVC, animated: true)
            } else {
                let allGroupVC = AllGroupController()
                navigationController?.pushViewController(allGroupVC, animated: true)
            }
        }
    }
}

// MARK: - cell 代理事件
extension GroupHomeController: GroupListCellDelegate {

    /// 点击了加入按钮
    func groupListCellDidSelectedJoinButton(_ cell: GroupListCell) {
        // 如果是游客模式，触发登录注册操作
        if TSCurrentUserInfo.share.isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }

        let groupIndexPath = table.indexPath(for: cell)!
        let cellModel = datas[groupIndexPath.section - 1].cellModels[groupIndexPath.row]
        let groupId = cellModel.id

        // 1.如果是加入圈子，先判断是否是付费圈子，如果是，显示付费弹窗
        let mode = cellModel.mode
        if mode == "paid" {
            PaidManager.showPaidGroupAlert(price: Double(cellModel.joinMoney), groupId: groupId, groupMode: mode) {
                // 付费的圈子有审核时间，所以不需要立刻通知列表刷新界面
            }
            return
        }

        // 2.如果不是付费圈子，直接发起加入申请
        let alert = TSIndicatorWindowTop(state: .loading, title: "正在加入圈子")
        alert.show()
        cell.joinButton.isEnabled = false
        GroupNetworkManager.joinGroup(groupId: groupId, complete: { [weak self] (isSuccess, message) in
            alert.dismiss()
            cell.joinButton.isEnabled = true
            guard let weakself = self else {
                return
            }
            // 成功加入
            if isSuccess {
                let successAlert = TSIndicatorWindowTop(state: .success, title: message)
                successAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                // 非公开的圈子，需要审核时间，所以不能马上改变加入状态
                if cellModel.mode == "public" {
                    weakself.datas[groupIndexPath.section - 1].cellModels[groupIndexPath.row].role = .member
                    weakself.datas[groupIndexPath.section - 1].cellModels[groupIndexPath.row].joined = GroupJoinModel(JSONString: "{\"audit\":1}")
                    weakself.table.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name.Group.joined, object: nil, userInfo: ["isJoin": true, "groupInfo": weakself.datas[groupIndexPath.section - 1].cellModels[groupIndexPath.row]])
                }
            } else {
                // 加入失败
                let faildAlert = TSIndicatorWindowTop(state: .faild, title: message ?? "加入失败")
                faildAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        })
    }
}
