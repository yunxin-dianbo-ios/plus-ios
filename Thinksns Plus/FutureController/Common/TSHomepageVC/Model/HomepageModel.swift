//
//  HomepageModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/10/30.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  个人主页 数据处理模型

import UIKit

class HomepageModel {

    /// 用户 id
    var userIdentity = 0
    /// 用户名称
    var userName = ""

    /// 用户信息
    var userInfo = TSUserInfoModel()
    /// 用户标签信息
    var userTags: [TSTagModel] = []

    init() {
    }

    /// 初始化方法
    init(userIdentity: Int, userName: String = "") {
        self.userIdentity = userIdentity
        self.userName = userName
    }
}

extension HomepageModel {

    /// 刷新个人主页数据
    func reloadHomepageInfo(complete: @escaping (Bool) -> Void) {
        // 1.创建结果记录容器
        var resultUserInfo = (false, TSUserInfoModel())
        var resultTagsInfo: (Bool, [TSTagModel]) = (false, [])
        // 2.创建组，管理网络请求
        let group = DispatchGroup()

        // 3.发起网络请求
        // 3.1 获取用户信息
        group.enter()
        if userIdentity > 0 {
            TSTaskQueueTool.getAndSave(userIds: [userIdentity]) { (results: [TSUserInfoModel]?, _, _) in
                if let model = results?.first {
                    resultUserInfo = (true, model)
                }
                group.leave()
            }
            // 3.2 获取用户标签信息
            group.enter()
            TSUserLabelNetworkManager.get(userTags: userIdentity, complete: { (tags: [TSTagModel]?, _) in
                if let models = tags {
                    resultTagsInfo = (true, models)
                }
                group.leave()
            })
        } else if userName.count > 0 {
            TSTaskQueueTool.getAndSave(userIds: [], userNames: [userName]) { (results: [TSUserInfoModel]?, _, _) in
                if let model = results?.first {
                    self.userIdentity = model.userIdentity
                    resultUserInfo = (true, model)
                    TSUserLabelNetworkManager.get(userTags: self.userIdentity, complete: { (tags: [TSTagModel]?, _) in
                        if let models = tags {
                            resultTagsInfo = (true, models)
                        }
                        group.leave()
                    })
                } else {
                    group.leave()
                }
            }
        } else {
            TSLogCenter.log.debug("请求用户信息关键参数为空！")
        }
        // 4.处理所有数据
        group.notify(queue: DispatchQueue.main) { [weak self] in
            let isSuccess = resultTagsInfo.0 && resultUserInfo.0
            if isSuccess {
                self?.userInfo = resultUserInfo.1
                self?.userTags = resultTagsInfo.1
            }
            complete(isSuccess)
        }
    }
}
