//
//  GroupRealmManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子 数据库管理类

import UIKit
import RealmSwift

class GroupRealmManager {

    fileprivate let realm: Realm!

    // MARK: - Lifecycle
    init() {
        let realm = try! Realm()
        self.realm = realm
    }

    /// 删除所有圈子相关
    func deleteAll() {
        // 删除历史记录
        let historyObjects = realm.objects(GroupSearchHistoryObject.self)

        try! realm.write {
            realm.delete(historyObjects)
        }
    }
}

// MARK: - 圈子搜索
extension GroupRealmManager {

    /// 创建搜索记录
    func saveSearchObject(content: String, type: GroupSearchHistoryObject.SearchType, groupID: Int? = 0) {
        let timeInterval = Int(Date().timeIntervalSince1970 as Double * 1_000_000_000)
        let object = GroupSearchHistoryObject()
        object.timeInterval = timeInterval
        object.content = content
        object.typeId = type.rawValue
        object.historyKey = content + "\(type.rawValue)"
        object.groupID = (groupID != nil) ? groupID! : 0
        try! realm.write {
            realm.add(object, update: true)
        }
    }

    /// 删除某条搜索记录
    func delete(searchObject: GroupSearchHistoryObject) {
        try! realm.write {
            realm.delete(searchObject)
        }
    }

    /// 清空某种类型的搜索记录
    func emptySearchObjects(type: GroupSearchHistoryObject.SearchType) {
        let searchObjects = realm.objects(GroupSearchHistoryObject.self).filter("typeId == \(type.rawValue)")
        try! realm.write {
            realm.delete(searchObjects)
        }
    }

    /// 获取某种类型的搜索记录po
    func getSearObjects(type: GroupSearchHistoryObject.SearchType, groupID: Int? = 0) -> Results<GroupSearchHistoryObject> {
        if type == .postInGroup {
            // 圈内搜索需要和圈子ID绑定
            let searchObjects = realm.objects(GroupSearchHistoryObject.self).filter("typeId == \(type.rawValue) && groupID == \(groupID!)").sorted(byKeyPath: "timeInterval", ascending: false)
            return searchObjects
        }
        let searchObjects = realm.objects(GroupSearchHistoryObject.self).filter("typeId == \(type.rawValue)").sorted(byKeyPath: "timeInterval", ascending: false)
        return searchObjects
    }
}
