//
//  TSUIImageExtension.swift
//  Thinksns Plus
//
//  Created by GorCat on 16/12/21.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  TSUIImageExtension

import UIKit

extension UIImage {

    /// 生成纯色图片
    ///
    /// - Parameters:
    ///   - color: 纯色的颜色
    ///   - size: 尺寸
    /// - Returns: 生成后的图片
    class func create(with color: UIColor, size: CGSize) -> UIImage {
        if size == CGSize.zero {
            return UIImage()
        }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    /// 将图片裁切成圆形
    func circularImage(size: CGSize?) -> UIImage {
        let newSize = size ?? self.size

        let minEdge = min(newSize.height, newSize.width)
        let size = CGSize(width: minEdge, height: minEdge)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()

        draw(in: CGRect(origin: .zero, size: size), blendMode: .copy, alpha: 1)
        context?.setBlendMode(.copy)
        context?.setFillColor(UIColor.clear.cgColor)

        let rectPath = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size))
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
        rectPath.append(circlePath)
        rectPath.usesEvenOddFillRule = true
        rectPath.fill()

        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return result!
    }

    class func imageWithColor(_ color: UIColor!, cornerRadius: Double!) -> UIImage {
        let minEdgeSize: Double = cornerRadius * 2.0 + 1.0
        let rect = CGRect(x: 0.0, y: 0.0, width: minEdgeSize, height: minEdgeSize)
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(cornerRadius))
        roundedRect.lineWidth = 0
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        roundedRect.fill()
        roundedRect.stroke()
        roundedRect.addClip()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return (image?.resizableImage(withCapInsets: UIEdgeInsets(top: CGFloat(cornerRadius), left: CGFloat(cornerRadius), bottom: CGFloat(cornerRadius), right: CGFloat(cornerRadius))))!
    }

    /// 图片灰度处理
    ///
    /// - Parameter image: 图片对象
    /// - Returns: 灰度图片
    class func getGrayImage(image: UIImage) -> UIImage {
        let imageHeight = image.size.height
        let imageWidth = image.size.width

        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: nil, width: Int(imageWidth), height: Int(imageHeight), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
        if context == nil {
            return UIImage.imageWithColor(TSColor.normal.disabled, cornerRadius: 0)
        }

        context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        return UIImage(cgImage: context!.makeImage()!)
    }

    /// 通过颜色生成一张纯色图片
    class func colorImage(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    /// 渲染图片色调
    ///
    /// - warning : 该方法有较高的性能消耗
    func set(tintColor: UIColor) -> UIImage {
        var newImage = self.withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        tintColor.set()
        newImage.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    /// 普通的图片转到TSImageObject对象
    func imageToTSImageObject() -> TSImageObject {
        let object = TSImageObject()
        object.storageIdentity = 0
        object.cacheKey = ""
        object.width = self.size.width
        object.height = self.size.height
        object.paid.value = true
        object.type = "download"
        return object
    }
}

public extension UIImage {

    /**
     *  按照指定宽度进行等比例重绘
     */
    public func reWidthImage(width: CGFloat) -> UIImage {
        let newsize = CGSize(width: width, height: self.size.height / self.size.width * width)
        return self.reSizeImage(reSize: newsize)
    }

    /**
     *  重设图片大小
     */
    func reSizeImage(reSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(reSize)
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    /**
     *  等比率缩放
     */
    func scaleImage(scale: CGFloat) -> UIImage {
        let reSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        return self.reSizeImage(reSize: reSize)
    }
}

public extension UIImage {
    static func base64ForJpgImage(_ image: UIImage) -> String {
        guard let imgData = UIImageJPEGRepresentation(image, 1.0) else {
            return ""
        }
        return imgData.base64EncodedString()
    }
}
