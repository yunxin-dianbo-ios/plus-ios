//
//  TSPostDraftModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 04/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  圈子帖子的草稿数据模型

import Foundation
import RealmSwift

class TSPostDraftModel {
    /// 草稿id
    var draftId: Int = 0
    /// 发帖样式
    var showType: PostPublishController.ShowType = .groupout
    ///
    var groupId: Int? = nil
    var groupName: String? = nil

    /// 是否同步到动态
    var isSyncMoment: Bool? = nil

    /// 帖子标题
    var title: String? = nil
    /// 帖子内容
    var summary: String? = nil
    var markdown: String? = nil

    /// 最新编辑时间
    var updateDate: Date = Date()
    /// 创建时间
    var createDate: Date = Date()

    init() {

    }

    /// 从数据库中加载
    init(object: TSPostDraftObject) {
        self.draftId = object.draftId
        self.updateDate = object.updateDate
        self.createDate = object.createDate
        if let showType = PostPublishController.ShowType(rawValue: object.showType) {
            self.showType = showType
        }
        self.groupId = object.groupId.value
        self.groupName = object.groupName
        self.isSyncMoment = object.isSyncMoment.value
        self.title = object.title
        self.summary = object.summary
        self.markdown = object.markdown
    }
    /// 转换成数据库模型
    func object() -> TSPostDraftObject {
        let object = TSPostDraftObject()
        object.draftId = self.draftId
        object.updateDate = self.updateDate
        object.createDate = self.createDate
        object.showType = self.showType.rawValue
        object.groupId = RealmOptional<Int>(self.groupId)
        object.groupName = self.groupName
        object.isSyncMoment = RealmOptional<Bool>(self.isSyncMoment)
        object.title = self.title
        object.summary = self.summary
        object.markdown = self.markdown
        return object
    }
}
