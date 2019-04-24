//
//  TaskObject.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift

class TaskObject: Object {

    /// 唯一标识，请使用 TaskIdPrefix 作为 id 的前缀
    dynamic var id = ""
    /// 任务的完成状态，0 进行中，1 已完成，2 未完成
    dynamic var taskStatus = 2

    // MARK: 附加参数

    /// 任务将要执行的操作，一般用于任务具有两种状态时。例如 1/0 ：收藏/取消收藏，点赞/取消点赞
    let operation = RealmOptional<Int>()

    /// 设置主键
    override static func primaryKey() -> String? {
        return "id"
    }

    /// 通过 task id 获取相关 id 信息
    func getIdInfo1() -> Int {
        let ids = id.components(separatedBy: ".")
        let idInfo = Int(ids[3])!
        return idInfo
    }

    func getIdInfo2() -> (Int, Int) {
        let ids = id.components(separatedBy: ".")
        let idInfo1 = Int(ids[3])!
        let idInfo2 = Int(ids[4])!
        return(idInfo1, idInfo2)
    }

    func getIdInfo3() -> (Int, Int, Int) {
        let ids = id.components(separatedBy: ".")
        let idInfo1 = Int(ids[3])!
        let idInfo2 = Int(ids[4])!
        let idInfo3 = Int(ids[5])!
        return(idInfo1, idInfo2, idInfo3)
    }

}

enum TaskIdPrefix {

    // 圈子
    enum Group: String {
        /// 帖子点赞
        case postDigg = "task.group.post_digg"
        /// 收藏帖子
        case postCollect = "task.group.post_collect"
        /// 加入/退出圈子
        case joinGroup = "task.group.group_join"
        /// 删除帖子
        case deletePost = "task.group.delete_post"
        /// 删除帖子评论
        case deleteComment = "task.group.delete_comment"
    }

    // 广告
    enum Advert: String {
        case update = "task.advert.update"
    }

    // 用户
    enum User: String {
        case certificate = "task.user.certificate"
    }
}
