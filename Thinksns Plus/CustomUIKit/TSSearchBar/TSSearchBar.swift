//
//  TSSearchBar.swift
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/5/2.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSSearchBar: UISearchBar, UITextFieldDelegate {

    var placeHolderFont: CGFloat = 12.0
    var _placeholderWidth: CGFloat = 0
    override func layoutSubviews() {
        super.layoutSubviews()
        for item in (self.subviews.last?.subviews)! {
            if item is UITextField {
                let field = item as? UITextField
                field?.frame = CGRect(x: 15, y: 7, width: self.frame.size.width - 30.0, height: self.frame.size.height - 15.0)
                field?.backgroundColor = UIColor.white
                field?.layer.cornerRadius = 2.0
                field?.layer.masksToBounds = true
                field?.textColor = UIColor(hex: 0x333333)
                field?.font = UIFont.systemFont(ofSize: 12)
                let attri = NSAttributedString(string: self.placeholder!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor(hex: 0x999999)])
                field?.attributedPlaceholder = attri
                if #available(iOS 11.0, *) {
                    // 先默认居中placeholder
                    self.setPositionAdjustment(UIOffset(horizontal: ((field?.frame.size.width)! - self.placeholderWidth) / 2, vertical: 0), for: .search)
                }
            }
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if #available(iOS 11.0, *) {
            self.setPositionAdjustment(UIOffset.zero, for: .search)
        }
        if (self.delegate?.responds(to: #selector(textFieldShouldBeginEditing(_:))))! {
            return (self.delegate?.searchBarShouldBeginEditing!(self))!
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if #available(iOS 11.0, *) {
            // 先默认居中placeholder
            if textField.text?.isEmpty == true {
                self.setPositionAdjustment(UIOffset(horizontal: (textField.frame.size.width - self.placeholderWidth) / 2, vertical: 0), for: .search)
            }
        }
        if (self.delegate?.responds(to: #selector(textFieldShouldEndEditing(_:))))! {
            return (self.delegate?.searchBarShouldEndEditing!(self))!
        }
        return true
    }
    var placeholderWidth: CGFloat! {
        set {
            _placeholderWidth = newValue
        }
        get {
            if _placeholderWidth < 1 {
                let size = self.placeholder?.boundingRect(with: CGSize(width: 100_010_001_000.0, height: 100_010_001_000.0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: self.placeHolderFont)], context: nil).size
                // icon与placeholder间距10
                // icon宽度
                return (size?.width)! + 10 + 20
            } else {
                return 2
            }
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
