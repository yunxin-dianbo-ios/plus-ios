//
//  BuildGroupModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  创建圈子 需要使用的数据模型

import UIKit

class BuildGroupModel {

    enum LocationInfo {
        /// 不显示位置
        case unshow
        /// 位置信息 (location 地区, latitude 纬度, longitude 经度, geoHash)
        case location(String, String, String, String)

        func isEqual(to otherLocal: LocationInfo) -> Bool {
            switch (otherLocal, self) {
            case (.unshow, .unshow):
                return true
            case (.location(let oldlocation, let oldlatitude, let oldlongtitude, let oldgeohash), .location(let location, let latitude, let longtitude, let geohash)):
                return oldlocation == location && oldlatitude == latitude && oldlongtitude == longtitude && oldgeohash == geohash
            default:
                return false
            }
        }
    }

    /// 封面图
    var coverImage: UIImage?
    var coverImageUrl = ""
    /// 圈名
    var name = ""
    /// 分类
    var categoryId = 0
    /// 分类名称
    var categoryName = ""
    /// 标签
    var tagIds: [Int] = []
    var tagNames: [String] = []
    /// 位置信息
    var locationInfo: LocationInfo? = .unshow
    /// 简介
    var intro = ""
    /// 同步到动态
    var allowFeed = false
    /// 圈子类型
    /// 圈子类型:public: 公开，private：私有，paid：付费的
    var mode = "public"
    /// 入圈付费积分金额，当 mode = "paid"
    var money = 0
    /// 公告
    var notice = ""

    init() {
    }

    /// 通过后台返回的网络 model 来初始化
    init(groupModel model: GroupModel) {
        coverImageUrl = TSUtil.praseTSNetFileUrl(netFile:  model.avatar) ?? ""
        name = model.name
        categoryId = model.categoryInfo.id
        categoryName = model.categoryInfo.name
        tagIds = model.tags.map { $0.id }
        tagNames = model.tags.map { $0.name }
        if model.location.isEmpty {
            locationInfo = .unshow
        } else {
            locationInfo = .location(model.location, model.latitude, model.longtitude, model.geoHash)
        }
        intro = model.summary
        allowFeed = model.allowFeed
        mode = model.mode
        money = model.money
        notice = model.notice
    }

    /// 获取通用的 tag models
    func getTagModels() -> [TSCategoryIdTagModel] {
        var models: [TSCategoryIdTagModel] = []
        for (index, tagId) in tagIds.enumerated() {
            let tagName = tagNames[index]
            let model = TSCategoryIdTagModel()
            model.tagId = tagId
            model.tagName = tagName
            models.append(model)
        }
        return models
    }

    /// 检查 model 的信息是否满足创建圈子
    func canBuildGroup() -> Bool {
        // 1.必须要上传头像
        if coverImage == nil && coverImageUrl.isEmpty {
            return false
        }
        // 2.必须要输入圈名
        if name.isEmpty {
            return false
        }
        // 3.必须要选择分类
        if categoryId < 1 {
            return false
        }
        // 4.必须要选择标签
        if tagIds.isEmpty {
            return false
        }
        // 5.需求可以不填写位置信息

        // 6.必须要选择圈子类型
        if mode.isEmpty {
            return false
        }
        // 7.如果是付费圈子，必须选择金额
        if mode == "paid", money == 0 {
            return false
        }
        return true
    }

}
