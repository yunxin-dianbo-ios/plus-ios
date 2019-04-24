//
//  TSPostCommentController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 08/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子-帖子页的评论页

import UIKit
import Kingfisher

extension Notification.Name {
    /// 帖子详情页的通知
    struct PostDetail {
        /// 帖子详情点赞
        static let Favor = NSNotification.Name(rawValue: "com.ts-plus.notification.name.postdetail.favor")
        /// 帖子详情取消赞
        static let UnFavor = NSNotification.Name(rawValue: "com.ts-plus.notification.name.postdetail.unfavor")
        /// 帖子删除
        static let Delete = NSNotification.Name(rawValue: "com.ts-plus.notification.name.postdetail.delete")
    }
}

protocol TSPostDetailControllerProtocol: class {
    func didDeletedPost(postId: Int, groupId: Int, in postDetailVC: TSPostCommentController) -> Void
}
extension TSPostDetailControllerProtocol {
    func didDeletedPost(postId: Int, groupId: Int, in postDetailVC: TSPostCommentController) -> Void {
    }
}

class TSPostCommentController: TSCommentListController {
    // MARK: - Internal Property

    /// 回调
    weak var delegate: TSPostDetailControllerProtocol?
    var postDeletedAction: ((_ postId: Int, _ groupId: Int) -> Void)?

    // MARK: - Internal Function

    // MARK: - Private Property

    /// 是否从圈子中来 - 用于来源圈子的点击响应判断
    fileprivate let fromGroupFlag: Bool

    /// 广告信息
    fileprivate var adverts: [TSAdvertObject] = []

    /// 帖子详情数据
    var detailModel: PostDetailModel?
    /// 头部控件
    fileprivate var headerView: PostDetailView?
    /// 底部工具栏
    fileprivate weak var toolBar: TSAnswerDetailToolBar!
    /// 导航栏标题
    fileprivate weak var titleView: TSIconNameTitleControl!

    /// 偏移量
    fileprivate var lastOffsetY: CGFloat = 0
    var shareImage: UIImage?

    // MARK: - Initialize Function

    init(groupId: Int, postId: Int, fromGroup: Bool = false) {
        self.fromGroupFlag = fromGroup
        super.init(type: .post, sourceId: postId, groupId: groupId, emptyType: .cell)
        // 帖子评论可以申请置顶
        self.couldTopComment = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function

    // MARK: - Override Function

    /// 请求数据
    override func requestData(_ type: TSListDataLoadType) -> Void {
        guard let groupId = self.groupId else {
            return
        }
        switch type {
        case .initial:
            self.loading()
            fallthrough
        case .refresh:
            // 请求详情页数据
            self.afterId = 0
            GroupTaskManager().getPostDetailData(postId: self.sourceId, groupId: groupId, limit: self.limit, complete: { (detailModel, commentList, msg, status, code) in
                if code == 404 {
                    self.loadFaild(type: .delete)
                    return
                }
                guard status, let detailModel = detailModel, let commentList = commentList else {
                    switch type {
                    case .initial:
                        self.loadFaild(type: .network)
                    case .refresh:
                        self.tableView.mj_header.endRefreshing()
                    default:
                        break
                    }
                    return
                }
                self.detailModel = detailModel
                self.toolBar.isFavored = detailModel.liked ? true : false
                self.sourceList = commentList
                self.cellHeightList = TSDetailCommentTableViewCell().setCommentHeight(comments: self.sourceList, width: ScreenWidth)
                self.afterId = commentList.last?.id ?? 0
                self.tableView.mj_footer.isHidden = commentList.count != self.limit
                // 导航栏
                if let user = detailModel.user {
                    self.titleView.title = user.name
                    self.titleView.iconView.avatarInfo = AvatarInfo(userModel: user)
                    self.navigationItem.rightBarButtonItem?.image = UIImage(named: user.getFollowStatus().rawValue)?.withRenderingMode(.alwaysOriginal)
                }
                // 获取广告
                let adverts = TSDatabaseManager().advert.getObjects(type: .postDetail)
                if adverts.count > 3 {
                    self.adverts = Array(adverts[0...2])
                } else {
                    self.adverts = adverts
                }
                // 加载markdown
                self.headerView?.loadModel(detailModel, complete: { (height) in
                    switch type {
                    case .initial:
                        self.endLoading()
                    case .refresh:
                        self.tableView.mj_header.endRefreshing()
                    default:
                        break
                    }
                    self.headerView?.bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: height)
                    self.commentCount = detailModel.commentsCount
                    self.tableView.reloadData()
                    self.setShareImage()
                })
            })
        case .loadmore:
            // 加载更多评论
            super.requestData(.loadmore)
        }
    }

    // MARK: - TSDetailCommentTableViewCellDelegate - 评论cell的回调
    /// 重写评论Cell中长按评论的回调
    override func didLongPressComment(in cell: TSDetailCommentTableViewCell, model: TSSimpleCommentModel) {
        // 如果本人是该圈子的管理员，则弹出删除选项，否则按照父类处理
        guard let role = self.detailModel?.group?.getRoleInfo(), let row = cell.indexPath?.row else {
            super.didLongPressComment(in: cell, model: model)
            return
        }
        switch role {
        case .master:
            fallthrough
        case .manager:
            // 弹窗删除选项
            self.showCommentDeleteAlert(commentIndex: row)
        default:
            if self.isBlack() {
                self.blackProcess()
                return
            }
            super.didLongPressComment(in: cell, model: model)
        }
    }

    func setShareImage() {
        let faceImageView = UIImageView(frame: CGRect(x: 12, y: 20, width: 50, height: 50))
        faceImageView.clipsToBounds = true
        faceImageView.layer.cornerRadius = 25
        let imageid = self.detailModel?.body.ts_getCustomMarkdownImageId()
        if !(imageid?.isEmpty)! {
            let strPrefixUrl = TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue
            let imageUrl = String(format: "%@/%d", strPrefixUrl, imageid![0])
            faceImageView.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "IMG_icon"), options: nil, progressBlock: nil) { (image, _, _, _) in
                if let image = image {
                    self.shareImage = image
                } else {
                    self.shareImage = UIImage(named: "IMG_icon")
                }
            }
        }
        self.shareImage = faceImageView.image
    }
}

// MARK: - UI加载

extension TSPostCommentController {
    override func initialUI() {
        super.initialUI()
        // navigationbar
        let titleView = TSIconNameTitleControl()
        titleView.addTarget(self, action: #selector(titleControlClick), for: .touchUpInside)
        titleView.iconView.isUserInteractionEnabled = false
        self.navigationItem.titleView = titleView
        self.titleView = titleView
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "IMG_ico_me_follow").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(rightItemClick))
        // bottomBar
        let toolBar = TSAnswerDetailToolBar()
        self.view.addSubview(toolBar)
        toolBar.delegate = self
        toolBar.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self.view)
            make.height.equalTo(TSAnswerDetailToolBar.defaultH)
        }
        self.toolBar = toolBar
        // tableView
        self.tableView.snp.remakeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.view)
            make.bottom.equalTo(toolBar.snp.top)
        }
        // tableHeaderView
        let headView = PostDetailView()
        self.tableView.tableHeaderView = headView
        headView.delegate = self
        self.headerView = headView
        let backBarItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backBtnAction(_:)))
        self.navigationItem.leftBarButtonItem = backBarItem
    }

}

// MARK: - 事件响应
extension TSPostCommentController {
    func backBtnAction(_ btn: UIButton) {
        TSUtil.popViewController(currentVC: self, animated: true)
    }
    /// 导航栏标题点击响应
    func titleControlClick() -> Void {
        guard let user = self.detailModel?.user else {
            return
        }
        let homePageVC = TSHomepageVC(user.userIdentity)
        self.navigationController?.pushViewController(homePageVC, animated: true)
    }
    /// 导航栏右侧按钮点击响应
    func rightItemClick() -> Void {
        // 用户关注 与 取消关注：
        guard let user = self.detailModel?.user else {
            return
        }
        var followOperate: TSFollowOperate
        var image: UIImage
        switch user.getFollowStatus() {
        case .oneself:
            return
        case .follow:
            followOperate = .unfollow
            image = #imageLiteral(resourceName: "IMG_ico_me_follow")
        case .eachOther:
            followOperate = .unfollow
            image = #imageLiteral(resourceName: "IMG_ico_me_follow")
        case .unfollow:
            followOperate = .follow
            image = #imageLiteral(resourceName: "IMG_ico_me_followed")
        }
        self.navigationItem.rightBarButtonItem?.image = image.withRenderingMode(.alwaysOriginal)
        TSUserNetworkingManager.followOperate(followOperate, userId: user.userIdentity) { [weak self](msg, status) in
            if status {
                self?.detailModel?.user?.follower = (followOperate == .follow)
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                // 还原
                self?.navigationItem.rightBarButtonItem?.image = UIImage(named: user.getFollowStatus().rawValue)?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
}

// MARK: - PostDetailViewProtocol
// 答案详情页的视图响应回调
extension TSPostCommentController: PostDetailViewProtocol {
    // 打赏按钮点击响应
    func postDetailView(_ postView: PostDetailView, didClickRewardBtn rewardBtn: UIButton) -> Void {
        // 黑名单用户判断处理
        if self.isBlack() {
            self.blackProcess()
            return
        }
        // 进入打赏界面
        let rewardVC = TSChoosePriceVCViewController(type: .post)
        rewardVC.sourceId = self.sourceId
        rewardVC.delegate = self
        self.navigationController?.pushViewController(rewardVC, animated: true)
    }
    // 打赏列表点击响应
    func didClickRewardListIn(postView: PostDetailView) -> Void {
        let rewardListVC = TSRewardListVC.list(type: .post)
        rewardListVC.rewardId = self.sourceId
        self.navigationController?.pushViewController(rewardListVC, animated: true)
    }
    // 点赞列表点击响应
    func didClickLikeListIn(postView: PostDetailView) -> Void {
        let likeListVC = TSLikeListTableVC(type: .post, sourceId: self.sourceId)
        self.navigationController?.pushViewController(likeListVC, animated: true)
    }
    /// 来源按钮点击响应
    func didClickSourceIn(postView: PostDetailView) -> Void {
        /// 权限判定
        if self.detailModel?.group?.joined == nil && self.detailModel?.group?.mode != "public" {
            // 未加入,圈子未公开
            // 不能进入详情
            // 进入预览页面
            let groupPreviewVC = GroupPreviewVC()
            groupPreviewVC.groupId = self.groupId!
            self.navigationController?.pushViewController(groupPreviewVC, animated: true)
            return
        }
        if self.detailModel?.group?.joined?.disabled == 1 {
            // 被拉黑
            // 不能进入详情
            TSIndicatorWindowTop.showDefaultTime(state: .faild, title: "提示信息_圈子黑名单".localized)
            return
        }
        // 如果是从圈子中进入的帖子详情，则不响应;如果是从其他地方进的帖子详情，则进入圈子详情
        if !self.fromGroupFlag, let groupId = self.groupId {
            let groupVC = GroupDetailVC(groupId: groupId)
            self.navigationController?.pushViewController(groupVC, animated: true)
        }
    }
}

// MARK: - TSChoosePriceVCDelegate

// 打赏界面打赏成功的回调
extension TSPostCommentController: TSChoosePriceVCDelegate {
    func didRewardSuccess(_ rewardModel: TSNewsRewardModel) {
        self.headerView?.addNewRewardModel(rewardModel)
    }
}

// MARK: - UITableViewDataSource

extension TSPostCommentController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // 暂时固定为2区
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount: Int = 0
        switch section {
        case 0:     // 广告
            rowCount = 1
        case 1:    // 评论
            rowCount = super.tableView(tableView, numberOfRowsInSection: section)
        default:
            break
        }
        return rowCount
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerSection: UIView? = nil
        switch section {
        case 0:     // 广告
            break
        case 1:     // 评论
            headerSection = super.tableView(tableView, viewForHeaderInSection: section)
        default:
            break
        }
        return headerSection
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:     // 广告
            // 广告Cell应该独立出来
            let identifier = "advertView"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            }
            cell!.contentView.removeAllSubviews()
            let advertView = TSAdvertNormal(itemCount:  self.adverts.count)
            advertView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: self.adverts.count == 0 ? 0 : TSNewsCommentUX.adHeight)
            advertView.set(models: self.adverts.map { TSAdvertViewModel(object: $0) })
            cell!.contentView.addSubview(advertView)
            return cell!
        default:    // 评论
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

}

// MARK: - UITableViewDelegate

extension TSPostCommentController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0
        switch indexPath.section {
        case 0:
            rowHeight = self.adverts.count == 0 ? 0 : TSNewsCommentUX.adHeight
        case 1:
            rowHeight = super.tableView(tableView, heightForRowAt: indexPath)
        default:
            break
        }
        return rowHeight
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var sectionHeight: CGFloat = 0
        switch section {
        case 0:     // 广告
            sectionHeight = self.adverts.count == 0 ? 0 : CommentCountsViewUX.top
        case 1:     // 评论
            sectionHeight = super.tableView(tableView, heightForHeaderInSection: section)
        default:
            break
        }
        return sectionHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:         // 广告
            // 广告视图自己携带了点击事件处理
            break
        case 1:         // 评论
            if self.isBlack() {
                self.blackProcess()
                return
            } else if self.isUnjoined() {
                self.unjoinedPressComment()
                return
            }
            super.tableView(tableView, didSelectRowAt: indexPath)
        default:
            break
        }
    }

}

// MARK: - TSAnswerDetailToolBarProtocol

/// 底部工具栏点击回调
extension TSPostCommentController: TSAnswerDetailToolBarProtocol {
    /// 点赞按钮点击响应
    func didClickFavorItemIn(toolBar: TSAnswerDetailToolBar) -> Void {
        if self.isBlack() {
            self.blackProcess()
            return
        } else if self.isUnjoined() {
            self.unjoinedPressFavor()
            return
        }
        toolBar.isFavored = !toolBar.isFavored
        self.postFavor()
    }
    /// 评论按钮点击响应
    func didClickCommentItemIn(toolBar: TSAnswerDetailToolBar) -> Void {
        if self.isBlack() {
            self.blackProcess()
            return
        } else if self.isUnjoined() {
            self.unjoinedPressComment()
            return
        }
        self.commentModel = nil
        self.showKeyBoard(placeHolderText: "显示_说点什么吧".localized, cell: nil)
    }
    /// 分享按钮点击响应
    func didClickShareItemIn(toolBar: TSAnswerDetailToolBar) -> Void {
        if self.isBlack() {
            self.blackProcess()
            return
        }
        self.showSharePopView()
    }
    /// 更多按钮点击响应
    func didClickMoreItemIn(toolBar: TSAnswerDetailToolBar) -> Void {
        if self.isBlack() {
            self.blackProcess()
            return
        } else if self.isUnjoined() {
            self.unjoinedProcess()
            return
        }
        self.showMorePopView()
    }
    /// 采纳按钮点击事件
    func didClickAgreeItem(toolBar: TSAnswerDetailToolBar) {

    }
}

/// 底部工具栏相关的扩展
extension TSPostCommentController {
    /// 黑名单检测
    fileprivate func isBlack() -> Bool {
        // 当前用户权限检测：黑名单用户 不可点赞 和 评论
        guard let group = self.detailModel?.group else {
            return false
        }
        return group.getRoleInfo() == .black
    }
    /// 黑名单处理
    fileprivate func blackProcess() -> Void {
        let alertVC = TSAlertController(title: "提示", message: "提示信息_圈子黑名单".localized, style: .actionsheet)
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }

    /// 管理员权限判断
    fileprivate func isManager() -> Bool {
        // 当前用户权限检测：黑名单用户 不可点赞 和 评论
        guard let group = self.detailModel?.group else {
            return false
        }
        return group.getRoleInfo() == .master || group.getRoleInfo() == .manager
    }
    /// 黑名单检测
    fileprivate func isUnjoined() -> Bool {
        // 当前用户权限检测：黑名单用户 不可点赞 和 评论
        guard let group = self.detailModel?.group else {
            return false
        }
        return group.getRoleInfo() == .unjoined
    }

    /// 未加入圈子提示
    fileprivate func unjoinedProcess() -> Void {
        let alertVC = TSAlertController(title: "提示", message: "提示信息_圈子未加入但进行了操作".localized, style: .actionsheet)
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }
    /// 未加入圈子提示
    fileprivate func unjoinedPressFavor() -> Void {
        let alertVC = TSAlertController(title: "提示", message: "提示信息_圈子未加入操作了点赞".localized, style: .actionsheet)
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }
    /// 未加入圈子提示
    fileprivate func unjoinedPressComment() -> Void {
        let alertVC = TSAlertController(title: "提示", message: "提示信息_圈子未加入操作了评论".localized, style: .actionsheet)
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }

    /// 帖子点赞
    fileprivate func postFavor() -> Void {
        // 帖子 点赞/取消赞 请求
        guard let detailModel = self.detailModel else {
            return
        }
        let favorOperate: TSFavorOperate = detailModel.liked ? TSFavorOperate.unfavor : TSFavorOperate.favor
        TSFavorNetworkManager.favorOperate(targetId: self.sourceId, targetType: .post, favorOperate: favorOperate) { (msg, status) in
            if status {
                detailModel.liked = favorOperate == TSFavorOperate.favor ? true : false
                detailModel.likesCount += favorOperate == TSFavorOperate.favor ? 1 : -1
                // 发送点赞通知
                let name = favorOperate == TSFavorOperate.favor ? NSNotification.Name.PostDetail.Favor : NSNotification.Name.PostDetail.UnFavor
                NotificationCenter.default.post(name: name, object: nil)
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                self.toolBar.isFavored = detailModel.liked ? true : false
            }
        }
    }

    /// 帖子分享 弹窗
    fileprivate func showSharePopView() -> Void {
        guard let detailModel = self.detailModel else {
            return
        }
        let messageModel = TSmessagePopModel(postDetail: detailModel)
        // 当分享内容为空时，显示默认内容
        var url = ShareURL.groupDetail.rawValue
        url.replaceAll(matching: "replacegroup", with: "\(detailModel.groupId)")
        url.replaceAll(matching: "replacepost", with: "\(detailModel.id)")
        let shareTitle = detailModel.title.count > 0 ? detailModel.title : TSAppSettingInfoModel().appDisplayName + " " + "帖子"
        var defaultContent = "默认分享内容".localized
        defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
        let shareContent = detailModel.summary.count > 0 ? detailModel.summary : defaultContent
        
        if TSCurrentUserInfo.share.userInfo?.userIdentity == detailModel.userId {
            let shareView = ShareListView(isMineSend: true, isCollection: detailModel.collected, shareType: ShareListType.groupMomentDetail)
            shareView.delegate = self
            shareView.messageModel = messageModel
            if shareImage != nil {
                shareView.show(URLString: url, image: shareImage, description: shareContent, title: shareTitle)
            } else {
                shareView.show(URLString: url, image: UIImage(named: "IMG_icon"), description: shareContent, title: shareTitle)
            }
        } else {
            let shareView = ShareListView(isMineSend: false, isCollection: detailModel.collected, shareType: ShareListType.groupMomentDetail)
            shareView.delegate = self
            shareView.messageModel = messageModel
            if shareImage != nil {
                shareView.show(URLString: url, image: shareImage, description: shareContent, title: shareTitle)
            } else {
                shareView.show(URLString: url, image: UIImage(named: "IMG_icon"), description: shareContent, title: shareTitle)
            }
        }
    }

    /// 显示更多弹窗
    fileprivate func showMorePopView() -> Void {
        /// 注：更多弹窗应提取出一个方法来，直接供代理调用
        guard let detailModel = self.detailModel, let role = detailModel.group?.getRoleInfo() else {
            return
        }
        // 未登录处理
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }

        // 收藏状态标记 - 已收藏，显示已收藏，点击则取消收藏
        let collectTitle: String = detailModel.collected ? "选择_取消收藏".localized : "选择_收藏".localized
        var customAction: TSCustomActionsheetView
        // 圈子的管理员 > 帖子发布者，即使是同一个人
        if role == .master || role == .manager {
            var titles: [String] = [String]()
            let excelletnTitle = detailModel.excellent != nil ? "撤销精华帖" : "设为精华帖"
            let pinnedTitle = detailModel.pinned ? "选择_取消置顶".localized : "选择_置顶帖子".localized
            titles.append(excelletnTitle)
            titles.append(pinnedTitle)
            titles.append(collectTitle)
            titles.append("选择_删除帖子".localized)
            customAction = TSCustomActionsheetView(titles: titles)
            customAction.tag = 250
        } else if role == .unjoined {
            // 未加入圈子，只有自己的才可以弹出删除
            if TSCurrentUserInfo.share.userInfo?.userIdentity == detailModel.userId {
                var titles: [String] = [String]()
                titles.append("选择_删除帖子".localized)
                customAction = TSCustomActionsheetView(titles: titles)
                customAction.tag = 251
            } else {
                var titles: [String] = [String]()
                titles.append(collectTitle)
                titles.append("选择_举报".localized)
                customAction = TSCustomActionsheetView(titles: titles)
                customAction.tag = 252
            }
        }
        // 帖子发布者
        else if TSCurrentUserInfo.share.userInfo?.userIdentity == detailModel.userId {
            var titles: [String] = [String]()
            // 黑名单 用户的帖子发布者 只有删除选项
            if self.isBlack() {
                titles.append("选择_删除帖子".localized)
            } else {
                titles.append("选择_申请帖子置顶".localized)
                titles.append(collectTitle)
                titles.append("选择_删除帖子".localized)
            }
            customAction = TSCustomActionsheetView(titles: titles)
            customAction.tag = 251
        }
        // 普通人：收藏
        else {
            // 黑名单
            if self.isBlack() {
                self.blackProcess()
                return
            }
            var titles: [String] = [String]()
            titles.append(collectTitle)
            titles.append("选择_举报".localized)
            customAction = TSCustomActionsheetView(titles: titles)
            customAction.tag = 252
        }
        customAction.delegate = self
        customAction.show()
    }
}

// MARK: - TSCustomAcionSheetDelegate

/// 选择弹窗的回调处理
extension TSPostCommentController: TSCustomAcionSheetDelegate {
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        // 根据标题 统一处理
        switch title {
        case "选择_删除帖子".localized:
            // 管理员 与 自己 都有删除的二次弹窗确认
            self.showPostDeleteConfirmAlert()
        case "选择_收藏".localized:
            self.postCollectOperate(.collect)
        case "选择_取消收藏".localized:
            self.postCollectOperate(.uncollect)
        case "选择_举报".localized:
            self.reportPost()
        case "选择_申请帖子置顶".localized:
            self.selfTopPostApplication()
        case "选择_置顶帖子".localized:
            self.showTopPostPopView()
        case "选择_取消置顶".localized:
            self.managerCancelPostTop()
        case "撤销精华帖":
            self.managerSetOrCancelPostExcellent(isCancel:true)
        case "设为精华帖":
            self.managerSetOrCancelPostExcellent(isCancel:false)
        default:
            break
        }
    }

}

// 弹窗相关的扩展处理
extension TSPostCommentController {

    /// 帖子删除弹窗 - 用于二次弹窗确认
    fileprivate func showPostDeleteConfirmAlert() -> Void {
        let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "删除帖子") {
            self.deletePost()
        }
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }

    /// 弹出评论删除选项弹窗
    func showCommentDeleteAlert(commentIndex: Int) -> Void {
        let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
        alertVC.addAction(TSAlertAction(title: "选择_删除".localized, style: .default, handler: { (action) in
            self.showCommentDeleteConfirmAlert(commentIndex: commentIndex)
        }))
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
    }

    /// 帖子删除
    fileprivate func deletePost() -> Void {
        guard let groupId = self.groupId else {
            return
        }
        let postId = self.sourceId
        GroupNetworkManager.delete(post: postId, groupId: groupId) { (status) in
            if status {
                let alert = TSIndicatorWindowTop(state: .success, title: "删除成功!")
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                    self.delegate?.didDeletedPost(postId: postId, groupId: groupId, in: self)
                    self.postDeletedAction?(postId, groupId)
                    let userInfo = ["postId": postId, "groupId": groupId]
                    NotificationCenter.default.post(name: NSNotification.Name.PostDetail.Delete, object: userInfo)
                    _ = self.navigationController?.popViewController(animated: true)
                })
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: "删除失败!")
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }

    /// 帖子收藏 或 取消收藏
    fileprivate func postCollectOperate(_ collectOperate: TSCollectOperate) -> Void {
        TSCollectNetworkManager.collectOperate(targetId: self.sourceId, targetType: .post, collectOperate: collectOperate) { (msg, status) in
            if status {
                self.detailModel?.collected = collectOperate == .collect ? true : false
                let alert = TSIndicatorWindowTop(state: .success, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            } else {
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }
    }

    /// 帖子举报
    fileprivate func reportPost() -> Void {
        guard let model = self.detailModel, let user = self.detailModel?.user else {
            return
        }
        // 进入举报界面
        let reportType = ReportTargetType.Post(groupId: model.groupId)
        let reportTarget = ReportTargetModel(targetId: self.sourceId, sourceUser: user, type: reportType, imageUrl: nil, title: model.title, body: model.summary)
        let reportVC = ReportViewController(reportTarget: reportTarget)
        self.navigationController?.pushViewController(reportVC, animated: true)
    }

    /// 帖子置顶申请
    fileprivate func selfTopPostApplication() -> Void {
        let topVC = TSTopAppilicationManager.postTopVC(postId: self.sourceId)
        self.navigationController?.pushViewController(topVC, animated: true)
    }

    /// 显示置顶帖子弹窗(用于管理员直接置顶时天数选择)
    fileprivate func showTopPostPopView() -> Void {
        let alert = TSAlertController(title: "设置帖子置顶天数", message: nil, style: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "可选范围1~30天"
            textField.keyboardType = .numberPad
        })
        alert.addAction(TSAlertAction(title: "取消", style: .theme, handler: { (action) in
        }))
        alert.addAction(TSAlertAction(title: "确定", style: .theme, handler: { (action) in
            let textField = alert.textFields?.first
            let topDay = Int(textField?.text ?? "")
            if let day = topDay, (day > 0 && day < 31) {
               self.managerTopPost(day: day)
            } else {
                let resultAlert = TSIndicatorWindowTop(state: .faild, title: "请输入正确的天数，可以选择置顶 1 ~ 30 天")
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }))
        self.parent?.present(alert, animated: false, completion: nil)
   }
    /// 管理员置顶帖子
    fileprivate func managerTopPost(day: Int) -> Void {
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "置顶中...")
        loadingAlert.show()
        GroupNetworkManager.managerTopPost(postId: self.sourceId, day: day, complete: { [weak self](status, message) in
            loadingAlert.dismiss()
            let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message ?? "置顶成功")
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            if status {
                self?.detailModel?.pinned = true
            }
        })
    }

    /// 取消帖子置顶
    fileprivate func managerCancelPostTop() -> Void {
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "撤销中...")
        loadingAlert.show()
        GroupNetworkManager.managerCancelTopPost(postId: self.sourceId, complete: { (status, message) in
            loadingAlert.dismiss()
            let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message ?? "取消成功")
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            if status {
                self.detailModel?.pinned = false
            }
        })
    }

    /// 设置或取消帖子加精
    fileprivate func  managerSetOrCancelPostExcellent(isCancel: Bool) -> Void {
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "加载中...")
        loadingAlert.show()
        GroupNetworkManager.managerSetOrCancelPost(postId: self.sourceId, complete: { (status, message) in
            loadingAlert.dismiss()
            let tmpMsg = isCancel ? "撤销成功" : "设置成功"
            let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message ?? tmpMsg)
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            if status {
                if isCancel {
                 self.detailModel?.excellent = nil
                } else {
                self.detailModel?.excellent = TSDate().dateString(.normal, nsDate: Date() as NSDate)
                }
            }
        })
    }
}

extension TSPostCommentController: ShareListViewDelegate {
    func didClickSetTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickCancelTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickSetExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickCancelExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
    }

    func didClickMessageButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, model: TSmessagePopModel) {
        let messageModel = model
        if (self.headerView?.imageArray.isEmpty)! {
            messageModel.contentType = .postText
        } else {
            messageModel.contentType = .postPic
            messageModel.coverImage = (self.headerView?.imageArray[0])!
        }
        let chooseFriendVC = TSPopMessageFriendList(model: messageModel)
        self.navigationController?.pushViewController(chooseFriendVC, animated: true)
    }

    func didClickReportButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {

    }

    func didClickCollectionButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {

    }

    func didClickDeleteButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {

    }

    func didClickRepostButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {
        let repostModel = TSRepostModel.coverGroupPostDetailModel(groupPostDetailModel: self.detailModel!)
        let releaseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: true)
        releaseVC.repostModel = repostModel
        let navigation = TSNavigationController(rootViewController: releaseVC)
        self.present(navigation, animated: true, completion: nil)
    }

    func didClickApplyTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {

    }
}
