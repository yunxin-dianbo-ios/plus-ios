//
//  QuoraStackFullImageCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答列表 拉伸图片 cell

import UIKit
import Kingfisher
import SnapKit

class QuoraStackFullImageCell: UITableViewCell {

    /// 图片
    let buttonForImage: UIButton = {
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .scaleAspectFill
        button.contentMode = .scaleAspectFill
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        // 暂时未用到点击事件
        button.isUserInteractionEnabled = false
        return button
    }()

    /// 是否已经更新了约束
    var didSetupConstraints = false

    /// 数据
    var model: QuoraStackFullImageCellModel! {
        didSet {
            setInfo()
        }
    }

    static let identifier = "QuoraStackFullImageCell"

    class func cellForm(table: UITableView, at indexPath: IndexPath, with data: QuoraStackFullImageCellModel) -> QuoraStackFullImageCell {
        let cell = table.dequeueReusableCell(withIdentifier: QuoraStackFullImageCell.identifier, for: indexPath) as! QuoraStackFullImageCell
        cell.model = data
        return cell
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(buttonForImage)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.addSubview(buttonForImage)
    }

    // MARK: - Private
    private func setInfo() {
        // 更新图片的内容
        buttonForImage.kf.setImage(with: model.imageURL, for: .normal)
        // 更新图片的位置
        buttonForImage.frame = CGRect(x: 0, y: model.top, width: UIScreen.main.bounds.width, height: model.imageHeight)
    }
}
