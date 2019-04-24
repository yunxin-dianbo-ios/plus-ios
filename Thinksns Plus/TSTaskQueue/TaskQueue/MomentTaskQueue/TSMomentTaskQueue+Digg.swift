//
//  TSMomentTaskQueue+Digg.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/23.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态点赞任务

import UIKit

extension TSMomentTaskQueue {

    /// 点赞任务队列
    func start(digg feedId: Int, isDigg: Bool) {
        let newDigg = isDigg ? 1 : 0

        // 发起网络任务
        let shouldNetwork = shouldDiggNetwork(newDigg, feedIdentity: feedId)
        if shouldNetwork {
            network(digg: newDigg, feedIdentity: feedId)
        }
    }

    /// 继续未完成的点赞任务
    func continueDiggTask(isOpenApp: Bool) {
        var list = TSDatabaseManager().momentTask.getFaildDiggList()
        if isOpenApp {
            list = TSDatabaseManager().momentTask.getUnFinishedDiggList()
        }
        if list.isEmpty {
            return
        }
        for task in list {
            TSDatabaseManager().momentTask.changeToStartState(digg: task)
            network(digg: task.diggState, feedIdentity: task.feedIdentity)
        }
    }

    // MARK: - Private
    /// 点赞网络请求
    private func network(digg newDigg: Int, feedIdentity: Int) {
        // 查询次数
        var count = diggNetCountArray[feedIdentity]
        if let count = count {
            diggNetCountArray.updateValue(count + 1, forKey: feedIdentity)
        } else {
            diggNetCountArray.updateValue(1, forKey: feedIdentity)
            count = 1
        }
        TSMomentNetworkManager().digg(newDigg, to: feedIdentity) { (status: Bool) in
            // 请求成功
            if status {
                // 获取任务
                let task = TSDatabaseManager().momentTask.getDigg(feedIdentity)!
                // 判断数据库的任务和当前网络请求的结果是否匹配
                if task.diggState == newDigg {
                    // 匹配，结束任务
                    TSDatabaseManager().momentTask.end(digg: task, success: true)
                    self.diggNetCountArray.updateValue(0, forKey: feedIdentity)
                } else {
                    // 不匹配，再进行网络其请求
                    if TSCurrentUserInfo.share.accountToken != nil {
                        self.network(digg: task.diggState, feedIdentity: task.feedIdentity)
                    }
                }
                return
            }
            // 请求失败
            if count! < self.networkCountMax {
                // 继续请求
                self.network(digg: newDigg, feedIdentity: feedIdentity)
            } else {
                // 结束请求，更新任务状态
                // 获取任务
                let task = TSDatabaseManager().momentTask.getDigg(feedIdentity)!
                TSDatabaseManager().momentTask.end(digg: task, success: false)
                self.diggNetCountArray.updateValue(0, forKey: feedIdentity)
            }
        }
    }

    /// 判断是否发起点赞网络请求，并保存任务
    private func shouldDiggNetwork(_ newDigg: Int, feedIdentity: Int) -> Bool {
        var shouldDiggNetwork = false
        if TSCurrentUserInfo.share.accountToken != nil {
            let task = TSDatabaseManager().momentTask.getDigg(feedIdentity)
            if let task = task {
                if task.taskState == 1 {
                    shouldDiggNetwork = true
                } else {
                    shouldDiggNetwork = false
                }
            } else {
                shouldDiggNetwork = true
            }
        }
        // 保存任务
        TSDatabaseManager().momentTask.save(diggTask: newDigg, feedIdentity: feedIdentity)
        return shouldDiggNetwork
    }

}
