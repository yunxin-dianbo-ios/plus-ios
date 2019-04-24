//
//  TSDataBaseManager.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/14.
//  Copyright © 2017年 LeonFa. All rights reserved.
//
//  数据库管理类

import UIKit
import RealmSwift

class TSDatabaseManager: NSObject {

    /// 用户相关
    var user = TSDatabaseUser()
    /// 动态相关
    var moment = TSDatabaseMoment()
    /// 数据库相关
    var chat = TSChatDatabaseManager()
    /// 评论相关
    var comment = TSDatabaseComment()
    /// 钱包相关
    var wallet = TSDatabaseWallet()
    /// 系统消息相关
    var system = TSDatabaseSystem()
    /// 广告相关
    var advert = TSDatabaseAdvert()

    /// 后台任务
    var task = DatabaseTask()

    /// 动态任务相关
    var momentTask = TSDatabaseMomentTask()
    /// 音乐
    var music = TSDatabaseMusic()
//    /// 图片缓存相关
//    var picCache = PictureRealmManager()

    /// 评论相关
    /// 之后应统一评论，并使用TSCommentRealmManager代替TSDatabaseComment
    var commentManager = TSCommentRealmManager()
    /// 问答模块
    let quora = TSQuoraRealmManager()

    /// 圈子(新)
    let group = GroupRealmManager()

    /// 草稿箱
    let draft = TSDraftRealmManager()

    /// 编辑器的图片缓存
    let editor = TSWebEditorRealmManager()

    override init() {
        super.init()
    }

    // MARK: - Pucblic
    /// 退出登录时清空数据库信息
    func deleteAll() {
        // 删除点赞任务
        momentTask.deleteAll()
        // 删除动态列表
        moment.deleteAll()
        // 删除聊天信息
        chat.deleteAll()
        // 删除钱包信息
        wallet.deleteAll()
        // 删除系统消息
        system.deleteAll()
        /// 删除所有动态评论
        comment.deleteAll()
        /// 删除所有音乐评论
        music.deleteAll()
        /// 清空音乐数据
        TSMusicPlayerHelper.sharePlayerHelper.clearMuiscData()
        /// 删除所有问答
        quora.deleteAll()
        /// 删除圈子(新)
        group.deleteAll()
        /// 删除动态列表(新)
        FeedListRealmManager().deleteAll()
        /// 删除所有草稿
        draft.deleteAll()
        /// 删除所有的编辑器图片缓存
        editor.deleteAll()
    }
}
