//
//  NewsDetailModel.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import Regex
import ObjectMapper

///  资讯详情数据模型
class NewsDetailModel: NewsModel {
    /// 内容，markdown格式
    var content_markdown: String!
    /// 内容，纯文本格式
    var content_text: String? = nil
    /// 点赞数
    var diggCount: Int!
    /// 评论数
    var commentCount: Int!
    /// 是否推荐
    var isRecommend: Bool!
    /// 标签信息
    var labels: [TSLabelModel] = []
    /// 审核状态
    var verifyState: NewsVerifyState!
    /// 投稿金额
    var contributionAmount: Int!
    /// 是否收藏
    var isCollect: Bool!
    /// 是否置顶
    var isTop: Bool!
    /// 审核次数
    var verifyCount: Int!

    /// 原始内容，没有经过处理，仍然是自定义的markdown格式
    var originContent: String = ""

    override func mapping(map: Map) {
        super.mapping(map: map)
        originContent <- map["content"]
        content_markdown <- (map["content"], TSNewsDetailContentTransfrom())
        content_text <- map["text_content"]
        diggCount <- map["digg_count"]
        commentCount <- map["comment_count"]
        isRecommend <- map["is_recommend"]
        labels <- map["tags"]
        verifyState <- (map["audit_status"], TSNewsVerifyStateTransfrom())
        contributionAmount <- map["contribute_amount"]
        isCollect <- map["has_collect"]
        isTop <- map["is_pinned"]
        verifyCount <- map["audit_count"]
    }
}

/// 资讯内容详情转化 将资讯详情内,所有的字符串 @![title](file id) 转换为 ![title](file rul)
class TSNewsDetailContentTransfrom: TransformType {
    public typealias Object = String
    public typealias JSON = String

    func transformFromJSON(_ value: Any?) -> Object? {
        if let content = value as? String {
            let imgRegex = Regex("@!\\[(.*)]\\(([0-9]+)\\)")
            if imgRegex.matches(content) {
                return content.ts_customMarkdownToStandard()
            }
            return content
        }
        return nil
    }

    func transformToJSON(_ value: Object?) -> JSON? {
        assert(false, "暂时不支持")
        return nil
    }

    private func convert(_ content: String) -> String {
        let imgRegex = Regex("@!\\[(.*)]\\(([0-9]+)\\)")
        var newContent = content
        let url = TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue
        while imgRegex.matches(newContent) == true {
            newContent = newContent.replacingFirst(matching: imgRegex, with: String(format:"![$1](%@/$2)", url))
        }
        return newContent
    }
}
