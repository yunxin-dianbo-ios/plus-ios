//
//  TSShowLocationVC.swift
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/6/25.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSShowLocationVC: TSViewController, MAMapViewDelegate, TSCustomAcionSheetDelegate {
    var address: String?
    var titleStr: String?
    var latitude: Float = 0.0
    var longitude: Float = 0.0
    var image: UIImage?
     var currentConversattion: EMConversation?
    ///地图
    var mapView: MAMapView!
    fileprivate var titleLab: UILabel!
    fileprivate var addressLab: UILabel!
    fileprivate var bottomView: UIView!
    fileprivate let bottomViewHeight: CGFloat = CGFloat(80 + TSBottomSafeAreaHeight)
    fileprivate var currentLocaton: CLLocationCoordinate2D?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "查看位置"
        self.initMapView()
        self.creatBottomView()
        setShareMusicButton()
        // Do any additional setup after loading the view.
    }
    // MARK: - Initializatio
    func initMapView() {
        mapView = MAMapView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - bottomViewHeight))
        self.view.addSubview(mapView)
        let userLocation = MAUserLocationRepresentation()
        userLocation.showsAccuracyRing = false
        mapView.update(userLocation)
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.centerCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
        mapView.setZoomLevel(18, animated: true)
    }
    func setShareMusicButton() {
        let shareButton = UIButton(type: .custom)
       shareButton.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.setupNavigationTitleItem(shareButton, title: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
          shareButton.setImage(UIImage(named: "ico_transmit"), for: UIControlState.normal)
          shareButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: shareButton.width - (shareButton.currentImage?.size.width)!, bottom: 0, right: 0)
    }
    func creatBottomView() {
        self.bottomView = UIView()
        self.bottomView.backgroundColor = UIColor.white
        self.view.addSubview(self.bottomView)
        self.bottomView.snp.makeConstraints { (mark) in
            mark.bottom.equalToSuperview()
            mark.height.equalTo(bottomViewHeight)
            mark.leading.trailing.equalToSuperview()
        }

        let otherNavBtn = UIButton()
        self.bottomView.addSubview(otherNavBtn)
        otherNavBtn.setImage(UIImage(named: "ico_navigate"), for: .normal)
        otherNavBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        otherNavBtn.setTitleColor(TSColor.main.theme, for: .normal)
        otherNavBtn.setTitle("去这里", for: .normal)
        otherNavBtn.snp.makeConstraints { (mark) in
            mark.height.equalTo(34)
            mark.width.equalTo(60)
            mark.trailing.equalToSuperview().offset(-10)
            mark.centerY.equalTo(self.bottomView.snp.centerY)
        }
        otherNavBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(otherNavBtn.imageView?.frame.size.width)!, bottom:  -(otherNavBtn.imageView?.frame.size.height)! - 10.0, right: 0)
        otherNavBtn.imageEdgeInsets = UIEdgeInsets(top: -(otherNavBtn.titleLabel?.intrinsicContentSize.height)! - 10.0 / 2, left: 0, bottom: 0, right: -(otherNavBtn.titleLabel?.intrinsicContentSize.width)!)
        otherNavBtn.addTarget(self, action: #selector(otherNavBtnDidClick), for: .touchUpInside)
        let spView = UIView()
        self.bottomView.addSubview(spView)
        spView.backgroundColor = TSColor.inconspicuous.disabled
        spView.snp.makeConstraints { (mark) in
            mark.height.equalTo(40)
            mark.width.equalTo(0.5)
            mark.trailing.equalTo(otherNavBtn.snp.leading).offset(-20)
            mark.centerY.equalTo(self.bottomView.snp.centerY)
        }

        //30 34
        self.titleLab = UILabel()
        self.titleLab.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.bottomView.addSubview(self.titleLab)
        self.titleLab.snp.makeConstraints { (mark) in
            mark.leading.equalTo(15)
            mark.trailing.equalTo(spView.snp.leading).offset(15)
            mark.top.equalTo(25)
            mark.height.equalTo(14)
        }
        self.titleLab.text = titleStr

        self.addressLab = UILabel()
        self.addressLab.font = UIFont.systemFont(ofSize: TSFont.ContentText.sectionTitle.rawValue)
        self.addressLab.textColor = TSColor.normal.minor
        self.bottomView.addSubview(self.addressLab)
        self.addressLab.snp.makeConstraints { (mark) in
            mark.leading.equalTo(15)
            mark.trailing.equalTo(spView.snp.leading).offset(15)
            mark.top.equalTo(self.titleLab.snp.bottom).offset(8)
            mark.height.equalTo(12)
        }
        self.addressLab.text = address
    }
    override func viewDidAppear(_ animated: Bool) {
        let pointAnnotation = MAPointAnnotation()
        pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        pointAnnotation.title = titleStr
        pointAnnotation.subtitle = address
        mapView.addAnnotation(pointAnnotation)
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
    func otherNavBtnDidClick() {
        var maps: Array<String> = []
        // 默认是有系统地图
        maps.append("Apple 地图")
        // 检测是否有高德地图
        if UIApplication.shared.canOpenURL(URL(string: "iosamap://map/")!) {
            maps.append("高德地图")
        }
        // 检测是否有百度地图
        if UIApplication.shared.canOpenURL(URL(string: "baidumap://map/")!) {
            maps.append("百度地图")
        }
        let actionsheetView = TSCustomActionsheetView(titles: maps)
        actionsheetView.delegate = self
        actionsheetView.tag = 2
        actionsheetView.show()
    }
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        var openUrl = ""
        if title == "Apple 地图" {
            openUrl = "http://maps.apple.com/?daddr=\(latitude),\(longitude)&saddr=Current+Location"
        } else if title == "高德地图" {
            openUrl = "iosamap://navi?sourceApplication=\(TSAppSettingInfoModel().appDisplayName)&backScheme=\(TSAppSettingInfoModel().appURLScheme)&poiname=\(titleStr!)&lat=\(latitude)&lon=\(longitude)&dev=1&style=2"
        } else if title == "百度地图" {
            if self.currentLocaton != nil {
                self.currentLocaton = self.gcj02CoordianteToBD09(gdCoordinate: self.currentLocaton!)
                openUrl = "baidumap://map/direction?origin=latlng:\(self.currentLocaton?.latitude),\(self.currentLocaton?.latitude)|name:我的位置&destination=latlng:\(latitude),\(longitude)|name:\(titleStr!)&mode=driving"
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: "暂未获取到当前位置,请稍后重试")
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
        if openUrl.isEmpty == false {
            openUrl = openUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.openURL(URL(string: openUrl)!)
        }
    }
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        self.currentLocaton = userLocation.coordinate
    }

    func gcj02CoordianteToBD09(gdCoordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let x_PI = Double.pi * 3_000.0 / 180.0
        let gd_lat = gdCoordinate.latitude
        let gd_lon = gdCoordinate.longitude
        let z = sqrt(gd_lat * gd_lat + gd_lon * gd_lon) + 0.000_02 * sin(gd_lat * x_PI)
        let theta = atan2(gd_lat, gd_lon) + 0.000_003 * cos(gd_lon * x_PI)
        return CLLocationCoordinate2D(latitude: z * sin(theta) + 0.006, longitude: z * cos(theta) + 0.006_5)
    }
    /// MARK : Action
    @objc func rightButtonClick() {
        let vc = TSChatSingleAddMemberVC()
        vc.ischangeGroupMember = "singleswitchgroup"
        vc.currentConversattion = self.currentConversattion
        vc.address = self.address
        vc.titleStr = self.titleStr
        vc.latitude = self.latitude
        vc.longitude = self.longitude
        vc.image = self.image
        navigationController?.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
