//
//  TSNewsDetailToolbarView.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

protocol TSNewsDetailToolbarDelegate: class {
    /// 点击了评论按钮
    func didSelectedCommentButton(_ toolbar: TSNewsDetailToolbarView)
    /// 点击了申请置顶按钮
    func didPressNewsApplyBtn(_ toolbar: TSNewsDetailToolbarView)
    /// 点击了删除资讯选项
    func didClickDeleteNewsOptionIn(toolbar: TSNewsDetailToolbarView, isManager: Bool) -> Void
    /// 点击了分享按钮
    func didClickShareButton(_ toolbar: TSNewsDetailToolbarView)
}

class TSNewsDetailToolbarView: TSToolbarView, TSToolbarViewDelegate, TSCustomAcionSheetDelegate {

    /// 动态数据
    var object: NewsDetailModel
    /// 分享图片获取视图
    var imageCacheView: UIImageView = UIImageView()

    /// 代理
    weak var commentDelegate: TSNewsDetailToolbarDelegate? = nil

    // MARK: - Lifecycle
    init(_ object: NewsDetailModel) {
        self.object = object
        super.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 48 - TSBottomSafeAreaHeight, width: UIScreen.main.bounds.width, height: 48 + TSBottomSafeAreaHeight), type: .top, items: [TSToolbarItemModel(image: "", title: "喜欢", index: 0), TSToolbarItemModel(image: "IMG_home_ico_comment_normal", title: "评论", index: 1), TSToolbarItemModel(image: "IMG_detail_ico_share_normal", title: "分享", index: 2), TSToolbarItemModel(image: "IMG_home_ico_more", title: "更多", index: 3)])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MAKR: - Custom user interface
    override func setUI() {
        super.setUI()
        delegate = self

        setTitleColor(object.isLike == true ? TSColor.main.warn : TSColor.normal.secondary, At: 0)
        setImage(object.isLike == true ? "IMG_home_ico_good_high" : "IMG_home_ico_good_normal", At: 0)
        // line
        let line = UIView(frame: CGRect(x: 0, y: -1, width: UIScreen.main.bounds.width, height: 1))
        line.backgroundColor = TSColor.inconspicuous.disabled
        addSubview(line)
    }

    // MARK: - Public
    /// 滑动效果动画
    func scrollowAnimation(_ offset: CGFloat) {
        let topY = UIScreen.main.bounds.height - 48 - TSBottomSafeAreaHeight
        let bottomY = UIScreen.main.bounds.height + 1
        let isAtTop = frame.minY == topY
        let isAtBottom = frame.minY == bottomY
        let isScrollowUp = offset > 0
        let isScrollowDown = offset < 0

        if (isAtTop && isScrollowDown) || (isAtBottom && isScrollowUp) {
            return
        }

        var frameY = frame.minY + offset
        if isScrollowDown && frameY < topY { // 上滑
            frameY = topY
        }
        if isScrollowUp && frameY > bottomY {
            frameY = bottomY
        }
        frame = CGRect(x: 0, y: frameY, width: frame.width, height: frame.height)
    }

    func uploadData(data: NewsDetailModel) {
        self.object = data
        setTitleColor(object.isLike == true ? TSColor.main.warn : TSColor.normal.secondary, At: 0)
        setImage(object.isLike == true ? "IMG_home_ico_good_high" : "IMG_home_ico_good_normal", At: 0)
    }

    // MARK: - Delegate
    // MARK: TSMomentDetailNavViewDelegate
    /// 点击了工具栏
    func toolbar(_ toolbar: TSToolbarView, DidSelectedItemAt index: Int) {
        if index == 0 { // 点赞
            setTitleColor(object.isLike == false ? TSColor.main.warn : TSColor.normal.secondary, At: 0)
            setImage(object.isLike == false ? "IMG_home_ico_good_high" : "IMG_home_ico_good_normal", At: 0)
            object.isLike = !object.isLike
            TSNewsNetworkManager().like(object.isLike, newsId: object.id, complete: { (_) in
            })
            if object.isLike == true { // 点赞
                NotificationCenter.default.post(name: NSNotification.Name.News.pressNewsDetailLikeBtn, object: nil)
            }
            if object.isLike == false { // 取消赞
                NotificationCenter.default.post(name: NSNotification.Name.News.pressNewsDetailUnlikeBtn, object: nil)
            }
        }
        if index == 1 { // 评论
            if let commentDelegate = commentDelegate {
                commentDelegate.didSelectedCommentButton(self)
            }
        }
        if index == 2 { // 分享
            if let commentDelegate = commentDelegate {
                commentDelegate.didClickShareButton(self)
            }
            return
            let shareTitle = self.object.title != "" ? self.object.title : TSAppSettingInfoModel().appDisplayName + " " + "音乐"
            var defaultContent = "默认分享内容".localized
            defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
            let shareContent = self.object.subject != "" ? self.object.subject : defaultContent

            let shareView = ShareView()
            let url = ShareURL.news.rawValue + "\(self.object.id!)"
            shareView.show(URLString: url, image: UIImage(named: "IMG_icon"), description: shareContent, title: shareTitle)
        }
        if index == 3 {
            var selectTitles: [String] = []
            // 自己： ["选择_申请资讯置顶", "选择_删除资讯"]
            // 他人： ["选择_收藏", "选择_举报"]
            if let id = TSCurrentUserInfo.share.userInfo?.userIdentity, object.authorId == id {
                selectTitles.append("选择_申请资讯置顶".localized)
                selectTitles.append("选择_删除资讯".localized)
            } else if TSCurrentUserInfo.share.accountManagerInfo?.getNewManager() ?? false {
                selectTitles.append(object.isCollect == false ? "选择_收藏".localized : "选择_取消收藏".localized)
                selectTitles.append("选择_删除资讯".localized)
            } else {
                selectTitles.append(object.isCollect == false ? "选择_收藏".localized : "选择_取消收藏".localized)
                selectTitles.append("选择_举报".localized)
            }
            let alert = TSCustomActionsheetView(titles: selectTitles)
            alert.delegate = self
            alert.show()
        }
    }

    // MARK: - TSCustomAcionSheetDelegate
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if title == "选择_收藏".localized || title == "选择_取消收藏".localized {
            object.isCollect = !object.isCollect
            TSNewsNetworkManager().colloction(object.isCollect, newsID: object.id, { (_, _) in
            })
            return
        }
        switch title {
        case "选择_申请资讯置顶".localized:
            self.commentDelegate?.didPressNewsApplyBtn(self)
        case "选择_删除资讯".localized:
            if let id = TSCurrentUserInfo.share.userInfo?.userIdentity, object.authorId == id {
                self.commentDelegate?.didClickDeleteNewsOptionIn(toolbar: self, isManager: false)
            } else if TSCurrentUserInfo.share.accountManagerInfo?.getNewManager() ?? false {
                self.commentDelegate?.didClickDeleteNewsOptionIn(toolbar: self, isManager: true)
            }
        case "选择_举报".localized:
            // 进入举报页
            let iconUrl = self.object.originContent.ts_customMarkdownToStandard().ts_getMarkdownImageUrl().first
            let user = TSUserInfoModel()
            user.name = self.object.author
            user.userIdentity = self.object.authorId
            let reportTarget = ReportTargetModel(targetId: self.object.id, sourceUser: user, type: .News, imageUrl: iconUrl, title: self.object.title, body: nil)
            let reportVC = ReportViewController(reportTarget: reportTarget)
            if let selectedVC = TSRootViewController.share.tabbarVC?.selectedViewController as? UINavigationController {
                selectedVC.pushViewController(reportVC, animated: true)
            }
        default:
            assert(false, "出现了无法解析的数据")
            break
        }
    }
}
