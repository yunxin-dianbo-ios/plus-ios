//
//  TSCommentEmptyCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 07/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  评论列表为空时的展示Cell
//  参考TSAnswerEmptyCell，可提取一个公共类Cell出来 TSListEmptyCell 或 TSListEmptyView

import Foundation
import UIKit

class TSCommentEmptyCell: UITableViewCell {
    // MARK: - Internal Property
    static let cellHeight: CGFloat = 250
    /// 重用标识符
    static let identifier: String = "TSCommentEmptyCellReuseIdentifier"
    // MARK: - Private Property
    // MARK: - Internal Function
    class func cellInTableView(_ tableView: UITableView) -> TSCommentEmptyCell {
        let identifier = TSCommentEmptyCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = TSCommentEmptyCell(style: .default, reuseIdentifier: identifier)
        }
        // 重置位置
        cell?.selectionStyle = .none
        return cell as! TSCommentEmptyCell
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
            // 高度约束，外界既可采用设置高度方式，也可采用自适应方式。
            make.height.equalTo(TSCommentEmptyCell.cellHeight)
        }
    }
    // 主视图布局
    private func initialMainView(_ mainView: UIView) -> Void {
        mainView.backgroundColor = TSColor.inconspicuous.background
        let imageView = TSImageView()
        imageView.image = UIImage(named: "IMG_img_default_nothing")
        imageView.contentMode  = .center
        mainView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
}
