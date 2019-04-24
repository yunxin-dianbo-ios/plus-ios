//
//  TSNewFriendsNetworkManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

import ObjectMapper
import Alamofire

class TSNewFriendsNetworkManager {

    static let limit = TSAppConfig.share.localInfo.limit

    /// 搜索联系人用户
    class func getJoinedContactsInfo(phones: [String], complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.配置路径
        var request = NewFriendsNetworkRequest().searchContacts
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["phones": phones]
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

    /// 获取热门用户
    ///
    /// - Parameters:
    ///   - offset: 偏移量, 注: 此参数为之前获取数量的总和
    ///   - limit: 每页数量
    ///   - complete: 结果
    class func getHotUsers(offset: Int, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.配置路径
        var request = NewFriendsNetworkRequest().hotUsers
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["limit": limit, "offset": offset]
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

    /// 获取最新用户
    ///
    /// - Parameters:
    ///   - offset: 偏移量, 注: 此参数为之前获取数量的总和
    ///   - limit: 每页数量
    ///   - complete: 结果
    class func getNewUsers(offset: Int, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.配置路径
        var request = NewFriendsNetworkRequest().newUsers
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["limit": limit, "offset": offset]
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

    /// 获取后台推荐用户
    ///
    /// - Parameters:
    ///   - offset: 偏移量, 注: 此参数为之前获取数量的总和
    ///   - limit: 每页数量
    ///   - complete: 结果
    class func getRecommendsUsers(complete: @escaping([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.配置路径
        var request = NewFriendsNetworkRequest().recommendsUsers
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

    /// 获取标签推荐用户
    ///
    /// - Parameters:
    ///   - offset: 偏移量, 注: 此参数为之前获取数量的总和
    ///   - limit: 每页数量
    ///   - complete: 结果
    class func getTagRecommendsUsers(offset: Int, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.配置路径
        var request = NewFriendsNetworkRequest().tagRecommendsUsers
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["limit": limit, "offset": offset]
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

    /// 提交当前用户的位置
    class func submitLocation(latitude: String?, longitude: String?, complete: ((Bool) -> Void)?) {
        // 过滤经纬度为 nil 的情况
        guard let latitude = latitude, let longitude = longitude else {
            complete?(false)
            return
        }
        // 1.配置路径
        var request = NewFriendsNetworkRequest().submitLocation
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["latitude": latitude, "longitude": longitude]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete?(false)
            case .failure(_):
                complete?(false)
            case .success(_):
                complete?(true)
            }
        }
    }

    /// 获取附近用户
    ///
    /// - Parameters:
    ///   - latitude: 	当前用户所在位置的纬度
    ///   - longitude: 当前用户所在位置的经度
    ///   - offset: 分页参数， 默认1，当返回数据小于limit， offset达到最大值
    ///   - limit: 默认20， 最大100
    ///   - complete: 结果
    class func getNearbyUsers(latitude: String?, longitude: String?, page: Int = 1, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 过滤经纬度为 nil 的情况
        guard let latitude = latitude, let longitude = longitude else {
            complete([], nil, true)
            return
        }
        // 1.配置路径
        var request = NewFriendsNetworkRequest().nearbyUsers
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let radius = 3_000 // 搜索范围，米为单位 [0 - 50000], 默认3000
        let parameters: [String: Any] = ["limit": limit, "page": page, "latitude": latitude, "longitude": longitude, "radius": radius]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let failure):
                complete(nil, failure.message, false)
            case .success(let data):
                // 4.通过 userId 获取用户信息
                let userIds = data.models.map { $0.userId }
                // 由于 getUsersInfo 这个接口在 userIds 为空时会返回所有的用户，所以，这里过滤用户为空的情况
                guard !userIds.isEmpty else {
                    complete([], nil, true)
                    return
                }
                TSDataQueueManager.share.userInfoQueue.getUsersInfo(usersId: userIds, isQueryDB: false, complete: { (models: [TSUserInfoModel]?, message: String?, status: Bool) in
                    complete(models, message, status)
                })
            }
        }
    }

    /// 通过地址获取经纬度
    ///
    /// - Note: 该方法返回的数据实际上是由高德提供，数据格式与 TS+ 后台返回的不同，故无法升级为 Request<TSLocationModel> 的网络请求方法
    class func getLocation(address: String, complete: @escaping (TSLocationModel?) -> Void) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.NewFriends.location.rawValue
        let parameters: [String: Any] = ["address": address]
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: parameters, complete: { (data: NetworkResponse?, status: Bool) in
            if status, let dataDic = data as? [String: Any] {
                // 1.取出地理位置信息的字典数组
                guard let geocodes = dataDic["geocodes"] as? [[String: Any]] else {
                    complete(nil)
                    return
                }
                // 2.过滤数组为空的情况
                guard let geocode = geocodes.first else {
                    complete(nil)
                    return
                }
                let model = TSLocationModel(JSON: geocode)
                complete(model)
                return
            }
            complete(nil)
        })
    }

    /// 搜索用户
    class func searchUsers(keyword: String, offset: Int, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        // 1.配置路径
        var request = NewFriendsNetworkRequest().search
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["keyword": keyword, "limit": limit, "offset": offset]
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
    // TODO: - 关于悬赏邀请中的用户搜索，是否可以传入话题相关，待确认
    /// 搜索用户重载 - 用于问答搜索时
    @discardableResult
    class func searchUsersWith(keyword: String, offset: Int = 0, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ((_ searchText: String, _ userList: [TSUserInfoModel]?, _ msg: String?, _ status: Bool) -> Void) ) -> DataRequest {
        // 1.配置路径
        var request = NewFriendsNetworkRequest().search
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        let parameters: [String: Any] = ["keyword": keyword, "limit": limit, "offset": offset]
        request.parameter = parameters
        // 3.发起请求
        return try! RequestNetworkData.share.textRequest(method: request.method, path: request.urlPath, parameter: request.parameter, complete: { (data, status) in
            var message: String?
            if status {
                // 数据解析
                let userList = Mapper<TSUserInfoModel>().mapArray(JSONObject: data)
                complete(keyword, userList, message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(keyword, nil, message, status)
            }
        })
    }
}
