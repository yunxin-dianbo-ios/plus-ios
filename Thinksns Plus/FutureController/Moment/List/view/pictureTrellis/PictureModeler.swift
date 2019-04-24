//
//  PictureViewerModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/10/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

extension Notification.Name {

    /// 记录圈子相关的通知
    public struct PaidImage {
        /// 用户购买了一张付费图片
        ///
        /// - Note: let userInfo: [String: Any] = ["imageId": String]
        public static let buyPic = NSNotification.Name(rawValue: "com.ts-plus.notification.name.pic.buy")
    }
}

class PictureModeler {

    /// 图片网络链接
    var url: String?
    /// 图片缓存地址
    var cache: String?
    /// 图片原始的大小
    var originalSize = CGSize.zero
    /// 加载图片时是否要清空旧的图片缓存
    var shouldClearCache = false
    /// 是否需要显示长图标识
    var shouldShowLongicon = false
    /// 没有被显示的图片的数量，小于 0 则不显示数量蒙层
    var unshowCount = 0
    /// 图片类型
    var mimeType: String = ""

    // MARK: Object
    func object() -> PictureObject {
        let object = PictureObject()
        object.url = url
        object.cache = cache
        object.originalWidth = originalSize.width
        object.originalHeight = originalSize.height
        object.shouldClearCache = shouldClearCache
        object.shouldShowLongicon = shouldShowLongicon
        object.mimeType = mimeType
        return object
    }
}

class PaidPictureModel: PictureModeler {
    /// 付费信息，为 nil 则表示不用付费
    var paidInfo: PaidInfo?

    override init() {
        super.init()
    }

    /// 初始化动态列表图片
    init(feedImageModel model: FeedImageModel) {
        super.init()
        assert(model.file >= 0)
        url = model.file.imageUrl()
        originalSize = model.size
        shouldShowLongicon = true
        mimeType = model.mimeType
        // 如果用户没有购买
        if !model.paid {
            paidInfo = PaidInfo()
            if model.type == "download" { // 下载付费
                paidInfo?.type = .pictureDownload
            } else if model.type == "read" { // 查看付费
                paidInfo?.type = .pictureSee
            }
            paidInfo?.node = model.node
            paidInfo?.price = Double(model.amount)
        }
    }

    /// 初始化帖子列表图片
    init(postImageModel model: PostImageModel) {
        super.init()
        url = model.id.imageUrl()
        originalSize = model.size
        shouldShowLongicon = true
        mimeType = model.mimeType
    }

    /// 初始化帖子列表图片
    init(topicPostImageModel model: TopicPostImageModel) {
        super.init()
        url = model.id.imageUrl()
        originalSize = model.size
        shouldShowLongicon = true
        mimeType = model.mimeType
    }

    init(object: PaidPictureObject) {
        super.init()
        url = object.url
        cache = object.cache
        originalSize = CGSize(width: object.originalWidth, height: object.originalHeight)
        shouldClearCache = object.shouldClearCache
        shouldShowLongicon = object.shouldShowLongicon
        mimeType = object.mimeType
        if let paidObject = object.paidInfo {
            paidInfo = PaidInfo(object: paidObject)
        }
    }

    // MARK: Object
    override func object() -> PaidPictureObject {
        let object = PaidPictureObject()
        object.url = url
        object.cache = cache
        object.originalWidth = originalSize.width
        object.originalHeight = originalSize.height
        object.shouldClearCache = shouldClearCache
        object.shouldShowLongicon = shouldShowLongicon
        object.paidInfo = paidInfo?.object()
        object.mimeType = mimeType
        return object
    }

    // MARK: - 等我把 ImageObject 删了，就可以吧这两个方法也删了
    func imageObject() -> TSImageObject {
        let object = TSImageObject()
        if let imageUrl = url {
            let subIndex = (TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue as NSString).length
            if let fileId = Int((imageUrl as NSString).substring(from: subIndex + 1)) {
                object.storageIdentity = fileId
            }
        }
        object.cacheKey = cache ?? ""
        object.width = originalSize.width
        object.height = originalSize.height
        object.mimeType = mimeType
        object.paid.value = true
        if let paidInfo = paidInfo, paidInfo.node != 0, paidInfo.price != 0 {
            object.paid.value = false
            if paidInfo.type == .pictureSee {
                object.type = "read"
            }
            if paidInfo.type == .pictureDownload {
                object.type = "download"
            }
            object.node.value = paidInfo.node
            object.amount.value = Int(paidInfo.price)
        }
        return object
    }

    init(imageObject object: TSImageObject) {
        super.init()
        cache = object.cacheKey
        originalSize = CGSize(width: object.width, height: object.height)
        shouldClearCache = false
        shouldShowLongicon = true
        mimeType = object.mimeType
        if let node = object.node.value, let amount = object.amount.value {
            paidInfo = PaidInfo()
            if object.payType == 1 { // 下载付费
                paidInfo?.type = .pictureDownload
            } else if object.payType == 2 { // 查看付费
                paidInfo?.type = .pictureSee
            }
            paidInfo?.node = node
            paidInfo?.price = Double(amount)
        }
    }
}

extension Int {
    func imageUrl() -> String {
        return TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue + "/\(self)"
    }
}

extension String {
    func imageUrl() -> String {
        return TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue + "/" + self
    }
}
