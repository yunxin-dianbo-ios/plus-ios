//
//  ImagePickerTool.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/28.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit

extension NSNotification.Name {

    public struct ImagePicker {
        public static let camera = NSNotification.Name("com.tsImagePicker.camera")
        public static let finish = NSNotification.Name("com.thImagePicker.finish")
    }
}

func CGLog<T>(message: T, method: String = #function, line: Int = #line) {
    #if DEBUG
        print("\(method)[\(line)]: \(message)")
    #endif
}

extension UIImage {

    /// 裁切图片
    ///
    /// - Parameter rect: 裁切大小，单位是 px
    /// - Returns: 裁切后的图片
    func cropImage(rect: CGRect) -> UIImage? {
        guard let cgImage = cgImage else {
            return nil
        }
        // 检查 rect 是否超出图片裁剪范围
        guard rect.width + rect.minX <= size.width, rect.height + rect.minY <= size.height else {
            CGLog(message: "裁剪范围超出了图片的大小")
            return nil
        }

        let cropX = rect.minX
        let cropY = rect.minY
        let cropWidth = rect.width
        let cropHeight = rect.height
        var cropRect: CGRect!

        if imageOrientation == .up {
            cropRect = rect
        }
        if imageOrientation == .down {
            cropRect = CGRect(x: size.width - cropWidth - cropX, y: size.height - cropHeight - cropY, width: cropWidth, height: cropHeight)
        }
        if imageOrientation == .left {
            cropRect = CGRect(x: size.height - cropHeight - cropY, y: cropX, width: cropHeight, height: cropWidth)
        }
        if imageOrientation == .right {
            cropRect = CGRect(x: cropY, y: size.width - cropWidth - cropX, width: cropHeight, height: cropWidth)
        }
        if imageOrientation == .upMirrored {
            cropRect = CGRect(x: size.width - cropWidth - cropX, y: cropY, width: cropWidth, height: cropHeight)
        }
        if imageOrientation == .downMirrored {
            cropRect = CGRect(x: cropX, y: size.height - cropHeight - cropY, width: cropWidth, height: cropHeight)
        }
        if imageOrientation == .leftMirrored {
            cropRect = CGRect(x: cropY, y: cropX, width: cropHeight, height: cropWidth)
        }
        if imageOrientation == .rightMirrored {
            cropRect = CGRect(x: size.height - cropHeight - cropY, y: size.width - cropWidth - cropX, width: cropHeight, height: cropWidth)
        }
        let cropCGImage = cgImage.cropping(to: cropRect)

        return UIImage(cgImage: cropCGImage!, scale: scale, orientation: imageOrientation)
    }

    /// 裁切照片
    ///
    /// - Note: 手机镜头实际捕获的图片，其宽高比和手机屏幕的宽高比是不同的，所以需要将其
    ///
    /// - Returns: 裁切成屏幕大小的图片
    func cameraImage() -> UIImage {
        // 1.计算裁切的宽高和坐标
        let screenSize = UIScreen.main.bounds.size

        let multiple = size.height / screenSize.height
        let cropWidth = screenSize.width * multiple
        let cropHeight = size.height
        let cropX = (size.width - cropWidth) / 2
        let cropRect = CGRect(x: cropX, y: 0, width: cropWidth, height: cropHeight)

        let cropImage = self.cropImage(rect: cropRect)
        return cropImage!
    }

    /// 获取镜像图片
    func mirrorImage() -> UIImage {
        return UIImage(cgImage: cgImage!, scale: scale, orientation: UIImageOrientation(rawValue: imageOrientation.rawValue + 3)!)
    }
}
