//
//  TSAccountDataBase.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSAccountDataBase {
    fileprivate let realm: Realm!

    // MARK: - Lifecycle
    convenience init() {
        let realm = try! Realm()
        self.init(realm)
    }

    /// 可以替换掉内部数据的初始化方 法,用于测试
    ///
    /// - Parameter realm: 数据库
    init(_ realm: Realm) {
        self.realm = realm
    }
}

extension TSAccountDataBase {
    func getSamAccount(_ str: String) -> Array<String> {
        var modelList: Array<String> = []
        if str == "" {
            return modelList
        }
        let objects = realm.objects(TSAccountNameObject.self).filter("nameStr CONTAINS %@", str)
        for object in objects {
            let model = TSAccountNameModel(object: object)
            modelList.append(model.nameStr)
        }
        return modelList
    }
    func saveName(_ name: TSAccountNameObject) -> Void {
        try! realm.write {
            realm.add(name, update: true)
            try! realm.commitWrite()
        }
        let objects = realm.objects(TSAccountNameObject.self)
        if objects.count > 20 {
            try! realm.write {
                realm.delete(objects.first!)
            }
        }
    }
}
