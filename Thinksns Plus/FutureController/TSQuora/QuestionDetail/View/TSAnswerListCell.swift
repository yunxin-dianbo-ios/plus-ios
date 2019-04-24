//
//  TSAnswerListCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 26/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题详情页中答案列表的Cell

import UIKit
import ActiveLabel

protocol TSAnswerListCellProtocol: class {
    /// 点赞
    func didClickFavorItemInCell(_ cell: TSAnswerListCell) -> Void
    /// 评论
    func didClickCommentItemInCell(_ cell: TSAnswerListCell) -> Void
    // 采纳
    func didClickAgreeButton(_ cell: TSAnswerListCell) -> Void
}

class TSAnswerListCell: UITableViewCell {

    // MARK: - Internal Property
    weak var delegate: TSAnswerListCellProtocol?
    /// 数据模型，加载数据模型请使用loadAnswer方法
    private(set) var model: TSAnswerListModel?
    /// 工具栏是否可用，主要用于点赞时避免连续请求，且应在重用里恢复设置
    var toolBarEnable: Bool = true {
        didSet {
            self.toolBar.isUserInteractionEnabled = toolBarEnable
        }
    }
    /**
    var isMyQuestion: Bool = false {
        didSet {
            guard let model = self.model else {
                self.agreeButton.isHidden = true
                return
            }
            if !model.isAdoption && isMyQuestion {
                self.agreeButton.isHidden = false
            }
        }
    }
    */
    /// 更新toolBar：点赞数/点赞状态/评论数
    func updateToolBar() -> Void {
        guard let model = self.model else {
            return
        }
        // favor
        self.toolBar.setTitle("\(model.likesCount)", At: 0)
        self.toolBar.setImage(model.liked ? "IMG_home_ico_good_high" : "IMG_home_ico_good_normal", At: 0)
        // comment
        self.toolBar.setTitle("\(model.commentsCount)", At: 1)
    }
    /// 点赞/取消点赞操作 - 用于点赞时的临时展示
    var favorOrUnFavor: Bool = false {
        didSet {
            self.toolBar.setImage(favorOrUnFavor ? "IMG_home_ico_good_high" : "IMG_home_ico_good_normal", At: 0)
            var favorCount = 0
            if let likesCount = self.model?.likesCount {
                favorCount = likesCount + (favorOrUnFavor ? 1 : -1)
                favorCount = favorCount > 0 ? favorCount : 0
            }
            self.toolBar.setTitle("\(favorCount)", At: 0)
        }
    }

    // MARK: - Private Property
    private let bottomSeparateH: CGFloat = 5        // 底部分割间距
    private let bottomH: CGFloat = 45               // 底部工具栏高度
    private let iconWH: CGFloat = 30                // 头像高宽
    private let leftMargin: CGFloat = 15            // 左侧间距
    private let rightMargin: CGFloat = 15           // 右侧间距
    private let topMargin: CGFloat = 15             // 顶部间距 - 头像/name/tag/time
    private let contentTopMargin: CGFloat = 15      // 正文顶部间距 - 正文与tag底部的间距
    private let contentBottomMargin: CGFloat = 15   // 正文底部间距 - 正文与底部工具栏之间的间距
    private let nameLeftMargin: CGFloat = 15        // 名字的左边距
    private let tagLeftMargin: CGFloat = 10         // tag标签的左边距
    private let tagH: CGFloat = 15                  // tag标签高度
    private let outlookBtnW: CGFloat = 55           // 围观按钮宽度
    private let outlookBtnH: CGFloat = 25           // 围观按钮高度
    private let outlookLabelRightMargin: CGFloat = 12    // 围观人数标签距离右侧围观按钮的间距

    private weak var toolBar: TSToolbarView!
    /// 头像
    private weak var iconView: AvatarView!
    /// 匿名头像
    private weak var iconAnonymousView: UIView!
    /// 名字
    private weak var nameLabel: UILabel!
    /// 被采纳标签
    private weak var adoptedTag: UIView!
    /// 邀请标签
    private weak var invitationTag: UIView!
    /// 发布时间
    private weak var timeLabel: UILabel!
    /// 发布的简短内容: 为了处理回答内容中含有的链接，使用ActiveLabel代替UILabel
    fileprivate weak var shortContentLabel: ActiveLabel!
//    fileprivate weak var shortContentLabel: UILabel!
    /// 底部视图 - 内容赋值时可能需要更新约束
    private weak var bottomView: UIView!
    /// 点赞按钮
    private weak var favorBtn: UIButton!
    /// 评论按钮
    private weak var commentBtn: UIButton!
    /// 围观按钮 
    private weak var outlookBtn: UIButton!
    /// 围观人数标签
    private weak var outlookLabel: UILabel!
    weak var agreeButton: UIButton!

    // MARK: - Internal Function

    class func cellInTableView(_ tableView: UITableView) -> TSAnswerListCell {
        let identifier = "TSAnswerListCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = TSAnswerListCell(style: .default, reuseIdentifier: identifier)
        }
        // 显示重置
        (cell as! TSAnswerListCell).resetShow()
        return cell as! TSAnswerListCell
    }
    /// 视图重置
    func resetShow() -> Void {
        self.shortContentLabel.text = ""
        self.timeLabel.text = ""
        self.outlookLabel.text = ""
        self.iconView.avatarInfo.avatarURL = nil
        self.iconAnonymousView.isHidden = true
        self.nameLabel.text = ""
        self.toolBarEnable = true
    }
    /// 加载数据
    ///
    /// - Parameters:
    ///   - answer: 待加载的答案，内部会持有该答案
    ///   - questionUserId: 答案所属的问题的用户Id，用于判断该答案的问题发布者
    ///   - showTag: 是否显示标签(邀请回答、已采纳)。我的提问和我的回答时可通过设置为false来隐藏
    func loadAnswer(_ answer: TSAnswerListModel, questionUserId: Int?, showTag: Bool = true, isAdopted: Bool) -> Void {
        self.model = answer
        self.setupWithModel(answer, questionUserId: questionUserId, showTag: showTag, isAdopted: isAdopted)
        self.toolBarEnable = true
    }

    // MARK: - Initialize Function

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Override Function

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        self.contentView.backgroundColor = TSColor.inconspicuous.background
        // mainView - 整体布局，便于扩展，特别是针对分割、背景色、四周间距
        let mainView = UIView()
        self.contentView.addSubview(mainView)
        self.initialMainView(mainView)
        mainView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView).offset(-bottomSeparateH)
        }
    }
    // 主视图布局
    private func initialMainView(_ mainView: UIView) -> Void {
        mainView.backgroundColor = UIColor.white
        // 1. topView
        let topView = UIView()
        mainView.addSubview(topView)
        self.initialTopView(topView)
        topView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(mainView)
        }
        // 2. bottomView
        let bottomView = UIView()
        mainView.addSubview(bottomView)
        self.initialBottomView(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(mainView)
            make.height.equalTo(bottomH)
            make.top.equalTo(topView.snp.bottom)
        }
        self.bottomView = bottomView
        // 3. separateLine
        bottomView.addLineWithSide(.inTop, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: 0, margin2: 0)
    }
    /// 顶部布局
    private func initialTopView(_ topView: UIView) -> Void {
        // 1. iconView
        let iconView = AvatarView(type: AvatarType.width38(showBorderLine: false))
        topView.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(iconWH)
            make.leading.equalTo(topView).offset(leftMargin)
            make.top.equalTo(topView).offset(topMargin)
        }
        self.iconView = iconView
        // 1.1 iconAnonymousView
        let anonymousView = UIControl(cornerRadius: iconWH * 0.5)
        topView.addSubview(anonymousView)
        anonymousView.backgroundColor = TSColor.normal.disabled
        // 添加点击事件，使匿名头像点击时不做任何响应(主要是不响应cell的选中事件)
        anonymousView.addTarget(self, action: #selector(anonymousViewClick), for: .touchUpInside)
        anonymousView.snp.makeConstraints { (make) in
            make.edges.equalTo(iconView)
        }
        self.iconAnonymousView = anonymousView
        // 1.1.x iconAnonymousLabel
        let iconAnonymousLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: UIColor.white, alignment: .center)
        anonymousView.addSubview(iconAnonymousLabel)
        iconAnonymousLabel.snp.makeConstraints { (make) in
            make.center.equalTo(anonymousView)
        }
        // 2. nameLabel
        let nameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 13), textColor: UIColor(hex: 0x333333))
        topView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconView)
            make.leading.equalTo(iconView.snp.trailing).offset(nameLeftMargin)
        }
        self.nameLabel = nameLabel
        // 3. adoptedTag  被采纳标签
        // 3.1 adoptedView
        let adoptedView = UIView(cornerRadius: 2, borderWidth: 1, borderColor: UIColor(hex: 0x4bb893))
        topView.addSubview(adoptedView)
        adoptedView.snp.makeConstraints { (make) in
            make.height.equalTo(tagH)
            make.top.equalTo(iconView)
            make.leading.equalTo(nameLabel.snp.trailing).offset(tagLeftMargin)
        }
        self.adoptedTag = adoptedView
        // 3.2 adoptedLabel
        let adoptedLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 10), textColor: UIColor(hex: 0x4bb893))
        adoptedView.addSubview(adoptedLabel)
        adoptedLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(adoptedView).offset(3)
            make.trailing.equalTo(adoptedView).offset(-3)
            make.centerY.equalTo(adoptedView)
        }
        // 4. invitationTag 邀请标签
        // 4.1 invitationView
        let invitationView = UIView(cornerRadius: 2, borderWidth: 1, borderColor: TSColor.main.theme)
        topView.addSubview(invitationView)
        invitationView.snp.makeConstraints { (make) in
            make.height.equalTo(tagH)
            make.top.equalTo(iconView)
            make.leading.equalTo(adoptedView.snp.trailing).offset(tagLeftMargin)
        }
        self.invitationTag = invitationView
        // 4.2 invitationLabel
        let invitationLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 10), textColor: TSColor.main.theme)
        invitationView.addSubview(invitationLabel)
        invitationLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(invitationView).offset(3)
            make.trailing.equalTo(invitationView).offset(-3)
            make.centerY.equalTo(invitationView)
        }
        // 5. timeLabel
        let timeLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: UIColor(hex: 0xcccccc))
        topView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconView)
            make.trailing.equalTo(topView).offset(-rightMargin)
        }
        self.timeLabel = timeLabel
        // 6. shortContentLabel
        let contentLabel = ActiveLabel()
        topView.addSubview(contentLabel)
        contentLabel.numberOfLines = 3
        contentLabel.textColor = TSColor.normal.content
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.lineSpacing = 2
        contentLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(topView).offset(leftMargin + iconWH + nameLeftMargin)
            make.trailing.equalTo(topView).offset(-rightMargin)
            make.top.equalTo(adoptedView.snp.bottom).offset(contentTopMargin)
            make.bottom.equalTo(topView).offset(-contentBottomMargin)
        }
        // 设置短链接点击事件
        contentLabel.handleURLTap { (url) in
            let newUrl = url.ts_serverLinkUrlProcess()
            if let nav = TSRootViewController.share.tabbarVC?.selectedViewController as? UINavigationController {
                TSUtil.pushURLDetail(url: newUrl, currentVC: nav)
            }
        }
        self.shortContentLabel = contentLabel
        // 8. Localized
        adoptedLabel.text = "已采纳".localized
        invitationLabel.text = "邀请回答".localized
        iconAnonymousLabel.text = "匿".localized
    }
    /// 底部布局
    private func initialBottomView(_ bottomView: UIView) -> Void {
        // 1. favorBtn/commentBtn
        let favorItem = TSToolbarItemModel(image: "IMG_home_ico_good_normal", title: "0", index: 0)
        let commentItem = TSToolbarItemModel(image: "IMG_home_ico_comment_normal", title: "0", index: 1)
        let toolX = leftMargin + iconWH + nameLeftMargin
        let toolBar = TSToolbarView(frame: CGRect(x: toolX, y: 0, width: UIScreen.main.bounds.width - toolX, height: bottomH), type: .left, items: [favorItem, commentItem])
        bottomView.addSubview(toolBar)
        toolBar.delegate = self
        self.toolBar = toolBar
        // 3. outlookBtn - 注：围观按钮不单独响应事件，其响应与cell的点击一致
        let outlookBtn = UIButton(cornerRadius: 4)
        bottomView.addSubview(outlookBtn)
        outlookBtn.isHidden = true  // 默认隐藏
        outlookBtn.setTitleColor(UIColor.white, for: .normal)
        outlookBtn.setTitleColor(TSColor.normal.minor, for: .selected)
        outlookBtn.setTitle("去围观", for: .normal)
        outlookBtn.setTitle("已围观", for: .selected)
        outlookBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        outlookBtn.isUserInteractionEnabled = false
        outlookBtn.setBackgroundImage(UIImage(color: TSColor.button.normal), for: .normal)
        outlookBtn.setBackgroundImage(UIImage(color: TSColor.inconspicuous.disabled), for: .selected)
        outlookBtn.snp.makeConstraints { (make) in
            make.width.equalTo(outlookBtnW)
            make.height.equalTo(outlookBtnH)
            make.centerY.equalTo(bottomView)
            make.trailing.equalTo(bottomView).offset(-rightMargin)
        }
        self.outlookBtn = outlookBtn
        // 4. outlookLabel
        let outlookLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: UIColor(hex: 0xb2b2b2))
        bottomView.addSubview(outlookLabel)
        outlookLabel.isHidden = true    //  默认隐藏
        outlookLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(bottomView)
            make.trailing.equalTo(bottomView).offset(-rightMargin)
        }
        self.outlookLabel = outlookLabel

        ///采纳按钮
        let agreeButton = UIButton()
        bottomView.addSubview(agreeButton)
        agreeButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(bottomView).offset(-16)
            make.width.equalTo(63)
            make.height.equalTo(25)
            make.centerY.equalTo(bottomView)
        }
        agreeButton.clipsToBounds = true
        agreeButton.layer.cornerRadius = 4
        agreeButton.layer.borderWidth = 1
        agreeButton.layer.borderColor = TSColor.main.theme.cgColor
        agreeButton.setImage(UIImage(named: "ico_adopt"), for: .normal)
        agreeButton.setTitle("采纳", for: .normal)
        agreeButton.titleLabel?.font = UIFont(name: "PingFang-SC-Medium", size: 13)
        agreeButton.setTitleColor(TSColor.main.theme, for: .normal)
        agreeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2.5, 0, 2.5)
        agreeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2.5, 0, -2.5)
        agreeButton.isHidden = true
        agreeButton.addTarget(self, action: #selector(agreeButtonClick(agree:)), for: UIControlEvents.touchUpInside)
        self.agreeButton = agreeButton
    }

    // MARK: - Private  数据加载
    /// 数据加载
    private func setupWithModel(_ model: TSAnswerListModel, questionUserId: Int?, showTag: Bool = true, isAdopted: Bool) -> Void {
        // 用户信息， 注意匿名展示 - 可优化
        if model.isAnonymity {
            // 匿名时展示
            if TSCurrentUserInfo.share.isLogin && model.userId == TSCurrentUserInfo.share.userInfo?.userIdentity {
                // 匿名发布者 自己查看
                self.iconView.isHidden = false
                self.iconAnonymousView.isHidden = true
                self.iconView.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.user?.sex)
                var avatarInfo = AvatarInfo()
                avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile:model.user?.avatar)
                if let user = model.user {
                    avatarInfo = AvatarInfo(userModel: user)
                }
                avatarInfo.type = .normal(userId: model.userId)
                self.iconView.avatarInfo = avatarInfo
                let nameFont = self.nameLabel.font!
                let attNmae = NSMutableAttributedString(str: model.user!.name, font: nameFont, color: self.nameLabel.textColor)
                attNmae.append(NSMutableAttributedString(str: "(匿名)", font: nameFont, color: TSColor.normal.secondary))
                self.nameLabel.attributedText = attNmae
            } else {
                // 匿名展示
                self.iconView.isHidden = true
                self.iconAnonymousView.isHidden = false
                self.nameLabel.text = "匿名用户"
            }
        } else {
            // 正常展示
            self.iconView.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: (model.user?.sex ?? 0))
            self.iconView.isHidden = false
            self.iconAnonymousView.isHidden = true
            var avatarInfo = AvatarInfo()
            avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile:model.user?.avatar)
            if let user = model.user {
                avatarInfo = AvatarInfo(userModel: user)
            }
            avatarInfo.type = .normal(userId: model.userId)
            self.iconView.avatarInfo = avatarInfo
            self.nameLabel.text = model.user?.name
        }

        if let date = model.createDate {
            self.timeLabel.text = TSDate().dateString(.normal, nsDate: date as NSDate)
        }
        // 答案内容展示，可能需要模糊
        // 被邀请人的答案开启围观后需要对外开启模糊(悬赏邀请开启围观时，被邀请人的答案，对外模糊展示(对内：问题发布者、被邀请的人 则无需开启模糊))
        if nil == model.could || true == model.could {
            self.shortContentLabel.numberOfLines = 3
            // 不需要围观 或 可以围观，则正常展示
            // body_text为新的答案的文本描述字段，之前的为nil，则使用之前的方式处理
            self.shortContentLabel.shouldAddFuzzyString = false  // 模糊展示标记更新，避免因重用导致异常
            let answer = model.body_text?.ts_customMarkdownToNormal() ?? model.body.ts_customMarkdownToNormal()
            self.shortContentLabel.attributedText = NSAttributedString(string: answer)
            shortContentLabel.mentionColor = TSColor.main.theme
            shortContentLabel.URLColor = TSColor.main.theme
            shortContentLabel.URLSelectedColor = TSColor.main.theme
        } else {
            self.shortContentLabel.numberOfLines = 1
            // 需要模糊展示
            self.shortContentLabel.shouldAddFuzzyString = true
            // 注：1. 使用attributedText而不是使用text；2. 当内容为空时也要传个空格，否则展示异常，根本就没有模糊图。
            self.shortContentLabel.attributedText = NSAttributedString(string: " ")
        }
        self.shortContentLabel.sizeToFit()
        // favor
        self.toolBar.setTitle("\(model.likesCount)", At: 0)
        self.toolBar.setImage(model.liked ? "IMG_home_ico_good_high" : "IMG_home_ico_good_normal", At: 0)
        // comment
        self.toolBar.setTitle("\(model.commentsCount)", At: 1)
        // outlook
        if nil == model.could {
            // 普通答案，无需展示围观
            self.outlookLabel.isHidden = true
            self.outlookBtn.isHidden = true
        } else if true == model.could {
            // 已围观
            self.outlookLabel.text = String(format: "%d人正在围观", model.outlookCount ?? 0)
            self.outlookLabel.isHidden = false
            self.outlookBtn.isSelected = true
            if TSCurrentUserInfo.share.isLogin && (TSCurrentUserInfo.share.userInfo?.userIdentity == model.userId || TSCurrentUserInfo.share.userInfo?.userIdentity == questionUserId) {
                // 当前登录用户是答案发布者 或 问题发布者，则不显示围观按钮
                self.outlookBtn.isHidden = true
                self.outlookLabel.snp.updateConstraints({ (make) in
                    make.trailing.equalTo(self.bottomView).offset(-rightMargin)
                })
            } else {
                // 未登录用户 或 其他人，则需要显示围观按钮
                self.outlookBtn.isHidden = false
                self.outlookLabel.snp.updateConstraints({ (make) in
                    make.trailing.equalTo(self.bottomView).offset(-(rightMargin + outlookBtnW + outlookLabelRightMargin))
                })
            }
        } else {
            // 未围观
            self.outlookLabel.text = String(format: "%d人正在围观", model.outlookCount ?? 0)
            self.outlookLabel.isHidden = false
            self.outlookBtn.isHidden = false
            self.outlookBtn.isSelected = false
            self.outlookLabel.snp.updateConstraints({ (make) in
                make.trailing.equalTo(self.bottomView).offset(-(rightMargin + outlookBtnW + outlookLabelRightMargin))
            })
        }
        // Tag
        if showTag {
            self.adoptedTag.isHidden = !model.isAdoption
            self.invitationTag.isHidden = !model.isInvited
        } else {
            self.adoptedTag.isHidden = true
            self.invitationTag.isHidden = true
        }
        // 暂时将adoptedTag放置到左边，invitationTag放置到右边
        if model.isInvited {
            self.invitationTag.snp.remakeConstraints { (make) in
                make.height.equalTo(tagH)
                make.top.equalTo(self.iconView)
                if model.isAdoption {
                    make.leading.equalTo(self.adoptedTag.snp.trailing).offset(tagLeftMargin)
                } else {
                    make.leading.equalTo(self.nameLabel.snp.trailing).offset(tagLeftMargin)
                }
            }
        }
        if !model.isAdoption && questionUserId == TSCurrentUserInfo.share.userInfo?.userIdentity && model.userId != TSCurrentUserInfo.share.userInfo?.userIdentity && !isAdopted {
            self.agreeButton.isHidden = false
            // 有采纳按钮的时候不显示围观
            self.outlookLabel.isHidden = true
        } else {
            self.agreeButton.isHidden = true
        }
    }

    // MARK: - Private  事件响应

    /// 匿名头像点击事件
    @objc fileprivate func anonymousViewClick() -> Void {
        // 匿名头像点击，不做任何处理。主要是拦截响应，避免点击匿名头像时响应cell的选中
    }

    /// 采纳按钮点击a事件
    @objc private func agreeButtonClick(agree: UIButton) {
        self.delegate?.didClickAgreeButton(self)
    }

}

// MARK: - TSToolbarViewDelegate

extension TSAnswerListCell: TSToolbarViewDelegate {
    /// item 被点击
    func toolbar(_ toolbar: TSToolbarView, DidSelectedItemAt index: Int) -> Void {
        if nil == self.model {
            return
        }
        switch index {
        // 点赞
        case 0:
            self.delegate?.didClickFavorItemInCell(self)
        // 评论
        case 1:
            // 需要判断是否是围观的情况,如果是还没有围观，需要拦截评论跳转
            // 为了业务逻辑的统一，在VC中去处理这个流程
            self.delegate?.didClickCommentItemInCell(self)
        default:
            break
        }
    }
}
