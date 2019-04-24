//
//  TSCustomActionsheetTableViewCell.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/1/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSCustomActionsheetTableViewCell: UITableViewCell {

    public var describeText: String? {
        get {
            return self.describeText
        }

        set {
            describeLabel.text = newValue
        }
    }

    @IBOutlet weak var describeLabel: UILabel!

}
