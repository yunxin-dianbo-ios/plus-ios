//
//  TSDiscoverCell.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/9.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

private struct TSDiscoverCellUX {
    /// 整体内容距左右边的距离
    static let spaceMargin: CGFloat = 15
    /// 图标与栏目名称的间距
    static let spaceContent: CGFloat = 10
    /// 图片大小
    static let imageWidth: CGFloat = 20
    /// 分割线与左右边的距离
    static let lineHorizontalSpace: CGFloat = 10
    /// 右边箭头的宽度 （高度和左边图片的宽度相当）
    static let rowImageWidth: CGFloat = TSDiscoverCellUX.imageWidth * 0.5
    /// 标题label的宽度 （最多四个字，字号的4倍）
    static let titleLabelWidth: CGFloat = TSFont.Title.pulse.rawValue * 4 + 5

}

class TSDiscoverCell: UITableViewCell {
    /// 标签图片
    let img = TSImageView()
    /// 栏目标题
    let titleLbale = TSLabel()
    /// 消息文字（文字不一定显示）
    let messageLabel = TSLabel()
    /// 消息小圆点
    let redDots = UIView()
    /// 箭头
    let rowsView = TSImageView()
    /// 底部分割线
    let garyLine = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.makeBaseUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: - UI

    func makeBaseUI() {
        self.selectionStyle = .none
        self.img.frame = CGRect(x: TSDiscoverCellUX.spaceMargin, y: (TSDiscoverTableUX.tableCellHeight - TSDiscoverCellUX.imageWidth) / 2, width: TSDiscoverCellUX.imageWidth, height: TSDiscoverCellUX.imageWidth)
        self.contentView.addSubview(self.img)

        self.rowsView.frame = CGRect(x: ScreenSize.ScreenWidth - TSDiscoverCellUX.spaceMargin - TSDiscoverCellUX.rowImageWidth, y: (TSDiscoverTableUX.tableCellHeight - TSDiscoverCellUX.imageWidth) / 2, width: TSDiscoverCellUX.rowImageWidth, height: TSDiscoverCellUX.imageWidth)
        self.rowsView.image = UIImage(named: "IMG_ic_arrow_smallgrey")
        self.contentView.addSubview(self.rowsView)

        self.titleLbale.frame = CGRect(x: self.img.frame.maxX + TSDiscoverCellUX.spaceContent, y: 0, width: TSDiscoverCellUX.titleLabelWidth, height: TSDiscoverTableUX.tableCellHeight)
        self.titleLbale.font = UIFont.systemFont(ofSize: TSFont.Title.pulse.rawValue)
        self.titleLbale.textColor = TSColor.main.content
        self.contentView.addSubview(self.titleLbale)

        self.messageLabel.frame = CGRect(x: self.titleLbale.frame.maxX + TSDiscoverCellUX.spaceContent, y: 0, width: self.rowsView.frame.minX - self.titleLbale.frame.maxX - (TSDiscoverCellUX.spaceContent * 2), height: TSDiscoverTableUX.tableCellHeight)
        self.messageLabel.textAlignment = NSTextAlignment.right
        self.messageLabel.textColor = TSColor.normal.secondary
        self.messageLabel.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        self.messageLabel.isHidden = true
        self.contentView.addSubview(self.messageLabel)

        self.redDots.frame = CGRect(x: self.messageLabel.frame.width - 2, y: 15, width: 5, height: 5)
        self.redDots.layer.cornerRadius = 2.5
        self.redDots.backgroundColor = .red
        self.messageLabel.addSubview(self.redDots)

        self.garyLine.frame = CGRect(x: TSDiscoverCellUX.lineHorizontalSpace, y: TSDiscoverTableUX.tableCellHeight - 1, width: ScreenSize.ScreenWidth - (TSDiscoverCellUX.lineHorizontalSpace * 2), height: 0.5)
        self.garyLine.backgroundColor = TSColor.inconspicuous.disabled
        self.contentView.addSubview(self.garyLine)
    }
// MARK: - public Methods

    /// 设置 cell 的标题和 icon
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - iconName: icon
    func setCellInfo(title: String, iconName: String) {
        self.img.image = UIImage(named: iconName)
        self.titleLbale.text = title
    }

    /// 设置cell底部分割线是否显示
    ///
    /// - Parameter show: true：显示，false: 不显示
    func setLineShow(show: Bool) {
        show ? (self.garyLine.isHidden = false) : (self.garyLine.isHidden = true)
    }
    /// 更新消息提示
    /// 当 isReaded 为 true的时候 代表消息已读，此时 message 请传入一个空字符串（“”）
    /// 当 isReaded 为 false的时候 消息才会显示，此时请传入正确的消息文本
    ///
    /// - Parameters:
    ///   - message: 消息
    ///   - isReaded: 是否已读
    func reloadMessage(message: String, isReaded: Bool) {
        self.messageLabel.isHidden = isReaded
        self.messageLabel.text = message
    }

// MARK: - style
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
