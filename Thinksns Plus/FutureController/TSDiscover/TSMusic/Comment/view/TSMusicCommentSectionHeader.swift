//
//  TSMusicCommentSectionHeader.swift
//  ThinkSNS +
//
//  Created by 小唐 on 26/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  音乐评论页面中的section

import Foundation
import UIKit

class TSMusicCommentSectionHeader: UITableViewHeaderFooterView {

    // MARK: - Internal Property
    static let headerHeight: CGFloat = 44
    static let identifier: String = "TSMusicCommentSectionHeaderReuseIdentifier"

    /// 标题
    private(set) weak var titleLabel: UILabel!

    // MARK: - Internal Function

    class func headerInTableView(_ tableView: UITableView) -> TSMusicCommentSectionHeader {
        let identifier = self.identifier
        var headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if nil == headerFooterView {
            headerFooterView = TSMusicCommentSectionHeader(reuseIdentifier: identifier)
        }
        // 重置位置
        return headerFooterView as! TSMusicCommentSectionHeader
    }

    // MARK: - Private Property

    // MARK: - Initialize Function

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        self.contentView.backgroundColor = UIColor.white
        // 1. topSeparator
        let topSeparator = UIView(bgColor: TSColor.inconspicuous.background)
        self.contentView.addSubview(topSeparator)
        topSeparator.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.contentView)
            make.height.equalTo(5)
        }
        // 2. titleLabel
        let titleLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: UIColor.black)
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topSeparator.snp.bottom)
            make.bottom.equalTo(self.contentView)
            make.leading.equalTo(self.contentView).offset(18)
        }
        self.titleLabel = titleLabel
        // 3. bottomLine
        self.contentView.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
        // 4. colorfulLine/greenLine
        let colorfulLine = UIView(bgColor: TSColor.main.theme)
        self.contentView.addSubview(colorfulLine)
        colorfulLine.snp.makeConstraints { (make) in
            make.height.equalTo(1.5)
            make.bottom.equalTo(self.contentView)
            make.leading.equalTo(titleLabel).offset(-8)
            make.trailing.equalTo(titleLabel).offset(8)
        }
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

}
