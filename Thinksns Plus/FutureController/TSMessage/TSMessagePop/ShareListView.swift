//
//  ShareListView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/7.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import SnapKit
import MonkeyKing

protocol ShareListViewDelegate: class {
    func didClickMessageButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, model: TSmessagePopModel)
    func didClickReportButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    func didClickCollectionButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    func didClickDeleteButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    func didClickRepostButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?)
    func didClickApplyTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    // 设置置顶
    func didClickSetTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    // 撤销置顶
    func didClickCancelTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    // 设为精华帖
    func didClickSetExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    // 取消精华帖
    func didClickCancelExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
}

enum ShareListURL: String {
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

enum ShareListType {
    /// 动态列表全套分享视图按钮，详情页只是在原来分享基础上增加了 转发 和 私信发送 两个按钮
    case momentList
    case momenDetail
    // 圈子详情
    case groupDetail
    // 圈子列表
    case groupMomentList
    case newDetail
     // 圈子帖子详情
    case groupMomentDetail
    case questionDetail
    case questionAnswerDetail
    /// 话题动态列表
    case topicFeedList
}

class ShareListView: UIView, Sharable {

    weak var delegate: ShareListViewDelegate?
    /// 点击取消的回调
    var dismissAction: (() -> Void)?
    /// 按钮间距
    let buttonSpace: CGFloat = 32.0
    /// 按钮尺寸
    let buttonSize: CGSize = CGSize(width: 33.0, height: 60)
    /// 按钮 tag
    let tagForShareButton = 200
    /// 按钮背景滚动视图
    var scrollow = UIScrollView()
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
    /// 是自己的还是他人的
    var isMine = false
    // 是否是管理员
    var isManager = false
    // 是否是圈主
    var isOwner = false
    // 是否是精华
    var isExcellent = false
    // 是否是置顶
    var isTop = false
    // 是否置顶
    var isCollect = false
    var cancleButton = UIButton(type: .custom)
    var oneLineheight: CGFloat = 117.0
    var twoLineheight: CGFloat = 333.0 / 2.0
    var messageModel: TSmessagePopModel? = nil
    var feedIndex: IndexPath? = nil
    var shareType = ShareListType.momentList

    /// share button
    var imageArray = ["IMG_detail_share_qq", "IMG_detail_share_zone", "IMG_detail_share_wechat", "IMG_detail_share_friends", "IMG_detail_share_weibo"]
    var titleArary = ["QQ", "空间", "微信", "朋友圈", "微博"]
    /// 自己发的
    var imageArrayMe = ["detail_share_forwarding", "detail_share_clt", "detail_share_sent", "detail_share_top", "detail_share_det"]
    var titleAraryMe = ["转发", "收藏", "私信发送", "申请置顶", "删除"]
    /// 自己发的,但没有申请置顶按钮(话题)
    var imageArrayMeNoReTop = ["detail_share_forwarding", "detail_share_clt", "detail_share_sent", "detail_share_det"]
    var titleAraryMeNoReTop = ["转发", "收藏", "私信发送", "删除"]
    /// 自己发的已收藏
    var imageArrayMeCollection = ["detail_share_forwarding", "detail_share_clt_hl", "detail_share_sent", "detail_share_top", "detail_share_det"]
    var titleAraryMeCollection = ["转发", "已收藏", "私信发送", "申请置顶", "删除"]
    /// 自己发的已收藏，但没有申请置顶按钮(话题)
    var imageArrayMeCollectionNoReTop = ["detail_share_forwarding", "detail_share_clt_hl", "detail_share_sent", "detail_share_det"]
    var titleAraryMeCollectionNoReTop = ["转发", "已收藏", "私信发送", "删除"]
//
//    /// 自己发的帖子
//    var imageArrayMePost = ["detail_share_forwarding", "detail_share_sent","detail_share_clt_hl", "detail_share_det"]
//    var titleAraryMePost = ["转发", "私信发送", "已收藏", "删除"]
//    /// 管理员
//    var imageArrayManagerPost = ["detail_share_forwarding", "detail_share_clt_hl", "detail_share_sent", "detail_share_det"]
//    var titleAraryManagerPost = ["转发", "已收藏", "私信发送", "删除"]
//    /// 普通用户
//    var imageArrayNorPost = ["detail_share_forwarding", "detail_share_clt_hl", "detail_share_sent", "detail_share_det"]
//    var titleAraryNorPost = ["转发", "已收藏", "私信发送", "删除"]

    /// 别人发的
    var imageArrayOther = ["detail_share_forwarding", "detail_share_report", "detail_share_clt", "detail_share_sent"]
    var titleAraryOther = ["转发", "举报", "收藏", "私信发送"]
    /// 别人发的已收藏
    var imageArrayOtherCollection = ["detail_share_forwarding", "detail_share_report", "detail_share_clt_hl", "detail_share_sent"]
    var titleAraryOtherCollection = ["转发", "举报", "已收藏", "私信发送"]
    /// 各类详情页
    /// 别人发的
    var imageArrayDetail = ["detail_share_forwarding", "detail_share_sent"]
    var titleAraryDetail = ["转发", "私信发送"]
    // MARK: Lifecycle
    init(isMineSend: Bool, isCollection: Bool, shareType: ShareListType) {
        super.init(frame: UIScreen.main.bounds)
        self.isManager = (TSCurrentUserInfo.share.accountManagerInfo?.getData())!
        self.isMine = isMineSend
        self.shareType = shareType
        self.isCollect = isCollection
        setUI()
    }

    init( shareType: ShareListType) {
        super.init(frame: UIScreen.main.bounds)
          self.shareType = shareType
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
        if shareType == .momentList || shareType == .groupMomentList {
            if isMine {
                if isCollect {
                    imageArray += imageArrayMeCollection
                    titleArary += titleAraryMeCollection
                } else {
                    imageArray += imageArrayMe
                    titleArary += titleAraryMe
                }
            } else if isManager {
                if isCollect {
                    imageArrayOtherCollection.remove(at: 1)
                    imageArray += imageArrayOtherCollection
                    titleAraryOtherCollection.remove(at: 1)
                    titleArary += titleAraryOtherCollection
                } else {
                    imageArrayOther.remove(at: 1)
                    imageArray += imageArrayOther
                    titleAraryOther.remove(at: 1)
                    titleArary += titleAraryOther
                }
                imageArray.append("detail_share_det")
                titleArary.append("删除")
            } else {
                if isCollect {
                    imageArray += imageArrayOtherCollection
                    titleArary += titleAraryOtherCollection
                } else {
                    imageArray += imageArrayOther
                    titleArary += titleAraryOther
                }
            }
        } else if shareType == .topicFeedList {
            /// 话题没有置顶，没有置顶
            if isMine {
                if isCollect {
                    imageArray += imageArrayMeCollectionNoReTop
                    titleArary += titleAraryMeCollectionNoReTop
                } else {
                    imageArray += imageArrayMeNoReTop
                    titleArary += titleAraryMeNoReTop
                }
            } else if isManager {
                if isCollect {
                    imageArrayOtherCollection.remove(at: 1)
                    imageArray += imageArrayOtherCollection
                    titleAraryOtherCollection.remove(at: 1)
                    titleArary += titleAraryOtherCollection
                } else {
                    imageArrayOther.remove(at: 1)
                    imageArray += imageArrayOther
                    titleAraryOther.remove(at: 1)
                    titleArary += titleAraryOther
                }
                imageArray.append("detail_share_det")
                titleArary.append("删除")
            } else {
                if isCollect {
                    imageArray += imageArrayOtherCollection
                    titleArary += titleAraryOtherCollection
                } else {
                    imageArray += imageArrayOther
                    titleArary += titleAraryOther
                }
            }
        } else if shareType == .groupDetail {
            /// 圈子详情
            if  isOwner || isManager {
                    imageArray.append("detail_share_forwarding")
                    imageArray.append("detail_share_sent")
                    imageArray.append(isExcellent ? "ico_cancel" : "ico_essence")
                    imageArray.append("detail_share_top")
                    imageArray.append("detail_share_det")
                    titleArary.append("转发")
                    titleArary.append("私信发送")
                    titleArary.append(isExcellent ? "撤销精华帖":"设为精华帖")
                    titleArary.append(isTop ? "撤销置顶":"置顶帖子")
                    titleArary.append("删除")
            } else {
             // 普通用户
                if isMine {
                    imageArray.append("detail_share_forwarding")
                    imageArray.append("detail_share_sent")
                    imageArray.append(isCollect ? "detail_share_clt_hl":"detail_share_clt")
                      if !isTop {
                    imageArray.append("detail_share_top")
                    }
                    imageArray.append("detail_share_det")
                    titleArary.append("转发")
                    titleArary.append("私信发送")
                    titleArary.append(isCollect ? "已收藏":"收藏")
                     if !isTop {
                    titleArary.append("申请置顶")
                    }
                    titleArary.append("删除")
                } else {
                    imageArray.append("detail_share_forwarding")
                    imageArray.append("detail_share_sent")
                    imageArray.append("detail_share_report")
                    imageArray.append(isCollect ? "detail_share_clt_hl":"detail_share_clt")
                    titleArary.append("转发")
                    titleArary.append("私信发送")
                    titleArary.append("举报")
                    titleArary.append(isCollect ? "已收藏":"收藏")
                }
            }
        } else {
            imageArray += imageArrayDetail
            titleArary += titleAraryDetail
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
            if titleArary[index] == "已收藏" {
                label.textColor = TSColor.main.theme
            }
            shareView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.top.equalTo(imageView.snp.bottom).offset(12)
                make.centerX.equalTo(imageView.snp.centerX)
            })

            shareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTaped(_:))))
            shareViewArray.append(shareView)
        }
        // scrollow
        var scrollViewHeight: CGFloat = twoLineheight
        if imageArray.count > 5 {
            scrollViewHeight = twoLineheight
        } else {
            scrollViewHeight = oneLineheight
        }
        scrollow.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - (scrollViewHeight + TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight() + 40), width: UIScreen.main.bounds.width, height: scrollViewHeight + TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight() + 40)
        scrollow.backgroundColor = UIColor(hex: 0xf6f6f6)
        scrollow.bounces = false
        let scrollowWidth = UIScreen.main.bounds.width
        scrollow.contentSize = CGSize(width: scrollowWidth, height: scrollViewHeight)
        addSubview(scrollow)

        /// button frame
        var tempView: UIView?
        for (index, view) in shareViewArray.enumerated() {
            scrollow.addSubview(view)
            if shareViewArray.count == 1 {
                view.snp.makeConstraints({ (make) in
                    make.center.equalTo(scrollow.center)
                })
                return
            }
            let marginOffset = scrollow.bounds.size.width - (CGFloat((shareViewArray.count > 5 ? 5 : shareViewArray.count) - 1) * buttonSpace + (CGFloat(shareViewArray.count > 5 ? 5 : shareViewArray.count) * buttonSize.width))
            if shareViewArray.count > 5 {
                if index < 5 {
                    view.snp.makeConstraints({ (make) in
                        if let tView = tempView {
                            make.left.equalTo(tView.snp.right).offset(buttonSpace)
                        } else {
                            make.left.equalTo(scrollow.snp.left).offset(marginOffset / 2)
                        }
                        make.top.equalTo(scrollow.snp.top).offset(20)
                        make.size.equalTo(buttonSize)
                    })
                } else {
                    view.snp.makeConstraints({ (make) in
                        if let tView = tempView, index != 5 {
                            make.left.equalTo(tView.snp.right).offset(buttonSpace)
                        } else {
                            make.left.equalTo(scrollow.snp.left).offset(marginOffset / 2)
                        }
                        make.top.equalTo(scrollow.snp.top).offset(40 + buttonSize.height)
                        make.size.equalTo(buttonSize)
                    })
                }
            } else {
                view.snp.makeConstraints({ (make) in
                    if let tView = tempView {
                        make.left.equalTo(tView.snp.right).offset(buttonSpace)
                    } else {
                        make.left.equalTo(scrollow.snp.left).offset(marginOffset / 2)
                    }
                    make.centerY.equalTo(scrollow.snp.centerY).offset(-20)
                    make.size.equalTo(buttonSize)
                })
            }
            tempView = view
        }

        // gesture
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShareView.dismiss)))
        cancleButton.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 40 - TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight(), width: ScreenWidth, height: 40)
        cancleButton.backgroundColor = UIColor.white
        cancleButton.setTitle("取消", for: .normal)
        cancleButton.setTitleColor(UIColor(hex: 0x333333), for: .normal)
        cancleButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        addSubview(cancleButton)
        cancleButton.addTarget(self, action: #selector(cancelBtnClick), for: UIControlEvents.touchUpInside)
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
        case "转发":
            self.isHidden = true
            delegate?.didClickRepostButon(self, fatherViewTag: index, feedIndex: feedIndex)
            dismiss()
        case "收藏", "已收藏":
            guard let feedindex = feedIndex else {
                return
            }
            delegate?.didClickCollectionButon(self, fatherViewTag: index, feedIndex: feedindex)
            dismiss()
        case "私信发送":
            guard let model = messageModel else {
                return
            }
            self.isHidden = true
            delegate?.didClickMessageButon(self, fatherViewTag: index, feedIndex: feedIndex, model: model)
            dismiss()
        case "申请置顶":
            guard let feedindex = feedIndex else {
                return
            }
            self.isHidden = true
            delegate?.didClickApplyTopButon(self, fatherViewTag: index, feedIndex: feedindex)
            dismiss()
        case "置顶帖子":
            guard let feedindex = feedIndex else {
                return
            }
            self.isHidden = true
            delegate?.didClickSetTopButon(self, fatherViewTag: index, feedIndex: feedindex)
            dismiss()
        case "撤销置顶":
            guard let feedindex = feedIndex else {
                return
            }
            self.isHidden = true
            delegate?.didClickCancelTopButon(self, fatherViewTag: index, feedIndex: feedindex)
            dismiss()
        case "设为精华帖":
            guard let feedindex = feedIndex else {
                return
            }
            self.isHidden = true
            delegate?.didClickSetExcellentButon(self, fatherViewTag: index, feedIndex: feedindex)
            dismiss()
        case "撤销精华帖":
            guard let feedindex = feedIndex else {
                return
            }
            self.isHidden = true
            delegate?.didClickCancelExcellentButon(self, fatherViewTag: index, feedIndex: feedindex)
            dismiss()
        case "删除":
            guard let feedindex = feedIndex else {
                return
            }
            self.isHidden = true
            delegate?.didClickDeleteButon(self, fatherViewTag: index, feedIndex: feedindex)
            dismiss()
        case "举报":
            guard let feedindex = feedIndex else {
                return
            }
            self.isHidden = true
            delegate?.didClickReportButon(self, fatherViewTag: index, feedIndex: feedindex)
            dismiss()
        default:
            break
        }
    }
    
    /// 取消按钮点击
    func cancelBtnClick() {
        dismiss()
        dismissAction?()
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
        dismissAction?()
    }

    func updateView(tag: Int, iscollect: Bool) {
        let bgView = self.scrollow.viewWithTag(tag + 200)
        for view in (bgView?.subviews)! {
            if view is UILabel {
                let titleLabel = view as! UILabel
                titleLabel.text = iscollect ? "已收藏" : "收藏"
                if titleLabel.text == "已收藏" {
                    titleLabel.textColor = TSColor.main.theme
                } else {
                    titleLabel.textColor = TSColor.normal.content
                }
            }
            if view is UIImageView {
                let imageIcon = view as! UIImageView
                imageIcon.image = iscollect ? #imageLiteral(resourceName: "detail_share_clt_hl") : #imageLiteral(resourceName: "detail_share_clt")
            }
        }
    }
}
