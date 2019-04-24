//
//  TSNewsDetailHeaderViewController.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  资讯详情页的文章详情

/**
 此控制器数据请求有2部分,部分数据是在该控制器初始化后加载;部分数据是获取从别的控制器获取了数据后传入
 导致部分页面控件是在初始化后创建,视图布局时布局;部分控件是传入数据时布局尺寸
 
 Warning: 修改尺寸和布局时,需要注意调整这两处
 */

import UIKit
import MarkdownView

protocol DetailHeaderViewControllerDelegate: class {
    func headerViewController(headrView view: UIView?, didFinishedLoadHtml successed: Bool)
    // 关注状态按钮点击响应
    func newsFollow(_ newHeaderView: UIView?, didClickFollowControl followControl: TSFollowControl) -> Void
}

class TSNewsDetailHeaderViewController: UIViewController, TSDetailRewardListViewDelegate, TSChoosePriceVCDelegate {
    /// 代理
    weak var delegate: DetailHeaderViewControllerDelegate? = nil
    /// 资讯id
    var newsId: Int
    /// 网页控件
    var markdownView: MarkdownView = MarkdownView()
    /// 打赏信息列表
    weak var rewardListView: TSDetailRewardListView!
    /// 打赏按钮
    weak var rewardBtn: TSRewardButton!
    /// 标题
    weak var titleLabel: UILabel!
    /// 原创作者
    weak var authorNameLabel: UILabel!
    var avatar: AvatarView!
    var user: TSUserInfoModel! {
        didSet {
            reloadUser()
        }
    }
    /// 关注按钮
    weak var followControl: TSFollowControl!
    /// 类别
    weak var categoryLabel: UILabel!
    /// 来源
    weak var fromLabel: UILabel!
    /// 点赞视图
    weak var likeUsersView: TSLikedUsersView!
    /// 详细信息标签
    weak var labelForSubInfo: UILabel!
    /// 点赞用户数据
    var likeUsers: [TSUserInfoModel] = []
    /// 资讯详情
    var newsDetailModel: NewsDetailModel? {
        didSet {
            load(newsDetailModel)
        }
    }
    // 图片数组
    var imageArray: [String] = []
    // 当前查看的图片链接
    var currentImgStr: String?

    // MARK: - lifeCycle
    init(newsId: Int) {
        self.newsId = newsId
        super.init(nibName: nil, bundle: nil)
        self.markdownView.frame = self.view.bounds
        self.markdownView.isScrollEnabled = false
        self.markdownView.onTouchLink = { [weak self] (request) in
            guard let url = request.url else {
                return false
            }
            if let tabVC = TSRootViewController.share.currentShowViewcontroller as? TSHomeTabBarController, let nav = tabVC.selectedViewController as? UINavigationController {
                TSUtil.pushURLDetail(url: url, currentVC: nav)
            } else {
                if let parentVC = self?.parent {
                    TSUtil.pushURLDetail(url: url, currentVC: parentVC)
                }
            }
            return false
        }

        self.markdownView.onTouchClick = {[weak self] (url) in
            let string: NSString = NSString(string: url)
            self?.currentImgStr = string.substring(from: 8)
            self?.previewPicture()
        }
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor(hex: 0x333333)
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(name: "PingFang-SC-Bold", size: 25)
        self.titleLabel = titleLabel

        let categoryLabel = UILabel()
        categoryLabel.textColor = TSColor.main.theme
        categoryLabel.font = UIFont.systemFont(ofSize: TSFont.SubInfo.special.rawValue)
        categoryLabel.textAlignment = .center
        categoryLabel.layer.borderColor = TSColor.main.theme.cgColor
        categoryLabel.layer.borderWidth = 0.5
        self.categoryLabel = categoryLabel

        let fromLabel = UILabel()
        fromLabel.font = UIFont.systemFont(ofSize: TSFont.Time.normal.rawValue)
        fromLabel.textColor = TSColor.normal.disabled
        self.fromLabel = fromLabel

        let likeUsersView = TSLikedUsersView(frame: CGRect.zero)
        likeUsersView.addTarget(self, action: #selector(likeUsersAction), for: .touchUpInside)
        likeUsersView.isHidden = true       // 默认隐藏，避免请求点赞数据失败时这里还可以点击响应
        self.likeUsersView = likeUsersView

        let labelForSubInfo = UILabel()
        labelForSubInfo.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        labelForSubInfo.textColor = TSColor.normal.disabled
        labelForSubInfo.textAlignment = .right
        labelForSubInfo.numberOfLines = 2
        self.labelForSubInfo = labelForSubInfo

        let avatar = AvatarView(type: AvatarType.width43(showBorderLine: false))
        avatar.isHidden = true
        self.avatar = avatar

        let authorNameLabel = UILabel()
        authorNameLabel.font = UIFont(name: "PingFangSC-Regular", size: 16)
        authorNameLabel.textColor = UIColor(hex: 0x333333)
        authorNameLabel.isHidden = true
        self.authorNameLabel = authorNameLabel

        let followControl = TSFollowControl()
        followControl.addTarget(self, action: #selector(followControlClick(_:)), for: .touchUpInside)
        followControl.isHidden = true
        self.followControl = followControl

        self.view.addSubview(titleLabel)
        self.view.addSubview(categoryLabel)
        self.view.addSubview(fromLabel)
        self.view.addSubview(markdownView)
        self.view.addSubview(likeUsersView)
        self.view.addSubview(labelForSubInfo)
        self.view.addSubview(avatar)
        self.view.addSubview(authorNameLabel)
        self.view.addSubview(followControl)
        self.view.backgroundColor = UIColor.white

        // 判断是否显示打赏
        if TSAppConfig.share.localInfo.isOpenReward == true {
            let rewardBtn = TSRewardButton(frame: CGRect.zero)
            rewardBtn.setTitle("打赏", for: .normal)
            rewardBtn.addTarget(self, action: #selector(reward), for: .touchUpInside)
            self.rewardBtn = rewardBtn

            let rewardListView = TSDetailRewardListView()
            rewardListView.backgroundColor = TSColor.main.white
            rewardListView.delegate = self
            self.rewardListView = rewardListView

            self.view.addSubview(rewardListView)
            self.view.addSubview(rewardBtn)
        } else {
            let rewardBtn = TSRewardButton(frame: CGRect.zero)
            let rewardListView = TSDetailRewardListView()
            self.rewardBtn = rewardBtn
            self.rewardListView = rewardListView
        }

        loadContent()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(pressNewsDetailLikeBtn), name: NSNotification.Name.News.pressNewsDetailLikeBtn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pressNewsDetailUnlikeBtn), name: NSNotification.Name.News.pressNewsDetailUnlikeBtn, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.News.pressNewsDetailLikeBtn, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.News.pressNewsDetailUnlikeBtn, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - load data in UI
    func load(_ data: NewsDetailModel?) {
        guard let data = data else {
            self.delegate?.headerViewController(headrView: nil, didFinishedLoadHtml: false)
            return
        }

        loadAuthorData(userid: data.authorId)
        self.titleLabel.text = data.title
        let size = self.titleLabel.sizeThatFits(CGSize(width: ScreenSize.ScreenWidth - 20, height: CGFloat(MAXFLOAT)))
        self.titleLabel.frame = CGRect(x: 10, y: 25, width: ScreenSize.ScreenWidth - 20, height: size.height)

        if data.from == "原创" {
            self.avatar.frame = CGRect(x: self.titleLabel.left, y: self.titleLabel.bottom + 20, width: 43, height: 43)
            self.authorNameLabel.text = data.author
            self.authorNameLabel.numberOfLines = 1
            self.authorNameLabel.sizeToFit()
            self.authorNameLabel.frame = CGRect(x: self.avatar.right + 10, y: self.avatar.top + 4, width: self.authorNameLabel.size.width, height: 18)
            self.avatar.isHidden = false
            self.authorNameLabel.isHidden = false
        }
        self.followControl.frame = CGRect(x: ScreenWidth - 15 - self.followControl.minW, y: 0, width: self.followControl.minW, height: self.followControl.defaultH)
        self.followControl.layer.cornerRadius = self.followControl.defaultH/2
        self.followControl.layer.masksToBounds = true
        self.followControl.centerY = self.avatar.centerY
        self.categoryLabel.text = data.categoryInfo.name
        self.categoryLabel.sizeToFit()
        if data.from == "原创" {
            self.categoryLabel.frame = CGRect(x: self.avatar.right + 10, y: self.avatar.bottom - self.categoryLabel.frame.height - 4, width: self.categoryLabel.frame.width + 5, height: self.categoryLabel.frame.height)
        } else {
            self.categoryLabel.frame = CGRect(x: 10, y: self.titleLabel.frame.maxY + 15, width: self.categoryLabel.frame.width + 5, height: self.categoryLabel.frame.height)
        }

        let timeString = TSDate().dateString(.detail, nsDate: data.createdDate as NSDate)
        self.fromLabel.text = timeString + "  " + TSAppConfig.share.pageViewsString(number: data.hits!) +  "显示_人浏览".localized
        self.fromLabel.sizeToFit()
        self.fromLabel.frame = CGRect(x: self.categoryLabel.frame.maxX + 5, y: self.categoryLabel.top, width: self.fromLabel.frame.width, height: self.categoryLabel.frame.height)

        var from = ""
        if data.from == "原创" { // 垃圾后台要求这样判断的
            from = String(format: "来自\n%@", data.author)
        } else {
            from = String(format: "来自\n%@", data.from)
        }
        labelForSubInfo.text = from
        labelForSubInfo.sizeToFit()
        var newContent: String = data.content_markdown
        // 摘要处理：存在摘要时则拼接展示，不存在则不再展示摘要
        let subject = data.subject
        if nil != subject && !subject!.isEmpty {
            newContent = "> <font color=\"#000\">[摘要]</font> " + subject! + "<br/>\n\n" + data.content_markdown
        }
        // 查看图片相关js
        let getImagesJSString =
        """
            function getImages(){
            var objs = document.getElementsByTagName(\"img\");
            var imgScr = '';
            for(var i=0;i<objs.length;i++) {
            if (i == 0){
              imgScr = objs[i].src;
            } else {
               imgScr = imgScr +'***'+ objs[i].src;
            }
            }
             return imgScr;
            }
            """
        let imageClickJSString =
        """
         function registerImageClickAction(){
        var imgs = document.getElementsByTagName('img')
           for(var i=0;i<imgs.length;i++){
            imgs[i].customIndex = i;
             imgs[i].onclick=function() {
            window.location.href='TSimage:'+this.src;
         }
        }
        }
       """
        self.markdownView.load(markdown: newContent, enableImage: true)
        // 25 是顶部标题等距离
        // 175 是底部距离
        markdownView.onRendered = { [unowned self] (height) in
            var newFrame = self.markdownView.frame
            newFrame.origin.y = self.fromLabel.frame.maxY + 25
            newFrame.size.height = height
            self.markdownView.frame = newFrame
            if TSAppConfig.share.localInfo.isOpenReward == true {
                newFrame.size.height = height + 175 + self.fromLabel.frame.maxY + 25
            } else {
                newFrame.size.height = height + 130 + 25
            }
            self.view.frame = newFrame

            self.delegate?.headerViewController(headrView: self.view, didFinishedLoadHtml: true)
            self.view.setNeedsLayout()
            self.markdownView.webView?.evaluateJavaScript(imageClickJSString, completionHandler: nil)
            self.markdownView.webView?.evaluateJavaScript(getImagesJSString, completionHandler: nil)
            self.markdownView.webView?.evaluateJavaScript("registerImageClickAction();", completionHandler: nil)
            self.markdownView.webView?.evaluateJavaScript("getImages()", completionHandler: { (image, error) in
                if error == nil {
                    if let  image = image as? NSString {
                        let array: [String] =   image.components(separatedBy: "***")
                        self.imageArray = array
                    }
                }
            })
        }
    }

    // MARK: - UI layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.likeUsersView.frame = CGRect(x: 10, y: self.markdownView.frame.maxY + 23, width: self.view.frame.width - 10, height: 28)

        labelForSubInfo.frame = CGRect(x: self.view.frame.width - 10 - labelForSubInfo.frame.width, y: likeUsersView.origin.y + (likeUsersView.size.height - labelForSubInfo.size.height) / 2.0, width: labelForSubInfo.size.width, height: labelForSubInfo.size.height)
        if TSAppConfig.share.localInfo.isOpenReward == true {
            self.rewardListView.frame = CGRect(x: 0, y: self.markdownView.frame.maxY + 100, width: self.view.frame.width, height: 74)
            self.rewardBtn.frame = CGRect(x: self.view.frame.width / 2 - 40, y: self.markdownView.frame.maxY + 70, width: 80, height: 30)
        }
    }

    // MARK: btn action
    fileprivate func previewPicture() -> Void {
        var currentIndex: Int = 0
        var objectArray: [TSImageObject] = []
        for section in 0..<imageArray.count {
            let path = String(describing: imageArray[section])
            if path == self.currentImgStr {
                currentIndex = section
            }
            let object = TSImageObject()
            let subIndex = (TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue as NSString).length
            if let fileId = Int((path as NSString).substring(from: subIndex + 1)) {
                object.storageIdentity = fileId
            }
            object.cacheKey = ""
            object.mimeType = "image/jpeg"
            objectArray.append(object)
        }
        let picturePreview = TSPicturePreviewVC(objects: objectArray, imageFrames: [], images: [], At: currentIndex)
        picturePreview.show()
    }
    func reward() {
        let vc = TSChoosePriceVCViewController(type: .news)
        vc.delegate = self
        vc.sourceId = newsId
        if let delegate = self.delegate as? TSNewsDetailViewController {
            delegate.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func likeUsersAction() {
        TSKeyboardToolbar.share.keyboarddisappear()
        if let delegate = self.delegate as? TSNewsDetailViewController {
            let likeList = TSLikeListTableVC(type: .news, sourceId: newsId)
            delegate.navigationController?.pushViewController(likeList, animated: true)
        }
    }

    func pressNewsDetailUnlikeBtn() {
        // 删除掉当前页面持有的数据内的用户ID为当前用户的数据
        guard let currentUser = TSCurrentUserInfo.share.userInfo else {
            return
        }
        for (index, user) in likeUsers.enumerated() {
            if user.userIdentity == currentUser.userIdentity {
                likeUsers.remove(at: index)
            }
        }
        let data = (likeUsers.count, likeUsers)
        self.likeUsersView.data = data
    }

    func pressNewsDetailLikeBtn() {
        // 伪造一个用户数据 用当前用户,把他加入到页面的数据中
        guard let currentUser = TSCurrentUserInfo.share.userInfo else {
            return
        }
        let user = currentUser.convert()
        likeUsers.insert(user, at: 0)
        let data = (likeUsers.count, likeUsers)
        self.likeUsersView.data = data
    }

    // MARK: reward delegate
    func tapUser() {
        let vc = TSRewardListVC.list(type: .news)
        vc.rewardId = newsId
        if let delegate = self.delegate as? TSNewsDetailViewController {
            delegate.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: chooseprice delegate
    func disMiss() {
        loadRewardInfo()
    }

    // MARK: - public
    public func loadContent() {
        loadRewardInfo()
    }

    func loadRewardInfo() {
        if TSAppConfig.share.localInfo.isOpenReward == true {
            TSNewsNetworkManager().rewardList(newsID: newsId, maxID: nil) { [weak self] (rewardModels, _) in
                if rewardModels != nil {
                    self?.rewardListView.userListDataSource = rewardModels
                }
            }
            TSNewsNetworkManager().rewardCount(newsID: newsId) { [weak self] (rewardCountModel, _) in
                if let model = rewardCountModel {
                    self?.rewardListView.rewardModel = model
                }
            }
        }
        TSNewsNetworkManager().likeList(newsId: newsId) { [weak self] (likeUserModels, _) in
            if let likeUserModels = likeUserModels {
                var tempArray = [TSUserInfoModel]()
                for likeUser in likeUserModels {
                    tempArray.append(likeUser.userDetail)
                }

                self?.likeUsers = tempArray
                let data = (likeCount: tempArray.count, users: tempArray)
                self?.likeUsersView.data = data
            }
        }
    }

    func loadAuthorData(userid: Int) {
        TSUserNetworkingManager().getUsersInfo(usersId: [userid], complete: { (usermodel, textString, succuce) in
            if succuce && usermodel?.count != nil {
                let userInfo: TSUserInfoModel = usermodel![0]
                self.user = userInfo
            }
        })
    }

    func reloadUser() {
        avatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: user.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: self.user.avatar)
        avatarInfo.verifiedIcon = self.user.verified?.icon ?? ""
        avatarInfo.verifiedType = self.user.verified?.type ?? ""
        avatarInfo.type = .normal(userId: user.userIdentity)
        self.avatar.avatarInfo = avatarInfo
        if newsDetailModel?.from == "原创" && user.userIdentity != TSCurrentUserInfo.share.userInfo?.userIdentity {
            self.followControl.isHidden = false
        } else {
            self.followControl.isHidden = true
        }
        self.followControl.isSelected = (true == user.follower) ? true : false
    }

    /// 关注状态按钮点击响应
    @objc fileprivate func followControlClick(_ control: TSFollowControl) -> Void {
        self.delegate?.newsFollow(self.view, didClickFollowControl: control)
    }
}
