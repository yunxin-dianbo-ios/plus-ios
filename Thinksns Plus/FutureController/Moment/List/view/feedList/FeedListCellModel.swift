//
//  MomentListBasicCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/10/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表基础样式 cell model

import UIKit

/// 发送状态
enum SendStatus: Int {
    /// 发送成功
    case success = 0
    /// 正在发送中
    case sending
    /// 发送失败
    case faild
}

class FeedListCellModel {

    // 数据 id 类型
    enum IdType {
        /// 广告（分页标识）
        case advert(pageId: Int, link: String)
        /// 动态（动态 id）
        case feed(feedId: Int)
        /// 帖子（圈子 id，帖子 id）
        case post(gourpId: Int, postId: Int)
        /// 话题（话题 ID， 动态ID）
        case topic(topicId: Int, postId: Int)

        var link: String? {
            switch self {
            case .advert(_, let link):
                return link
            default:
                return nil
            }
        }

        subscript(index: String) -> Int? {
            switch self {
            case .advert(let pageId, _):
                if index == "pageId" {
                    return pageId
                }
            case .feed(let feedId):
                if index == "feedId" {
                    return feedId
                }
            case .post(let groupId, let postId):
                if index == "groupId" {
                    return groupId
                }
                if index == "postId" {
                    return postId
                }
            case .topic(let topicId, let postId):
                if index == "groupId" {
                    return topicId
                }
                if index == "feedId" {
                    return postId
                }
            }
            return nil
        }
    }
    /// 用于搜索排序的
    var idindex = 0
    /// 动态 id
    var id: IdType = .feed(feedId: 0)
    /// index 用于话题动态分页
    var index: Int = 0
    /// 用户 id
    var userId: Int = 0
    /// 用户名，为空则不显示
    var userName = ""
    /// 头像信息，为 nil 则不显示头像
    var avatarInfo: AvatarInfo?
    /// 文字标题，为空则不显示
    var title = ""
    /// 文字内容，为空则不显示
    var content = ""
    /// 图片，为空则不显示
    /// 当该动态是含有视频时,会把视频的封面当做以往的单张图片处理展示
    var pictures: [PaidPictureModel] = []
    /// 文章来源，为空则不显示
    var from = ""
    /// 文章来源，为空则不显示
    var fromGroupID: Int = 0
    /// 当前微巴中的身份
    /// 角色 member-普通成员 administrator - 管理者 founder - 创建者
    var role = ""
    /// 话题，为空则不显示评论
    var topics: [TopicListModel] = []
    /// 是否显示话题板块儿
    var showTopics = false
    /// 动态所属话题的话题id
    var cellTopicId: Int = 0
    /// 工具栏信息，为 nil 则不显示工具栏
    var toolModel: FeedListToolModel?
    /// 评论，为空则不显示评论
    var comments: [FeedCommentListCellModel] = []
    /// 左边时间，为空则不显示
    var leftTime = ""
    /// 右边时间，为空则不显示
    var rightTime = ""
    /// 付费信息，为 nil 则不用付费
    var paidInfo: PaidInfo?
    /// 性别
    var sex: Int = 0

    /// 是否显示模糊文字
    var shouldAddFuzzyString = false
    /// 发送状态
    var sendStatus = SendStatus.success
    /// 发送失败的原因
    var sendStatusReason = "发送失败"
    /// 是否显示置顶标签
    var showTopIcon = false
    /// 是否显示置顶标签
    var showPostTopIcon = false
    /// 在线视频播放地址
    var videoURL: String = ""
    /// 本地视频文件地址
    var localVideoFileURL: String?
    /// 临时使用变量
    var isPlaying: Bool = false

    /// cell 高度
    var cellHeight: CGFloat = 0
    /// 转发的类型
    var repostType: String? = nil
    /// 转发的ID
    var repostId: Int = 0
    /// 转发信息
    var repostModel: TSRepostModel? = nil
    /// 热门标识
    var hot: Int = 0
    /// 加精标识，有值标识加精，没值表示不加精
    var excellent: String?

    /// 是否显示头像
    var isHiddenAvatar = false
    /// 是否显示昵称
    var isHiddenName = false
    /// 是否显示右侧时间
    var isHiddenRightTime = false
    
    init() {
    }

    /// 初始化动态收藏列表的的数据模型
    convenience init(feedCollection model: FeedListModel) {
        self.init(feedListModel: model)
        toolModel = nil
        comments = []
    }

    /// 初始话个人主页的数据模型
    convenience init(homepageModel model: FeedListModel) {
        self.init(feedListModel: model)
        // 不显示头像
        isHiddenAvatar = true
        // 不显示用户名
        isHiddenName = true
        // 不显示右边时间
        isHiddenRightTime = true
        // 显示左边时间
        leftTime = TSDate().dateString(.simple, nsDate: model.create as NSDate)
    }

    /// 初始化首页动态数据模型
    init(feedListModel model: FeedListModel) {
        idindex = model.id
        id = .feed(feedId: model.id)
        index = model.index
        userId = model.userId
        userName = model.userInfo.name
        sex = model.userInfo.sex
        avatarInfo = AvatarInfo(userModel: model.userInfo)
        avatarInfo?.type = .normal(userId: model.userInfo.userIdentity)
        content = model.content
        pictures = model.images.map { PaidPictureModel(feedImageModel: $0) }
        toolModel = FeedListToolModel(feedListModel: model)
        comments = model.comments.map { FeedCommentListCellModel(feedListCommentModel: $0) }
        topics = model.topics
        rightTime = TSDate().dateString(.normal, nsDate: model.create as NSDate)
        repostType = model.repostType
        repostId = model.repostId
        repostModel = model.repostModel
        hot = model.hot
        excellent = model.excellent
        // 1.如果有付费信息
        if let paidModel = model.paidNode, userId != TSCurrentUserInfo.share.userInfo?.userIdentity {
            // 2.先判断是否为当前用户发布的付费内容，如果是，则页面不用显示成付费状态
            guard userId != TSCurrentUserInfo.share.userInfo?.userIdentity else {
                return
            }
            // 3.判断用户是否已经付费，如果已经付费，则页面不用显示成付费状态
            guard paidModel.paid == false else {
                return
            }
            // 4.以上情况都不存在，则将视图显示成需要付费的状态
            paidInfo = PaidInfo()
            paidInfo?.type = .text
            paidInfo?.node = paidModel.node
            paidInfo?.price = Double(paidModel.amount)
            shouldAddFuzzyString = true
        }
        // 视频的处理
        // 如果存在视频时,视频的封面当做单张图片显示和处理同时设置播放地址
        if let video = model.feedVideo, video.width > 0 && video.height > 0 {
            let picture = PaidPictureModel()
            picture.url = video.videoCoverID.imageUrl()
            picture.originalSize = CGSize(width: video.width, height: video.height)
            pictures = [picture]
            videoURL = video.videoID.imageUrl()
        }
    }

    /// 初始化帖子收藏列表的的数据模型
    convenience init(postCollection model: PostListModel) {
        self.init(postModel: model)
//        toolModel = nil
         toolModel = FeedListToolModel(postListModel: model)
        comments = []
        from = model.groupInfo.name
        fromGroupID = model.groupInfo.id
    }

    /// 根据帖子 net model 来初始化
    init(postModel model: PostListModel) {
        id = .post(gourpId: model.groupId, postId: model.id)
        avatarInfo = AvatarInfo(userModel: model.userInfo)
        avatarInfo?.type = .normal(userId: model.userInfo.userIdentity)
        userId = model.userInfo.userIdentity
        userName = model.userInfo.name
        sex = model.userInfo.sex
        title = model.title
        content = model.summary
        rightTime = TSDate().dateString(.normal, nsDate: model.create as NSDate)
        pictures = model.images.map { PaidPictureModel(postImageModel: $0) }
        toolModel = FeedListToolModel(postListModel: model)
        comments = model.comments.map { FeedCommentListCellModel(postListCommentModel: $0, postId: model.id, groupId: model.groupId) }
        if let roleStr = model.groupInfo.joined?.role {
            role = roleStr
        }
        excellent = model.excellent
    }

    /// 根据话题动态 net model 来初始化
    init(topicPostModel model: TopicPostListModel) {
        id = .post(gourpId: model.groupId, postId: model.id)
        avatarInfo = AvatarInfo(userModel: model.userInfo)
        avatarInfo?.type = .normal(userId: model.userInfo.userIdentity)
        userId = model.userInfo.userIdentity
        userName = model.userInfo.name
        sex = model.userInfo.sex
        title = model.title
        content = model.summary
        rightTime = TSDate().dateString(.normal, nsDate: model.create as NSDate)
        pictures = model.images.map { PaidPictureModel(topicPostImageModel: $0) }
        toolModel = FeedListToolModel(topicPostListModel: model)
        comments = model.comments.map { FeedCommentListCellModel(topicPostListCommentModel: $0, postId: model.id, groupId: model.groupId) }
    }

    /// 自定义列表动态
    ///
    /// - Note: 用于动态列表展示新发的动态 model
    init(feedId: Int, userId: Int, userName: String, avatarInfo: AvatarInfo, content: String, pictures: [PaidPictureModel], rightTime: String, topicInfo: [TopicListModel]) {
        id = .feed(feedId: feedId)
        self.userId = userId
        self.userName = userName
        self.avatarInfo = avatarInfo
        if userId == TSCurrentUserInfo.share.userInfo!.userIdentity {
            self.avatarInfo?.type = .normal(userId: userId)
        }
        self.content = content
        self.pictures = pictures
        self.rightTime = rightTime

        self.toolModel = FeedListToolModel()
        self.sendStatus = .sending
        self.topics = topicInfo
    }

    /// 通过动态列表数据 object 初始化
    init(object: FeedListObject) {
        id = .feed(feedId: object.feedId)
        userId = object.userId
        userName = object.userName
        if let avatarObject = object.avatarInfo {
            avatarInfo = AvatarInfo(object: avatarObject)
        }
        content = object.content
        for picObject in object.pictures {
            pictures.append(PaidPictureModel(object: picObject))
        }
        if let toolObject = object.toolModel {
            toolModel = FeedListToolModel(object: toolObject)
        }
        for commentObject in object.comments {
            comments.append(FeedCommentListCellModel(object: commentObject))
        }
        leftTime = object.leftTime
        rightTime = object.rightTime
        if let paidObject = object.paidInfo {
            paidInfo = PaidInfo(object: paidObject)
        }
        shouldAddFuzzyString = object.shouldAddFuzzyString
        sendStatus = SendStatus(rawValue: object.sendStatus)!
        showTopIcon = object.showTopIcon
        showPostTopIcon = object.showPostTopIcon
        localVideoFileURL = object.localVideoFileURL
        videoURL = object.videoURl
        hot = object.hot
        excellent = object.excellent
        repostId = object.repostId
        repostType = object.repostType
        repostModel = object.repostModel
    }

    /// 从广告数据中初始化
    ///
    ///   - pageId: 广告前一条动态的分页标识
    init(advert object: TSAdvertObject) {
        guard let feedAnalog = object.analogFeed else {
            return
        }
        id = .advert(pageId: 0, link: feedAnalog.link)
        avatarInfo = AvatarInfo()
        avatarInfo?.avatarURL = feedAnalog.avatar
        userName = feedAnalog.name
        content = feedAnalog.content
        rightTime = TSDate().dateString(.normal, nsDate: feedAnalog.time)
        // 图片
        let picModel = PaidPictureModel()
        picModel.url = feedAnalog.image
        picModel.originalSize = CGSize(width: UIScreen.main.bounds.width - 116, height: UIScreen.main.bounds.width - 116)
        if let imageData = object.analogFeed {
            picModel.originalSize = CGSize(width: imageData.width, height: imageData.height)
        }
        pictures.append(picModel)
    }

    /// 从旧的发送失败的动态 object 中初始化（因为是发送失败或者发送中的，所以没有写评论转化的逻辑，也没转换付费信息）
    init(faildMoment object: TSMomentListObject) {
        guard let userInfo = TSCurrentUserInfo.share.userInfo else {
            return
        }
        id = .feed(feedId: object.feedIdentity)
        userId = object.userIdentity
        userName = userInfo.name
        sex = userInfo.sex
        let avatar = AvatarInfo()
        avatar.avatarURL = TSUtil.praseTSNetFileUrl(netFile: userInfo.avatar)
        avatar.verifiedIcon = userInfo.verified?.icon ?? ""
        avatar.verifiedType = userInfo.verified?.type ?? ""
        avatar.type = .normal(userId: userInfo.userIdentity)
        avatarInfo = avatar
        content = object.content
        for imgObject in object.pictures {
            pictures.append(PaidPictureModel(imageObject: imgObject))
        }
        for topicObj in object.topics {
            topics.append(TopicListModel(object: topicObj))
        }
        toolModel = FeedListToolModel()
        toolModel?.commentCount = object.commentCount
        toolModel?.viewCount = object.view
        toolModel?.diggCount = object.digg
        toolModel?.isDigg = object.isDigg == 1
        toolModel?.isCollect = object.isCollect == 1
        rightTime = TSDate().dateString(.normal, nsDate: object.create)
        shouldAddFuzzyString = false
        switch object.sendState {
        case 0: ///< 发送中
            sendStatus = .sending
        case 1: ///< 成功
            sendStatus = .success
        case 2: ///< 发送失败
            sendStatus = .faild
        default:
            sendStatus = .faild
        }
        sendStatusReason = object.sendStateReason
        showTopIcon = false
        localVideoFileURL = object.shortVideoOutputUrl
        /// 转发
        repostId = object.repostID
        repostType = object.repostType
        repostModel = object.repostModel
    }

    // MARK: Object

    /// 将 model 转成可以保存到数据库的动态列表 object
    ///
    /// - Parameter type: 动态列表的类型
    /// - Returns: 动态列表 object
    func object(_ type: FeedListType) -> FeedListObject {
        var object: FeedListObject
        switch type {
        case .hot:
            object = HotFeedsListObject()
        case .new:
            object = NewFeedListObject()
        case .follow:
            object = FollowFeedListObject()
        }
        object.feedId = id["feedId"] ?? 0
        object.userId = userId
        object.userName = userName
        object.sex = sex
        object.avatarInfo = avatarInfo?.object()
        object.content = content
        for picture in pictures {
            let picObject = picture.object()
            object.pictures.append(picObject)
        }
        object.toolModel = toolModel?.object()
        for comment in comments {
            let commentObject = comment.object()
            object.comments.append(commentObject)
        }
        object.leftTime = leftTime
        object.rightTime = rightTime
        object.paidInfo = paidInfo?.object()
        object.shouldAddFuzzyString = shouldAddFuzzyString
        object.sendStatus = sendStatus.rawValue
        object.showTopIcon = showTopIcon
        object.showPostTopIcon = showPostTopIcon
        object.localVideoFileURL = localVideoFileURL
        object.videoURl = videoURL
        object.hot = hot
        object.excellent = excellent
        object.repostId = repostId
        object.repostType = repostType
        object.repostModel = repostModel
        return object
    }

}

class FeedListToolModel {
    /// 是否点赞
    var isDigg = false
    /// 是否收藏
    var isCollect = false
    /// 点赞数
    var diggCount = 0
    /// 评论数
    var commentCount = 0
    /// 浏览数
    var viewCount = 1

    init() {
    }

    /// 初始化列表动态数据模型
    init(feedListModel model: FeedListModel) {
        isDigg = model.hasLike
        isCollect = model.hasCollect
        diggCount = model.likeCount
        commentCount = model.commentCount
        viewCount = model.viewCount
    }

    init(postListModel model: PostListModel) {
        isDigg = model.liked
        isCollect = model.collected
        diggCount = model.likesCount
        commentCount = model.commentCount
        viewCount = model.viewCount
    }

    init(topicPostListModel model: TopicPostListModel) {
        isDigg = model.liked
        isCollect = model.collected
        diggCount = model.likesCount
        commentCount = model.commentCount
        viewCount = model.viewCount
    }

    init(object: FeedListToolObject) {
        isDigg = object.isDigg
        isCollect = object.isCollect
        diggCount = object.diggCount
        commentCount = object.commentCount
        viewCount = object.viewCount
    }

    // MARK: Object
    func object() -> FeedListToolObject {
        let object = FeedListToolObject()
        object.isDigg = isDigg
        object.isCollect = isCollect
        object.diggCount = diggCount
        object.commentCount = commentCount
        object.viewCount = viewCount
        return object
    }
}
