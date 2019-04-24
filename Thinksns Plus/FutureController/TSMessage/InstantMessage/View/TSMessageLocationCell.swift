//
//  TSMessageLocationCell.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/6/23.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSMessageLocationCell: UITableViewCell {
    static let identifier = "TSMessageLocationCell"
    ///名字
    @IBOutlet weak var titltLable: UILabel!
    ///地址
    @IBOutlet weak var subLable: UILabel!
    // MARK: - Public
    func setInfo(model: AMapPOI?) {
        titltLable.text = model?.name
        subLable.text = model?.address
    }

    func setInfoTip(model: AMapTip) {
        titltLable.text = model.name
        subLable.text = model.address
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
