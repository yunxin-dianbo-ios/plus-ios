//
//  TSNewsContributeModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 17/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯发布模型

import Foundation
import Regex

class TSNewsContributeModel {
    /// 标题
    var title: String?
    /// 正文，markdown格式
    var content_markdown: String?
    /// 正文，纯文本格式
    var content_text: String?
    /// 选中的栏目
    var selectedCategory: TSNewsCategoryModel?
    /// 选择的标签列表
    var selectedTagList: [TSTagModel]?
    /// 文章来源
    var source: String?
    /// 作者
    var author: String?
    /// 摘要
    var abstract: String?
    /// 封面
    var coverFileId: Int?
    /// 第一张图片
    var firstImageId: Int?

    /// 资讯的id，主要用于修改资讯
    var newsId: Int?
    /// 初始的封面id，用于修改咨询时判断封面id是否更改，若没有更改，则不传该字段
    var originCoverId: Int?

    /// 判断内容是否为空
    func isEmpty() -> Bool {
        var emptyFlag: Bool = true
        // 任何一个有值，都不为空
        if nil != self.title && !self.title!.isEmpty {
            emptyFlag = false
        } else if nil != self.content_markdown && !self.content_markdown!.isEmpty {
            emptyFlag = false
        } else if nil != self.content_text && !self.content_text!.isEmpty {
            emptyFlag = false
        } else if nil != self.selectedCategory {
            emptyFlag = false
        } else if nil != self.selectedTagList && !self.selectedTagList!.isEmpty {
            emptyFlag = false
        } else if nil != self.source && !self.source!.isEmpty {
            emptyFlag = false
        } else if nil != self.author && !self.author!.isEmpty {
            emptyFlag = false
        } else if nil != self.abstract && !self.abstract!.isEmpty {
            emptyFlag = false
        } else if nil != self.coverFileId || nil != self.firstImageId {
            emptyFlag = false
        }
        return emptyFlag
    }

    init() {

    }
    init(news: NewsDetailModel) {
        self.newsId = news.id

        self.title = news.title
        self.content_markdown = news.originContent
        self.content_text = news.content_text
        self.source = news.from
        self.author = news.author
        self.abstract = news.subject
        // 栏目、分类
        if let category = news.categoryInfo {
            self.selectedCategory = TSNewsCategoryModel(newsCategory: category)
        }
        // 标签
        var tagList: [TSTagModel] = [TSTagModel]()
        for label in news.labels {
            tagList.append(TSTagModel(label: label))
        }
        self.selectedTagList = tagList
        // 封面图
        if let coverInofs = news.coverInfos, coverInofs.isEmpty == false {
            self.coverFileId = coverInofs[0].id
            self.originCoverId = coverInofs[0].id
        }
        // 第一张图
        if let fileId = news.originContent.ts_customMarkdownToStandard().ts_getMarkdownImageUrl().first {
            self.firstImageId = Int(fileId)
        }
    }

}
