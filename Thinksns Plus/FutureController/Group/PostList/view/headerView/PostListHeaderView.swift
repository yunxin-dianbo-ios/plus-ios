//
//  PostListHeaderView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import YYKit

protocol PostListHeaderViewDelegate: class {
    /// 点击了加入按钮
    func postListHeaderDidSelectedJoinButton(_ view: PostListHeaderView)
    /// 点击了私聊按钮
    func postListHeaderDidSelectedChatButtonWith(_ view: PostListHeaderView)
}

class PostListHeaderView: StretchTableHeader {

    /// 代理
    weak var delegate: PostListHeaderViewDelegate?

    /// 内容视图
    let contentView = PostListFixedHeaderView()
    /// 内容 model,不要尝试从外部写入
    var contentModel = PostListControllerModel()

    fileprivate var table = UITableView()

    open func set(taleView: UITableView) {
        self.table = taleView
    }

    open func load(contentModel: PostListControllerModel) {
        self.contentModel = contentModel

        // 1.设置内容视图
        contentView.model = contentModel
        contentView.delegate = self

        // 2.设置弹性 header 的数据
        let stretchHeaderModel = StretchTableHeaderModel()
        // 设置弹性 header 的背景是毛玻璃效果
        stretchHeaderModel.bgDisplay = .blur
        // 将固定的 header 添加到弹性视图上
        stretchHeaderModel.fixedView = contentView
        // 将 table 传入弹性 header 中，由内部设置偏移量
        stretchHeaderModel.tableView = table
        // 设置弹性 header 上的背景视图的最小高度
        stretchHeaderModel.bgHeightMin = 160
        // 设置弹性 header 上固定的 header 的最小高度
        /// 留出底部10pt的间隔高度
        stretchHeaderModel.headerHeightMin = contentView.frame.height + 10
        stretchHeaderModel.backgroundUrl = contentModel.coverImage

        // 3.刷新视图
        load(stretchModel: stretchHeaderModel)
        updateChildviews(tableOffset: table.contentOffset.y)
        backgroundColor = TSColor.inconspicuous.background
    }
    /// 刷新子视图的 frame
    ///
    /// - Parameter offset: table 在 y 轴上的偏移量
    override open func updateChildviews(tableOffset offset: CGFloat) {
        // 由于scrollView 向下拖拽的content
        let offset = -(stretchModel.headerHeightMin + offset)
        // 如果是向上拖动 返回.
        if offset < 0 {
            return
        }
        let orignalWidth = UIScreen.main.bounds.width
        // 1.更新 header 的 frame
        frame = CGRect(x: 0, y: -(stretchModel.headerHeightMin + offset), width: orignalWidth, height: stretchModel.headerHeightMin + offset)
        // 2.更新背景视图的 frame
        let bgWidth = (stretchModel.bgHeightMin + offset) * 2.5
        bgImageView.frame = CGRect(x: -(bgWidth - orignalWidth) / 2, y: 0, width: bgWidth, height: stretchModel.bgHeightMin + offset)
        bottomMaskView.frame = CGRect(x: 0, y:  bgImageView.frame.maxY - 44, width: UIScreen.main.bounds.width, height: 44)
        // 如果有高斯模糊层
        if stretchModel.bgDisplay == .blur {
            blurView.frame = bgImageView.bounds
        }
        // 3.更新固定视图的 frame
        if let fixedView = stretchModel.fixedView {
            ///
            stretchModel.fixedView?.frame = CGRect(origin: CGPoint(x: 0, y: frame.height - fixedView.frame.height - 10), size: fixedView.frame.size)
        }
    }

}

extension PostListHeaderView: PostListFixedHeaderViewDelegate {

    /// 点击了简介 label 上的查看更多按钮
    func postListFixedHeaderView(_ view: PostListFixedHeaderView, didSelectedIntroLabelButtonWithNewFrame newFixedViewFrame: CGRect) {
        // 获取弹性视图的 model
        // 更新数据
        self.stretchModel.headerHeightMin = newFixedViewFrame.height
        load(stretchModel: self.stretchModel)
        // [注意] 这里要手动调用一次刷新界面的方法
        updateChildviews(tableOffset: -newFixedViewFrame.height - TSStatusBarHeight)
    }

    /// 点击了加入按钮
    func postListFixedHeaderViewDidSelectedJoinButton(_ view: PostListFixedHeaderView) {
        delegate?.postListHeaderDidSelectedJoinButton(self)
    }

    /// 点击了私聊按钮
    func postListFixedHeaderViewDidSelectedChatButtonWith(_ view: PostListFixedHeaderView) {
        delegate?.postListHeaderDidSelectedChatButtonWith(self)
    }
}
