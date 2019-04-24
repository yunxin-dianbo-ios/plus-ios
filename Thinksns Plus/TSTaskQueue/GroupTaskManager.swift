//
//  TSGroupTaskManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 08/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  新版圈子的Task管理

import Foundation

class GroupTaskManager {

}

extension GroupTaskManager {

    /// 获取帖子详情页的加载数据: 帖子详情 + 评论列表
    func getPostDetailData(postId: Int, groupId: Int, limit: Int, complete: @escaping((_ postDetail: PostDetailModel?, _ commentList: [TSSimpleCommentModel]?, _ msg: String?, _ status: Bool, _ code: Int?) -> Void)) -> Void {
        // 方案1：并行获取
        // 方案2：串行获取
        // 1. 获取帖子详情
        GroupNetworkManager.postDetail(postId: postId, groupId: groupId) { (postDetail, msg, status, code) in
            guard status, let postDetail = postDetail else {
                complete(nil, nil, msg, false, code)
                return
            }
            // 2. 获取评论列表
            TSCommentTaskQueue.getCommentList(type: .post, sourceId: postId, afterId: 0, limit: limit, complete: { (commentList, msg, status) in
                guard status, let commentList = commentList else {
                    complete(postDetail, nil, msg, status, code)
                    return
                }
                complete(postDetail, commentList, msg, status, code)
            })
        }
    }

}
