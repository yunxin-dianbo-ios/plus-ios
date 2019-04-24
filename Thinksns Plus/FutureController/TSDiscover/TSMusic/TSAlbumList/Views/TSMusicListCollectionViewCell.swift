//
//  TSMusicListCollectionViewCell.swift
//  LiusSwiftDemo
//
//  Created by LiuYu on 2017/2/10.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  “音乐FM”专辑列表的cell

import UIKit
import Kingfisher

class TSMusicListCollectionViewCell: UICollectionViewCell {
    static let identifier = "TSMusicListCollectionViewCell"
// MARK: - 控件
    // 收听数
    @IBOutlet weak var listenInCount: UILabel!
    // 封面
    @IBOutlet weak var coverImage: UIImageView!
    // 耳机
    @IBOutlet weak var earphoneImage: UIImageView!
    // 简介
    @IBOutlet weak var introLabel: UILabel!
    /// 封面图上的渐变色蒙版
//    let coverImageView: UIImageView = UIImageView()
    // 专辑付费图标
    @IBOutlet weak var payIcon: UIImageView!

// MARK: - 数据
    // 数据模型
    var cellData: TSAlbumListModel?

// MARK: - 生命周期
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.borderWidth = 1
        self.layer.borderColor = InconspicuousColor().disabled.cgColor
        self.coverImage.backgroundColor = TSColor.inconspicuous.disabled
        self.listenInCount.layer.shadowColor = UIColor.black.cgColor
        self.listenInCount.layer.shadowOffset = CGSize(width: -1, height: 0)
        self.listenInCount.layer.shadowRadius = 3
        self.listenInCount.layer.shadowOpacity = 0.4

    }

// MARK: - Public Method
    /// 填充cell数据
    public func setItemData(cellData: TSAlbumListModel) {
        self.cellData = cellData

        let coverUrl = TSURLPath.imageV2URLPath(storageIdentity: cellData.storage?.id, compressionRatio: 50, size: cellData.storage?.size)
        let placeholder = UIImage.create(with: TSColor.inconspicuous.disabled, size: self.coverImage.frame.size)
        self.coverImage.kf.setImage(with: coverUrl, placeholder: placeholder, options: nil, progressBlock: nil, completionHandler: nil)
        self.listenInCount.text = String(cellData.tasteCount)
        self.introLabel.attributedText = self .setLineSpace(cellData.title, lineSpace: 3)
        self.payIcon.isHidden = (nil == cellData.paidNode) ? true : false   // 是否展示付费标记
    }

// MARK: - private Method
    // 设置文字行间距
    func setLineSpace(_ string: String, lineSpace: CGFloat) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        let paragraphStye = NSMutableParagraphStyle()

        paragraphStye.lineSpacing = lineSpace
        let rang = NSRange(location: 0, length: CFStringGetLength(string as CFString))
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStye, range: rang)
        return attributedString
    }
}
