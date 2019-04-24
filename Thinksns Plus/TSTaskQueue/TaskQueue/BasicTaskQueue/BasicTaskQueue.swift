//
//  BasicTaskQueue.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  后台任务队列

import UIKit

class BasicTaskQueue {

    /// 开启后台一个任务
    class func start(task: TaskObject, network: @escaping (@escaping (Bool) -> Void) -> Void) {
        // 0.判断任务是否在执行中
        if task.taskStatus == 0 {
            return
        }

        // 1.如果没在只执行中，更新为启动状态
        TSDatabaseManager().task.start(task: task)

        // 2.保存一下 task 的 operation
        let currentOperation = task.operation.value

        // 3.设置网络请求返回后的操作
        let finishBlock = { (isSuccess: Bool) in

            // 3.1 更新 task 的任务状态
            if !isSuccess {
                TSDatabaseManager().task.end(task: task, isSuccess: false)
                return
            }

            // 3.2 任务成功，检查一下 operation 是否匹配
            if currentOperation == task.operation.value {
                // operation 匹配，结束任务
                TSDatabaseManager().task.end(task: task, isSuccess: true)
            } else {
                // operation 不匹配，进行新一轮的网络请求
                start(task: task, network: network)
            }
        }

        // 4.发起网络请求
        network(finishBlock)
    }

    /// 未完成的任务
    class func unFinishedTask(isOpenApp: Bool, idPrefix: String) -> [TaskObject] {
        var list = TSDatabaseManager().task.getFaildTask(idPrefix: idPrefix)
        if isOpenApp {
            list = TSDatabaseManager().task.getUnfinishedTask(idPrefix: idPrefix)
        }
        return list
    }

}
