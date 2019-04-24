//
//  TSQuoraTableCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答主页 cell 数据模型

import UIKit

class TSQuoraTableCellModel: NSObject {

    /// 问题 id
    var id: Int = -1
    /// 答案 id
    var answerId: Int?

    /// 顶部间距
    var top: StackSeperatorCellModel = {
        let top = StackSeperatorCellModel()
        top.height = 15
        top.lineColor = UIColor.white
        return top
    }()

    /// 标题
    var titleModel: QuoraStackTitleCellModel?
    /// 图片
    var imageModel: QuoraStackFullImageCellModel?
    /// 内容
    var contentModel: QuoraStackAvatarContentCellModel?
    /// 关注/回答/悬赏/时间
    var bottomInfoModel: QuoraStackBottomButtonsCellModel?

    /// 底部间距
    var bottom: StackSeperatorCellModel = {
        let bottom = StackSeperatorCellModel()
        bottom.height = 9.5
        bottom.lineColor = UIColor.white
        return bottom
    }()
    /// 分割线
    var seperator: StackSeperatorCellModel = {
        let seperator = StackSeperatorCellModel()
        seperator.height = 5
        seperator.lineColor = TSColor.inconspicuous.disabled
        return seperator
    }()

    // MARK: 辅助数据
    var dataArray: [AnyObject] {
        // 过滤掉为空的数据
        let array: [AnyObject?] = [top, titleModel, imageModel, contentModel, bottomInfoModel, bottom, seperator]
        return array.flatMap { $0 }
    }
}

extension TSQuoraTableCellModel {

    /// 我的问答的 cellModel
    ///
    /// 只有"标题"和"关注/回答/时间"的 cellModel
    convenience init(TitleAndFollow model: TSQuestionListModel) {
        self.init()
        // 0.问题 id 和答案 id
        id = model.id
        answerId = model.listShowingAnswer?.id
        // 1.标题
        titleModel = QuoraStackTitleCellModel()
        titleModel?.title = model.title
        if model.isExcellent { // 判断是否需要加精标签
            titleModel?.appendImage = .excellent
        }
        // 2.关注/回答/悬赏/时间
        bottomInfoModel = QuoraStackBottomButtonsCellModel()
        bottomInfoModel?.top = 10
        bottomInfoModel?.followCount = model.watchersCount
        bottomInfoModel?.answerCount = model.answersCount
        bottomInfoModel?.rewardNumber = model.amount
        bottomInfoModel?.time = model.createDate as NSDate
    }

    /// 问答主页的 cellModel
    ///
    /// 完整版的 cellModel
    convenience init(model: TSQuestionListModel) {
        self.init()
        // 0.问题 id 和答案 id
        id = model.id
        answerId = model.listShowingAnswer?.id
        // 1.标题
        titleModel = QuoraStackTitleCellModel()
        titleModel?.title = model.title
        if model.isExcellent { // 判断是否需要加精标签
            titleModel?.appendImage = .excellent
        }

        // 2.图片
        imageModel = TSQuoraTableCellModel.getImageModel(from: model.listShowingAnswer)

        // 3.文字内容
        contentModel = TSQuoraTableCellModel.getContentModel(from: model.listShowingAnswer)

        // 4.关注/回答/悬赏/时间
        bottomInfoModel = QuoraStackBottomButtonsCellModel()
        bottomInfoModel?.followCount = model.watchersCount
        bottomInfoModel?.answerCount = model.answersCount
        bottomInfoModel?.rewardNumber = model.amount
        bottomInfoModel?.time = model.createDate as NSDate
    }

}

// MARK: - 处理传入数据的一些辅助方法
extension TSQuoraTableCellModel {

    /// 获取 contentModel
    ///
    /// - Parameter answer: 问答列表中的答案数据模型
    /// - Returns: cell 文本头像数据模型
    class func getContentModel(from answer: TSAnswerListModel?) -> QuoraStackAvatarContentCellModel? {
        guard let answer = answer else {
            return nil
        }
        let content = QuoraStackAvatarContentCellModel()
        // 是否围观
        content.shouldHiddenContent = !(answer.could ?? true)
        // 用户名
        let answerUserName = answer.isAnonymity ? "匿名用户" : (answer.user?.name ?? "")
        // 文字内容
        if content.shouldHiddenContent {
            // 需要围观
            content.content = answerUserName  + "："
        } else {
            // 不需要围观
            // body_text为新的答案的文本描述字段，之前的为nil，则使用之前的方式处理
            let answer = answer.body_text ?? answer.body.ts_customMarkdownToNormal()
            content.content = answerUserName  + "：" + answer
        }
        if !answer.isAnonymity, let user = answer.user {
            // 用户头像
            content.avatarURL = TSUtil.praseTSNetFileUrl(netFile: user.avatar)
            // 用户性别
            content.sex = user.sex
            content.user = user
        }
        content.isAnonymity = answer.isAnonymity
        return content
    }

    /// 获取 imageModel
    ///
    /// - Parameter answer: 问答列表中的答案数据模型
    /// - Returns: 图片数据模型
    class func getImageModel(from answer: TSAnswerListModel?) -> QuoraStackFullImageCellModel? {
        guard let answer = answer else {
            return nil
        }
        // 计算问答列表上图片显示的大小
        let scale = UIScreen.main.scale
        let imageSize = CGSize(width: UIScreen.main.bounds.width * scale, height: UIScreen.main.bounds.width / 375 * 150 * scale)
        // 获取 MacDown String 中第一张图片的 url
        guard let imageURL = answer.body.getMarkdownImageURLs(imageSize: imageSize).first else {
            return nil
        }
        let image = QuoraStackFullImageCellModel(imageHeight: imageSize.height / scale, top: 15, bottom: 0)
        image.imageURL = imageURL
        return image
    }

}

extension String {

    /// 解析 markdown string 中信息
    ///
    /// - Parameters:
    ///   - string: markdown string
    ///   - imageSize: 图片大小
    /// - Returns: (图片 URL 数组，过滤掉所有图片信息的 markdown string)
    func getMarkdownImageURLs(imageSize: CGSize?) -> [URL] {
        // 1.创建正则表达类
        // 安卓那边用个这个 @!\[.*?]\((\d+)\)
        let regex = try! NSRegularExpression(pattern: "@!\\[(image|)\\]\\([0-9]*\\)", options: [])
        // 2.查询 string 参数中是否有匹配字段
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
        // 3.解析查询结果
        var images: [URL?] = []
        for match in matches {
            // 3.1 遍历查询结果
            for n in 0..<match.numberOfRanges {
                // 3.2 获取匹配字段
                let range = match.rangeAt(n)
                let imageString = self.subString(with: range) // @![image](xxx) 或者 @![](xx)
                // 3.3 裁切出 id
                guard let imageID = imageString.slice(from: "(", to: ")") else {
                    continue
                }
                // 3.4 结合 imageSize 和 imageID 信息，拼接出最终的 imageURL
                let imageURL = TSURLPath.imageV2URLPath(storageIdentity: Int(imageID), compressionRatio: nil, cgSize: imageSize)
                images.append(imageURL)
            }
        }
        // 4.过滤 nil 信息
        return images.flatMap { $0 }
    }

    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound)
            .flatMap { substringFrom in (range(of: to, range: substringFrom..<endIndex)?.lowerBound)
                .map {
                    substringTo in substring(with: substringFrom..<substringTo)
                }
        }
    }
}
