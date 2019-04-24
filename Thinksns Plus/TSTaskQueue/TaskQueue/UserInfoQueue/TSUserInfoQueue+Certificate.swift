//
//  TSUserInfoQueue+Certificate.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/9.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  获取用户认证信息

import UIKit

extension TSUserInfoQueue {

    // MARK: - 获取用户认证信息

    /// 发起 获取用户认证信息 任务
    func getCertificateInfo() {
        // 1.创建后台任务
        let taskId = TaskIdPrefix.User.certificate.rawValue
        let task = TSDatabaseManager().task.addTask(id: taskId, operation: nil)
        // 2.启动后台任务
        startCertificateTask(task: task)
    }

    /// 继续未完成的 获取用户认证信息 任务
    func continueCertificateTask(isOpenApp: Bool) {
        // 1. 获取未完成的任务
        let tasks = BasicTaskQueue.unFinishedTask(isOpenApp: isOpenApp, idPrefix: TaskIdPrefix.User.certificate.rawValue)
        // 2. 遍历任务
        for task in tasks {
            startCertificateTask(task: task)
        }
    }

    /// 启动 获取用户认证信息 任务
    internal func startCertificateTask(task: TaskObject) {
        // 启动任务
        BasicTaskQueue.start(task: task) { (finish: @escaping (Bool) -> Void) in
            TSUserNetworkingManager().getUserCertificate(complete: { (object: TSUserCertificateObject?) in
                // 1.获取数据失败
                guard let object = object else {
                    finish(false)
                    return
                }
                // 2.获取数据成功，保存数据
                TSDatabaseManager().user.saveCurrentUser(certificate: object)
                finish(true)
            })
        }
    }

    // MARK: - 上传用户认证信息

    /// 上传用户认证信息
    func uploadCertificate(object: TSUserCertificateObject, complete: @escaping (Bool, String) -> Void) {
        let files = Array(object.files.map { Int($0.storageIdentity) })
        /*
         如果已经提交过认证信息，那么，就只有调用"更新用户认证信息"的接口才能生效；如果用户从未提交过认证信息，就需要调用"上传用户认证信息"的接口
         */
        // 1.判断当前用户是否已经认证过
         let isVerified = TSDatabaseManager().user.getCurrentUserCertificate()?.status != -1
        if !isVerified {
            // 2.用户没有认证过，用"上传"接口
            TSUserNetworkingManager().certificate(type: object.type, files: files, name: object.name, phone: object.phone, number: object.number, desc: object.desc, orgName: object.orgName, orgAddress: object.orgAddress) { (isSuccess, message) in
                // 请求失败
                guard isSuccess else {
                    complete(false, message)
                    return
                }
                // 请求成功，将认证信息保存到数据库
                object.status = 0
                TSDatabaseManager().user.saveCurrentUser(certificate: object)
                complete(true, message)
            }
        } else {
            // 3.用户认证过，用更新接口
            TSUserNetworkingManager().updateCertificate(type: object.type, files: files, name: object.name, phone: object.phone, number: object.number, desc: object.desc, orgName: object.orgName, orgAddress: object.orgAddress) { (isSuccess, message) in
                // 请求失败
                guard isSuccess else {
                    complete(false, message)
                    return
                }
                // 请求成功，将认证信息保存到数据库
                object.status = 0
                TSDatabaseManager().user.saveCurrentUser(certificate: object)
                complete(true, message)
            }
        }
    }
}
