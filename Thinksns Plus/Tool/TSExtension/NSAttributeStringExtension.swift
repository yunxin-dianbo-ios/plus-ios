//
//  NSAttributeStringExtension.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/10/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

extension String {
    func attributonString() -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
}

extension NSMutableAttributedString {
    /// 设置全部文字字体
    ///
    /// - Parameter font: 字体
    /// - Returns: 富文本
    func setAllTextFont(font: UIFont) -> NSMutableAttributedString {
        let attributeString = self
        attributeString.addAttributes([NSFontAttributeName: font], range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
    /// 设置文字字体大小
    ///
    /// - Parameter font: 字体大小
    /// - Returns: 文字
    func setTextFont(_ font: CGFloat) -> NSMutableAttributedString {
        let attributeString = self
        attributeString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: font)], range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }

    /// 给文字添加行间距
    ///
    /// - Parameters:
    ///   - lineSpacing: 行间距
    /// - Returns: 格式后的文字
    func setlineSpacing(_ lineSpacing: CGFloat) -> NSMutableAttributedString {
        let attributeString = self
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = lineSpacing / 2.0
        paragraphStyle.headIndent = 0.000_1
        paragraphStyle.tailIndent = -0.000_1
        paragraphStyle.alignment = .left
        attributeString.addAttributes([NSParagraphStyleAttributeName: paragraphStyle], range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }

    /// 给文字添加字间距
    ///
    /// - Parameter kerning: 字间距
    /// - Returns: 文字
    func setKerning(_ kerning: CGFloat) -> NSMutableAttributedString {
        let attributeString = self
        attributeString.addAttributes([NSKernAttributeName: kerning], range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }

    /// 添加付费模糊效果
    ///
    /// - Returns: 文字
    func addFuzzyString() -> NSMutableAttributedString {
        // 1.设置占位文字
        let payPlaceholder = "智士软件通过Sociax社会化平台，致力于成为企业2.0及社会化软件领域的领导者。我们的项目始于 2008年，由一群80后的创业团队，基于国内外先进的SNS及Web2.0技术理念，以Think工作室的形式，首先推出开源社区平台 --ThinkSNS，并在个人、企业和非营利组织中快速传播，队伍不断壮大。"
        let normalString = self
        let attributeString = NSMutableAttributedString(string: self.string + payPlaceholder)
        // 1.将 self 原有的 attributes 添加给 attributeString
        if let attributes = self.attributes {
            attributeString.addAttributes(attributes, range: NSRange(location: 0, length: attributeString.length))
        }
        // 2.将需要付费的范围进行模糊
        let blurRange = NSRange(location: normalString.length, length: attributeString.length - normalString.length)
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 6
        attributeString.addAttributes([NSShadowAttributeName: shadow, NSStrokeWidthAttributeName: 1, NSStrokeColorAttributeName: UIColor.white], range:blurRange)
        return attributeString
    }
}
