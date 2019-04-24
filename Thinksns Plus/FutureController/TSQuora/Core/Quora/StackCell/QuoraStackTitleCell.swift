//
//  QuoraStackTitleCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答列表 标题 cell 

import UIKit

class QuoraStackTitleCell: UITableViewCell {

    /// 标题
    let labelForTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    /// 是否已经更新了约束
    var didSetupConstraints = false

    /// 数据
    var model: QuoraStackTitleCellModel?

    static let identifier = "QuoraStackTitleCell"

    class func cellForm(table: UITableView, at indexPath: IndexPath, with data: inout QuoraStackTitleCellModel) -> QuoraStackTitleCell {
        let cell = table.dequeueReusableCell(withIdentifier: QuoraStackTitleCell.identifier, for: indexPath) as! QuoraStackTitleCell
        cell.setInfo(model: &data)
        return cell
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(labelForTitle)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.addSubview(labelForTitle)
    }

    // MARK: - Private

    /// 设置展示内容
    private func setInfo(model: inout QuoraStackTitleCellModel) {
        self.model = model

        let screenWidth = UIScreen.main.bounds.width
        // 1.设置文本内容
        labelForTitle.text = model.title
        labelForTitle.font = UIFont.systemFont(ofSize: model.font)
        labelForTitle.textColor = model.textColor
        labelForTitle.frame = CGRect(x: model.left, y: model.top, width: (screenWidth - model.left - model.right), height: 0)
        // 设置尾部图片
        addAppedImage(type: model.appendImage, title: model.title)
        labelForTitle.sizeToFit()
        // 2.计算内部控件的高度
        model.labelHeight = labelForTitle.frame.height
    }

    /// 设置尾部图片
    private func addAppedImage(type: QuoraStackTitleCellModel.AppendImageType?, title: String) {
        guard let type = type else {
            return
        }
        var imageName = ""
        switch type {
        case .excellent:
            imageName = "IMG_ico_quora_choice"
        }
        guard !imageName.isEmpty else {
            return
        }
        let image = UIImage(named: imageName)
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2.5), size: image!.size)
        let attachmentString = NSAttributedString(attachment: attachment)
        let titleString = NSMutableAttributedString(string: title + " ")

        titleString.append(attachmentString)
        labelForTitle.attributedText = titleString
    }
}
