//
//  TSRecommendExpertsSectionHeader.swift
//  ThinkSNS +
//
//  Created by 小唐 on 21/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  推荐专家的sectionHader
//  注1：用于问答发布中的悬赏邀请界面
//  注2：显示标题位置不是竖直方向居中，而是离底部很近。为了达到设计的效果

import Foundation
import UIKit

class TSRecommendExpertsSectionHeader: UITableViewHeaderFooterView {

    // MARK: - Internal Property
    static let headerHeight: CGFloat = 38
    static let identifier: String = "TSRecommendExpertsSectionHeaderReuseIdentifier"

    private(set) weak var titleLabel: UILabel!

    // MARK: - Internal Function

    class func headerInTableView(_ tableView: UITableView) -> TSRecommendExpertsSectionHeader {
        let identifier = self.identifier
        var headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if nil == headerFooterView {
            headerFooterView = TSRecommendExpertsSectionHeader(reuseIdentifier: identifier)
        }
        // 重置位置
        return headerFooterView as! TSRecommendExpertsSectionHeader
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
        let titleLabel = UILabel(text: "显示_推荐专家".localized, font: UIFont.systemFont(ofSize: 13), textColor: TSColor.normal.minor)
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.contentView).offset(15)
            make.bottom.equalTo(self.contentView).offset(-2)
        }
        self.titleLabel = titleLabel
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

}
