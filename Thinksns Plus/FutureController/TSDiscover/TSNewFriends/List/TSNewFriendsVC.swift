//
//  TSNewFriendsVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSNewFriendsVC: UIViewController {

    enum UserType {
        /// 热门用户
        case hot
        /// 最新用户
        case new
        /// 推荐用户
        case recommend
        /// 附近
        case nearby
    }

    /// 城市选择按钮
    @IBOutlet weak var buttonForCity: UIButton!
    /// 类别标签视图
    @IBOutlet weak var labelView: TSTopLabelView!
    /// 滚动视图
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var backBtn: UIButton!
    /// 定位管理类。这里偷懒，不想单独写定位，故用已经写好的具有定位功能的视图作为管理类
    let locationManager = TSAMapLocationView(frame: .zero)
    /// 定位城市
    var address: String? {
        didSet {
            setLocationInfo()
        }
    }

    // MARK: - Lifecycle
    class func vc() -> TSNewFriendsVC {
        let vc = UIStoryboard(name: "TSNewFriendsVC", bundle: nil).instantiateInitialViewController() as! TSNewFriendsVC
        vc.view.frame = UIScreen.main.bounds
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for (index, vc) in vcs.enumerated() {
            vc.view.frame = CGRect(x: CGFloat(index) * UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - TSNavigationBarHeight - 45)
        }
    }

    // MARK: - Custom user interface
    func setUI() {
        // 增大返回按钮的响应区域
        self.backBtn.setEnlargeResponseAreaEdge(size: 15)
        let titleArray = ["热门", "最新", "推荐", "附近"]
        let vcTypes: [TSNewFriendsVC.UserType] = [.hot, .new, .recommend, .nearby]
        // 1.滚动视图
        scrollview.contentSize = CGSize(width: CGFloat(titleArray.count) * UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - TSNavigationBarHeight - 45)
        // 2.标签视图
        labelView.frame = CGRect(x: 0, y: TSNavigationBarHeight, width: UIScreen.main.bounds.width, height: 45)
        labelView.titleArray = titleArray
        labelView.animatedScrollView = scrollview
        // 3.添加子视图控制器
        for (index, type) in vcTypes.enumerated() {
            let vc = TSNewFriendsDetailVC(type: type)
            add(childVC: vc, at: index)
            vcs.append(vc)
        }
        // 4.设置定位
        locationManager.finishBlock = { [weak self] (address) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.address = address
        }
    }

    var vcs: [TSNewFriendsDetailVC] = []

    /// 添加子视图控制器
    func add(childVC: UIViewController, at index: Int) {
        childVC.view.frame = CGRect(x: CGFloat(index) * UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64 - 45)
        addChildViewController(childVC)
        scrollview.addSubview(childVC.view)
    }

    // MARK: - Data

    /// 设置地址相关信息
    func setLocationInfo() {
        guard let address = address else {
            return
        }
        // 1.设置按钮显示地址
        let addressInfo = address.components(separatedBy: " ").last ?? "选择城市"
        buttonForCity.setTitle(addressInfo, for: .normal)
        // 2.获取经纬度等信息
        let requestAddress = address.replacingOccurrences(of: " ", with: "")
        TSNewFriendsNetworkManager.getLocation(address: requestAddress) { [weak self] (data: TSLocationModel?) in
            guard let weakSelf = self, let model = data else {
                return
            }
            // 3.将地址相关信息传给子视图控制器
            for childVC in weakSelf.childViewControllers {
                guard childVC.isKind(of: TSNewFriendsDetailVC.self) else {
                    continue
                }
                let newFriendDetailVC = childVC as!TSNewFriendsDetailVC
                newFriendDetailVC.location = model
            }
            // 4.上传当前用户的位置信息
            TSNewFriendsNetworkManager.submitLocation(latitude: model.latitudes(), longitude: model.longitudes(), complete: nil)
        }
    }

    // MARK: - IBAction

    /// 点击了搜索框
    @IBAction func searchBarTaped() {
        let vc = TSNewFriendsSearchVC.vc()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    /// 点击了通讯录按钮
    @IBAction func contactsButtonTaped() {
        guard TSContacts().getAuthority() else {
            return
        }
        navigationController?.pushViewController(TSContactsVC(), animated: true)
    }

    /// 点击了返回按钮
    @IBAction func backButtonTaped() {
        _ = navigationController?.popViewController(animated: true)
    }

    /// 点击了城市按钮
    @IBAction func cityButtonTaped() {
        let vc = TSSelectAreaViewController()
        vc.setFinishOpration { [weak self] (str) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.address = str
            weakSelf.labelView.setSelected(index: (weakSelf.childViewControllers.count - 1))
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
