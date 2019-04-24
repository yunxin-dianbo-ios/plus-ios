//
//  TSMomentListModel.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表数据类型

import UIKit
import SwiftyJSON
import ObjectMapper

struct TSMomentListModel {

    /// 用户标识
    var userIdentity: Int
    /// 动态唯一标识符
    var feedMark: Int64

    /// 动态内容
    var moment: TSMomentFeedModel
    /// 动态工具栏
    var tool: TSMomentToolModel
    /// 动态评论（最新三条）
    var comments: [TSMomentCommnetModel]

    // MARK: - V2 数据

    /// 纬度
    var latitude: String?
    /// 经度
    var longtitude: String?
    /// GeoHash
    var geohash: String?
    /// 审核状态
    var status: Int?

    /// 动态收费信息
    var paid: TSPaidFeedModel?
    /// 评论收费信息
    var commentPaid: TSPaidFeedModel?

    /// 点赞用户列表
    var diggs: [Int]?
    /// 打赏统计
    var rewardCount: TSNewsRewardCountModel?
    // 短视频文件标识
    var videoID: Int?
    // 短视频封面标识
    var coverID: Int?
    // 短视频高度
    var videoHeight: Int?
    // 短视频宽度
    var videoWidth: Int?
}

extension TSMomentListModel {

    // [长期注释] 由于 v2 接口数据结构的剧烈变更，时间有限，衡量许久，仅将 v2 的后数据的后台返回格式映射到 v1 的数据结构中。
    /// v2 接口的初始化方法
    init(dataV2 data: [String: Any]) {
        userIdentity = data["user_id"] as! Int
        feedMark = data["feed_mark"] as! Int64
        // 1.判断一下，动态是否是由当前用户发布的，如果是，将所有相关的付费状态改为已付费
        let isCurrentUser = TSCurrentUserInfo.share.userInfo?.userIdentity == userIdentity

        moment = TSMomentFeedModel()
        moment.repostType = data["repostable_type"] as? String
        if let repostId = data["repostable_id"] as? Int {
            moment.repostId = repostId
        }
        moment.topics = Mapper<TopicListModel>().mapArray(JSONArray: (data["topics"] as? [[String: Any]])!)
        moment.feedIdentity = data["id"] as! Int
        moment.create = (data["created_at"] as! String).convertToDate()
        moment.update = (data["updated_at"] as? String)?.convertToDate()
        moment.delete = (data["deleted_at"] as? String)?.convertToDate()
        moment.content = data["feed_content"] as? String ?? ""
        // 自定义的image标签替换为空字符串
        moment.content = moment.content.ts_customMarkdownToClearString()
        moment.from = data["feed_from"] as! Int
        if let video = data["video"] as? [String: Any] {
            videoID = video["video_id"] as? Int
            coverID = video["cover_id"] as? Int
            videoHeight = video["height"] as? Int
            videoWidth = video["width"] as? Int
        }
        if let imagesArray = data["images"] as? [[String: Any]] {
            for image in imagesArray {
                let imageObject = TSImageObject()
                imageObject.storageIdentity = image["file"] as! Int
                imageObject.type = image["type"] as? String
                imageObject.paid.value = image["paid"] as? Bool
                imageObject.mimeType = image["mime"] as! String
                // 如果是当前用户发布的动态，将图片付费状态改为已付费
                if isCurrentUser {
                    imageObject.paid.value = true
                }

                imageObject.node.value = image["paid_node"] as? Int
                imageObject.amount.value = image["amount"] as? Int

                if let sizeString = image["size"] as? String {
                    let key = "x"
                    guard sizeString.contains(key) else {
                        moment.pictures.append(imageObject)
                        continue
                    }
                    let items = sizeString.components(separatedBy: key)
                    imageObject.width = CGFloat(Float(items[0])!)
                    imageObject.height = CGFloat(Float(items[1])!)
                }
                moment.pictures.append(imageObject)
            }
        }

        tool = TSMomentToolModel()
        tool.digg = data["like_count"] as? Int ?? 0
        tool.view = data["feed_view_count"] as? Int ?? 0
        tool.comment = data["feed_comment_count"] as? Int ?? 0
        let hasDigg = data["has_like"] as? Bool ?? false
        let hasCollect = data["has_collect"] as? Bool ?? false
        tool.isDigg = hasDigg ? 1 : 0
        tool.isCollect = hasCollect ? 1 : 0

        latitude = data["feed_latitude"] as? String
        longtitude = data["feed_longtitude"] as? String
        geohash = data["feed_geohash"] as? String
        status = data["audit_status"] as? Int

        if let paidData = data["paid_node"] as? [String: Any] {
            paid = TSPaidFeedModel(data: paidData)
            // 如果是当前用户发布的动态，将动态付费状态改为已付费
            if isCurrentUser {
                paid?.paid = true
            }

        }

        if let commentPaidData = data["comment_paid_node"] as? [String: Any] {
            commentPaid = TSPaidFeedModel(data: commentPaidData)
            // 如果是当前用户发布的动态，将评论付费状态改为已付费
            if isCurrentUser {
                commentPaid?.paid = true
            }

        }

        comments = []
        if let commentsArray = data["comments"] as? [[String: Any]] {
            for item in commentsArray {
                let comment = TSMomentCommnetModel(item)
                comments.append(comment)
            }
        }

        diggs = data["diggs"] as? [Int]

        if let rewardCountInfo = data["reward"] as? [String: Any] {
            rewardCount = TSNewsRewardCountModel(JSON: rewardCountInfo)
        }
    }

    // MARK: - Convert

    /// 置顶动态 model 转 object
    func convertToTopObject() -> TSMomentListObject {
        let object = converToObject()
        object.isTop = true
        return object
    }

    /// model 转 object 方法
    func converToObject() -> TSMomentListObject {
        let object = TSMomentListObject()
        object.userIdentity = self.userIdentity
        object.sendState = 1

        // 动态信息
        object.feedIdentity = self.moment.feedIdentity
        object.primaryKey = self.moment.feedIdentity
        object.title = self.moment.title
        object.content = self.moment.content
        object.create = self.moment.create
        object.from = self.moment.from
        object.pictures.removeAll()
        for pictureObject in self.moment.pictures {
            object.pictures.append(pictureObject)
        }

        // 动态工具栏
        object.digg = self.tool.digg
        object.view = self.tool.view
        object.commentCount = self.tool.comment
        object.isDigg = self.tool.isDigg
        object.isCollect = self.tool.isCollect

        // 短视频
        if let videoID = videoID, let videoHeight = videoHeight, let videoWidth = videoWidth, let coverID = coverID {
            object.videoURL = videoID.imageUrl()
            let imageObject = TSImageObject()
            imageObject.cacheKey = ""
            imageObject.height = CGFloat(videoHeight)
            imageObject.width = CGFloat(videoWidth)
            imageObject.storageIdentity = coverID
            object.pictures.append(imageObject)
        }

        // 动态评论
        object.comments.removeAll()
        for commentModel in self.comments {
            let commentObject = TSMomentCommnetObject()
            commentObject.feedId = self.moment.feedIdentity
            commentObject.commentIdentity = commentModel.commentIdentity
            commentObject.content = commentModel.content
            commentObject.create = commentModel.create
            commentObject.replayToUserIdentity = commentModel.replayToUserIdentity
            commentObject.toUserIdentity = commentModel.toUserIdentity
            commentObject.userIdentity = commentModel.userIdentity
            commentObject.commentMark = commentModel.commentMark
            commentObject.painned.value = commentModel.painned
            object.comments.append(commentObject)
        }
        // 话题
        object.topics.removeAll()
        for topicmodel in self.moment.topics {
            let topicObj = TopicListObject()
            topicObj.topicId = topicmodel.topicId
            topicObj.topicTitle = topicmodel.topicTitle
            object.topics.append(topicObj)
        }
        // v2 数据
        object.latitude = latitude
        object.longtitude = longtitude
        object.geohash = geohash
        object.status.value = status
        if let paidModel = paid {
            let paidObject = TSPaidFeedObject()
            paidObject.setInfo(model: paidModel)
            object.paid = paidObject
        }
        if let commentPaidModel = commentPaid {
            let paidObject = TSPaidFeedObject()
            paidObject.setInfo(model: commentPaidModel)
            object.commentPaid = paidObject
        }
        if let diggModels = diggs {
            for diggModel in diggModels {
                let realmInt = RealmInt()
                realmInt.value = diggModel
                object.diggs.append(realmInt)
            }
        }
        if let rewardCount = rewardCount {
            let reward = TSRewardObject()
            reward.amount = rewardCount.amount
            reward.count = rewardCount.count
            object.reward = reward
        }
        /// 转发
        object.repostType = self.moment.repostType
        object.repostID = self.moment.repostId
        object.repostModel = self.moment.repostModel
        return object
    }
}
