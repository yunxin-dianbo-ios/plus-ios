//
//  TSDatabaseWallet.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  钱包相关 数据库管理类

import UIKit
import RealmSwift

class TSDatabaseWallet {

    private let realm: Realm!

    // MARK: - Lifecycle
    convenience init() {
        let realm = try! Realm()
        self.init(realm)
    }

    /// 可以替换掉内部数据的初始化方法,用于测试
    ///
    /// - Parameter realm: 数据库
    init(_ realm: Realm) {
        self.realm = realm
    }

    /// 删除所有钱包相关数据
    func deleteAll() {
        // 1.删除提现明细的历史记录
        let history = realm.objects(TSWithdrawHistoryObject.self)
        // 2.删除钱包明细的历史记录
        let walletHistory = realm.objects(TSWalletHistoryObject.self)

        try! realm.write {
            realm.delete(history)
            realm.delete(walletHistory)
        }
    }

    // MARK: - 钱包明细

    /// 获取钱包明细的历史记录
    func getWalletHidtory() -> Results<TSWalletHistoryObject> {
        let result = realm.objects(TSWalletHistoryObject.self).sorted(byKeyPath: "id", ascending: false)
        return result
    }

    /// 储存钱包明细的历史记录
    func saveWallet(history: [TSWalletHistoryObject]) {
        try! realm.write {
            realm.add(history, update: true)
        }
    }

    // MARK: - 提现明细

    /// 获取提现明细的历史记录
    func getWithdrawHistory() -> Results<TSWithdrawHistoryObject> {
        let result = realm.objects(TSWithdrawHistoryObject.self).sorted(byKeyPath: "id", ascending: false)
        return result
    }

    /// 储存提现明细的历史记录
    func saveWithdraw(history: [TSWithdrawHistoryObject]) {
        try! realm.write {
            realm.add(history, update: true)
        }
    }
}
