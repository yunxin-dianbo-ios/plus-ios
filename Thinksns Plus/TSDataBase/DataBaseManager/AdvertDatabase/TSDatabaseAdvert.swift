//
//  TSDatabaseAdvert.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import RealmSwift

class TSDatabaseAdvert {

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

    // MARK: - 删除
    func deleteAll() {
        let spaceObjects = realm.objects(TSAdSpaceObject.self)
        let advertObjects = realm.objects(TSAdvertObject.self)
        let analogFeedObject = realm.objects(TSFeedAnalogObject.self)
        let analogNewsObject = realm.objects(TSNewsAnalogObject.self)
        try! realm.write {
            realm.delete(spaceObjects)
            realm.delete(advertObjects)
            realm.delete(analogFeedObject)
            realm.delete(analogNewsObject)
        }
    }

    // MARK: - 写入

    /// 写入广告数据
    ///
    /// - Parameters:
    ///   - objects: 新数据
    ///   - update: 是否清空旧数据
    func save(objects: [TSAdvertObject], update: Bool) {
        try! realm.write {
            if update {
                let oldObjects = realm.objects(TSAdvertObject.self)
                let analogFeedObject = realm.objects(TSFeedAnalogObject.self)
                let analogNewsObject = realm.objects(TSNewsAnalogObject.self)
                realm.delete(oldObjects)
                realm.delete(analogFeedObject)
                realm.delete(analogNewsObject)
            }
            realm.add(objects, update: true)
        }
    }

    /// 写入广告位数据
    ///
    /// - Parameters:
    ///   - objects: 新数据
    ///   - update: 是否清空旧数据
    func save(spaceObjects objects: [TSAdSpaceObject], update: Bool) {
        try! realm.write {
            if update {
                let oldObjects = realm.objects(TSAdSpaceObject.self)
                realm.delete(oldObjects)
            }
            realm.add(objects, update: true)
        }
    }

    // MARK: - 获取

    /// 通过类型查询 id 
    func getSpaceId(with type: AdvertSpaceType) -> Int? {
        let result = realm.objects(TSAdSpaceObject.self).filter("space = '\(type.rawValue)'")
        return result.first?.id
    }

    /// 通过广告位 id 获取数据
    func getObjects(spaceId: Int) -> [TSAdvertObject] {
        let result = realm.objects(TSAdvertObject.self).filter("spaceId == \(spaceId)").sorted(byKeyPath: "order", ascending: true)
        return Array(result)
    }

    /// 通过类型查询广告数据
    func getObjects(type: AdvertSpaceType) -> [TSAdvertObject] {
        guard let spaceId = getSpaceId(with: type) else {
            return []
        }
        let advertObjects = getObjects(spaceId: spaceId)
        return advertObjects
    }
}
