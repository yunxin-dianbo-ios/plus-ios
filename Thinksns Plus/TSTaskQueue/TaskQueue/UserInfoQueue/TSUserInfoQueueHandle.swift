//
//  TSDataQueueHandle.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 用户网络请求控制

import UIKit

class TSUserInfoQueueHandle: NSObject {

    /// 最大请求次数
    var maxRequestCount = 20
    // 串行队列
    let queue = DispatchQueue(label: "Queue")
    // 队列组
    let dispatchGroup = DispatchGroup()
    // 错误请求次数
    var errorRequestCount = 0
    // 延迟请求时间
    var afterTime = 2.0
    // 是否请求成功
    var isSuccess = true
    // 成功信息
    var message: String?
    // 网络请求返回的数据
    var data: [Int: TSUserInfoObject]? = nil
    // 错误信息
    var err: NSError?

    /// 获取用户信息的请求
    ///
    /// - Parameters:
    ///   - userId: 用户id
    ///   - maxRequestCount: 最大重复请求次数
    ///   - isMust: 是否是需要重复请求或保存任务（true表示为不重复请求并且不保存任务）
    ///   - complete: 完成后回传的数据
    func request(userIds: Array<Int>, maxRequestCount: Int, isMust: Bool, complete: @escaping ([Int: TSUserInfoObject]?, NSError?) -> Void) {
        self.maxRequestCount = maxRequestCount
        assert(!userIds.isEmpty)
        queue.async(group: dispatchGroup, qos: .utility, flags: .assignCurrentContext) {
            self.dispatchGroup.enter()
            self.isSuccess = true
            TSTaskQueueTool.getAndSave(userInfo: userIds, complete: { (_, userInfoObjectDic, error) in
                self.err = error
                self.data = userInfoObjectDic
                if isMust == true { // 不用循环处理
                    self.isSuccess = true
                    self.dispatchGroup.leave()
                    return
                }

                if error != nil { // 请求成功
                    if self.errorRequestCount < self.maxRequestCount {
                        self.errorRequestCount += 1
                        self.isSuccess = false
                        self.dispatchGroup.leave()
                        self.queue.asyncAfter(deadline: DispatchTime.now() + self.afterTime, execute: {
                            self.request(userIds: userIds, maxRequestCount: maxRequestCount, isMust: isMust, complete: { (_, _) in
                                complete(self.data, self.err)
                            })
                        })
                    } else {
                        // 返回错误
                        self.data = nil
                        self.isSuccess = true
                        self.dispatchGroup.leave()
                    }
                } else {
                    self.isSuccess = true
                    self.dispatchGroup.leave()
                }
            })
        }

        dispatchGroup.notify(queue: .main) {
            if self.isSuccess {
                complete(self.data, self.err)
            }
        }
    }
}
