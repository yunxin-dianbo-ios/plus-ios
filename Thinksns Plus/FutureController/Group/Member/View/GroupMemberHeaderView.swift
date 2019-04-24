//
//  GroupMemberHeaderView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 13/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  成员列表的headerView

import UIKit

class GroupMemberHeaderView: UITableViewHeaderFooterView {

    // MARK: - Internal Property
    static let headerHeight: CGFloat = 35
    static let identifier: String = "GroupMemberHeaderViewReuseIdentifier"

    private(set) weak var titleLabel: UILabel!

    // MARK: - Internal Function

    class func headerInTableView(_ tableView: UITableView) -> GroupMemberHeaderView {
        let identifier = self.identifier
        var headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if nil == headerFooterView {
            headerFooterView = GroupMemberHeaderView(reuseIdentifier: identifier)
        }
        // 重置位置
        return headerFooterView as! GroupMemberHeaderView
    }

    // MARK: - Private Property

    fileprivate let leftMargin: CGFloat = 15

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
        self.contentView.backgroundColor = TSColor.inconspicuous.background
        let nameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 13), textColor: TSColor.normal.minor)
        self.contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.contentView).offset(leftMargin)
            make.centerY.equalTo(self.contentView)
        }
        self.titleLabel = nameLabel
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

}
