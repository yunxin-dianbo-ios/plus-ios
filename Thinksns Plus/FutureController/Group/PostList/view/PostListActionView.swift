//
//  PostListActionView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/28.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class PostListActionView: FeedListView {

    /// 圈子 id
    var groupId: Int?
    /// 当前用户在圈子中的角色
    var role: GroupManagerType?
    /// 是否来自圈子标记，用于进入帖子详情时使用(本视图被多处使用，而进入帖子详情页需要该参数)
    var fromGroupFlag: Bool = false

    /// 创建新评论需要用到的信息
    ///
    /// - (feedIndexPath, feedId, replyId, replyName)
    var newCommentInfo: (IndexPath, Int, Int?, String?)?

    /// 评论编辑弹框需要用的属性（大概是这样）
    var yAxis: CGFloat = 0
    /// 是否是联合滚动的子视图
    var isUnionChildTable: Bool = false
    /// 主视图是否可以滚动
    var curentTabCanScroll: Bool = false {
        didSet {
            if curentTabCanScroll == false {
                self.contentOffset = .zero
            }
        }
    }
    /// 是否正在请求数据
    var isRequestList: Bool = false
    // 精华帖列表不显示精子
    override func isNeedShowPostExcellent() -> Bool {
        return self.tableIdentifier != "recommendTable"
    }

    override func setUI() {
        super.setUI()
        interactDelegate = self
    }
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        TSLogCenter.log.debug(scrollView.contentOffset)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideReleaseButton"), object: nil)
        self.perform(#selector(scrollViewDidEndScrollingAnimation), with: nil, afterDelay: 0.000_01)
        scrollDelegate?.scrollViewDidScroll(scrollView)
        /// 如果当前的视图作为联合滚动的table才走以下逻辑
        if isUnionChildTable {
            if curentTabCanScroll == false {
                scrollView.contentOffset = .zero
            }
            if scrollView.contentOffset.y <= 0 {
                curentTabCanScroll = false
                scrollView.contentOffset = .zero
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leaveTop"), object: nil)
            }
        }
    }
}

// MARK: - FeedListViewDelegate: 用户交互事件代理
extension PostListActionView: FeedListViewDelegate {

    /// 点击了帖子 cell
    func feedList(_ view: FeedListView, didSelected cell: FeedListCell, onSeeAllButton: Bool) {
        // 如果是游客模式，触发登录注册操作
        if TSCurrentUserInfo.share.isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        TSKeyboardToolbar.share.keyboarddisappear()

        let indexPath = view.indexPath(for: cell)!
        let model = cell.model
        switch model.id {
        // 1.如果是广告，跳转广告页面
        case .advert(_, let link):
            TSAdvertTaskQueue.showDetailVC(urlString: link)
        // 2.如果是圈子帖子
        case .post(gourpId: let groupId, postId: let postId):
            pushToPostDetailVC(groupId: groupId, postId: postId, model: model, indexPath: indexPath, isTapMore: false)
            break
        default:
            break
        }
    }

    /// 点击了图片
    func feedList(_ view: FeedListView, didSelected  cell: FeedListCell, on pictureView: PicturesTrellisView, withPictureIndex index: Int) {
        // 1.如果是游客模式，触发登录注册操作
        if TSCurrentUserInfo.share.isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }

        TSKeyboardToolbar.share.keyboarddisappear()
        // 解析一下图片的数据
        let imageModels = pictureView.models
        let imageModel = imageModels[index]

        // 2.如果图片为查看付费，显示购买弹窗
        if let paidInfo = imageModel.paidInfo, let imageUrl = imageModel.url, paidInfo.type == .pictureSee {
            PaidManager.showPaidPicAlert(imageUrl: imageUrl, paidInfo: paidInfo, complete: { [weak self] in
                self?.reloadData()
            })
            return
        }

        // 3.如果以上情况都没有发生，就跳转图片查看器
        let imageFrames = pictureView.frames
        let images = pictureView.pictures
        let imageObjects = imageModels.map { $0.imageObject() }
        let picturePreview = TSPicturePreviewVC(objects: Array(imageObjects), imageFrames: imageFrames, images: images, At: index)
        picturePreview.show()
    }

    /// 点击了工具栏
    func feedList(_ view: FeedListView, didSelected cell: FeedListCell, on toolbar: TSToolbarView, withToolbarButtonIndex index: Int) {
        let postIndexPath = view.indexPath(for: cell)!
        let model = cell.model
            // 可能是收藏列表/自己的帖子列表等列表中没有这个role信息
            // 需要从cell.model中获取
            /// 角色 member-普通成员 administrator - 管理者 founder - 创建者
            if model.role == "member" {
                role = GroupManagerType.member
            } else if model.role == "administrator" {
                role = GroupManagerType.manager
            } else if model.role == "founder"{
                role = GroupManagerType.master
            }
        // 如果是游客模式，触发登录注册操作
        if TSCurrentUserInfo.share.isLogin == false && index != 3 {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }

        guard let groupId = model.id["groupId"], let postId = model.id["postId"], let toolModel = model.toolModel else {
            return
        }
        self.groupId = groupId
        // 点赞
        if index == 0 {
            // 如果当前用户在黑名单，则不能执行操作
            // 如果不是圈子成员，则不能操作
            if role == .black {
                self.blackProcess()
                return
            }
            // 发起网络请求
            if toolModel.isDigg {
                // 取消点赞
                GroupNetworkManager.undiggPost(postId: postId, complete: { (_) in
                })
            } else {
                // 点赞
                GroupNetworkManager.diggPost(postId: postId, complete: { (_) in
                })
            }
            // 刷新界面
            model.toolModel?.isDigg = !toolModel.isDigg
            let diggCount = toolModel.diggCount
            model.toolModel?.diggCount = toolModel.isDigg ? diggCount + 1 : diggCount - 1
            reloadRow(at: postIndexPath, with: .none)
        }
        // 评论
        if index == 1 {
            // 如果当前用户在黑名单，则不能执行操作
            // 如果不是圈子成员，则不能操作
            if role == .black {
                self.blackProcess()
                return
            } else if role == .unjoined || role == nil {
                self.unjoinedPressComment()
                return
            }
            // 记录点击的位置信息
            newCommentInfo = (postIndexPath, postId, nil, nil)
            setTSKeyboard(placeholderText: "随便说说~", feedCell: cell)
        }
        if index == 3 {
            // 如果是黑名单用户，则仅进行删除操作
            guard role != .black else {
                if model.userId == TSCurrentUserInfo.share.userInfo?.userIdentity {
                    let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
                    alert.addAction(deletePostAction(groupId: groupId, postId: postId, postIndexPath: postIndexPath))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
                } else {
                    self.blackProcess()
                }
                return
            }
            // 下面是初步初始化新版分享视图（杂七杂八的权限判断看的头晕）
            if model.sendStatus == .success {
                let messageModel = TSmessagePopModel(postMomentModel: model)
                // 当分享内容为空时，显示默认内容
                let image = (cell.picturesView.pictures.first ?? nil) ?? UIImage(named: "IMG_icon")
                let title = TSAppSettingInfoModel().appDisplayName + " " + "帖子"
                var defaultContent = "默认分享内容".localized
                defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
                let description = model.content.isEmpty ? defaultContent : model.content
                var url = ShareURL.groupDetail.rawValue
                url.replaceAll(matching: "replacepost", with: "\(postId)")
                url.replaceAll(matching: "replacegroup", with: "\(groupId)")

                let shareView = ShareListView(shareType: ShareListType.groupDetail)
                shareView.isMine = model.userId == TSCurrentUserInfo.share.userInfo?.userIdentity
                shareView.isOwner = role == .master
                shareView.isManager = role == .manager
                shareView.isCollect = toolModel.isCollect
                shareView.isExcellent = model.excellent != nil
                shareView.isTop = model.showPostTopIcon
                shareView.setUI()
                shareView.delegate = self
                shareView.messageModel = messageModel
                shareView.feedIndex = postIndexPath
                shareView.show(URLString: url, image: image, description: description, title: title)
            } else {
                let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
                alert.addAction(deletePostAction(groupId: groupId, postId: postId, postIndexPath: postIndexPath))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
            }
        }
    }

    /// 点击了评论行
    func feedList(_ view: FeedListView, didSelected cell: FeedListCell, on commentView: FeedCommentListView, withCommentIndexPath commentIndexPath: IndexPath) {
        let postIndexPath = view.indexPath(for: cell)!

        // 如果是游客模式，触发登录注册操作
        if TSCurrentUserInfo.share.isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }

        // 获取评论信息
        let model = commentView.datas[commentIndexPath.row]
        guard let postId = model.id["postId"], let commentId = model.id["commentId"] else {
            return
        }
        // 0.如果当前用户已经退出该圈子，只能删除
        guard role != nil else {
            if model.userId == TSCurrentUserInfo.share.userInfo?.userIdentity {
                let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
                // 添加删除选项
                alert.addAction(deletePostAction(commentId: commentId, postId: postId, commentIndexPath: commentIndexPath, postIndexPath: postIndexPath))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
                return
            } else {
                self.unjoinedPressComment()
                return
            }
        }

        // 1 如果是当前用户自己的评论，则显示弹窗
        if model.userId == TSCurrentUserInfo.share.userInfo?.userIdentity {
            let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)

            //  1.2如果是发送成功的评论，并且当前用户不是黑名单用户，添加置顶选项
            if model.sendStatus == .success && role != .black {
                alert.addAction(topCommentAction(commentId: commentId))
            }
            // 1.1 添加删除选项
            alert.addAction(deletePostAction(commentId: commentId, postId: postId, commentIndexPath: commentIndexPath, postIndexPath: postIndexPath))
            // 1.3 如果是发送失败的评论，添加重新发送选项
            if model.sendStatus == .faild && role != .black {
                alert.addAction(submitCommetAction(postIndexPath: postIndexPath, commentIndexPath: commentIndexPath))
            }
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
            return
        }

        // 2.如果当前用户是黑名单用户，则不能发起评论
        guard role != .black else {
            self.blackProcess()
            return
        }

        // 3.如果点击了别人的评论，显示评论编辑
        // 记录点击的位置信息
        newCommentInfo = (postIndexPath, postId, model.userId, model.name)
        setTSKeyboard(placeholderText: "回复: \(model.name)", feedCell: cell)
    }

    /// 长按了评论行
    func feedList(_ view: FeedListView, didLongPress cell: FeedListCell, on commentView: FeedCommentListView, withCommentIndexPath commentIndexPath: IndexPath) {
        // 如果当前用户是黑名单用户，则不能发起操作
        guard role != .black else {
            self.blackProcess()
            return
        }
        // 获取评论信息
        let model = commentView.datas[commentIndexPath.row]
        guard let postId = model.id["postId"], let commentId = model.id["commentId"] else {
            return
        }
        guard let postIndexPath = view.indexPath(for: cell) else {
            return
        }
        /// 未加入圈子的情况
        guard role != nil else {
            let cellModel = cell.model
            if cellModel.userId == TSCurrentUserInfo.share.userInfo?.userIdentity {
                let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
                alert.addAction(deletePostAction(commentId: commentId, postId: postId, commentIndexPath: commentIndexPath, postIndexPath: postIndexPath))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
                return
            } else {
                self.unjoinedPressComment()
                return
            }
        }
        let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
        // 1.如果是圈主或者管理员，可以删除评论
        if role == .master || role == .manager {
            alert.addAction(deletePostAction(commentId: commentId, postId: postId, commentIndexPath: commentIndexPath, postIndexPath: postIndexPath))
        } else {
            // 2.其他非圈主或者管理员的成员，可以举报
            // 如果是自己的则弹窗提示是否删除/置顶
            if model.userId == TSCurrentUserInfo.share.userInfo?.userIdentity {
                // 自己的评论
                let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
                alert.addAction(topCommentAction(commentId: commentId))
                alert.addAction(deletePostAction(commentId: commentId, postId: postId, commentIndexPath: commentIndexPath, postIndexPath: postIndexPath))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
            } else {
                // 之前处理：弹出举报评论选项
                //alert.addAction(informCommentAction(postIndexPath: postIndexPath, commentIndexPath: commentIndexPath))
                // 目前暂时处理：直接进入评论举报界面
                let commentModel = datas[postIndexPath.row].comments[commentIndexPath.row]
                let informModel = ReportTargetModel(feedCommentModel: commentModel)
                let informVC = ReportViewController(reportTarget: informModel)
                self.parentViewController?.navigationController?.pushViewController(informVC, animated: true)
            }
            return
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
        return
    }

    /// 点击了评论内容中的用户名
    func feedList(_ view: FeedListView, didSelected cell: FeedListCell, didSelectedComment commentCell: FeedCommentListCell, onUser userId: Int) {
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": userId])
    }

    /// 点击了帖子重发帖子按钮
    func feedList(_ view: FeedListView, didSelectedResendButton cell: FeedListCell) {
//        let feedIndexPath = view.indexPath(for: cell)!
//        let alert = TSAlertController(title: nil, message: nil, style: .actionsheet)
//        alert.addAction(resendFeedAction(feedIndexPath: feedIndexPath))
//        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
    }
}

extension PostListActionView: TSKeyboardToolbarDelegate {

    /// 键盘准备收起（emmmm....，旧代码中这个方法是空着的）
    func keyboardWillHide() {
    }

    /// 点了评论编辑上发送按钮
    func keyboardToolbarSendTextMessage(message: String, inputBox: AnyObject?) {
        // 0.处理解析新评论的数据
        guard let (postIndexPath, postId, replyId, replyName) = newCommentInfo, !message.isEmpty, let groupId = groupId else {
            return
        }
        // 1.创建新评论的数据模型
        let newCommentModel = FeedCommentListCellModel(groupId: groupId, postId: postId, content: message, replyId: replyId, replyName: replyName)
        // 2.将新评论显示在列表上
        datas[postIndexPath.row].comments.insert(newCommentModel, at: 0)
        reloadRow(at: postIndexPath, with: .none)
        // 3.发起网络请求提交新评论
        let commentIndexPath = IndexPath(row: 0, section: 0 ) // 新评论展示在评论列表的最顶端
        submitCommet(atPostIndexPath: postIndexPath, commentIndexPath: commentIndexPath)
    }

    /// 回传键盘工具栏的Frame（ctrl+v 旧代码）
    func keyboardToolbarFrame(frame: CGRect, type: keyboardRectChangeType) {
        let toScrollValue = frame.origin.y - yAxis
        if  frame.origin.y > yAxis && contentOffset.y < toScrollValue {
            return
        }
        if Int(frame.origin.y) == Int(yAxis) {
            return
        }
        switch type {
        case .popUp, .typing:
            setContentOffset(CGPoint(x: 0, y: contentOffset.y - toScrollValue), animated: false)
            yAxis = frame.origin.y
        default:
            break
        }
    }
}

// MARK: - 帖子列表相关操作
extension PostListActionView {

    /// 跳转到帖子详情页
    ///
    /// - Parameters:
    ///   - groupId: 圈子 id
    ///   - postId: 帖子 id
    ///   - model: cell model
    ///   - indexPath: 帖子坐标
    ///   - isTapMore: 是否点击了“查看全部按钮”
    func pushToPostDetailVC(groupId: Int, postId: Int, model: FeedListCellModel, indexPath: IndexPath, isTapMore: Bool) {
        // 1.如果是未发送成功的帖子，就不跳转
        guard model.sendStatus == .success else {
            return
        }
        // 2.如果是文字付费的帖子，显示付费弹窗
//        if let paidInfo = model.paidInfo {
//            PaidManager.showFeedPaidTextAlert(feedId: feedId, paidInfo: paidInfo, complete: { [weak self] (newContent) in
//                self?.datas[indexPath.row].content = newContent
//                self?.datas[indexPath.row].paidInfo = nil
//                self?.reloadData()
//            })
//            return
//        }
        // 3.以上情况都不是，跳转帖子详情页
        let detailVC = TSPostCommentController(groupId: groupId, postId: postId, fromGroup: self.fromGroupFlag)
        parentViewController?.navigationController?.pushViewController(detailVC, animated: true)
    }

    /// 提交某条评论
    func submitCommet(atPostIndexPath postIndexPath: IndexPath, commentIndexPath: IndexPath) {
        // 1.获取评论 model
        let commentModel = datas[postIndexPath.row].comments[commentIndexPath.row]
        // 2.切换评论的状态为正在发送中
        datas[postIndexPath.row].toolModel?.commentCount += 1 // 评论数 +1
        commentModel.sendStatus = .sending
        reloadRow(at: postIndexPath, with: .none)
        // 3.获取网络请求相关参数
        let content = commentModel.content
        guard let postId = commentModel.id["postId"] else {
            return
        }
        var replyId: Int?
        switch commentModel.type {
        case .user(_, let replyUserId):
            replyId = replyUserId
        default:
            break
        }
        // 4.发起网络请求
        GroupNetworkManager.commentPost(postId: postId, body: content, replyUserId: replyId) { [weak self] (model, status) in
            guard let weakself = self, let groupId = weakself.groupId else {
                return
            }
            if status {
                // 5.如果评论成功，更新列表中的 newCommentModel 的信息
                if let model = model {
                    commentModel.id = .post(groupId: groupId, postId: postId, commentId: model.id)
                    commentModel.sendStatus = .success
                }
            } else {
                // 6.评论失败，更新列表中的 newCommentModel 的信息
                commentModel.sendStatus = .faild
                weakself.reloadRow(at: postIndexPath, with: .none)
            }
        }
    }

    /// 设置键盘
    ///
    /// - Parameters:
    ///   - placeholderText: 占位字符串
    ///   - cell: cell
    fileprivate func setTSKeyboard(placeholderText: String, feedCell: FeedListCell) {
        let origin = feedCell.convert(feedCell.commentView.frame.origin, to: UIApplication.shared.keyWindow)
        yAxis = origin.y + feedCell.commentView.frame.size.height
        TSKeyboardToolbar.share.keyboardToolbarDelegate = self
        TSKeyboardToolbar.share.keyboardBecomeFirstResponder()
        TSKeyboardToolbar.share.keyboardSetPlaceholderText(placeholderText: placeholderText)
    }
    /// 点击了来自的圈子
    func feedCellDidTapFromLab(_ cell: FeedListCell) {
        let postListVC = GroupDetailVC(groupId: cell.model.fromGroupID)
        self.parentViewController?.navigationController?.pushViewController(postListVC, animated: true)
    }
}

// MARK: - 弹窗操作选项
extension PostListActionView {

    // MARK: 帖子

    /// 分享帖子 alert action
    func sharePostAction(postId: Int, groupId: Int, title: String, description: String, image: UIImage?) -> TSAlertAction {
        // 当分享内容为空时，显示默认内容
        let image = image ?? UIImage(named: "IMG_icon")
        let title = title.isEmpty ? TSAppSettingInfoModel().appDisplayName + " " + "帖子" : title
        var defaultContent = "默认分享内容".localized
        defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
        let description = description.isEmpty ? defaultContent : description

        // 创建 action
        let action = TSAlertAction(title:"选择_分享".localized, style: .default, handler: { (_) in
            let shareView = ShareView()
            var url = ShareURL.groupDetail.rawValue
            url.replaceAll(matching: "replacepost", with: "\(postId)")
            url.replaceAll(matching: "replacegroup", with: "\(groupId)")
            shareView.show(URLString: url, image: image, description: description, title: title)
        })
        return action
    }

    /// 收藏帖子 alert action
    ///
    /// - Parameters:
    ///   - isCollect: true 收藏帖子；false 取消收藏帖子
    func collectPostAction(postId: Int, postIndexPath: IndexPath, isCollect: Bool) -> TSAlertAction {
        let collectTitle = isCollect ? "选择_取消收藏".localized :"选择_收藏".localized
        let action = TSAlertAction(title: collectTitle, style: .default, handler: { [weak self] (_) in
            if isCollect {
                // 取消收藏
                GroupNetworkManager.uncollectPost(postId: postId, complete: { (_) in
                })
            } else {
                // 收藏
                GroupNetworkManager.collectPost(postId: postId, complete: { (_) in
                })
            }
            // 刷新界面
            self?.datas[postIndexPath.row].toolModel?.isCollect = isCollect
        })
        return action
    }

    /// 置顶帖子 alert action
    func topPostAction(postId: Int) -> TSAlertAction {
        var showTitle = ""
        if role == .manager || role == .master {
            showTitle = "置顶帖子"
        } else {
            showTitle = "申请帖子置顶".localized
        }
        let action = TSAlertAction(title: showTitle, style: .default, handler: { [weak self] (_) in
            let top = TSTopAppilicationManager.postTopVC(postId: postId)
            self?.parentViewController?.navigationController?.pushViewController(top, animated: true)
        })
        return action
    }

    /// 删除帖子 alert action
    func deletePostAction(groupId: Int, postId: Int, postIndexPath: IndexPath) -> TSAlertAction {
        let action = TSAlertAction(title: "删除帖子", style: .default, handler: { [weak self] (_) in
            self?.showPostDeleteConfirmAlert(groupId: groupId, postId: postId, postIndexPath: postIndexPath)
        })
        return action
    }

    /// 显示删除帖子二次确认弹窗
    func showPostDeleteConfirmAlert(groupId: Int, postId: Int, postIndexPath: IndexPath) -> Void {
        let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "删除帖子") {
            self.deletePost(groupId: groupId, postId: postId, postIndexPath: postIndexPath)
        }
        parentViewController?.present(alertVC, animated: false, completion: nil)
    }
    /// 删除帖子
    fileprivate func deletePost(groupId: Int, postId: Int, postIndexPath: IndexPath) -> Void {
        // 发起帖子删除网络请求
        GroupNetworkManager.delete(post: postId, groupId: groupId, complete: { (_) in
        })
        // 刷新列表
        self.datas.remove(at: postIndexPath.row)
        self.reloadData()
    }

    /// 举报帖子 alert action
    func informPostAction(postIndexPath: IndexPath) -> TSAlertAction {
        let cellModel = datas[postIndexPath.row]
        let informModel = ReportTargetModel(feedModel: cellModel)!
        let action = TSAlertAction(title: "举报", style: .default, handler: { [weak self] (_) in
            let informVC = ReportViewController(reportTarget: informModel)
            self?.parentViewController?.navigationController?.pushViewController(informVC, animated: true)
        })
        return action
    }

    /// 撤销置顶帖子
    func cancelTopPost(postIndexPath: IndexPath) -> TSAlertAction {
        let postModel = datas[postIndexPath.row]
        let postId = postModel.id["postId"]!
        let action = TSAlertAction(title: "撤销置顶", style: .default) { [weak self] (_) in

            let alert = TSIndicatorWindowTop(state: .loading, title: "撤销中...")
            alert.show()
            GroupNetworkManager.managerCancelTopPost(postId: postId, complete: { (status, message) in
                alert.dismiss()
                let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message)
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                // 如果撤销成功
                if status {
                    if self?.tableIdentifier == "2" {
                        self?.datas.remove(at: postIndexPath.row)
                    } else {
                        self?.datas[postIndexPath.row].showPostTopIcon = false
                    }
                    self?.reloadData()
                }
            })
        }
        return action
    }

    /// 管理员置顶帖子
    func managerTopPost(postIndexPath: IndexPath) -> TSAlertAction {
        let postModel = datas[postIndexPath.row]
        let postId = postModel.id["postId"]!
        let action = TSAlertAction(title: "置顶帖子", style: .default) { [weak self] (_) in

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
                    let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "置顶中...")
                    loadingAlert.show()
                    GroupNetworkManager.managerTopPost(postId: postId, day: day, complete: { (status, message) in
                        loadingAlert.dismiss()
                        let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message)
                        resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                        // 如果置顶成功
                        if status {
                            self?.datas[postIndexPath.row].showPostTopIcon = true
                            self?.reloadData()
                        }
                    })
                } else {
                    let resultAlert = TSIndicatorWindowTop(state: .faild, title: "请输入正确的天数，可以选择置顶 1 ~ 30 天")
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }

            }))
            self?.parentViewController?.present(alert, animated: false, completion: nil)
        }
        return action
    }

    // MARK: 评论

    /// 举报评论 alert action
    func informCommentAction(postIndexPath: IndexPath, commentIndexPath: IndexPath) -> TSAlertAction {
        let commentModel = datas[postIndexPath.row].comments[commentIndexPath.row]
        let informModel = ReportTargetModel(feedCommentModel: commentModel)
        let action = TSAlertAction(title: "举报评论", style: .default) { [weak self] (_) in
            let informVC = ReportViewController(reportTarget: informModel)
            self?.parentViewController?.navigationController?.pushViewController(informVC, animated: true)
        }
        return action
    }

    /// 重发评论 alert action
    func submitCommetAction(postIndexPath: IndexPath, commentIndexPath: IndexPath) -> TSAlertAction {
        let action = TSAlertAction(title: "重新发送", style: .default) { [weak self] (_) in
            self?.submitCommet(atPostIndexPath: postIndexPath, commentIndexPath: commentIndexPath)
        }
        return action
    }

    /// 置顶评论 alert action
    func topCommentAction(commentId: Int) -> TSAlertAction {
        let action = TSAlertAction(title: "申请评论置顶", style: .default) { [weak self] (_) in
            let topVC = TSTopAppilicationManager.postCommentTopVC(commentId: commentId)
            self?.parentViewController?.navigationController?.pushViewController(topVC, animated: true)
        }
        return action
    }

    /// 删除评论 alert action
    func deletePostAction(commentId: Int, postId: Int, commentIndexPath: IndexPath, postIndexPath: IndexPath) -> TSAlertAction {
        let action = TSAlertAction(title: "选择_删除".localized, style: .default, handler: { [weak self] (_) in
            self?.showCommentDeleteConfirmAlert(commentId: commentId, postId: postId, commentIndexPath: commentIndexPath, postIndexPath: postIndexPath)
        })
        return action
    }

    /// 显示删除评论的二次确认弹窗
    func showCommentDeleteConfirmAlert(commentId: Int, postId: Int, commentIndexPath: IndexPath, postIndexPath: IndexPath) -> Void {
        let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "删除评论") {
            self.deleteComment(commentId: commentId, postId: postId, commentIndexPath: commentIndexPath, postIndexPath: postIndexPath)
        }
        parentViewController?.present(alertVC, animated: false, completion: nil)
    }

    /// 删除评论
    fileprivate func deleteComment(commentId: Int, postId: Int, commentIndexPath: IndexPath, postIndexPath: IndexPath) -> Void {
        // 发起删除的网络请求
        GroupNetworkManager.deleteComment(postId: postId, commentId: commentId, complete: { (_) in
        })
        // 刷新界面
        self.datas[postIndexPath.row].comments.remove(at: commentIndexPath.row)
        self.datas[postIndexPath.row].toolModel?.commentCount -= 1
        self.reloadRow(at: postIndexPath, with: .none)
    }

}

// MARK: - 黑名单相关
extension PostListActionView {
    /// 黑名单权限检测
    fileprivate func isBlack() -> Bool {
        // 当前用户权限检测：黑名单用户 不可点赞 和 评论、举报圈子
        guard let roleType = self.role else {
            return false
        }
        return roleType == .black
    }
    /// 黑名单处理
    fileprivate func blackProcess() -> Void {
        let alertVC = TSAlertController(title: "提示", message: "提示信息_圈子黑名单".localized, style: .actionsheet)
        DispatchQueue.main.async {
            self.parentViewController?.present(alertVC, animated: false, completion: nil)
        }
    }
    /// 未加入圈子提示
    fileprivate func unjoinedProcess() -> Void {
        let alertVC = TSAlertController(title: "提示", message: "提示信息_圈子未加入但进行了操作".localized, style: .actionsheet)
        DispatchQueue.main.async {
            self.parentViewController?.present(alertVC, animated: false, completion: nil)
        }
    }
    /// 未加入圈子提示
    fileprivate func unjoinedPressFavor() -> Void {
        let alertVC = TSAlertController(title: "提示", message: "提示信息_圈子未加入操作了点赞".localized, style: .actionsheet)
        DispatchQueue.main.async {
            self.parentViewController?.present(alertVC, animated: false, completion: nil)
        }
    }
    /// 未加入圈子提示
    fileprivate func unjoinedPressComment() -> Void {
        let alertVC = TSAlertController(title: "提示", message: "提示信息_圈子未加入操作了评论".localized, style: .actionsheet)
        DispatchQueue.main.async {
            self.parentViewController?.present(alertVC, animated: false, completion: nil)
        }
    }
}

extension PostListActionView: ShareListViewDelegate {
    // 设置置顶
    func didClickSetTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let cell = self.cellForRow(at: feedIndex) as! FeedListCell
        let model = cell.model
        guard let postId = model.id["postId"] else {
            return
        }
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
                let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "置顶中...")
                loadingAlert.show()
                GroupNetworkManager.managerTopPost(postId: postId, day: day, complete: { (status, message) in
                    loadingAlert.dismiss()
                    let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    // 如果置顶成功
                    if status {
                        self.datas[feedIndex.row].showPostTopIcon = true
                        self.reloadData()
                    }
                })
            } else {
                let resultAlert = TSIndicatorWindowTop(state: .faild, title: "请输入正确的天数，可以选择置顶 1 ~ 30 天")
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }))
        self.parentViewController?.present(alert, animated: false, completion: nil)
    }

    // 撤销置顶
    func didClickCancelTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let postModel = datas[feedIndex.row]
        let postId = postModel.id["postId"]!

            let alert = TSIndicatorWindowTop(state: .loading, title: "撤销中...")
            alert.show()
            GroupNetworkManager.managerCancelTopPost(postId: postId, complete: { (status, message) in
                alert.dismiss()
                let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message)
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                // 如果撤销成功
                if status {
                    if self.tableIdentifier == "2" {
                        self.datas.remove(at: feedIndex.row)
                    } else {
                        self.datas[feedIndex.row].showPostTopIcon = false
                    }
                    self.reloadData()
                }
            })
    }

    // 设为精华帖
    func didClickSetExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let postModel = datas[feedIndex.row]
        let postId = postModel.id["postId"]!
            let alert = TSIndicatorWindowTop(state: .loading, title: "加载中...")
            alert.show()
            GroupNetworkManager.managerSetOrCancelPost(postId: postId, complete: { (status, message) in
                alert.dismiss()
                let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message ?? "设置成功")
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                // 如果撤销成功
                if status {
                    self.datas[feedIndex.row].excellent = TSDate().dateString(.normal, nsDate: Date() as NSDate)
                    self.reloadData()
                }
            })
    }

    // 取消精华
    func didClickCancelExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let postModel = datas[feedIndex.row]
        let postId = postModel.id["postId"]!
            let alert = TSIndicatorWindowTop(state: .loading, title: "撤销中...")
            alert.show()
            GroupNetworkManager.managerSetOrCancelPost(postId: postId, complete: { (status, message) in
                alert.dismiss()
                let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message ?? "撤销成功")
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                // 如果撤销成功
                if status {
                    self.datas[feedIndex.row].excellent = nil
                    if  !self.isNeedShowPostExcellent() {
                       self.datas.remove(at: feedIndex.row)
                    }
                    self.reloadData()
                }
            })
    }

    func didClickMessageButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, model: TSmessagePopModel) {

        let chooseFriendVC = TSPopMessageFriendList(model: model)
        parentViewController?.navigationController?.pushViewController(chooseFriendVC, animated: true)
    }

    // 帖子举报
    func didClickReportButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let cellModel = datas[feedIndex.row]
        let informModel = ReportTargetModel(feedModel: cellModel)!
        let informVC = ReportViewController(reportTarget: informModel)
        self.parentViewController?.navigationController?.pushViewController(informVC, animated: true)
    }

    // 帖子收藏
    func didClickCollectionButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let cell = self.cellForRow(at: feedIndex) as! FeedListCell
        let model = cell.model
        guard  let postId = model.id["postId"] else {
            return
        }
        if model.toolModel == nil {
            return
        }
        if (model.toolModel?.isCollect)! {
            // 取消收藏
            GroupNetworkManager.uncollectPost(postId:postId, complete: { (_) in})
            // 刷新界面
            self.datas[feedIndex.row].toolModel?.isCollect = false
        } else {
            // 收藏
            GroupNetworkManager.collectPost(postId: postId, complete: { (_) in
            })
            // 刷新界面
            self.datas[feedIndex.row].toolModel?.isCollect = true
        }
    }

    // 帖子删除
    func didClickDeleteButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let cell = self.cellForRow(at: feedIndex) as! FeedListCell
        let model = cell.model
        guard let groupId = model.id["groupId"], let postId = model.id["postId"] else {
            return
        }
        self.showPostDeleteConfirmAlert(groupId: groupId, postId: postId, postIndexPath: feedIndex)
    }

    func didClickRepostButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {
        let cell = self.cellForRow(at: feedIndex!) as! FeedListCell
        let model = cell.model
        let repostModel = TSRepostModel.coverGroupPostListModel(groupPostListModel: model)
        let releaseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: true)
        releaseVC.repostModel = repostModel
        let navigation = TSNavigationController(rootViewController: releaseVC)
        self.parentViewController?.present(navigation, animated: true, completion: nil)
    }

    // 申请帖子置顶
    func didClickApplyTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        let cell = self.cellForRow(at: feedIndex) as! FeedListCell
        let model = cell.model
        guard  let postId = model.id["postId"] else {
            return
        }
        let top = TSTopAppilicationManager.postTopVC(postId: postId)
        self.parentViewController?.navigationController?.pushViewController(top, animated: true)
    }
}
