//
//  TSQuestionDetailView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 26/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题详情视图 - 问答详情页的问题详情视图
//  注：应将该视图命名更正为TSQuestionDetailHeaderView, 而将TSQuestionDetailView给分离出来一个真正的问题详情视图，或者问题内容视图。

import UIKit
import MarkdownView
import YYKit

protocol TSQuestionDetailViewProtocol: class {
    /// 关注按钮点击回调
    func questionView(_ questionView: TSQuestionDetailView, didClickFollowControl followControl: UIControl) -> Void
    /// 悬赏按钮点击回调
    func questionView(_ questionView: TSQuestionDetailView, didClickRewardBtn rewardBtn: UIButton) -> Void
    /// 回答按钮
    func questionView(_ questionView: TSQuestionDetailView, didClickAnswerBtn answerBtn: UIButton) -> Void
    /// 话题点击
    func questionView(_ questionView: TSQuestionDetailView, didClickTopic topic: TSQuoraTopicModel) -> Void
    /// 更多点击展开的回调
    func questionView(_ questionView: TSQuestionDetailView, didClickMoreWithNewHeight newHeight: CGFloat) -> Void
}

class TSQuestionDetailView: UIView {

    // MARK: - Internal Property
    weak var delegate: TSQuestionDetailViewProtocol?
    /// 数据模型
    private(set) var model: TSQuestionDetailModel?
    /// 加载数据，会返回高度，便于外界布局
    func loadModel(_ model: TSQuestionDetailModel, complete:((_ height: CGFloat) -> Void)? = nil) -> Void {
        self.model = model
        self.setupWithModel(model, complete: complete)
    }
    /// 重新加载数据 - 但不对内容样式更改
    func reloadExceptContent() -> Void {
        self.setupNormalData(self.model)
    }
    // MARK: - Private Property
    /// 话题视图
    private weak var topicView: TSQuestionDetailTopicsView!
    /// 标题
    private weak var titleLabel: UILabel!
    private weak var authorNameLabel: UILabel!
    private weak var avatar: AvatarView!
    /// 匿名状态下  图标也要换
    private weak var anoLabel: UILabel!
    // 问题正文内容
    fileprivate weak var questionContentView: TSQuestionDetailContentView!

    /// 关注数
    private weak var followCountLabel: UILabel!
    /// 悬赏金额
    private weak var offerPriceSeparateLabel: UILabel!
    private weak var offerPriceLabel: TSIconLabel!
    /// 围观总金额
    private weak var outlookSeparateLabel: UILabel!
    private weak var outlookAmountLabel: TSIconLabel!

    /// 关注状态
    private weak var followControl: TSFollowControl!
    /// 悬赏按钮
    private weak var offerRewardBtn: UIButton!
    /// 回答按钮
    private weak var answerBtn: UIButton!

    // 底部工具栏按钮Tag基值
    private let bottomBtnTagBase: Int = 250
    private let leftMargin: CGFloat = 15        // 左侧间距
    private let rightMargin: CGFloat = 15       // 右侧间距
    private let bottomH: CGFloat = 45             // 底部工具栏高度
    private let titleTopMargin: CGFloat = 15    // 标题顶部间距
    private let contentTopMargin: CGFloat = 20  // 内容顶部间距
    private let followTopMargin: CGFloat = 15   // 关注顶部间距
    private let followBottomMargin: CGFloat = 15// 关注底部间距
    private let followBtnH: CGFloat = 25        // 关注高度
    private let titleFont: UIFont = UIFont.boldSystemFont(ofSize: 18)   // 标题字体
    /// 固定高度
    private var fixedHeight: CGFloat {
        return self.bottomH + self.followBottomMargin + self.followBtnH + self.followTopMargin + self.contentTopMargin + self.titleTopMargin
    }

    // MARK: - Internal Function

    // MARK: - Initialize Function
    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        self.backgroundColor = UIColor.white
        // 1. topicView
        let topicView = TSQuestionDetailTopicsView(width: Float(ScreenWidth - leftMargin - rightMargin), minHeight: 40)
        self.addSubview(topicView)
        topicView.delegate = self
        topicView.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(leftMargin)
            make.trailing.equalTo(self).offset(-rightMargin)
            make.top.equalTo(self)
            make.height.greaterThanOrEqualTo(40)
        }
        self.topicView = topicView
        // 2. contentView
        let contentView = UIView()
        self.addSubview(contentView)
        contentView.addLineWithSide(.inTop, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: 0, margin2: 0)
        self.initialContentView(contentView)
        contentView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(topicView)
            make.top.equalTo(topicView.snp.bottom)
        }
        // 3. bottomView
        let bottomView = UIView()
        self.addSubview(bottomView)
        self.initialBottomView(bottomView)
        bottomView.addLineWithSide(.inTop, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: 0, margin2: 0)
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(contentView.snp.bottom)
            make.height.equalTo(bottomH)
        }
    }
    /// 内容视图布局
    private func initialContentView(_ contentView: UIView) -> Void {
        // 1. titleLabel
        let titleLabel = UILabel(text: "", font: self.titleFont, textColor: UIColor(hex: 0x333333))
        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(contentView)
            make.trailing.equalTo(contentView)
            make.top.equalTo(contentView).offset(titleTopMargin)
        }
        self.titleLabel = titleLabel

        let avatar = AvatarView(type: AvatarType.width20(showBorderLine: false))
        contentView.addSubview(avatar)
        avatar.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(7)
            make.leading.equalTo(titleLabel)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        self.avatar = avatar
        
        let anoLabel = UILabel()
        contentView.addSubview(anoLabel)
        anoLabel.backgroundColor = UIColor(hexString: "0xcccccc")
        anoLabel.layer.cornerRadius = 10
        anoLabel.layer.masksToBounds = true
        anoLabel.text = "匿"
        anoLabel.textAlignment = .center
        anoLabel.font = UIFont.systemFont(ofSize: 11)
        anoLabel.textColor = UIColor.white
        anoLabel.frame = CGRect(x: 0, y: 43.5, width: 20, height: 20)
        self.anoLabel = anoLabel
        self.anoLabel.isHidden = true

        let authorNameLabel = UILabel()
        contentView.addSubview(authorNameLabel)
        authorNameLabel.font = UIFont(name: "PingFangSC-Regular", size: 13)
        authorNameLabel.textColor = UIColor(hex: 0x999999)
        authorNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatar.snp.right).offset(6)
            make.height.equalTo(20)
            make.trailing.equalTo(titleLabel)
            make.top.equalTo(avatar)
        }
        self.authorNameLabel = authorNameLabel

        // 2. 内容正文
        let questionContentView = TSQuestionDetailContentView(contentLrMargin: self.leftMargin, viewWidth: ScreenWidth - self.leftMargin - self.rightMargin)
        contentView.addSubview(questionContentView)
        questionContentView.delegate = self
        questionContentView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(avatar.snp.bottom).offset(contentTopMargin)
            make.height.equalTo(100)    // 随便写的初始高度
        }
        self.questionContentView = questionContentView
        // 3. contentBottomView
        let contentBottomView = UIView()
        contentView.addSubview(contentBottomView)
        self.initialContentBottomView(contentBottomView)
        contentBottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(contentView)
            make.top.equalTo(questionContentView.snp.bottom)
        }
    }
    /// 内容底部视图布局
    private func initialContentBottomView(_ bottomView: UIView) -> Void {
        // 4. followControl
        let followControl = TSFollowControl()
        bottomView.addSubview(followControl)
        followControl.addTarget(self, action: #selector(followControlClick(_:)), for: .touchUpInside)
        followControl.snp.makeConstraints { (make) in
            make.height.equalTo(followBtnH)
            make.trailing.equalTo(bottomView)
            make.bottom.equalTo(bottomView).offset(-followBottomMargin)
            make.top.equalTo(bottomView).offset(followTopMargin)
            make.width.greaterThanOrEqualTo(65)
        }
        self.followControl = followControl

        // 1. followCountLabel
        let followCountLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: UIColor(hex: 0x999999))
        bottomView.addSubview(followCountLabel)
        followCountLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(bottomView)
            make.centerY.equalTo(followControl)
        }
        self.followCountLabel = followCountLabel
        // 2.x separateLabel
        let offerPriceSeparateLabel = UILabel(text: " · ", font: UIFont.systemFont(ofSize: 14), textColor: UIColor(hex: 0x999999))
        bottomView.addSubview(offerPriceSeparateLabel)
        offerPriceSeparateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(bottomView)
            make.leading.equalTo(followCountLabel.snp.trailing)
        }
        self.offerPriceSeparateLabel = offerPriceSeparateLabel
        // 2. offerPriceLabel
        let offerPriceLabel = TSIconLabel(iconName: "IMG_ico_quora__shang", text: "")
        bottomView.addSubview(offerPriceLabel)
        offerPriceLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(offerPriceSeparateLabel.snp.trailing)
            make.centerY.equalTo(bottomView)
        }
        self.offerPriceLabel = offerPriceLabel
        // 3.x outlookSeparateLabel
        let outlookSeparateLabel = UILabel(text: " · ", font: UIFont.systemFont(ofSize: 14), textColor: UIColor(hex: 0x999999))
        bottomView.addSubview(outlookSeparateLabel)
        outlookSeparateLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(offerPriceLabel.snp.trailing)
            make.centerY.equalTo(bottomView)
        }
        self.outlookSeparateLabel = outlookSeparateLabel
        // 3. outlookAmountLabel
        let outlookAmountLabel = TSIconLabel(iconName: "IMG_ico_quora__wei", text: "")
        bottomView.addSubview(outlookAmountLabel)
        outlookAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(bottomView)
            make.leading.equalTo(outlookSeparateLabel.snp.trailing)
        }
        self.outlookAmountLabel = outlookAmountLabel

        // 默认隐藏
        offerPriceSeparateLabel.isHidden = true
        offerPriceLabel.isHidden = true
        outlookSeparateLabel.isHidden = true
        outlookAmountLabel.isHidden = true

    }
    /// 底部视图布局
    private func initialBottomView(_ bottomView: UIView) -> Void {
        let imageTitleMargin: CGFloat = 10
        // 公开悬赏/添加回答
        let titles = ["公开悬赏", "显示_添加回答".localized]
        let imageNames = ["IMG_ico_quora_question_reward", "IMG_ico_quora_question_answer"]
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .custom)
            bottomView.addSubview(button)
            button.setTitle(title, for: .normal)
            button.setImage(UIImage(named: imageNames[index]), for: .normal)
            button.setTitleColor(UIColor(hex: 0x666666), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.addTarget(self, action: #selector(bottomBtnClick(_:)), for: .touchUpInside)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: imageTitleMargin * 0.5, bottom: 0, right: 0)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTitleMargin * 0.5, bottom: 0, right: 0)
            button.tag = index + self.bottomBtnTagBase
            button.addTarget(self, action: #selector(bottomBtnClick(_:)), for: .touchUpInside)
            button.snp.makeConstraints({ (make) in
                make.top.bottom.equalTo(bottomView)
                make.width.equalTo(bottomView).multipliedBy(0.5)
                if 0 == index {
                    make.leading.equalTo(bottomView)
                } else {
                    make.leading.equalTo(bottomView.snp.centerX)
                }
            })
        }
        self.offerRewardBtn = self.viewWithTag(self.bottomBtnTagBase + 0) as! UIButton
        self.answerBtn = self.viewWithTag(self.bottomBtnTagBase + 1) as! UIButton
        // 分隔线
        let separateLine = UIView(bgColor: UIColor(hex: 0xededed))
        bottomView.addSubview(separateLine)
        separateLine.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.width.equalTo(0.5)
            make.center.equalTo(bottomView)
        }
    }

    // MARK: - Private  数据加载
    /// 记载普通数据 - 非内容部分(内容部分涉及高度)
    private func setupNormalData(_ model: TSQuestionDetailModel?) -> Void {
        guard let model = model else {
            return
        }
        // 1. 话题标签
        self.topicView.topics = model.topics
        // 2. content
        self.titleLabel.text = model.title
        /// 作者信息 (如果是匿名,并且不是自己,那么不会有信息)
        if model.isAnonymity {
            if model.userId == TSCurrentUserInfo.share.userInfo?.userIdentity {
                avatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: TSCurrentUserInfo.share.userInfo?.sex)
                let avatarInfo = AvatarInfo()
                avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: TSCurrentUserInfo.share.userInfo?.avatar)
                avatarInfo.verifiedIcon = TSCurrentUserInfo.share.userInfo?.verified?.icon ?? ""
                avatarInfo.verifiedType = TSCurrentUserInfo.share.userInfo?.verified?.type ?? ""
                avatarInfo.type = .normal(userId: TSCurrentUserInfo.share.userInfo?.userIdentity)
                self.avatar.avatarInfo = avatarInfo
                if let name = TSCurrentUserInfo.share.userInfo?.name {
                    self.authorNameLabel.text = name + "(匿名)"
                }
            } else {
                avatar.avatarPlaceholderType = AvatarView.PlaceholderType.unknown
                let avatarInfo = AvatarInfo()
                avatarInfo.type = .normal(userId: nil)
                self.avatar.avatarInfo = avatarInfo
                self.authorNameLabel.text = "匿名用户"
                
                anoLabel.isHidden = false
            }
        } else {
            avatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.user?.sex)
            let avatarInfo = AvatarInfo()
            avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: model.user?.avatar)
            avatarInfo.verifiedIcon = model.user?.verified?.icon ?? ""
            avatarInfo.verifiedType = model.user?.verified?.type ?? ""
            avatarInfo.type = .normal(userId: model.user?.userIdentity)
            self.avatar.avatarInfo = avatarInfo
            self.authorNameLabel.text = model.user?.name
        }
        // 关注数
        self.followCountLabel.text = "\(model.watchersCount) 关注"
        // 悬赏
        if model.amount > 0 {
            self.offerPriceLabel.text = "\(model.amount)"
            self.offerPriceSeparateLabel.isHidden = false
            self.offerPriceLabel.isHidden = false
            // 围观
            if model.isLook {
                // 使用问题模型中的围观金额，通过邀请答案转换而来
                let outlookAmout = model.outlookAmount ?? 0
                // 使用邀请答案中的围观金额字段
                //let outlookAmout = model.invitationAnswers?.first?.outlookAmount ?? 0
                // 使用计算方案：围观总数 * 围观金额
                //var outlookAmout = 0
                //if let outlookUnitPrice = TSAppConfig.share.launchInfo?.quoraOutLookAmount, let outlookCount = model.invitationAnswers?.first?.outlookCount {
                //    outlookAmout = outlookUnitPrice * outlookCount
                //}
                self.outlookAmountLabel.text = "\(outlookAmout)"
                self.outlookSeparateLabel.isHidden = false
                self.outlookAmountLabel.isHidden = false
            } else {
                self.outlookSeparateLabel.isHidden = true
                self.outlookAmountLabel.isHidden = true
            }
        } else {
            self.offerPriceSeparateLabel.isHidden = true
            self.offerPriceLabel.isHidden = true
        }
        // 关注状态
        self.followControl.isSelected = model.isWatched
        // 3. bototmTool
        // 悬赏按钮的状态： 未设置悬赏 已设置悬赏（对外公开的悬赏）和 已邀请悬赏
        switch model.rewardType {
        case .none:
            // 未设置悬赏
            self.offerRewardBtn.setTitle("未设置悬赏", for: .normal)
            self.offerRewardBtn.setImage(#imageLiteral(resourceName: "IMG_ico_quora_question_reward"), for: .normal)
        case .normal:
            // 已设置悬赏（对外公开的悬赏） - 无邀请
            self.offerRewardBtn.setTitle("已设置悬赏", for: .normal)
            self.offerRewardBtn.setImage(#imageLiteral(resourceName: "IMG_ico_quora_question_invited"), for: .normal)
        case .invitation:
            // 已邀请悬赏
            self.offerRewardBtn.setTitle("已邀请悬赏", for: .normal)
            self.offerRewardBtn.setImage(#imageLiteral(resourceName: "IMG_ico_quora_question_invited"), for: .normal)
        }
        // 添加回答状态
        let answerTitle: String = (nil == model.myAnswer) ? "显示_添加回答".localized : "显示_查看回答".localized
        let answerImage: UIImage? = (nil == model.myAnswer) ? #imageLiteral(resourceName: "IMG_ico_quora_question_answer") : nil
        self.answerBtn.setTitle(answerTitle, for: .normal)
        self.answerBtn.setImage(answerImage, for: .normal)
    }
    /// 加载详情页数据
    private func setupWithModel(_ model: TSQuestionDetailModel?, complete: ((_ height: CGFloat) -> Void)? = nil) -> Void {
        guard let model = model else {
            return
        }
        self.setupNormalData(model)
        // 内容展示处理
        self.questionContentView.loadModel(model) { (contentH) in
            self.questionContentView.snp.updateConstraints({ (make) in
                make.height.equalTo(contentH)
            })
            self.layoutIfNeeded()
            let height = self.heightWithModel(model, contentH: contentH)
            complete?(height)
        }
    }

    /// 高度计算: 非折叠状态需计算展示内容，折叠状态不计算内容
    fileprivate func heightWithModel(_ model: TSQuestionDetailModel, contentH: CGFloat) -> CGFloat {
        // title位置的高度计算
        let titleH: CGFloat = model.title.size(maxSize: CGSize(width: ScreenWidth - self.leftMargin - self.rightMargin, height: CGFloat(MAXFLOAT)), font: self.titleFont, lineMargin: 0).height
        let totalH: CGFloat = self.fixedHeight + titleH + CGFloat(self.topicView.currentHeight) + contentH + 7 + 20
        return totalH
    }

    // MARK: - Private  事件响应
    /// 关注按钮点击响应
    @objc private func followControlClick(_ control: UIControl) -> Void {
        self.delegate?.questionView(self, didClickFollowControl: control)
    }
    /// 底部按钮点击响应
    @objc private func bottomBtnClick(_ button: UIButton) -> Void {
        let index = button.tag - self.bottomBtnTagBase
        switch index {
        case 0:     // 公开悬赏
             button.isSelected = !button.isSelected
            self.delegate?.questionView(self, didClickRewardBtn: button)
            print("bottomBtnClick  公开悬赏")
        case 1:     // 添加回答
            button.isSelected = !button.isSelected
            self.delegate?.questionView(self, didClickAnswerBtn: button)
            print("bottomBtnClick  添加回答")
        default:
            break
        }
    }
}

// MARK: - TSQuestionDetailTopicsViewProtocol

extension TSQuestionDetailView: TSQuestionDetailTopicsViewProtocol {
    /// 选中选中的回调
    func topicView(_ topicView: TSQuestionDetailTopicsView, didClickTopic topic: TSQuoraTopicModel) -> Void {
        self.delegate?.questionView(self, didClickTopic: topic)
    }
}

// MARK: - TSQuestionDetailContentViewProtocol

extension TSQuestionDetailView: TSQuestionDetailContentViewProtocol {
    /// 问题详情展开回调
    func didClickShowMoreWithNewHeight(_ newHeight: CGFloat) {
        guard let model = self.model else {
            return
        }
        let height: CGFloat = self.heightWithModel(model, contentH: newHeight)
        self.questionContentView.snp.updateConstraints({ (make) in
            make.height.equalTo(height)
        })
        self.layoutIfNeeded()
        self.delegate?.questionView(self, didClickMoreWithNewHeight: height)
    }
}
