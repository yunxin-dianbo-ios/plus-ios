//
//  TSMomentDetailToolbar.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态详情 工具栏

import UIKit

protocol TSMomentDetailToolbarDelegate: class {
    func toolbar(_ toolbar: TSMomentDetailToolbar, DidSelectedItemAt index: Int)
}
class TSMomentDetailToolbar: TSToolbarView, TSToolbarViewDelegate {

    /// 动态数据
    let object: TSMomentListObject

    /// 代理
    weak var commentDelegate: TSMomentDetailToolbarDelegate?

    // MARK: - Lifecycle
    init(_ object: TSMomentListObject) {
        self.object = object

        // [长期注释] 动态详情页收藏按钮改为“更多”按钮. 2017/04/24
//        super.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 48, width: UIScreen.main.bounds.width, height: 48), type: .top, items: [TSToolbarItemModel(image: "", title: "喜欢", index: 0), TSToolbarItemModel(image: "IMG_home_ico_comment_normal", title: "评论", index: 1), TSToolbarItemModel(image: "IMG_detail_ico_share_normal", title: "分享", index: 2), TSToolbarItemModel(image: "", title: "收藏", index: 3)])
        var yPoint = UIScreen.main.bounds.height - 48 - TSBottomSafeAreaHeight
        if UIApplication.shared.statusBarFrame.size.height != TSStatusBarHeight {
            yPoint -= TSStatusBarHeight
        }
    super.init(frame: CGRect(x: 0, y: yPoint, width: UIScreen.main.bounds.width, height: 48 + TSBottomSafeAreaHeight), type: .top, items: [TSToolbarItemModel(image: "", title: "喜欢", index: 0), TSToolbarItemModel(image: "IMG_home_ico_comment_normal", title: "评论", index: 1), TSToolbarItemModel(image: "IMG_detail_ico_share_normal", title: "分享", index: 2), TSToolbarItemModel(image: "IMG_home_ico_more", title: "更多", index: 3)])
    }

    required init?(coder aDecoder: NSCoder) {
        object = TSMomentListObject()
        super.init(coder: aDecoder)
    }

    // MAKR: - Custom user interface
    override func setUI() {
        super.setUI()
        delegate = self
        // tool
        updateToolBar()
        // line
        let line = UIView(frame: CGRect(x: 0, y: -1, width: UIScreen.main.bounds.width, height: 1))
        line.backgroundColor = TSColor.inconspicuous.disabled
        addSubview(line)
    }

    // MARK: - Public

    /// 更新工具栏的内容
    func updateToolBar() {
        // ”喜欢“按钮
        setTitleColor(object.isDigg == 1 ? TSColor.main.warn : TSColor.normal.secondary, At: 0)
        setImage(object.isDigg == 0 ? "IMG_home_ico_good_normal" : "IMG_home_ico_good_high", At: 0)
        // [长期注释] 动态详情页收藏按钮改为“更多”按钮. 2017/04/24
        // “收藏”按钮
//        setTitleColor(object.isCollect == 1 ? TSColor.main.warn : TSColor.normal.secondary, At: 3)
//        setImage(object.isCollect == 0 ? "IMG_detail_ico_good_uncollect" : "IMG_detail_ico_collect", At: 3)
    }

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
            if UIApplication.shared.statusBarFrame.size.height != TSStatusBarHeight {
                frameY -= TSStatusBarHeight
            }
        }
        if isScrollowUp && frameY > bottomY {
            frameY = bottomY
        }

        frame = CGRect(x: 0, y: frameY, width: frame.width, height: frame.height)
    }

    // MARK: - Delegate

//    /// [长期注释] 由于后台的原因，要求按钮的点击间隔长达 1s
//    var canDigg = true

    // MARK: TSMomentDetailNavViewDelegate
    /// 点击了工具栏
    func toolbar(_ toolbar: TSToolbarView, DidSelectedItemAt index: Int) {
        if index == 0 { // 喜欢
//            // [长期注释] 拦截点赞操作间隔长达 1s
//            if !canDigg {
//                return
//            }
//            canDigg = false
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
//                if let weakSelf = self {
//                    weakSelf.canDigg = true
//                }
//            })

            setTitleColor(object.isDigg == 0 ? TSColor.main.warn : TSColor.normal.secondary, At: 0)
            setImage(object.isDigg == 1 ? "IMG_home_ico_good_normal" : "IMG_home_ico_good_high", At: 0)
            // 发起任务
            let isDigg = object.isDigg == 1 ? false : true
            TSDataQueueManager.share.moment.start(digg: object.feedIdentity, isDigg: isDigg)
            // 更改动态数据库
            TSDatabaseManager().moment.change(digg: object)
        }
        // [长期注释] 动态详情页收藏按钮改为“更多”按钮. 2017/04/24
//        if index == 3 { // 收藏
//            setTitleColor(object.isCollect == 0 ? TSColor.main.warn : TSColor.normal.secondary, At: 3)
//            setImage(object.isCollect == 1 ? "IMG_detail_ico_good_uncollect" : "IMG_detail_ico_collect", At: 3)
//            // 发起任务
//            TSDataQueueManager.share.moment.start(collect: object)
//        }
        if let commentDelegate = commentDelegate {
            commentDelegate.toolbar(self, DidSelectedItemAt: index)
        }
    }
}
