//
//  TSDatabaseSystem.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSDatabaseSystem {

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

    /// 删除所有系统消息
    func deleteAll() {
        let message = realm.objects(TSSystemMessageObject.self)
        try! realm.write {
            realm.delete(message)
        }
    }

    // MARK: - 系统消息

    /// 获取所有的系统消息
    func getMessage() -> Results<TSSystemMessageObject> {
        let result = realm.objects(TSSystemMessageObject.self).sorted(byKeyPath: "id", ascending: false)
        return result
    }

    /// 储存系统消息
    func save(message: [TSSystemMessageObject]) {
        try! realm.write {
            realm.add(message, update: true)
        }
    }
}
