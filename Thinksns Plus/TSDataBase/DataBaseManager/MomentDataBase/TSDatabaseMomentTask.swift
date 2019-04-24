//
//  TSDatabaseMomentTask.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  数据库管理类 动态相关任务

import UIKit
import RealmSwift

// MARK: - 当动态详情页和动态发布页重写后，这个类就该删除了
class TSDatabaseMomentTask {

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

    // MARK: - 删除动态

    // MARK: 获取任务
    /// 获取失败的删除任务
    func getFaildDeleteList() -> [TSMomentDeleteTaskObject] {
        let faildDelete = realm.objects(TSMomentDeleteTaskObject.self).filter("taskState == 2")
        return Array(faildDelete)
    }

    /// 获取未完成的删除任务
    func getUnFinishDeleteList() -> [TSMomentDeleteTaskObject] {
        let unFinishedDigg = realm.objects(TSMomentDeleteTaskObject.self).filter("taskState != 1")
        return Array(unFinishedDigg)
    }

    /// 获取单个删除任务
    ///
    /// - Parameters:
    ///   - feedIdentity: 动态唯一标识
    /// - Returns: 任务
    func getDelete(_ feedIdentity: Int) -> TSMomentDeleteTaskObject? {
        let result = realm.objects(TSMomentDeleteTaskObject.self).filter("feedIdentity == \(feedIdentity)")
        if result.isEmpty {
            return nil
        }
        return result.first!
    }

    // MARK: 写入任务
    /// 写入删除任务
    func save(deleteTask feedIdentity: Int) {
        let result = realm.objects(TSMomentDeleteTaskObject.self).filter("feedIdentity == \(feedIdentity)")
        if !result.isEmpty {
            return
        }
        realm.beginWrite()
        let newObject = TSMomentDeleteTaskObject()
        newObject.feedIdentity = feedIdentity
        newObject.taskState = 0
        realm.add(newObject, update: true)
        try! realm.commitWrite()
    }

    /// 设置删除任务为进行状态
    func changeToStartState(delete: TSMomentDeleteTaskObject) {
        realm.beginWrite()
        delete.taskState = 0
        try! realm.commitWrite()
    }

    // MARK: 结束任务

    /// 结束删除任务
    ///
    /// - Parameters:
    ///   - digg: 收藏任务
    ///   - success: 是否成功
    func end(delete task: TSMomentDeleteTaskObject, success: Bool) {
        try! realm.write {
            task.taskState = success ? 1 : 2
            if task.taskState == 1 { // 如果成功，删除任务
                realm.delete(task)
            }
        }
    }

    // MARK: - 点赞

    // MARK: 获取任务
    /// 获取失败的点赞任务
    func getFaildDiggList() -> [TSMomentDiggTaskObject] {
        let failDigg = realm.objects(TSMomentDiggTaskObject.self).filter("taskState == 2")
        return Array(failDigg)
    }

    /// 获取未完成的点赞任务
    func getUnFinishedDiggList() -> [TSMomentDiggTaskObject] {
        let unFinishedDigg = realm.objects(TSMomentDiggTaskObject.self).filter("taskState != 1")
        return Array(unFinishedDigg)
    }

    /// 获取单个赞任务
    ///
    /// - Parameters:
    ///   - feedIdentity: 动态唯一标识
    /// - Returns: 任务
    func getDigg(_ feedIdentity: Int) -> TSMomentDiggTaskObject? {
        let result = realm.objects(TSMomentDiggTaskObject.self).filter("feedIdentity == \(feedIdentity)")
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
    func save(diggTask newDigg: Int, feedIdentity: Int) {
        let result = realm.objects(TSMomentDiggTaskObject.self).filter("feedIdentity == \(feedIdentity)")
        var newObject = TSMomentDiggTaskObject()
        newObject.feedIdentity = feedIdentity
        if !result.isEmpty {
            newObject = result.first!
        }
        realm.beginWrite()
        newObject.taskState = 0
        newObject.diggState = newDigg
        realm.add(newObject, update: true)
        try! realm.commitWrite()
    }

    /// 设置赞任务为进行状态
    func changeToStartState(digg: TSMomentDiggTaskObject) {
        realm.beginWrite()
        digg.taskState = 0
        try! realm.commitWrite()
    }

    // MARK: 结束任务

    /// 结束赞任务
    ///
    /// - Parameters:
    ///   - digg: 赞任务
    ///   - success: 是否成功
    func end(digg task: TSMomentDiggTaskObject, success: Bool) {
        try! realm.write {
            task.taskState = success ? 1 : 2
        }
    }

    // MARK: - 收藏

    // MARK: 获取任务
    /// 获取失败的收藏任务
    func getFaildCollectList() -> [TSMomentCollectTaskObject] {
        let failCollect = realm.objects(TSMomentCollectTaskObject.self).filter("taskState == 2")
        return Array(failCollect)
    }

    /// 获取未完成的收藏任务
    func getUnFinishedCollectList() -> [TSMomentCollectTaskObject] {
        let unFinishedCollect = realm.objects(TSMomentCollectTaskObject.self).filter("taskState != 1")
        return Array(unFinishedCollect)
    }

    /// 获取单个收藏任务
    ///
    /// - Parameters:
    ///   - feedIdentity: 动态唯一标识
    /// - Returns: 任务
    func getCollect(_ feedIdentity: Int) -> TSMomentCollectTaskObject? {
        let result = realm.objects(TSMomentCollectTaskObject.self).filter("feedIdentity == \(feedIdentity)")
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
    func save(collectTask newCollect: Int, feedIdentity: Int) {
        let result = realm.objects(TSMomentCollectTaskObject.self).filter("feedIdentity == \(feedIdentity)")
        var newObject = TSMomentCollectTaskObject()
        newObject.feedIdentity = feedIdentity
        if !result.isEmpty {
            newObject = result.first!
        }
        realm.beginWrite()
        newObject.taskState = 0
        newObject.collectState = newCollect
        realm.add(newObject, update: true)
        try! realm.commitWrite()
    }

    /// 设置收藏任务为进行状态
    func changeToStartState(collect: TSMomentCollectTaskObject) {
        realm.beginWrite()
        collect.taskState = 0
        try! realm.commitWrite()
    }

    // MARK: 结束任务

    /// 结束收藏任务
    ///
    /// - Parameters:
    ///   - digg: 收藏任务
    ///   - success: 是否成功
    func end(collect task: TSMomentCollectTaskObject, success: Bool) {
        try! realm.write {
            task.taskState = success ? 1 : 2
        }
    }

    // MAKR: - 删除任务
    func deleteAll() {
        deleteDiggTask()
        deletCollectionTask()
        deleteDeleteTask()
    }

    /// 删除收藏任务
    func deletCollectionTask() {
        let tasks = realm.objects(TSMomentCollectTaskObject.self)
        try! realm.write {
            realm.delete(tasks)
        }
    }

    /// 删除赞任务
    func deleteDiggTask() {
        let tasks = realm.objects(TSMomentDiggTaskObject.self)
        try! realm.write {
            realm.delete(tasks)
        }
    }

    /// 删除删除任务
    func deleteDeleteTask() {
        let tasks = realm.objects(TSMomentDeleteTaskObject.self)
        try! realm.write {
            realm.delete(tasks)
        }
    }
}
