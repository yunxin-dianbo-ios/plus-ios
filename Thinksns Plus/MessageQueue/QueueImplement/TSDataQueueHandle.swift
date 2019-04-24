//
//  TSDataQueueHandle.swift
//  Thinksns Plus
//
//  Created by 法正磊 on 2017/2/19.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSDataQueueHandle: NSObject, TSDataQueueHandleProtocol {

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
    var data: Array<Any> = Array()
    // 错误信息
    var err: NSError?

    /// 获取用户信息的请求
    ///
    /// - Parameters:
    ///   - userId: 用户id
    ///   - maxRequestCount: 最大重复请求次数
    ///   - complete: 完成后回传的数据
    func userInformationRequestHandle(userIds: Array<Int>, maxRequestCount: Int, isMust: Bool, complete: @escaping (Any?, NSError?) -> Void) {
        self.maxRequestCount = maxRequestCount
        queue.async(group: dispatchGroup, qos: .utility, flags: .assignCurrentContext) {
                self.dispatchGroup.enter()

                TSUserNetworkingManager().getUserInfo(userIds, complete: { (_, responseData, error) in
                    if !isMust {
                        self.handleErrorJudge(error: error, responseData: responseData, complete: {
                            self.userInformationRequestHandle(userIds: userIds, maxRequestCount: maxRequestCount, isMust: isMust, complete: { (_, _) in
                            })
                        })
                    }
                })
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            if self.isSuccess {
                    complete(self.data, self.err)
            }
        }
    }

    /// 获取用户关系列表
    ///
    /// - Parameters:
    ///   - userId: 用户id
    ///   - maxId: 分页查询Id
    ///   - maxRequestCount: 最大重复请求次数
    ///   - complete: 回传的数据
    internal func relationListDataRequestHandle(userId: String, maxId: String?, relationType: TSUserRelationType, maxRequestCount: Int, complete: @escaping (String?, Any?, NSError?) -> Void) {
        self.maxRequestCount = maxRequestCount
        queue.async(group: dispatchGroup, qos: .utility, flags: .assignCurrentContext) {
            self.dispatchGroup.enter()
            var id: Int?
            if let maxId = maxId {
                id = Int(maxId)
            }

            TSUserNetworkingManager().getUserFansAndFollowList(Int(userId)!, type: relationType, max: id, complete: { (_, responseData, error) in
            self.handleErrorJudge(error: error, responseData: responseData, complete: {
                self.relationListDataRequestHandle(userId: userId, maxId: maxId, relationType: relationType, maxRequestCount: maxRequestCount, complete: { (_, _, _) in
                })
            })
                })
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            if self.isSuccess {
                complete(nil, self.data, self.err)
            }
        }
    }

    /// 处理重复请求的逻辑
    ///
    /// - Parameters:
    ///   - error: 错误信息
    ///   - responseData: 数据
    ///   - complete: 完成后的回调
  private  func handleErrorJudge(error: NSError?, responseData: Any?, complete: @escaping () -> Void) {
        if error == nil {
            self.data.append(responseData!)
            self.dispatchGroup.leave()
        } else {
            if self.errorRequestCount < self.maxRequestCount {
                self.errorRequestCount += 1
                self.isSuccess = false
                self.dispatchGroup.leave()
                self.queue.asyncAfter(deadline: DispatchTime.now() + self.afterTime, execute: {
                    complete()
                })
            } else {
                // 返回错误
                err = error
                self.isSuccess = true
                self.dispatchGroup.leave()
            }
        }
    }
}
