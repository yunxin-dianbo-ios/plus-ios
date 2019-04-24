//
//  TSAnswerDetailView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 11/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  答案详情页的头视图 —— 答案详情部分

import UIKit
import MarkdownView
import SnapKit

protocol TSAnswerDetailViewProtocol: class {
    // 关注状态按钮点击响应 
    func answerView(_ answerView: TSAnswerDetailView, didClickFollowControl followControl: TSFollowControl) -> Void
    // 打赏按钮点击响应
    func answerView(_ answerView: TSAnswerDetailView, didClickRewardBtn rewardBtn: UIButton) -> Void
    // 打赏列表点击响应
    func didClickRewardListIn(answerView: TSAnswerDetailView) -> Void
    // 点赞列表点击响应
    func didClickLikeListIn(answerView: TSAnswerDetailView) -> Void
}

class TSAnswerDetailView: UIView, TSDetailRewardListViewDelegate {

    // MARK: - Internal Property

    /// 回调响应
    weak var delegate: TSAnswerDetailViewProtocol?
    /// 数据模型
    private(set) var model: TSAnswerDetailModel?

    // MARK: - Internal Function
    /// 加载数据，会返回高度，便于外界布局
    func loadModel(_ model: TSAnswerDetailModel, complete:((_ height: CGFloat) -> Void)? = nil) -> Void {
        self.model = model
        self.setupWithModel(model, complete: complete)
    }
    /// 加载打赏信息
    func loadRewardInfo(with model: TSAnswerDetailModel) -> Void {
        self.setupRewardInfo(with: model)
    }
    /// 加载点赞信息
    func loadFavorInfo(with model: TSAnswerDetailModel) -> Void {
        self.setupFavorInfo(with: model)
    }
    /// 加载常规数据(不含content)
    func loadNormalData(with model: TSAnswerDetailModel) -> Void {
        self.setupNormalData(with: model)
    }

    // MARK: - Private Property

    /// 头像视图
    fileprivate weak var userBtn: AvatarView!
    /// 匿名视图
    fileprivate weak var anonymousView: UIView!
    /// 姓名
    fileprivate weak var nameLabel: UILabel!
    /// 描述
    fileprivate weak var descLabel: UILabel!
    /// 关注按钮
    fileprivate weak var followControl: TSFollowControl!
    /// 点赞信息
    fileprivate weak var likeListView: TSLikedUsersView!

    /// 发布时间Label
    fileprivate weak var publishTimeLabel: UILabel!
    /// 浏览人数Label
    fileprivate weak var scanNumLabel: UILabel!
    /// 打赏按钮
    fileprivate weak var rewardBtn: UIButton!
    /// 打赏信息视图
    fileprivate var rewardInfoView: TSDetailRewardListView!

    /// 顶部高度
    fileprivate let topH: CGFloat = 60
    fileprivate let contentTopMargin: CGFloat = 15
    fileprivate let contentBottomMargin: CGFloat = 15
    /// 内容附加信息高度
    fileprivate let contentExtraH: CGFloat = 28
    /// 打赏视图高度
    fileprivate var rewardViewH: CGFloat {
        if TSAppConfig.share.localInfo.isOpenReward == true {
            return self.rewardBtnTopMargin + self.rewardBtnH + self.rewardDescTopMargin + self.rewardDescH + self.rewardListTopMargin + self.rewardListH + self.rewardListBottomMargin
        }
        return 0
    }
    fileprivate let rewardBtnTopMargin: CGFloat = 20
    fileprivate let rewardBtnH: CGFloat = 30
    fileprivate let rewardDescTopMargin: CGFloat = 6
    fileprivate let rewardDescH: CGFloat = 13
    fileprivate let rewardListTopMargin: CGFloat = 15
    fileprivate let rewardListH: CGFloat = 20
    fileprivate let rewardListBottomMargin: CGFloat = 20
    /// 固定高度
    fileprivate let separateH: CGFloat = 5
    fileprivate var fixedHeight: CGFloat {
        return self.topH + self.contentTopMargin + self.contentBottomMargin + self.contentExtraH + self.rewardViewH + self.separateH
    }
    /// detailView - markdownView
    fileprivate weak var detailView: MarkdownView!
    fileprivate let leftMargin: CGFloat = 15
    fileprivate let rightMargin: CGFloat = 15
    // 图片数组
    fileprivate var imageArray: [String] = []
    // 当前查看的图片链接
    var currentImgStr: String?

    // MARK: - Initialize Function
    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    fileprivate func initialUI() -> Void {
        self.backgroundColor = UIColor.white
        // 1. topView
        let topView = UIView()
        self.addSubview(topView)
        self.initialTopView(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self)
            make.height.equalTo(self.topH)
        }
        // 2. detailView - markdownView
        let detailView = MarkdownView()
        self.addSubview(detailView)
        detailView.isScrollEnabled = false
        detailView.snp.makeConstraints { (make) in
            // 注：由于MarkdownView自身的左右Margin导致样式变更，所以这里约束左右为self或更改contentView的约束
            make.leading.trailing.equalTo(self)
            make.top.equalTo(topView.snp.bottom).offset(contentTopMargin)
            make.height.equalTo(20)    // 随便写的初始高度
        }
        self.detailView = detailView
        // 3. detailExtraView
        let extraView = UIView()
        self.addSubview(extraView)
        self.initialDetailExtraView(extraView)
        extraView.snp.makeConstraints { (make) in
            make.top.equalTo(detailView.snp.bottom).offset(self.contentBottomMargin)
            make.leading.trailing.equalTo(self)
            make.height.equalTo(self.contentExtraH)
        }
        // 4. rewardView - 打赏
        if TSAppConfig.share.localInfo.isOpenReward == true {
            let rewardView = UIView()
            self.addSubview(rewardView)
            self.initialRewardView(rewardView)
            rewardView.snp.makeConstraints { (make) in
                make.leading.trailing.equalTo(self)
                make.bottom.equalTo(self)
                make.top.equalTo(extraView.snp.bottom)
                make.height.equalTo(self.rewardViewH)
            }
        } else {
            let rewardBtn = UIButton(cornerRadius: 3)
            self.rewardBtn = rewardBtn

            let rewardInfoView = TSDetailRewardListView(frame: CGRect.zero)
            self.rewardInfoView = rewardInfoView
        }
        // 5. separateView
        let separateView = UIView(bgColor: TSColor.inconspicuous.background)
        self.addSubview(separateView)
        separateView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self)
            make.height.equalTo(self.separateH)
        }
    }
    /// topView布局：回答人信息、关注状态按钮
    fileprivate func initialTopView(_ topView: UIView) -> Void {
        let iconWH: CGFloat = 38
        let nameLeftMargin: CGFloat = 15
        // 1. iconView
        let iconBtn = AvatarView(type: AvatarType.width38(showBorderLine: false))
        topView.addSubview(iconBtn)
        iconBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(topView)
            make.leading.equalTo(topView).offset(leftMargin)
            make.width.height.equalTo(iconWH)
        }
        self.userBtn = iconBtn
        // 1.1 anonymousView
        // TODO: - 匿名视图 应提取出来，待完成
        let anonymousView = UIView(cornerRadius: iconWH * 0.5)
        topView.addSubview(anonymousView)
        anonymousView.backgroundColor = TSColor.normal.disabled
        anonymousView.isHidden = true   // 默认隐藏
        anonymousView.snp.makeConstraints { (make) in
            make.edges.equalTo(iconBtn)
        }
        let iconAnonymousLabel = UILabel(text: "匿", font: UIFont.systemFont(ofSize: 14), textColor: UIColor.white, alignment: .center)
        anonymousView.addSubview(iconAnonymousLabel)
        iconAnonymousLabel.snp.makeConstraints { (make) in
            make.center.equalTo(anonymousView)
        }
        self.anonymousView = anonymousView
        // 4. followBtn
        let followControl = TSFollowControl()
        topView.addSubview(followControl)
        followControl.addTarget(self, action: #selector(followControlClick(_:)), for: .touchUpInside)
        followControl.snp.makeConstraints { (make) in
            make.centerY.equalTo(topView)
            make.trailing.equalTo(topView).offset(-self.rightMargin)
            make.height.equalTo(followControl.defaultH)
            make.width.equalTo(followControl.minW)
        }
        self.followControl = followControl
        // 2. nameLabel
        let nameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: TSColor.main.content)
        topView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(iconBtn.snp.trailing).offset(nameLeftMargin)
            make.top.equalTo(iconBtn)
        }
        self.nameLabel = nameLabel
        // 3. descLabel
        let descLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.minor)
        topView.addSubview(descLabel)
        descLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(iconBtn)
            make.leading.equalTo(iconBtn.snp.trailing).offset(nameLeftMargin)
            make.trailing.equalTo(followControl.snp.leading).offset(-10)
        }
        self.descLabel = descLabel
        // 5. bottomLine
        topView.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)

        // test 
        nameLabel.text = "Name"
        descLabel.text = "Description"
    }
    /// detailExtraView 布局：点赞、发布时间、浏览人数
    fileprivate func initialDetailExtraView(_ extraView: UIView) -> Void {
        // 1. 点赞头像列表视图
        let likeListView = TSLikedUsersView(frame: CGRect.zero)
        extraView.addSubview(likeListView)
        likeListView.addTarget(self, action: #selector(likeListClick(_:)), for: .touchUpInside)
        likeListView.isHidden = true    // 默认隐藏(内部不能自适应，有大小约束)
        likeListView.snp.makeConstraints { (make) in
            make.leading.equalTo(extraView).offset(self.leftMargin)
            make.top.bottom.equalTo(extraView)
            make.trailing.equalTo(extraView.snp.centerX).offset(50)
        }
        self.likeListView = likeListView
        // 3. 发布时间Label
        let publishTimeLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.disabled, alignment: .right)
        extraView.addSubview(publishTimeLabel)
        publishTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(extraView)
            make.trailing.equalTo(extraView).offset(-self.rightMargin)
        }
        self.publishTimeLabel = publishTimeLabel
        // 4. 浏览人数Label
        let scanNumLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.disabled, alignment: .right)
        extraView.addSubview(scanNumLabel)
        scanNumLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(extraView)
            make.trailing.equalTo(publishTimeLabel)
        }
        self.scanNumLabel = scanNumLabel
    }
    /// rewardView布局：打赏视图布局
    fileprivate func initialRewardView(_ rewardView: UIView) -> Void {
        // 1. 打赏按钮
        let rewardBtn = UIButton(cornerRadius: 3)
        rewardView.addSubview(rewardBtn)
        rewardBtn.setTitle("显示_打赏".localized, for: .normal)
        rewardBtn.setTitleColor(UIColor.white, for: .normal)
        rewardBtn.backgroundColor = UIColor(hex: 0xf76c69)
        rewardBtn.addTarget(self, action: #selector(rewardBtnClick(_:)), for: .touchUpInside)
        rewardBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(rewardView)
            make.width.equalTo(80)
            make.height.equalTo(self.rewardBtnH)
            make.top.equalTo(rewardView).offset(self.rewardBtnTopMargin)
        }
        self.rewardBtn = rewardBtn
        // 2. 打赏信息
        let rewardInfoView = TSDetailRewardListView(frame: CGRect.zero)
        rewardView.addSubview(rewardInfoView)
        rewardInfoView.delegate = self
        rewardInfoView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(rewardView)
            make.top.equalTo(rewardBtn.snp.bottom)
        }
        self.rewardInfoView = rewardInfoView
    }

    // MARK: - Private  数据加载

    /// 加载打赏信息
    private func setupRewardInfo(with model: TSAnswerDetailModel) -> Void {
        let rewardModel = TSNewsRewardCountModel()
        rewardModel.count = model.rewardersCount
        rewardModel.amount = String(format: "%.2f", model.rewardsAmount)
        self.rewardInfoView.rewardModel = rewardModel
        self.rewardInfoView.userListDataSource = model.rewarders
    }
    /// 加载点赞信息
    private func setupFavorInfo(with model: TSAnswerDetailModel) -> Void {
        if let likedList = model.likes {
            var users = [TSUserInfoModel]()
            for like in likedList {
                users.append(like.userDetail)
            }
            self.likeListView.data = (likeCount: model.likesCount, users: users)
            self.likeListView.isHidden = users.isEmpty
        }
    }
    /// 加载除content之外的信息
    private func setupNormalData(with model: TSAnswerDetailModel) -> Void {
        fatalError("setupNormalData 待完成")
        // 待完成，可考虑将下面setupWithModel中的部分放置到这里来
    }
    /// 加载详情页数据
    private func setupWithModel(_ model: TSAnswerDetailModel?, complete: ((_ height: CGFloat) -> Void)? = nil) -> Void {
        guard let model = model else {
            return
        }
        // 1. userInfo
        if model.isAnonymity {
            // 匿名时展示
            self.followControl.isHidden = true
            if TSCurrentUserInfo.share.isLogin && model.userId == TSCurrentUserInfo.share.userInfo?.userIdentity {
                // 匿名发布者 自己查看
                self.anonymousView.isHidden = true
                self.userBtn.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: (model.user?.sex ?? 0))
                var avatarInfo = AvatarInfo()
                avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile:model.user?.avatar)
                if let user = model.user {
                    avatarInfo = AvatarInfo(userModel: user)
                }
                avatarInfo.type = .normal(userId: model.userId)
                self.userBtn.avatarInfo = avatarInfo
                self.descLabel.text = model.user?.shortDesc()
                let nameFont = self.nameLabel.font!
                let attNmae = NSMutableAttributedString(str: model.user!.name, font: nameFont, color: self.nameLabel.textColor)
                attNmae.append(NSMutableAttributedString(str: "(匿名)", font: nameFont, color: TSColor.normal.secondary))
                self.nameLabel.attributedText = attNmae
            } else {
                self.anonymousView.isHidden = false
                self.descLabel.text = nil
                self.nameLabel.text = "匿名用户"
                // 匿名用户居中
                self.nameLabel.snp.remakeConstraints({ (make) in
                    make.leading.equalTo(self.descLabel)
                    make.centerY.equalTo(self.userBtn)
                })
            }
        } else {
            // 正常展示
            self.anonymousView.isHidden = true
            self.userBtn.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: (model.user?.sex ?? 0))
            var avatarInfo = AvatarInfo()
            avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile:model.user?.avatar)
            if let user = model.user {
                avatarInfo = AvatarInfo(userModel: user)
            }
            avatarInfo.type = .normal(userId: model.userId)
            self.userBtn.avatarInfo = avatarInfo
            self.nameLabel.text = model.user?.name
            self.descLabel.text = model.user?.shortDesc()
            self.followControl.isHidden = model.userId == TSCurrentUserInfo.share.userInfo?.userIdentity
            self.followControl.isSelected = (true == model.user?.follower) ? true : false
        }
        // 2. contentExtraInfo
        // 点赞用户列表
        self.setupFavorInfo(with: model)
        // 点赞右侧：发布时间 + 浏览人数
        if let date = model.createDate {
            let nsDate = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
            let strDate = TSDate().dateString(.normal, nsDate: nsDate)
            self.publishTimeLabel.text = "发布于\(strDate)"
        }
        self.scanNumLabel.text = "\(TSAppConfig.share.pageViewsString(number: model.viewsCount))人浏览"
        // 3. rewardInfo
        self.setupRewardInfo(with: model)
        // 4. content
        // 注入查看图片相关的js
        let getImagesJSString =
        """
            function getImages(){
            var objs = document.getElementsByTagName(\"img\");
            var imgScr = '';
            for(var i=0;i<objs.length;i++) {
            if (i == 0){
              imgScr = objs[i].src;
            } else {
               imgScr = imgScr +'***'+ objs[i].src;
            }
            }
             return imgScr;
            }
            """
        let imageClickJSString =
        """
         function registerImageClickAction(){
        var imgs = document.getElementsByTagName('img')
           for(var i=0;i<imgs.length;i++){
            imgs[i].customIndex = i;
             imgs[i].onclick=function() {
            window.location.href='TSimage:'+this.src;
         }
        }
        }
       """
        self.detailView.load(markdown: model.body.ts_customMarkdownToStandard(), enableImage: true)
        self.detailView.onRendered = { [unowned self] (height) in
            self.detailView.snp.updateConstraints({ (make) in
                make.height.equalTo(height)
            })
            // 回调
            let totalH: CGFloat = self.fixedHeight + height
            complete?(totalH)
            self.detailView.webView?.evaluateJavaScript(imageClickJSString, completionHandler: nil)
            self.detailView.webView?.evaluateJavaScript(getImagesJSString, completionHandler: nil)
            self.detailView.webView?.evaluateJavaScript("registerImageClickAction();", completionHandler: nil)
            self.detailView.webView?.evaluateJavaScript("getImages()", completionHandler: { (image, error) in
                if error == nil {
                    if let  image = image as? NSString {
                        let array: [String] =   image.components(separatedBy: "***")
                        self.imageArray = array
                    }
                }
            })
        }
        detailView.onTouchLink = { [weak self] (request) in
            guard let url = request.url else {
                return false
            }
            if let parentVC = self?.parentViewController {
                TSUtil.pushURLDetail(url: url, currentVC: parentVC)
            }
            return false
        }
        detailView.onTouchClick = {[weak self] (url) in
            let string: NSString = NSString(string: url)
            self?.currentImgStr = string.substring(from: 8)
            self?.previewPicture()
        }
    }

    // MARK: - Private  事件响应
    fileprivate func previewPicture() -> Void {
        var currentIndex: Int = 0
        var objectArray: [TSImageObject] = []
        for section in 0..<imageArray.count {
            let path = String(describing: imageArray[section])
            if path == self.currentImgStr {
                currentIndex = section
            }
            let object = TSImageObject()
            let subIndex = (TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue as NSString).length
            if let fileId = Int((path as NSString).substring(from: subIndex + 1)) {
                object.storageIdentity = fileId
            }
            object.cacheKey = ""
            object.mimeType = "image/jpeg"
            objectArray.append(object)
        }
        let picturePreview = TSPicturePreviewVC(objects: objectArray, imageFrames: [], images: [], At: currentIndex)
        picturePreview.show()
    }
    /// 关注状态按钮点击响应
    @objc fileprivate func followControlClick(_ control: TSFollowControl) -> Void {
        self.delegate?.answerView(self, didClickFollowControl: control)
    }
    /// 打赏按钮点击响应
    @objc fileprivate func rewardBtnClick(_ button: UIButton) -> Void {
        self.delegate?.answerView(self, didClickRewardBtn: button)
    }
    /// 点赞列表点击响应
    @objc fileprivate func likeListClick(_ control: UIControl) -> Void {
        self.delegate?.didClickLikeListIn(answerView: self)
    }

    // MARK: - Delegate Function

    // MARK: - TSDetailRewardListViewDelegate

    func tapUser() {
        self.delegate?.didClickRewardListIn(answerView: self)
    }

}
