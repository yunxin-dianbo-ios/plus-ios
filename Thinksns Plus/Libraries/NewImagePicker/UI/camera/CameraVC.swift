//
//  CameraVC.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/26.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController, CameraViewDeleagate {

    /// 闪光灯按钮
    @IBOutlet weak var buttonForFlash: UIButton!

    /// 相机视图
    let cameraView: CameraView = {
        let cameraView = CameraView(frame: UIScreen.main.bounds)
        cameraView.backgroundColor = UIColor.black
        cameraView.frame = UIScreen.main.bounds
        return cameraView
    }()

    /// 提供用户确定相片的视图
    let confirmView: CameraMakeSureView = {
        let view = CameraMakeSureView.viewForConfirm()
        return view
    }()

    /// 是否保存拍好的图片，default 是不保存
    public var saveImage = false

    /// 结束拍照后的操作
    public var finishBlock: ((UIImage) -> Void)?
    /// 父控制器
    weak var superVC: AlbumCollectionVC?

    // MARK: - Lifecycle
    class func camera() -> CameraVC {
        let sb = UIStoryboard(name: "CameraVC", bundle: nil)
        let cameraVC = sb.instantiateInitialViewController() as! CameraVC
        return cameraVC
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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.insertSubview(cameraView, at: 0)
        if confirmView.superview != nil {
            view.insertSubview(confirmView, at: view.subviews.endIndex)
        }
    }

    // MARK: - Custom user interface
    func setUI() {
        view.backgroundColor = UIColor.black
        cameraView.delegate = self

        confirmView.frame = view.bounds
        confirmView.buttonForConfirm.addTarget(self, action: #selector(comfirButtonTaped), for: .touchUpInside)
        confirmView.buttonForCancel.addTarget(self, action: #selector(cancelButtonTaped), for: .touchUpInside)

        view.addSubview(cameraView)
    }

    // MARK: - Button click

    /// 取消按钮点击事件
    func cancelButtonTaped() {
        if confirmView.superview != nil {
            confirmView.removeFromSuperview()
        }
    }

    /// 确认按钮点击事件
    func comfirButtonTaped() {
        guard let image = confirmView.imageView.image else {
            CGLog(message: "没有图片")
            return
        }
        // 1.判断是否需要保存图片
        if saveImage {
            // 需要，保存图片
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            // 不需要，执行结束操作
            cancelButtonTaped()
            finishBlock?(image)
        }
    }

    /// 保存图片反馈
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        guard error == nil else {
            CGLog(message: error?.localizedDescription)
            return
        }
        CGLog(message: "save success")
        cancelButtonTaped()
        finishBlock?(image)
    }

    // MARK: - Public
    public func setFinish(operation: ((UIImage) -> Void)?) {
        finishBlock = operation
    }

    // MARK: - IBAction

    /// 点击了切换镜头
    @IBAction func swapButtonTaped(_ sender: UIButton) {
        cameraView.swap()
        let orientation = cameraView.config.device?.position
        // 如果是前置摄像头，关闭闪光灯
        buttonForFlash.isEnabled = orientation == .front ? false : true
    }

    /// 点击了关闭
    @IBAction func closeButtonTaped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    /// 点击了闪光灯
    @IBAction func flashButtonTaped(_ sender: UIButton) {
        cameraView.switchFlash()
        let buttonImage = UIImage(named: cameraView.isflashOpen ? "img_camera_flashOn" : "img_camera_flashOff")
        sender.setImage(buttonImage, for: .normal)
    }

    /// 点击了照相
    @IBAction func takePhoto() {
        cameraView.takePhoto()
    }

    // MARK: - Delegate

    // MARK: CameraViewDeleagate
    func camera(view: CameraView, finishTakePhoto image: UIImage?) {
        guard let image = image, confirmView.superview == nil else {
            return
        }
        let cropImage = image.cameraImage()
        confirmView.imageView.image = cropImage
        view.addSubview(confirmView)
    }

}
