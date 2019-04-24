//
//  TSMusicCommentIntroCell.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSMusicCommentIntroCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!

    @IBOutlet weak var musicTitleLabel: UILabel!

    @IBOutlet weak var testCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setCellStyle()
    }

    private func setCellStyle() {
        self.selectionStyle = .none

        self.iconView.backgroundColor = TSColor.inconspicuous.background
        self.iconView.contentMode = UIViewContentMode.scaleAspectFill
        self.iconView.clipsToBounds = true

        self.musicTitleLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.musicTitleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.musicTitleLabel.textColor = TSColor.normal.blackTitle

        self.testCountLabel.textColor = TSColor.main.theme
        self.testCountLabel.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
    }

    public func reloadData(title: String, testCount: Int, strogeID id: Int) {
        self.iconView.kf.setImage(with: TSURLPath.imageV2URLPath(storageIdentity: id, compressionRatio: 32, size: nil))
        self.musicTitleLabel.text = title
        self.testCountLabel.text = "\(testCount)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
