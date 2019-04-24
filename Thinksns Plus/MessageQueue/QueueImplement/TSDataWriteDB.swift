//
//  TSMessageWriteDBData.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSDataWriteDB: NSObject, TSDataWriteDBProtocol {

    /// 写入用户信息
    ///
    /// - Parameters:
    ///   - responseData: 网络获取的数据
    ///   - userId: 用户Id
    ///   - complete: 返回数据
    func writeDataWithUserInformation(responseData: Any, userIds: Array<Int>, complete: @escaping (TSUserInfoObject) -> Void) {
        guard let info = responseData as? NSDictionary else {
            assert(false, "\(TSDataWriteDB.self)获取的用户数据为空")

        }

        /// 还要写关系表！！！！
        for item in userIds {
            TSDataBaseManager.share.user.setNotificationOnUserInfoWith(item) { (object) in
                complete(object!)
            }
            let userInfoModel = setUserInfo(info: info, userId: item)
            TSDataBaseManager.share.user.writeUserInfo(userInfoModel)

        }
    }

    func setUserInfo(info: NSDictionary, userId: Int) -> TSUserInfoModel {

        var userInfo = TSUserInfoModel()

        userInfo.area = info["area"] as? String ?? "无"
        userInfo.city = info["city"] as? String ?? "无"
        userInfo.education = info["education"] as? String ?? "未知"
        userInfo.province = info["province"] as? String ?? "无"
        userInfo.location = info["location"] as? String ?? "未填写"
        userInfo.sex = info["sex"] as? Int ?? 2
        userInfo.name = info["name"] as? String ?? "未填写"
        userInfo.intro = info["intro"] as? String ?? "这家伙很懒~~"
        userInfo.userIdentity = userId
        return userInfo
    }
}
