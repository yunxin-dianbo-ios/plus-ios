//
//  CameraView.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/26.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewDeleagate: class {
    func camera(view: CameraView, finishTakePhoto image: UIImage?)
}

class CameraView: UIView, AVCapturePhotoCaptureDelegate {

    let cameraQueue = DispatchQueue(label: "com.zero.ALCameraViewController.Queue")

    /// 代理
    weak var delegate: CameraViewDeleagate?

    /// 摄像配置
    let config = CameraConfig(position: .back)
    /// 预览视图
    var preview: AVCaptureVideoPreviewLayer?

    /// 是否开启闪光灯
    var isflashOpen = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        startSession()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Custom user interface

    // 开启相机
    func startSession() {
        config.starSession { [weak self] (preview) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.preview = preview
            weakSelf.preview?.frame = weakSelf.bounds
            weakSelf.layer.addSublayer(weakSelf.preview!)
        }
    }

    // MARK: - Public

    /// 照相
    func takePhoto() {
        // 1.iOS 10 以下，通过 AVCaptureStillImageOutput 的 block 返回相片
        guard #available(iOS 10, *) else {

            let stillImageOutput = config.output as! AVCaptureStillImageOutput
            let orientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
            let connection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo)
            connection?.videoOrientation = orientation
            stillImageOutput.captureStillImageAsynchronously(from: connection, completionHandler: { [weak self] (buffer: CMSampleBuffer?, _) in
                guard let weakSelf = self, let buffer = buffer else {
                    return
                }
                guard let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer) else {
                    return
                }
                var image = UIImage(data: data)
                // 如果是前置摄像头，镜像一下图片
                if weakSelf.config.device?.position == .front {
                    image = image?.mirrorImage()
                }
                weakSelf.delegate?.camera(view: weakSelf, finishTakePhoto: image)
            })
            return
        }

        // 2.iOS 10 以上，通过 AVCapturePhotoOutput 的 代理方法 返回相片
        guard let photoOutput = config.output as? AVCapturePhotoOutput else {
            return
        }
        let setting = AVCapturePhotoSettings()
        setting.flashMode = isflashOpen ? .on : .off
        // 如果是前置摄像头，关闭闪光灯
        if config.device?.position == .front {
            setting.flashMode = .off
        }
        photoOutput.capturePhoto(with: setting, delegate: self)
    }

    /// 切换镜头
    func swap() {
        // 1.获取新的镜头方向
        let currentPosition = config.input?.device.position
        let newPosition: AVCaptureDevicePosition = currentPosition == .back ? .front : .back
        // 2.切换镜头
        config.swap(position: newPosition)

        // 3.如果是 iOS 10，在切换前置后置摄像头时，需要设置一下闪光灯
        guard #available(iOS 10, *) else {
            guard config.device?.hasFlash == true else {
                return
            }
            try! config.device?.lockForConfiguration()
            if newPosition == .front {
                // 前置时，关闭赏光
                config.device?.flashMode = .on
            } else {
                // 后置时，开启闪光设置
                config.device?.flashMode = isflashOpen ? .on : .off
            }
            config.device?.unlockForConfiguration()
            return
        }
    }

    /// 切换闪光灯
    func switchFlash() {
        // 1.iOS 10 以上，通过 output 设置闪光灯
        isflashOpen = !isflashOpen

        // 2.iOS 10 以下，通过 device 设置闪光灯
        guard config.device?.hasFlash == true else {
            return
        }
        guard  #available(iOS 10, *) else {
            try! config.device?.lockForConfiguration()
            config.device?.flashMode = isflashOpen ? .on : .off
            config.device?.unlockForConfiguration()
            return
        }
    }

    // MARK: - Delegate

    // MARK: - AVCapturePhotoCaptureDelegate
    @available(iOS 10.0, *)
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        guard let sampleBuffer = photoSampleBuffer else {
            return
        }
        guard let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }
        var image = UIImage(data: data)
        // 如果是前置摄像头，镜像一下图片
        if config.device?.position == .front {
            image = image?.mirrorImage()
        }
        delegate?.camera(view: self, finishTakePhoto: image)
    }

}
