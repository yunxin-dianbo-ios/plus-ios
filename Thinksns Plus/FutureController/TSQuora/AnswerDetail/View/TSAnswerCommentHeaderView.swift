//
//  TSAnswerCommentHeaderView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  答案评论的头视图

import UIKit

class TSAnswerCommentHeaderView: UITableViewHeaderFooterView {

    // MARK: - Internal Property
    static let headerHeight: CGFloat = 40
    static let identifier: String = "TSAnswerCommentHeaderViewReuseIdentifier"
    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }

    // MARK: - Internal Function

    class func headerInTableView(_ tableView: UITableView) -> TSAnswerCommentHeaderView {
        let identifier = self.identifier
        var headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if nil == headerFooterView {
            headerFooterView = TSAnswerCommentHeaderView(reuseIdentifier: identifier)
        }
        // 重置位置
        return headerFooterView as! TSAnswerCommentHeaderView
    }

    // MARK: - Private Property
    private weak var titleLabel: UILabel!

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
        self.backgroundColor = UIColor.white
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
