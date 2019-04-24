//
//  TSMusicCommentToolView.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

struct TSMusicCommentToolViewUX {
    /// 回复框的高度
    static let commentToolViewHeight: CGFloat = 44
}

protocol TSMusicCommentToolViewDelegate: class {
    func sendMessage(text: String)
    func commentViewResignFirstResponder()
}

class TSMusicCommentToolView: UIView, TSMusicCommentTextViewDelegate {

    var commentToolView: TSMusicCommentTextView? = nil

    weak var delegate: TSMusicCommentToolViewDelegate? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = TSColor.main.white
        creatTextCommentView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func creatTextCommentView() {

        self.commentToolView = TSMusicCommentTextView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), superViewSourceHeight: TSMusicCommentToolViewUX.commentToolViewHeight)
        self.commentToolView?.toolBarViewDelegate = self
        guard let textToolBarView = commentToolView else {
            assert(false, "\(TSTextToolBarView.self)初始化失败")
            return
        }

        textToolBarView.changeHeightClosure = {[weak self] value in
            if let weak = self {
                var frame = weak.frame
                frame.origin.y = frame.origin.y - (value - frame.height)
                frame.size.height = value
                weak.frame = frame
            }
        }
        self.addSubview(self.commentToolView!)
    }

    // MARK: - delegate
    func sendTextMessage(message: String, inputBox: AnyObject?) {
        if self.delegate != nil {
            self.delegate?.sendMessage(text: message)
        }
    }

    func removeToolBar() {
        if self.delegate != nil {
            self.delegate?.commentViewResignFirstResponder()
        }
    }

    func emojiClick(emoji: String) {
        self.commentToolView?.sendTextView.insertText(emoji)
        self.commentToolView?.sendTextView.scrollRangeToVisible((self.commentToolView?.sendTextView.selectedRange)!)
    }

    func setPlaceHolderText(text: String) {
        self.commentToolView?.sendTextView.placeholder = text
    }

    func showView() {
        self.commentToolView?.sendTextView.becomeFirstResponder()
    }

    func hiddenView() {
        self.commentToolView?.sendTextView.resignFirstResponder()
    }
}
