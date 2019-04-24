//
//  TSReleaseDynamicTool.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 发布动态工具类

import UIKit
import Photos
import KMPlaceholderTextView

class TSReleasePulseTool: NSObject {

    /// 设置展示字数Label
    ///
    /// - Parameter textView: textView
    class func setShowWordsCountLabelContent(textView: UITextView, showWordsCountLabel: UILabel, showWordsCount: Int, maxContentCount: Int) {
        if textView.text.count >= showWordsCount {
            showWordsCountLabel.isHidden = false
            showWordsCountLabel.attributedText = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: "\(textView.text.count)" as NSString, firstColor: TSColor.normal.statisticsNumberOfWords, firstSize: TSFont.SubInfo.statisticsNumberOfWords.rawValue), second: (secondString: "/\(maxContentCount)" as NSString, secondColor: TSColor.normal.blackTitle, TSFont.SubInfo.statisticsNumberOfWords.rawValue))
        } else {
            showWordsCountLabel.isHidden = true
        }
    }

    /// 限制titleView字数
    ///
    /// - Parameters:
    ///   - textView: textView description
    ///   - maximumWordLimit: 最大字数限制
    class func setTitleTextViewMaxWords(textView: UITextView, maximumWordLimit: Int, titleHeight: NSLayoutConstraint, titleTextView: KMPlaceholderTextView) {
        if textView.text.count > maximumWordLimit {
            let str = textView.text
            if let str = str {
                let aaa = str.substring(to: str.index(str.startIndex, offsetBy: maximumWordLimit))
                textView.text = aaa
                if textView.isEqual(titleTextView) {
                    let newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(MAXFLOAT)))
                    titleHeight.constant = newSize.height
                }
                return
            }
        }
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(MAXFLOAT)))
        titleHeight.constant = newSize.height
    }
}
