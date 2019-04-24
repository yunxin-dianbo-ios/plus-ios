//
//  PostDetailView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 08/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子帖子详情视图 - 帖子详情页中上部分的帖子详情

import UIKit
import MarkdownView

protocol PostDetailViewProtocol: class {
    /// 打赏按钮点击响应
    func postDetailView(_ postView: PostDetailView, didClickRewardBtn rewardBtn: UIButton) -> Void
    /// 打赏列表点击响应
    func didClickRewardListIn(postView: PostDetailView) -> Void
    /// 点赞列表点击响应
    func didClickLikeListIn(postView: PostDetailView) -> Void
    /// 来源按钮点击响应
    func didClickSourceIn(postView: PostDetailView) -> Void
}
extension PostDetailViewProtocol {
    /// 打赏按钮点击响应
    func postDetailView(_ postView: PostDetailView, didClickRewardBtn rewardBtn: UIButton) -> Void {
    }
    /// 打赏列表点击响应
    func didClickRewardListIn(postView: PostDetailView) -> Void {
    }
    /// 点赞列表点击响应
    func didClickLikeListIn(postView: PostDetailView) -> Void {
    }
    /// 来源按钮点击响应
    func didClickSourceIn(postView: PostDetailView) -> Void {

    }
}

class PostDetailView: UIView, TSDetailRewardListViewDelegate {
    // MARK: - Internal Property

    var delegate: PostDetailViewProtocol?
    /// 数据模型
    private(set) var model: PostDetailModel?

    // MARK: - Internal Function
    /// 加载数据，会返回高度，便于外界布局
    func loadModel(_ model: PostDetailModel, complete:((_ height: CGFloat) -> Void)? = nil) -> Void {
        self.model = model
        self.setupWithModel(model, complete: complete)
    }
    /// 添加新的打赏 - 用于打赏成功时调用
    func addNewRewardModel(_ rewardModel: TSNewsRewardModel) -> Void {
        guard let model = self.model else {
            return
        }
        model.rewardCount += 1
        model.rewardAmount += Float(rewardModel.amount)

        let rewardCountModel = TSNewsRewardCountModel()
        rewardCountModel.count = model.rewardCount
        rewardCountModel.amount = String(format: "%.2f", model.rewardAmount)
        self.rewardInfoView.rewardModel = rewardCountModel
        self.rewardInfoView.userListDataSource?.append(rewardModel)
    }

    // MARK: - Private Property

    /// 点赞用户列表
    fileprivate var likeUserList: [TSUserInfoModel] = [TSUserInfoModel]()

    /// 顶部视图
    fileprivate weak var topView: UIView!
    /// 标题
    fileprivate weak var titleLabel: UILabel!
    /// 来源
    fileprivate weak var sourceBtn: UIButton!

    /// markdown视图
    fileprivate weak var detailView: MarkdownView!

    // MARK: - TODO:  detailBottomView(extraView + rewardView) - 应考虑独立出来，写一个公用的

    // MARK: - TODO:  extraView - 应考虑独立出来，写一个公用的
    /// extraView : 点赞、发布时间、浏览人数
    fileprivate weak var detailExtraView: UIView!
    /// 点赞信息
    fileprivate weak var likeListView: TSLikedUsersView!
    /// 发布时间Label
    fileprivate weak var publishTimeLabel: UILabel!
    /// 浏览人数Label
    fileprivate weak var scanNumLabel: UILabel!

    // MARK: - TODO:  rewardView - 应考虑独立出来，写一个公用的
    /// rewardView
    fileprivate weak var rewardView: UIView!
    // 打赏视图可能并不添加，所以不能使用weak修饰。
    /// 打赏信息视图 - 打赏列表
    fileprivate var rewardInfoView: TSDetailRewardListView!
    /// 打赏按钮
    fileprivate var rewardBtn: UIButton!

    // 左右间距
    fileprivate let leftMargin: CGFloat = 10
    fileprivate let rightMargin: CGFloat = 10
    // topView高度
    fileprivate let titleTopH: CGFloat = 20
    fileprivate let sourceTopH: CGFloat = 10
    fileprivate let sourceH: CGFloat = 12
    // contentView
    fileprivate let contentTopMargin: CGFloat = 25
    fileprivate let contentBottomMargin: CGFloat = 20
    /// contentExtra
    fileprivate let contentExtraH: CGFloat = 28
    //图片数组
    var imageArray: [String] = []
    var imgStr: String?
    /// 顶部高度固定部分(title不固定)
    fileprivate var fixedTopH: CGFloat {
        return self.titleTopH + self.sourceTopH + self.sourceH
    }
    /// 打赏视图高度
    fileprivate var rewardViewH: CGFloat {
        var height: CGFloat = 0
        if TSAppConfig.share.localInfo.isOpenReward && TSAppConfig.share.localInfo.isGroupReward {
            height = self.rewardBtnTopMargin + self.rewardBtnH + self.rewardDescTopMargin + self.rewardDescH + self.rewardListTopMargin + self.rewardListH + self.rewardListBottomMargin
        }
        return height
    }
    fileprivate let rewardBtnTopMargin: CGFloat = 20
    fileprivate let rewardBtnH: CGFloat = 30
    fileprivate let rewardDescTopMargin: CGFloat = 6
    fileprivate let rewardDescH: CGFloat = 13
    fileprivate let rewardListTopMargin: CGFloat = 15
    fileprivate let rewardListH: CGFloat = 20
    fileprivate let rewardListBottomMargin: CGFloat = 20
    /// 固定高度
    fileprivate let separateH: CGFloat = 2
    fileprivate var fixedHeight: CGFloat {
        let fixedH: CGFloat = self.fixedTopH + self.contentTopMargin + self.contentBottomMargin + self.contentExtraH + self.rewardViewH
        return fixedH
    }

    // MARK: - Initialize Function
    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
        self.registerNotification()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialUI()
        self.registerNotification()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // 1. topView
        let topView = UIView()
        self.addSubview(topView)
        self.initialTopView(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self)
        }
        // 2. detailView - markdownView
        let detailView = MarkdownView()
        self.addSubview(detailView)
        // TODO: - 由于很多地方使用到MarkdownView，而每个地方都这么配置，可考虑再封装一层
        detailView.isScrollEnabled = false
        detailView.onTouchLink = { [weak self] (request) in
            debugPrint(request)
            guard let url = request.url else {
                return false
            }
            if let parentVC = self?.parentViewController {
                TSUtil.pushURLDetail(url: url, currentVC: parentVC)
            }
            return false
        }
        detailView.onTouchClick = {[weak self] (url) in
            let string: NSString = NSString(string: url)
            self?.imgStr = string.substring(from: 8)
            self?.previewPicture()
        }
        detailView.snp.makeConstraints { (make) in
            // 注：由于MarkdownView自身的左右Margin导致样式变更，所以这里约束左右为self且无需额外margin
            make.leading.trailing.equalTo(self)
            make.top.equalTo(topView.snp.bottom).offset(contentTopMargin)
            make.height.equalTo(25)    // 随便写的初始高度
        }
        self.detailView = detailView
        // 3. detailExtraView
        let extraView = UIView()
        self.addSubview(extraView)
        self.initialDetailExtraView(extraView)
        extraView.snp.makeConstraints { (make) in
            make.top.equalTo(detailView.snp.bottom).offset(self.contentBottomMargin)
            make.leading.trailing.equalTo(self)
            make.height.equalTo(self.contentExtraH)
        }
        // 4. rewardView - 打赏
        if TSAppConfig.share.localInfo.isOpenReward && TSAppConfig.share.localInfo.isGroupReward {
            let rewardView = UIView()
            self.addSubview(rewardView)
            self.initialRewardView(rewardView)
            rewardView.snp.makeConstraints { (make) in
                make.leading.trailing.equalTo(self)
                make.bottom.equalTo(self)
                make.top.equalTo(extraView.snp.bottom)
                make.height.equalTo(self.rewardViewH)
            }
        } else {
            self.rewardBtn = UIButton(cornerRadius: 3)
            self.rewardInfoView = TSDetailRewardListView(frame: CGRect.zero)
        }
    }
    /// topView布局：回答人信息、关注状态按钮
    fileprivate func initialTopView(_ topView: UIView) -> Void {
        // 1. titleLabel
        let titleLabel = UILabel(text: "", font: UIFont.boldSystemFont(ofSize: 25), textColor: TSColor.normal.blackTitle)
        topView.addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(topView).offset(leftMargin)
            make.trailing.equalTo(topView).offset(-rightMargin)
            make.top.equalTo(topView).offset(titleTopH)
            make.height.equalTo(75) // 随便写的初始高度，之后根据计算高度进行确定
        }
        self.titleLabel = titleLabel
        // 2. fromLabel
        let fromLabel = UILabel(text: "来自", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.disabled)
        topView.addSubview(fromLabel)
        fromLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(sourceTopH)
            make.leading.equalTo(titleLabel)
            make.height.equalTo(sourceH)
            make.bottom.equalTo(topView)
        }
        // 3. sourceBtn - 根据需要可能使用按钮响应
        let sourceBtn = UIButton(font: UIFont.systemFont(ofSize: 12))
        topView.addSubview(sourceBtn)
        sourceBtn.setTitleColor(TSColor.main.theme, for: .normal)
        sourceBtn.addTarget(self, action: #selector(sourceBtnClick(_:)), for: .touchUpInside)
        sourceBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(fromLabel.snp.trailing).offset(5)
            make.centerY.equalTo(fromLabel)
        }
        self.sourceBtn = sourceBtn
    }
    fileprivate func previewPicture() -> Void {
        var currentIndex: Int = 0
        var objectArray: [TSImageObject] = []
        for section in 0..<imageArray.count {
            let path = String(describing: imageArray[section])
            if path == imgStr {
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
    /// detailExtraView 布局：点赞、发布时间、浏览人数
    fileprivate func initialDetailExtraView(_ extraView: UIView) -> Void {
        // 1. 点赞头像列表视图
        let likeListView = TSLikedUsersView(frame: CGRect.zero)
        extraView.addSubview(likeListView)
        likeListView.addTarget(self, action: #selector(likeListClick), for: .touchUpInside)
        likeListView.isHidden = true    // 默认隐藏(内部不能自适应，于是外界约束了大小，避免没数据时响应)
        likeListView.snp.makeConstraints { (make) in
            make.leading.equalTo(extraView).offset(self.leftMargin)
            //make.centerY.equalTo(extraView)
            make.top.bottom.equalTo(extraView)
            make.trailing.equalTo(extraView.snp.centerX).offset(50)
        }
        self.likeListView = likeListView
        // 2. 发布时间Label
        let publishTimeLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.disabled, alignment: .right)
        extraView.addSubview(publishTimeLabel)
        publishTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(extraView)
            make.trailing.equalTo(extraView).offset(-self.rightMargin)
        }
        self.publishTimeLabel = publishTimeLabel
        // 3. 浏览人数Label
        let scanNumLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.disabled, alignment: .right)
        extraView.addSubview(scanNumLabel)
        scanNumLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(extraView)
            make.trailing.equalTo(publishTimeLabel)
        }
        self.scanNumLabel = scanNumLabel
    }
    /// rewardView布局：打赏视图布局
    fileprivate func initialRewardView(_ rewardView: UIView) -> Void {
        // 1. 打赏按钮
        let rewardBtn = UIButton(cornerRadius: 3)
        rewardView.addSubview(rewardBtn)
        rewardBtn.setTitle("显示_打赏".localized, for: .normal)
        rewardBtn.setTitleColor(UIColor.white, for: .normal)
        rewardBtn.backgroundColor = UIColor(hex: 0xf76c69)
        rewardBtn.addTarget(self, action: #selector(rewardBtnClick(_:)), for: .touchUpInside)
        rewardBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(rewardView)
            make.width.equalTo(80)
            make.height.equalTo(self.rewardBtnH)
            make.top.equalTo(rewardView).offset(self.rewardBtnTopMargin)
        }
        self.rewardBtn = rewardBtn
        // 2. 打赏信息
        let rewardInfoView = TSDetailRewardListView(frame: CGRect.zero)
        rewardView.addSubview(rewardInfoView)
        rewardInfoView.delegate = self
        rewardInfoView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(rewardView)
            make.top.equalTo(rewardBtn.snp.bottom)
        }
        self.rewardInfoView = rewardInfoView
    }

    // MARK: - Private  数据加载

    // MARK: - Private  数据加载

    /// 加载打赏信息
    private func setupRewardInfo(with model: PostDetailModel) -> Void {
        let rewardModel = TSNewsRewardCountModel()
        rewardModel.count = model.rewardCount
        rewardModel.amount = String(format: "%.2f", model.rewardAmount)
        self.rewardInfoView.rewardModel = rewardModel
        //打赏用户列表 - 请求加载
        self.loadPostExtraData(postId: model.id, favorCount: model.likesCount)
    }
    /// 加载详情页数据
    private func setupWithModel(_ model: PostDetailModel?, complete: ((_ height: CGFloat) -> Void)? = nil) -> Void {
        guard let model = model else {
            return
        }
        // 1. topView
        self.titleLabel.text = model.title
        titleLabel.sizeToFit()
        let titleH: CGFloat = self.titleLabel.frame.size.height
        self.titleLabel.snp.updateConstraints { (make) in
            make.height.equalTo(titleH)
        }
        // 来源：由之前的发布者 更正为 圈子名
        self.sourceBtn.setTitle(model.group?.name, for: .normal)
        // 3. extraInfoView
        let nsDate = NSDate(timeIntervalSince1970: model.createDate.timeIntervalSince1970)
        let strDate = TSDate().dateString(.normal, nsDate: nsDate)
        self.publishTimeLabel.text = "发布于\(strDate)"
        self.scanNumLabel.text = TSAppConfig.share.pageViewsString(number: model.viewsCount) + "人浏览"
        // 4.rewardInfo
        self.setupRewardInfo(with: model)
        // 2. detailView - content
        let string =
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
        let click =
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
        model.body = model.body.replacingOccurrences(of: "\\[image\\]", with: "[image]")
        let content = model.body.ts_customMarkdownToStandard()
        self.detailView.load(markdown: content, enableImage: true)
        self.detailView.onRendered = { [unowned self] (height) in
            self.detailView.snp.updateConstraints({ (make) in
                make.height.equalTo(height)
            })
            // 回调
            let totalH: CGFloat = self.fixedHeight + height + titleH
            complete?(totalH)
            self.detailView.webView?.evaluateJavaScript(click, completionHandler: { (_, error) in
            })
            self.detailView.webView?.evaluateJavaScript("registerImageClickAction();", completionHandler: nil)
            self.detailView.webView?.evaluateJavaScript(string, completionHandler: { (_, _) in
            })
            self.detailView.webView?.evaluateJavaScript("getImages()", completionHandler: { (image, error) in
                if error == nil {
                    if let  image = image as? NSString {
                        let array: [String] =   image.components(separatedBy: "***")
                       self.imageArray = array
                    }
                }
            })
        }
    }

    /// 加载附加数据：点赞列表、打赏相关
    fileprivate func loadPostExtraData(postId: Int, favorCount: Int) -> Void {
        // 请求打赏列表
        if TSAppConfig.share.localInfo.isOpenReward && TSAppConfig.share.localInfo.isGroupReward {
            TSRewardNetworkManger.getRewardList(type: .post, sourceId: postId, complete: { [weak self](rewardModels, msg, status) in
                guard status, let rewardModels = rewardModels else {
                    return
                }
                self?.rewardInfoView.userListDataSource = rewardModels
            })
        }
        // 请求点赞列表
        TSFavorNetworkManager.favorList(targetId: postId, targetType: .post, afterId: 0) { (favorList, msg, status) in
            guard status, let favorList = favorList else {
                return
            }
            var tempArray = [TSUserInfoModel]()
            for favormodel in favorList {
                tempArray.append(favormodel.userDetail)
            }
            if tempArray.isEmpty {
                return
            }
            self.likeUserList = tempArray
            let data = (likeCount: favorCount, users: tempArray)
            self.likeListView.data = data
            self.likeListView.isHidden = self.likeUserList.isEmpty
        }
    }

    // MARK: - Private  事件响应
    /// 来源按钮点击响应
    @objc fileprivate func sourceBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickSourceIn(postView: self)
    }
    /// 打赏按钮点击响应
    @objc fileprivate func rewardBtnClick(_ button: UIButton) -> Void {
        self.delegate?.postDetailView(self, didClickRewardBtn: button)
    }
    /// 点赞列表点击响应
    @objc fileprivate func likeListClick() -> Void {
        self.delegate?.didClickLikeListIn(postView: self)
    }

    // MARK: - Delegate Function

    // MARK: - TSDetailRewardListViewDelegate

    func tapUser() {
        self.delegate?.didClickRewardListIn(postView: self)
    }

    // MARK: - Notification

    // 底部工具栏的点赞 使用通知来进行
    fileprivate func registerNotification() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(postDetailFavorNotificationProcess), name: NSNotification.Name.PostDetail.Favor, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postDetailUnFavorNotificationProcess), name: NSNotification.Name.PostDetail.UnFavor, object: nil)
    }
    @objc fileprivate func postDetailUnFavorNotificationProcess() {
        // 删除掉当前页面持有的数据内的用户ID为当前用户的数据
        guard let currentUser = TSCurrentUserInfo.share.userInfo, let model = self.model else {
            return
        }
        for (index, user) in self.likeUserList.enumerated() {
            if user.userIdentity == currentUser.userIdentity {
                self.likeUserList.remove(at: index)
                break
            }
        }
        let data = (model.likesCount, self.likeUserList)
        self.likeListView.data = data
        self.likeListView.isHidden = self.likeUserList.isEmpty
    }
    @objc fileprivate func postDetailFavorNotificationProcess() {
        // 伪造一个用户数据 用当前用户,把他加入到页面的数据中
        guard let currentUser = TSCurrentUserInfo.share.userInfo, let model = self.model else {
            return
        }
        let user = currentUser.convert()
        self.likeUserList.insert(user, at: 0)
        let data = (model.likesCount, self.likeUserList)
        self.likeListView.data = data
        self.likeListView.isHidden = self.likeUserList.isEmpty
    }

}
