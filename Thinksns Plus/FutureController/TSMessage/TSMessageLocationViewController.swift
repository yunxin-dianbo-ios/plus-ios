//
//  TSMessageLocationViewController.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/6/22.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

typealias SendPOIClosure = (_ poi: AMapPOI?, _ image: UIImage?) -> Void
private let Height: CGFloat = (ScreenHeight - TSNavigationBarHeight) * 0.5
class TSMessageLocationViewController: UIViewController {
     /// 搜索UISearchControlle

    ///列表
    var tableView: TSTableView!
    /// currentPage
    var currentPage = 1
    var request: AMapPOIAroundSearchRequest!
    //经纬度
    var selectedLocationCoordinate: CLLocationCoordinate2D!
    ///标题
    /// 选择某一行
    var selectePOI: AMapPOI?
    var titleName: String?
    var sendBlock: SendPOIClosure?
    ///大头针
    var pointAnnotaiton: MAPointAnnotation!
    ///地图
    var mapView: MAMapView!
    var sendPoiClosure: SendPOIClosure?
    ///地图搜索
    var search: AMapSearchAPI!
    //搜索数组
    var searchArray: [AMapTip]?
    var reRequest: AMapReGeocodeSearchRequest?
    /// AMapPOI
    var poiArray: [AMapPOI]?
    /// 选中的中心
    var selectedCenterCoordinate: CLLocationCoordinate2D?
   ///MARK -视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.setZoomLevel(18, animated: true)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.showsScale = false
        TSUtil.checkAuthorizeStatus(type: .getLocation, authCompelteHandler: {
            
        }, cancelHandler: {
            
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        if selectedCenterCoordinate != nil {
            mapView.setCenter(selectedCenterCoordinate!, animated: true)
            selectedCenterCoordinate = nil
            mapView.height = Height
            tableView.mj_y = mapView.bottom
            tableView.height = ScreenHeight - 47 - mapView.height
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func setUI() {
        initSeachBar()
        initMapView()
        initTableView()
        initSearch()
        initRigthItem()
        initLeftItem()
    }
    //MARK：- 初始化右边item
    func initRigthItem () {
        let rightItemBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightItemBtn.setTitle("发送", for: .normal)
        rightItemBtn.set(font: UIFont.systemFont(ofSize: 16))
        rightItemBtn.setTitleColor(TSColor.main.theme, for: .normal)
        rightItemBtn.setTarget(self, action: #selector(rightBtnClick), for: .touchUpInside)
        rightItemBtn.sizeToFit()
        let rightItem = UIBarButtonItem(customView:   rightItemBtn)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    //MARK：- 初始化左边边item
    func initLeftItem () {
        let leftItemBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        leftItemBtn.setTitle("取消", for: .normal)
        leftItemBtn.set(font: UIFont.systemFont(ofSize: 16))
        leftItemBtn.setTitleColor(TSColor.main.theme, for: .normal)
        leftItemBtn.setTarget(self, action: #selector(leftBtnClick), for: .touchUpInside)
        leftItemBtn.sizeToFit()
        let leftItem = UIBarButtonItem(customView:   leftItemBtn)
        self.navigationItem.leftBarButtonItem = leftItem
    }
    func initSeachBar() {
        let seachView = TSSeachBar.seachBarHeadView()
        seachView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 47)
        seachView.seachButton.addTarget(self, action: #selector(seachButtonClick), for: .touchUpInside)
        view.addSubview(seachView)
    }
    // MARK: - Initializatio
    func initMapView() {
        mapView = MAMapView(frame: CGRect(x: 0, y: 47, width: ScreenWidth, height: Height))
        let userLocation = MAUserLocationRepresentation()
        userLocation.showsAccuracyRing = false
        mapView.showsCompass = false
        mapView.update(userLocation)
        view.addSubview(mapView)
    }

    func initSearch() {
        search = AMapSearchAPI()
        search.delegate = self
        request = AMapPOIAroundSearchRequest()
        request.offset = TSAppConfig.share.localInfo.limit
        request.requireExtension = true
    }

    func initTableView() {
        let height = ScreenHeight - 47 - mapView.height
        tableView = TSTableView(frame: CGRect(x: 0, y: mapView.bottom - TSNavigationBarHeight, width: ScreenWidth, height: height ), style:.plain )
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.register(UINib(nibName: "TSMessageLocationCell", bundle: nil), forCellReuseIdentifier: TSMessageLocationCell.identifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.mj_header = nil
        tableView.mj_footer = TSRefreshFooter(refreshingBlock: {
            guard self.selectedLocationCoordinate != nil else {
                self.tableView.mj_footer.endRefreshing()
                return
            }
            self.currentPage += 1
            self.request.page = self.currentPage
            self.request.location = AMapGeoPoint.location(withLatitude: CGFloat(self.selectedLocationCoordinate.latitude), longitude: CGFloat(self.selectedLocationCoordinate.longitude))
            self.search.aMapPOIAroundSearch(self.request)
        })
    }
    // MARK: - action
    @objc func seachButtonClick() {
        let vc = TSLocationResultViewController()
        vc.postValueBlock = {[weak self] (latitude, longitude) in
            self?.selectedCenterCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func rightBtnClick() {
        if sendBlock != nil && self.selectePOI != nil {
            /// 需求：截图以地图中心为中心点，宽高比例 = 3:2
            var shotHeight = self.mapView.height > ScreenWidth * 2.0 / 3 ? ScreenWidth * 2 : self.mapView.height
            let shotWidth = self.mapView.width > shotHeight / 2.0 * 3 ? shotHeight / 2.0 * 3 : self.mapView.width
            if shotWidth < shotHeight / 2.0 * 3 {
                shotHeight = shotWidth / 3.0 * 2
            }
            self.mapView.takeSnapshot(in: CGRect(x: (self.mapView.width - shotWidth) / 2.0, y: (self.mapView.height - shotHeight) / 2.0, width: shotWidth, height: shotHeight)) { (shotImage, status) in
                if status == 0 {
                    TSIndicatorWindowTop.showDefaultTime(state: .faild, title: "地图未加载完毕,稍后重试")
                    return
                }
                self.sendBlock!(self.selectePOI, shotImage)
                self.configDisappearMapView()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    @objc func  leftBtnClick() {
        configDisappearMapView()
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        TSLogCenter.log.debug("释放了")
    }
}

extension TSMessageLocationViewController:MAMapViewDelegate {
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        //POI周边搜索
        let poiRequest = AMapPOIAroundSearchRequest()
        let center = mapView.region.center
        poiRequest.location = AMapGeoPoint.location(withLatitude: CGFloat(center.latitude), longitude: CGFloat(center.longitude))
        poiRequest.radius = 1_000
        poiRequest.requireExtension = true
        // 重置页码
        self.currentPage = 1
        search.aMapPOIAroundSearch(poiRequest)
        self.selectedLocationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(center.latitude), longitude: CLLocationDegrees(center.longitude))
    }
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        let coor = userLocation.coordinate
        if self.selectedLocationCoordinate == nil {
            self.selectedLocationCoordinate = coor
            // 主动发起一次POI请求
            self.request.location = AMapGeoPoint.location(withLatitude: CGFloat(self.selectedLocationCoordinate.latitude), longitude: CGFloat(self.selectedLocationCoordinate.longitude))
            self.mapView.setCenter(self.selectedLocationCoordinate, animated: true)
            self.search.aMapPOIAroundSearch(self.request)
        }
    }

    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAUserLocation.self) {
            return nil
        }
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView?
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            annotationView!.canShowCallout = true
            annotationView!.animatesDrop = true
            annotationView!.isDraggable = true
            return annotationView!
        }
        return nil
    }
    func mapViewRegionChanged(_ mapView: MAMapView!) {
        if let centerCoordinate = mapView.centerCoordinate as? CLLocationCoordinate2D, let pointAnnotaiton = self.pointAnnotaiton {
            pointAnnotaiton.coordinate = centerCoordinate
        }
    }
    func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
        if let centerCoordinate = mapView.centerCoordinate as? CLLocationCoordinate2D, let pointAnnotaiton = self.pointAnnotaiton {
            pointAnnotaiton.coordinate = centerCoordinate
        }
    }

     func configDisappearMapView() {
        search.delegate = nil
        search = nil
        request = nil
        searchArray = nil
        mapView.clearDisk()
        mapView.delegate = nil
        mapView.showsUserLocation = false
        mapView.userTrackingMode = .none
        mapView.removeFromSuperview()
    }
}
extension TSMessageLocationViewController:AMapSearchDelegate {
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        let remoteArray: Array <AMapPOI> = response.pois
        if self.currentPage == 1 {
            // 默认选中第一个
            if remoteArray.count > 0 {
                selectePOI = remoteArray[0]
                if pointAnnotaiton == nil {
                    pointAnnotaiton = MAPointAnnotation()
                    pointAnnotaiton.coordinate = mapView.centerCoordinate
                    mapView.addAnnotation(pointAnnotaiton)
                }
            }
            poiArray = remoteArray
            tableView.reloadData()
            if (poiArray?.count)! > 0 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
                }
            }
        } else {
            poiArray = poiArray! + remoteArray
            tableView.reloadData()
        }

        if (poiArray?.count)! > 0 && response.pois.count < TSAppConfig.share.localInfo.limit {
            self.tableView.mj_footer .endRefreshingWithNoMoreData()
        } else {
            self.tableView.mj_footer .endRefreshing()
        }
        if (poiArray?.count)! > 0 {
            self.tableView.removePlaceholderViews()
            self.tableView.isUserInteractionEnabled = true
        } else {
            self.tableView.show(placeholderView: .empty)
            self.tableView.mj_footer.isHidden = true
            self.tableView.isUserInteractionEnabled = false
        }
    }
    func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        searchArray = response.tips
    }
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
    }
    // MARK: 加载失败回调
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        tableView.mj_footer.endRefreshing()
        if poiArray != nil && (poiArray?.count)! > 0 {
            self.tableView.removePlaceholderViews()
            self.tableView.isUserInteractionEnabled = true
        } else {
            self.tableView.show(placeholderView: .empty)
            self.tableView.mj_footer.isHidden = true
            self.tableView.isUserInteractionEnabled = false
        }
    }
}

extension TSMessageLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        debugPrint(poiArray)
        return poiArray?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: TSMessageLocationCell.identifier, for: indexPath) as! TSMessageLocationCell
        let poi = poiArray?[indexPath.row]
        cell.setInfo(model: poi)
        if poi?.uid == self.selectePOI?.uid {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let poi = poiArray?[indexPath.row]
        self.selectePOI = poi
        let coor = CLLocationCoordinate2D(latitude: CLLocationDegrees(CGFloat((poi?.location.latitude)!)), longitude: CLLocationDegrees(CGFloat((poi?.location.longitude)!)))
        mapView.setCenter(coor, animated: true)
        tableView .reloadData()
    }
}
extension TSMessageLocationViewController:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.selectedCenterCoordinate != nil {
            return
        }
        let currentPosition = scrollView.contentOffset.y
        if currentPosition > 5 {
            if self.mapView.height == Height * 0.5 {
                return
            }
            UIView .animate(withDuration: 0.25) {
                let height = ScreenHeight - 47 - TSNavigationBarHeight
                self.mapView.height = Height * 0.5
                self.tableView.mj_y = Height * 0.5 + 47
                self.tableView.height = height - self.mapView.height
            }
        } else {
            UIView .animate(withDuration: 0.25) {
                self.mapView.height = Height
                self.tableView.mj_y = self.mapView.bottom
                let height = ScreenHeight - 47 - self.mapView.height
                self.tableView.height = height
            }
        }
    }
}
