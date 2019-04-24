//
//  FeedListRealmManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表 数据库管理

import UIKit
import RealmSwift

class FeedListRealmManager {

    fileprivate let realm: Realm!

    // MARK: - Lifecycle
    init() {
        let realm = try! Realm()
        self.realm = realm
    }

    /// 获取列表的动态列表
    func get(feedlist type: FeedListType) -> [FeedListObject] {
        let objectType: FeedListObject.Type
        switch type {
        case .new:
            objectType = NewFeedListObject.self
        case .hot:
            objectType = HotFeedsListObject.self
        case .follow:
            objectType = FollowFeedListObject.self
        }
        return Array(realm.objects(objectType).sorted(byKeyPath: "sortId", ascending: true))
    }

    func deleteAll() {
        let feeds = realm.objects(FeedListObject.self)
        let hotFeeds = realm.objects(HotFeedsListObject.self)
        let followFeeds = realm.objects(FollowFeedListObject.self)
        let newFeeds = realm.objects(NewFeedListObject.self)
        let comments = realm.objects(FeedListCommentObject.self)
        let avatars = realm.objects(AvatarObject.self)
        let tools = realm.objects(FeedListToolObject.self)
        let pics = realm.objects(PaidPictureObject.self)
        let paidInfo = realm.objects(PiadInfoObject.self)
        try! realm.write {
            realm.delete(feeds)
            realm.delete(hotFeeds)
            realm.delete(followFeeds)
            realm.delete(newFeeds)
            realm.delete(comments)
            realm.delete(avatars)
            realm.delete(tools)
            realm.delete(pics)
            realm.delete(paidInfo)
        }
    }

    /// 储存动态列表
    func save(feedlist objects: [FeedListObject]) {
        try! realm.write {
            realm.add(objects)
        }
    }

    /// 删除动态列表
    func delete(feedlist type: FeedListType) {
        let objectType: FeedListObject.Type
        switch type {
        case .new:
            objectType = NewFeedListObject.self
        case .hot:
            objectType = HotFeedsListObject.self
        case .follow:
            objectType = FollowFeedListObject.self
        }
        let results = realm.objects(objectType)
        try! realm.write {
            realm.delete(results)
        }
    }
}
