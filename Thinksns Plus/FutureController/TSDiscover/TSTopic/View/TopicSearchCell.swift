//
//  TopicSearchCell.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/24.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TopicSearchCell: UITableViewCell {
    static let identifier = "TopicSearchCell"

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var titleText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setInfo(model: TopicListModel, keyword: String?) {
        titleText.text = model.topicTitle
        if keyword == "" || keyword == nil {
            titleText.attributedText = nil
            titleText.text = model.topicTitle
        } else {
            let rangeArr = NSArray(array: LabelLineText.range(ofSubString: keyword, in: titleText.text))
            if rangeArr.count != 0 {
                let mutal = NSMutableAttributedString(string: titleText.text ?? "")
                let para = [NSForegroundColorAttributeName: TSColor.main.theme]
                for item in rangeArr {
                    let itemString: String = item as! String
                    let range: NSRange = NSRangeFromString(itemString)
                    mutal.addAttributes(para, range: range)
                }
                titleText.attributedText = mutal
            }
        }
    }
}
