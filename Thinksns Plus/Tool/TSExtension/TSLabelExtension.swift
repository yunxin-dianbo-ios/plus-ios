//
//  TSLabelExtension.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/07/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    convenience init(text: String?, font: UIFont, textColor: UIColor, alignment: NSTextAlignment = .left) {
        self.init(frame: CGRect.zero)
        self.textColor = textColor
        self.font = font
        self.text = text
        self.textAlignment = alignment
    }
}
