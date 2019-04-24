//
//  TSQuestionRelativeCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 04/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题相关Cell

import UIKit

class TSQuestionRelativeCell: UITableViewCell {

    // MARK: - Internal Property
    /// 重用标识符
    static let identifier: String = "TSQuestionRelativeCellReuseIdentifier"
    /// 数据
    var question: String? {
        didSet {
            self.questionLabel.text = question
        }
    }

    // MARK: - Private Property
    private weak var questionLabel: UILabel!

    // MARK: - Internal Function

    class func cellInTableView(_ tableView: UITableView) -> TSQuestionRelativeCell {
        let identifier = TSQuestionRelativeCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = TSQuestionRelativeCell(style: .default, reuseIdentifier: identifier)
        }
        // 重置位置
        return cell as! TSQuestionRelativeCell
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
        let lrMargin: CGFloat = 20
        let tbMargin: CGFloat = 20
        // 1. questionLabel
        let questionLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15), textColor: TSColor.normal.content)
        self.contentView.addSubview(questionLabel)
        questionLabel.numberOfLines = 2
        questionLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.contentView)
            make.top.equalTo(self.contentView).offset(tbMargin)
            make.bottom.equalTo(self.contentView).offset(-tbMargin)
            make.leading.equalTo(self.contentView).offset(lrMargin)
            make.trailing.equalTo(self.contentView).offset(-lrMargin)
        }
        self.questionLabel = questionLabel
        // 2. separateLine
        self.contentView.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
    }

}
