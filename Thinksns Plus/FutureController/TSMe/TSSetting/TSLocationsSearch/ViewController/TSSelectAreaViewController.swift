//
//  TSSelectAreaViewController.swift
//  date
//
//  Created by Fiction on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  区域选择页面，vc

import UIKit

class TSSelectAreaViewController: TSViewController, TSSAreaSearchTableViewDelegate, TSAMapLocationViewDelegat, TSPopularCityCollectionViewDelegate, UITextFieldDelegate {
    // MARK: - property
    /// cell个数
    let cellCount: CGFloat = 4.0
    /// 间距的个数
    let spacingCount: CGFloat = 5.0
    /// cell高度
    let cellHight: CGFloat = 30.0
    /// 间距
    let spacing: CGFloat = 15.0
    /// 搜索的navigationUI
    let searchBar = TSSearchBarView()
    /// 搜索textfield
    weak var searchTextFeild: UITextField!
    /// 取消按钮
    weak var cancelBtn: UIButton!
    /// 定位展示UI
    weak var aMapLocationView: TSAMapLocationView!
    /// 热门城市CollectionView
    weak var popularCityView: TSPopularCityCollectionView!
    /// 搜索展示tableview
    weak var areaSearchTableView: TSSAreaSearchTableView!
    /// 回调block
    var finishOpration: ((String) -> Void)?

    /// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TSColor.inconspicuous.background
        self.navigationController?.isNavigationBarHidden = true
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        TSLocationsSearchNetworkManager().getPopularCity { (result, status) in
            if status {
                self.popularCityView.changeDataSource(data: result)
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    // MARK: - layout UI
    func setUI() {
        self.searchTextFeild = searchBar.searchTextFiled
        self.searchTextFeild.returnKeyType = .search
        searchTextFeild.delegate = self
        self.cancelBtn = searchBar.rightButton
        self.cancelBtn.addTarget(self, action: #selector(cancelAndPop), for: .touchUpInside)

        let aMapLocationView = TSAMapLocationView(frame: CGRect.zero)
        aMapLocationView.backgroundColor = TSColor.main.white
        self.aMapLocationView = aMapLocationView
        self.aMapLocationView?.TSAMapLocationViewDelegat = self

        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.size.width - spacing * spacingCount) / cellCount
        layout.itemSize = CGSize(width: width, height: cellHight)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 30)
        let popularCityView = TSPopularCityCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.popularCityView = popularCityView
        self.popularCityView.TSPopularCityCollectionViewDelegate = self

        self.view.addSubview(searchBar)
        self.view.addSubview(aMapLocationView)
        self.view.addSubview(popularCityView)

        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(TSTopAdjustsScrollViewInsets)
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view.snp.top).offset(TSNavigationBarHeight)
        }
        aMapLocationView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.left.right.equalTo(self.view)
            make.height.equalTo(45)
        }
        popularCityView.snp.makeConstraints { (make) in
            make.top.equalTo(aMapLocationView.snp.bottom)
            make.left.right.equalTo(self.view)
            make.height.equalTo(200)
        }

        /// 最后加载搜索显示TableView
        let areaSearchTableView = TSSAreaSearchTableView(frame: CGRect.zero, style: .plain)
        self.areaSearchTableView = areaSearchTableView
        self.areaSearchTableView.TSSAreaSearchTableViewDelegate = self
        self.view.addSubview(areaSearchTableView)

        areaSearchTableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsets(top: TSNavigationBarHeight, left: 0, bottom: 0, right: 0))
        }

        self.popularCityView.isHidden = true
        self.areaSearchTableView.isHidden = true
    }
    /// block回调方法
    func setFinishOpration(opration: @escaping ((String) -> Void)) {
        finishOpration = opration
    }

    // MARK: - 代理
    func stringOfRow(str: String) {
        finishOpration?(str)
        _ = navigationController?.popViewController(animated: true)
    }
    func stringForLocation(str: String) {
        finishOpration?(str)
        _ = navigationController?.popViewController(animated: true)
    }
    func stringOfPopularCityCollectionRow(str: String) {
        finishOpration?(str)
        _ = navigationController?.popViewController(animated: true)
    }
    func selfContentSizeHight(hight: CGFloat) {
        self.popularCityView.snp.updateConstraints { (make) in
            make.top.equalTo(aMapLocationView.snp.bottom)
            make.left.right.equalTo(self.view)
            make.height.equalTo(hight)
        }
        self.popularCityView.isHidden = false
    }

    // MARK: - Action
    /// 搜索框传值，附带交互
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let str = textField.text
        guard str != nil else {
            return false
        }
        guard str != "" else {
            self.areaSearchTableView.isHidden = true
            return false
        }
        TSLocationsSearchNetworkManager().getLocationsSearchResult(searchStr: str!) { (result) in
            self.areaSearchTableView.setAreaSearchDataSource(data: result)
            self.areaSearchTableView.isHidden = false
            textField.resignFirstResponder()
        }
        return true
    }

    /// 取消按钮方法
    func cancelAndPop() {
        _ = navigationController?.popViewController(animated: true)
    }
}
