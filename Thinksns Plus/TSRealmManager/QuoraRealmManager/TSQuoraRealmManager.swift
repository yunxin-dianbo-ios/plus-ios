//
//  TSQuoraRealmManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问答模块数据库管理

import Foundation
import RealmSwift

class TSQuoraRealmManager {
    fileprivate let realm: Realm!

    // MARK: - Lifecycle
    init() {
        let realm = try! Realm()
        self.realm = realm
    }

    /// 删除整个表
    func deleteAll() {
        self.deleteAllQuoraDetails()
        self.deleteAllAnserList()
        emptySearchObjects(type: .question)
        emptySearchObjects(type: .topic)
    }
}

// MARK: - 问答列表

extension TSQuoraRealmManager {

}

// MARK: - 问答详情

extension TSQuoraRealmManager {
    /// 获取指定的问答详情
    func getQuoraDetail(in questionId: Int) -> TSQuoraDetailModel? {
        if let object = realm.object(ofType: TSQuoraDetailObject.self, forPrimaryKey: questionId) {
            return TSQuoraDetailModel(object: object)
        } else {
            return nil
        }
    }
    /// 存储指定的问答详情
    func save(_ quora: TSQuoraDetailModel) -> Void {
        self.save(quora.object())
    }
    func save(_ quora: TSQuoraDetailObject) -> Void {
        realm.beginWrite()
        realm.add(quora, update: true)
        try! realm.commitWrite()
    }
    /// 删除指定的问答详情
    func delete(quoraId: Int) -> Void {
        if let object = realm.object(ofType: TSQuoraDetailObject.self, forPrimaryKey: quoraId) {
            try! realm.write {
                realm.delete(object)
            }
        }
    }
    func delete(_ quora: TSQuoraDetailModel) -> Void {
        self.delete(quora.object())
    }
    func delete(_ quora: TSQuoraDetailObject) -> Void {
        try! realm.write {
            realm.delete(quora)
        }
    }
    /// 删除所有的问答详情
    func deleteAllQuoraDetails() -> Void {
        let objects = realm.objects(TSQuoraDetailObject.self)
        try! realm.write {
            realm.delete(objects)
        }
    }
}

// MARK: - 问答答案列表

extension TSQuoraRealmManager {
    /// 获取指定问题下的答案列表
    func getAnswerList(in questionId: Int, orderType: TSAnserOrderType) -> [TSAnswerListModel] {
        var anserList = [TSAnswerListModel]()
        let filter = String(format: "questionId == \(questionId)")
        var orderPath: String
        switch orderType {
        case .diggCount:
            orderPath = "likesCount"
        case .publishTime:
            orderPath = "createDate"
        }
        // ascending 升序
        let objects = realm.objects(TSAnswerListObject.self).filter(filter).sorted(byKeyPath: orderPath, ascending: false)
        for object in objects {
            anserList.append(TSAnswerListModel(object: object))
        }
        return anserList
    }
    /// 存储指定问题下的答案列表
    func save(_ answerList: [TSAnswerListModel]) -> Void {
        for answer in answerList {
            realm.beginWrite()
            realm.add(answer.object(), update: true)
            try! realm.commitWrite()
        }
    }
    func save(_ anserList: [TSAnswerListObject]) -> Void {
        realm.beginWrite()
        realm.add(anserList, update: true)
        try! realm.commitWrite()
    }
    /// 删除指定问题下的答案列表
    func delteAnswerList(in questionId: Int) -> Void {
        let filter = String(format: "questionId == \(questionId)")
        let objects = realm.objects(TSAnswerListObject.self).filter(filter)
        try! realm.write {
            realm.delete(objects)
        }
    }
    /// 删除所有的答案列表
    func deleteAllAnserList() -> Void {
        let objects = realm.objects(TSAnswerListObject.self)
        try! realm.write {
            realm.delete(objects)
        }
    }
}

// MARK: - 问答答案详情

// MARK: - 问答xxx

// MARK: - 问答搜索
extension TSQuoraRealmManager {

    /// 创建搜索记录
    func saveSearchObject(content: String, type: QuoraSearchHistoryObject.SearchType) {
        let timeInterval = Int(Date().timeIntervalSince1970 as Double * 1_000_000_000)
        let object = QuoraSearchHistoryObject()
        object.timeInterval = timeInterval
        object.content = content
        object.typeId = type.rawValue
        try! realm.write {
            realm.add(object, update: true)
        }
    }

    /// 删除某条搜索记录
    func delete(searchObject: QuoraSearchHistoryObject) {
        try! realm.write {
            realm.delete(searchObject)
        }
    }
    /// 是否有置顶内容的搜索记录 ，true 有
    func hasContent(content: String) -> Bool {
        let searchObjects = realm.objects(QuoraSearchHistoryObject.self).filter("content == %@", content)
        return !searchObjects.isEmpty
    }

    /// 清空置顶内容的搜索记录
    func deleteByContent(content: String) {
        let searchObjects = realm.objects(QuoraSearchHistoryObject.self).filter("content == %@", content)
        try! realm.write {
            realm.delete(searchObjects)
        }
    }
    /// 清空某种类型的搜索记录
    func emptySearchObjects(type: QuoraSearchHistoryObject.SearchType) {
        let searchObjects = realm.objects(QuoraSearchHistoryObject.self).filter("typeId == \(type.rawValue)")
        try! realm.write {
            realm.delete(searchObjects)
        }
    }

    /// 获取某种类型的搜索记录
    func getSearObjects(type: QuoraSearchHistoryObject.SearchType) -> Results<QuoraSearchHistoryObject> {
        let searchObjects = realm.objects(QuoraSearchHistoryObject.self).filter("typeId == \(type.rawValue)").sorted(byKeyPath: "timeInterval", ascending: false)
        return searchObjects
    }
}
