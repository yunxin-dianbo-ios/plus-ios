//
//  TSDatabaseUser.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  数据库 - 用户相关
//  提供各种获取用户信息的相关的方法

import UIKit
import RealmSwift

class TSDatabaseUser {
    fileprivate let realm: Realm!

    // MARK: - Lifecycle
    convenience init() {
        let realm = try! Realm()
        self.init(realm)
    }

    /// 可以替换掉内部数据的初始化方 法,用于测试
    ///
    /// - Parameter realm: 数据库
    init(_ realm: Realm) {
        self.realm = realm
    }

    /// 删除整个表
    func deleteAll() {
        try! realm.write {
            self.deleteCurrentUser()
            self.deleteAllUserInfo()
            // 其他用户关联部分
        }
        self.deleteCurrentUserCertificate()
    }
}

// MARK: - 当前用户信息
extension TSDatabaseUser {

    // MARK: 用户信息

    /// 从数据库中获取当前用户的信息
    func getCurrentUser() -> TSCurrentUserInfoModel? {
        if let object = realm.objects(TSCurrentUserInfoObject.self).first {
            return TSCurrentUserInfoModel(object: object)
        }
        return nil
    }
    /// 保存当前用户信息
    func saveCurrentUser(_ userModel: TSCurrentUserInfoModel) -> Void {
        // 当前用户信息是唯一的，即使primarykey不一样
        let savedUsers = realm.objects(TSCurrentUserInfoObject.self)
        realm.beginWrite()
        // 移除旧的
        realm.delete(savedUsers)
        // 添加新的
        realm.add(userModel.object(), update: true)
        try! realm.commitWrite()
    }
    /// 重载保存当前用户信息
    func saveCurrentUser(_ userObject: TSCurrentUserInfoObject) -> Void {
        // 当前用户信息是唯一的，即使primarykey不一样
        let savedUsers = realm.objects(TSCurrentUserInfoObject.self)
        try! realm.write {
            realm.delete(savedUsers)
            realm.add(userObject, update: true)
            try! realm.commitWrite()
        }
    }
    /// 删除当前用户信息
    func deleteCurrentUser() -> Void {
        try! realm.write {
            let objects = realm.objects(TSCurrentUserInfoObject.self)
            realm.delete(objects)
            try! realm.commitWrite()
        }
    }

    /// 修改当前用户信息
    func updateCurrentUser() -> Void {
        guard let model = TSCurrentUserInfo.share.userInfo else {
            return
        }
        try! realm.write {
            realm.add(model.object(), update: true)
            try! realm.commitWrite()
        }
    }

    // MARK: 用户认证

    /// 删除用户认证信息
    func deleteCurrentUserCertificate() {
        let objects = realm.objects(TSUserCertificateObject.self)
        try! realm.write {
            realm.delete(objects)
        }
    }

    /// 保存用户认证信息
    func saveCurrentUser(certificate: TSUserCertificateObject) {
        realm.beginWrite()
        realm.add(certificate, update: true)
        try! realm.commitWrite()
    }
    /// 获取用户认证信息
    func getCurrentUserCertificate() -> TSUserCertificateObject? {
        return realm.objects(TSUserCertificateObject.self).first
    }
    /// 监听用户认证信息
    func notificationForUserCertificate(block: @escaping (RealmCollectionChange<Results<TSUserCertificateObject>>) -> Void) -> NotificationToken {
        let userCertificate = realm.objects(TSUserCertificateObject.self)
        return userCertificate.observe(block)
    }
}

// MARK: - 其他单人的用户信息

extension TSDatabaseUser {
    /// 根据用户Id获取指定用户的信息
    func getUserInfo(userId: Int) -> TSUserInfoModel? {
        let result = realm.object(ofType: TSUserInfoObject.self, forPrimaryKey: userId)
        if let userInfoObject = result {
            return TSUserInfoModel(object: userInfoObject)
        }
        return nil
    }

    /// 保存指定用户信息
    func saveUserInfo(_ userModel: TSUserInfoModel) -> Void {
        //self.saveUserInfo(userObject: userModel.object())
        realm.beginWrite()
        realm.add(userModel.object(), update: true)
        try! realm.commitWrite()
    }
    func saveUserInfo(_ userObject: TSUserInfoObject) -> Void {
        try! realm.write {
            realm.add(userObject, update: true)
            try! realm.commitWrite()
        }
    }

    /// 删除单人信息
    func deleteUserInfo(_ userId: Int) -> Void {
        try! realm.write {
            if let object = realm.object(ofType: TSUserInfoObject.self, forPrimaryKey: userId) {
                realm.delete(object)
                try! realm.commitWrite()
            }
        }
    }

}

// MARK: - 其他多人的用户信息

extension TSDatabaseUser {

    /// 根据指定的用户Id数组获取指定用户列表的信息
    func getUsersInfo(usersId: [Int]) -> [TSUserInfoModel] {
        var userList = [TSUserInfoModel]()
        for userId in usersId {
            let result = self.getUserInfo(userId: userId)
            if let userModel = result {
                userList.append(userModel)
            }
        }
        return userList
    }

    /// 保存指定用户列表的信息
    func saveUsersInfo(_ usersModel: [TSUserInfoModel]) -> Void {
        var userObjects = [TSUserInfoObject]()
        for userModel in usersModel {
            userObjects.append(userModel.object())
        }
        self.saveUsersInfo(userObjects)
    }
    func saveUsersInfo(_ userObjects: [TSUserInfoObject]) -> Void {
        try! realm.write {
            realm.add(userObjects, update: true)
            try! realm.commitWrite()
        }
    }

    /// 删除多人信息
    func deleteUsersInfo(_ usersId: [Int]) -> Void {
        for userId in usersId {
            let objects = realm.objects(TSUserInfoObject.self).filter("userIdentity == \(userId)")
            realm.beginWrite()
            realm.delete(objects)
            try! realm.commitWrite()
        }
    }
    func deleteAllUserInfo() -> Void {
        try! realm.write {
            let objects = realm.objects(TSUserInfoObject.self)
            realm.delete(objects)
            try! realm.commitWrite()
        }
    }
}

// MARK: - Old API

// MARK: - 用户信息

extension TSDatabaseUser {
    /// 写入多个用户信息
    func save(usersInfo: [TSUserInfoObject]) {
        for info in usersInfo {
            realm.beginWrite()
            realm.add(info, update: true)
            try! realm.commitWrite()
        }
    }

    /// 保存用户列表
    func save(from models: [TSUserInfoModel]) {
        for model in models {
            let result = realm.objects(TSUserInfoObject.self).filter("userIdentity == \(model.userIdentity)")
            var object = TSUserInfoObject()
            object.userIdentity = model.userIdentity
            if !result.isEmpty {
                object = result.first!
            }
            object = model.object()
            realm.beginWrite()
            realm.add(object, update: true)
            try! realm.commitWrite()
        }
    }

    /// 检测用户信息变动通知
    ///
    /// - Parameters:
    ///   - userIdentity: 用户 userIdentity
    ///   - completed: 结果
    /// - Returns: 通知口令，要接收通知请保持对口令的强引用
    func setNotification(userIdentity: Int, completed: @escaping (_ changes: RealmCollectionChange<Results<TSUserInfoObject>>) -> Void) -> NotificationToken {
        let userInfoResults = realm.objects(TSUserInfoObject.self).filter("userIdentity == \(userIdentity)")
        let token = userInfoResults.observe { (changes) in
            completed(changes)
        }
        return token
    }

    // TODO: 下面的几种写法是为了兼容之前的数据库存取方法，之后应考虑移除

    /// 从数据获取数据库用户的信息
    func get(_ userIdentities: Int) -> TSUserInfoObject? {
        let objects = realm.objects(TSUserInfoObject.self).filter("userIdentity == \(userIdentities)")
        if objects.isEmpty {
            return nil
        }
        return objects.first!
    }

    /// 从数据库获取多个用户的信息
    ///
    /// Note: 如果查询数据,会返回空数组
    func get(infoFrom userIdentities: [Int]) -> [TSUserInfoObject] {
        var userObjectss: [TSUserInfoObject] = []
        for identity in userIdentities {
            let userObject = realm.objects(TSUserInfoObject.self).filter("userIdentity == \(identity)")
            if !userObject.isEmpty {
                userObjectss.append(userObject.first!)
            }
        }
        return userObjectss
    }

}

// MARK: - 点赞榜
extension TSDatabaseUser {
    /// 获取用户中心点赞榜的列表
    func getDiggRank(userId: Int) -> TSUserDiggsrankListObject? {
        let diggRankList = realm.objects(TSUserDiggsrankListObject.self).filter("userId == \(userId)")
        if diggRankList.isEmpty {
            return nil
        }
        return Array(diggRankList).first
    }

    func delete(diggrankUserId: Int) {
        try! realm.write {
            let relation = realm.objects(TSUserDiggsrankListObject.self).filter("userId == \(diggrankUserId)")
            realm.delete(relation)
        }
    }

    /// 储存点赞榜列表
    func save(diggRank: TSUserDiggsrankListObject) {
        try! realm.write {
            realm.add(diggRank, update: true)
            try! realm.commitWrite()
        }
    }

    /// 检测点赞
    ///
    /// - Parameters:
    ///   - userIdentity: 用户 userIdentity
    ///   - completed: 结果
    /// - Returns: 通知口令，要接收通知请保持对口令的强引用
    func setDiggrankNotification(userId: Int, completed: @escaping (_ changes: RealmCollectionChange<Results<TSUserDiggsrankListObject>>) -> Void) -> NotificationToken {
        let results = realm.objects(TSUserDiggsrankListObject.self).filter("userId == \(userId)")
        let token = results.observe { (changes) in
            completed(changes)
        }
        return token
    }
}
