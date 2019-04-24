//
//  TSGroupTaskQueue.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/19.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
//
//class TSGroupTaskQueue: NSObject {
//
//    /// 继续圈子中未完成的任务
//    func continueTasks(isOpenApp: Bool) {
//        continueJoinTask(isOpenApp: isOpenApp)
//    }
//
//    // MARK: - 圈子列表
//
//    /// 网络请求获取圈子列表
//    ///
//    /// - Parameters:
//    ///   - type: 圈子类型
//    ///   - after: 分页标识
//    ///   - complete: 结果
//    func network(list type: TSGroupVC.GroupListType, after: Int?, complete: (([TSGroupObject]?, String?) -> Void)?) {
//
//        TSGroupNetworkManager().getGroups(type: type, after: after) { (objects: [TSGroupObject]?, message: String?) in
//            if let objects = objects {
//                // 如果是获取第一页数据，清空旧数据
//                if after == nil {
//                    TSDatabaseManager().groups.delete(type: type)
//                }
//                // 保存新数据到数据库
//                TSDatabaseManager().groups.save(list: objects)
//            }
//            complete?(objects, message)
//        }
//    }
//
//    /// 从数据库获取第一页数据
//    func database(firstPage type: TSGroupVC.GroupListType) -> [TSGroupObject] {
//        return TSDatabaseManager().groups.getFirstPage(type: type)
//    }
//
//    // MARK: - 加入/退出圈子
//
//    /// 发起 加入/退出圈子 的任务
//    func startJoin(groupId: Int, complete: @escaping (Bool) -> Void) {
//        guard let object = TSDatabaseManager().groups.getGroup(id: groupId) else {
//            return
//        }
//        let newStatus = object.isMember ? false : true
//        TSGroupNetworkManager().group(isJoin: newStatus, id: object.id) { (isSuccess: Bool) in
//            if isSuccess {
//                // 如果成功，修改数据库状态
//                TSDatabaseManager().groups.change(joinStatue: object)
//            }
//            complete(isSuccess)
//        }
//    }
//
//    /// 发起 加入/退出圈子 的任务
//    func startJoin(groupId: Int) {
//        guard let object = TSDatabaseManager().groups.getGroup(id: groupId) else {
//            return
//        }
//        // 1.修改数据库状态
//        TSDatabaseManager().groups.change(joinStatue: object)
//        // 2.创建任务
//        let operation = object.isMember ? 1 : 0
//        let taskId = TaskIdPrefix.Group.joinGroup.rawValue + ".\(groupId)"
//        let task = TSDatabaseManager().task.addTask(id: taskId, operation: operation)
//        // 3.启动任务
//        startJoin(task: task)
//    }
//
//    /// 继续未完成的 收藏/取消收藏任务
//    private func continueJoinTask(isOpenApp: Bool) {
//        // 1. 获取未完成的任务
//        let tasks = BasicTaskQueue.unFinishedTask(isOpenApp: isOpenApp, idPrefix: TaskIdPrefix.Group.joinGroup.rawValue)
//        // 2. 遍历任务
//        for task in tasks {
//            startJoin(task: task)
//        }
//    }
//
//    /// 发起加入任务
//    internal func startJoin(task: TaskObject) {
//        // 1. 通过 id 解析网络请求的相关参数
//        let groupId = task.getIdInfo1()
//        let isJoin = task.operation.value == 1 ? true : false
//        // 2. 启动任务
//        BasicTaskQueue.start(task: task) { (finish: @escaping (Bool) -> Void) in
//            TSGroupNetworkManager().group(isJoin: isJoin, id: groupId, complete: finish)
//        }
//    }
//}
