//
//  TSMessagePopoutVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/8.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher

class TSMessagePopoutVC: UIViewController, TSSystemEmojiSelectorViewDelegate {

    /// 整体白色背景视图与屏幕左右的间距
    var margin: CGFloat = 46.0 * ScreenWidth / 375.0
    /// 整体白色背景视图的高度
    var whiteHeight: CGFloat = 479 / 2.0
    /// 整体白色背景的宽度
    var whiteWidth: CGFloat = ScreenWidth - (46.0 * ScreenWidth / 375.0) * 2
    /// 整体白色背景的内部视图与白色背景左右间距
    var inMargin: CGFloat = 20.0
    /// 有透明度的背景视图
    var bgView = UIView()
    /// 整体白色背景视图
    var whiteView = UIView()
    /// 发送给谁 主题文字
    var titleLabel = UILabel()
    /// 分割线1
    var firstLine = UIView()
    /// 内容背景视图
    var contentBgView = UIView()
    /// 内容所属者
    var contentOwnerLabel = UILabel()
    /// 视频或者图片 icon
    var imageIcon = UIImageView()
    /// 内容
    var contentLabel = UILabel()
    /// 圈子图片、帖子图片、资讯图片
    var coverImage = UIImageView()
    /// 留言框背景视图
    var textBgView = UIView()
    /// 留言框
    var textInputView = UITextView()
    /// 输入框默认文字
    var placeHolderButton = UILabel()
    /// 表情按钮
    var smileButton = UIButton(type: .custom)
    /// 分割线2
    var secondLine = UIView()
    /// 分割线3
    var thirdLine = UIView()
    /// 取消按钮
    var cancelButton = UIButton(type: .custom)
    /// 发送按钮
    var sureButton = UIButton(type: .custom)
    var currentKbH: CGFloat = 0
    /// 确定按钮信息回传
    var sendBlock: ((TSmessagePopModel) -> Void)?
    /// 当前的model
    var sendModel: TSmessagePopModel!
    /// 选择Emoji的视图
    var emojiView: TSSystemEmojiSelectorView!
    let MAX_STARWORDS_LENGTH = 255

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHideNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewBeginEditingNotificationProcess(_:)), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewEndEditingNotificationProcess(_:)), name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(textViewDidChanged(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        setUI()
        emojiView = TSSystemEmojiSelectorView(frame: CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: 0))
        emojiView.delegate = self
        view.addSubview(emojiView)
    }

    func setUI() {
        whiteView.frame = CGRect(x: margin, y: 0, width: whiteWidth, height: whiteHeight)
        whiteView.backgroundColor = UIColor.white
        whiteView.layer.cornerRadius = 5.0
        whiteView.centerY = ScreenHeight / 2.0
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(whiteViewTap))
        whiteView.addGestureRecognizer(tap)
        self.view.addSubview(whiteView)

        /// 这里高度原本是16 但是避免文字显示不完整，扩大了 4 ，Y坐标就向上偏移 2
        titleLabel.frame = CGRect(x: inMargin, y: 20 - 2, width: whiteWidth - inMargin * 2, height: 20)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor(hex: 0x333333)
        whiteView.addSubview(titleLabel)
//
//        firstLine.frame = CGRect(x: inMargin, y: titleLabel.bottom + 13, width: whiteWidth - inMargin * 2, height: 0.5)
//        firstLine.backgroundColor = TSColor.inconspicuous.disabled
//        whiteView.addSubview(firstLine)

        contentBgView.frame = CGRect(x: inMargin, y: titleLabel.bottom + 13, width: whiteWidth - inMargin * 2, height: 55.0)
        contentBgView.backgroundColor = TSColor.inconspicuous.disabled
        whiteView.addSubview(contentBgView)

        contentOwnerLabel.frame = CGRect(x: 10, y: 3, width: contentBgView.width - 20, height: 27)
        contentOwnerLabel.font = UIFont.systemFont(ofSize: 13)
        contentOwnerLabel.textColor = TSColor.inconspicuous.navTitle
        contentBgView.addSubview(contentOwnerLabel)

        imageIcon.frame = CGRect(x: 10, y: contentOwnerLabel.bottom, width: 15, height: 12)
        imageIcon.clipsToBounds = true
        imageIcon.contentMode = .scaleAspectFill
        contentBgView.addSubview(imageIcon)

        contentLabel.frame = CGRect(x: imageIcon.right + 5, y: contentOwnerLabel.bottom, width: contentBgView.width - 10 - (imageIcon.right + 5), height: 12)
        contentLabel.font = UIFont.systemFont(ofSize: 12)
        contentLabel.textColor = UIColor(hex: 0xa0a0a0)
        contentLabel.backgroundColor = UIColor.clear
        contentBgView.addSubview(contentLabel)

        coverImage.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        coverImage.clipsToBounds = true
        coverImage.contentMode = .scaleAspectFill
        contentBgView.addSubview(coverImage)

        textBgView.frame = CGRect(x: inMargin, y: contentBgView.bottom + 15, width: whiteWidth - inMargin * 2, height: 50.0)
        textBgView.layer.cornerRadius = 3.0
        textBgView.backgroundColor = UIColor.white
        textBgView.layer.borderWidth = 0.5
        textBgView.layer.borderColor = TSColor.inconspicuous.disabled.cgColor
        whiteView.addSubview(textBgView)

        textInputView.frame = CGRect(x: 5, y: 0, width: textBgView.width - 32 - 5, height: 50)
        textInputView.textColor = TSColor.inconspicuous.navTitle
        textInputView.font = UIFont.systemFont(ofSize: 14)
        textInputView.delegate = self
        textBgView.addSubview(textInputView)

        placeHolderButton.frame = CGRect(x: 10, y: textInputView.top + 10, width: textBgView.width - 32 - 10, height: 14)
        placeHolderButton.text = "给朋友留言"
        placeHolderButton.textColor = UIColor(hex: 0x999999)
        placeHolderButton.font = UIFont.systemFont(ofSize: 14)
        placeHolderButton.isUserInteractionEnabled = true
        placeHolderButton.backgroundColor = UIColor.clear
        textBgView.addSubview(placeHolderButton)
        let tapPlaceHoder: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(placeHolderTap))
        placeHolderButton.addGestureRecognizer(tapPlaceHoder)

        smileButton.frame = CGRect(x: textInputView.right + 7, y: 7, width: 18, height: 18)
        smileButton.setImage(#imageLiteral(resourceName: "ico_kb_expression"), for: .normal)
        smileButton.setImage(UIImage(named: "ico_chat_keyboard"), for: .selected)
        smileButton.addTarget(self, action: #selector(emojiBtnClick), for: UIControlEvents.touchUpInside)
        textBgView.addSubview(smileButton)

        secondLine.frame = CGRect(x: 0, y: textBgView.bottom + 15, width: whiteWidth, height: 0.5)
        secondLine.backgroundColor = TSColor.inconspicuous.disabled
        whiteView.addSubview(secondLine)

        thirdLine.frame = CGRect(x: (whiteWidth - 0.5) / 2.0, y: secondLine.bottom, width: 0.5, height: whiteHeight - secondLine.bottom)
        thirdLine.backgroundColor = TSColor.inconspicuous.disabled
        whiteView.addSubview(thirdLine)

        cancelButton.frame = CGRect(x: 0, y: secondLine.bottom, width: (whiteWidth - 0.5) / 2.0, height: thirdLine.height)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitleColor(UIColor(hex: 0x999999), for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.addTarget(self, action: #selector(hidSelf), for: UIControlEvents.touchUpInside)
        whiteView.addSubview(cancelButton)

        sureButton.frame = CGRect(x: thirdLine.right, y: secondLine.bottom, width: (whiteWidth - 0.5) / 2.0, height: thirdLine.height)
        sureButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        sureButton.setTitleColor(TSColor.main.theme, for: .normal)
        sureButton.setTitle("发送", for: .normal)
        sureButton.addTarget(self, action: #selector(sendBtnClick), for: UIControlEvents.touchUpInside)
        whiteView.addSubview(sureButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension TSMessagePopoutVC: UITextViewDelegate {
    /// 键盘通知响应
    @objc fileprivate func kbWillShowNotificationProcess(_ notification: Notification) -> Void {
        guard let userInfo = notification.userInfo, let kbFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        self.currentKbH = kbFrame.size.height
        let kbH: CGFloat = self.currentKbH
        let bottomH: CGFloat = ScreenHeight - whiteView.bottom
        if kbH > bottomH {
            UIView.animate(withDuration: 0.25) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -(kbH - bottomH) - 20.0)
            }
        }
    }

    @objc fileprivate func kbWillHideNotificationProcess(_ notification: Notification) -> Void {
        self.kbProcessReset()
    }

    @objc fileprivate func viewBeginEditingNotificationProcess(_ notification: Notification) -> Void {
        let kbH: CGFloat = self.currentKbH
        let bottomH: CGFloat = ScreenHeight - whiteView.bottom
        if kbH > bottomH {
            UIView.animate(withDuration: 0.25) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -(kbH - bottomH) - 20.0)
            }
        }
        self.smileButton.isSelected = false
        emojiView.hidenEmojiView()
    }
    @objc fileprivate func viewEndEditingNotificationProcess(_ notification: Notification) -> Void {
        self.kbProcessReset()
    }

    /// 键盘相关的复原
    fileprivate func kbProcessReset() -> Void {
        UIView.animate(withDuration: 0.25) {
            self.view.transform = CGAffineTransform.identity
        }
    }
}
extension TSMessagePopoutVC {
    func emojiViewDidSelected(emoji: String) {
        self.textInputView.insertText(emoji)
        self.textInputView.scrollRangeToVisible(self.textInputView.selectedRange)
    }
}
extension TSMessagePopoutVC {
    func hidSelf() {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }

    func whiteViewTap() {

    }
    func sendBtnClick() {
        if let sendBlock = self.sendBlock {
            self.sendModel.noteContent = self.textInputView.text
            sendBlock(self.sendModel)
        }
        self.hidSelf()
    }
    func emojiBtnClick() {
        smileButton.isSelected = !smileButton.isSelected
        if smileButton.isSelected {
            emojiView.showEmojiView()
            textInputView.resignFirstResponder()
        } else {
            emojiView.hidenEmojiView()
            textInputView.becomeFirstResponder()
        }
    }
    public func show(vc: TSMessagePopoutVC) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.rootViewController?.addChildViewController(vc)
        window.rootViewController?.didMove(toParentViewController: window.rootViewController)
        window.rootViewController?.view.addSubview(vc.view)
    }

    func setInfo(model: TSmessagePopModel) {
        self.sendModel = model
        let mutabel = NSMutableAttributedString(string: "\(model.titleFirst)\(model.titleSecond)")
        let atr = [NSForegroundColorAttributeName: TSColor.main.theme]
        mutabel.addAttributes(atr, range: NSRange(location: model.titleFirst.count, length: mutabel.length - model.titleFirst.count))
        titleLabel.attributedText = mutabel
        contentOwnerLabel.text = model.owner
        contentLabel.text = model.content
        if model.contentType == .text {
            coverImage.isHidden = true
            imageIcon.isHidden = true
            contentLabel.frame = CGRect(x: 10, y: contentOwnerLabel.bottom, width: contentBgView.width - 20, height: 12)
        } else if model.contentType == .pic || model.contentType == .video {
            imageIcon.image = model.imageIcon
            imageIcon.isHidden = false
            coverImage.isHidden = true
        } else if model.contentType == .groupPic {
            imageIcon.isHidden = true
            contentOwnerLabel.frame = CGRect(x: coverImage.right + 5, y: 3, width: contentBgView.width - (coverImage.right + 5) - 5, height: 27)
            contentLabel.frame = CGRect(x: coverImage.right + 5, y: contentOwnerLabel.bottom, width: contentBgView.width - (coverImage.right + 5) - 5, height: 12)
            coverImage.kf.setImage(with: URL(string: model.coverImage), placeholder: nil, options: [KingfisherOptionsInfoItem.onlyLoadFirstFrame], progressBlock: nil, completionHandler: nil)
        } else if model.contentType == .postPic {
            imageIcon.isHidden = true
            contentOwnerLabel.frame = CGRect(x: coverImage.right + 5, y: 3, width: contentBgView.width - (coverImage.right + 5) - 5, height: 27)
            contentLabel.frame = CGRect(x: coverImage.right + 5, y: contentOwnerLabel.bottom, width: contentBgView.width - (coverImage.right + 5) - 5, height: 12)
            coverImage.kf.setImage(with: URL(string: model.coverImage), placeholder: nil, options: [KingfisherOptionsInfoItem.onlyLoadFirstFrame], progressBlock: nil, completionHandler: nil)
        } else if model.contentType == .postText {
            imageIcon.isHidden = true
            coverImage.isHidden = true
            contentLabel.frame = CGRect(x: 10, y: contentOwnerLabel.bottom, width: contentBgView.width - 20, height: 12)
        } else if model.contentType == .newsText {
            imageIcon.isHidden = true
            coverImage.isHidden = true
            contentLabel.isHidden = true
            let titleHeight = model.owner.heightWithConstrainedWidth(width: contentBgView.width - 20, font: contentOwnerLabel.font)
            contentOwnerLabel.frame = CGRect(x: 10, y: (contentBgView.height - titleHeight) / 2.0, width: contentBgView.width - 20, height: titleHeight)
            contentOwnerLabel.numberOfLines = 2
        } else if model.contentType == .question {
            coverImage.isHidden = true
            imageIcon.isHidden = true
            contentLabel.frame = CGRect(x: 10, y: contentOwnerLabel.bottom, width: contentBgView.width - 20, height: 12)
        } else if model.contentType == .questionAnswer {
            coverImage.isHidden = true
            imageIcon.isHidden = true
            contentLabel.frame = CGRect(x: 10, y: contentOwnerLabel.bottom, width: contentBgView.width - 20, height: 12)
        } else {
            imageIcon.isHidden = true
            contentLabel.isHidden = true
            coverImage.frame = CGRect(x: contentBgView.width - 8 - 115.0 / 2.0, y: 8, width: 115.0 / 2.0, height: 78 / 2.0)
            let titleHeight = model.owner.heightWithConstrainedWidth(width: contentBgView.width - 8 - 8 - 23 - coverImage.width, font: contentOwnerLabel.font)
            contentOwnerLabel.frame = CGRect(x: 10, y: (contentBgView.height - titleHeight) / 2.0, width: contentBgView.width - 8 - 8 - 23 - coverImage.width, height: titleHeight)
            contentOwnerLabel.numberOfLines = 2
            coverImage.kf.setImage(with: URL(string: model.coverImage), placeholder: nil, options: [KingfisherOptionsInfoItem.onlyLoadFirstFrame], progressBlock: nil, completionHandler: nil)
        }
    }

    func placeHolderTap() {
        textInputView.becomeFirstResponder()
    }

    func textViewDidChanged(notification: Notification) -> Void {
        // textView判断
        guard let textView = notification.object as? UITextView else {
            return
        }
        if textView != textInputView {
            return
        }
        let text = textView.text as NSString

        if text.length > MAX_STARWORDS_LENGTH {
            let str = text.substring(to: MAX_STARWORDS_LENGTH)
            textView.text = str
        }
        // 占位处理
        placeHolderButton.isHidden = !(nil == textView.text || textView.text!.isEmpty)
    }
}
