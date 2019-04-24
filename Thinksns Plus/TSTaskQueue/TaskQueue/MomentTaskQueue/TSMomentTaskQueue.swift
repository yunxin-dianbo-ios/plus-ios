//
//  TSMomentTaskQueue.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  任务队列 - 动态相关

import UIKit
import Photos
import RealmSwift
import ReachabilitySwift
import Kingfisher
import AVKit

struct WebpCacheSerializer: CacheSerializer {
    func data(with image: Image, original: Data?) -> Data? {
        return original
    }

    func image(with data: Data, options: KingfisherOptionsInfo?) -> Image? {
        return UIImage(data: data)
    }
}

class TSMomentTaskQueue: NSObject {
    /// 单页动态条数
    static let listLimit = TSAppConfig.share.localInfo.limit
    /// 默认图片压缩后最大物理体积200kb
    fileprivate static let postImageMaxSizeKb: CGFloat = 200
    /// 赞/收藏的网络请求次数
    let networkCountMax = 1
    /// 点赞网络请求次数记录
    var diggNetCountArray: [Int: Int] = [:]
    /// 收藏网络请求次数记录
    var collectNetCountArray: [Int: Int] = [:]
    /// 删除网络请求次数记录
    var deleteNetCountArray: [Int: Int] = [:]
    /// 添加过的删除未成功的id
    var deleteFeedId: [Int] = Array()
    /// 添加过的id
    var appendFeedId: [Int] = Array()
    /// 动态编号记录，防止在列表刷新时被删除
    static var usingMomentIdentity: Int?

    // MARK: Other
    /// 获取用户的 Identity
    public func getUserIdenity(_ objects: [TSMomentListObject]) -> [Int] {
        var userIdentities: [Int] = []
        for object in objects {
            if !userIdentities.contains(object.userIdentity) {
                userIdentities.append(object.userIdentity)
            }
        }
        for object in objects {
            for item in object.comments {
                if  !userIdentities.contains(item.userIdentity) {
                     userIdentities.append(item.userIdentity)
                }

                if item.replayToUserIdentity != 0 && !userIdentities.contains(item.userIdentity) {
                    userIdentities.append(item.replayToUserIdentity)
                }
            }
        }
        return userIdentities
    }

    /// 合成 cellModel
    public func makeCellModels(_ momentObjects: [TSMomentListObject], _ userInfoModels: [Int: TSUserInfoObject], isNetWork: Bool, isTop: Bool) -> [TSMomentListCellModel] {
        var cellModels: [TSMomentListCellModel] = []
        for momentObject in momentObjects {
            var cellModel = TSMomentListCellModel()
            calculationCommentCount(mommetObject: momentObject, isNetWork: isNetWork)
            cellModel.data = momentObject
            cellModel.comments = makeCommentModels(mommentObject: momentObject, feedId: momentObject.feedIdentity, isNetWork: isNetWork)
            cellModel.isShowTopTag = isTop
            cellModel.userInfo = userInfoModels[momentObject.userIdentity]
            cellModels.append(cellModel)
        }
        return cellModels
    }

    /// 计算包括发送和删除的点赞数
    ///
    /// - Parameter mommetObject: 动态模型
    func calculationCommentCount(mommetObject: TSMomentListObject, isNetWork: Bool) {
        if isNetWork {
           calculationDleteCount(mommetObject: mommetObject)
        }

        let failComments = TSDatabaseManager().comment.get(feedId: mommetObject.feedIdentity)
        if let sends = failComments {
            if !appendFeedId.contains(mommetObject.feedIdentity) {
                for item in sends {
                    var isHave = false
                    for comment in mommetObject.comments {
                        if comment.commentMark == item.commentMark {
                            isHave = true
                        }
                    }

                    if isHave {
                        continue
                    }
                    if item.feedId == mommetObject.feedIdentity {
                        appendFeedId.append(item.feedId)
                        let realm = try! Realm()
                        realm.beginWrite()
                        mommetObject.commentCount += 1
                        try! realm.commitWrite()
                    }
                }
            }
        }
    }

    /// 计算删除后的评论数量
    private func calculationDleteCount(mommetObject: TSMomentListObject) {
        let deleteCommentsTask = TSDatabaseManager().comment.getDeleteTask()
        if !deleteFeedId.contains(mommetObject.feedIdentity) {
            if let delete = deleteCommentsTask {
                for item in delete {
                    if item.feedId.value == mommetObject.feedIdentity {
                        for deletem in mommetObject.comments {
                            if deletem.commentMark == item.commentMark.value {
                                deleteFeedId.append(item.feedId.value!)
                                let realm = try! Realm()
                                realm.beginWrite()
                                mommetObject.commentCount -= 1
                                try! realm.commitWrite()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - 发布
    /// 合成评论的Model
    func makeCommentModels(mommentObject: TSMomentListObject, feedId: Int, isNetWork: Bool) -> [TSSimpleCommentModel] {
        var commentCellModels: [TSSimpleCommentModel] = Array()
        let deleteCommentsTask = TSDatabaseManager().comment.getDeleteTask()
        for item in mommentObject.comments {
            var isHaveDeleteTask = false
            // 遍历还没删除的任务，如果有就不添加到展示页面，针对网络请求
            if let deleteComments = deleteCommentsTask {
                for delete in deleteComments {
                    if delete.commentMark.value == item.commentMark {
                        isHaveDeleteTask = true
                    }
                }
            }

            if isHaveDeleteTask {
                continue
            }

            checkSendComment(mommentObject: mommentObject, comment: item, commentCellModels: &commentCellModels, isNetWork: isNetWork)

            let commentUserInfo = TSDatabaseManager().user.get(item.userIdentity)
            var replyUserInfo: TSUserInfoObject?
            if item.replayToUserIdentity != 0 {
                replyUserInfo = TSDatabaseManager().user.get(item.replayToUserIdentity)
            }
            let model = TSSimpleCommentModel(userInfo: commentUserInfo, replyUserInfo: replyUserInfo, content: item.content, createdAt: item.create, id: item.commentIdentity, commentMark: item.commentMark, status: item.status, isTop: item.painned.value == 1)
            commentCellModels.append(model)
        }

        if mommentObject.comments.isEmpty {
            checkSendComment(mommentObject: mommentObject, comment: nil, commentCellModels: &commentCellModels, isNetWork: true)
        }

        // 1.提取置顶的评论
        let topComment = commentCellModels.filter { $0.isTop == true }
        // 2.其他评论根据 id 来排序
        var normalComment = commentCellModels.filter { $0.isTop == false }
        normalComment.sort { (s1, s2) -> Bool in
            return s1.id > s2.id
        }
        // 3.对评论重新进行排序
        let finalComments = topComment + normalComment

        return finalComments
    }

    /// 检查还没发送成功的评论
    func checkSendComment(mommentObject: TSMomentListObject, comment: TSMomentCommnetObject?, commentCellModels: inout [TSSimpleCommentModel], isNetWork: Bool) {
        if isNetWork {
            let failComments = TSDatabaseManager().comment.get(feedId: mommentObject.feedIdentity)
            if let comments = failComments {
                for failComment in comments {
                    var isHave = false
                    for comment in mommentObject.comments {
                        if comment.commentMark == failComment.commentMark {
                            isHave = true
                        }
                    }

                    if isHave {
                        continue
                    }

                    let realm = try! Realm()
                    realm.beginWrite()
                    let commentObject = TSMomentCommnetObject()
                    commentObject.feedId = failComment.feedId
                    commentObject.commentIdentity = failComment.commentIdentity
                    commentObject.content = failComment.content
                    commentObject.create = failComment.create
                    commentObject.replayToUserIdentity = failComment.replayToUserIdentity
                    commentObject.toUserIdentity = failComment.toUserIdentity
                    commentObject.userIdentity = failComment.userIdentity
                    commentObject.commentMark = failComment.commentMark
                    commentObject.status = 1
                    realm.add(commentObject, update: true)
                    mommentObject.comments.append(commentObject)
                    try! realm.commitWrite()

                    let commentUserInfo = TSDatabaseManager().user.get(commentObject.userIdentity)
                    var replyUserInfo: TSUserInfoObject?
                    if commentObject.replayToUserIdentity != 0 {
                        replyUserInfo = TSDatabaseManager().user.get(commentObject.replayToUserIdentity)
                    }
                    let model = TSSimpleCommentModel(userInfo: commentUserInfo, replyUserInfo: replyUserInfo, content: commentObject.content, createdAt: commentObject.create, id: commentObject.commentIdentity, commentMark: commentObject.commentMark, status: commentObject.status, isTop: false)
                    commentCellModels.append(model)
                }
            }
        } else {
            let failComments = TSDatabaseManager().comment.get(feedId: (comment?.feedId)!)
            if let comments = failComments {
                for failComment in comments {
                    if failComment.commentMark == comment?.commentMark {
                        let realm = try! Realm()
                        realm.beginWrite()
                        comment?.status = 1
                        try! realm.commitWrite()
                    }
                }
            }
        }

    }

    func postShortVideo(urlPath: String, coverImage: UIImage, feedContent: String?, topicsInfo: [TopicCommonModel]? = [], isTopicPublish: Bool) {
        // 生成数据缓存数据
        // 上传数据
        // 发布动态
        var outPutData: Data?
        if let recorderData = try? Data(contentsOf: URL(string: urlPath)!) {
            // 自己录制的视频这样读数据 三方库搞的
            outPutData = recorderData
        }
        if let localData = try? Data(contentsOf: URL(fileURLWithPath: urlPath)) {
            // 相册选的视频这样读数据
            outPutData = localData
        }
        guard let _ = outPutData else {
            return
        }
        /*
        1、需要先生成feedID，然后移动将要发送的视频文件至指定"/tmp/videoFeedFiles/uid"的目录下，并以feedID.mp4命名
        2、后续发送成功后在回调中删除对应的视频文件
        3、shortVideoOutputUrl：视频的名称（包含文件后缀）,如：1534484580.mp4
        4、缓存视频的完整路径由TSUtil.getWholeFilePath(name: "1534484580.mp4")获取
         */
        let filePath = urlPath.components(separatedBy: "/").last!
        let videoPath = NSHomeDirectory() + "/tmp/" + filePath
        let videoFeedPath = TSUtil.getWholeFilePath(name: "")
        // 判断该文件夹是否存在，若不存在则创建
        let videoFeedFilePathIsExist = FileManager.default.fileExists(atPath: videoFeedPath)
        if videoFeedFilePathIsExist == false {
            try! FileManager.default.createDirectory(atPath: videoFeedPath, withIntermediateDirectories: true, attributes: nil)
        }
        let feedID = TSCurrentUserInfo.share.createResourceID()
        let videoFeedName = "\(feedID)" + ".mp4"
        // 如果存在同名的文件先移除，再移动
        if FileManager.default.fileExists(atPath: videoFeedPath + videoFeedName) == true {
            try! FileManager.default.removeItem(at: URL(fileURLWithPath: videoFeedPath + videoFeedName))
        }
        // 移动到指定文件夹
        if FileManager.default.fileExists(atPath: videoPath) == true {
            try! FileManager.default.moveItem(at: URL(fileURLWithPath: videoPath), to: URL(fileURLWithPath: videoFeedPath + videoFeedName))
        }
        let asset = AVAsset(url: URL(fileURLWithPath: videoFeedPath + videoFeedName))
        guard let videoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first else {
            return
        }
        // 缓存图片
        ImageCache.default.store(coverImage, forKey: String(feedID), toDisk: true)
        var imageCacheKeys: [String] = []
        var imageSizes: [CGSize] = []
        // 封面图的本地缓存为feedID
        imageCacheKeys.append(String(feedID))
        // 封面的尺寸等于视频的原始尺寸
        imageSizes.append(CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height))
        let momentListObject = TSDatabaseManager().moment.save(feedID: feedID, shortVideoOutputUrl: videoFeedName, feedContent: feedContent ?? "", feedTitle: nil, coordinate: nil, imageCacheKeys: imageCacheKeys, imageSizes: imageSizes, imageMimeTypes: ["image/jpeg"], userId: TSCurrentUserInfo.share.userInfo!.userIdentity, nsDate: NSDate(), topicsInfo: topicsInfo)
        self.uploadVideo(momentListObject: momentListObject, isTopicPublish: isTopicPublish)
        momentListObject.sendState = 0 ///< 发送中
        TSDatabaseManager().moment.save(momentRelease: momentListObject)
        // 收到通知的地方 根据已有的本地信息构建UI
        NotificationCenter.default.post(name: isTopicPublish ? NSNotification.Name.Moment.TopicAddNew : NSNotification.Name.Moment.AddNew, object: nil, userInfo: ["newFeedId": momentListObject.feedIdentity])
    }

    func uploadVideo(momentListObject: TSMomentListObject, isTopicPublish: Bool) {
        var outPutData: Data?
        let filePath = TSUtil.getWholeFilePath(name: momentListObject.shortVideoOutputUrl!)
        do {
            let url = URL(fileURLWithPath: filePath)
            outPutData = try Data(contentsOf: url)
        } catch let error {
            print(error)
        }
        guard let videoData = outPutData else {
            DispatchQueue.main.async {
                let realm = try! Realm()
                realm.beginWrite()
                momentListObject.sendState = 2 ///< 2 发送失败
                momentListObject.sendStateReason = "视频路径错误"
                try! realm.commitWrite()
                // 发送失败的动态 只有 oldId
                NotificationCenter.default.post(name: isTopicPublish ? NSNotification.Name.Moment.TopicAddNew : NSNotification.Name.Moment.AddNew, object: nil, userInfo: ["oldId": momentListObject.feedIdentity])
            }
            return
        }
        guard let picture = momentListObject.pictures.first else {
            assert(false)
            return
        }
        var coverData: Data = Data()
        if let data = ImageCache.default.retrieveImageInMemoryCache(forKey: picture.cacheKey)?.kf.jpegRepresentation(compressionQuality: 1.0) {
            coverData = data
        } else if let data = ImageCache.default.retrieveImageInDiskCache(forKey: picture.cacheKey)?.kf.jpegRepresentation(compressionQuality: 1.0) {
            coverData = data
        }
        // 上传视频
        // 上传图片
        // 上传资源可以重复上传
        let videoSize = CGSize(width: picture.width, height: picture.height)
        DispatchQueue.global(qos: .background).async {
            var videoFileID: Int? = nil
            var imageFildID: Int? = nil
            let requestGroup = DispatchGroup()
            requestGroup.enter()
            requestGroup.enter()
            TSUploadNetworkManager().uploadVideoFile(data: videoData, videoSize: videoSize) { (fileID, _, _) in
                videoFileID = fileID
                requestGroup.leave()
            }

            TSUploadNetworkManager().uploadFile(data: coverData) { (fileID, _, _) in
                imageFildID = fileID
                requestGroup.leave()
            }

            requestGroup.notify(queue: DispatchQueue.main) {
                guard let videoFileID = videoFileID, let imageFildID = imageFildID else {
                    let realm = try! Realm()
                    realm.beginWrite()
                    momentListObject.sendState = 2 ///< 2 发送失败
                    momentListObject.sendStateReason = "视频上传失败"
                    try! realm.commitWrite()
                    // 发送失败的动态 只有 oldId
                    NotificationCenter.default.post(name: isTopicPublish ? NSNotification.Name.Moment.TopicAddNew : NSNotification.Name.Moment.AddNew, object: nil, userInfo: ["oldId": momentListObject.feedIdentity])
                    return
                }
                // 必须都上传成功了才能发布文本动态信息
                self.postShortVideoTextInfo(momentListObject: momentListObject, videoFildID: videoFileID, coverImageID: imageFildID, feedContent: momentListObject.content, isTopicPublish: isTopicPublish)
            }
        }
    }

    func postShortVideoTextInfo(momentListObject: TSMomentListObject, videoFildID: Int, coverImageID: Int, feedContent: String?, isTopicPublish: Bool) {
        // 成功发送成功的通知 错误发送错误的通知
        TSMomentNetworkManager().postShortVideo(momentListObject: momentListObject, shortVideoID: videoFildID, coverImageID: coverImageID, feedContent: feedContent) { (feedId, error) in
            if momentListObject.isInvalidated {
                return
            }
            if let feedId = feedId {
                // [重写注意] 由于重写了动态列表是剥离了数据库的，而旧的"动态发布结果"的通知，并不能传递足够的信息给列表。需要进行修改，后面重写动态发布时，再讨论一下通知需要发送的具体参数
                DispatchQueue.main.async {
                    let oldFeedId = momentListObject.feedIdentity
                    let realm = try! Realm()
                    realm.beginWrite()
                    momentListObject.sendState = 1 ///< 发送成功
                    momentListObject.feedIdentity = feedId
                    try! realm.commitWrite()
                    TSDatabaseManager().moment.save(userMoments: TSCurrentUserInfo.share.userInfo!.userIdentity, objects: [momentListObject])
                    /*
                     1、发布成功需要移除沙盒中缓存的视频文件，但是不能直接删除
                     发送过程中/发送失败的动态直接播放的是本地文件
                     如果发送过程中播放该视频，等后台发送完毕之后视频文件被删除播放就会出错，提示网络连接失败
                     
                     方案调整为：
                     每次启动应用检查是否有缓存的视频，如果有视频且没有对应的发布失败的动态就删除掉
                     */
                    /// 发送成功
                    NotificationCenter.default.post(name: isTopicPublish ? NSNotification.Name.Moment.TopicAddNew : NSNotification.Name.Moment.AddNew, object: nil, userInfo: ["oldId": oldFeedId, "newId": feedId])
                }
                return
            }
            if error != nil {
                DispatchQueue.main.async {
                    let realm = try! Realm()
                    realm.beginWrite()
                    momentListObject.sendState = 2 ///< 发送失败
                    momentListObject.sendStateReason = error?.userInfo["NSLocalizedDescription"] as! String
                    try! realm.commitWrite()
                    TSDatabaseManager().moment.save(momentRelease: momentListObject)
                    // [重写注意] 由于重写了动态列表是剥离了数据库的，而旧的"动态发布结果"的通知，并不能传递足够的信息给列表。需要进行修改，后面重写动态发布时，再讨论一下通知需要发送的具体参数
                    let oldFeedId = momentListObject.feedIdentity
                    NotificationCenter.default.post(name: isTopicPublish ? NSNotification.Name.Moment.TopicAddNew : NSNotification.Name.Moment.AddNew, object: nil, userInfo: ["oldId": oldFeedId])
                }
            }
        }
    }

    /// 上传发布动态的图片,重发也调用了该函数
    ///
    /// - Parameter momentListObject: 数据模型
    func releasePulseImages(momentListObject: TSMomentListObject, isTopicPublish: Bool) {
        guard momentListObject.pictures.isEmpty == false else {
            releaseText(momentListObject: momentListObject, storageTaskIds: [], isTopicPublish: isTopicPublish)
            return
        }
        let picInfos: [(mimeType: String, cacheKey: String, payType: Int)] = momentListObject.pictures.map { (imageObject) -> (mimeType: String, cacheKey: String, payType: Int) in
            var picInfo: (mimeType: String, cacheKey: String, payType: Int)
            picInfo.mimeType = imageObject.mimeType
            picInfo.cacheKey = imageObject.cacheKey
            picInfo.payType = imageObject.payType
            return picInfo
        }
        DispatchQueue.global(qos: .background).async {
            let webpCacheSerializer = WebpCacheSerializer()
            let imageDatas: [Data] = picInfos.map { (picInfo) -> Data in
                var uploadData: Data = Data()
                if picInfo.mimeType == "image/jpeg" {
                    // 如果不是GIF的图片，就压缩一下,原始的二进制流不能直接上传，非iOS/macOS系统打不开
                    // 但是100%的转换图片会很大
                    if let data = ImageCache.default.retrieveImageInMemoryCache(forKey: picInfo.cacheKey)?.kf.jpegRepresentation(compressionQuality: 1.0) {
                        uploadData = data
                    } else if let data = ImageCache.default.retrieveImageInDiskCache(forKey: picInfo.cacheKey)?.kf.jpegRepresentation(compressionQuality: 1.0) {
                        uploadData = data
                    }
                    // 非付费图片需要压缩
                    if picInfo.payType != 0 {
                        uploadData = TSUtil.compressImageData(imageData: uploadData, maxSizeKB: TSMomentTaskQueue.postImageMaxSizeKb)
                    }
                } else if picInfo.mimeType == "image/gif" {
                    if let data = ImageCache.default.retrieveImageInMemoryCache(forKey: picInfo.cacheKey, options: [.cacheSerializer(webpCacheSerializer)])?.kf.gifRepresentation() {
                        uploadData = data
                    } else if let data = ImageCache.default.retrieveImageInDiskCache(forKey: picInfo.cacheKey, options: [.cacheSerializer(webpCacheSerializer)])?.kf.gifRepresentation() {
                        uploadData = data
                    }
                } else if picInfo.mimeType == "image/png" {
                    if let data = ImageCache.default.retrieveImageInMemoryCache(forKey: picInfo.cacheKey, options: [.cacheSerializer(webpCacheSerializer)])?.kf.pngRepresentation() {
                        uploadData = data
                    } else if let data = ImageCache.default.retrieveImageInDiskCache(forKey: picInfo.cacheKey, options: [.cacheSerializer(webpCacheSerializer)])?.kf.pngRepresentation() {
                        uploadData = data
                    }
                    // 非付费图片需要压缩
                    if picInfo.payType != 0 {
                        uploadData = TSUtil.compressImageData(imageData: uploadData, maxSizeKB: TSMomentTaskQueue.postImageMaxSizeKb)
                    }
                }
                return uploadData
            }
            let mimeTypes: [String] = picInfos.map { (picInfo) -> String in
                return picInfo.mimeType
            }

            TSUploadNetworkManager().upload(imageDatas: imageDatas, mimeTypes: mimeTypes, index: 0, finishIDs: []) { imageFileds in
                DispatchQueue.main.async {
                    if imageFileds.isEmpty == false {
                        TSMomentTaskQueue().releaseText(momentListObject: momentListObject, storageTaskIds: imageFileds, isTopicPublish: isTopicPublish)
                    } else {
                            // 发送失败
                            let realm = try! Realm()
                            realm.beginWrite()
                            momentListObject.sendState = 2
                            momentListObject.sendStateReason = "图片上传失败"
                            try! realm.commitWrite()
                            TSDatabaseManager().moment.save(momentRelease: momentListObject)
                    }
                }
            }
        }
    }

    /// 发布文本内容
    ///
    /// - Parameters:
    ///   - momentListObject: 数据模型
    ///   - storageTaskIds: 图片的唯一Id[]
    ///   - isTopicPublish: 是不是从话题详情页发布的动态
    func releaseText(momentListObject: TSMomentListObject, storageTaskIds: [Int], isTopicPublish: Bool) {
        TSMomentNetworkManager().release(momentListObject: momentListObject, storageTaskIds: storageTaskIds) { (feedId, error) in
            DispatchQueue.main.async {
                if let feedId = feedId {
                    // [重写注意] 由于重写了动态列表是剥离了数据库的，而旧的"动态发布结果"的通知，并不能传递足够的信息给列表。需要进行修改，后面重写动态发布时，再讨论一下通知需要发送的具体参数
                        let oldFeedId = momentListObject.feedIdentity
                    NotificationCenter.default.post(name: isTopicPublish ? NSNotification.Name.Moment.TopicAddNew : NSNotification.Name.Moment.AddNew, object: nil, userInfo: ["oldId": oldFeedId, "newId": feedId])
                        let realm = try! Realm()
                        realm.beginWrite()
                        momentListObject.sendState = 1
                        momentListObject.feedIdentity = feedId
                        try! realm.commitWrite()
                        TSDatabaseManager().moment.save(userMoments: TSCurrentUserInfo.share.userInfo!.userIdentity, objects: [momentListObject])
                        return
                }
                // 发送失败
                let realm = try! Realm()
                realm.beginWrite()
                momentListObject.sendStateReason = error?.userInfo["NSLocalizedDescription"] as! String
                momentListObject.sendState = 2
                try! realm.commitWrite()
                TSDatabaseManager().moment.save(momentRelease: momentListObject)
                // [重写注意] 由于重写了动态列表是剥离了数据库的，而旧的"动态发布结果"的通知，并不能传递足够的信息给列表。需要进行修改，后面重写动态发布时，再讨论一下通知需要发送的具体参数
                let oldFeedId = momentListObject.feedIdentity
                NotificationCenter.default.post(name: isTopicPublish ? NSNotification.Name.Moment.TopicAddNew : NSNotification.Name.Moment.AddNew, object: nil, userInfo: ["oldId": oldFeedId])
            }
        }
    }

    /// 启动时检查是否有失败的发布动态任务，有则转成失败状态
    func checkReleaseFailTask(isOpenApp: Bool) {
        if isOpenApp {
            let faildSendMoments: [TSMomentListObject]? = TSDatabaseManager().moment.getFaildSendMoments()
            guard let faildSendMoment = faildSendMoments else {
                return
            }
            TSDatabaseManager().moment.replace(momentRelease: faildSendMoment)
        }
    }
}
