//
//  TSRepostModel.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/31.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

enum TSRepostType: String {
    /// 动态
    case postWord
    case postImage
    case postVideo
    /// 圈子
    case group
    /// 帖子
    case groupPost
    /// 资讯
    case news
    /// 问题
    case question
    /// 回答
    case questionAnswer
    /// 已删除
    case delete
}
class TSRepostModel: Object {
    /// 是否可以进入详情
    dynamic var couldShowDetail: Bool = true
    /// 分享最大内容数量
    fileprivate let maxContenWord = 60
    /// 类型
    var type: TSRepostType = .postWord
    /// 用于object传递,优先使用该字段
    dynamic var typeStr: String?
    /// 基本ID
    dynamic var id: Int = 0
    /// 附加ID,比如帖子需要的圈子ID
    dynamic var subId: Int = 0
    /// 标题内容
    dynamic var title: String?
    /// 正文内容
    dynamic var content: String?
    /// 封面
    dynamic var coverImage: String?
    /// 根据typeStr更新type
    func updataModelType() {
        if let typeStr = self.typeStr {
            if typeStr == "postWord" {
                self.type = .postWord
            } else if typeStr == "postVideo" {
                self.type = .postVideo
            } else if typeStr == "postImage" {
                self.type = .postImage
            } else if typeStr == "group" {
                self.type = .group
            } else if typeStr == "groupPost" {
                self.type = .groupPost
            } else if typeStr == "news" {
                self.type = .news
            } else if typeStr == "question" {
                self.type = .question
            } else if typeStr == "questionAnswer" {
                self.type = .questionAnswer
            } else if typeStr == "delete" {
                /// 已经删除
                self.type = .delete
            } else {
                /// 已经删除
                self.type = .delete
            }
        }
    }
    // MARK: - 动态
    class func coverPostModel(feedModel: FeedListCellModel) -> TSRepostModel {
        let repostModel = TSRepostModel()
        if let feedId = feedModel.id["feedId"] {
            repostModel.id = feedId
        }
        if feedModel.videoURL.count > 0 {
            repostModel.type = .postVideo
        } else if feedModel.pictures.count > 0 {
            repostModel.type = .postImage
        } else {
            repostModel.type = .postWord
        }
        repostModel.title = feedModel.userName
        repostModel.content = feedModel.content
        if let content = repostModel.content, content.count > TSRepostModel().maxContenWord {
            repostModel.content = content.substring(to: content.index(content.startIndex, offsetBy: TSRepostModel().maxContenWord))
        }
        return repostModel
    }
    class func coverPostMomentListModel(momentListModel: TSMomentListCellModel) -> TSRepostModel {
        let repostModel = TSRepostModel()
        repostModel.id = (momentListModel.data?.feedIdentity)!
        repostModel.title = momentListModel.userInfo?.name
        repostModel.content = momentListModel.data?.content
        if let videoURL = momentListModel.data?.videoURL, videoURL.count > 0 {
            repostModel.type = .postVideo
        } else if let pictures = momentListModel.data?.pictures, pictures.count > 0 {
            repostModel.type = .postImage
        } else {
            repostModel.type = .postWord
        }
        if let content = repostModel.content, content.count > TSRepostModel().maxContenWord {
            repostModel.content = content.substring(to: content.index(content.startIndex, offsetBy: TSRepostModel().maxContenWord))
        }
        return repostModel
    }
    // MARK: - 圈子
    class func coverGroupModel(groupModel: GroupModel) -> TSRepostModel {
        let repostModel = TSRepostModel()
        repostModel.id = groupModel.id
        repostModel.type = .group
        repostModel.coverImage = TSUtil.praseTSNetFileUrl(netFile: groupModel.avatar)
        repostModel.title = groupModel.name
        repostModel.content = groupModel.summary
        if let content = repostModel.content, content.count > TSRepostModel().maxContenWord {
            repostModel.content = content.substring(to: content.index(content.startIndex, offsetBy: TSRepostModel().maxContenWord))
        }
        return repostModel
    }
    // MARK: - 帖子 详情model
    class func coverGroupPostDetailModel(groupPostDetailModel: PostDetailModel) -> TSRepostModel {
        let repostModel = TSRepostModel()
        repostModel.id = groupPostDetailModel.id
        repostModel.subId = groupPostDetailModel.groupId
        repostModel.type = .groupPost
        let images = groupPostDetailModel.body.ts_customMarkdownToStandard().ts_getMarkdownImageUrl()
        if images.count > 0 {
            repostModel.coverImage = images[0]
        } else {
            repostModel.coverImage = nil
        }
        repostModel.title = groupPostDetailModel.title
        repostModel.content = groupPostDetailModel.summary.count > 0 ? TSRepostModel.getShareContentFromMarkdown(markDownContent: groupPostDetailModel.summary) : TSRepostModel.getShareContentFromMarkdown(markDownContent: groupPostDetailModel.body)
        if let content = repostModel.content, content.count > TSRepostModel().maxContenWord {
            repostModel.content = content.substring(to: content.index(content.startIndex, offsetBy: TSRepostModel().maxContenWord))
        }
        return repostModel
    }
    // MARK: - 帖子 列表model
    class func coverGroupPostListModel(groupPostListModel: FeedListCellModel) -> TSRepostModel {
        let repostModel = TSRepostModel()
        if let feedId = groupPostListModel.id["postId"], let groupId = groupPostListModel.id["groupId"] {
            repostModel.id = feedId
            repostModel.subId = groupId
        }
        if groupPostListModel.pictures.count > 0 {
            repostModel.coverImage = groupPostListModel.pictures[0].url
            repostModel.content = "[图片]"
        } else {
            repostModel.content = TSRepostModel.getShareContentFromMarkdown(markDownContent: groupPostListModel.content)
        }
        repostModel.type = .groupPost
        repostModel.title = groupPostListModel.title
        if let content = repostModel.content, content.count > TSRepostModel().maxContenWord {
            repostModel.content = content.substring(to: content.index(content.startIndex, offsetBy: TSRepostModel().maxContenWord))
        }
        return repostModel
    }
    // MARK: - 资讯
    class func coverNewsModel(newsModel: NewsDetailModel) -> TSRepostModel {
        let repostModel = TSRepostModel()
        repostModel.type = .news
        repostModel.id = newsModel.id
        repostModel.title = newsModel.title
        repostModel.content = newsModel.subject != nil ? newsModel.subject : TSRepostModel.getShareContentFromMarkdown(markDownContent: newsModel.content_markdown)
        if let imgInfos = newsModel.coverInfos, imgInfos.isEmpty == false {
            let imgUrl = TSURLPath.imageV2URLPath(storageIdentity: imgInfos[0].id, compressionRatio: 20, cgSize: imgInfos[0].size)
            repostModel.coverImage = imgUrl?.absoluteString
        }
        if let content = repostModel.content, content.count > TSRepostModel().maxContenWord {
            repostModel.content = content.substring(to: content.index(content.startIndex, offsetBy: TSRepostModel().maxContenWord))
        }
        return repostModel
    }
    // MARK: - 问题
    class func coverQuestionModel(questionModel: TSQuestionDetailModel) -> TSRepostModel {
        let repostModel = TSRepostModel()
        repostModel.type = .question
        repostModel.id = questionModel.id
        repostModel.title = questionModel.title
        repostModel.content = TSRepostModel.getShareContentFromMarkdown(markDownContent: questionModel.body)
        if let content = repostModel.content, content.count > TSRepostModel().maxContenWord {
            repostModel.content = content.substring(to: content.index(content.startIndex, offsetBy: TSRepostModel().maxContenWord))
        }
        return repostModel
    }
    // MARK: - 回答
    class func coverQuestionAnswerModel(questionAnswerModel: TSAnswerDetailModel) -> TSRepostModel {
        let repostModel = TSRepostModel()
        repostModel.type = .questionAnswer
        repostModel.id = questionAnswerModel.id
        repostModel.title = questionAnswerModel.question?.title
        repostModel.content = TSRepostModel.getShareContentFromMarkdown(markDownContent: questionAnswerModel.body)
        if let content = repostModel.content, content.count > TSRepostModel().maxContenWord {
            repostModel.content = content.substring(to: content.index(content.startIndex, offsetBy: TSRepostModel().maxContenWord))
        }
        return repostModel
    }
    // MARK: - 统一的MarkDown格式的内容处理,比如帖子、资讯、问答等内容都需要统一处理
    fileprivate class func getShareContentFromMarkdown(markDownContent: String) -> String {
        /// 移除html标签以及\n等符号 -> 转标准markdown(如果是TS的markdown格式) -> 将图片样式转换为[图片]
        return markDownContent.ts_filterMarkdownTagsToPlainText().ts_customMarkdownToStandard().ts_standardMarkdownToNormal()
    }
}
