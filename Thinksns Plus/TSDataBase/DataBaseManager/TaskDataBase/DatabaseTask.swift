//
//  DatabaseTask.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  后台任务管理类

import UIKit
import RealmSwift

class DatabaseTask {
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

    // MARK: - 获取

    /// 获取失败的任务
    func getFaildTask(idPrefix: String) -> [TaskObject] {
        let faild = realm.objects(TaskObject.self).filter("taskStatus == 2 AND id BEGINSWITH '\(idPrefix)'")
        return Array(faild)
    }

    /// 获取未完成的任务
    func getUnfinishedTask(idPrefix: String) -> [TaskObject] {
        let unFinished = realm.objects(TaskObject.self).filter("taskStatus != 1 AND id BEGINSWITH '\(idPrefix)'")
        return Array(unFinished)
    }

    /// 获取任务
    func getTask(id: String) -> TaskObject? {
        let tasks = realm.objects(TaskObject.self).filter("id = '\(id)'")
        return tasks.first
    }

    // MARK: - 写入

    /// 添加一个任务
    ///
    /// - Note: 如果任务已经存在，则只会更新 operation
    ///
    /// - Parameters:
    ///   - id: 任务唯一标识
    ///   - operation: 任务将要执行的操作，一般用于任务具有两种状态时。例如 1/0 ：收藏/取消收藏，点赞/取消点赞
    /// - Returns: 任务
    func addTask(id: String, operation: Int?) -> TaskObject {
        // 1.检出有误旧任务已经存在，有旧任务存在，仅更新旧任务状态
        if let oldTask = realm.objects(TaskObject.self).filter("id = '\(id)'").first, let operation = operation {
            try! realm.write {
                oldTask.operation.value = operation
            }
        }
        // 2.如果没有旧任务，就创建一个新的任务
        let task = TaskObject()
        task.id = id
        task.operation.value = operation
        realm.beginWrite()
        realm.add(task, update: true)
        try! realm.commitWrite()
        return task
    }

    /// 结束任务
    func end(task: TaskObject, isSuccess: Bool) {
        try! realm.write {
            task.taskStatus = isSuccess ? 1 : 2
        }
    }

    /// 启动任务
    func start(task: TaskObject) {
        try! realm.write {
            task.taskStatus = 0
        }
    }

}
