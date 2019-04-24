//
//  TSmessagePopModel.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/8.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

enum messageType {
    /// 纯文字
    case text
    /// 图片
    case pic
    /// 视频
    case video
    /// 圈子图片
    case groupPic
    /// 帖子纯文字
    case postText
    /// 帖子图片
    case postPic
    /// 资讯纯文字
    case newsText
    /// 资讯图片
    case newsPic
    /// 问题详情
    case question
    /// 回答详情
    case questionAnswer
}

class TSmessagePopModel {

    var titleFirst = "发送给："
    var titleSecond = ""
    /// 正文标题（用户名、圈子名称、帖子标题、资讯标题）
    var owner = ""
    var imageIcon: UIImage = #imageLiteral(resourceName: "ico_pic_disabled")
    /// 正文内容（圈子简介、帖子正文）
    var content = "查看图片"
    var contentType = messageType.text
    /// 动态id 帖子id 资讯id 圈子id（圈子类型的时候）
    var feedId = 0
    var coverImage = ""
    /// 帖子类型的时候圈子的id
    var groupId = 0
    /// 留言内容
    var noteContent = ""
    init() {
    }

    init(momentModel: FeedListCellModel) {
        feedId = momentModel.id["feedId"] ?? 0
        self.owner = momentModel.userName
        contentType = .text
        content = momentModel.content
        if momentModel.pictures.count > 0 {
            self.imageIcon = #imageLiteral(resourceName: "ico_pic_disabled")
            contentType = .pic
            content = "查看图片"
        }
        if !momentModel.videoURL.isEmpty {
            self.imageIcon = #imageLiteral(resourceName: "ico_video_disabled")
            contentType = .video
            content = "查看视频"
        }
    }
    init(momentDetail: TSMomentListCellModel) {
        feedId = momentDetail.data?.feedIdentity ?? 0
        self.owner = momentDetail.userInfo?.name ?? ""
        contentType = .text
        content = momentDetail.data?.content ?? ""
        if !(momentDetail.data?.pictures.isEmpty)! {
            self.imageIcon = #imageLiteral(resourceName: "ico_pic_disabled")
            contentType = .pic
            content = "查看图片"
        }
        if momentDetail.data?.videoURL != nil {
            self.imageIcon = #imageLiteral(resourceName: "ico_video_disabled")
            contentType = .video
            content = "查看视频"
        }
    }
    init(groupDetail: PostListControllerModel) {
        feedId = groupDetail.id
        self.owner = groupDetail.name
        content = groupDetail.intro
        contentType = .text
        if groupDetail.coverImage.count > 0 {
            contentType = .groupPic
            coverImage = groupDetail.coverImage
        }
    }
    init(postMomentModel: FeedListCellModel) {
        feedId = postMomentModel.id["postId"] ?? 0
        groupId = postMomentModel.id["groupId"] ?? 0
        self.owner = postMomentModel.title
        contentType = .postText
        content = postMomentModel.content.ts_customMarkdownToNormal().ts_filterMarkdownTagsToPlainText()
        if postMomentModel.pictures.count > 0 {
            contentType = .postPic
            content = postMomentModel.content.ts_filterMarkdownTagsToPlainText()
            coverImage = postMomentModel.pictures[0].url ?? ""
        }
    }
    init(postDetail: PostDetailModel) {
        feedId = postDetail.id
        groupId = postDetail.groupId
        self.owner = postDetail.title
        contentType = .postText
        content = postDetail.body.ts_customMarkdownToNormal().ts_filterMarkdownTagsToPlainText()
    }
    init(newsDetail: NewsDetailModel) {
        feedId = newsDetail.id
        self.owner = newsDetail.title
        contentType = .newsText
        content = newsDetail.subject?.ts_customMarkdownToNormal().ts_filterMarkdownTagsToPlainText() ?? newsDetail.content_markdown.ts_customMarkdownToNormal().ts_filterMarkdownTagsToPlainText()
    }
    /// 问题
    init(questionDetail: TSQuestionDetailModel) {
        feedId = questionDetail.id
        self.owner = questionDetail.title
        contentType = .question
        if let bogyText = questionDetail.body_text {
            content = bogyText.ts_customMarkdownToNormal()
        } else {
            content = questionDetail.body.ts_customMarkdownToNormal()
        }
    }
    /// 回答
    init(questionAnswer: TSAnswerDetailModel) {
        feedId = questionAnswer.id
        if let questionTitle = questionAnswer.question?.title {
            self.owner = questionTitle
        } else {
            self.owner = "回答了问题:"
        }
        contentType = .questionAnswer
        if let bogyText = questionAnswer.body_text {
            content = bogyText.ts_customMarkdownToNormal()
        } else {
            content = questionAnswer.body.ts_customMarkdownToNormal()
        }
    }
}
