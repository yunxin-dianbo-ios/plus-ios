//
//  PostPublishGroupControl.swift
//  ThinkSNS +
//
//  Created by 小唐 on 27/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  帖子发布中的圈子圈子选择控件

import Foundation

class PostPublishGroupControl: UIControl {

    // MARK: - Internal Property

    var detail: String? {
        didSet {
            if let detail = detail {
                self.detailLabel.text = detail
                self.detailLabel.textColor = TSColor.main.content
            } else {
                self.detailLabel.text = "显示_请选择圈子".localized
                self.detailLabel.textColor = TSColor.normal.minor
            }
        }
    }

    /// 标题
    fileprivate let titleLabel = UILabel(text: "显示_选择圈子".localized, font: UIFont.systemFont(ofSize: 15), textColor: TSColor.main.content)
    /// 详情
    fileprivate let detailLabel = UILabel(text: "显示_请选择圈子".localized, font: UIFont.systemFont(ofSize: 15), textColor: TSColor.normal.minor, alignment: .right)
    /// rightArrow
    fileprivate let accessoryIcon = #imageLiteral(resourceName: "IMG_ic_arrow_smallgrey")
    fileprivate let accessoryView = UIImageView(image: #imageLiteral(resourceName: "IMG_ic_arrow_smallgrey"))

    // MARK: - Internal Function

    // MARK: - Private Property

    fileprivate let lrMargin: CGFloat = 10

    // MARK: - Initialize Function

    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Override Function

    // MARK: - Private  UI

    private func initialUI() -> Void {
        self.backgroundColor = UIColor.white
        // 1. titleLabel
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(lrMargin)
        }
        // 3. accessoryView
        self.addSubview(accessoryView)
        accessoryView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.size.equalTo(accessoryIcon.size)
            make.trailing.equalTo(self).offset(-lrMargin)
        }
        // 2. detailLabel
        self.addSubview(detailLabel)
        detailLabel.numberOfLines = 2
        detailLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.leading.equalTo(titleLabel.snp.trailing).offset(lrMargin)
            make.trailing.equalTo(accessoryView.snp.leading).offset(-3)
        }
    }

    // MARK: - Private  数据

    // MARK: - Private  事件

}
