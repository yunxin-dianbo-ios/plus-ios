//
//  TSMomentDetailHeaderView.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态详情展示页面 (顶部视图)

import UIKit
import TYAttributedLabel
import ActiveLabel

protocol TSMomentDetailHeaderViewDelegate: class {
    /// 点击了图片
    func headerView(_ headerView: TSMomentDetailHeaderView, didSelectedImagesAt index: Int)
    func headerView(_ headerView: TSMomentDetailHeaderView, didSelectedDiggView: TSMomentDetailDiggView)
    /// 点击了打赏按钮
    func reward()
    // 点击了打赏用户列表
    func tapUser()
}

class TSMomentDetailHeaderView: UIView, TSMomentDetailDiggViewDelegate, TSDetailRewardListViewDelegate {
    /// 图片按钮 tag
    let tagForImageButton = 200
    /// 内容
    let labelForContent = ActiveLabel()
    /// 话题
    let topicsView = UIView()
    /// 时间和浏览量
    let labelForSubInfo = TSLabel()
    /// 点赞栏
    var diggView: TSMomentDetailDiggView?
    /// 第一站图
    var firstImage: TSPreviewButton!

    /// 评论视图
    let commentView = UIView()
    /// 评论栏
    let commentLabel = TSLabel()
    /// 装饰线条
    let blueLine = UIView()
    /// 评论数量和点赞数量之间的分割线
    var separateLineView: UIView?
    /// 播放标识
    var playBtn = UIButton(type: .custom)
    // 注：打赏这里有修改，将下面2个控件的weak属性给去掉了。解决了页面崩溃的bug，但导致打赏位置视图空白。
    /// 打赏按钮
    weak var rewardBtn: TSRewardButton!
    /// 打赏用户列表
    weak var rewardListView: TSDetailRewardListView!
    /// 转发
    var repostView: TSRepostView?
    var userListDataSource: [TSNewsRewardModel]? {
        didSet {
            if userListDataSource == nil {
                return
            }
            if TSAppConfig.share.localInfo.isOpenReward == true && TSAppConfig.share.localInfo.isFeedReward ==
                    true {
                self.rewardListView.userListDataSource = userListDataSource
            }
        }
    }
    var rewardCount: TSRewardObject? {
        didSet {
            guard let rewardCount = rewardCount else {
                return
            }
            if TSAppConfig.share.localInfo.isOpenReward == true && TSAppConfig.share.localInfo.isFeedReward ==
                    true {
                let rewardModel = TSNewsRewardCountModel()
                rewardModel.amount = rewardCount.amount
                rewardModel.count = rewardCount.count
                self.rewardListView.rewardModel = rewardModel
            }
        }
    }

    /// 数据模型
    var object: TSMomentListObject

    var topicModes: [TopicListModel]?
    /// 代理
    weak var delegate: TSMomentDetailHeaderViewDelegate?

    // MARK: - Lifecycle
    init(_ object: TSMomentListObject) {
        self.object = object
        super.init(frame: .zero)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        self.object = TSMomentListObject()
        super.init(coder: aDecoder)
    }

    // MARK: Custom user interface
    func setUI() {
        backgroundColor = UIColor.white
        let momentData = object
        let screentWidth = UIScreen.main.bounds.width
        let width = UIScreen.main.bounds.width - 20
        // 模块间隔
        let spacing: CGFloat = 20

        // images
        var imagesTopSpacing: CGFloat = 0
        let images = momentData.pictures.filter { (object) -> Bool in
            return object.width > 0 && object.height > 0
        }
        for index in 0..<images.count {
            let button = TSPreviewButton(type: .custom)
            button.tag = tagForImageButton + index
            button.addTarget(self, action: #selector(imagesButtonTaped(_:)), for: .touchUpInside)

            let image = images[index]
            var height = screentWidth / image.width * image.height
            if momentData.videoURL != nil {
                // 视频动态的显示规则:
                // 宽:高 > 1 -> 宽度按屏幕宽度,按照原始比例显示
                // 宽:高 <= 1 -> 宽度按屏幕宽度,正方形显示
                var playerHeight = screentWidth / image.width * image.height
                if playerHeight > screentWidth {
                    playerHeight = screentWidth
                }
                height = playerHeight
            }
            button.frame = CGRect(x: 0, y: imagesTopSpacing, width: screentWidth, height: height)
            button.imageObject = image
            // 更新 imagesTopSpacing
            imagesTopSpacing = imagesTopSpacing + height + 5
            addSubview(button)
            if momentData.videoURL != nil {
                firstImage = button
                // 视频动态的显示规则:
                // 宽:高 > 1 -> 宽度按屏幕宽度,按照原始比例显示
                // 宽:高 <= 1 -> 宽度按屏幕宽度,正方形显示
                var playerHeight = screentWidth / image.width * image.height
                if playerHeight > screentWidth {
                    playerHeight = screentWidth
                }
                button.frame = CGRect(x: 0, y: 0, width: screentWidth, height: playerHeight)
                playBtn.frame = CGRect(x: 20, y: height - 20 - 40, width: 40, height: 40)
                playBtn.center = button.center
                playBtn.setImage(UIImage(named: "ico_video_play_list"), for: .normal)
                playBtn.isUserInteractionEnabled = false
                button.addSubview(playBtn)
            }
            if image.mimeType == "image/gif" {
                let iconView = UIImageView(image: UIImage(named: "pic_gif"))
                iconView.sizeToFit()
                let iconX = screentWidth - iconView.width
                let iconY = height - iconView.height
                iconView.frame = CGRect(origin: CGPoint(x: iconX, y: iconY), size: iconView.size)
                button.addSubview(iconView)
            }
        }

        // content
        let contentTopSpacing = imagesTopSpacing + spacing
        labelForContent.mentionColor = TSColor.main.theme
        labelForContent.URLColor = TSColor.main.theme
        labelForContent.URLSelectedColor = TSColor.main.theme
        labelForContent.numberOfLines = 0
        labelForContent.lineSpacing = 6
        labelForContent.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        labelForContent.textColor = TSColor.normal.content
        labelForContent.lineBreakMode = .byWordWrapping
        // 不能简单的用可编辑属性文字去初始化，因为还需要给属性文字添加 attribute限制 （NSMutableAttributedString(string: momentData.content)）
        labelForContent.attributedText = momentData.content.attributonString().setTextFont(15).setlineSpacing(6)
        labelForContent.frame = CGRect(origin: CGPoint(x: 10, y: contentTopSpacing), size: CGSize(width: width, height: 20))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 3
        paragraphStyle.alignment = .left
        paragraphStyle.headIndent = 0.000_1
        paragraphStyle.tailIndent = -0.000_1
        let attribute = [NSFontAttributeName: labelForContent.font, NSParagraphStyleAttributeName: paragraphStyle.copy(), NSStrokeColorAttributeName: TSColor.normal.content]

        /// 先计算出有多少行 在根据有多少行去拿总高度 这样比较稳妥一点
        let arr: NSArray = NSArray(array: LabelLineText.getSeparatedLines(fromLabelAddAttribute: labelForContent.attributedText, frame: labelForContent.frame, attribute: attribute))
        let labelMaxHeight = TSUtil.heightOfLines(line: arr.count, font: labelForContent.font)

        labelForContent.frame = CGRect(origin: CGPoint(x: 10, y: contentTopSpacing), size: CGSize(width: width, height: labelMaxHeight))
//        labelForContent.sizeToFit()

        labelForContent.handleURLTap { [weak self] (url) in
            if let parentVC = self?.parentViewController {
                TSUtil.pushURLDetail(url: url, currentVC: parentVC)
            }
        }

        labelForContent.handleMentionTap { (name) in
            /// 获取到的是name+一个看不见的分隔符号，所以需要把尾部的分隔符号移除
            let uname = name.substring(to: name.index(name.startIndex, offsetBy: name.count - 1))
            TSUtil.pushUserHomeName(name: uname)
        }
        /// 如果有转发的内容，转发的卡片在文本下边
        let repostViewBgView = UIView()
        if let repostModel = object.repostModel {
            repostViewBgView.frame = CGRect(x: 0, y: labelForContent.frame.maxY + 12, width: UIScreen.main.bounds.width, height: 0)
            addSubview(repostViewBgView)
            repostView = TSRepostView()
            repostView?.cardShowType = .listView
            repostModel.updataModelType()
            repostViewBgView.height = (repostView?.getSuperViewHeight(model: repostModel, superviewWidth: repostViewBgView.width))!
            repostViewBgView.addSubview(repostView!)
            repostView?.updateUI(model: repostModel)
            repostView?.didTapCardBlock = { _ in
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
                    /// 直接进入帖子详情页面
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
            repostView?.contentLab.handleURLTap { [weak self] (url) in
                if let parentVC = self?.parentViewController {
                    TSUtil.pushURLDetail(url: url, currentVC: parentVC)
                }
            }
            // 点击at某人
            repostView?.contentLab.handleMentionTap { (name) in
                /// 获取到的是name+一个看不见的分隔符号，所以需要把尾部的分隔符号移除
                let uname = name.substring(to: name.index(name.startIndex, offsetBy: name.count - 1))
                TSUtil.pushUserHomeName(name: uname)
            }
        }
        // 话题板块儿
        var topicSpace: CGFloat = 0
        if repostView != nil {
            topicSpace = repostViewBgView.frame.maxY + spacing
        } else {
            if labelForContent.text != "" {
                topicSpace = labelForContent.frame.maxY + spacing
            } else {
                topicSpace = imagesTopSpacing + spacing
            }
        }

        topicsView.frame = CGRect(x: 10, y: topicSpace, width: screentWidth - 20, height: 1)
        var modelArray: [TopicListModel] = []
        for item in momentData.topics {
            let modelTopic = TopicListModel(object: item)
            modelArray.append(modelTopic)
        }
        self.setTopicsUI(datas: modelArray, originYY: topicSpace)

        // 时间和浏览量
        var subInfoTopSpacing: CGFloat = 0
        subInfoTopSpacing = topicsView.frame.maxY
//        if labelForContent.text != "" {
//            subInfoTopSpacing = labelForContent.frame.maxY + spacing
//        } else {
//            subInfoTopSpacing = imagesTopSpacing + spacing
//        }

        labelForSubInfo.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        labelForSubInfo.textColor = TSColor.normal.disabled
        let timeString = TSDate().dateString(.detail, nsDate: momentData.create)
        labelForSubInfo.text = "发布于\(timeString)\n" + TSAppConfig.share.pageViewsString(number: momentData.view) + "显示_人浏览".localized
        labelForSubInfo.textAlignment = .right
        labelForSubInfo.numberOfLines = 2
        labelForSubInfo.sizeToFit()
        labelForSubInfo.frame = CGRect(x: screentWidth - 10 - labelForSubInfo.frame.width, y: subInfoTopSpacing, width: labelForSubInfo.frame.width, height: labelForSubInfo.frame.height)

        // 点赞栏
        diggView = TSMomentDetailDiggView(object)
        diggView?.delegate = self
        diggView?.frame = CGRect(x: 10, y: labelForSubInfo.frame.minY, width: diggView!.frame.width, height: diggView!.frame.height)

        // 分割线
        separateLineView = UIView(frame: CGRect(x: 0, y: labelForSubInfo.frame.maxY + 25, width: screentWidth, height: 5))
        separateLineView?.backgroundColor = TSColor.inconspicuous.background

        // 评论栏
        commentLabel.textColor = TSColor.normal.content
        commentLabel.font = UIFont.systemFont(ofSize: TSFont.SubText.subContent.rawValue)

        // 评论视图
        // 底部分割线
        let bottomline = UIView(frame: CGRect(x: 0, y: 39, width: screentWidth, height: 1))
        bottomline.backgroundColor = TSColor.inconspicuous.disabled
        // 装饰线条
        blueLine.backgroundColor = TSColor.main.theme
        commentView.addSubview(bottomline)
        commentView.addSubview(blueLine)
        commentView.frame = CGRect(x: 0, y: (separateLineView?.frame.maxY)!, width: screentWidth, height: 40)

        addSubview(labelForContent)
        addSubview(topicsView)
        addSubview(diggView!)
        addSubview(labelForSubInfo)
        addSubview(separateLineView!)

        // 判断是否开启了打赏功能
        if TSAppConfig.share.localInfo.isOpenReward == true && TSAppConfig.share.localInfo.isFeedReward == true {
            // 添加打赏相关视图
            let rewardBtn = TSRewardButton(frame: CGRect.zero)
            rewardBtn.setTitle("打赏", for: .normal)
            rewardBtn.addTarget(self, action: #selector(reward), for: .touchUpInside)
            self.rewardBtn = rewardBtn

            let rewardListView = TSDetailRewardListView()
            rewardListView.backgroundColor = TSColor.main.white
            rewardListView.delegate = self
            self.rewardListView = rewardListView

            rewardBtn.frame = CGRect(x: self.frame.width / 2 - 40, y: self.labelForSubInfo.frame.maxY + 20, width: 80, height: 30)
            rewardListView.frame = CGRect(x: 0, y: rewardBtn.frame.maxY, width: self.frame.width, height: 74)
            separateLineView?.frame = CGRect(x: 0, y:rewardListView.frame.maxY, width: screentWidth, height: 5)
            commentView.frame = CGRect(x: 0, y: separateLineView!.frame.maxY, width: screentWidth, height: 40)
            frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height + 74 + 30)

            addSubview(rewardListView)
            addSubview(rewardBtn)
        }

        addAdverView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if TSAppConfig.share.localInfo.isOpenReward == true && TSAppConfig.share.localInfo.isFeedReward == true {
            rewardBtn.frame = CGRect(x: self.frame.width / 2 - 40, y: self.labelForSubInfo.frame.maxY + 20, width: 80, height: 30)
            rewardListView.frame = CGRect(x: 0, y: rewardBtn.frame.maxY, width: self.frame.width, height: 74)
            separateLineView?.frame.origin.y = rewardListView.frame.maxY
        }
    }

    // MARK: - Button click
    // 点击了打赏按钮
    func reward() {
        self.delegate?.reward()
    }

    /// 点击了图片
    func imagesButtonTaped(_ sender: TSButton) {
        let index = sender.tag - tagForImageButton
        if let delegate = delegate {
            delegate.headerView(self, didSelectedImagesAt: index)
        }
    }

    // MARK: - Delegate
    // MARK: TSDetailRewardListViewDelegate
    // 点击了打赏用户列表
    func tapUser() {
        self.delegate?.tapUser()
    }

    // MARK: TSMomentDetailDiggViewDelegate
    func diggViewTaped(_ diggView: TSMomentDetailDiggView) {
        if let delegate = delegate {
            delegate.headerView(self, didSelectedDiggView: diggView)
        }
    }

    // MARK: - Public

    /// 刷新图片
    func uploadImage(at index: Int) {
        guard let button = viewWithTag(tagForImageButton + index) as? TSPreviewButton else {
            return
        }
        let imageObject = object.pictures[index]
        button.imageObject = imageObject
    }

    /// 广告视图
    var advertView: TSAdvertNormal?
    /// 增加广告视图
    public func addAdverView() {
        // 1.获取详情页广告数据
        var adverts = TSDatabaseManager().advert.getObjects(type: .feedDetail)
        if adverts.isEmpty {
            return // 没有广告，则不添加广告视图
        }
        // 2.详情页的广告数量不能超过 3 个
        let maxCount = 3
        if adverts.count > maxCount {
            adverts = Array(adverts[0..<maxCount])
        }

        let advertContentView = UIView()
        // 3.设置广告视图
        advertView = TSAdvertNormal(itemCount: adverts.count)
        advertView?.set(models: adverts.map { TSAdvertViewModel(object: $0) })
        advertView?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: advertView!.frame.size)
        advertContentView.addSubview(advertView!)

        let advertLine2 = UIView(frame: CGRect(x: 0, y: advertView!.frame.maxY, width: UIScreen.main.bounds.width, height: 5))
        advertLine2.backgroundColor = TSColor.inconspicuous.background
        advertContentView.addSubview(advertLine2)

        advertContentView.frame = CGRect(x: 0, y: separateLineView!.frame.maxY, width: UIScreen.main.bounds.width, height: advertView!.frame.size.height + 5)
        // 4.更新
        if advertContentView.superview == nil {
            commentView.frame = CGRect(x: 0, y: advertContentView.frame.maxY, width: commentView.frame.width, height: commentView.frame.height)
            frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height + advertContentView.frame.size.height)
            addSubview(advertContentView)
        }
    }

    /// 设置评论人数显示
    ///
    /// - Parameter number: 评论人数，为 nil 则会移除评论视图
    func setCommentLabel(_ number: Int?) {
        let isHaveNumber: Bool
        if let number = number, number > 0 {
            isHaveNumber = true
        } else {
            isHaveNumber = false
        }
        let isHaveAdvert: Bool = !TSDatabaseManager().advert.getObjects(type: .feedDetail).isEmpty
        if isHaveNumber || isHaveAdvert {
            separateLineView?.isHidden = false
        } else {
            separateLineView?.isHidden = true
        }

        if TSDatabaseManager().advert.getObjects(type: .feedDetail).isEmpty {

        }
        separateLineView?.isHidden = false
        if let number = number, number > 0 {
            commentLabel.text = "\(number)条评论"
            commentLabel.sizeToFit()
            let commentSize = (commentLabel.text?.sizeOfString(usingFont: commentLabel.font))!
            let screenWidth = UIScreen.main.bounds.width
            blueLine.frame = CGRect(x: 10, y: 38, width: commentSize.width + 10, height: 2)
            commentLabel.frame = CGRect(x: 15, y: 0, width: commentSize.width, height: 40)
            if commentLabel.superview == nil {
                addSubview(commentView)
                commentView.addSubview(commentLabel)
            }
            frame = CGRect(x: 0, y: 0, width: screenWidth, height: commentView.frame.maxY)
        } else {
            if commentLabel.superview != nil {
                commentLabel.removeFromSuperview()
                commentView.removeFromSuperview()
            }
            frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: commentView.frame.maxY - 40)
        }
    }

    /// 加载点赞头像的数据
    func getDiggData(complete: @escaping (_ isSuccess: Bool, _ momentIsDeleted: Bool) -> Void) {
        diggView?.getDiggData(complete: complete)
    }

    /// 获取图片在屏幕上的 frame
    func getImagesFrame() -> [CGRect] {
        var imagesFrame: [CGRect] = []
        for index in 0..<object.pictures.count {
            let button = (viewWithTag(tagForImageButton + index) as? UIButton)!
            let windowPoint = button.convert(button.bounds.origin, to: nil)
            let buttonScreenRect = CGRect(x: windowPoint.x, y: windowPoint.y, width: button.frame.width, height: button.frame.height)
            imagesFrame.append(buttonScreenRect)
        }
        return imagesFrame
    }

    /// 获取所有图片
    func getImages() -> [UIImage?] {
        var images: [UIImage?] = []
        for index in 0..<object.pictures.count {
            let button = viewWithTag(tagForImageButton + index) as? UIButton
            if let button = button {
                let image = button.image(for: .normal)
                images.append(image)
            }
        }
        return images
    }

    /// 刷新点赞头像
    func updateDiggIcon() {
        if let diggView = diggView {
            diggView.updateDiggView()
        }
    }

    /// 布局话题板块儿
    func setTopicsUI(datas: [TopicListModel], originYY: CGFloat) {
        self.topicModes = datas
        topicsView.removeAllSubViews()
        var XX: CGFloat = 0
        var YY: CGFloat = 0
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
                bgView.backgroundColor = UIColor(hex: 0x8fd1e8)
                bgView.alpha = 0.12
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
                    tagBgViewHeight = tagLabel.bottom + 20
                }
            }
        }
        topicsView.frame = CGRect(x: 10, y: originYY, width: maxWidth, height: tagBgViewHeight)
    }
    // MARK: - 点击话题板块儿的某个话题标签 跳转到话题详情页
    func jumpToTopicDetailVC(sender: UIButton) {
        guard let topicModes = topicModes else {
            return
        }
        let modelTopic = topicModes[sender.tag - 666]
        let topicVC = TopicPostListVC(groupId:  modelTopic.topicId)
        parentViewController?.navigationController?.pushViewController(topicVC, animated: true)
    }

}
