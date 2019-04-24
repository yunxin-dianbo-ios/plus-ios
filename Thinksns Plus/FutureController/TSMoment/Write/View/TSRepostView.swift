//
//  TSRePostView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/31.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
/*
 1、转发的卡片不同的内容样式的字体大小不同
 2、发布页面的字体大小和列表中的也不一样
 3、发布页面的布局和列表中的布局存在细微差别
 4、动态、圈子、帖子、问题、回答标题都是16pt，下面的文字就14pt；资讯：标题是14pt，下面的文字就12pt
 所以整体有两套布局配置，发布页面和列表页（详情页相同）
 */
import UIKit
import ActiveLabel
enum TSRepostViewType {
    /// 发布页面
    case postView
    /// 列表或者详情页
    case listView
}
struct TSRepostViewUX {
    /// 发布页面中
    static let postUINormalTitleFont: CGFloat = 16
    static let postUINormalContentFont: CGFloat = 14
    static let postUINewsTitleFont: CGFloat = 14
    static let postUINewsContentFont: CGFloat = 12
    // 视图的高度
    static let postUIPostWordCardHeight: CGFloat = 85
    static let postUIPostVideoCardHeight: CGFloat = 70
    static let postUIPostImageCardHeight: CGFloat = 70
    static let postUIGroupCardHeight: CGFloat = 72
    static let postUIGroupPostCardHeight: CGFloat = 85
    static let postUINewsCardHeight: CGFloat = 88
    static let postUIQuestionCardHeight: CGFloat = 88
    static let postUIQuestionAnswerCardHeight: CGFloat = 77

    /// 列表以及详情页
    static let listUINormalTitleFont: CGFloat = 14
    static let listUINormalContentFont: CGFloat = 14
    static let listUINewsTitleFont: CGFloat = 15
    static let listUINewsContentFont: CGFloat = 15
    static let listUIPostWordCardHeight: CGFloat = 64
    static let listUIPostVideoCardHeight: CGFloat = 45
    static let listUIPostImageCardHeight: CGFloat = 45
    static let listUIGroupCardHeight: CGFloat = 80
    static let listUIGroupPostImageHeight: CGFloat = 220
    static let listUINewsCardHeight: CGFloat = 88
    static let listUIQuestionCardHeight: CGFloat = 75
    static let listUIQuestionAnswerCardHeight: CGFloat = 75
    static let listUIDeleteCardHeight: CGFloat = 40
}

class TSRepostView: UIView {
    /// 卡片显示的位置类型
    var cardShowType: TSRepostViewType = .listView
    /// 图片
    private var coverImageView: UIImageView!
    /// 特殊标示,比如视频
    private var iconImageView: UIImageView!
    /// 标题,第一行文字就是标题，如果只有一行，那么它就是内容
    private var titleLab: UILabel!
    /// 内容label
    /// 不要在外部赋值，允许访问该label的目的是允许处理Handel
    var contentLab: ActiveLabel!
    /// 点击了分享卡片
    var didTapCardBlock: (() -> Void)?
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func getSuperViewHeight(model: TSRepostModel, superviewWidth: CGFloat) -> CGFloat {
        var superViewHeight: CGFloat = 0
        if self.cardShowType == .listView {
            switch model.type {
            case .postWord:
                superViewHeight = TSRepostViewUX.listUIPostWordCardHeight
            case .postImage:
                superViewHeight = TSRepostViewUX.listUIPostImageCardHeight
            case .postVideo:
                superViewHeight = TSRepostViewUX.listUIPostVideoCardHeight
            case .group:
                superViewHeight = TSRepostViewUX.listUIGroupCardHeight + 30
            case .groupPost:
                // 图片固定220pt搞定，需要加上10pt + 一行title 17pt + 18 pt + 两行正文 34pt + 10pt
                var contentHeight: CGFloat = 0
                var spHeight: CGFloat = 0
                var imageHeight: CGFloat = 0
                if let coverImage = model.coverImage, coverImage.count > 0 {
                    imageHeight = TSRepostViewUX.listUIGroupPostImageHeight
                }
                if let content = model.content, content.count > 0 {
                    contentHeight = content.size(maxSize: CGSize(width: superviewWidth - 16 * 2, height: 34), font: UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)).height
                    spHeight = 10 + 17 + 18 + (imageHeight > 0 ? 10 : 0)
                } else {
                    spHeight = 10 + 17 + (imageHeight > 0 ? 10 : 0)
                }
                superViewHeight = imageHeight + spHeight + contentHeight + 15
            case .news:
                superViewHeight = TSRepostViewUX.listUINewsCardHeight
            case .question:
                superViewHeight = TSRepostViewUX.listUIQuestionCardHeight
            case .questionAnswer:
                superViewHeight = TSRepostViewUX.listUIQuestionAnswerCardHeight
            case .delete:
                superViewHeight = TSRepostViewUX.listUIDeleteCardHeight
            }
        }
        return superViewHeight
    }
    func creatUI() {
        /// 现在内容label和卡片点击冲突，暂保留卡片点击
        let control = UIControl(frame: self.bounds)
        addSubview(control)
        control.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.top.equalToSuperview()
        }
        let tapReg = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
        control.addGestureRecognizer(tapReg)
        backgroundColor = TSColor.small.repostBackground
        coverImageView = UIImageView()
        coverImageView.backgroundColor = TSColor.normal.imagePlaceholder
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        self.addSubview(coverImageView)
        iconImageView = UIImageView()
        self.addSubview(iconImageView)
        titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalTitleFont)
        titleLab.textColor = TSColor.main.content
        self.addSubview(titleLab)
        contentLab = ActiveLabel()
        contentLab.mentionColor = TSColor.main.theme
        contentLab.URLColor = TSColor.main.theme
        contentLab.URLSelectedColor = TSColor.main.theme
        contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)
        contentLab.textColor = TSColor.normal.minor
        contentLab.lineSpacing = 2
        contentLab.lineBreakMode = NSLineBreakMode.byTruncatingTail
        contentLab.textAlignment = .left
        self.addSubview(contentLab)
    }
    func updateUI(model: TSRepostModel) {
        backgroundColor = TSColor.small.repostBackground
        if cardShowType == .postView {
            self.isUserInteractionEnabled = false
            contentLab.enabledTypes = []
        } else {
            self.isUserInteractionEnabled = true
        }
        if model.type == .postWord {
            self.updatePostTextUI(model: model)
        } else if model.type == .postVideo || model.type == .postImage {
            self.updatePostMediaUI(model: model)
        } else if model.type == .group {
            self.updateGroupUI(model: model)
        } else if model.type == .groupPost {
            self.updateGroupPostUI(model: model)
        } else if model.type == .news {
            self.updateNewsUI(model: model)
        } else if model.type == .question {
            self.updateQuestionUI(model: model)
        } else if model.type == .questionAnswer {
            self.updateQuestionAnswerUI(model: model)
        } else if model.type == .delete {
            self.updataDeleteContentUI(model: model)
        }
    }
    // MARK: - 已经删除
    private func updataDeleteContentUI(model: TSRepostModel) {
        self.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(TSRepostViewUX.listUIDeleteCardHeight)
        }
        titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalTitleFont)
        coverImageView.isHidden = true
        iconImageView.isHidden = true
        titleLab.isHidden = false
        contentLab.isHidden = true
        titleLab.numberOfLines = 1
        titleLab.text = "该内容已被删除"
        titleLab.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(11)
            make.trailing.equalToSuperview().offset(-11)
            make.centerY.equalTo((superview?.snp.centerY)!)
        }
    }
    // MARK: - 动态
    private func updatePostTextUI(model: TSRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUIPostWordCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(5)
                /// 设计图只需要30pt，但是这个富文本控件显示两行需要38
                /// 所以需要把整个控件上间距也调小4pt 使整个控件竖直居中
                make.height.equalTo(38)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TSRepostViewUX.listUIPostWordCardHeight)
            }
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = true
            contentLab.isHidden = false
            contentLab.numberOfLines = 2
            var showStr = model.title! + "："
            if let content = model.content {
                showStr = showStr + content
            } else {
                showStr = showStr + " "
            }
            // 设置名字是黑色
            contentLab.text = showStr
            contentLab.fixAddAttributes([NSForegroundColorAttributeName as NSString: TSColor.main.content], range: NSRange(location: 0, length: model.title!.count + 1))
            contentLab.attributedText = showStr.attributonString().setTextFont(TSRepostViewUX.listUINormalContentFont).setlineSpacing(6)

            let attribute = [NSFontAttributeName: UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)]
            let arr: NSArray = NSArray(array: LabelLineText.getSeparatedLines(fromLabelAddAttribute: contentLab.attributedText, frame: contentLab.frame, attribute: attribute))
            let rangeArr: NSArray = NSArray(array: LabelLineText.getSeparatedLinesRange(fromLabelAddAttribute: contentLab.attributedText, frame: contentLab.frame, attribute: attribute))
            var sixLineText: NSString = ""
            var sixRange: NSRange?
            let sixReplaceRange: NSRange?
            var replaceLocation: NSInteger = 0
            let replaceText: String = "阅读全文  "
            let replaceAtttribute: NSMutableAttributedString = NSMutableAttributedString(string: replaceText)
            let replacefirstAtttribute: NSMutableAttributedString = NSMutableAttributedString(string: "...")
            replaceAtttribute.addAttributes(attribute, range: NSRange(location: 0, length: replaceAtttribute.length))
            if arr.count > 2 {
                sixLineText = NSString(string: "\(arr[1] )")
                let modelSix: rangeModel = rangeArr[1] as! rangeModel
                for (index, _) in rangeArr.enumerated() {
                    if index > 0 {
                        break
                    }
                    let model: rangeModel = rangeArr[index] as! rangeModel
                    replaceLocation = replaceLocation + model.locations
                }

                // 计算出最合适的 range 范围来放置 "阅读全文  " ，让 UI 看起来就是刚好拼接在第六行最后面
                sixReplaceRange = NSRange(location: replaceLocation + modelSix.locations - replaceText.count, length: replaceText.count)
                sixRange = NSRange(location: replaceLocation, length: modelSix.locations)
                let mutableReplace: NSMutableAttributedString = NSMutableAttributedString(attributedString: (contentLab.attributedText?.attributedSubstring(from: sixRange!))!)

                /// 这里要处理 第六行是换行的空白 或者 第六行未填满就换行 的情况
                var lastRange: NSRange?
                if modelSix.locations == 1 {
                    /// 换行直接追加
                    lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - 1)
                } else {
                    /// 如果第六行最后一个字符是 \n 换行符的话，需要将换行符扔掉，再 追加 “查看更多”字样
                    let mutablepassLastString: NSMutableAttributedString = NSMutableAttributedString(attributedString: mutableReplace.attributedSubstring(from: NSRange(location: modelSix.locations - 1, length: 1)))
                    var originI: Int = 0
                    if mutablepassLastString.string == "\n" {
                        originI = 1
                    }
                    for i in originI..<modelSix.locations - 1 {
                        /// 获取每一次替换后的属性文本
                        let mutablepass: NSMutableAttributedString = NSMutableAttributedString(attributedString: mutableReplace.attributedSubstring(from: NSRange(location: 0, length: modelSix.locations - i)))
                        mutablepass.append(replaceAtttribute)
                        let mutablePassWidth = self.WidthOfAttributeString(contentHeight: 20, attributeString: mutablepass, font: UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont))
                        /// 判断当前系统是不是 11.0 及以后的 是就不处理，11.0 以前要再细判断(有没有空格，有的情况下再判断宽度对比小的话要多留两个汉字距离来追加 阅读全文 字样)
                        if #available(iOS 11.0, *) {
                            if mutablePassWidth <= contentLab.width * 2 / 3 {
                                lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - i)
                                break
                            }
                        } else {
                            if mutablePassWidth <= contentLab.width * 2 / 3 {
                                let mutableAll: NSMutableAttributedString = NSMutableAttributedString(attributedString: (contentLab.attributedText?.attributedSubstring(from: NSRange(location: 0, length: replaceLocation + modelSix.locations - i)))!)
                                if mutableAll.string.contains(" ") {
                                    if mutablePassWidth <= (contentLab.width * 2 / 3 - contentLab.font.pointSize * 2.0) {
                                        lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - i)
                                        break
                                    }
                                } else {
                                    lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - i)
                                    break
                                }
                            }
                        }
                    }
                }
                if lastRange == nil {
                    lastRange = NSRange(location: 0, length: replaceLocation)
                }

                let mutable: NSMutableAttributedString = NSMutableAttributedString(attributedString: (contentLab.attributedText?.attributedSubstring(from: lastRange!))!)
                mutable.append(replacefirstAtttribute)
                mutable.append(replaceAtttribute)
                contentLab.attributedText = NSAttributedString(attributedString: mutable)
                contentLab.fixAddAttributes([NSForegroundColorAttributeName as NSString: TSColor.main.content], range: NSRange(location: 0, length: (contentLab.text?.count ?? 0)))
            }

            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                /// 设计图只需要30pt，但是这个富文本控件显示两行需要38
                /// 所以需要把整个控件上间距也调小4pt 使整个控件竖直居中
                make.height.equalTo(38)
            }
        }
    }
    private func updatePostMediaUI(model: TSRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUIPostVideoCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = true
            iconImageView.isHidden = false
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(18)
                make.height.equalTo(18)
            }
            if model.type == .postVideo {
                iconImageView.image = UIImage(named: "ico_video_disabled")
                contentLab.text = "查看视频"
            } else  if model.type == .postImage {
                iconImageView.image = UIImage(named: "ico_pic_disabled")
                contentLab.text = "查看图片"
            }

            iconImageView.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.top.equalTo(titleLab.snp.bottom).offset(10)
                make.width.equalTo(15)
                make.height.equalTo(12)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(iconImageView.snp.trailing).offset(6)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.centerY.equalTo(iconImageView.snp.centerY)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TSRepostViewUX.listUIPostVideoCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)
            contentLab.textColor = TSColor.main.theme
            titleLab.textColor = TSColor.main.content
            coverImageView.isHidden = true
            iconImageView.isHidden = false
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            let showTitle = model.title! + "："
            titleLab.text = showTitle
            let showTitleSize = showTitle.size(maxSize: CGSize(width: ScreenWidth, height: 20), font: titleLab.font!)
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(17)
                make.top.equalToSuperview().offset(12)
                make.height.equalTo(15)
                make.width.equalTo(showTitleSize.width + 2)
            }
            titleLab.sizeToFit()
            if model.type == .postVideo {
                iconImageView.image = UIImage(named: "ico_video_highlight")
                contentLab.text = "查看视频"
            } else  if model.type == .postImage {
                iconImageView.image = UIImage(named: "ico_pic_highlight")
                contentLab.text = "查看图片"
            }
            iconImageView.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.trailing).offset(2)
                make.centerY.equalTo(titleLab.snp.centerY)
                make.width.equalTo(15)
                make.height.equalTo(12)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(iconImageView.snp.trailing).offset(6)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.centerY.equalTo(iconImageView.snp.centerY)
            }
        }
    }
    // MARK: - 圈子
    private func updateGroupUI(model: TSRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUIGroupCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            if let coverImage = model.coverImage {
                coverImageView.setImageWith(URL(string: coverImage), placeholder: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(11)
                    make.top.equalToSuperview().offset(11)
                    make.height.width.equalTo(50)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.width.equalTo(0)
                }
            }

            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(15)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(4)
                make.height.equalTo(38)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(15)
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.listUIGroupCardHeight)
            }
            self.superview?.backgroundColor = UIColor(hex: 0xF7F7F7)
            self.backgroundColor = UIColor(hex: 0xFFFFFF)
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            if let coverImage = model.coverImage {
                coverImageView.setImageWith(URL(string: coverImage), placeholder: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(11)
                    make.top.equalToSuperview().offset(11)
                    make.height.width.equalTo(50)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.width.equalTo(0)
                }
            }
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(15)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(4)
                make.height.equalTo(38)
            }
        }
    }
    // MARK: - 帖子
    private func updateGroupPostUI(model: TSRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUIGroupPostCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            if let coverImage = model.coverImage {
                coverImageView.setImageWith(URL(string: coverImage), placeholder: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.width.equalTo(TSRepostViewUX.postUIGroupPostCardHeight)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.width.equalTo(0)
                }
            }

            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(15)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(9)
                make.height.equalTo(38)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.top.equalToSuperview().offset(10)
                make.height.equalTo(18)
            }
            var contentHeight: CGFloat = 0
            if let content = model.content, content.count > 0 {
                contentLab.text = model.content
                contentHeight = content.size(maxSize: CGSize(width: (superview?.width)! - 16 * 2, height: 34), font: UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)).height
                contentHeight = contentHeight + 4
                contentLab.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(16)
                    make.trailing.equalToSuperview().offset(-16)
                    make.top.equalTo(titleLab.snp.bottom).offset(8)
                    make.height.equalTo(contentHeight)
                }
            } else {
                contentLab.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.top.equalTo(titleLab.snp.bottom)
                    make.height.equalTo(contentHeight)
                }
            }

            if let coverImage = model.coverImage {
                coverImageView.setImageWith(URL(string: coverImage), placeholder: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(23)
                    make.trailing.equalToSuperview().offset(-23)
                    make.top.equalTo(contentLab.snp.bottom).offset(8)
                    make.height.width.equalTo(TSRepostViewUX.listUIGroupPostImageHeight)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.width.equalTo(0)
                }
            }
        }
    }
    // MARK: - 资讯
    private func updateNewsUI(model: TSRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUINewsCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINewsTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINewsContentFont)

            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 2
            contentLab.numberOfLines = 1

            if let coverImage = model.coverImage {
                coverImageView.setImageWith(URL(string: coverImage), placeholder: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.trailing.equalToSuperview().offset(-5)
                    make.top.equalToSuperview().offset(10)
                    make.bottom.equalToSuperview().offset(-10)
                    make.width.equalTo(95)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.trailing.equalToSuperview().offset(0)
                    make.height.width.equalTo(0)
                }
            }

            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalTo(coverImageView.snp.leading).offset(-23)
                make.top.equalToSuperview().offset(13)
                make.height.equalTo(35)
            }

            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalTo(titleLab.snp.trailing)
                make.top.equalTo(titleLab.snp.bottom).offset(8)
                make.height.equalTo(15)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TSRepostViewUX.listUINewsCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINewsTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINewsContentFont)
            titleLab.textColor = TSColor.main.content
            contentLab.textColor = TSColor.normal.minor
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 2
            contentLab.numberOfLines = 1
            if let coverImage = model.coverImage {
                coverImageView.setImageWith(URL(string: coverImage), placeholder: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.trailing.equalToSuperview().offset(-5)
                    make.top.equalToSuperview().offset(10)
                    make.bottom.equalToSuperview().offset(-10)
                    make.width.equalTo(95)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.trailing.equalToSuperview().offset(0)
                    make.height.width.equalTo(0)
                }
            }

            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalTo(coverImageView.snp.leading).offset(-23)
                make.top.equalToSuperview().offset(8)
                make.height.equalTo(40)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalTo(titleLab.snp.trailing)
                make.top.equalTo(titleLab.snp.bottom).offset(8)
                make.height.equalTo(15)
            }
        }
    }
    // MARK: - 问题
    private func updateQuestionUI(model: TSRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUIQuestionCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 2
            contentLab.numberOfLines = 1
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(40)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(5)
                /// 设计图只需要30pt，但是这个富文本控件显示两行需要38
                /// 所以需要把整个控件上间距也调小4pt 使整个控件竖直居中
//                make.height.equalTo(18)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TSRepostViewUX.listUIQuestionCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINewsTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINewsContentFont)
            titleLab.textColor = TSColor.main.content
            contentLab.textColor = TSColor.normal.minor
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 2
            contentLab.numberOfLines = 1
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(8)
                make.height.equalTo(36)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.top.equalTo(titleLab.snp.bottom).offset(8)
                make.height.equalTo(18)
            }
        }
    }
    // MARK: - 回答
    private func updateQuestionAnswerUI(model: TSRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUIQuestionAnswerCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(8)
                make.height.equalTo(15)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(8)
                make.height.equalTo(40)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TSRepostViewUX.postUIQuestionAnswerCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)
            titleLab.textColor = TSColor.main.content
            contentLab.textColor = TSColor.normal.minor
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(5)
                /// 设计图只需要30pt，但是这个富文本控件显示两行需要38
                /// 所以需要把整个控件上间距也调小4pt 使整个控件竖直居中
                make.height.equalTo(38)
            }
        }
    }
    /// 点击了卡片
    func didTapCard() {
        if let tapBlock = didTapCardBlock {
            tapBlock()
        }
    }
    /// 这个地方需要处理从ActiveLabel穿透过来的点击事件，不然该事件会被tableview处理，导致cell被点击
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let tapBlock = didTapCardBlock {
            tapBlock()
        }
    }
    func WidthOfAttributeString(contentHeight: CGFloat, attributeString: NSAttributedString, font: UIFont) -> CGFloat {
        let attributes = [NSFontAttributeName: font]
        let att: NSString = NSString(string: attributeString.string)
        let rectToFit1 = att.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: contentHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        if attributeString.length == 0 {
            return 0
        }
        return rectToFit1.size.width
    }
}
