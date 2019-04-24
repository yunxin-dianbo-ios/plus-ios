//
//  GroupNetworkManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子 网络请求管理类

import UIKit

import Alamofire

class GroupNetworkManager {

}

// MARK: - 圈子列表
extension GroupNetworkManager {

    /// 获取圈子分类
    class func getGroupCategories(complete: @escaping ([GroupCategoriesModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().categroies
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.models, nil, true)
            }
        }
    }

    /// 分类下圈子列表
    ///
    /// - Parameters:
    ///   - categoriesId: 分类 id
    ///   - limit: 默认 20 ，数据返回条数 默认为20
    ///   - offset: 默认 0 ，数据偏移量，传递之前通过接口获取的总数。
    ///   - complete: 结果
    class func getGroups(categoriesId: Int, limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, complete: @escaping ([GroupModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().categroiesGroups
        request.urlPath = request.fullPathWith(replacers: ["\(categoriesId)"])
        // 2.配置参数
        let parameters: [String: Any] = ["offset": offset, "limit": limit]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.models, nil, true)
            }
        }
    }

    /// 全部圈子列表
    ///
    /// - Parameters:
    ///   - categoriesId: 圈子分类id
    ///   - keyword: 用于搜索圈子，按圈名搜索
    ///   - limit: 默认 20 ，数据返回条数 默认为20
    ///   - offset: 默认 0 ，数据偏移量，传递之前通过接口获取的总数。
    ///   - complete: 结果
    class func getAllGroups(categoriesId: Int?, keyword: String?, limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, complete: @escaping ([GroupModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().allGroups
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["offset": offset, "limit": limit]
        if let categoriesId = categoriesId {
            parameters.updateValue(categoriesId, forKey: "category_id")
        }
        if let keyword = keyword {
            parameters.updateValue(keyword, forKey: "keyword")
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.models, nil, true)
            }
        }
    }

    /// 推荐圈子列表
    ///
    /// - Parameters:
    ///   - type: random 随机获取，可以为空
    ///   - limit: 默认 20 ，数据返回条数 默认为20
    ///   - offset: 默认 0 ，数据偏移量，传递之前通过接口获取的总数。
    ///   - complete: 结果
    class func getRecommendGroups(type: String = "random", limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, complete: @escaping ([GroupModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().recommendGroups
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["offset": offset, "limit": limit]
        if !type.isEmpty {
            parameters.updateValue(type, forKey: "type")
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.models, nil, true)
            }
        }
    }

    /// 我的圈子列表
    ///
    /// - Parameters:
    ///   - type: 默认: join, join 我加入 audit 待审核，可以为空 allow_post 可以发帖的
    ///   - limit: 默认 20 ，数据返回条数 默认为20
    ///   - offset: 默认 0 ，数据偏移量，传递之前通过接口获取的总数。
    ///   - complete: 结果
    class func getMyGroups(type: String = "join", limit: Int = TSAppConfig.share.localInfo.limit, offset: Int, complete: @escaping ([GroupModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().myGroups
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["offset": offset, "limit": limit]
        if !type.isEmpty {
            parameters.updateValue(type, forKey: "type")
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.models, nil, true)
            }
        }
    }

    /// 圈子详情信息
    class func getGroupInfo(groupId: Int, complete: @escaping (GroupModel?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().groupInfo
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.model, nil, true)
            }
        }
    }

    /// 圈子总数
    class func getGroupsCount(complete: @escaping (GroupsInfoModel?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().groupsCount
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.model, nil, true)
            }
        }
    }

    /// 加入圈子
    class func joinGroup(groupId: Int, complete: @escaping (Bool, String?) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().joinGroup
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        var parametars: [String : Any] = [:]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parametars.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        request.parameter = parametars
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败")
            case .failure(let faild):
                complete(false, faild.message)
            case .success(let success):
                var message = success.message
                if let dic = success.sourceData as? [String: Any], let successInfo = dic["message"] as? String {
                    message = successInfo
                }
                complete(true, message)
            }
        }
    }

    /// 退出圈子
    class func exitGroup(groupId: Int, complete: @escaping (Bool, String?) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().exitGroup
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败")
            case .failure(let faild):
                complete(false, faild.message)
            case .success(let success):
                var message = success.message
                if let dic = success.sourceData as? [String: Any], let successInfo = dic["message"] as? String {
                    message = successInfo
                }
                complete(true, message)
            }
        }
    }

    /// 获取创建圈子的协议
    class func getBuildAgreement(complete: @escaping (Bool, String?, String?) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().buildAgreement
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败", nil)
            case .failure(let faild):
                complete(false, faild.message, nil)
            case .success(let success):
                var message = success.message
                if let dic = success.sourceData as? [String: Any], let successInfo = dic["message"] as? String {
                    message = successInfo
                }
                complete(true, message, success.model?.agreement)
            }
        }
    }

    /// 创建圈子
    ///
    /// - Parameters:
    ///   - category: 圈子分类 id
    ///   - cover: 封面图
    ///   - name: 圈子名称
    ///   - tags: 必须 圈子标签 格式:[{id:1},{id:3}...]
    ///   - mode: 必须 圈子类别 public: 公开，private：私有，paid：付费的
    ///   - intro: 圈子简介
    ///   - notice: 圈子公告
    ///   - money: 收费圈子进圈金额，单位 gold，如果 mode 为 paid 必须存在
    ///   - allowFeed: 是否允许同步动态 同步需要传 1
    ///   - (String, String, String, String): (location 地区, latitude 纬度, longitude 经度, geoHash) 4 个值必须一同存在
    ///   - complete: 结果
    class func buildGroup(category: Int, cover: UIImage, name: String, tags: [Int], mode: String, intro: String?, notice: String?, money: Int?, allowFeed: Bool, locationInfo: (String, String, String, String)?, complete: @escaping (String?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().buildGroup
        request.urlPath = request.fullPathWith(replacers: ["\(category)"])
        // 2.配置参数
        var parameters: [String: Any] = ["name": name, "tags": tags, "mode": mode, "allow_feed": allowFeed ? "1" : "0"]
        if mode == "paid", let money = money {
            // 注：收费入圈价格由之前的金额更正为积分，且这里应传入整数类型的参数
            parameters.updateValue("\(money)", forKey: "money")
        }
        if let intro = intro {
            parameters.updateValue(intro, forKey: "summary")
        }
        if let notice = notice {
            parameters.updateValue(notice, forKey: "notice")
        }
        if let (location, latitude, longitude, geoHash) = locationInfo {
            parameters.updateValue(location, forKey: "location")
            parameters.updateValue(latitude, forKey: "latitude")
            parameters.updateValue(longitude, forKey: "longitude")
            parameters.updateValue(geoHash, forKey: "geo_hash")
        }
        // 将 image 转成 data
        guard let imageData = UIImageJPEGRepresentation(cover, 1) else {
            return
        }
        // 自定义header
        let authorization = TSCurrentUserInfo.share.accountToken?.token
        var coustomHeaders: HTTPHeaders = ["Accept": "application/json"]
        if let authorization = authorization {
            let token = "Bearer " + authorization
            coustomHeaders.updateValue(token, forKey: "Authorization")
        }
        // 发起网络请求
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            // 添加图片 file
            multipartFormData.append(imageData, withName: "avatar", fileName: "avatar", mimeType: "image/jpeg")
            // 添加其他参数
            for (key, val) in parameters {
                if let stringValue = val as? String {
                    multipartFormData.append(stringValue.data(using: String.Encoding.utf8)!, withName: key)
                }
                if key == "tags", let tags = val as? [Int] {
                    for tagId in tags {
                        multipartFormData.append("\(tagId)".data(using: String.Encoding.utf8)!, withName: "tags[][id]")
                    }
                }
            }
        }, usingThreshold: 0, to: TSAppConfig.share.rootServerAddress + request.urlPath, method: .post, headers: coustomHeaders, encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if response.result.isSuccess {
                        let resultDic = response.result.value as! Dictionary<String, Any>
                        // 后台返回错误信息
                        if let errorDic = resultDic["errors"] as? [String: Any] {
                            if let message = errorDic["message"] as? String {
                            complete(message, false)
                            return
                            }
                            if let message = resultDic["message"] as? String {
                                complete(message, false)
                                return
                            }
                        }
                        // 后台返回正确信息
                        if let message = resultDic["message"] as? String {
                            complete(message, true)
                            return
                        }
                        // 后台返回了报错信息
                        // 比如未认证等情况
                        if let message = resultDic["message"] as? Array<String> {
                            complete(message[0], false)
                            return
                        }
                        // 未知状态
                        complete(nil, false)
                    } else {
                        complete((response.result.error as NSError?)?.localizedDescription, false)
                    }
                }
            case .failure(let encodingError):
                complete((encodingError as NSError?)?.localizedDescription, false)
            }
        })
    }

    /// 修改圈子
    ///
    /// - Parameters:
    ///   - category: 圈子分类 id
    ///   - cover: 封面图
    ///   - name: 圈子名称
    ///   - tags: 必须 圈子标签 格式:[{id:1},{id:3}...]
    ///   - mode: 必须 圈子类别 public: 公开，private：私有，paid：付费的
    ///   - intro: 圈子简介
    ///   - notice: 圈子公告
    ///   - money: 收费圈子进圈金额，gold 单位，如果 mode 为 paid 必须存在
    ///   - allowFeed: 是否允许同步动态 同步需要传 1
    ///   - (String, String, String, String): (location 地区, latitude 纬度, longitude 经度, geoHash) 4 个值必须一同存在
    ///   - complete: 结果
    // swiftlint:disable:next cyclomatic_complexity
    class func changeGroup(groupId: Int, cover: UIImage?, name: String?, tags: [Int]?, mode: String?, intro: String?, notice: String?, money: Int?, allowFeed: Bool?, locationInfo: (String, String, String, String)?, complete: @escaping (String?, Bool, Dictionary<String, Any>?) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().changeGroup
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        // 2.配置参数
        var parameters: [String: Any] = [: ]
        if let name = name {
            parameters.updateValue(name, forKey: "name")
        }
        if let tags = tags {
            parameters.updateValue(tags, forKey: "tags")
        }
        if let mode = mode {
            parameters.updateValue(mode, forKey: "mode")
        }
        if let allowFeed = allowFeed {
            parameters.updateValue(allowFeed ? "1" : "0", forKey: "allow_feed")
        }
        if let money = money {
            // 注：收费入圈价格由之前的金额更正为积分，且这里应传入整数类型的参数
            parameters.updateValue("\(money)", forKey: "money")
        }
        if let intro = intro {
            parameters.updateValue(intro, forKey: "summary")
        }
        if let notice = notice {
            parameters.updateValue(notice, forKey: "notice")
        }
        if let (location, latitude, longitude, geoHash) = locationInfo {
            parameters.updateValue(location, forKey: "location")
            parameters.updateValue(latitude, forKey: "latitude")
            parameters.updateValue(longitude, forKey: "longitude")
            parameters.updateValue(geoHash, forKey: "geo_hash")
        }
        // 将 image 转成 data
        var imageData: Data?
        if let coverImage = cover {
            imageData = UIImageJPEGRepresentation(coverImage, 1)
        }
        // 自定义header
        let authorization = TSCurrentUserInfo.share.accountToken?.token
        var coustomHeaders: HTTPHeaders = ["Accept": "application/json"]
        if let authorization = authorization {
            let token = "Bearer " + authorization
            coustomHeaders.updateValue(token, forKey: "Authorization")
        }
        // 发起网络请求
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            // 添加图片 file
            if let imageData = imageData {
                multipartFormData.append(imageData, withName: "avatar", fileName: "avatar", mimeType: "image/jpeg")
            }
            // 添加其他参数
            for (key, val) in parameters {
                if let stringValue = val as? String {
                    multipartFormData.append(stringValue.data(using: String.Encoding.utf8)!, withName: key)
                }
                if key == "tags", let tags = val as? [Int] {
                    for tagId in tags {
                        multipartFormData.append("\(tagId)".data(using: String.Encoding.utf8)!, withName: "tags[][id]")
                    }
                }
            }
        }, usingThreshold: 0, to: TSAppConfig.share.rootServerAddress + request.urlPath, method: .post, headers: coustomHeaders, encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if response.result.isSuccess {
                        let resultDic = response.result.value as! Dictionary<String, Any>
                        // 后台返回错误信息
                        if let errorDic = resultDic["errors"] as? [String: Any] {
                            if let message = errorDic["message"] as? String {
                                complete(message, false, nil)
                                return
                            }
                            if let message = resultDic["message"] as? String {
                                complete(message, false, nil)
                                return
                            }
                        }
                        // 后台返回正确信息
                        if let message = resultDic["message"] as? String {
                            complete(message, message.count < 5, resultDic["group"] as? Dictionary<String, Any>)
                            return
                        }
                        // 后台返回正确信息
                        if let message = resultDic["message"] as? Array<String> {
                            complete(message[0], false, nil)
                            return
                        }
                        // 未知状态
                        complete(nil, false, nil)
                    } else {
                        complete((response.result.error as NSError?)?.localizedDescription, false, nil)
                    }
                }
            case .failure(let encodingError):
                complete((encodingError as NSError?)?.localizedDescription, false, nil)
            }
        })
    }

    /// 修改发帖权限
    ///
    /// - Parameters:
    ///   - groupId: 圈子 id
    ///   - permission: 'member' - 允许成员发帖, 'administrator' - 允许管理员发帖, 'founder' - 允许圈主发帖
    class func changPostCapability(groupId: Int, permission: [String], complete: @escaping (Bool, String?) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().postCapability
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        // 2.配置参数
        let parameters: [String: Any] = ["permissions": permission]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败")
            case .failure(let faild):
                complete(false, faild.message)
            case .success(let success):
                var message = success.message
                if let dic = success.sourceData as? [String: Any], let successInfo = dic["message"] as? String {
                    message = successInfo
                }
                complete(true, message ?? "修改成功")
            }
        }
    }

    /// 转让圈子
    class func transferGroup(groupId: Int, toUser userId: Int, complete: @escaping (Bool, String?) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().transferGroup
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        // 2.配置参数
        let parameters: [String: Any] = ["target": userId]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "圈子转让失败")
            case .failure(let faild):
                complete(false, faild.message ?? "圈子转让失败")
            case .success(let success):
                var message = success.message
                if let dic = success.sourceData as? [String: Any], let successInfo = dic["message"] as? String {
                    message = successInfo
                }
                complete(true, message ?? "圈子转让成功")
            }
        }
    }
}

// MARK: - 帖子列表
extension GroupNetworkManager {

    /// 我的帖子列表
    ///
    /// - Parameters:
    ///   - type: 默认:1 , 1-发布的 2- 已置顶 3-置顶待审
    ///   - offset: 默认 0 ，数据偏移量，传递之前通过接口获取的总数
    ///   - limit: 默认 15 ，数据返回条数 默认为15
    ///   - complete: 结果
    class func getMyPosts(type: String, offset: Int, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ([PostListModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().myPosts
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["type": type, "limit": limit, "offset": offset]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.models, nil, true)
            }
        }
    }

    /// 圈子帖子列表
    ///
    /// - Parameters:
    ///   - groupId: 圈子 id
    ///   - type: 默认:latest_post, latest_post 最新帖子,latest_reply最新回复
    ///   - limit: 默认 20 ，数据返回条数 默认为20
    ///   - after: 可选，上次获取到数据最后一条 ID，用于获取该 ID 之后的数据。
    ///   - complete: 结果
    class func getPosts(groupId: Int, type: String, limit: Int = TSAppConfig.share.localInfo.limit, offset: Int?, complete: @escaping (PostListResultsModel?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().postList
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        // 2.配置参数
        var parameters: [String: Any] = ["limit": limit]
        if let offset = offset {
            parameters.updateValue(offset, forKey: "offset")
        }
        if !type.isEmpty {
            if type != "excellent" {
                parameters.updateValue(type, forKey: "type")
            } else {
                parameters.updateValue(1, forKey: "excellent")
            }
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.model, nil, true)
            }
        }
    }

    /// 圈子精华帖子列表(仅用于圈子预览)
    ///
    /// - Parameters:
    ///   - groupId: 圈子 id
    ///   - type: 默认:latest_post, latest_post 最新帖子,latest_reply最新回复
    ///   - limit: 默认 20 ，数据返回条数 默认为20
    ///   - after: 可选，上次获取到数据最后一条 ID，用于获取该 ID 之后的数据。
    ///   - complete: 结果
    class func getPreviewPosts(groupId: Int, complete: @escaping ([PostListModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().previewPostList
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                /// 兼容不返回用户信息的列表请求，比如：圈子预览
                if data.models.isEmpty {
                    complete([], nil, true)
                    return
                }
                if data.models[0].userInfo.name.isEmpty {
                    var userIDs: [Int] = []
                    for model in data.models {
                        userIDs.append(model.userId)
                    }
                    TSUserNetworkingManager().getUserInfo(userIDs, complete: { (info, userModels, error) in
                        if error == nil, let userModels = userModels, userModels.isEmpty == false {
                            var userModelsDic: [Int: TSUserInfoModel] = [:]
                            for userInfo in userModels {
                                userModelsDic.updateValue(userInfo, forKey: userInfo.userIdentity)
                            }
                            var enableModels: [PostListModel] = []
                            /// 更新帖子列表中的用户信息
                            for postModel in data.models {
                                if let userInfo = userModelsDic[postModel.userId] {
                                    postModel.userInfo = userInfo
                                    //移除评论数据
                                    postModel.comments = []
                                    enableModels.append(postModel)
                                }
                            }
                            complete(enableModels, nil, true)
                        } else {
                            complete(nil, "网络请求错误", false)
                        }
                    })
                } else {
                    complete(data.models, nil, true)
                }
            }
        }
    }

    /// 帖子详情
    ///
    /// - Parameters:
    ///   - groupId: 圈子 id
    ///   - postId: 帖子 id
    ///   - complete: 请求结果回调
    class func postDetail(postId: Int, groupId: Int, complete: @escaping (PostDetailModel?, String?, Bool, Int?) -> Void) -> Void {
        // 1.请求 url
        var request = GroupNetworkRequest().postDetail
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)", "\(postId)"])
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false, 200)
            case .failure(let failure):
                complete(nil, failure.message, false, failure.statusCode)
            case .success(let data):
                complete(data.model, nil, true, 200)
            }
        }
    }

    /// 发布帖子
    ///
    /// - Parameters:
    ///   - groupId: 圈子 id
    ///   - title: 必须 帖子标题
    ///   - body: 必须 帖子内容
    ///   - summary: 列表专用字段，概述，简短内容
    ///   - images: 文件id,例如[1,2,3]
    ///   - syncFeed: 是否同步至动态
    ///   - complete: 请求结果回调
    class func publishPost(in groupId: Int, title: String, body: String, summary: String, images: [Int], syncFeed: Bool = false, complete: @escaping (PostListModel?, String?, Bool) -> Void) -> Void {
        // 1.请求 url
        var request = GroupNetworkRequest.publishPost
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        // 2.配置参数
        /// 这里需要限制一下summary的字数 <=191
        var summaryFinal: String = summary
        if summaryFinal.count > 191 {
            summaryFinal = summaryFinal.subString(with: NSRange(location: 0, length: 191))
        }
        var parameters: [String: Any] = ["title": title, "body": body, "summary": summaryFinal, "images": images]
        // 同步至动态，同步需要传sync_feed = 1
        parameters.updateValue(syncFeed ? 1 : 0, forKey: "sync_feed")
        if syncFeed {
            // 设备标示 同步动态需要传 1:pc 2:h5 3:ios 4:android 5:其他
            parameters.updateValue(3, forKey: "feed_from")
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.model?.postModel, data.model?.message, true)
            }
        }
    }

    /// 编辑帖子
    ///
    /// - Parameters:
    ///   - postId: 帖子 id
    ///   - 其余参数，参见publishPost请求
    class func updatePost(postId: Int, groupId: Int, title: String, body: String, summary: String, images: [Int], syncFeed: Bool = false, complete: @escaping (PostListModel?, String?, Bool) -> Void) -> Void {
        // 1.请求 url
        var request = GroupNetworkRequest.updatePost
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)", "\(postId)"])
        // 2.配置参数
        var parameters: [String: Any] = ["title": title, "body": body, "summary": summary, "images": images]
        // 同步至动态，同步需要传sync_feed = 1
        parameters.updateValue(syncFeed ? 1 : 0, forKey: "sync_feed")
        if syncFeed {
            // 设备标示 同步动态需要传 1:pc 2:h5 3:ios 4:android 5:其他
            parameters.updateValue(3, forKey: "feed_from")
        }
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.model?.postModel, data.model?.message, true)
            }
        }
    }

    /// 搜索帖子
    class func searchPost(keyword: String, groupId: Int?, offset: Int, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ([PostListModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().searchPost
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["keyword": keyword, "limit": limit, "offset": offset]
        if let groupId = groupId {
            parameters.updateValue(groupId, forKey: "group_id")
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.models, nil, true)
            }
        }
    }

    /// 删除帖子
    class func delete(post postId: Int, groupId: Int, complete: @escaping (Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().deletePost
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)", "\(postId)"])
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false)
            case .failure(_):
                complete(false)
            case .success(_):
                complete(true)
            }
        }
    }

    /// 点赞帖子
    class func diggPost(postId: Int, complete: @escaping (Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().digg
        request.urlPath = request.fullPathWith(replacers: ["\(postId)"])
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false)
            case .failure(_):
                complete(false)
            case .success(_):
                complete(true)
            }
        }
    }

    /// 取消点赞帖子
    class func undiggPost(postId: Int, complete: @escaping (Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().undigg
        request.urlPath = request.fullPathWith(replacers: ["\(postId)"])
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false)
            case .failure(_):
                complete(false)
            case .success(_):
                complete(true)
            }
        }
    }

    /// 收藏帖子
    class func collectPost(postId: Int, complete: @escaping (Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().collect
        request.urlPath = request.fullPathWith(replacers: ["\(postId)"])
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false)
            case .failure(_):
                complete(false)
            case .success(_):
                complete(true)
            }
        }
    }

    /// 取消收藏帖子
    class func uncollectPost(postId: Int, complete: @escaping (Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().uncollect
        request.urlPath = request.fullPathWith(replacers: ["\(postId)"])
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false)
            case .failure(_):
                complete(false)
            case .success(_):
                complete(true)
            }
        }
    }

    /// 我收藏的帖子
    class func getMyCollectPosts(offset: Int, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ([PostListModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().collection
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                complete(data.models, nil, true)
            }
        }
    }

    /// 评论帖子
    class func commentPost(postId: Int, body: String, replyUserId: Int?, complete: @escaping (PostListCommentModel?, Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().commentPost
        request.urlPath = request.fullPathWith(replacers: ["\(postId)"])
        // 2.配置参数
        var parameters: [String: Any] = ["body": body]
        if let replyId = replyUserId {
            parameters.updateValue(replyId, forKey: "reply_user")
        }
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, false)
            case .failure(_):
                complete(nil, false)
            case .success(let success):
                complete(success.model?.comment, true)
            }
        }
    }

    /// 删除评论
    class func deleteComment(postId: Int, commentId: Int, complete: @escaping (Bool) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().deleteComment
        request.urlPath = request.fullPathWith(replacers: ["\(postId)", "\(commentId)"])
        // 2.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false)
            case .failure(_):
                complete(false)
            case .success(_):
                complete(true)
            }
        }
    }

    /// 置顶帖子
    class func topPost(postId: Int, amount: Int, day: Int, complete: @escaping (Bool, String?) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().topPost
        request.urlPath = request.fullPathWith(replacers: ["\(postId)"])
        // 2.配置参数
        var parameters: [String: Any] = ["amount": amount, "day": day]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parameters.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }

        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败")
            case .failure(let faild):
                complete(false, faild.message)
            case .success(let success):
                var message = success.message
                if let dic = success.sourceData as? [String: Any], let successInfo = dic["message"] as? [String] {
                    message = successInfo.first
                }
                complete(true, message)
            }
        }
    }

    /// 置顶帖子评论
    class func topComment(commentId: Int, amount: Int, day: Int, complete: @escaping (Bool, String?) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().topComment
        request.urlPath = request.fullPathWith(replacers: ["\(commentId)"])
        // 2.配置参数
        var parameters: [String: Any] = ["amount": amount, "day": day]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parameters.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }

        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败")
            case .failure(let faild):
                complete(false, faild.message)
            case .success(let success):
                var message = success.message
                if let dic = success.sourceData as? [String: Any], let successInfo = dic["message"] as? [String] {
                    message = successInfo.first
                }
                complete(true, message)
            }
        }
    }

    /// 圈主和管理员置顶帖子
    class func managerTopPost(postId: Int, day: Int, complete: @escaping (Bool, String?) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().managerTopPost
        request.urlPath = request.fullPathWith(replacers: ["\(postId)"])
        // 2.配置参数
        let parameters: [String: Any] = [ "day": day]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败")
            case .failure(let faild):
                complete(false, faild.message)
            case .success(let success):
                var message = success.message
                if let dic = success.sourceData as? [String: Any], let successInfo = dic["message"] as? String {
                    message = successInfo
                }
                complete(true, message)
            }
        }
    }

    /// 圈主和管理员取消置顶帖子
    class func managerCancelTopPost(postId: Int, complete: @escaping (Bool, String?) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().managerCancelTopPost
        request.urlPath = request.fullPathWith(replacers: ["\(postId)"])
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败")
            case .failure(let faild):
                complete(false, faild.message)
            case .success(let success):
                var message = success.message
                if let dic = success.sourceData as? [String: Any], let successInfo = dic["message"] as? String {
                    message = successInfo
                }
                complete(true, message)
            }
        }
    }
    /// 圈主和管理员设置/取消精华帖子
    class func managerSetOrCancelPost(postId: Int, complete: @escaping (Bool, String?) -> Void) {
        // 1.请求 url
        var request = GroupNetworkRequest().managerSetOrCancelExcellentPost
        request.urlPath = request.fullPathWith(replacers: ["\(postId)"])
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(false, "网络请求失败")
            case .failure(let faild):
                complete(false, faild.message)
            case .success(let success):
                var message = success.message
                if let dic = success.sourceData as? [String: Any], let successInfo = dic["message"] as? String {
                    message = successInfo
                }
                complete(true, message)
            }
        }
    }
}

// MARK: - 圈子 成员管理
extension GroupNetworkManager {

    /// 请求成员列表时成员的类型
    enum MemberType: String {
        /// 所有成员，含有申请加入圈子但还没审核的
        case all
        /// 管理员
        case manager
        /// 普通成员
        case member
        /// 黑名单
        case blacklist
        /// 审核通过且未被拉黑成员
        case audit_user
    }
    /// 圈子成员加入时的审核
    enum MemberJoinAudit: Int {
        /// 允许 - 接收
        case accept = 1
        /// 拒绝
        case reject
    }

    /// 圈子成员列表
    ///
    /// - Parameters:
    ///   - groupId: 圈子 id
    ///   - after: 翻页标示 默认 0，
    ///   - limit: 数据返回条数 默认为15
    ///   - type: 成员列表的类型 默认 all, all-所有, manager-管理员, member-成员, blacklist-黑名单
    ///   - complete: 请求结果回调
    class func memberList(groupId: Int, after: Int, limit: Int = TSAppConfig.share.localInfo.limit, type: MemberType, complete: @escaping ((_ memberList: [GroupMemberModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = GroupNetworkRequest.Mmeber.memberList
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        // 2.配置参数
        let parameters: [String: Any] = ["after": after, "limit": limit, "type": type.rawValue]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求失败", false)
            case .failure(let response):
                complete(nil, response.message, false)
            case .success(let response):
                complete(response.models, response.message, true)
            }
        }
    }
    /// 圈子成员搜索
    /// 圈子成员列表的接口上添加了一个参数
    class func memberSearch(key: String, groupId: Int, after: Int, limit: Int = TSAppConfig.share.localInfo.limit, type: MemberType, complete: @escaping ((_ memberList: [GroupMemberModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = GroupNetworkRequest.Mmeber.memberList
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        // 2.配置参数
        let parameters: [String: Any] = ["name": key, "after": after, "limit": limit, "type": type.rawValue]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求失败", false)
            case .failure(let response):
                complete(nil, response.message, false)
            case .success(let response):
                complete(response.models, response.message, true)
            }
        }
    }

    /// 移除圈子成员
    ///
    /// - Parameters:
    ///   - groupId: 圈子 id
    ///   - memberId: 成员 id
    ///   - complete: 请求结果回调
    class func removeMember(groupId: Int, memberId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = GroupNetworkRequest.Mmeber.removeMember
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)", "\(memberId)"])
        // 2.配置参数
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete("网络请求失败", false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }

    /// 设置成员为管理员
    class func setMemberToAdministrator(groupId: Int, memberId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = GroupNetworkRequest.Mmeber.setManager
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)", "\(memberId)"])
        // 2.配置参数
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete("网络请求失败", false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }

    /// 移除一个成员的管理员角色
    class func removeAdministrator(groupId: Int, memberId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = GroupNetworkRequest.Mmeber.removeManager
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)", "\(memberId)"])
        // 2.配置参数
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete("网络请求失败", false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }

    /// 将一个成员加入黑名单
    class func addBlackList(groupId: Int, memberId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = GroupNetworkRequest.Mmeber.addBlackList
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)", "\(memberId)"])
        // 2.配置参数
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete("网络请求失败", false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }

    /// 将一个成员移除黑名单
    class func removeBlackList(groupId: Int, memberId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = GroupNetworkRequest.Mmeber.removeBlackList
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)", "\(memberId)"])
        // 2.配置参数
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete("网络请求失败", false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }

    /// 待审核成员列表
    class func getAuditList(after: Int, limit: Int, complete: @escaping ((_ auditList: [ReceivePendingGroupAuditModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = GroupNetworkRequest.Mmeber.auditList
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["after": after, "limit": limit]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求失败", false)
            case .failure(let response):
                complete(nil, response.message, false)
            case .success(let response):
                complete(response.models, response.message, true)
            }
        }
    }

    /// 审核圈子加入请求
    class func auditJoin(groupId: Int, memberId: Int, audit: MemberJoinAudit, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = GroupNetworkRequest.Mmeber.auditJoin
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)", "\(memberId)"])
        // 2.配置参数
        let parameters: [String: Any] = ["status": audit.rawValue]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete("网络请求失败", false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }
}

// MARK: - 圈子 收益管理
extension GroupNetworkManager {

    /// 收益列表
    class func incomeList(groupId: Int, type: GroupIncomeType, after: Int, limit: Int, start: TimeInterval, end: TimeInterval, complete: @escaping ((_ incomeList: [GroupIncomeModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = GroupNetworkRequest.Income.list
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        // 2.配置参数
        let parameters: [String: Any] = ["limit": limit, "after": after, "type": type.rawValue, "start": start, "end": end]
        //parameters.updateValue(start, forKey: "start")
        //parameters.updateValue(end, forKey: "end")
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求失败", false)
            case .failure(let response):
                complete(nil, response.message, false)
            case .success(let response):
                complete(response.models, response.message, true)
            }
        }
    }

}
