//
//  ReportTargetControll.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  被举报的对象
//  根据加载的对象进行布局，而不提前布局。

import UIKit

class ReportTargetControl: UIControl {

    // MARK: - Internal Property

    var model: ReportTargetModel? {
        didSet {
            self.setupWithModel(model)
        }
    }
    /// 举报对象的显示类型
    enum ReportTargetShowType {
        /// 什么都不显示
        case none
        /// 显示一个
        case onlyImage
        case onlyTitle
        case onlyDetail
        /// 显示两个
        case bothImageTitle
        case bothImageDetail
        case bothTitleDetail
        /// 显示三个
        case all
    }

    // MARK: - Private Property

    fileprivate let iconView: UIImageView = UIImageView(cornerRadius: 0)
    fileprivate let titleLabel: UILabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: TSColor.normal.minor)
    // 暂先使用UILabel，之后更正为YYLabel
    fileprivate let detailLabel: UILabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.minor)

    // MARK: - Initialize Function

    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Internal Function
    // MARK: - Override Function

    // MARK: - Private  UI

    private func initialUI() -> Void {
        // 仅设置UI，不做布局处理
    }

    // MARK: - Private  数据

    /// 数据加载
    fileprivate func setupWithModel(_ model: ReportTargetModel?) -> Void {
        guard let model = model else {
            return
        }
        let showType = self.targetShowTypeWithModel(model)
        self.setupWith(showType: showType, model: model)
    }
    /// 根据数据模型获取展示类型
    fileprivate func targetShowTypeWithModel(_ model: ReportTargetModel) -> ReportTargetShowType {
        var showType = ReportTargetShowType.none
        // 根据内容判断该项是否要展示
        var showImage: Bool = false
        var showTitle: Bool = false
        var showDetail: Bool = false
        if nil != model.imageUrl && !model.imageUrl!.isEmpty {
            showImage = true
        }
        if nil != model.title && !model.title!.isEmpty {
            showTitle = true
        }
        if nil != model.body && !model.body!.isEmpty {
            showDetail = true
        }
        // 根据展示组合确定展示类型
        if showImage && showTitle && showDetail {
            showType = .all
        } else if showImage && showTitle && !showDetail {
            showType = .bothImageTitle
        } else if showImage && showDetail && !showTitle {
            showType = .bothImageDetail
        } else if showTitle && showDetail && !showImage {
            showType = .bothTitleDetail
        } else if showImage && !showTitle && !showDetail {
            showType = .onlyImage
        } else if showTitle && !showImage && !showDetail {
            showType = .onlyTitle
        } else if showDetail && !showImage && !showTitle {
            showType = .onlyDetail
        }
        return showType
    }
    /// 根据 模型和展示类型 加载数据
    fileprivate func setupWith(showType: ReportTargetShowType, model: ReportTargetModel) {
        self.removeAllSubViews()
        // 注：其实该视图的高度是固定的。所以布局无需考虑高度问题.
        let iconWH: CGFloat = 40
        let iconMargin: CGFloat = 5
        let verMargin: CGFloat = 6
        let textIconMargin: CGFloat = 7
        let textLrMargin: CGFloat = 10

        switch showType {
        case .none:
            break
        case .onlyImage:
            self.addSubview(iconView)
            iconView.kf.setImage(with: URL(string: model.imageUrl!))
            iconView.snp.makeConstraints({ (make) in
                make.width.height.equalTo(iconWH)
                make.centerY.equalTo(self)
                make.leading.equalTo(self).offset(iconMargin)
            })
        case .onlyTitle:
            self.addSubview(titleLabel)
            titleLabel.text = model.title
            titleLabel.snp.makeConstraints({ (make) in
                make.centerY.equalTo(self)
                make.leading.equalTo(self).offset(textLrMargin)
                make.trailing.equalTo(self).offset(-textLrMargin)
            })
        case .onlyDetail:
            self.addSubview(detailLabel)
            detailLabel.text = model.body
            detailLabel.snp.makeConstraints({ (make) in
                make.centerY.equalTo(self)
                make.leading.equalTo(self).offset(textLrMargin)
                make.trailing.equalTo(self).offset(-textLrMargin)
            })
        case .bothImageTitle:
            self.addSubview(iconView)
            iconView.kf.setImage(with: URL(string: model.imageUrl!))
            iconView.snp.makeConstraints({ (make) in
                make.width.height.equalTo(iconWH)
                make.centerY.equalTo(self)
                make.leading.equalTo(self).offset(iconMargin)
            })
            self.addSubview(titleLabel)
            titleLabel.text = model.title
            titleLabel.snp.makeConstraints({ (make) in
                make.centerY.equalTo(self)
                make.leading.equalTo(iconView.snp.trailing).offset(textIconMargin)
                make.trailing.equalTo(self).offset(-textLrMargin)
            })
        case .bothImageDetail:
            self.addSubview(iconView)
            iconView.kf.setImage(with: URL(string: model.imageUrl!))
            iconView.snp.makeConstraints({ (make) in
                make.width.height.equalTo(iconWH)
                make.centerY.equalTo(self)
                make.leading.equalTo(self).offset(iconMargin)
            })
            self.addSubview(detailLabel)
            detailLabel.text = model.body
            detailLabel.snp.makeConstraints({ (make) in
                make.centerY.equalTo(self)
                make.leading.equalTo(iconView.snp.trailing).offset(textIconMargin)
                make.trailing.equalTo(self).offset(-textLrMargin)
            })
        case .bothTitleDetail:
            self.addSubview(titleLabel)
            titleLabel.text = model.title
            titleLabel.snp.makeConstraints({ (make) in
                make.leading.equalTo(self).offset(textLrMargin)
                make.trailing.equalTo(self).offset(-textLrMargin)
                make.bottom.equalTo(self.snp.centerY).offset(-CGFloat(verMargin) * 0.5)
            })
            self.addSubview(detailLabel)
            detailLabel.text = model.body
            detailLabel.snp.makeConstraints({ (make) in
                make.leading.equalTo(self).offset(textLrMargin)
                make.trailing.equalTo(self).offset(-textLrMargin)
                make.top.equalTo(self.snp.centerY).offset(CGFloat(verMargin) * 0.5)
            })
        case .all:
            self.addSubview(iconView)
            iconView.kf.setImage(with: URL(string: model.imageUrl!))
            iconView.snp.makeConstraints({ (make) in
                make.width.height.equalTo(iconWH)
                make.centerY.equalTo(self)
                make.leading.equalTo(self).offset(iconMargin)
            })
            self.addSubview(titleLabel)
            titleLabel.text = model.title
            titleLabel.snp.makeConstraints({ (make) in
                make.leading.equalTo(iconView.snp.trailing).offset(textIconMargin)
                make.trailing.equalTo(self).offset(-textLrMargin)
                make.bottom.equalTo(self.snp.centerY).offset(-CGFloat(verMargin) * 0.5)
            })
            self.addSubview(detailLabel)
            detailLabel.text = model.body
            detailLabel.snp.makeConstraints({ (make) in
                make.leading.equalTo(iconView.snp.trailing).offset(textIconMargin)
                make.trailing.equalTo(self).offset(-textLrMargin)
                make.top.equalTo(self.snp.centerY).offset(CGFloat(verMargin) * 0.5)
            })
        }
    }

    // MARK: - Private  事件响应

}
