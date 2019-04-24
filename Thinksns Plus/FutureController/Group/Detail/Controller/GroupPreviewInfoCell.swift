//
//  GroupPreviewInfoCell.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/9/10.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class GroupPreviewInfoCell: UITableViewCell {
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var contentLab: UILabel!
    @IBOutlet weak var contentLabBC: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
