//
//  TSAnswerDraftModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 11/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  答案草稿箱模型

import Foundation
import RealmSwift

class TSAnswerDraftModel {

    /// 草稿箱id
    var draftId: Int = 0
    /// 所回答的问题id
    var questionId: Int = 0
    /// 所回答的问题标题
    var questionTitle: String?
    /// 是否匿名
    var isAnonymity: Bool = false
    /// 草稿箱保存的答案，markdown版
    var markdown: String = ""
    /// 草稿箱保存的答案，纯文字版，用于列表展示，为nil表示兼容之前的
    var content: String? = nil
    /// 最新编辑时间
    var updateDate: Date = Date()
    /// 创建时间
    var createDate: Date = Date()

    /// 答案id，用于判断是 发布答案的草稿 还是 编辑答案的草稿
    var answerId: Int?

    init() {

    }

    /// 从数据库中加载
    init(object: TSAnswerDraftObject) {
        self.draftId = object.draftId
        self.questionId = object.questionId
        self.questionTitle = object.questionTitle
        self.isAnonymity = object.isAnonymity
        self.markdown = object.markdown
        self.content = object.content
        self.updateDate = object.updateDate
        self.createDate = object.createDate
        self.answerId = object.answerId.value
    }
    /// 转换成数据库模型
    func object() -> TSAnswerDraftObject {
        let object = TSAnswerDraftObject()
        object.draftId = self.draftId
        object.questionId = self.questionId
        object.questionTitle = self.questionTitle
        object.isAnonymity = self.isAnonymity
        object.markdown = self.markdown
        object.content = self.content
        object.updateDate = self.updateDate
        object.createDate = self.createDate
        object.answerId = RealmOptional<Int>(self.answerId)
        return object
    }

}
