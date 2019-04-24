//
//  TSMomentTaskQueue+Delete.swift
//  ThinkSNS +
//
//  Created by GorCat on 17/4/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态删除任务

import UIKit

extension TSMomentTaskQueue {

    /// 继续未完成的删除任务
    func continueDeleteTask(isOpenApp: Bool) {
        var list = TSDatabaseManager().momentTask.getFaildDeleteList()
        if isOpenApp {
            list = TSDatabaseManager().momentTask.getUnFinishDeleteList()
        }
        if list.isEmpty {
            return
        }
        for task in list {
            TSDatabaseManager().momentTask.changeToStartState(delete: task)
            network(delete: task.feedIdentity)
        }
    }

    /// 删除任务队列
    func start(delete feedId: Int) {
        if feedId == -1 {
            return
        }
        // 创建任务
        TSDatabaseManager().momentTask.save(deleteTask: feedId)
        // 进行网络请求
        network(delete: feedId)
    }

    // MARK: - Private
    /// 数据库处理
    func database(delete momentObject: TSMomentListObject) {
        // 删除数据库的动态
        TSDatabaseManager().moment.delete(moment: momentObject.feedIdentity)
    }

    /// 网络请求
    private func network(delete feedIdentity: Int) {
        // 查询次数
        var count = deleteNetCountArray[feedIdentity]
        if let count = count {
            deleteNetCountArray.updateValue(count + 1, forKey: feedIdentity)
        } else {
            deleteNetCountArray.updateValue(1, forKey: feedIdentity)
            count = 1
        }
        // 发起网络请求
        TSMomentNetworkManager().deleteMoment(feedIdentity) { (isSuccess) in
            if isSuccess { // 网络请求成功
                // 结束任务
                let task = TSDatabaseManager().momentTask.getDelete(feedIdentity)
                if let task = task {
                    TSDatabaseManager().momentTask.end(delete: task, success: true)
                }
                self.deleteNetCountArray.updateValue(0, forKey: feedIdentity)
            } else { // 网络请求失败
                if count! < self.networkCountMax {
                    // 继续请求
                    self.network(delete: feedIdentity)
                } else {
                    // 结束请求，更新任务状态
                    // 结束任务
                    let task = TSDatabaseManager().momentTask.getDelete(feedIdentity)
                    if let task = task {
                        TSDatabaseManager().momentTask.end(delete: task, success: false)
                    }
                    self.deleteNetCountArray.updateValue(0, forKey: feedIdentity)
                }
            }
        }
    }
}
