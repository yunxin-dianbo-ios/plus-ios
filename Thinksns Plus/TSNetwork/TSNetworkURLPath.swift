//
//  TSNetworkURLPath.swift
//  Thinksns Plus
//
//  Created by lip on 2016/12/16.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  网络请求路径
//  该文件正在逐渐废弃中，新增和修改网络请求相关BUG时，优先将使用此处枚举值的地方替换成 Request<T: Mappable>

import Foundation

/// 记录生成环境使用的链接地址
public enum TSURLPath: String {
    /// 历史原因遗留的无用数据,忽略即可
    case temp

    /// 拼接图片 URL
    ///
    /// - Parameters:
    ///   - storageIdentity: 图片 id
    ///   - compressionRatio: 图片压缩率
    /// - Returns: 图片链接
    @available(*, deprecated, message: "正在逐渐废弃掉该接口")
    static func imageURLPath(storageIdentity: Int?, compressionRatio: Int?) -> URL? {
        return TSURLPath.imageV2URLPath(storageIdentity: storageIdentity, compressionRatio: compressionRatio, cgSize: nil)
    }

    /// 获取图片的 URL (V2 版本)
    ///
    /// - Parameters:
    ///   - storageIdentity: 图片 id
    ///   - compressionRatio: 分辨率压缩率
    ///   - size: 格式"宽x高"，例如："1270x4380"
    @available(*, deprecated, message: "正在逐渐废弃掉该接口")
    static func imageV2URLPath(storageIdentity: Int?, compressionRatio: Int?, size: String?) -> URL? {
        guard let storageIdentity = storageIdentity else {
            return nil
        }
        var path = TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue + "/\(storageIdentity)"
        if let size = size {
            let key = "x"
            let items = size.components(separatedBy: key)
            path = path + "?w=\(items[0])&h=\(items[1])"
        }
        if let compressionRatio = compressionRatio {
            path = path + "&q=\(compressionRatio)"
        }
        return URL(string: path)
    }

    /// 获取图片的 URL (V2 版本)
    ///
    /// - Parameters:
    ///   - storageIdentity: 图片 id
    ///   - compressionRatio: 分辨率压缩率
    ///   - size: 请求获取到的图片大小,建议在列表内根据UI尺寸获取小尺寸图片
//    @available(*, deprecated, message: "正在逐渐废弃掉该接口")
    static func imageV2URLPath(storageIdentity: Int?, compressionRatio: Int?, cgSize: CGSize?) -> URL? {
        guard let storageIdentity = storageIdentity else {
            return nil
        }
        var path = TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue + "/\(storageIdentity)" + "?"
        if let size = cgSize {
            path = path + "w=\(size.width)&h=\(size.height)"
        }
        if let compressionRatio = compressionRatio {
            path = path + "&q=\(compressionRatio)"
        }
        return URL(string: path)
    }

    enum application: String {
        /// 关于我们页面
        case aboutUs = "api/v2/aboutus"
        /// 开发中的 H5 页面
        case developPage = "api/develop"
    }
}

// MARK: - V2 版本接口
enum TSURLPathV2: String {
    /// 默认路径
    case path = "api/v2/"
    /// 用户信息
    enum User: String {
        /// 当前用户
        case user
        /// 多个用户
        case users
        /// 用户的评论
        case comments = "user/comments"
        /// 用户收到的赞
        case diggs = "user/likes"
        /// token
        case auth = "auth/login"
        /// 修改用户的头像
        case updateAvatar = "user/avatar"
        /// 修改用户背景
        case updateBg = "user/bg"
        /// 认证
        case certificate = "user/certification"
        /// 环信密码
        case hyPassword = "easemob/password"
        /// 环信创建群聊
        case hyCreateGroup = "easemob/group"
        /// 环信简易群列表信息
        case hySimpleGroupInfo = "easemob/groups"

        /// 环信群增删成员 增加 .post  删除 .delete
        case hyGroupAddMember = "easemob/group/member"
        /// 管理员权限信息 .get
        case managerInfgo = "user/abilities"
    }
    /// 资讯分类
    case newsCates = "news/cates"
    /// 系统相关接口
    enum System: String {
        /// 启动加载器
        case bootstrappers
    }

    enum Account: String {
        /// 发送非会员验证码
        case sendCAPTCHAregister = "verifycodes/register"
        /// 会员验证码
        case sendCAPTCHA = "verifycodes"
        /// 重置密码
        case retrievePwd = "user/retrieve-password"
        /// 修改密码
        case updatePwd = "user/password"
     }

    /// 文件上传
    enum UploadFile: String {
        /// 文件比较
        case isUploaded = "files/uploaded"
        /// 文件上传和获取
        case files
    }

    /// 钱包
    enum Wallet: String {
        /// 配置
        case config = "wallet"
        /// 提现 post / 提现明细 get
        case withdraw = "wallet/cashes"
        /// 充值
        case recharge = "wallet/recharge"
        /// 充值，凭据取回
        case retrieve = "?mode=retrieve"
        /// 钱包明细（包含收入明细和支出明细）
        case charge = "wallet/charges"
        /// 节点付费检查
        case purchasesCheck = "purchases"
        /// 节点付费
        case purchases = "currency/purchases"
    }

    /// 动态
    enum Feed: String {
        case feeds
        /// 评论
        case comments = "/comments"
        /// 点赞
        case like = "/like"
        /// 点赞列表
        case likes = "/likes"
        /// 取消点赞
        case unlike = "/unlike"
        /// 收藏
        case collection = "/collections"
        /// 取消收藏
        case uncollect = "/uncollect"
        /// 动态置顶
        case pinneds = "/currency-pinneds"
    }

    /// 下载文件
    enum Download: String {
        case files
    }

    /// 置顶
    enum Pinned: String {
        /// 动态评论置顶审核列表
        case list = "user/feed-comment-pinneds"
        /// 评论置顶审核通过 - 注： ":feed"表示传feedId
//        case agree = "feeds/:feed/comments/:comment/pinneds/:pinned"
        /// 拒绝动态评论置顶申请
        case deny = "user/feed-comment-pinneds/"
        /// 删除动态置顶评论
//        case delete = "feeds/:feed/comments/:comment/unpinned"
        /// 动态置顶
        /// 评论置顶

    }

    /// 通知
    enum Notification: String {
        /// HEAD方式获取未读数
        /// GET方式获取通知列表
        /// GET带notificationId读取指定通知
        /// PATCH带notificationId标记通知
        case notification = "user/notifications"
    }

    /// 广告
    enum Advert: String {
        /// 获取所有广告位
        case AdPositionId = "advertisingspace"
        /// 获取某个广告位广告
        case detail = "advertisingspace/{space_id}/advertising"
        /// 获取多个广告位的广告
        case multipleDetails = "advertisingspace/advertising"
    }

    /// 圈子
    enum Group: String {
        /// 创建圈子/ 圈子动态列表
        case create = "groups"
        /// 加入/退出圈子
        case join = "groups/{group}/join"
        /// 我加入的圈子
        case joined = "groups/joined"
        /// 圈子成员
        case members = "groups/{group}/members"
        /// 圈子详情
        case detail = "groups/{group}"
        /// 圈子动态详情
        case post = "groups/{group}/posts/{post}"
        /// 获取圈子动态列表/创建圈子动态
        case posts = "groups/{group}/posts"
        /// 获取评论列表
        case comments = "groups/{group}/posts/{post}/comments"
        /// 创建评论
        case creatComment = "groups/{group}/posts/{post}/comment"
        /// 删除评论
        case comment = "groups/{group}/posts/{post}/comments/{comment}"
        /// 点赞/取消点赞 圈子动态
        case digg = "groups/{group}/posts/{post}/like"
        /// 圈子动态点赞列表
        case diggs = "groups/{group}/posts/{post}/likes"
        /// 收藏/取消收藏 圈子动态
        case collection = "groups/{group}/posts/{post}/collection"
        /// 我收藏的圈子动态列表
        case collections = "groups/posts/collections"
    }
    /// 音乐
    enum Music: String {
        /// 音乐专辑(列表、详情)
        case album = "music/specials"
        /// 收藏的专辑列表
        case collectionAlbum = "music/collections"
        /// 音乐(详情、)
        case music = "music"
    }

    /// 找人
    enum NewFriends: String {
        /// 热门用户
        case hot = "user/populars"
        /// 最新用户
        case new = "user/latests"
        /// 推荐用户
        case recommend = "user/find-by-tags"
        /// 附近用户
        case nearby = "around-amap"
        /// 搜索用户
        case search = "user/search"
        /// 搜索通讯录用户
        case contactsSearch = "user/find-by-phone"
        /// 获取经纬度
        case location = "around-amap/geo"
    }
    /// 问答
    enum Question: String {
        /// 配置，获取申请精选的费用，围观费用，匿名规则
        case configs = "question-configs"
    }
    /// 消息
    enum Message: String {
        /// at我的消息ID列表
        case atMeIDList = "user/notifications"
    }
    /// 版本号
    enum AppVersion: String {
        case appVersion = "plus-appversion?&type=ios"
    }
}
