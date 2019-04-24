//
//  TSShareCenter.swift
//  Thinksns Plus
//
//  Created by GorCat on 16/12/21.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  分享界面展示

import UIKit
import SnapKit
import MonkeyKing

enum ShareURL: String {
    /// 动态分享+feedid
    case feed = "/feeds/"
    /// 用户分享+userid
    case user = "/users/"
    /// 问答 - 问题，拼接问题id
    case question = "/questions/"
    /// 问答 - 答案，{question} 替换为问题id 拼接答案id
    case answswer = "/questions/replacequestion/answers/"
    /// 资讯分享 拼接资讯id
    case news = "/news/"
    /// 圈子详情
    case groupsList = "/groups/replacegroup?type=replacefetch"
    /// 圈子帖子详情
    case groupDetail = "/groups/replacegroup/posts/replacepost"
    /// 话题分享
    case topics = "/question-topics/replacetopic"
}

// MARK: - ShareView 分享视图
class ShareView: UIView, Sharable {
    enum shareType {
        case weChat
    }
    /// 按钮间距
    let buttonSpace: CGFloat = 32.0
    /// 按钮尺寸
    let buttonSize: CGSize = CGSize(width: 33.0, height: 60)
    /// 按钮 tag
    let tagForShareButton = 200

    /// 分享按钮组
    var shareViewArray = [UIView]()
    /// 分享链接
    var shareUrlString: String? = nil
    /// 分享图片
    var shareImage: UIImage? = nil
    /// 分享描述
    var shareDescription: String? = nil
    /// 分享标题
    var shareTitle: String? = nil
    // share button
    var imageArray = ["IMG_detail_share_qq", "IMG_detail_share_zone", "IMG_detail_share_wechat", "IMG_detail_share_friends", "IMG_detail_share_weibo"]
    var titleArary = ["QQ", "空间", "微信", "朋友圈", "微博"]

    // MARK: Lifecycle
    init() {
        super.init(frame: UIScreen.main.bounds)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: - Custom user interface
    func setUI() {
        backgroundColor = UIColor(white: 0, alpha: 0.2)
        // 没有微信时将微信和朋友圈移除
        if !ShareManager.thirdAccout(type: .wechat).isAppInstalled {
            imageArray.remove(at: 3)
            titleArary.remove(at: 3)
            imageArray.remove(at: 2)
            titleArary.remove(at: 2)
        }

        for index in 0..<imageArray.count {
            let shareView = UIView()
            shareView.isUserInteractionEnabled = true
            shareView.tag = tagForShareButton + index
            let imageView = UIImageView(image: UIImage(named: imageArray[index]))
            shareView.addSubview(imageView)
            imageView.isUserInteractionEnabled = true
            imageView.snp.makeConstraints({ (make) in
                make.centerX.equalTo(shareView.snp.centerX)
                make.top.equalTo(shareView.snp.top)
            })

            let label = UILabel()
            label.textColor = TSColor.normal.content
            label.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
            label.text = titleArary[index]
            shareView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.top.equalTo(imageView.snp.bottom).offset(12)
                make.centerX.equalTo(imageView.snp.centerX)
            })

            shareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTaped(_:))))
            shareViewArray.append(shareView)
        }

        // scrollow
        let scrollow = UIScrollView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 117, width: UIScreen.main.bounds.width, height: 117))
        scrollow.backgroundColor = UIColor.white
        scrollow.bounces = false
        let scrollowWidth = UIScreen.main.bounds.width
        scrollow.contentSize = CGSize(width: scrollowWidth, height: 117)
        addSubview(scrollow)

        // button frame
        //let buttonWidth = CGFloat(scrollowWidth - 26 * 2) / CGFloat(shareButtonArray.count)
        var tempView: UIView?
        for view in shareViewArray {
            scrollow.addSubview(view)
            if shareViewArray.count == 1 {
                view.snp.makeConstraints({ (make) in
                    make.center.equalTo(scrollow.center)
                })
                return
            }

            let marginOffset = scrollow.bounds.size.width - (CGFloat(shareViewArray.count - 1) * buttonSpace + (CGFloat(shareViewArray.count) * buttonSize.width))
            view.snp.makeConstraints({ (make) in
                if let tView = tempView {
                    make.left.equalTo(tView.snp.right).offset(buttonSpace)
                } else {
                    make.left.equalTo(scrollow.snp.left).offset(marginOffset / 2)
                }
                make.centerY.equalTo(scrollow.snp.centerY)
                make.size.equalTo(buttonSize)
            })
            tempView = view
        }

        // gesture
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShareView.dismiss)))
    }

    // MARK: - Button click
    internal func buttonTaped(_ sender: UIGestureRecognizer) {
        let view = sender.view
        let index = view!.tag - 200
        let finishBlock = setFinishBlock()
        let shareName = titleArary[index]
        switch shareName {
        case "QQ":
            shareURLToQQ(URLString: shareUrlString, image: shareImage, description: shareDescription, title: shareTitle, complete: finishBlock)
        case "空间":
            shareURLToQQZone(URLString: shareUrlString, image: shareImage, description: shareDescription, title: shareTitle, complete: finishBlock)
        case "微信":
            shareURLToWeChatWith(URLString: shareUrlString, image: shareImage, description: shareDescription, title: shareTitle, complete: finishBlock)
        case "朋友圈":
            shareURLToWeChatMomentsWith(URLString: shareUrlString, image: shareImage, description: shareDescription, title: shareTitle, complete: finishBlock)
        case "微博":
            shareURLToWeiboWith(URLString: shareUrlString, image: shareImage, description: shareDescription, title: shareTitle, complete: finishBlock)
        default:
            break
        }
    }

    /// 设置完成后的回调方法
    func setFinishBlock() -> ((Bool) -> Void) {
        func finishBlock(success: Bool) -> Void {
            if success {
            }
        }
        return finishBlock
    }

    // MARK: Public
    /// 显示分享视图
    ///
    /// - Parameters:
    ///   - URLString: 分享的链接
    ///   - image: 分享的图片
    ///   - description: 分享的'对链接的描述'
    ///   - title: 分享的'链接标题'
    public func show(URLString: String?, image: UIImage?, description: String?, title: String?) {
        if let url = URLString, let encoding = (url + "?from=3").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            shareUrlString = TSAppConfig.share.rootServerAddress + "redirect?target=" + encoding
        }
        shareImage = image
        shareDescription = description
        shareTitle = title
        if self.superview != nil {
            return
        }
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.addSubview(self)
    }

    /// 隐藏分享视图
    public func dismiss() {
        if self.superview == nil {
            return
        }
        self.removeFromSuperview()
    }
    /// 直接分享到三方
    func shareInfo(type: shareType, URLString: String?, image: UIImage?, description: String?, title: String?, complete: @escaping (Bool) -> Void) {
        if let url = URLString, let encoding = (url + "?from=3").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            shareUrlString = TSAppConfig.share.rootServerAddress + "redirect?target=" + encoding
        }
        shareImage = image
        shareDescription = description
        shareTitle = title
        let finishBlock = setFinishBlock()
        if type == .weChat {
            shareURLToWeChatWith(URLString: shareUrlString, image: shareImage, description: shareDescription, title: shareTitle, complete: finishBlock)
        }
    }
}

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle: Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}
