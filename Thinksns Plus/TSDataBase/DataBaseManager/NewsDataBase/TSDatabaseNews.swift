//
//  TSDatabaseNews.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  资讯数据库相关操作

import UIKit
import RealmSwift

extension TSDatabaseNews {

}

class TSDatabaseNews {

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

    // MARK: - 增

    /// 保存资讯栏目到数据库
    ///
    /// - Parameter tags: 资讯栏目数组
    func save(allNewsTags tags: [TSNewsTagObject]) {
        for object in tags {
            realm.beginWrite()
            realm.add(object, update: true)
            try! realm.commitWrite()
        }
    }

    /// 保存资讯列表的数据（不包含顶部banner）到数据库
    ///
    /// - Parameters:
    ///   - list: 资讯数据
    ///   - id: 所在栏目的id
    func save(newsList list: [TSNewsListObject], tagID id: Int) {

        let relationObjects = realm.objects(TSNewsAndTagsRelationObject.self)
        let selectedRelations = relationObjects.filter("tagID = \(id)")

        /// 删除之前保存的关系
        realm.beginWrite()
        for relation in selectedRelations {
            realm.delete(relation)
        }
        try! realm.commitWrite()

        /// 添加新的关系
        realm.beginWrite()
        for object in list {

            /// 添加 TSNewsAndTagsRelationObject 表中的信息
            let newRelation = TSNewsAndTagsRelationObject()
            newRelation.newsID = object.id
            newRelation.tagID = id
            realm.add(newRelation)

            /// 添加/更新 TSNewsListObject 表中的信息
            realm.add(object, update: true)
        }
        try! realm.commitWrite()
    }

    /// 清空阅读记录
    func deleteNewsSelected() {
        let object = realm.objects(TSNewsSelectedObject.self)
        try! realm.write {
            realm.delete(object)
        }
    }

    /// 删除数据库中的某条资讯记录
    ///
    /// - Parameter id: 资讯id
    func deleteNews(newsID id: Int) {

        /// 删除“栏目-资讯”关系表中的相关数据
        var relation = realm.objects(TSNewsAndTagsRelationObject.self)
        relation = relation.filter("newsID = \(id)")

        realm.beginWrite()
        realm.delete(relation)
        try! realm.commitWrite()

        // [长期注释] 暂不删除本地资讯数据. 2017/04/26
//        /// 删除对应资讯
//        var object = realm.objects(TSNewsListObject.self)
//        object = object.filter("id = \(id)")
//
//        if object.isEmpty {
//            return
//        }
//
//        realm.beginWrite()
//        realm.delete(object)
//        try! realm.commitWrite()
    }

    // MARK: - 查

    /// 查询数据库中的栏目
    ///
    /// - Parameters:
    ///   - string: 查询条件语句
    ///   - key: 排序键名
    /// - Returns: [TSNewsTagObject]
    func selectTagsFromDataBase(WithCriteriaString string: String, sortKey key: String) -> [TSNewsTagObject] {
        var tags = realm.objects(TSNewsTagObject.self)
        tags = tags.filter("\(string)").sorted(byKeyPath: "\(key)")
        return Array(tags)
    }

    /// 查询栏目里的列表数据（不包含顶部banner）
    ///
    /// - Parameter id: 栏目id
    /// - Returns: 结果
    func selectNewsList(tagID id: Int) -> [TSNewsListObject] {

        var resultArray: [TSNewsListObject] = []
        /// 先查关系表
        let relationObjects = realm.objects(TSNewsAndTagsRelationObject.self)
        let selectedRelations = Array(relationObjects.filter("tagID = \(id)").sorted(byKeyPath: "newsID", ascending: false))

        /// 关系表里没有相应记录 返回空数组
        if selectedRelations.isEmpty {
            return resultArray
        }

        /// 待查询的列表数据
        let listObjects = realm.objects(TSNewsListObject.self)
        /// 用查出来的关系来查找资讯表中的对应资讯
        for relation in selectedRelations {
            let selectedListObjects = listObjects.filter("id = \(relation.newsID)")
            let selectedListObject = Array(selectedListObjects).first
            resultArray.append(selectedListObject!)
        }
        return resultArray
    }

    /// 查询数据库中是否有某条资讯的阅读记录
    ///
    /// - Parameter id: 资讯id
    /// - Returns: 结果
    func isSelectedNews(News id: Int) -> Bool {
        var object = realm.objects(TSNewsSelectedObject.self)
        object = object.filter("newsID = \(id)")
        return !object.isEmpty
    }

    /// 查询数据库中的某条资讯记录
    ///
    /// - Parameters:
    ///   - id: 资讯id
    ///   - complate: 结果
    func selectNews(newsID id: Int, complate:@escaping(_ object: TSNewsListObject?) -> Void) {
        var objects = realm.objects(TSNewsListObject.self)
        objects = objects.filter("id = \(id)")
        if objects.isEmpty {
            complate(nil)
            return
        }
        complate(objects.first!)
    }

    // MARK: - 改
    /// 更改数据库中的栏目订阅信息
    func uploadTagInfo(tags: [TSNewsTagObject], isMarked: Bool) {
        for i in 0..<tags.count {
            let object = tags[i]
            realm.beginWrite()
            object.index = i
            isMarked ? (object.isMarked = 1) : (object.isMarked = 0)
            isMarked ? (object.index = i) : (object.index = -1)
            try! realm.commitWrite()
        }
    }

    // MARK: - 收藏

    // MARK: 获取任务
    /// 获取失败的收藏任务
    func getFaildCollectList() -> [TSNewsCollectionTaskObject] {
        let failCollect = realm.objects(TSNewsCollectionTaskObject.self).filter("taskState == 2")
        return Array(failCollect)
    }

    /// 获取未完成的收藏任务
    func getUnFinishedCollectList() -> [TSNewsCollectionTaskObject] {
        let unFinishedCollect = realm.objects(TSNewsCollectionTaskObject.self).filter("taskState != 1")
        return Array(unFinishedCollect)
    }

    /// 获取单个收藏任务
    ///
    /// - Parameters:
    ///   - feedIdentity: 资讯唯一标识
    /// - Returns: 任务
    func getCollect(_ newsIdentity: Int) -> TSNewsCollectionTaskObject? {
        let userIdentity = (TSCurrentUserInfo.share.userInfo?.userIdentity)!
        let id = "\(userIdentity)#\(newsIdentity)"
        let result = realm.objects(TSNewsCollectionTaskObject.self).filter("id = '\(id)'")
        if result.isEmpty {
            return nil
        }
        return result.first!
    }

    // MARK: 写入任务

    /// 写入收藏任务
    ///
    /// - Parameters:
    ///   - newCollect: 0 取消收藏，1 收藏
    ///   - feedIdentity: 动态唯一标识
    func save(collectTask newCollect: Int, newsIdentity: Int) {
        let userIdentity = (TSCurrentUserInfo.share.userInfo?.userIdentity)!
        let id = "\(userIdentity)#\(newsIdentity)"
        let result = realm.objects(TSNewsCollectionTaskObject.self).filter("id = '\(id)'")
        var newObject = TSNewsCollectionTaskObject()
        newObject.id = id
        if !result.isEmpty {
            newObject = result.first!
        }
        realm.beginWrite()
        newObject.newsIdentity = newsIdentity
        newObject.userIdentity = userIdentity
        newObject.taskState = 0
        newObject.collectionState = newCollect
        realm.add(newObject, update: true)
        try! realm.commitWrite()
    }

    /// 设置收藏任务为进行状态
    func changeToStartState(collect: TSNewsCollectionTaskObject) {
        realm.beginWrite()
        collect.taskState = 0
        try! realm.commitWrite()
    }

    // MARK: 结束任务

    /// 结束收藏任务
    ///
    /// - Parameters:
    ///   - success: 是否成功
    func end(collect task: TSNewsCollectionTaskObject, success: Bool) {
        try! realm.write {
            task.taskState = success ? 1 : 2
        }
    }
    // MAKR: - 删除任务
    func deleteAll() {
        deleteDiggTask()
        deletCollectionTask()
    }
    /// 删除收藏任务
    func deletCollectionTask() {
        let tasks = realm.objects(TSNewsCollectionTaskObject.self)
        try! realm.write {
            realm.delete(tasks)
        }
    }

    /// 删除赞任务
    func deleteDiggTask() {
        let tasks = realm.objects(TSNewsCollectionTaskObject.self)
        try! realm.write {
            realm.delete(tasks)
        }
    }

    /// 更新数据库
    func change(collect object: TSNewsListObject) {
        try! realm.write {
            object.isConllected = object.isConllected == 0 ? 1 : 0
        }
    }

    // MARK: - 点赞

    // MARK: 获取任务
    /// 获取失败的点赞任务
    func getFaildDiggList() -> [TSNewsDiggTaskObject] {
        let failDigg = realm.objects(TSNewsDiggTaskObject.self).filter("taskStatus == 2")
        return Array(failDigg)
    }

    /// 获取未完成的点赞任务
    func getUnFinishedDiggList() -> [TSNewsDiggTaskObject] {
        let unFinishedDigg = realm.objects(TSNewsDiggTaskObject.self).filter("taskStatus != 1")
        return Array(unFinishedDigg)
    }

    /// 获取单个赞任务
    ///
    /// - Parameters:
    ///   - newsID: 资讯唯一标识
    /// - Returns: 任务
    func getDigg(_ newsID: Int) -> TSNewsDiggTaskObject? {
        let result = realm.objects(TSNewsDiggTaskObject.self).filter("newsID == \(newsID)")
        if result.isEmpty {
            return nil
        }
        return result.first!
    }

    // MARK: 写入任务

    /// 写入赞任务
    ///
    /// - Parameters:
    ///   - newDigg: 0 取消赞，1 点赞
    ///   - feedIdentity: 动态唯一标识
    func save(diggTask newDigg: Int, newID: Int) {
        let result = realm.objects(TSNewsDiggTaskObject.self).filter("newsID == \(newID)")
        var newObject = TSNewsDiggTaskObject()
        newObject.newsID = newID
        if !result.isEmpty {
            newObject = result.first!
        }
        realm.beginWrite()
        newObject.taskStatus = 0
        newObject.diggStatus = newDigg
        realm.add(newObject, update: true)
        try! realm.commitWrite()
    }

    /// 设置赞任务为进行状态
    func changeToStartState(digg: TSNewsDiggTaskObject) {
        realm.beginWrite()
        digg.taskStatus = 0
        try! realm.commitWrite()
    }

    // MARK: 结束任务

    /// 结束赞任务
    ///
    /// - Parameters:
    ///   - digg: 赞任务
    ///   - success: 是否成功
    func end(digg task: TSNewsDiggTaskObject, success: Bool) {
        try! realm.write {
            task.taskStatus = success ? 1 : 2
        }
    }

    /// 更新数据库(点赞)
    func change(digg object: TSNewsListObject) {
        try! realm.write {
            object.isDiged = object.isDiged == 0 ? 1 : 0
        }
    }
}
