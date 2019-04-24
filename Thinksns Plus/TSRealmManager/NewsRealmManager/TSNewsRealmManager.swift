//
//  TSNewsRealmManager.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TSNewsRealmManager {
    fileprivate let realm: Realm!

    // MARK: - Lifecycle
    init() {
        let realm = try! Realm()
        self.realm = realm
    }

    /// 删除整个表
    func deleteAll() {
    }
}

// MARK: - 资讯投稿草稿
extension TSNewsRealmManager {

}

// MARK: - 资讯投稿相关
extension TSNewsRealmManager {

}
