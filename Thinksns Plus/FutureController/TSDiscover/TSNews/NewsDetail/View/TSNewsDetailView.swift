//
//  TSNewsDetailView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 10/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯详情视图
//  用于：正常的资讯详情 + 投稿中的资讯详情
//  
/**
 注：投稿中的资讯详情视图 与 正常的资讯详情视图区别：
 1. 没有打赏相关；
 2. 没有点赞相关；
 3. 关于浏览数，可有可无。他们建议保留，但从UI和实际仅自己可见的角度来说，为了不产生别人也可见的歧义，不建议保留。
 */

import Foundation
import UIKit
import MarkdownView

protocol TSNewsDetailViewProtocol: class {
    // 打赏按钮点击响应
    func newsDetailView(_ newsDetailView: TSNewsDetailView, didClickRewardBtn rewardBtn: UIButton) -> Void
    // 打赏列表点击响应
    func didClickRewardListIn(newsDetailView: TSNewsDetailView) -> Void
}
extension TSNewsDetailViewProtocol {
    // 打赏按钮点击响应
    func newsDetailView(_ newsDetailView: TSNewsDetailView, didClickRewardBtn rewardBtn: UIButton) -> Void {
    }
    // 打赏列表点击响应
    func didClickRewardListIn(newsDetailView: TSNewsDetailView) -> Void {
    }
}

/// 资讯详情的类型
enum TSNewsDetailType {
    /// 投稿中的
    case contributing
    /// 正常的，已发布的
    case normal
}

/// 资讯详情视图
class TSNewsDetailView: UIView, TSDetailRewardListViewDelegate {

    // MARK: - Internal Property
    /// 回调响应
    weak var delegate: TSNewsDetailViewProtocol?
    /// 资讯类型
    private(set) var type: TSNewsDetailType
    /// 资讯数据模型
    private(set) var model: NewsDetailModel?

    // MARK: - Internal Function
    /// 加载数据，会返回高度，便于外界布局
    func loadModel(_ model: NewsDetailModel, complete:((_ height: CGFloat) -> Void)? = nil) -> Void {
        self.model = model
        self.setupWithModel(model, complete: complete)
    }
    /// 加载附加数据
    func loadExtraData(with newsId: Int) -> Void {
        self.loadNewsExtraData(newsId: newsId)
    }

    // MARK: - Private Property

    /// 点赞用户列表
    fileprivate var likeUserList: [TSUserInfoModel] = [TSUserInfoModel]()

    /// 资讯标题
    fileprivate weak var titleLabel: UILabel!
    /// 分类栏目
    fileprivate weak var categoryLabel: UILabel!
    /// 来源
    fileprivate weak var sourceLabel: UILabel!
    /// 点赞信息
    fileprivate weak var likeListView: TSLikedUsersView!
    /// 发布时间Label
    fileprivate weak var publishTimeLabel: UILabel!
    /// 浏览人数Label
    fileprivate weak var scanNumLabel: UILabel!
    /// 打赏按钮
    fileprivate weak var rewardBtn: UIButton!
    /// 打赏信息视图
    fileprivate weak var rewardInfoView: TSDetailRewardListView!
    /// 详情视图 - markdown
    fileprivate weak var detailView: MarkdownView!

    // 左右间距
    fileprivate let leftMargin: CGFloat = 10
    fileprivate let rightMargin: CGFloat = 10
    // topView高度
    fileprivate let titleTopH: CGFloat = 25
    fileprivate let categoryTopH: CGFloat = 10
    fileprivate let categoryH: CGFloat = 15
    fileprivate let contentTopH: CGFloat = 25
    // contentView
    fileprivate let contentTopMargin: CGFloat = 25
    fileprivate let contentBottomMargin: CGFloat = 25
    /// contentExtra
    fileprivate let contentExtraH: CGFloat = 28
    // type为contributing时的底部间距
    fileprivate let contributingBottomMargin: CGFloat = 25
    /// 顶部高度固定部分(title不固定)
    fileprivate var fixedTopH: CGFloat {
        return self.titleTopH + self.categoryTopH + self.categoryH
    }
    /// 打赏视图高度
    fileprivate var rewardViewH: CGFloat {
        return self.rewardBtnTopMargin + self.rewardBtnH + self.rewardDescTopMargin + self.rewardDescH + self.rewardListTopMargin + self.rewardListH + self.rewardListBottomMargin
    }
    fileprivate let rewardBtnTopMargin: CGFloat = 20
    fileprivate let rewardBtnH: CGFloat = 30
    fileprivate let rewardDescTopMargin: CGFloat = 6
    fileprivate let rewardDescH: CGFloat = 13
    fileprivate let rewardListTopMargin: CGFloat = 15
    fileprivate let rewardListH: CGFloat = 20
    fileprivate let rewardListBottomMargin: CGFloat = 20
    /// 固定高度
    fileprivate let separateH: CGFloat = 2
    fileprivate var fixedHeight: CGFloat {
        var fixedH: CGFloat = self.fixedTopH + self.contentTopMargin + self.contentBottomMargin + self.contentExtraH
        switch self.type {
        case .contributing:
            fixedH += self.contributingBottomMargin
        case .normal:
            fixedH += self.rewardViewH
        }
        return fixedH
    }

    // MARK: - Initialize Function
    init(type: TSNewsDetailType) {
        self.type = type
        super.init(frame: CGRect.zero)
        self.initialUI()
        self.registerNotification()
    }
    init(frame: CGRect, type: TSNewsDetailType) {
        self.type = type
        super.init(frame: frame)
        self.initialUI()
        self.registerNotification()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        self.backgroundColor = UIColor.white
        // 1. topView
        let topView = UIView()
        self.addSubview(topView)
        self.initialTopView(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self)
        }
        // 2. detailView - markdownView
        let detailView = MarkdownView()
        self.addSubview(detailView)
        detailView.isScrollEnabled = false
        detailView.onTouchLink = { [weak self] (request) in
            guard let url = request.url else {
                return false
            }
            if let parentVC = self?.parentViewController {
                TSUtil.pushURLDetail(url: url, currentVC: parentVC)
            }
            return false
        }
        detailView.snp.makeConstraints { (make) in
            // 注：由于MarkdownView自身的左右Margin导致样式变更，所以这里约束左右为self且无需额外margin
            make.leading.trailing.equalTo(self)
            make.top.equalTo(topView.snp.bottom).offset(contentTopMargin)
            make.height.equalTo(25)    // 随便写的初始高度
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
            if self.type == TSNewsDetailType.contributing {
                make.bottom.equalTo(self).offset(-contributingBottomMargin)
            }
        }
        // - 下面部分只有在已发布的
        if self.type == TSNewsDetailType.normal {
            // 4. rewardView - 打赏
            let rewardView = UIView()
            self.addSubview(rewardView)
            self.initialRewardView(rewardView)
            rewardView.snp.makeConstraints { (make) in
                make.leading.trailing.equalTo(self)
                make.bottom.equalTo(self)
                make.top.equalTo(extraView.snp.bottom)
                make.height.equalTo(self.rewardViewH)
            }
            // 5. separateView
            let separateView = UIView(bgColor: TSColor.normal.disabled)
            self.addSubview(separateView)
            separateView.snp.makeConstraints { (make) in
                make.leading.trailing.bottom.equalTo(self)
                make.height.equalTo(self.separateH)
            }
        }
    }
    /// topView布局：回答人信息、关注状态按钮
    fileprivate func initialTopView(_ topView: UIView) -> Void {
        // 1. titleLabel
        let titleLabel = UILabel(text: "", font: UIFont.boldSystemFont(ofSize: 18), textColor: TSColor.main.theme)
        topView.addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(topView).offset(leftMargin)
            make.trailing.equalTo(topView).offset(-rightMargin)
            make.top.equalTo(topView).offset(titleTopH)
            make.height.equalTo(75)
        }
        self.titleLabel = titleLabel
        // 2. categoryLabel
        let categoryLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 11), textColor: TSColor.main.theme, alignment: .center)
        topView.addSubview(categoryLabel)
        categoryLabel.layer.borderColor = TSColor.main.theme.cgColor
        categoryLabel.layer.borderWidth = 0.5
        categoryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(categoryTopH)
            make.leading.equalTo(titleLabel)
            make.height.equalTo(categoryH)
            make.width.equalTo(25)  // 这里先暂时随便写个，之后通过计算修正
            make.bottom.equalTo(topView)
        }
        self.categoryLabel = categoryLabel
        // 3. sourceLabel
        let sourceLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.disabled)
        topView.addSubview(sourceLabel)
        sourceLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(categoryLabel.snp.trailing).offset(5)
            make.centerY.equalTo(categoryLabel)
            make.trailing.equalTo(titleLabel)
        }
        self.sourceLabel = sourceLabel
    }
    /// detailExtraView 布局：点赞、发布时间、浏览人数
    fileprivate func initialDetailExtraView(_ extraView: UIView) -> Void {
        // 1. 点赞头像列表视图
        let likeListView = TSLikedUsersView(frame: CGRect.zero)
        extraView.addSubview(likeListView)
        likeListView.snp.makeConstraints { (make) in
            make.leading.equalTo(extraView).offset(self.leftMargin)
            make.centerY.equalTo(extraView)
        }
        self.likeListView = likeListView
        // 2. 发布时间Label
        let publishTimeLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.disabled, alignment: .right)
        extraView.addSubview(publishTimeLabel)
        publishTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(extraView)
            make.trailing.equalTo(extraView).offset(-self.rightMargin)
        }
        self.publishTimeLabel = publishTimeLabel
        // 3. 浏览人数Label
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

    /// 加载详情页数据
    private func setupWithModel(_ model: NewsDetailModel, complete: ((_ height: CGFloat) -> Void)? = nil) -> Void {
        // 1. topView
        self.titleLabel.text = model.title
        titleLabel.sizeToFit()
        let titleH: CGFloat = self.titleLabel.frame.size.height
        self.titleLabel.snp.updateConstraints { (make) in
            make.height.equalTo(titleH)
        }
        self.categoryLabel.text = model.categoryInfo.name
        var from = ""
        if model.from == "原创" { // 垃圾后台要求这样判断的
            from = String(format: "%@", model.author)
        } else {
            from = String(format: "来自 %@", model.from)
        }
        self.sourceLabel.text = from
        let categoryW: CGFloat = model.categoryInfo.name.size(maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), font: self.categoryLabel.font).width + 10.0
        self.categoryLabel.snp.updateConstraints { (make) in
            make.width.equalTo(categoryW)
        }
        // 3. extraInfoView
        let nsDate = NSDate(timeIntervalSince1970: model.createdDate.timeIntervalSince1970)
        let strDate = TSDate().dateString(.normal, nsDate: nsDate)
        self.publishTimeLabel.text = "发布于\(strDate)"
        self.scanNumLabel.text = TSAppConfig.share.pageViewsString(number: model.hits) +  "显示_人浏览".localized
        // 2. detailView - content
        var newContent: String = model.content_markdown
        // 摘要处理：存在摘要时则拼接展示，不存在则不再展示摘要
        let subject = model.subject
        if nil != subject && !subject!.isEmpty {
            newContent = "> **摘要** <br/>" + subject! + "<br/>\n\n" + model.content_markdown
        }
        self.detailView.load(markdown: newContent, enableImage: true)
        self.detailView.onRendered = { [unowned self] (height) in
            self.detailView.snp.updateConstraints({ (make) in
                make.height.equalTo(height)
            })
            // 回调
            let totalH: CGFloat = self.fixedHeight + height + titleH
            complete?(totalH)
        }
    }
    /// 加载附加数据：点赞列表、打赏相关
    fileprivate func loadNewsExtraData(newsId: Int) -> Void {
        TSNewsNetworkManager().rewardList(newsID: newsId, maxID: nil) { [weak self] (rewardModels, _) in
            if rewardModels != nil {
                self?.rewardInfoView.userListDataSource = rewardModels
            }
        }
        TSNewsNetworkManager().rewardCount(newsID: newsId) { [weak self] (rewardCountModel, _) in
            if let model = rewardCountModel {
                self?.rewardInfoView.rewardModel = model
            }
        }
        TSNewsNetworkManager().likeList(newsId: newsId) { [weak self] (likeUserModels, _) in
            if let likeUserModels = likeUserModels {
                var tempArray = [TSUserInfoModel]()
                for likeUser in likeUserModels {
                    tempArray.append(likeUser.userDetail)
                }
                if tempArray.isEmpty {
                    return
                }
                self?.likeUserList = tempArray
                let data = (likeCount: tempArray.count, users: tempArray)
                self?.likeListView.data = data
            }
        }

    }

    // MARK: - Private  事件响应

    /// 打赏按钮点击响应
    @objc fileprivate func rewardBtnClick(_ button: UIButton) -> Void {
        self.delegate?.newsDetailView(self, didClickRewardBtn: button)
    }

    // MARK: - Delegate Function

    // MARK: - TSDetailRewardListViewDelegate

    func tapUser() {
        self.delegate?.didClickRewardListIn(newsDetailView: self)
    }

    // MARK: - Notification

    // 注：为了兼容TSNewsDetailViewController中底部工具栏上的点赞操作，才使用TSNewsDetailHeaderViewController中的通知方式
    //    其实更合理的方案是通过底部工具栏的代理回调后，再显示调用当前视图的点赞相关方法更新信息
    fileprivate func registerNotification() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(pressNewsDetailLikeBtn), name: NSNotification.Name.News.pressNewsDetailLikeBtn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pressNewsDetailUnlikeBtn), name: NSNotification.Name.News.pressNewsDetailUnlikeBtn, object: nil)
    }
    @objc fileprivate func pressNewsDetailUnlikeBtn() {
        // 删除掉当前页面持有的数据内的用户ID为当前用户的数据
        guard let currentUser = TSCurrentUserInfo.share.userInfo else {
            return
        }
        for (index, user) in self.likeUserList.enumerated() {
            if user.userIdentity == currentUser.userIdentity {
                self.likeUserList.remove(at: index)
            }
        }
        let data = (self.likeUserList.count, self.likeUserList)
        self.likeListView.data = data
    }
    @objc fileprivate func pressNewsDetailLikeBtn() {
        // 伪造一个用户数据 用当前用户,把他加入到页面的数据中
        guard let currentUser = TSCurrentUserInfo.share.userInfo else {
            return
        }
        let user = currentUser.convert()
        self.likeUserList.insert(user, at: 0)
        let data = (self.likeUserList.count, self.likeUserList)
        self.likeListView.data = data
    }

}
