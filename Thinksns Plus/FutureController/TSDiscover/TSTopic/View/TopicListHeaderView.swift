//
//  TopicListHeaderView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/24.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol TopicListHeaderViewDelegate: class {
    func jumpToMenberListVC(_ topicListHeaderView: TopicListHeaderView, topicId: Int)
}

class TopicListHeaderView: StretchTableHeader {

    weak var delegate: TopicListHeaderViewDelegate?
    /// 内容视图
    let contentView = TopicListFixedHeaderView()
    /// 内容 model
    fileprivate var contentModel = TopicListControllerModel()
    fileprivate var table = UITableView()

    open func set(taleView: UITableView) {
        self.table = taleView
    }

    open func load(contentModel: TopicListControllerModel) {
        self.contentModel = contentModel

        if contentModel.coverImage == nil {
            contentView.allHeight = 150
        } else {
            contentView.allHeight = 188
        }
        // 1.设置内容视图
        contentView.model = contentModel
        contentView.delegate = self
        // 2.设置弹性 header 的数据
        let stretchHeaderModel = StretchTableHeaderModel()
        // 设置弹性 header 的背景是毛玻璃效果
        stretchHeaderModel.bgDisplay = .none
        // 将固定的 header 添加到弹性视图上
        stretchHeaderModel.fixedView = contentView
        // 将 table 传入弹性 header 中，由内部设置偏移量
        stretchHeaderModel.tableView = table
        // 设置弹性 header 上的背景视图的最小高度
        if contentModel.coverImage == nil {
            stretchHeaderModel.bgHeightMin = 150
            stretchHeaderModel.headerHeightMin = contentView.frame.height
        } else {
            stretchHeaderModel.bgHeightMin = 188
            stretchHeaderModel.headerHeightMin = contentView.frame.height
        }
        // 设置弹性 header 上固定的 header 的最小高度
        stretchHeaderModel.backgroundUrl = TSUtil.praseTSNetFileUrl(netFile: contentModel.coverImage)
        // 3.刷新视图
        load(stretchModel: stretchHeaderModel)
        updateChildviews(tableOffset: table.contentOffset.y)
        if contentModel.coverImage == nil {
            self.bgImageView.backgroundColor = UIColor.white
            self.topMaskView.isHidden = true
            self.bottomMaskView.isHidden = true
        }
    }
}

extension TopicListHeaderView: TopicListFixedHeaderViewDelegate {
    func didClickJumpButton(_ topicListFixedHeaderView: TopicListFixedHeaderView, topicId: Int) {
        self.delegate?.jumpToMenberListVC(self, topicId: topicId)
    }
}
