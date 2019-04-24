//
//  RankListManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  排行榜 网络请求管理

import UIKit

class RankListManager: NSObject {

    /// 排行榜类型
    enum RankType: String {
        case fans = "全站粉丝排行榜"
        case wealth = "财富达人排行榜"
        case income = "收入达人排行榜"
        case attendance = "社区签到排行榜"
        case communityExperts = "社区专家排行榜"
        case quoraExperts = "问答达人排行榜"
        case answerToday = "今日解答排行榜"
        case answerWeek = "一周解答排行榜"
        case answerMonth = "本月解答排行榜"
        case feedToday = "今日动态排行榜"
        case feedWeek = "一周动态排行榜"
        case feedMonth = "本月动态排行榜"
        case newsToday = "今日资讯排行榜"
        case newsWeek = "一周资讯排行榜"
        case newsMonth = "本月资讯排行榜"
    }

    /// 批量获取排行榜信息
    ///
    /// - Parameters:
    ///   - rankTypes: 排行榜类型
    ///   - offset: 分页标识
    ///   - aComplete: 结果会按传入的 rankTypes 进行排序后返回
    class func getRrankLists(rankTypes: [RankType], offset: Int, complete aComplete: @escaping ([[TSUserInfoModel]]?, String?, Bool) -> Void) {
        // 1.创建一个组
        let group = DispatchGroup()
        // 2.创建结果数组
        var allDatas: [RankType: [TSUserInfoModel]?] = [:]
        var allMessages: [RankType: String?] = [:]
        var allStatus: [RankType: Bool] = [:]
        // 3.遍历排行榜类型，发起网络请求
        for type in rankTypes {
            group.enter()
            RankListManager.getRankList(rankType: type, offset: offset, complete: { (datas: [TSUserInfoModel]?, message: String?, status: Bool) in
                // 4.将数据保存在结果数组中
                allStatus.updateValue(status, forKey: type)
                allMessages.updateValue(message, forKey: type)
                allDatas.updateValue(datas, forKey: type)
                group.leave()
            })
        }
        // 5.组完成通知
        group.notify(queue: DispatchQueue.main) {
            // 6.处理结果数据
            let isRequestSuccess = Array(allStatus.values).filter { !$0 }.isEmpty
            if isRequestSuccess {
                // 6.1 获取数据成功
                var datas: [[TSUserInfoModel]] = []
                for type in rankTypes {
                    guard let typeData = allDatas[type], let data = typeData else {
                        aComplete(nil, nil, true)
                        break
                    }
                    datas.append(data)
                }
                aComplete(datas, nil, true)
            } else {
                // 6.2 获取数据失败
                let message = Array(allMessages.values).flatMap { $0 }.first
                aComplete(nil, message, false)
            }
        }
    }

    /// 获取排行榜数据
    ///
    /// - Parameters:
    ///   - rankType: 排行榜类型
    ///   - offset: 数据偏移量
    ///   - complete: 结果
    class func getRankList(rankType: RankType, offset: Int, complete: @escaping ([TSUserInfoModel]?, String?, Bool) -> Void) {
        switch rankType {
        case .fans:
            RankListNetworkManager.getFansRank(offset: offset, complete: complete)
        case .wealth:
            RankListNetworkManager.getWealthRank(offset: offset, complete: complete)
        case .income:
            RankListNetworkManager.getIncomeRank(offset: offset, complete: complete)
        case .attendance:
            RankListNetworkManager.getAttendanceRank(offset: offset, complete: complete)
        case .communityExperts:
            RankListNetworkManager.getCommunityExpertsRank(offset: offset, complete: complete)
        case .quoraExperts:
            RankListNetworkManager.getQuoraExpertsRank(offset: offset, complete: complete)
        case .answerToday:
            RankListNetworkManager.getAnswersRank(type: "day", offset: offset, complete: complete)
        case .answerWeek:
            RankListNetworkManager.getAnswersRank(type: "week", offset: offset, complete: complete)
        case .answerMonth:
            RankListNetworkManager.getAnswersRank(type: "month", offset: offset, complete: complete)
        case .feedToday:
            RankListNetworkManager.getFeedsRank(type: "day", offset: offset, complete: complete)
        case .feedWeek:
            RankListNetworkManager.getFeedsRank(type: "week", offset: offset, complete: complete)
        case .feedMonth:
            RankListNetworkManager.getFeedsRank(type: "month", offset: offset, complete: complete)
        case .newsToday:
            RankListNetworkManager.getNewsRank(type: "day", offset: offset, complete: complete)
        case .newsWeek:
            RankListNetworkManager.getNewsRank(type: "week", offset: offset, complete: complete)
        case .newsMonth:
            RankListNetworkManager.getNewsRank(type: "month", offset: offset, complete: complete)
        }
    }
}
