//
//  TSAnswerEmptyCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 02/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题详情中答案列表为空时展示的cell

import UIKit

class TSAnswerEmptyCell: UITableViewCell {

    // MARK: - Internal Property
//    static let cellHeight: CGFloat = 250
    static let identifier: String = "TSAnswerEmptyCellReuseIdentifier"

    // MARK: - Private Property

    // MARK: - Internal Function

    class func cellInTableView(_ tableView: UITableView) -> TSAnswerEmptyCell {
        let identifier = TSAnswerEmptyCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = TSAnswerEmptyCell(style: .default, reuseIdentifier: identifier)
        }
        // 重置位置
        return cell as! TSAnswerEmptyCell
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
        self.contentView.backgroundColor = TSColor.inconspicuous.background
        // promptLabel
        let promptLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 18), textColor: UIColor(hex: 0xcccccc), alignment: .center)
        self.contentView.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.contentView)
            make.top.equalTo(self.contentView).offset(105)
            make.bottom.equalTo(self.contentView).offset(-105)
        }
        promptLabel.text = "还没有回答~".localized
    }

}
