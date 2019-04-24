//
//  TSAMapLocationView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/9.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol TSAMapLocationViewDelegat: NSObjectProtocol {
    /// 返回定位的string
    /// - TSAMapLocationViewDelegat
    func stringForLocation(str: String)
}

/// 需要显示什么动画还是图片
enum rightShowWhat: String {
    case Iamge
    case Anmie
}

class TSAMapLocationView: UIView, AMapLocationManagerDelegate {
    // MARK: - property
    weak var TSAMapLocationViewDelegat: TSAMapLocationViewDelegat? = nil
    /// 反地理字符转的串数组
    var locationArray: Array<String> = []
    /// 【当前定位】
    let locationTitleLabel: UILabel = UILabel()
    /// 定位状态和显示
    let locationLabel: UILabel = UILabel()
    /// 定位中动画
    let locationImageAnmie: TSIndicatorFlowerView = TSIndicatorFlowerView()
    /// 定位完成图标
    let locationImage: UIImageView = UIImageView(image: #imageLiteral(resourceName: "IMG_find_ico_location2"))
    /// 三方定位控制器
    lazy var locationManager = AMapLocationManager()
    /// 定位超时时间
    let defaultLocationTimeout = 5
    /// 逆地理请求超时时间
    let defaultReGeocodeTimeout = 5

    /// 定位结束
    var finishBlock: ((String?) -> Void)?

    // MARK: - lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        self.showImageOrAnmie(show: .Iamge)
        configLocationManager()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - layout UI
    func setUI() {
        locationTitleLabel.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        locationTitleLabel.textColor = TSColor.main.content
        locationTitleLabel.text = "当前定位"
        locationLabel.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        locationLabel.textColor = TSColor.normal.secondary
        locationLabel.text = "未定位"
        locationImage.contentMode = .center

        self.addSubview(locationTitleLabel)
        self.addSubview(locationLabel)
        self.addSubview(locationImageAnmie)
        self.addSubview(locationImage)

        locationTitleLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self).offset(10)
        }
        locationLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self)
            make.left.equalTo(locationTitleLabel.snp.right).offset(17.5)
        }
        locationImage.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self)
            make.width.height.equalTo(45)
            make.right.equalTo(self)
        }
        locationImageAnmie.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.width.height.equalTo(15)
            make.right.equalTo(self.snp.right).offset(-13.5)
        }
    }

    // MARK: - 本页面逻辑判断

    /// 检查定位权限
    ///
    /// - Returns: 根据BOOL返回值，是否开始定位
    func checkLocationPermissions() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse:
            return true
        case .denied, .restricted:
            return false
        default:
            return false
        }
    }

    /// 显示定位状态
    /// 定为中的动画还是定位后的图标
    ///
    /// - Parameter show: 传入状态枚举值
    func showImageOrAnmie(show: rightShowWhat) {
        switch show {
        case .Iamge:
            locationImageAnmie.dismiss()
            locationImage.isHidden = false
        default:
            locationImage.isHidden = true
            locationImageAnmie.starAnimationForFlowerGrey()
        }
    }

    /// 筛选反地理位置
    ///
    /// - Parameter reGeocode: reGeocode 是三方返回的反地理位置数据
    func filterReGeocode(reGeocode: AMapLocationReGeocode) {
        let country: String? = reGeocode.country
        let province: String? = reGeocode.province
        let city: String? = reGeocode.city
        let district: String? = reGeocode.district
        let street: String? = reGeocode.street
        var array = [country, province, city, district, street]

        for index in 0..<array.count {
            let str = array[index]
            if str != nil && !(str!.isEmpty) {
                locationArray.append(str!)
            } else {
                break
            }
        }
        self.locationLabel.text = locationArray.last ?? "定位失败"
        self.finishBlock?(locationArray.last)
        self.locationLabel.textColor = TSColor.main.content
        self.showImageOrAnmie(show: .Iamge)
        self.isUserInteractionEnabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var str: String = ""
        guard !locationArray.isEmpty else {
            return
        }
        for index in locationArray {
            str.append(" " + index)
        }
        str.remove(at: str.startIndex)
        self.TSAMapLocationViewDelegat?.stringForLocation(str: str)
    }

    // MARK: - 三方定位

    /// 定位授权状态回调方法
    ///
    /// - Parameters:
    ///   - manager: manager
    ///   - status: authorizedWhenInUse
    func amapLocationManager(_ manager: AMapLocationManager!, didChange status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            self.showImageOrAnmie(show: .Anmie)
            self.getLocation()
        case .denied:
            let appName = TSAppConfig.share.localInfo.appDisplayName
            TSErrorTipActionsheetView().setWith(title: "定位权限设置", TitleContent: "请为\(appName)开放定位权限：手机设置-隐私-定位-\(appName)(打开)", doneButtonTitle: ["去设置", "取消"], complete: { (_) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.openURL(url!)
                }
            })
        default:
            TSLogCenter.log.debug("定位准备中...")
        }

    }

    /// 获取一次定位
    func getLocation() {
        /// 关闭此view的用户操作，防止误操作
        self.isUserInteractionEnabled = false
        locationManager.requestLocation(withReGeocode: true, completionBlock: { [weak self] (_, reGeocode: AMapLocationReGeocode?, error: Error?) in
            if let error = error {
                let error = error as NSError
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
                    self?.locationLabel.text = "三方定位错误"
                    self?.finishBlock?(nil)
                    self?.showImageOrAnmie(show: .Iamge)
                    return
                } else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                    || error.code == AMapLocationErrorCode.timeOut.rawValue
                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                    || error.code == AMapLocationErrorCode.badURL.rawValue
                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
                    self?.locationLabel.text = "三方逆地理错误"
                    self?.finishBlock?(nil)
                    self?.showImageOrAnmie(show: .Iamge)
                }
            }

            if let reGeocode = reGeocode {
                self?.filterReGeocode(reGeocode: reGeocode)
            }
        })
    }

    /// locationManager配置方法
    /// - 顺带判断定位权限状态
    func configLocationManager() {
        locationManager.delegate = self
        /// 推荐精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        /// 定位超时时间
        locationManager.locationTimeout = defaultLocationTimeout
        /// 逆地理请求超时时间
        locationManager.reGeocodeTimeout = defaultReGeocodeTimeout
        let result = checkLocationPermissions()
        guard result else {
            return
        }
        self.showImageOrAnmie(show: .Anmie)
        getLocation()
    }

}
