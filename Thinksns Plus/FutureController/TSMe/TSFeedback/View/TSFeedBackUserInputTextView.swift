//
//  TSFeedBackUserInputTestView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 反馈内容和字数限制显示

import UIKit
import KMPlaceholderTextView

protocol feedBackUserInputAvailabilityDelegate: NSObjectProtocol {
    /// 检查用户输入的字符串
    func feedBackUserInputAvailability(inputStr: String)
}

class TSFeedBackUserInputTextView: UIView, UITextViewDelegate {
    // KMPlaceholderTextView
    public var feedcontent: KMPlaceholderTextView = KMPlaceholderTextView()
    // 字数限制显示label
    public let showWordCountLabel: UILabel = UILabel()
    // 最大反馈内容字数
    let maxfeedbacktextview: Int = 200

    weak var feedBackUserInputAvailabilityDelegate: feedBackUserInputAvailabilityDelegate? = nil

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = TSColor.main.white
        setFeedcontent()
    }
    // MARK: - UI
    func setFeedcontent() {
        feedcontent.placeholder = "占位符_意见反馈".localized
        feedcontent.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        feedcontent.placeholderColor = TSColor.normal.disabled
        feedcontent.placeholderFont = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        feedcontent.delegate = self
        self.addSubview(feedcontent)
        feedcontent.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(15)
            make.left.equalTo(self).offset(14)
            make.right.equalTo(self).offset(-14)
            make.bottom.equalTo(self).offset(-9.5)
        }
        showWordCountLabel.text = "显示_200".localized
        showWordCountLabel.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        showWordCountLabel.textColor = TSColor.normal.disabled
        showWordCountLabel.backgroundColor = UIColor.clear
        showWordCountLabel.textAlignment = .right
        self.addSubview(showWordCountLabel)
        showWordCountLabel.snp.makeConstraints { (make) in
            make.height.equalTo(9.5)
            make.width.equalTo(100)
            make.bottom.equalTo(feedcontent)
            make.right.equalTo(feedcontent)
        }
    }

    internal func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" || text == "\n\r"{
            feedcontent.resignFirstResponder()
            return false
        }
        return true
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.isEqual(feedcontent) {
            self.feedBackUserInputAvailabilityDelegate?.feedBackUserInputAvailability(inputStr: feedcontent.text)
            guard !feedcontent.text.isEmpty else {
                showWordCountLabel.text = "显示_200".localized
                return
            }
            let contstring: String = "\(feedcontent.text.count)"
            showWordCountLabel.attributedText = NSMutableAttributedString().differentColorAndSizeString(first: (contstring as NSString, TSColor.main.warn, TSFont.SubInfo.mini.rawValue), second: ("/200", TSColor.normal.disabled, TSFont.SubInfo.mini.rawValue))
        }
    }
}
