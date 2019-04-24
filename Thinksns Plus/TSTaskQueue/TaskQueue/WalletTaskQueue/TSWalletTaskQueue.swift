//
//  TSWalletTaskQueue.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/6.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  钱包任务队列

import UIKit

class TSWalletTaskQueue: NSObject {

    // MARK: - 钱包配置

    /// 更新用户信息
    ///
    /// - Parameter complete: 结果
    class func updateUserInfo(complete: ((Bool) -> Void)?) {
        // 请求用户信息
        TSDataQueueManager.share.userInfoQueue.getCurrentUserInfo(isQueryDB: false) { (userModel, _, status) in
            if status, let userModel = userModel {
                TSCurrentUserInfo.share.userInfo = userModel
            }
            complete?(status)
        }
    }

    // MARK: - 钱包明细

    /// 获取钱包明细数据库数据
    func getWalletDB() -> [TSWalletHistoryObject] {
        let result = TSDatabaseManager().wallet.getWalletHidtory()
        return Array(result)
    }

    /// 钱包明细 网络请求
    ///
    /// - Parameters:
    ///   - page: 分页页数，第一页是 0
    ///   - complete: 结果
    func network(wallet page: Int?, complete: @escaping (_ result: Bool, _ data: [TSWalletHistoryObject]?, _ error: String?) -> Void) {
        WalletNetworkManager.getOrders(after: page, action: nil) { (ststus, message, models) in
            guard let models = models else {
                complete(false, nil, message)
                return
            }
            let objects = models.map { $0.walletHistoryObject() }
            complete(true, objects, nil)
        }
    }

    // MARK: - 提现明细

    /// 获取提现明细数据库数据
    func getWithdrawDB() -> [TSWithdrawHistoryObject] {
        let result = TSDatabaseManager().wallet.getWithdrawHistory()
        return Array(result)
    }

    /// 提现明细 网络请求
    ///
    /// - Parameters:
    ///   - page: 分页页数，第一页是 0
    ///   - complete: 结果
    func network(withdraw page: Int?, complete: @escaping (_ result: Bool, _ data: [TSWithdrawHistoryObject]?, _ error: String?) -> Void) {

        WalletNetworkManager.getCashes(after: page) { (status, message, models) in
            guard let models = models else {
                complete(false, nil, message)
                return
            }
            let objects = models.map { $0.convertToObject() }
            complete(true, objects, nil)
        }
    }
}
