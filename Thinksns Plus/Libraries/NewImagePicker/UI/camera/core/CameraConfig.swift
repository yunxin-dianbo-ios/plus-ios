//
//  CameraConfig.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/28.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import AVFoundation

class CameraConfig: NSObject {

    let cameraQueue = DispatchQueue(label: "com.zero.ALCameraViewController.Queue")

    /// 捕获管理类
    var session = AVCaptureSession()
    /// 捕获输入
    var input: AVCaptureDeviceInput?
    /// 设备管理
    var device: AVCaptureDevice?
    /// 捕获输出
    var output: AVCaptureOutput?
    /// 预览视图
    var preview: AVCaptureVideoPreviewLayer?

    // MARK: - Lifecycle

    /// 初始化
    ///
    /// - Parameter position: 摄像镜头位置
    init(position: AVCaptureDevicePosition) {
        super.init()
        configOutput()
        configInput(position: position)
        configSession()
    }

    // MARK: - Public

    /// 开启摄像镜头
    ///
    /// - Parameter complete: 镜头预览视图
    public func starSession(complete: @escaping(AVCaptureVideoPreviewLayer) -> Void) {
        cameraQueue.async { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.session.startRunning()
            DispatchQueue.main.async() { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.preview = AVCaptureVideoPreviewLayer(session: weakSelf.session)
                weakSelf.preview?.videoGravity = AVLayerVideoGravityResizeAspectFill
                complete(weakSelf.preview!)
            }
        }
    }

    /// 切换镜头
    ///
    /// - Parameter newPosition: 镜头位置
    public func swap(position newPosition: AVCaptureDevicePosition) {
        // 1.开始配置 session，移除旧的输入捕获配置
        session.beginConfiguration()
        session.removeInput(input)

        // 2.更新 intput，给 session 添加新的 intput
        configInput(position: newPosition)
        session.addInput(input)

        // 3.结束配置 session
        session.commitConfiguration()
    }

    // MARK: - Config
    /// 配置 session
    private func configSession() {
        guard let input = input, let output = output else {
            return
        }
        session.sessionPreset = AVCaptureSessionPresetPhoto
        session.addInput(input)
        session.addOutput(output)
    }

    /// 设置 输出捕获
    private func configOutput() {
        guard #available(iOS 10, *) else {
            // 1.iOS 10 以下，使用 AVCaptureStillImageOutput
            let stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            output = stillImageOutput
            return
        }
        // 2.iOS 10 以上，使用 AVCapturePhotoOutput
        let photoOutput = AVCapturePhotoOutput()
        output = photoOutput
    }

    /// 设置 输入捕获
    private func configInput(position: AVCaptureDevicePosition) {
        // 1.获得摄像镜头
        getDevice(position: position)
        // 2.创建 输入捕获
        guard let device = device else {
            return
        }
        input = try! AVCaptureDeviceInput(device: device)
    }

    /// 获取摄像镜头
    ///
    /// - Parameter currentPosition: 摄像头位置
    private func getDevice(position currentPosition: AVCaptureDevicePosition) {
        guard #available(iOS 10, *) else {
            // 1.iOS 10 以下，使用 AVCaptureDevice
            if let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] {
                device = devices.filter { $0.position == currentPosition }.first
            }
            // 设置 flashMode
            if device?.hasFlash == true {
                try! device?.lockForConfiguration()
                device?.flashMode = .off
                device?.unlockForConfiguration()
            }
            return
        }
        // 2.iOS 10 以上，使用 AVCaptureDeviceDiscoverySession
        let deviceSession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: currentPosition)
        if let devices = deviceSession?.devices {
            device = devices.filter { $0.position == currentPosition }.first
        }
    }
}
