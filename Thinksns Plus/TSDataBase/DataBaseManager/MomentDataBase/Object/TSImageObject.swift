//
//  TSImageObject.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  图片数据表模型

import UIKit
import RealmSwift

class TSImageObject: Object {
    // 缓存标示
    dynamic var cacheKey: String = ""
    // 主要用于图片保存到本地的key
    var locCacheKey: String = ""
    // 图片资源本地唯一标识
    dynamic var storageIdentity: Int = 0
    // 宽度 单位:像素
    dynamic var width: CGFloat = 0
    // 高度 单位:像素
    dynamic var height: CGFloat = 0
    /// 图片类型
    dynamic var mimeType: String = ""

     // MARK: - V2 数据

    /// 是否在加载时清除缓存
    dynamic var shouldCleanCache = false

    /// 收费方式
    dynamic var type: String?

    /// 当前用户是否已经付费
    let paid = RealmOptional<Bool>()
    /// 付费节点
    let node = RealmOptional<Int>()
    /// 付费金额
    let amount = RealmOptional<Int>()
    // 发布时，图片的付费方式 0 表示发布时不付费，2 表示查看收费， 1 表示下载收费
    dynamic var payType = -1
    // 发布时，图片的付费价格
    dynamic var price = 0

    /// 设置主键
    override static func primaryKey() -> String? {
        return "storageIdentity"
    }

    /// 获取图片压缩比
    ///
    /// - Parameter factWidth: 图片展示宽度
    /// - Returns: 压缩比
    func getImageRatio(factWidth: CGFloat) -> Int {
        let fact = width
        // 过滤一下数据
        if fact == 0 {
            return 100
        }
        // 使用需要显示的宽度 除以 真实宽度 的百分比
        var ratio = Int(factWidth / fact * CGFloat(100))
        if ratio > 100 {
            ratio = 100
        }
        if ratio < 1 {
            ratio = 1
        }
        return ratio
    }

    /// 判断图片是否为长图
    func isLongPic() -> Bool {
        let screenRatio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
        let picRatio = height / width
        return picRatio / screenRatio > 3
    }
}

extension TSImageObject {
    func set(shouldChangeCache shouldChange: Bool) {
        let realm = try! Realm()
        realm.beginWrite()
        self.shouldCleanCache = shouldChange
        realm.add(self, update: true)
        try! realm.commitWrite()
    }
}
