//
//  GroupLocationController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子定位控制器
//  注：可考虑将定位统一为一个定位模块，便于后续的维护和管理。
//  目前涉及定位的界面有：创建圈子-位置选择、个人信息设置-城市选择、找人-选择城市。
//  参考界面TSSelectAreaViewController
//  注：搜索功能需要进一步明确交互细节

import UIKit

protocol GroupLocationControllerProtocol: class {
    /// 位置选中回调，为nil时表示不显示位置
    func didSelectedLocation(_ location: GroupLocationModel?) -> Void
}

class GroupLocationController: UIViewController {
    // MARK: - Internal Property

    weak var delegate: GroupLocationControllerProtocol?
    var selectedLocationAction: ((_ location: GroupLocationModel?) -> Void)?

    // MARK: - Internal Function
    // MARK: - Private Property

    /// 当前展示类型
    enum ShowType {
        case searh
        case location
    }
    fileprivate var showType: ShowType = .location

    fileprivate var searchTableView: UITableView!
    fileprivate var locationTableView: UITableView!

    fileprivate var searchSourceList: [AMapPOI] = [AMapPOI]()
    fileprivate var locationSourceList: [AMapPOI] = [AMapPOI]()
    /// 不显示定位按钮
    fileprivate let noneLocationLabel = UILabel()
    /// 搜索的navigationUI
    fileprivate weak var searchBar: TSSearchBarView!
    fileprivate weak var searchField: UITextField!
    fileprivate weak var cancelBtn: UIButton!

    /// 三方POI Search
    fileprivate var search: AMapSearchAPI?
    /// 三方定位控制器
    lazy var locationManager = AMapLocationManager()
    /// 定位超时时间
    let defaultLocationTimeout = 5
    /// 逆地理请求超时时间
    let defaultReGeocodeTimeout = 5

    fileprivate var currentLocation: CLLocation?

    // MARK: - Initialize Function

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TSColor.inconspicuous.background
        self.initialUI()
        self.initialDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

}

// MARK: - UI

extension GroupLocationController {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        // 1. 导航栏搜索框
        let searchBar = TSSearchBarView()
        self.view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(TSTopAdjustsScrollViewInsets)
            make.height.equalTo(64.0)
        }
        self.searchBar = searchBar
        // 1.x 导航栏搜索框相关配置
        self.searchField = searchBar.searchTextFiled
        self.searchField.returnKeyType = .search
        searchField.delegate = self
        self.cancelBtn = searchBar.rightButton
        self.cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        self.view.addSubview(self.noneLocationLabel)
        self.noneLocationLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view).offset(15)
            make.top.equalTo(searchBar.snp.bottom)
            make.height.equalTo(44.0)
        }
        self.noneLocationLabel.text = "不显示位置"
        self.noneLocationLabel.textAlignment = .left
        self.noneLocationLabel.font = UIFont.systemFont(ofSize: 15)
        self.noneLocationLabel.textColor = UIColor.black
        self.noneLocationLabel.isUserInteractionEnabled = true
        let noneLocationTap = UITapGestureRecognizer(target: self, action: #selector(noneLocationLabelDidTap))
        self.noneLocationLabel.addGestureRecognizer(noneLocationTap)
        // 2. 位置列表
        self.searchTableView = self.createTableView()
        self.locationTableView = self.createTableView()
        self.searchTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction:nil)
        self.locationTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction:nil)
        self.locationTableView.mj_header.beginRefreshing()
        self.searchTableView.isHidden = true
        self.searchTableView.tag = 250
        self.locationTableView.tag = 251
    }
    /// 不显示位置信息
    func noneLocationLabelDidTap() {
        self.delegate?.didSelectedLocation(nil)
        self.selectedLocationAction?(nil)
        _ = self.navigationController?.popViewController(animated: true)
    }

    fileprivate func createTableView() -> UITableView {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 250
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(noneLocationLabel.snp.bottom)
            make.leading.trailing.bottom.equalTo(self.view)
        }
        return tableView
    }
}

// MARK: - 数据处理与加载

extension GroupLocationController {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        self.configLocationManager()
        self.configPOISearch()
        self.locationTableView.reloadData()
    }

    func setShowType(_ showType: ShowType) -> Void {
        self.showType = showType
        switch showType {
        case .location:
            self.locationTableView.isHidden = false
            self.searchTableView.isHidden = true
        case .searh:
            self.locationTableView.isHidden = true
            self.searchTableView.isHidden = false
        }
    }
}

// MARK: - 定位相关

extension GroupLocationController {

    /// 定位配置 - 顺带判断定位权限状态
    func configLocationManager() {
        locationManager.delegate = self
        /// 推荐精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        /// 定位超时时间
        locationManager.locationTimeout = self.defaultLocationTimeout
        /// 逆地理请求超时时间
        locationManager.reGeocodeTimeout = self.defaultReGeocodeTimeout
        let status = self.checkLocationPermissions()
        if status {
            self.getCurrentLocation()
        } else {
            self.locationTableView.mj_header.endRefreshing()
        }
    }

    /// POI配置
    func configPOISearch() -> Void {
        // 构造 AMapSearchAPI
        let search = AMapSearchAPI()
        search?.delegate = self
        self.search = search
    }

    /// 定位周围的
    func locationAroundPOIRequest(location: CLLocation, keyword: String?) -> Void {
        // 设置周边检索的参数
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude))
        if let keyword = keyword {
            request.keywords = keyword
        }
        request.requireExtension = true
        // 发起周边检索
        search?.aMapPOIAroundSearch(request)
    }
    func keywordPOIRequest(_ keyword: String) -> Void {
        // 设置周边检索的参数
        self.searchTableView.mj_header.beginRefreshing()
        let request = AMapPOIAroundSearchRequest()
        if let location = self.currentLocation {
            request.location = AMapGeoPoint.location(withLatitude: CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude))
        }
        request.keywords = keyword
        request.requireExtension = true
        // 发起周边检索
        search?.aMapPOIAroundSearch(request)
    }

    /// 检查定位权限 根据BOOL返回值，是否开始定位
    func checkLocationPermissions() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse:
            fallthrough
        case .authorizedAlways:
            return true
        case .denied:
            return false
        case .notDetermined, .restricted:
            return false
        }
    }

    /// 获取当前定位
    fileprivate func getCurrentLocation() -> Void {

        self.locationManager.requestLocation(withReGeocode: true) { (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
            if let error = error {
                let error = error as NSError
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
                    //                    self?.locationLabel.text = "三方定位错误"
                    //                    self?.finishBlock?(nil)
                    //                    self?.showImageOrAnmie(show: .Iamge)
                    return
                } else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                    || error.code == AMapLocationErrorCode.timeOut.rawValue
                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                    || error.code == AMapLocationErrorCode.badURL.rawValue
                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
                    //                    self?.locationLabel.text = "三方逆地理错误"
                    //                    self?.finishBlock?(nil)
                    //                    self?.showImageOrAnmie(show: .Iamge)
                }
            }
            print(location)
            print(reGeocode)
            if let location = location {
                self.currentLocation = location
                self.locationAroundPOIRequest(location: location, keyword: nil)
            }
        }
    }
}

// MARK: - 事件响应

extension GroupLocationController {
    /// 取消按钮点击响应
    @objc fileprivate func cancelBtnClick() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Notification

extension GroupLocationController {

}

// MARK: - Delegate Function

// MARK: - UITableViewDataSource

extension GroupLocationController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if tableView == self.locationTableView {
            rowCount = self.locationSourceList.count
        } else if tableView == self.searchTableView {
            rowCount = self.searchSourceList.count
        }
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.locationTableView {
            let cell = LocationPoiCell.cellInTableView(tableView)
            cell.model = self.locationSourceList[indexPath.row]
            return cell
        } else if tableView == self.searchTableView {
            let cell = LocationPoiCell.cellInTableView(tableView)
            cell.model = self.searchSourceList[indexPath.row]
            return cell
        }

        return UITableViewCell(style: .default, reuseIdentifier: "")
    }
}

// MARK: - UITableViewDelegate

extension GroupLocationController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.locationTableView {
            if 1 == indexPath.section {
                return UITableViewAutomaticDimension
            } else {
                return 44
            }
        } else if tableView == self.searchTableView {
            return UITableViewAutomaticDimension
        }
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.locationTableView {
            // 选中位置
            let poi = self.locationSourceList[indexPath.row]
            let location = GroupLocationModel(poi: poi)
            self.delegate?.didSelectedLocation(location)
            self.selectedLocationAction?(location)
            _ = self.navigationController?.popViewController(animated: true)
        } else if tableView == self.searchTableView {
            // 选中位置
            let poi = self.searchSourceList[indexPath.row]
            let location = GroupLocationModel(poi: poi)
            self.delegate?.didSelectedLocation(location)
            self.selectedLocationAction?(location)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

}

// MARK: - Delegate <AMapSearchDelegate>

extension GroupLocationController: AMapSearchDelegate {
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {

//        if response.count == 0 {
//            return
//        }

//        1）可以在回调中解析 response，获取 POI 信息。
//        2）response.pois 可以获取到 AMapPOI 列表，POI 详细信息可参考 AMapPOI 类。
//        3）若当前城市查询不到所需 POI 信息，可以通过 response.suggestion.cities 获取当前 POI 搜索的建议城市。
//        4）如果搜索关键字明显为误输入，则可通过 response.suggestion.keywords法得到搜索关键词建议。

        switch self.showType {
        case .location:
            self.locationSourceList.removeAll()
            for poi in response.pois {
                self.locationSourceList.append(poi)
            }
            self.locationTableView.reloadData()
            self.locationTableView.mj_header.endRefreshing()
        case .searh:
            self.searchSourceList.removeAll()
            for poi in response.pois {
                self.searchSourceList.append(poi)
            }
            self.searchTableView.reloadData()
            self.searchTableView.mj_header.endRefreshing()
        }
    }
}

// MARK: - Delegate <AMapLocationManagerDelegate>

extension GroupLocationController: AMapLocationManagerDelegate {

    /// 定位授权状态回调方法
    func amapLocationManager(_ manager: AMapLocationManager!, didChange status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            fallthrough
        case .authorizedAlways:
            self.getCurrentLocation()
        case .notDetermined:
            return
        default:
            let appName = TSAppConfig.share.localInfo.appDisplayName
            TSErrorTipActionsheetView().setWith(title: "定位权限设置", TitleContent: "请为\(appName)开放定位权限：手机设置-隐私-定位-\(appName)(打开)", doneButtonTitle: ["去设置", "取消"], complete: { (_) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.openURL(url!)
                }
            })
        }
    }
}

// MARK: - Delegate <UITextFieldDelegate>

extension GroupLocationController: UITextFieldDelegate {
    /// 搜索框传值，附带交互
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let str = textField.text else {
            self.setShowType(.location)
            return false
        }
        if str == "" {
            self.setShowType(.location)
            return false
        }
        self.setShowType(.searh)
        self.keywordPOIRequest(str)
        return true
    }
}
