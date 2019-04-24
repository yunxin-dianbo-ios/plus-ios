//
//  GroupNetwordRequest.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子网络请求管理类

import UIKit

class GroupNetworkRequest {

    /// 创建圈子协议
    let buildAgreement = Request<GroupAgreementModel>(method: .get, path: "plus-group/groups/protocol", replacers: [])

    /// 获取全部圈子分类
    let categroies = Request<GroupCategoriesModel>(method: .get, path: "plus-group/categories", replacers: [])

    /// 分类下圈子列表
    let categroiesGroups = Request<GroupModel>(method: .get, path: "plus-group/categories/:category/groups", replacers: [":category"])

    /// 全部圈子列表
    let allGroups = Request<GroupModel>(method: .get, path: "plus-group/groups", replacers: [])

    /// 推荐圈子列表
    let recommendGroups = Request<GroupModel>(method: .get, path: "plus-group/recommend/groups", replacers: [])

    /// 我的圈子列表
    let myGroups = Request<GroupModel>(method: .get, path: "plus-group/user-groups", replacers: [])

    /// 圈子详情
    let groupInfo = Request<GroupModel>(method: .get, path: "plus-group/groups/:group", replacers: [":group"])

    /// 加入圈子
    let joinGroup = Request<Empty>(method: .put, path: "plus-group/currency-groups/:group", replacers: [":group"])

    /// 退出圈子
    let exitGroup = Request<Empty>(method: .delete, path: "plus-group/groups/:group/exit", replacers: [":group"])

    /// 创建圈子
    let buildGroup = Request<Empty>(method: .post, path: "plus-group/categories/:category/groups", replacers: [":category"])

    /// 修改圈子
    let changeGroup = Request<Empty>(method: .patch, path: "plus-group/groups/:group", replacers: [":group"])

    /// 获取圈子总数
    let groupsCount = Request<GroupsInfoModel>(method: .get, path: "plus-group/groups/count", replacers: [])

    /// 圈子帖子列表
    let postList = Request<PostListResultsModel>(method: .get, path: "plus-group/groups/:group/posts", replacers: [":group"])
    /// 预览可见的精华帖子列表
    let previewPostList = Request<PostListModel>(method: .get, path: "group/groups/:groupId/preview-posts", replacers: [":group"])
    /// 圈子帖子详情
    let postDetail = Request<PostDetailModel>(method: .get, path: "plus-group/groups/:group/posts/:post", replacers: [":group", ":post"])

    /// 修改发帖权限
    let postCapability = Request<Empty>(method: .patch, path: "plus-group/groups/:group/permissions", replacers: [":group"])

    /// 转让圈子
    let transferGroup = Request<Empty>(method: .patch, path: "plus-group/groups/:group/owner", replacers: [":group"])

    /// 创建帖子
    static let publishPost = Request<PostPublishNetworkModel>(method: .post, path: "plus-group/groups/:group/posts", replacers: [":group"])

    /// 编辑帖子
    static let updatePost = Request<PostPublishNetworkModel>(method: .put, path: "plus-group/groups/:group/posts/:post", replacers: [":group", ":post"])

    /// 删除圈子帖子
    let deletePost = Request<Empty>(method: .delete, path: "plus-group/groups/:group/posts/:post", replacers: [":group", ":post"])

    /// 点赞帖子
    let digg = Request<Empty>(method: .post, path: "plus-group/group-posts/:post/likes", replacers: [":post"])

    /// 取消点赞帖子
    let undigg = Request<Empty>(method: .delete, path: "plus-group/group-posts/:post/likes", replacers: [":post"])

    /// 收藏帖子
    let collect = Request<Empty>(method: .post, path: "plus-group/group-posts/:post/collections", replacers: [":post"])

    /// 取消收藏帖子
    let uncollect = Request<Empty>(method: .delete, path: "plus-group/group-posts/:post/uncollect", replacers: [":post"])

    /// 收藏的帖子
    let collection = Request<PostListModel>(method: .get, path: "plus-group/user-post-collections", replacers: [])

    /// 评论帖子
    let commentPost = Request<PostSendCommentModel>(method: .post, path: "plus-group/group-posts/:post/comments", replacers: [":post"])

    /// 删除评论
    let deleteComment = Request<Empty>(method: .delete, path: "plus-group/group-posts/:post/comments/:comment", replacers: [":post", ":comment"])

    /// 申请置顶帖子
    let topPost = Request<Empty>(method: .post, path: "plus-group/currency-pinned/posts/:post", replacers: [":post"])

    /// 帖子评论申请置顶
    let topComment = Request<Empty>(method: .post, path: "plus-group/currency-pinned/comments/:comment", replacers: [":comment"])

    /// 圈主和管理员置顶帖子
    let managerTopPost = Request<Empty>(method: .post, path: "plus-group/pinned/posts/:post/create", replacers: [":post"])

    /// 圈主和管理员取消置顶帖子
    let managerCancelTopPost = Request<Empty>(method: .patch, path: "plus-group/pinned/posts/:post/cancel", replacers: [":post"])

    /// 圈主和管理员设置/取消精华帖
    let managerSetOrCancelExcellentPost = Request<Empty>(method: .put, path: "group/posts/:post/toggle-excellent", replacers: [":post"])

    /// 搜索帖子
    let searchPost = Request<PostListModel>(method: .get, path: "plus-group/group-posts", replacers: [])

    /// 我的帖子
    let myPosts = Request<PostListModel>(method: .get, path: "plus-group/user-group-posts", replacers: [])

    /// 成员管理
    struct Mmeber {
        /// 圈子成员列表
        static let memberList = Request<GroupMemberModel>(method: .get, path: "plus-group/groups/:group/members", replacers: [":group"])
        /// 移除圈子成员
        static let removeMember = Request<Empty>(method: .delete, path: "plus-group/groups/:group/members/:member", replacers: [":group", ":member"])
        /// 设置成员为管理员
        static let setManager = Request<Empty>(method: .put, path: "plus-group/groups/:group/managers/:member", replacers: [":group", ":member"])
        /// 移除一个成员的管理员角色
        static let removeManager = Request<Empty>(method: .delete, path: "plus-group/groups/:group/managers/:member", replacers: [":group", ":member"])
        /// 将一个成员加入黑名单
        static let addBlackList = Request<Empty>(method: .put, path: "plus-group/groups/:group/blacklist/:member", replacers: [":group", ":member"])
        /// 将一个成员移除黑名单
        static let removeBlackList = Request<Empty>(method: .delete, path: "plus-group/groups/:group/blacklist/:member", replacers: [":group", ":member"])
        /// 审核圈子加入请求
        static let auditJoin = Request<Empty>(method: .patch, path: "plus-group/currency-groups/:group/members/:member/audit", replacers: [":group", ":member"])
        /// 待审核成员列表
        static let auditList = Request<ReceivePendingGroupAuditModel>(method: .get, path: "plus-group/user-group-audit-members", replacers: [])
    }

    /// 收益管理
    struct Income {
        /// 圈子 收益记录列表
        static let list = Request<GroupIncomeModel>(method: .get, path: "plus-group/groups/:group/incomes", replacers: [":group"])
    }

}
