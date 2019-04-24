//
//  QRCodeScanVC.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2017/12/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation

private let qrWidth: CGFloat = ScreenWidth - 100
private let qrHeight: CGFloat = ScreenHeight - 64
private let topHeight: CGFloat = 80

class QRCodeScanVC: TSViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureView: UIView?

    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode]

    lazy var messageLabel: UILabel = {[unowned self] in
        let messageLabel = UILabel(frame: CGRect(x: 0, y: ScreenHeight - 124, width: ScreenWidth, height: 60))
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.textColor = UIColor.white//UIColor(red: 51, green: 51, blue: 51)
        messageLabel.numberOfLines = 0
        return messageLabel
        }()

    /// 扫码框
    lazy var qrCodeFrameView: UIView = {[unowned self] in
        let qrCodeFrameView = UIView(frame: CGRect(x: (ScreenWidth - qrWidth) / 2, y: topHeight, width: qrWidth, height: qrWidth))
        qrCodeFrameView.layer.borderColor = TSColor.main.theme.cgColor
        qrCodeFrameView.layer.borderWidth = 1
        return qrCodeFrameView
        }()

    lazy var tishiLabel: UILabel = {[unowned self] in
        let tishiLabel = UILabel(frame: CGRect(x: 0, y: topHeight + qrWidth, width: ScreenWidth, height: 60))
        tishiLabel.textAlignment = .center
        tishiLabel.font = UIFont.systemFont(ofSize: 15)
        tishiLabel.backgroundColor = UIColor.clear
        tishiLabel.textColor = UIColor.white
//        tishiLabel.text = "将二维码放入条框内，即可自动扫码"
        tishiLabel.numberOfLines = 0
        return tishiLabel
        }()

    lazy var openButton: UIButton = {[unowned self] in
        let openButton = UIButton(frame: CGRect(x: 0, y: topHeight + qrWidth + 60 + (ScreenHeight - 124 - (topHeight + qrWidth + 60)) / 2.0 - 25, width: 50, height: 50))
        openButton.centerX = ScreenWidth / 2.0
        openButton.layer.masksToBounds = true
        openButton.layer.cornerRadius = 25
        openButton.setImage(UIImage(named: "ico_torch"), for: .selected)
        openButton.setImage(UIImage(named: "ico_torch_on"), for: .normal)
        openButton.addTarget(self, action: #selector(openFlashlight), for: UIControlEvents.touchUpInside)
        openButton.isSelected = true
        return openButton
    }()

    /// 扫码动画
    lazy var qrImageView: UIImageView = {[unowned self] in
        let qrImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: qrWidth, height: qrWidth))
        return qrImageView
        }()

    /// 以下是四个背景
    lazy var bgImageView: UIImageView = {[unowned self] in
        let bgImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: topHeight))
        bgImageView.backgroundColor = UIColor.black
        bgImageView.alpha = 0.5
        return bgImageView
        }()

    lazy var bgImageView1: UIImageView = {[unowned self] in
        let bgImageView = UIImageView(frame: CGRect(x: 0, y: topHeight, width: 50, height: qrWidth))
        bgImageView.backgroundColor = UIColor.black
        bgImageView.alpha = 0.5
        return bgImageView
        }()

    lazy var bgImageView2: UIImageView = {[unowned self] in
        let bgImageView = UIImageView(frame: CGRect(x: qrWidth + 50, y: topHeight, width: 50, height: qrWidth))
        bgImageView.backgroundColor = UIColor.black
        bgImageView.alpha = 0.5
        return bgImageView
        }()

    lazy var bgImageView3: UIImageView = {[unowned self] in
        let bgImageView = UIImageView(frame: CGRect(x: 0, y: qrWidth + topHeight, width: ScreenWidth, height: qrHeight - qrWidth - 40))
        bgImageView.backgroundColor = UIColor.black
        bgImageView.alpha = 0.5
        return bgImageView
        }()
    /// 以下是四个角
    lazy var topLeftImageView: UIImageView = {[unowned self] in
        let iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        iconImageView.image = UIImage(named: "icon_frame_o")
        return iconImageView
        }()
    lazy var topRightImageView: UIImageView = {[unowned self] in
        let iconImageView = UIImageView(frame: CGRect(x: qrWidth - 24, y: 0, width: 24, height: 24))
        iconImageView.image = UIImage(named: "icon_frame_t")
        return iconImageView
        }()
    lazy var bottomLeftImageView: UIImageView = {[unowned self] in
        let iconImageView = UIImageView(frame: CGRect(x: 0, y: qrWidth - 24, width: 24, height: 24))
        iconImageView.image = UIImage(named: "icon_frame_r")
        return iconImageView
        }()
    lazy var bottomRightImageView: UIImageView = {[unowned self] in
        let iconImageView = UIImageView(frame: CGRect(x: qrWidth - 24, y: qrWidth - 24, width: 24, height: 24))
        iconImageView.image = UIImage(named: "icon_frame_f")
        return iconImageView
        }()

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = {[
            NSForegroundColorAttributeName: UIColor.black
            ]}()
        self.navigationController?.navigationBar.tintColor = UIColor(hex: 0x2b345c)
        self.navigationController?.navigationBar.shadowImage = nil
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = {[
            NSForegroundColorAttributeName: UIColor.white
            ]}()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        UIApplication.shared.statusBarStyle = .lightContent
        // 开始视频捕获
        captureSession?.startRunning()
        // 开始动画
        qrImageView.startAnimating()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.title = "扫一扫"
        self.createSession()
    }

    // MARK: - 动画
    func setAnimationImages() {
        // 下拉刷新图片数组
        var images: [UIImage] = []
        for index in 1...14 {
            let imageName = "saoma_\(index)"
            let image = UIImage(named: imageName)!
            images.append(image)
        }
        qrImageView.animationImages = images
        qrImageView.animationDuration = 14 * 0.1
    }

    func createSession() {
        // 获得 AVCaptureDevice 对象，用于初始化捕获视频的硬件设备，并配置硬件属性
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            // 通过之前获得的硬件设备，获得 AVCaptureDeviceInput 对象
            let input = try AVCaptureDeviceInput(device: captureDevice)
            // 初始化 captureSession 对象
            captureSession = AVCaptureSession()
            // 给 session 添加输入设备
            captureSession?.addInput(input)
            // 初始化 AVCaptureMetadataOutput 对象，并将它作为输出
            let captureMetadataOutput = AVCaptureMetadataOutput()

            captureSession?.addOutput(captureMetadataOutput)
            // Set delegate and use the default dispatch queue to execute the call back  设置 delegate 并使用默认的 dispatch 队列来执行回调
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes

            // 初始化视频预览 layer，并将其作为 viewPreview 的 sublayer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            // Start video capture. 开始视频捕获
            captureSession?.startRunning()
            // 背景
            view.addSubview(bgImageView)
            view.addSubview(bgImageView1)
            view.addSubview(bgImageView2)
            view.addSubview(bgImageView3)
            // 扫码框
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
            qrCodeFrameView.addSubview(qrImageView)
            // 四个边角
            qrCodeFrameView.addSubview(topLeftImageView)
            qrCodeFrameView.addSubview(topRightImageView)
            qrCodeFrameView.addSubview(bottomLeftImageView)
            qrCodeFrameView.addSubview(bottomRightImageView)
            // 提示
            view.addSubview(messageLabel)
            view.bringSubview(toFront: messageLabel)
            view.addSubview(tishiLabel)
            view.bringSubview(toFront: tishiLabel)
            view.addSubview(openButton)
            view.bringSubview(toFront: openButton)
            self.setAnimationImages()
            // 开始动画
            qrImageView.startAnimating()

        } catch {
            // 如果出现任何错误，仅做输出处理，并返回
            print(error)
            return
        }
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // 检查：metadataObjects 对象不为空，并且至少包含一个元素
        if metadataObjects == nil || metadataObjects.count.isEqualZero {
            return
        }
        // 获得元数据对象
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
            messageLabel.text = "不能识别的二维码！"
            captureSession?.stopRunning()
            qrImageView.stopAnimating()
            return
        }

        if metadataObj.type == AVMetadataObjectTypeQRCode, let result = metadataObj.stringValue {
            if result.contains("redirect?target="), let decodeStr = result.removingPercentEncoding {
                //扫描到了用户uid

                let urlArray = decodeStr.components(separatedBy: "/")
                if let uid = urlArray.last {
                    captureSession?.stopRunning()
                    qrImageView.stopAnimating()
                    self.navigationController?.popViewController(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "saoyisaouid"), object: nil, userInfo: ["uid": uid])
                    return
                }
            }
        }
        messageLabel.text = "不能识别的二维码！"
        captureSession?.stopRunning()
        qrImageView.stopAnimating()
    }

    func getDictionaryFromJSONString(jsonString: String) -> NSDictionary {

        let jsonData: Data = jsonString.data(using: .utf8)!

        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }

    func openFlashlight(_ sender: UIButton) {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if device == nil {
            sender.isEnabled = false
            return
        }
        if device?.torchMode == AVCaptureTorchMode.off {
            do {
                try device?.lockForConfiguration()
            } catch {
                return
            }
            device?.torchMode = .on
            device?.unlockForConfiguration()
            sender.isSelected = false
        } else {
            do {
                try device?.lockForConfiguration()
            } catch {
                return
            }
            device?.torchMode = .off
            device?.unlockForConfiguration()
            sender.isSelected = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
