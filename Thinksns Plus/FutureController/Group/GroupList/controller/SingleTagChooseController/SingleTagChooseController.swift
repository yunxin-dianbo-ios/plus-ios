//
//  ATagScrollView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  copy "TSNewTagScrollView.swift" 的代码，将其中的 obejct 改为 model

import UIKit

class SingleTagChooseController: UIViewController {
    /// 导航栏右边按钮视图
    let rightNavView = GroupListRightNavView()
    // tag 标题
    var titles: [String] = [] {
        didSet {
            collection.reloadData()
        }
    }
    // 当前选中 tag 的坐标
    var currentIndex = 0

    // 选中 tag 返回 block
    var selectedBlock: ((Int) -> Void)?

    /// tag 集合视图
    let collection = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: SingleTagChooseCollectionLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    func setUI() {
        view.backgroundColor = .white
        // 1.导航栏右边按钮视图
        rightNavView.searchButton.addTarget(self, action: #selector(searchButtonTaped), for: .touchUpInside)
        rightNavView.buildButton.addTarget(self, action: #selector(buildButtonTaped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)

        collection.backgroundColor = .white
        collection.delegate = self
        collection.dataSource = self
        collection.register(SingleTagChooseCell.self, forCellWithReuseIdentifier: SingleTagChooseCell.identifier)

        view.addSubview(collection)
    }

    func set(titles: [String], selected index: Int) {
        self.titles = titles
        currentIndex = index
        collection.reloadData()
    }
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
}

extension SingleTagChooseController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collection.deselectItem(at: indexPath, animated: false)
        currentIndex = indexPath.row
        collection.reloadData()
        selectedBlock?(currentIndex)
        navigationController?.popViewController(animated: true)
    }

}

extension SingleTagChooseController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: SingleTagChooseCell.identifier, for: indexPath) as! SingleTagChooseCell
        cell.set(titile: titles[indexPath.row], isSelected: indexPath.row == currentIndex)
        return cell
    }

}

class SingleTagChooseCollectionLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()

        itemSize = CGSize(width: (UIScreen.main.bounds.width - 15) / 4, height: 45)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        sectionInset = UIEdgeInsets(top: 17.5, left: 7.5, bottom: 17.5, right: 7.5)
        scrollDirection = .vertical
    }
}
