//
//  TSLocationResultViewController.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/6/23.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
typealias closureBlock = (CGFloat, CGFloat) -> Void
class TSLocationResultViewController: UIViewController {
    /// 搜索的navigationUI
    fileprivate weak var searchBar: TSSearchBarView!
    fileprivate weak var searchField: UITextField!
    fileprivate weak var cancelBtn: UIButton!
    /// 占位图
    let occupiedView = UIImageView()
    //返回经纬度的闭包
    var postValueBlock: closureBlock?
    /// currentPage
    var  currentPage = 1
    fileprivate weak var normalTableView: TSTableView!
    var search: AMapSearchAPI = AMapSearchAPI()

    var  request: AMapPOIAroundSearchRequest!
    //AMapPOIKeywordsSearchRequest
    var keywordsRequest: AMapPOIKeywordsSearchRequest!

    var searchArray: [AMapPOI]? {
        didSet {
            self.normalTableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initMapSearch()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillAppear(animated)
          self.navigationController?.navigationBar.isHidden = false
    }
    func setupUI() {
        let searchBar = TSSearchBarView()
        self.view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.view).offset(TSTopAdjustsScrollViewInsets)
            make.bottom.equalTo(self.view.snp.top).offset(TSNavigationBarHeight)
        }
        self.searchBar = searchBar
        // 1.x 导航栏搜索框相关配置
        self.searchField = searchBar.searchTextFiled
        self.searchField.returnKeyType = .search
        searchField.delegate = self
        self.cancelBtn = searchBar.rightButton
        self.normalTableView = self.createTableView()
        self.searchField.becomeFirstResponder()
        occupiedView.backgroundColor = UIColor.white
        occupiedView.contentMode = .center
        self.cancelBtn.addTarget(self, action: #selector(cancelBtnClick(_:)), for: .touchUpInside)
    }

    ///MARK -- 初始化mapMapSearch
    func initMapSearch() {
        search = AMapSearchAPI()
        search.delegate = self
          keywordsRequest = AMapPOIKeywordsSearchRequest()
          keywordsRequest.offset = TSAppConfig.share.localInfo.limit
          keywordsRequest.requireExtension = true
//        request = AMapPOIAroundSearchRequest()
//        request.offset = TSAppConfig.share.localInfo.limit
//        request.requireExtension = true
//
//        let tips = AMapInputTipsSearchRequest()
//        tips.keywords = ""
//        self.search.aMapInputTipsSearch(tips)
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
            occupiedView.frame = self.normalTableView.bounds
         self.normalTableView.addSubview(occupiedView)
        }
    }
    fileprivate func createTableView() -> TSTableView {
        let tableView = TSTableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        //tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.mj_header = nil
       tableView.mj_footer = TSRefreshFooter(refreshingBlock: {
        self.currentPage += 1
        self.keywordsRequest.page = self.currentPage
        self.keywordsRequest.keywords = self.searchField.text
        self.search.aMapPOIKeywordsSearch(self.keywordsRequest)
       })
//        tableView.mj_footer.isHidden = true     // 默认隐藏上拉加载更多
        tableView.register(UINib(nibName: "TSMessageLocationCell", bundle: nil), forCellReuseIdentifier: TSMessageLocationCell.identifier)
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self.view)
            make.top.equalTo(searchBar.snp.bottom)
        }
        return tableView
    }
    //MARK -- action
    @objc fileprivate func cancelBtnClick(_ button: UIButton) -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func refresh() {
    }
    @objc func loadMore () {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension TSLocationResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchArray?.count != 0 {
               occupiedView.removeFromSuperview()
        }
        if self.searchArray == nil {
            showOccupiedView(type: .empty)
        }
        return self.searchArray?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: TSMessageLocationCell.identifier, for: indexPath) as! TSMessageLocationCell
        let poi = searchArray?[indexPath.row]
         cell.setInfo(model: poi)
//        cell.setInfoTip(model: poi!)
        let range = poi?.name.range(of: self.searchField.text ?? "")
        if let range = range {
              let NSRange = "".nsRange(from: range)
                    if NSRange.location != NSNotFound {
                    cell.titltLable.attributedText = poi?.name.ts_attrStringloc(loc: (NSRange.location), len: (NSRange.length), color: UIColor(hex: 0x86cdad), backgroundColor: nil)
                    } else {
                        cell.titltLable.text = poi?.name
                    }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let poi = searchArray?[indexPath.row]
        if poi != nil, let location = poi!.location, postValueBlock != nil {
            postValueBlock!(location.latitude, location.longitude)
            self.navigationController?.popViewController(animated: true)
        } else {
            TSIndicatorWindowTop.showDefaultTime(state: .faild, title: "当前选择项不可用")
        }
    }
}
/// MARK --UITextFieldDelegate
extension TSLocationResultViewController :UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.searchArray != nil {
            self.searchArray!.removeAll()
        }
        keywordsRequest.keywords = textField.text
        self.search.aMapPOIKeywordsSearch(keywordsRequest!)
        self.searchField.resignFirstResponder()
        return true
    }
}

extension TSLocationResultViewController : AMapSearchDelegate {
    func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        // 过滤掉没有定位信息的不可用POI
//        if var tips = response.tips {
//            var disableIndexs: Array<Int> = []
//            for (index, item) in tips.enumerated() {
//                if item.location == nil {
//                    disableIndexs.append(index)
//                }
//            }
//            if disableIndexs.count > 0 {
//                for (index, disableIndex) in disableIndexs.enumerated() {
//                    tips.remove(at: disableIndex - index)
//                }
//            }
//            self.searchArray = tips
//        } else {
//            showOccupiedView(type: .empty)
//        }
//    }
//        debugPrint(response.tips.count)
//
//        if response.tips.count == 0 {
//            showOccupiedView(type: .empty)
//        } else {
//              self.searchArray = response.tips
//        }
    }
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
         debugPrint(response.pois)
        let remoteArray: Array <AMapPOI> = response.pois
        if self.currentPage == 1 {
            self.searchArray = remoteArray
        } else {
            self.searchArray = searchArray! + remoteArray
        }
        if (searchArray?.count)! > 0 && response.pois.count < TSAppConfig.share.localInfo.limit {
            self.normalTableView.mj_footer .endRefreshingWithNoMoreData()
        } else {
            self.normalTableView.mj_footer .endRefreshing()
        }
        if (searchArray?.count)! > 0 {
            self.normalTableView.removePlaceholderViews()
        } else {
            self.normalTableView.show(placeholderView: .empty)
            self.normalTableView.mj_footer.isHidden = true
        }
    }
}
