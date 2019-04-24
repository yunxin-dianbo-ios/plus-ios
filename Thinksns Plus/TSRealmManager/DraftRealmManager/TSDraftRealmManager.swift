//
//  TSDraftRealmManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 04/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  草稿箱数据库管理
//  之后应将答案草稿、问题草稿的数据库管理也给迁移到这里来，方便以后的统一管理

import Foundation
import RealmSwift

class TSDraftRealmManager {
    fileprivate let realm: Realm!

    // MARK: - Lifecycle
    init() {
        let realm = try! Realm()
        self.realm = realm
    }

    /// 删除整个表
    func deleteAll() {
        self.deleteAllPostDraft()
        self.deleteAllQuestionDraft()
        self.deleteAllAnswerDraft()
    }
}

// MARK: - 圈子帖子草稿
extension TSDraftRealmManager {
    /// 获取帖子草稿列表
    func getPostDraftList() -> [TSPostDraftModel] {
        let objects = realm.objects(TSPostDraftObject.self)
        var draftList = [TSPostDraftModel]()
        for object in objects {
            draftList.append(TSPostDraftModel(object: object))
        }
        return draftList
    }
    /// 增加帖子草稿 - id自增
    func addPostDraft(_ post: TSPostDraftModel) -> Void {
        let object = post.object()
        // id自增
        object.draftId = TSPostDraftObject.incrementaID()
        realm.beginWrite()
        realm.add(object, update: true)
        try! realm.commitWrite()
    }
    /// 修改帖子草稿 - id不变
    func updatePostDraft(_ post: TSPostDraftModel) -> Void {
        realm.beginWrite()
        realm.add(post.object(), update: true)
        try! realm.commitWrite()
    }
    /// 删除帖子草稿
    func deletePostDraft(draftId: Int) -> Void {
        if let object = realm.object(ofType: TSPostDraftObject.self, forPrimaryKey: draftId) {
            try! realm.write {
                realm.delete(object)
            }
        }
    }
    func deleteAllPostDraft() -> Void {
        let objects = realm.objects(TSPostDraftObject.self)
        try! realm.write {
            realm.delete(objects)
        }
    }
}

// MARK: - 问题草稿
extension TSDraftRealmManager {
    /// 获取问题草稿列表
    func getQuestionDraftList() -> [TSQuestionDraftModel] {
        let objects = realm.objects(TSQuestionDraftObject.self)
        var draftList = [TSQuestionDraftModel]()
        for object in objects {
            draftList.append(TSQuestionDraftModel(object: object))
        }
        return draftList
    }
    /// 增加问题草稿 - id自增
    func addQuestionDraft(_ question: TSQuestionDraftModel) -> Void {
        let object = question.object()
        // id自增
        object.draftId = TSQuestionDraftObject.incrementaID()
        realm.beginWrite()
        realm.add(object, update: true)
        try! realm.commitWrite()
    }
    /// 修改问题草稿 - id不变
    func updateQuestionDraft(_ question: TSQuestionDraftModel) -> Void {
        realm.beginWrite()
        realm.add(question.object(), update: true)
        try! realm.commitWrite()
    }
    /// 删除问题草稿
    func deleteQuestionDraft(draftId: Int) -> Void {
        if let object = realm.object(ofType: TSQuestionDraftObject.self, forPrimaryKey: draftId) {
            try! realm.write {
                realm.delete(object)
            }
        }
    }
    func deleteAllQuestionDraft() -> Void {
        let objects = realm.objects(TSQuestionDraftObject.self)
        try! realm.write {
            realm.delete(objects)
        }
    }
}

// MARK: - 答案草稿
extension TSDraftRealmManager {
    /// 获取答案草稿列表
    func getAnswerDraftList() -> [TSAnswerDraftModel] {
        let objects = realm.objects(TSAnswerDraftObject.self)
        var draftList = [TSAnswerDraftModel]()
        for object in objects {
            draftList.append(TSAnswerDraftModel(object: object))
        }
        return draftList
    }
    /// 增加答案草稿 - id自增
    func addAnswerDraft(_ answer: TSAnswerDraftModel) -> Void {
        let object = answer.object()
        // id自增
        object.draftId = TSAnswerDraftObject.incrementaID()
        realm.beginWrite()
        realm.add(object, update: true)
        try! realm.commitWrite()
    }
    /// 修改答案草稿 - id不变
    func updateAnswerDraft(_ answer: TSAnswerDraftModel) -> Void {
        realm.beginWrite()
        realm.add(answer.object(), update: true)
        try! realm.commitWrite()
    }
    /// 删除答案草稿
    func deleteAnswerDraft(draftId: Int) -> Void {
        if let object = realm.object(ofType: TSAnswerDraftObject.self, forPrimaryKey: draftId) {
            try! realm.write {
                realm.delete(object)
            }
        }
    }
    func deleteAllAnswerDraft() -> Void {
        let objects = realm.objects(TSAnswerDraftObject.self)
        try! realm.write {
            realm.delete(objects)
        }
    }
}
