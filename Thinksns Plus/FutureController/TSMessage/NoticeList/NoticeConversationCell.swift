//
//  NoticeConversationCell.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

struct NoticeConversationCellModel {
    let title: String
    let content: String
    let badgeCount: Int
    let date: Date?
    let image: String
    func badgeValue() -> Int {
        if badgeCount > 99 {
            return 99
        }
        return badgeCount
    }
}

class NoticeConversationCell: TSTableViewCell {
    weak var coverView: UIImageView!
    weak var titleLabel: TSLabel!
    weak var contentLabel: TSLabel!
    weak var timeLabel: TSLabel!
    weak var countButtton: UIButton!
    var model: NoticeConversationCellModel = NoticeConversationCellModel(title: "title", content: "content", badgeCount: 0, date: nil, image: "") {
        didSet {
            load(model: model)
        }
    }

    // MARK: - lifecycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let coverView = UIImageView()
        self.coverView = coverView

        let titleLabel = TSLabel()
        titleLabel.font = UIFont.systemFont(ofSize: TSFont.UserName.navigation.rawValue)
        titleLabel.textColor = TSColor.main.content
        self.titleLabel = titleLabel

        let contentLabel = TSLabel()
        contentLabel.font = UIFont.systemFont(ofSize: TSFont.UserName.listPulse.rawValue)
        contentLabel.textColor = TSColor.normal.minor
        contentLabel.lineBreakMode = .byTruncatingMiddle
        self.contentLabel = contentLabel

        let timeLabel = TSLabel()
        timeLabel.font = UIFont.systemFont(ofSize: TSFont.Time.normal.rawValue)
        timeLabel.textColor = TSColor.normal.disabled
        timeLabel.textAlignment = .right
        self.timeLabel = timeLabel

        let countButtton = UIButton(type: .custom)
        countButtton.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Time.normal.rawValue)
        countButtton.isUserInteractionEnabled = false
        countButtton.titleLabel?.textColor = TSColor.main.white
        countButtton.backgroundColor = TSColor.main.warn
        countButtton.clipsToBounds = true
        self.countButtton = countButtton

        contentView.addSubview(coverView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(countButtton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("不支持xib使用")
    }

    func load(model: NoticeConversationCellModel) {
        coverView.image = UIImage(named: model.image)
        titleLabel.text = model.title
        contentLabel.text = model.content
        if let date = model.date {
            timeLabel.text = TSDate().dateString(.normal, nsDate: date as NSDate)
            timeLabel.isHidden = false
        } else {
            timeLabel.isHidden = true
        }
        let countStr = "\(model.badgeValue())"
        countButtton.setTitle(countStr, for: .normal)
        countButtton.isHidden = model.badgeValue() <= 0
        countButtton.layer.cornerRadius = 15/*设计高度*/ * 0.5

        coverView.snp.remakeConstraints { (mark) in
            mark.width.equalTo(38)
            mark.height.equalTo(38)
            mark.top.equalToSuperview().offset(15)
            mark.left.equalToSuperview().offset(10)
        }
        titleLabel.snp.remakeConstraints { (mark) in
            mark.left.equalTo(coverView.snp.right).offset(15)
            mark.top.equalToSuperview().offset(15)
            mark.height.equalTo(16)

            mark.right.equalTo(timeLabel.snp.left).offset(-15)
        }
        contentLabel.snp.remakeConstraints { (mark) in
            mark.left.equalTo(coverView.snp.right).offset(15)
            mark.top.equalTo(titleLabel.snp.bottom).offset(7)
            mark.right.equalTo(timeLabel.snp.left).offset(-15)
        }
        timeLabel.snp.remakeConstraints { (mark) in
            mark.right.equalToSuperview().offset(-9)
            mark.top.equalToSuperview().offset(18)
            mark.left.equalTo(titleLabel.snp.right).offset(15)
        }
        countButtton.snp.remakeConstraints { (mark) in
            mark.right.equalToSuperview().offset(-18)
            mark.height.equalTo(15)
            mark.centerY.equalTo(contentLabel.snp.centerY)
            if model.badgeValue() > 9 {
                mark.width.equalTo(22)
            } else {
                mark.width.equalTo(15)
            }
        }
    }
}
