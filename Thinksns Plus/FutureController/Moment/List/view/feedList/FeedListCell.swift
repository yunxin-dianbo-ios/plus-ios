//
//  MomentListBasicCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/10/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表 cell

import UIKit
import ActiveLabel

/// 动态列表 cell 代理
@objc protocol FeedListCellDelegate: class {

    /// 点击了查看更多按钮
    func feedCell(_ cell: FeedListCell, at index: Int)
    /// 点击了图片
    func feedCell(_ cell: FeedListCell, didSelectedPictures pictureView: PicturesTrellisView, at index: Int)
    /// 点击了图片上的数量蒙层按钮
    func feedCell(_ cell: FeedListCell, didSelectedPicturesCountMaskButton pictureView: PicturesTrellisView)
    /// 点击了工具栏
    func feedCell(_ cell: FeedListCell, didSelectedToolbar toolbar: TSToolbarView, at index: Int)
    /// 点击了评论行
    func feedCell(_ cell: FeedListCell, didSelectedComment commentView: FeedCommentListView, at indexPath: IndexPath)
    /// 点击了评论内容中的用户名
    func feedCell(_ cell: FeedListCell, didSelectedComment commentCell: FeedCommentListCell, onUser userId: Int)
    /// 长按了评论行
    func feedCell(_ cell: FeedListCell, didLongPressComment commentView: FeedCommentListView, at indexPath: IndexPath)
    /// 点击了查看全部按钮
    func feedCellDidSelectedSeeAllButton(_ cell: FeedListCell)
    /// 点击了重发按钮
    func feedCellDidSelectedResendButton(_ cell: FeedListCell)
    /// 点击了来自XXX圈子
   @objc optional func feedCellDidTapFromLab(_ cell: FeedListCell)
    /// 点击了话题板块儿的某个话题
    @objc optional func feedCellDidClickTopic(_ cell: FeedListCell, topicId: Int)
}

/// 动态列表 cell
class FeedListCell: UITableViewCell {

    static let identifier = "FeedListCell"

    /// 代理 
    weak var delegate: FeedListCellDelegate?
    /// 姓名 label
    let nameLabel = UILabel()
    /// 文字标题
    let titleLabel = UILabel()
    /// 文字内容 label
    let contentLabel = ActiveLabel()
    /// 图片九宫格
    let picturesView = PicturesTrellisView()
    /// 视频播放容器
    let playerContentView = UIButton(type: .custom)
    /// 文章来源
    let fromLabel = UILabel()
    /// 工具栏分割线
    let toolbarLine = UIView()
    /// 占位图
    var placeholderView = UIView()
    /// 话题板块儿
    var topicsView = UIView()
    /// 工具栏
    let toolbar = TSToolbarView(type: .left)
    /// 广告分割线
    let advertLine = UIView()
    /// 广告标识
    let advertLabel = UILabel()
    /// 广告工具栏按钮
    let advertToolBtn = UIButton(type: .custom)
    /// 评论列表
    let commentView = FeedCommentListView()
    /// 头像
    let avatarView = AvatarView(origin: CGPoint(x: 10, y: 15), type: AvatarType.width38(showBorderLine: false))
    /// 重发按钮
    var resendButton: TSMomentResendButton?
    /// 左方时间按钮
    let leftTimeLabel = UILabel()
    /// 右方时间按钮
    let rightTimeLabel = UILabel()
    /// 动态置顶图片
    let topIcon = UIImageView(image: UIImage(named:"IMG_label_zhiding"))
    /// 帖子置顶标识
    let postTop = UILabel()
    /// 是否需要显示加精的标识
    var isNeedShowPostExcellent = true
    /// 帖子加精标识
    let postExcellent = UILabel()
    /// 底部分割线
    let bottomLine = UIView()
    /// 播放按钮
    let playIcon = UIImageView(image: UIImage(named: "ico_video_play_list"))
    /// 转发
    var repostView = TSRepostView()
    ///
    let repostViewBgView = UIView()

    /// 数据
    internal var model = FeedListCellModel() {
        didSet {
            loadModel()
        }
    }

    // MARK: - 生命周期
    class func cell(for tableView: UITableView, at indexPath: IndexPath) -> FeedListCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! FeedListCell
        return cell
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    /// 设置视图
    internal func setUI() {
        contentView.backgroundColor = UIColor.white
        let toolbarFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 58, height: 45)
        toolbar.set(items: [TSToolbarItemModel(image: "", title: "", index: 0), TSToolbarItemModel(image: "IMG_home_ico_comment_normal", title: "", index: 1), TSToolbarItemModel(image: "IMG_home_ico_eye_normal", title: "", index: 2), TSToolbarItemModel(image: "IMG_home_ico_more", title: "", index: 3)], frame: toolbarFrame)
        toolbar.set(isUserInteractionEnabled: false, at: 2)
        playerContentView.tag = 10_086 ///< 短视频播放器需要使用这个tag,找到这个视图把播放器加载到视图上,该图层放在图片容器最上面，尺寸等于图片容器
        playerContentView.addTarget(self, action: #selector(videoDidClick(_:)), for: .touchUpInside)
        playerContentView.backgroundColor = UIColor.clear
        playIcon.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        advertToolBtn.addTarget(self, action: #selector(didClickAdvertToolBtn(_:)), for: .touchUpInside)
        self.selectionStyle = .none
        //转发
        repostView.cardShowType = .listView
        repostViewBgView.isHidden = true
        repostViewBgView.addSubview(repostView)

        contentView.addSubview(nameLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(picturesView)
        contentView.addSubview(playerContentView)
        contentView.addSubview(fromLabel)
        contentView.addSubview(repostViewBgView)
        contentView.addSubview(topicsView)
        contentView.addSubview(toolbarLine)
        contentView.addSubview(placeholderView)
        contentView.addSubview(toolbar)
        contentView.addSubview(advertLine)
        contentView.addSubview(advertLabel)
        contentView.addSubview(advertToolBtn)
        contentView.addSubview(commentView)
        contentView.addSubview(leftTimeLabel)
        contentView.addSubview(rightTimeLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(topIcon)
        contentView.addSubview(postTop)
        contentView.addSubview(postExcellent)
        contentView.addSubview(bottomLine)
//        contentView.addSubview(resendButton)
    }

    func didClickAdvertToolBtn(_ btn: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didClickAdvertToolBtn"), object: nil, userInfo: ["FeedListCell": self])
    }

    func videoDidClick(_ button: UIButton) {
        delegate?.feedCell(self, didSelectedPictures: picturesView, at: 0)
    }

    internal func loadModel() {
        /*
         此方法中的 1~4 加载顺序不可随意调整；如需调整，重点看一下 1~4 方法中对 topRecord 的更新。
         */

        var topRecord: CGFloat = 19

        // 1.姓名 label
        loadNameLabel(topRecord: &topRecord)

        // 2 标题 label
        loadTitleLabel(topRecord: &topRecord)

        // 3.文字内容 label
        loadContentLabel(topRecord: &topRecord)
        // 3.5 转发的view
        loadRepostView(topRecord: &topRecord)

        // 4.图片九宫格
        loadPicturesTrellis(topRecord: &topRecord)

        // 5.文章来源
        loadFromLabel(topRecord: &topRecord)

        // 6.5 话题视图板块儿
        loadTopicsView(topRecord: &topRecord)

        // 6.头像和左边时间 label
        loadAvatarView(topRecord: &topRecord) // 头像
        loadLeftTimeLabel(topRecord: &topRecord) // 左边时间

        // 增加一个占位显示的图块 文字或者图片下面的留白区域
        loadPlaceholderView(topRecord: &topRecord)

        // 7.工具栏
        loadToolbar(topRecord: &topRecord)

        // 8.加载广告栏
        loadAdvertLabel(topRecord: &topRecord)

        // 9.评论视图
        loadCommentView(topRecord: &topRecord)

        // 10.重发按钮
        loadResendButton(topRecord: &topRecord)

        // 11.cell 底部分割线
        loadBottomLine(topRecord: &topRecord)

        // 12.和 topRecord 不相关的控件
        loadRightTimeLabel() // 右边时间 label
        loadTopIcon() // 动态置顶图标
        loadPostExcellentIcon() // 动态帖子加精图标
        loadPostTopIcon() // 动态帖子置顶图标
        // 更新 model 的 cellHeight
        model.cellHeight = topRecord
    }

    /// 加载姓名 label
    func loadNameLabel(topRecord: inout CGFloat) {
        // 1.如果姓名为空，则不显示姓名 label
        nameLabel.isHidden = model.userName.isEmpty || model.isHiddenName
        guard !model.userName.isEmpty, model.isHiddenName == false else {
            return
        }
        // 2.如果姓名不为空，更新姓名 label 显示设置
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        nameLabel.textColor = UIColor(hex: 0x333333)
        nameLabel.text = model.userName
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(origin: CGPoint(x: 58, y: 19), size:
            CGSize(width: nameLabel.size.width, height: 14))
        // 3.更新 topRecoed
        topRecord = nameLabel.frame.maxY
    }

    /// 加载标题 label
    func loadTitleLabel(topRecord: inout CGFloat) {
        // 1.如果姓名为空，则不显示姓名 label
        titleLabel.isHidden = model.title.isEmpty
        guard !model.title.isEmpty else {
            return
        }
        // 2.如果姓名不为空，更新姓名 label 显示设置
        // 标题设置为中等加粗效果
        titleLabel.font = UIFont(name: "PingFangSC-Medium", size: 16)
        titleLabel.textColor = UIColor(hex: 0x333333)
        titleLabel.numberOfLines = 0
        titleLabel.text = model.title
        let titleWidth = UIScreen.main.bounds.width - 58 - 13
        titleLabel.frame = CGRect(origin: .zero, size: CGSize(width: titleWidth, height: 0))
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(origin: CGPoint(x: 58, y: topRecord + 14), size: titleLabel.size)
        // 3.更新 topRecoed
        topRecord = titleLabel.frame.maxY
    }

    /// 加载内容 label
    internal func loadContentLabel(topRecord: inout CGFloat) {
        // 1.如果 content 为空，则不显示 content label
        contentLabel.isHidden = model.content.isEmpty
        guard !model.content.isEmpty else {
            return
        }
        // 2.如果 content 不为空，更新 content label 的显示设置
        let shouldAddFuzzyString = model.shouldAddFuzzyString // 是否需要显示模糊字体
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.mentionColor = TSColor.main.theme
        contentLabel.URLColor = TSColor.main.theme
        contentLabel.URLSelectedColor = TSColor.main.theme
        contentLabel.textColor = UIColor(hex: 0x666666)
        contentLabel.shouldAddFuzzyString = shouldAddFuzzyString
        contentLabel.numberOfLines = 0
        contentLabel.lineSpacing = 6
        contentLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        contentLabel.textAlignment = .left
        // 设置短链接点击事件
        contentLabel.handleURLTap { [weak self] (url) in
            guard shouldAddFuzzyString == false else {
                return
            }
            if let parentVC = self?.parentViewController {
                TSUtil.pushURLDetail(url: url, currentVC: parentVC)
            }
        }
        contentLabel.handleLookMoreTap { [weak self] (feedid) in
            guard shouldAddFuzzyString == false else {
                return
            }
            self?.delegate?.feedCell(self!, at: 0)
        }
        contentLabel.handleMentionTap { (name) in
            /// 获取到的是name+一个看不见的分隔符号，所以需要把尾部的分隔符号移除
            let uname = name.substring(to: name.index(name.startIndex, offsetBy: name.count - 1))
            TSUtil.pushUserHomeName(name: uname)
        }
        // 设置处理过的文字内容
        contentLabel.attributedText = model.content.attributonString().setTextFont(15).setlineSpacing(6)
        // 计算 frame
        let contentWidth = UIScreen.main.bounds.width - 58 - 13
        contentLabel.frame = CGRect(origin: .zero, size: CGSize(width: contentWidth, height: 0))
        let contentY = topRecord == 20 ? 20 : topRecord + 12
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 3
        paragraphStyle.alignment = .left
        paragraphStyle.headIndent = 0.000_1
        paragraphStyle.tailIndent = -0.000_1
        var labelHeight: CGFloat = 0
        let heightLine = self.heightOfLines(line: 6, font: UIFont.systemFont(ofSize: 15))
        let maxHeight = self.heightOfAttributeString(contentWidth: contentLabel.width, attributeString: contentLabel.attributedText!, font: UIFont.systemFont(ofSize: 15), paragraphstyle: paragraphStyle)
        if heightLine >= maxHeight {
            labelHeight = maxHeight
        } else {
            labelHeight = heightLine
        }
        contentLabel.frame = CGRect(x: 58, y: contentY, width: contentLabel.width, height: labelHeight)

        if !shouldAddFuzzyString {
            let attribute = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSParagraphStyleAttributeName: paragraphStyle.copy(), NSStrokeColorAttributeName: TSColor.main.theme]
            let arr: NSArray = NSArray(array: LabelLineText.getSeparatedLines(fromLabelAddAttribute: contentLabel.attributedText, frame: contentLabel.frame, attribute: attribute))
            let rangeArr: NSArray = NSArray(array: LabelLineText.getSeparatedLinesRange(fromLabelAddAttribute: contentLabel.attributedText, frame: contentLabel.frame, attribute: attribute))
            var sixLineText: NSString = ""
            var sixRange: NSRange?
            let sixReplaceRange: NSRange?
            var replaceLocation: NSInteger = 0
            let replaceText: String = "阅读全文    "
            let replaceAtttribute: NSMutableAttributedString = NSMutableAttributedString(string: replaceText)
            let replacefirstAtttribute: NSMutableAttributedString = NSMutableAttributedString(string: "...")
            replaceAtttribute.addAttributes(attribute, range: NSRange(location: 0, length: replaceAtttribute.length))
            if arr.count > 6 {
                sixLineText = NSString(string: "\(arr[5] )")
                let modelSix: rangeModel = rangeArr[5] as! rangeModel
                for (index, _) in rangeArr.enumerated() {
                    if index > 4 {
                        break
                    }
                    let model: rangeModel = rangeArr[index] as! rangeModel
                    replaceLocation = replaceLocation + model.locations
                }

                // 计算出最合适的 range 范围来放置 "阅读全文  " ，让 UI 看起来就是刚好拼接在第六行最后面
                sixReplaceRange = NSRange(location: replaceLocation + modelSix.locations - replaceText.count, length: replaceText.count)
                sixRange = NSRange(location: replaceLocation, length: modelSix.locations)
                let mutableReplace: NSMutableAttributedString = NSMutableAttributedString(attributedString: (contentLabel.attributedText?.attributedSubstring(from: sixRange!))!)

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
                        let mutablePassWidth = self.WidthOfAttributeString(contentHeight: 20, attributeString: mutablepass, font: UIFont.systemFont(ofSize: 15), paragraphstyle: paragraphStyle)
                        /// 判断当前系统是不是 11.0 及以后的 是就不处理，11.0 以前要再细判断(有没有空格，有的情况下再判断宽度对比小的话要多留两个汉字距离来追加 阅读全文 字样)
                        if #available(iOS 11.0, *) {
                            if mutablePassWidth <= contentLabel.width * 2 / 3 {
                                lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - i)
                                break
                            }
                        } else {
                            if mutablePassWidth <= contentLabel.width * 2 / 3 {
                                let mutableAll: NSMutableAttributedString = NSMutableAttributedString(attributedString: (contentLabel.attributedText?.attributedSubstring(from: NSRange(location: 0, length: replaceLocation + modelSix.locations - i)))!)
                                if mutableAll.string.contains(" ") {
                                    if mutablePassWidth <= (contentLabel.width * 2 / 3 - contentLabel.font.pointSize * 2.0) {
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

                let mutable: NSMutableAttributedString = NSMutableAttributedString(attributedString: (contentLabel.attributedText?.attributedSubstring(from: lastRange!))!)
                mutable.append(replacefirstAtttribute)
                mutable.append(replaceAtttribute)
                contentLabel.attributedText = NSAttributedString(attributedString: mutable)
            }
        }
        // 更新 topRecord
        topRecord = contentLabel.frame.maxY
    }
    /// 转发视图
    internal func loadRepostView(topRecord: inout CGFloat) {
        if model.repostId > 0, let type = model.repostType, type.isEmpty == false, let repostModel = model.repostModel {
            /// 如果有转发的内容，转发的卡片在文本下边
            let contentWidth = UIScreen.main.bounds.width - 58 - 13
            repostViewBgView.isHidden = false
            repostViewBgView.frame = CGRect(x: 58, y: topRecord + 10, width: contentWidth, height: 0)
            repostModel.updataModelType()
            repostViewBgView.height = repostView.getSuperViewHeight(model: repostModel, superviewWidth: repostViewBgView.width)
            repostViewBgView.addSubview(repostView)
            repostView.updateUI(model: repostModel)
            topRecord = repostViewBgView.frame.maxY + 5
            repostView.didTapCardBlock = { _ in
                if repostModel.type == .postWord || repostModel.type == .postVideo || repostModel.type == .postImage {
                    let detailVC = TSCommetDetailTableView(feedId: repostModel.id)
                    self.parentViewController?.navigationController?.pushViewController(detailVC, animated: true)
                } else if repostModel.type == .group {
                    if repostModel.couldShowDetail == false {
                        // 进入预览页面
                        let groupPreviewVC = GroupPreviewVC()
                        groupPreviewVC.groupId = repostModel.id
                        self.parentViewController?.navigationController?.pushViewController(groupPreviewVC, animated: true)
                    } else {
                        let groupVC = GroupDetailVC(groupId: repostModel.id)
                        self.parentViewController?.navigationController?.pushViewController(groupVC, animated: true)
                    }
                } else if repostModel.type == .groupPost {
//                    if repostModel.couldShowDetail == false {
//                        // 进入预览页面
//                        let groupPreviewVC = GroupPreviewVC()
//                        groupPreviewVC.groupId = repostModel.subId
//                        self.parentViewController?.navigationController?.pushViewController(groupPreviewVC, animated: true)
//                    } else {
//                        let postDetailVC = TSPostCommentController(groupId: repostModel.subId, postId: repostModel.id)
//                        self.parentViewController?.navigationController?.pushViewController(postDetailVC, animated: true)
//                    }
                    // 直接进入帖子详情
                    let postDetailVC = TSPostCommentController(groupId: repostModel.subId, postId: repostModel.id)
                    self.parentViewController?.navigationController?.pushViewController(postDetailVC, animated: true)
                } else if repostModel.type == .news {
                    let infoVC = TSNewsCommentController(newsId: repostModel.id)
                    self.parentViewController?.navigationController?.pushViewController(infoVC, animated: true)
                } else if repostModel.type == .question {
                    let questionDetailVC = TSQuoraDetailController()
                    questionDetailVC.questionId = repostModel.id
                    self.parentViewController?.navigationController?.pushViewController(questionDetailVC, animated: true)
                } else if repostModel.type == .questionAnswer {
                    let answerDetailVC = TSAnswerDetailController(answerId: repostModel.id)
                    self.parentViewController?.navigationController?.pushViewController(answerDetailVC, animated: true)
                }
            }
            // 设置短链接点击事件
            repostView.contentLab.handleURLTap { [weak self] (url) in
                if let parentVC = self?.parentViewController {
                    TSUtil.pushURLDetail(url: url, currentVC: parentVC)
                }
            }
            // 点击at某人
            repostView.contentLab.handleMentionTap { (name) in
                /// 获取到的是name+一个看不见的分隔符号，所以需要把尾部的分隔符号移除
                let uname = name.substring(to: name.index(name.startIndex, offsetBy: name.count - 1))
                TSUtil.pushUserHomeName(name: uname)
            }
        } else {
            repostViewBgView.isHidden = true
        }
    }
    /// 加载图片九宫格
    internal func loadPicturesTrellis(topRecord: inout CGFloat) {
        // 1.如果图片为空，不显示图片九宫格
        picturesView.isHidden = model.pictures.isEmpty
        playerContentView.isHidden = picturesView.isHidden
        guard !model.pictures.isEmpty else {
            return
        }
        if model.videoURL.count > 0 || model.localVideoFileURL != nil {
            picturesView.isUseVideoFrameRule = true
            playerContentView.isHidden = false
        } else {
            picturesView.isUseVideoFrameRule = false
            playerContentView.isHidden = true
        }
        // 2.更新图片九宫格的显示设置
        picturesView.delegate = self
        picturesView.models = model.pictures // 内部计算 size
        let pictureY = topRecord == 20 ? 20 : topRecord + 10
        picturesView.frame = CGRect(origin: CGPoint(x: 58, y: pictureY), size: picturesView.size)
        if model.videoURL.count > 0 || model.localVideoFileURL != nil {
            playIcon.isHidden = false
        } else {
            playIcon.isHidden = true
        }
        playIcon.center = CGPoint(x: picturesView.width / 2, y: picturesView.height / 2)
        picturesView.insertSubview(playIcon, at: picturesView.subviews.count)
        if model.isPlaying == false {
            playerContentView.frame = picturesView.frame
        }
        // 3.更新 topRecord
        topRecord = picturesView.frame.maxY
    }

    /// 加载文章来源
    func loadFromLabel(topRecord: inout CGFloat) {
        // 1.如果文章来源为空，不显示来源 label
        fromLabel.isHidden = model.from.isEmpty
        guard !model.from.isEmpty else {
            return
        }
        // 2.更新来源 label 的显示设置
        fromLabel.font = UIFont.systemFont(ofSize: 12)
        let fromString = NSMutableAttributedString.attributeStringWith(strings: ["来自 ", model.from], colors: [UIColor(hex: 0xb2b2b2), TSColor.main.theme], fonts: [12, 12])
        fromLabel.attributedText = fromString
        let fromWidth = UIScreen.main.bounds.width - 58 - 13
        fromLabel.frame = CGRect(x: 58, y: topRecord + 6, width: fromWidth, height: 13)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapFromLab(tap:)))
        fromLabel.addGestureRecognizer(tap)
        fromLabel.isUserInteractionEnabled = true
        // 3.更新 topRecord
        topRecord = fromLabel.frame.maxY
    }

    /// 加载头像
    func loadAvatarView(topRecord: inout CGFloat) {
        // 1.如果头像信息不存在，就不显示头像
        avatarView.isHidden = model.avatarInfo == nil || model.isHiddenAvatar
        guard let avatarInfo = model.avatarInfo, model.isHiddenAvatar == false else {
            return
        }
        // 2.如果头像信息存在，更新头像显示设置
        avatarView.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.sex)
        avatarView.avatarInfo = avatarInfo
        // 3.更新 topRecord
        topRecord = max(avatarView.frame.maxY, topRecord)
    }

    /// 加载左边时间
    func loadLeftTimeLabel(topRecord: inout CGFloat) {
        // 1.如果左边时间数据为空，则不显示左边时间 label
        leftTimeLabel.isHidden = model.leftTime.isEmpty
        guard !model.leftTime.isEmpty else {
            return
        }
        // 2.如果左边时间数据存在，更新左边时间 label 显示设置
        leftTimeLabel.textColor = UIColor(hex: 0x333333)
        leftTimeLabel.numberOfLines = 0
        leftTimeLabel.font = UIFont.systemFont(ofSize: 20)
        leftTimeLabel.frame = CGRect(x: (58 - 20) / 2, y: 15, width: 28, height: 1)
        if model.leftTime.count > 3 {
            // 如果是 “DD\nM月” 格式的文本，处理成富文本显示
            let day = (model.leftTime as NSString).substring(to: 2)
            let month = (model.leftTime as NSString).substring(from: 2)
            let strings = [day, month]
            let colors = [UIColor(hex: 0x333333), UIColor(hex: 0x333333)]
            leftTimeLabel.attributedText = NSMutableAttributedString.attributeStringWith(strings: strings, colors: colors, fonts: [20, 12])
        } else {
            // 如果是 “今\n天” 类型的纯文本，直接显示
            leftTimeLabel.text = model.leftTime
        }
        leftTimeLabel.sizeToFit()
        // 3.更新 topRecord
        topRecord = max(leftTimeLabel.frame.maxY, topRecord)
    }

    func loadPlaceholderView(topRecord: inout CGFloat) {
        placeholderView = UIView(frame: CGRect(x: 0, y: topRecord, width: UIScreen.main.bounds.width, height: 15))
        placeholderView.backgroundColor = UIColor.white
        topRecord = placeholderView.frame.maxY
    }

    func loadTopicsView(topRecord: inout CGFloat) {
        topicsView.isHidden = model.topics.isEmpty
        guard !model.topics.isEmpty else {
            return
        }
        topicsView.frame = CGRect(x: 58, y: topRecord, width: ScreenWidth - 58 - 10, height: 0)
        if model.cellTopicId == 0 {
            self.setTopicUI(datas: model.topics, originYY: topRecord)
        } else {
            for (index, item) in model.topics.enumerated() {
                if item.topicId == model.cellTopicId {
                    model.topics.remove(at: index)
                    break
                }
            }
            guard !model.topics.isEmpty else {
                return
            }
            self.setTopicUI(datas: model.topics, originYY: topRecord)
        }
        topRecord = topicsView.frame.maxY
    }

    /// 加载工具栏
    internal func loadToolbar(topRecord: inout CGFloat) {
        // 1.如果工具栏数据不存在，就不显示工具栏
        toolbarLine.isHidden = model.toolModel == nil
        toolbar.isHidden = model.toolModel == nil
        guard let toolModel = model.toolModel else {
            return
        }
        // 2.如果工具栏存在，刷新工具栏显示设置
        // 设置工具栏分割线
        toolbarLine.backgroundColor = TSColor.inconspicuous.disabled
        toolbarLine.frame = CGRect(x: 0, y: topRecord, width: UIScreen.main.bounds.width, height: 0.7)
        toolbar.backgroundColor = UIColor.white
        toolbar.setImage(toolModel.isDigg ? "IMG_home_ico_good_high" : "IMG_home_ico_good_normal", At: 0)
        toolbar.setTitle(TSAppConfig.share.pageViewsString(number: toolModel.diggCount), At: 0)
        // 更新点赞数量颜色
        toolbar.setTitleColor(toolModel.isDigg ? TSColor.main.warn : TSColor.normal.secondary, At: 0)
        // 设置评论按钮
        toolbar.setTitle(TSAppConfig.share.pageViewsString(number: toolModel.commentCount), At: 1)
        // 设置浏览量按钮
        toolbar.setTitle(TSAppConfig.share.pageViewsString(number: toolModel.viewCount), At: 2)
        toolbar.delegate = self
        // 设置工具栏的 frame
        toolbar.frame.origin = CGPoint(x: 58, y: topRecord + 1)
        // 3.更新 topRecord
        topRecord = toolbar.frame.maxY
    }

    /// 加载广告栏
    func loadAdvertLabel(topRecord: inout CGFloat) {
        // 1.判断一下是要显示广告标识
        let isAdvert = model.id["pageId"] != nil
        advertLine.isHidden = !isAdvert
        advertLabel.isHidden = advertLine.isHidden
        advertToolBtn.isHidden = advertLine.isHidden
        guard isAdvert else {
            return
        }
        // 2.更新广告分割线和广告标识的显示设置
        advertLine.backgroundColor = TSColor.inconspicuous.disabled
        advertLine.frame = CGRect(x: 0, y: topRecord + 9, width: UIScreen.main.bounds.width, height: 0.7)
        advertLabel.text = "广告"
        advertLabel.font = UIFont.systemFont(ofSize: 11)
        advertLabel.textColor = UIColor(hex: 0xb2b2b2)
        advertLabel.layer.borderColor = UIColor(hex: 0xb2b2b2).cgColor
        advertLabel.layer.borderWidth = 0.5
        advertLabel.textAlignment = .center
        advertLabel.sizeToFit()
        advertLabel.frame = CGRect(x: 62, y: topRecord + 9 + (40 - 15) / 2, width: 30, height: 15)
        // 显示工具栏按钮
        advertToolBtn.setImage(UIImage(named: "IMG_home_ico_more"), for: .normal)
        let imageWidth: CGFloat = 16.0
        advertToolBtn.frame = CGRect(x: self.bounds.width - imageWidth - 15, y: topRecord + 9 + (40 - 16) / 2, width: imageWidth, height: imageWidth)
        // 3.更新 topRecord
        topRecord = topRecord + 9 + 39
    }

    /// 加载评论视图
    func loadCommentView(topRecord: inout CGFloat) {
        // 1.如果评论数据为空，就不显示评论视图
        commentView.isHidden = model.comments.isEmpty
        guard !model.comments.isEmpty else {
            return
        }
        // 2.如果评论数据不为空，就更新评论视图显示设置
        commentView.frame = CGRect(origin: CGPoint(x: 0, y: topRecord), size: .zero)
        commentView.commentsCount = model.toolModel?.commentCount ?? 0
        commentView.set(datas: model.comments)
        commentView.delegate = self
        // 3.更新 topRecord
        topRecord = commentView.frame.maxY
    }

    /// 加载重发按钮
    func loadResendButton(topRecord: inout CGFloat) {
        // 1.如果动态发送未失败，就不显示重发按钮
        if resendButton != nil {
            resendButton?.removeFromSuperview()
            resendButton = nil
        }
        guard model.sendStatus == .faild else {
            return
        }
        resendButton = TSMomentResendButton(title: model.sendStatusReason)
        guard let resendButton = resendButton else {
            return
        }
        contentView.addSubview(resendButton)
        // 2.如果动态发送失败，更新重发按钮显示设置
        resendButton.frame.origin = CGPoint(x: 58, y: topRecord)
        resendButton.addTarget(self, action: #selector(resendButtonTaped), for: .touchUpInside)
        // 3.更新 topRecord
        topRecord = resendButton.frame.maxY + 10
    }

    /// 加载底部分割线
    func loadBottomLine(topRecord: inout CGFloat) {
        bottomLine.backgroundColor = TSColor.inconspicuous.background
        bottomLine.frame = CGRect(x: 0, y: topRecord, width: UIScreen.main.bounds.width, height: 10)
        // 更新 topRecord
        topRecord = bottomLine.frame.maxY
    }

    /// 加载右边时间 label
    func loadRightTimeLabel() {
        // 1.如果右边时间数据不存在，则不显示右边时间 label
        rightTimeLabel.isHidden = model.rightTime.isEmpty || model.isHiddenRightTime
        guard !model.rightTime.isEmpty, model.isHiddenRightTime == false else {
            return
        }
        // 2.如果右边时间数据存在，更新右边时间 label 的显示设置
        rightTimeLabel.font = UIFont.systemFont(ofSize: 12)
        rightTimeLabel.textColor = UIColor(hex: 0xcccccc)
        rightTimeLabel.textAlignment = .right
        rightTimeLabel.text = model.rightTime
        rightTimeLabel.sizeToFit()
        // 计算 frame 
        let labelX = UIScreen.main.bounds.width - rightTimeLabel.frame.width - 10
        rightTimeLabel.frame = CGRect(origin: CGPoint(x: labelX, y: 19), size: rightTimeLabel.size)
    }

    /// 加载置顶图标
    func loadTopIcon() {
        // 1.如果不需要显示置顶图标，则不显示置顶标签
        topIcon.isHidden = !model.showTopIcon
        guard model.showTopIcon else {
            return
        }
        // 2.如果需要显示置顶图标，更新指定图标的显示设置
        topIcon.sizeToFit()
        var iconX = UIScreen.main.bounds.width - topIcon.frame.width - 10
        if !model.rightTime.isEmpty {
            iconX = iconX - rightTimeLabel.size.width - 8
        }
        topIcon.frame = CGRect(origin: CGPoint(x: iconX, y: 19), size: topIcon.size)
    }

    /// 加载帖子置顶图标
    func loadPostTopIcon() {
        // 1.如果不需要显示置顶图标，则不显示置顶标签
        postTop.isHidden = !model.showPostTopIcon
        guard model.showPostTopIcon else {
            return
        }
        // 2.如果需要显示置顶图标，更新指定图标的显示设置
        postTop.backgroundColor = UIColor(red: 75.0 / 255.0, green: 184.0 / 255.0, blue: 147.0 / 255.0, alpha: 1.0)
        postTop.textColor = UIColor.white
        postTop.layer.cornerRadius = 2
        postTop.clipsToBounds = true
        postTop.text = "顶"
        postTop.textAlignment = .center
        postTop.font = UIFont.systemFont(ofSize: 11)
        postTop.sizeToFit()

        var iconX = UIScreen.main.bounds.width - postTop.frame.width - 10
        if  !postExcellent.isHidden {
            iconX = iconX - rightTimeLabel.size.width - 15 - postExcellent.size.width - 10
        } else {
            if !model.rightTime.isEmpty {
                iconX = iconX - rightTimeLabel.size.width - 15
            }
        }

        postTop.frame = CGRect(origin: CGPoint(x: iconX, y: 16), size: CGSize(width: postTop.size.width + 5, height: postTop.size.height + 3))
    }

    /// 加载帖子加精图标
    func loadPostExcellentIcon() {
        // 1.如果不需要显示加精图标，则不显示加精标签
        postExcellent.isHidden = !(isNeedShowPostExcellent && model.excellent != nil)
        guard isNeedShowPostExcellent, model.excellent != nil else {
            return
        }
        // 2.如果需要显示加精图标，更新指定图标的显示设置
        postExcellent.backgroundColor = UIColor(red: 247.0 / 255.0, green: 108.0 / 255.0, blue: 105.0 / 255.0, alpha: 1.0)
        postExcellent.textColor = UIColor.white
        postExcellent.layer.cornerRadius = 2
        postExcellent.clipsToBounds = true
        postExcellent.text = "精"
        postExcellent.textAlignment = .center
        postExcellent.font = UIFont.systemFont(ofSize: 11)
        postExcellent.sizeToFit()

        var iconX = UIScreen.main.bounds.width - postExcellent.frame.width - 10
        if !model.rightTime.isEmpty {
            iconX = iconX - rightTimeLabel.size.width - 15
        }
        postExcellent.frame = CGRect(origin: CGPoint(x: iconX, y: 16), size: CGSize(width: postExcellent.size.width + 5, height: postExcellent.size.height + 3))
    }

    /// 话题板块儿 ui
    func setTopicUI(datas: [TopicListModel], originYY: CGFloat) {
        topicsView.removeAllSubViews()
        var XX: CGFloat = 0
        var YY: CGFloat = 15
        let labelHeight: CGFloat = 20
        let inSpace: CGFloat = 8
        let outSpace: CGFloat = 5
        let maxWidth: CGFloat = topicsView.width
        var tagBgViewHeight: CGFloat = 0

        if !datas.isEmpty {
            for (index, item) in datas.enumerated() {
                var labelWidth = item.topicTitle.sizeOfString(usingFont: UIFont.systemFont(ofSize: 10)).width
                labelWidth = labelWidth + inSpace * 2
                if labelWidth > maxWidth {
                    labelWidth = maxWidth
                }
                let tagLabel: UIButton = UIButton(type: .custom)
                let bgView: UIView = UIView()
                tagLabel.frame = CGRect(x: XX, y: YY, width: labelWidth, height: labelHeight)
                XX = tagLabel.right + outSpace
                if tagLabel.right > maxWidth {
                    XX = 0
                    YY = tagLabel.bottom + outSpace
                    tagLabel.frame = CGRect(x: XX, y: YY, width: labelWidth, height: labelHeight)
                    XX = tagLabel.right + outSpace
                }
                bgView.frame = tagLabel.frame
                bgView.backgroundColor = TSColor.main.theme.withAlphaComponent(0.15)
                bgView.layer.cornerRadius = 3
                tagLabel.backgroundColor = UIColor.clear
                tagLabel.setTitleColor(TSColor.main.theme, for: .normal)
                tagLabel.layer.cornerRadius = 3
                tagLabel.setTitle(item.topicTitle, for: .normal)
                tagLabel.titleLabel?.font = UIFont.systemFont(ofSize: 10)
                tagLabel.tag = 666 + index
                tagLabel.addTarget(self, action: #selector(jumpToTopicDetailVC(sender:)), for: UIControlEvents.touchUpInside)
                topicsView.addSubview(bgView)
                topicsView.addSubview(tagLabel)
                if index == (datas.count - 1) {
                    tagBgViewHeight = tagLabel.bottom
                }
            }
        }
        topicsView.frame = CGRect(x: 58, y: originYY, width: maxWidth, height: tagBgViewHeight)
    }

    // MARK: - 用户交互事件

    /// 点击了重发按钮
    func resendButtonTaped() {
        delegate?.feedCellDidSelectedResendButton(self)
    }
    /// 点击了来自Lab
    func didTapFromLab(tap: UITapGestureRecognizer) {
        delegate?.feedCellDidTapFromLab!(self)
    }

    func heightOfLines(line: Int, font: UIFont) -> CGFloat {
        if line <= 0 {
            return 0
        }

        var mutStr = "*"
        for _ in 0..<line - 1 {
            mutStr = mutStr + "\n*"
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 3
        paragraphStyle.headIndent = 0.000_1
        paragraphStyle.tailIndent = -0.000_1
        let attribute = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSParagraphStyleAttributeName: paragraphStyle.copy(), NSStrokeColorAttributeName: UIColor.black]
        let tSize = mutStr.size(attributes: attribute)
        return tSize.height
    }

    func heightOfAttributeString(contentWidth: CGFloat, attributeString: NSAttributedString, font: UIFont, paragraphstyle: NSMutableParagraphStyle) -> CGFloat {
        let attributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphstyle.copy()]
        let att: NSString = NSString(string: attributeString.string)
        let rectToFit1 = att.boundingRect(with: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        if attributeString.length == 0 {
            return 0
        }
        return rectToFit1.size.height
    }

    func WidthOfAttributeString(contentHeight: CGFloat, attributeString: NSAttributedString, font: UIFont, paragraphstyle: NSMutableParagraphStyle) -> CGFloat {
        let attributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphstyle.copy()]
        let att: NSString = NSString(string: attributeString.string)
        let rectToFit1 = att.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: contentHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        if attributeString.length == 0 {
            return 0
        }
        return rectToFit1.size.width
    }

// MARK: - 点击话题板块儿的某个话题标签 跳转到话题详情页
    func jumpToTopicDetailVC(sender: UIButton) {
        if model.topics.isEmpty {
            return
        }
        let modelTopic = model.topics[sender.tag - 666]
        delegate?.feedCellDidClickTopic!(self, topicId: modelTopic.topicId)
    }
}

// MARK: - TSMomentPicturePreviewDelegate: 九宫格图片代理
extension FeedListCell: PicturesTrellisViewDelegate {

    /// 图片点击事件
    func picturesTrellisView(_ view: PicturesTrellisView, didSelectPictureAt index: Int) {
        delegate?.feedCell(self, didSelectedPictures: view, at: index)
    }

    /// 点击了数量蒙层按钮
    func picturesTrellisViewDidSelectedCountMaskButton(_ view: PicturesTrellisView) {
        delegate?.feedCell(self, didSelectedPicturesCountMaskButton: view)
    }
}

// MARK: - TSToolbarViewDelegate: 工具栏代理
extension FeedListCell: TSToolbarViewDelegate {

    /// 工具栏的 item 被点击
    func toolbar(_ toolbar: TSToolbarView, DidSelectedItemAt index: Int) {
        delegate?.feedCell(self, didSelectedToolbar: toolbar, at: index)
    }
}

// MARK: - FeedCommentListViewDelegate: 评论视图代理事件
extension FeedListCell: FeedCommentListViewDelegate {

    /// 长按了评论视图的评论行
    func feedCommentListView(_ view: FeedCommentListView, didLongPressComment data: FeedCommentListCellModel, at indexPath: IndexPath) {
        delegate?.feedCell(self, didLongPressComment: view, at: indexPath)
    }

    /// 点击了查看全部按钮
    func feedCommentListViewDidSelectedSeeAllButton(_ view: FeedCommentListView) {
        delegate?.feedCellDidSelectedSeeAllButton(self)
    }

    /// 点击了评论行
    func feedCommentListView(_ view: FeedCommentListView, didSelectedComment data: FeedCommentListCellModel, at indexPath: IndexPath) {
        delegate?.feedCell(self, didSelectedComment: view, at: indexPath)
    }

    /// 点击了评论内容中的用户名
    func feedCommentListView(_ view: FeedCommentListView, didSelectedComment cell: FeedCommentListCell, onUser userId: Int) {
        delegate?.feedCell(self, didSelectedComment: cell, onUser: userId)
    }
}
