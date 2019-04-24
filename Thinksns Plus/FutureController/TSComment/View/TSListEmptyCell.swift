//
//  TSListEmptyCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 07/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  列表为空时的占位视图(占位的空Cell)
/***
    使用Cell而不是使用View或直接在UITableView中创建，是因为
        列表数据为空，不代表TableView为空，因为TableView可能有头视图；或者有SectionHeader；甚至为空的是主要Section中的内容而别的section仍然有内容如广告。
 */

import Foundation
import UIKit

class TSListEmptyCell: UITableViewCell {

    // MARK: - Internal Property
    /// 空视图的高度，由外界构造时传入，默认为250。既能自适应高度，也能设置高度。
    let cellHeight: CGFloat
    /// 重用标识符
    static let identifier: String = "TSListEmptyCellReuseIdentifier"
    /// 提示标题
    var prompt: String? {
        didSet {
            self.promptLabel.text = prompt
        }
    }

    // MARK: - Private Property
    private(set) weak var promptLabel: UILabel!

    // MARK: - Internal Function

    class func cellInTableView(_ tableView: UITableView, cellHeight: CGFloat = 250) -> TSListEmptyCell {
        let identifier = TSListEmptyCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = TSListEmptyCell(style: .default, reuseIdentifier: identifier, cellHeight: cellHeight)
        }
        // 重置位置
        cell?.selectionStyle = .none
        return cell as! TSListEmptyCell
    }

    // MARK: - Initialize Function

    init(style: UITableViewCellStyle, reuseIdentifier: String?, cellHeight: CGFloat) {
        self.cellHeight = cellHeight
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        self.cellHeight = 250
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
            // 高度约束，外界既可采用设置高度方式，也可采用自适应方式。
            make.height.equalTo(self.cellHeight)
        }
    }
    // 主视图布局
    private func initialMainView(_ mainView: UIView) -> Void {
        mainView.backgroundColor = TSColor.inconspicuous.background
        // promptLabel
        let promptLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 18), textColor: UIColor(hex: 0xcccccc), alignment: .center)
        mainView.addSubview(promptLabel)
        promptLabel.numberOfLines = 0
        promptLabel.snp.makeConstraints { (make) in
            make.center.equalTo(mainView)
            make.leading.equalTo(mainView).offset(20)
            make.trailing.equalTo(mainView).offset(-20)
        }
        self.promptLabel = promptLabel
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

}
