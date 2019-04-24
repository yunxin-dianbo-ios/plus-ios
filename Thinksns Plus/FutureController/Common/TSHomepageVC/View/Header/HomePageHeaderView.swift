//
//  HomePageHeaderView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/10/10.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  个人主页 顶部视图

import UIKit
import Kingfisher

protocol HomePageHeaderViewDelegate: class {
    /// 点击了个人主页背景图
    func headerview(_ headerview: HomePageHeaderView, didSelectedBackImageView: UIImageView)
    /// 点击了个人主页的粉丝关注按钮
    func headerview(_ headerview: HomePageHeaderView, didSelectedFansOrFollowButton isFansButton: Bool)
}

class HomePageHeaderView: StretchTableHeader {

    /// 代理
    weak var delegate: HomePageHeaderViewDelegate?

    /// 内容视图
    let contentView = HomePageHeaderContentView()
    /// 内容 model
    fileprivate var contentModel = HomepageModel()

    fileprivate var table = UITableView()

    open func set(taleView: UITableView) {
        self.table = taleView
    }

    open func load(contentModel: HomepageModel) {
        self.contentModel = contentModel

        // 1.设置内容视图
        contentView.model = contentModel
        contentView.buttonForFans.addTarget(self, action: #selector(fansButtonTaped), for: .touchUpInside)
        contentView.buttonForFollow.addTarget(self, action: #selector(followButtonTaped), for: .touchUpInside)

        /// 设置阴影颜色
        contentView.labelForName.shadowColor = UIColor.black
        ///设置阴影大小
        contentView.labelForName.shadowOffset = CGSize(width: 0.4, height: 0.4)
        contentView.buttonForFans.setTitleShadowColor(UIColor.black, for: .normal)
        contentView.buttonForFans.titleLabel?.shadowOffset = CGSize(width: 0.4, height: 0.4)
        contentView.buttonForFollow.setTitleShadowColor(UIColor.black, for: .normal)
        contentView.buttonForFollow.titleLabel?.shadowOffset = CGSize(width: 0.4, height: 0.4)

        // 2.设置弹性 header 的数据
        let stretchHeaderModel = StretchTableHeaderModel()
        // 设置弹性 header 的背景是毛玻璃效果
        stretchHeaderModel.bgDisplay = .none
        // 将固定的 header 添加到弹性视图上
        stretchHeaderModel.fixedView = contentView
        // 将 table 传入弹性 header 中，由内部设置偏移量
        stretchHeaderModel.tableView = table
        // 设置弹性 header 上的背景视图的最小高度
        stretchHeaderModel.bgHeightMin = UIScreen.main.bounds.width / 2
        // 设置弹性 header 上固定的 header 的最小高度
        stretchHeaderModel.headerHeightMin = contentView.frame.height
        stretchHeaderModel.backgroundUrl = TSUtil.praseTSNetFileUrl(netFile: contentModel.userInfo.bg)
        stretchHeaderModel.placeholderImage = UIImage(named: "IMG_default_pic_personal (1)")
        stretchHeaderModel.shouldCleanCache = true

        // 2.设置背景图点击事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(backImageViewTaped))
        contentView.addGestureRecognizer(tap)

        // 3.刷新视图
        load(stretchModel: stretchHeaderModel)
        updateChildviews(tableOffset: table.contentOffset.y)
    }

    /// 点击了粉丝按钮
    func fansButtonTaped() {
        delegate?.headerview(self, didSelectedFansOrFollowButton: true)
    }

    /// 点击了关注按钮
    func followButtonTaped() {
        delegate?.headerview(self, didSelectedFansOrFollowButton: false)
    }

    /// 点击了背景图
    func backImageViewTaped() {
        delegate?.headerview(self, didSelectedBackImageView: bgImageView)
    }

}
