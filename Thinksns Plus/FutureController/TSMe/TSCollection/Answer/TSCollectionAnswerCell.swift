//
//  TSCollectionAnswerCell.swift
//  ThinkSNSPlus
//
//  Created by 小唐 on 20/03/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  收藏回答Cell
//  注1：特殊处理该回答被删除时，但该收藏仍然存在的情况
//  注2：收藏回答Cell暂时使用TSMyAnswerListCell

import Foundation

/// 收藏回答Cell
class TSCollectionAnswerCell: UITableViewCell {

    // MARK: - Internal Property

    /// 重用标识符
    static let identifier: String = "TSCollectionAnswerCellReuseIdentifier"

    // MARK: - Private Property

    // MARK: - Internal Function

    class func cellInTableView(_ tableView: UITableView) -> TSCollectionAnswerCell {
        let identifier = TSCollectionAnswerCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = TSCollectionAnswerCell(style: .default, reuseIdentifier: identifier)
        }
        // 重置位置
        return cell as! TSCollectionAnswerCell
    }

    // MARK: - Initialize Function

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Override Function

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // mainView - 整体布局，便于扩展，特别是针对分割、背景色、四周间距
        let mainView = UIView()
        self.contentView.addSubview(mainView)
        self.initialMainView(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }
    // 主视图布局
    private func initialMainView(_ mainView: UIView) -> Void {

    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

}
