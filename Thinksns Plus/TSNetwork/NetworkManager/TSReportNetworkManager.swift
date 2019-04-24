//
//  TSReportNetworkManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  举报相关的请求
/**
 

 **/

import Foundation

import ObjectMapper

/// 圈子举报处理类型
enum TSGroupReportProcessOperate {
    /// 同意
    case accept
    /// 拒绝
    case reject
}

class TSReportNetworkManager {

}

// MARK: - 举报

extension TSReportNetworkManager {

    /// 举报圈子    因举报界面中暂不兼容圈子举报，所以圈子举报接口单独添加
    ///
    /// - Parameters:
    ///   - groupId: 圈子id
    ///   - reason: 举报原因
    ///   - complete: 请求结果回调
    class func reportGroup(groupId: Int, reason: String, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = TSReportNetworkRequest.group
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        // 2.配置参数
        let parameters: [String: Any] = ["reason": reason]
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

    /// 举报
    ///
    /// - Parameters:
    ///   - type: 举报类型
    ///   - reportTargetId: 举报对象的id
    ///   - reason: 举报原因
    ///   - complete: 请求结果回调
    class func report(type: ReportTargetType, reportTargetId: Int, reason: String, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request: Request<Empty>
        switch type {
        case .Comment(commentType: let commentType, sourceId: _, groupId: _):
            request = TSReportNetworkRequest.Comment.other
            if commentType == .post {
                request = TSReportNetworkRequest.Comment.post
            }
        case .Post:
            request = TSReportNetworkRequest.post
        case .Moment:
            request = TSReportNetworkRequest.moment
        case .News:
            request = TSReportNetworkRequest.news
        case .User:
            request = TSReportNetworkRequest.user
        case .Group:
            request = TSReportNetworkRequest.group
        case .Answer:
            request = TSReportNetworkRequest.answer
        case .Question:
            request = TSReportNetworkRequest.question
        case .Topic:
            request = TSReportNetworkRequest.topic
        }
        request.urlPath = request.fullPathWith(replacers: ["\(reportTargetId)"])
        // 2.配置参数
        var parameters: [String: Any] = [String: Any]()
        // 有的地方传的参数叫content，有的地方传的参数叫reason，topic：message，不用判断的解决方案
        parameters.updateValue(reason, forKey: "reason")
        parameters.updateValue(reason, forKey: "content")
        parameters.updateValue(reason, forKey: "message")
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

// MARK: - 评论举报
/// 暂时使用上面的举报，之后根据需要再来建立统一的评论处理
extension TSReportNetworkManager {

}

// MARK: - 圈子的举报管理

extension TSReportNetworkManager {

    /// 圈子举报列表
    ///
    /// - Parameters:
    ///   - groupId: 圈子id
    ///   - type: 类型 表示请求哪种类型的圈子举报
    ///   - after: 翻页标示
    ///   - limit: 操作(搜藏/取消收藏)
    ///   - complete: 请求结果回调
    ///   - start 秒级时间戳，起始筛选时间
    ///   - end 秒级时间戳，结束筛选时间
    class func groupReportList(groupId: Int, type: GroupReportManageType, after: Int, limit: Int, start: TimeInterval, end: TimeInterval, complete: @escaping ((_ reportList: [GroupReportModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = TSReportNetworkRequest.Group.list
        request.urlPath = request.fullPathWith(replacers: [""])
        // 2.配置参数
        var parameters: [String: Any] = ["group_id": groupId, "after": after, "limit": limit, "start": start, "end": end]
        //parameters.updateValue("", forKey: "start")
        //parameters.updateValue("", forKey: "end")
        var status: GroupReportStatus?
        switch type {
        case .all:
            break
        case .waiting:
            status = GroupReportStatus.waiting
        case .accepted:
            status = GroupReportStatus.accepted
        case .rejected:
            status = GroupReportStatus.rejected
        }
        if let status = status {
            parameters.updateValue(status.rawValue, forKey: "status")
        }
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

    /// 圈子举报处理
    ///
    /// - Parameters:
    ///   - reportId: 举报id
    ///   - processOperate: 对举报的处理：同意 | 拒绝
    ///   - complete: 请求结果回调
    class func groupReportProcess(reportId: Int, processOperate: TSGroupReportProcessOperate, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request: Request<Empty>
        switch processOperate {
        case .accept:
            request = TSReportNetworkRequest.Group.accept
        case .reject:
            request = TSReportNetworkRequest.Group.reject
        }
        request.urlPath = request.fullPathWith(replacers: ["\(reportId)"])
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

}
