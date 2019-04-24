//
//  TSQuoraTopicModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答话题数据模型

import ObjectMapper

class TSQuoraTopicModel: Mappable {

    /// 话题ID
    var id: Int = 0
    /// 话题名称
    var name: String = ""
    /// 话题描述
    var description: String = ""
    /// 话题下的问题数量统计
    var questionsCount: Int = 0
    /// 话题下的关注用户统计
    var followsCount: Int = 0
    /// 当前对象是否关注话题
    var isFollow: Bool = false
    /// 话题头像，如果存在则为「字符串」，否则固定值 null
    var avatar: TSNetFileModel?
    /// 专家列表
    var experts: [TSUserInfoModel] = []
    var expertsCount = 0

    // MARK: - Mappable

    required init?(map: Map) {
    }
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        description <- map["description"]
        questionsCount <- map["questions_count"]
        followsCount <- map["follows_count"]
        isFollow <- map["has_follow"]
        avatar <- map["avatar"]
        experts <- map["experts"]
        expertsCount <- map["experts_count"]
    }

    // MARK: - DB
    init(object: TSQuoraTopicObject) {
        id = object.id
        name = object.name
        description = object.topicDescription
        questionsCount = object.questionsCount
        followsCount = object.followsCount
        if nil != object.avatar {
            self.avatar = TSNetFileModel(object: object.avatar!)
        }
        expertsCount = object.expertsCount
        for expertObject in object.experts {
            let model = TSUserInfoModel(object: expertObject)
            experts.append(model)
        }
    }

    func object() -> TSQuoraTopicObject {
        let object = TSQuoraTopicObject()
        object.id = id
        object.name = name
        object.topicDescription = description
        object.questionsCount = questionsCount
        object.followsCount = followsCount
        object.avatar = avatar?.object()
        object.expertsCount = expertsCount
        for expert in experts {
            let expertObject = expert.object()
            object.experts.append(expertObject)
        }
        return object
    }

    // MARK: - Initialize

    /// 通过话题详情页的 view model 创建
    ///
    /// - Parameter topicDetailModel: 话题详情页的 view model
    init(topicDetailModel: TopicDetailControllerModel) {
        id = topicDetailModel.basicInfoModel.id
        name = topicDetailModel.basicInfoModel.title
    }
}
