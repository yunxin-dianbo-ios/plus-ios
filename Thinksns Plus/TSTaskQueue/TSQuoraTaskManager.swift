//
//  TSQuoraTask.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问答模块的操作封装

import Foundation

class TSQuoraTaskManager {

}

// MARK: - 问答列表

// MARK: - 问答详情

extension TSQuoraTaskManager {
    /// 网络获取问答详情页的数据(问答详情 + 答案列表)
    func networkQuoraDetailData(in questionId: Int, offset: Int = 0, orderType: TSAnserOrderType = .diggCount, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ((_ quoraDetail: TSQuoraDetailModel?, _ answerList: [TSAnswerListModel]?, _ msg: String?, _ status: Bool, _ code: Int?) -> Void)) -> Void {
        // 方案1：并行获取
        // 方案2：串行获取
        // 1. 获取问答详情
        self.networkQuoraDetail(in: questionId) { (quoraDetail, msg, status, code) in
            guard status, let quoraDetail = quoraDetail else {
                complete(nil, nil, msg, false, code)
                return
            }
            // 2. 获取答案列表
            self.networkAnswerList(in: questionId, offset: offset, orderType: orderType, limit: limit, complete: { (answerList, msg, status) in
                guard status, let answerList = answerList else {
                    complete(quoraDetail, nil, msg, status, code)
                    return
                }
                complete(quoraDetail, answerList, msg, status, code)
            })
        }
    }
    /// 本地获取问答详情页的数据(问答详情 + 答案列表)
    func localQuoraDetailData(in questionId: Int, answerOrderType: TSAnserOrderType) -> (quoraDetail: TSQuoraDetailModel?, answerList: [TSAnswerListModel]?) {
        let quoraDetail = TSDatabaseManager().quora.getQuoraDetail(in: questionId)
        let answerList = TSDatabaseManager().quora.getAnswerList(in: questionId, orderType: answerOrderType)
        return (quoraDetail, answerList)
    }

    /// 网络获取问答详情
    func networkQuoraDetail(in questionId: Int, complete: @escaping ((_ quoraDetail: TSQuoraDetailModel?, _ msg: String?, _ status: Bool, _ code: Int?) -> Void)) -> Void {
        TSQuoraNetworkManager.getQuoraDetail(questionId: questionId) { (quoraDetail, msg, status, code) in
            if status, let quoraDetail = quoraDetail {
                // 数据库操作
                TSDatabaseManager().quora.save(quoraDetail)
                complete(quoraDetail, msg, status, code)
            } else {
                complete(nil, msg, status, code)
            }
        }
    }
    /// 本地获取问答详情
    func localQuoraDetail(in questionId: Int) -> TSQuoraDetailModel? {
        return TSDatabaseManager().quora.getQuoraDetail(in: questionId)
    }

    /// 网络获取问答答案列表
    /// 具体参数，请参看对应的网络请求
    func networkAnswerList(in questionId: Int, offset: Int = 0, orderType: TSAnserOrderType = .diggCount, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ((_ answerList: [TSAnswerListModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        TSQuoraNetworkManager.getAnswerList(questionId: questionId, offset: offset, orderType: orderType, limit: limit) { (answerList, msg, status) in
            if status, let answerList = answerList {
                // 数据库操作
                if 0 >= offset {
                    TSDatabaseManager().quora.delteAnswerList(in: questionId)
                }
                TSDatabaseManager().quora.save(answerList)
                complete(answerList, msg, status)
            } else {
                complete(nil, msg, status)
            }
        }
    }
    // TODO: - 本地获取，应该增加排序方式，连数据库也应同步修正
    /// 本地获取问答答案列表
    func localAnswerList(in questionId: Int, orderType: TSAnserOrderType) -> [TSAnswerListModel] {
        return TSDatabaseManager().quora.getAnswerList(in: questionId, orderType: orderType)
    }
}

// MARK: - 答案详情

extension TSQuoraTaskManager {
    /// 获取答案的详情
    func networkAnswerDetail(for answerId: Int, complete: @escaping ((_ answerDetail: TSAnswerDetailModel?, _ msg: String?, _ status: Bool, _ code: Int?) -> Void)) -> Void {
        TSQuoraNetworkManager.getAnswerDetail(answerId) { (answerDetail, msg, status, code) in
            guard status, let answerDetailModel = answerDetail else {
                if let answerDetail = answerDetail {
                    complete(answerDetail, msg, status, code)
                } else {
                    complete(nil, msg, status, code)
                }
                return
            }
            complete(answerDetailModel, msg, status, code)
        }
    }

    /// 获取答案界面的数据： 答案详情 + 评论列表
    func networkAnswerDetailData(for answerId: Int, afterId: Int = 0, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping ((_ answerDetail: TSAnswerDetailModel?, _ commentList: [TSSimpleCommentModel]?, _ msg: String?, _ status: Bool, _ code: Int?) -> Void)) -> Void {
        // 方案1：并行获取
        // 方案2：串行获取
        // 1. 获取答案详情
        self.networkAnswerDetail(for: answerId) { (answerDetail, msg, status, code) in
            guard status, let answerDetailModel = answerDetail else {
                if let answerDetail = answerDetail {
                    complete(answerDetail, nil, msg, false, code)
                } else {
                    complete(nil, nil, msg, false, code)
                }
                return
            }
            TSCommentTaskQueue.getCommentList(type: .answer, sourceId: answerId, afterId: afterId, limit: limit, complete: { (commentList, msg, status) in
                guard status, let commentList = commentList else {
                    complete(answerDetailModel, nil, msg, status, code)
                    return
                }
                complete(answerDetailModel, commentList, msg, status, code)
            })
        }
    }

}

// MARK: - 发布问答

// MARK: - 话题相关
