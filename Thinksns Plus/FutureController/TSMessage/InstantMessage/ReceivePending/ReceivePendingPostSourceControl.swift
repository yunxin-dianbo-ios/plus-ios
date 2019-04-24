//
//  ReceivePendingPostSourceControl.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  帖子置顶里的帖子Control
//  目前按需求，只显示image 和 title，如果要显示3个，请参考ReportTargetControl

import Foundation

class ReceivePendingPostSourceControl: UIControl {

    // MARK: - Internal Property

    var model: PostDetailModel? {
        didSet {
            self.setupWithModel(model)
        }
    }
    /// 显示类型
    enum ShowType {
        /// 什么都不显示
        case none
        /// 仅显示title
        case onlyTitle
        /// 显示图片和Title
        case iconTitle
    }

    // MARK: - Private Property

    fileprivate let iconView: UIImageView = UIImageView(cornerRadius: 0)
    fileprivate let titleLabel: UILabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: TSColor.main.content)
    /// 只显示头像和标题，不显示正文
    //fileprivate let detailLabel: UILabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.minor)

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
        self.backgroundColor = TSColor.inconspicuous.background
        // 仅设置UI，不做布局处理
        self.titleLabel.numberOfLines = 2
    }

    // MARK: - Private  数据

    /// 数据加载
    fileprivate func setupWithModel(_ model: PostDetailModel?) -> Void {
        guard let model = model else {
            self.removeAllSubViews()
            return
        }
        let showType = self.showTypeWithModel(model)
        self.setupWith(showType: showType, model: model)
    }
    /// 根据数据模型获取展示类型
    fileprivate func showTypeWithModel(_ model: PostDetailModel) -> ShowType {
        var showType = ShowType.none
        showType = model.body.ts_customMarkdownToStandard().ts_getMarkdownImageUrl().isEmpty ? ShowType.onlyTitle : ShowType.iconTitle
        return showType
    }
    /// 根据 模型和展示类型 加载数据
    fileprivate func setupWith(showType: ShowType, model: PostDetailModel) {
        self.removeAllSubViews()
        self.titleLabel.text = nil
        self.iconView.image = nil
        // 注：其实该视图的高度是固定的。所以布局无需考虑高度问题.
        let iconWH: CGFloat = 28
        let iconMargin: CGFloat = 5
        let textIconMargin: CGFloat = 7
        let textLrMargin: CGFloat = 10

        switch showType {
        case .none:
            break
        case .onlyTitle:
            self.addSubview(titleLabel)
            titleLabel.text = model.title
            titleLabel.snp.makeConstraints({ (make) in
                make.leading.equalTo(self).offset(textLrMargin)
                make.trailing.equalTo(self).offset(-textLrMargin)
                make.centerY.equalTo(self)
            })
        case .iconTitle:
            self.addSubview(iconView)
            if let strUrl = model.body.ts_customMarkdownToStandard().ts_getMarkdownImageUrl().first {
                iconView.kf.setImage(with: URL(string: strUrl))
            }
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
                make.centerY.equalTo(self)
            })
        }
    }

    // MARK: - Private  事件响应

}
