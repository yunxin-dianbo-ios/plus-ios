//
//  TSCommentHeaderView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 07/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  评论列表的SectionHeader

import Foundation
import UIKit

class TSCommentHeaderView: UITableViewHeaderFooterView {

    // MARK: - Internal Property
    static let headerHeight: CGFloat = 40
    static let identifier: String = "TSCommentHeaderViewReuseIdentifier"
    /// 评论数标题
    var commentCount: Int = 0 {
        didSet {
            self.titleLabel.text = "\(commentCount)条评论"
        }
    }

    // MARK: - Internal Function

    class func headerInTableView(_ tableView: UITableView) -> TSCommentHeaderView {
        let identifier = self.identifier
        var headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if nil == headerFooterView {
            headerFooterView = TSCommentHeaderView(reuseIdentifier: identifier)
        }
        // 重置位置
        return headerFooterView as! TSCommentHeaderView
    }

    // MARK: - Private Property
    private(set) weak var titleLabel: UILabel!

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
        // 0. self
        self.contentView.backgroundColor = UIColor.white
        // 1. titleLabel
        let titleLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: UIColor.black)
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.contentView)
            make.leading.equalTo(self.contentView).offset(17.5)
        }
        self.titleLabel = titleLabel
        // 3. separateLine
        self.contentView.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
        // 2. bottomLine
        let bottomLine = UIView(bgColor: TSColor.main.theme)
        self.contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.contentView)
            make.height.equalTo(2)
            make.centerX.equalTo(titleLabel)
            make.width.equalTo(titleLabel).offset(10)
        }
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

}
