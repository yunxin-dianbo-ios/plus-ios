//
//  TopicListFixedHeaderView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/24.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import YYKit
import TYAttributedLabel
import Kingfisher

protocol TopicListFixedHeaderViewDelegate: class {
    func didClickJumpButton(_ topicListFixedHeaderView: TopicListFixedHeaderView, topicId: Int)
}

class TopicListFixedHeaderView: UIView {

    weak var delegate: TopicListFixedHeaderViewDelegate?
    /// 话题名称
    let nameLabel = UILabel()
    /// 话题创建者
    let ownerLabel = UILabel()
    /// 简介
    let topicIntro = TYAttributedLabel(frame: CGRect(x: 15, y: 0, width: ScreenWidth - 30, height: 1))
    /// 话题参与者
    let topicMenber = UIView()
    /// 白色背景图
    let whiteView = UIView()
    var allHeight: CGFloat = 180

    // 数据
    var model = TopicListControllerModel() {
        didSet {
            loadModel()
        }
    }

    init() {
        super.init(frame: .zero)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    func setUI() {
        backgroundColor = UIColor.clear
        addSubview(whiteView)
        addSubview(nameLabel)
        addSubview(ownerLabel)
        addSubview(topicIntro)
        addSubview(topicMenber)
    }

    func loadModel() {
        var yRecord: CGFloat = 0
        // 2.话题名字
        loadNameLabel(yRecord: &yRecord)
        loadOwnerLabel(yRecord: &yRecord)
        loadIntroLabel(yRecord: &yRecord)
        // 7.话题参与者
        loadTopicMenberView(yRecord: &yRecord)
        // 8.白色背景图
        loadWhiteView(yRecord: &yRecord)
        // 更新 frame
        frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: yRecord))
    }

    /// 加载话题名
    func loadNameLabel(yRecord: inout CGFloat) {
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        let  name = NSString(string: model.name)
        nameLabel.text = name.replacingOccurrences(of: "\n", with: "")
        nameLabel.sizeToFit()
        // 没有背景图
        if model.coverImage == nil {
             nameLabel.textColor = TSColor.main.content
            nameLabel.frame = CGRect(x: 15, y: allHeight - (160 - 146) - 11 - 16 - 10 - 8 - 20, width: UIScreen.main.bounds.width - 85, height: nameLabel.size.height)
        } else {
            nameLabel.frame = CGRect(x: 15, y: allHeight - (160 - 146) - 11 - 16 - 10 - 8, width: UIScreen.main.bounds.width - 85, height: nameLabel.size.height)
            nameLabel.textColor = UIColor(hex: 0xffffff)
            /// 设置阴影颜色
            nameLabel.shadowColor = UIColor.black
            ///设置阴影大小
            nameLabel.shadowOffset = CGSize(width: 0.4, height: 0.4)
        }
        yRecord = nameLabel.frame.maxY
    }

    /// 加载创建者
    func loadOwnerLabel(yRecord: inout CGFloat) {
        ownerLabel.font = UIFont.systemFont(ofSize: 11)
        // 没有背景图
        if model.coverImage == nil {
              ownerLabel.textColor = TSColor.normal.refreshText
        } else {
            ownerLabel.textColor = UIColor(hex: 0xffffff)
            ownerLabel.shadowColor = UIColor.gray
            ///设置阴影大小
            ownerLabel.shadowOffset = CGSize(width: 0.4, height: 0.4)
        }
        ownerLabel.text = "创建者：\(model.ownerName)"
        ownerLabel.sizeToFit()
        ownerLabel.frame = CGRect(origin: CGPoint(x: 15, y: yRecord + 8), size: ownerLabel.size)
        // 更新 yRecord
        yRecord = ownerLabel.frame.maxY
    }

    /// 加载简介
    func loadIntroLabel(yRecord: inout CGFloat) {
        topicIntro.numberOfLines = 0
        var textCont = TYTextContainer()
        textCont.text = model.intro
        if textCont.text == nil || textCont.text == "" {
             topicIntro.isHidden = true
        } else {
            topicIntro.isHidden = false
            topicIntro.textContainer = textCont
            topicIntro.textContainer.linesSpacing = 4
            topicIntro.textContainer.textColor = UIColor(hex: 0x999999)
            topicIntro.textContainer.font = UIFont.systemFont(ofSize: 14)
            textCont = textCont.createTextContainer(withTextWidth: UIScreen.main.bounds.width - 30)
            // 没有背景图
            if model.coverImage == nil {
                topicIntro.frame = CGRect(x: 15, y: yRecord + 15, width: ScreenWidth - 30, height: textCont.textHeight)
            } else {
                topicIntro.frame = CGRect(x: 15, y: allHeight + 20, width: ScreenWidth - 30, height: textCont.textHeight)
            }
            yRecord = topicIntro.frame.maxY
        }
    }

    func loadTopicMenberView(yRecord: inout CGFloat) {
        topicMenber.removeAllSubViews()
        topicMenber.frame = CGRect(x: 0, y: yRecord + 20, width: ScreenWidth, height: 145)
        let line = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 0.5))
        line.backgroundColor = UIColor(hex: 0xededed)
        topicMenber.addSubview(line)
        let titleTextL = UILabel(frame: CGRect(x: 15, y: 19, width: 150, height: 15))
        titleTextL.textColor = UIColor(hex: 0x333333)
        titleTextL.font = UIFont.systemFont(ofSize: 13)
        titleTextL.text = "参与话题的人"
        topicMenber.addSubview(titleTextL)
        let rightIcon = UIImageView(frame: CGRect(x: ScreenWidth - 18, y: 0, width: 10, height: 20))
        rightIcon.image = #imageLiteral(resourceName: "IMG_ic_arrow_smallgrey")
        rightIcon.centerY = titleTextL.centerY
        topicMenber.addSubview(rightIcon)
        /// 添加一个透明按钮做为跳转的点击区域
        let jumpButton = UIButton(type: .custom)
        jumpButton.frame = CGRect(x: 0, y: 19, width: ScreenWidth, height: 15)
        jumpButton.backgroundColor = UIColor.clear
        topicMenber.addSubview(jumpButton)
        jumpButton.addTarget(self, action: #selector(jumpToTopicMenberListVC), for: UIControlEvents.touchUpInside)
        rightIcon.isHidden = model.menbers.count < 4
        setMenberUI(menber: model.menbers, topY: titleTextL.frame.maxY + 20)
        yRecord = topicMenber.frame.maxY
    }

    func loadWhiteView(yRecord: inout CGFloat) {
        whiteView.backgroundColor = UIColor.white
        whiteView.frame = CGRect(x: 0, y: allHeight, width: UIScreen.main.bounds.width, height: yRecord - allHeight)
        // 更新 yRecord
        yRecord = whiteView.frame.maxY
    }

    func setMenberUI(menber: [TSUserInfoModel], topY: CGFloat) {
        let headerH: CGFloat = 50.0
        let outSpace: CGFloat = (ScreenWidth - 15 * 2 - headerH * 4) / 3
        for (index, item) in menber.enumerated() {
            if index > 3 {
                return
            }
            let avatarView = AvatarView(type: AvatarType.custom(avatarWidth: headerH, showBorderLine: false))
            avatarView.frame = CGRect(x: 15 + (headerH + outSpace) * CGFloat(index), y: topY, width: headerH, height: headerH)
            let avatarInfo = AvatarInfo(userModel: item)
            avatarView.avatarInfo = avatarInfo
            avatarView.buttonForAvatar.isUserInteractionEnabled = true
            avatarView.isUserInteractionEnabled = true
            topicMenber.addSubview(avatarView)
            let nameL = UILabel(frame: CGRect(x: 0, y: avatarView.bottom + 10, width: 80, height: 12))
            nameL.centerX = avatarView.centerX
            nameL.text = item.name
            nameL.textAlignment = .center
            nameL.font = UIFont.systemFont(ofSize: 12)
            nameL.textColor = UIColor(hex: 0x333333)
            topicMenber.addSubview(nameL)
        }
    }

    func jumpToTopicMenberListVC() {
        if model.menbers.count < 4 {
            return
        }
        self.delegate?.didClickJumpButton(self, topicId: model.id)
    }
}
