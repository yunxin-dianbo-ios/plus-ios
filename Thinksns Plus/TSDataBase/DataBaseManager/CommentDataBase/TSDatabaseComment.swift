//
//  TSCommentDatabase.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/9.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  数据库评论相关

import UIKit
import RealmSwift

class TSDatabaseComment: NSObject {

    // MARK: - SAVE
    /// 储存发送的评论
    ///
    /// - Parameter comment: 评论对象
    func save(comment: TSSendCommentObject) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(comment, update: true)
            try! realm.commitWrite()
        }
    }

    /// 储存删除的评论
    ///
    /// - Parameter delete: 删除的object
    func save(delete: TSDeleteCommentObject) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(delete, update: true)
            try! realm.commitWrite()
        }
    }

    // MARK: - DELETE
    /// 删除发送成功的评论
    ///
    /// - Parameter commentIdentity: 评论唯一id
    func delete(commentMark: Int64) {
        let realm = try! Realm()
        try! realm.write {
            let comment = realm.objects(TSSendCommentObject.self).filter("commentMark == \(commentMark)")
            guard let commentObject = comment.first else {
                return
            }
            realm.delete(commentObject)
            try! realm.commitWrite()
        }
    }

    /// 删除删除的评论
    ///
    /// - Parameter deleteCommentMark: 删除唯一标识
    func delete(deleteCommentMark: Int64) {
        let realm = try! Realm()
        try! realm.write {
            let comment = realm.objects(TSDeleteCommentObject.self).filter("commentMark == \(deleteCommentMark)")
            if comment.isEmpty {
                return
            }
            realm.delete(comment)
            try! realm.commitWrite()
        }
    }

    /// 删除数据库的评论
    func delete(mommentCommentMark: Int64) {
        let realm = try! Realm()
        let comment = realm.objects(TSMomentCommnetObject.self).filter("commentMark == \(mommentCommentMark)")
        if comment.isEmpty {
            return
        }
        realm.beginWrite()
        realm.delete(comment)
        try! realm.commitWrite()
    }

    /// 删除所有评论数据
    func deleteAll() {
        let realm = try! Realm()
        let comments = realm.objects(TSMomentCommnetObject.self)
        let sendComments = realm.objects(TSSendCommentObject.self)
        realm.beginWrite()
        realm.delete(comments)
        realm.delete(sendComments)
        try! realm.commitWrite()
    }

    // MARK: - GET
    /// 获取还没发送成功的Id
    ///
    /// - Parameter feedId: 动态的id
    /// - Returns: 返回评论对象数组
    func get(feedId: Int) -> [TSSendCommentObject]? {
        let realm = try! Realm()
        let result = realm.objects(TSSendCommentObject.self).filter("feedId = \(feedId)")
        if result.isEmpty {
            return nil
        }
        return Array(result)
    }

    /// 获取还没发送成功的评论
    ///
    /// - Returns: 返回没有成功的评论
    func getSendTask() -> [TSSendCommentObject]? {
        let realm = try! Realm()
        let result = realm.objects(TSSendCommentObject.self)
        return Array(result)
    }

    /// 改变所有评论状态
    ///
    /// - Parameter failComments: 失败的评论任务
    func replace(failComments: [TSSendCommentObject]) {
        for item in failComments {
            let realm = try! Realm()
            realm.beginWrite()
            item.status = 1
            try! realm.commitWrite()
        }
    }

    /// 获取还未删除的评论
    ///
    /// - Returns: 待删除的评论
    func getDeleteTask() -> [TSDeleteCommentObject]? {
        let realm = try! Realm()
        let result = realm.objects(TSDeleteCommentObject.self)
        if result.isEmpty {
            return nil
        }
        return Array(result)
    }
}
