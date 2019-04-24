//
//  NoticeTableViewController.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  通知视图控制器

import UIKit

class NoticeTableViewController: TSTableViewController {
    /// 数据源
    lazy var dataSource: [NoticeDetailModel] = []
    /// 数据加载数量
    let limit = 15
    /// 父控制器
    var superViewController: Any?
    /// 分页
    var page = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.white
        title = "系统消息"
        tableView.register(NoticeTableViewCell.self, forCellReuseIdentifier: "NoticeTableViewController")
        tableView.mj_header.beginRefreshing()
        tableView.mj_footer.isHidden = true
        tableView.separatorStyle = .none
    }

    override func refresh() {
        var request = NoticeNetworkRequest().notiList
        request.urlPath = request.fullPathWith(replacers: [])
        page = 1
        let parameter: [String : Any] = ["page":page, "type": "system"]
        request.parameter = parameter
        let readGroup = DispatchGroup()
        readGroup.enter()
        RequestNetworkData.share.text(request: request) { [unowned self] (networkResult) in
            self.page += 1
            self.tableView.mj_header.endRefreshing()
            switch networkResult {
            case .error(_):
                self.page -= 1
                self.show(placeholderView: .network)
            case .failure(let response):
                self.page -= 1
                if let message = response.message {
                    self.show(indicatorA: message, timeInterval: 3)
                    return
                }
                self.show(indicatorA: "提示信息_网络错误".localized, timeInterval: 3)
            case .success(let reponse):
                if let data = reponse.model?.data {
                    self.dataSource = data
                }
                if self.dataSource.isEmpty {
                    self.show(placeholderView: .empty)
                }
                if let data = reponse.model?.data {
                    if data.count < 15 {
                        self.tableView.mj_footer.isHidden = true
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.isHidden = false
                        self.tableView.mj_footer.resetNoMoreData()
                    }
                }
                
                self.tableView.reloadData()
                readGroup.leave()
            }
        }
        readGroup.notify(queue: .main) { // 当获取完数据成功后,标记该数据已读,移除小红点
            if self.dataSource.isEmpty {
                return
            }
            var request = NoticeNetworkRequest().readAllNoti
            request.urlPath = request.fullPathWith(replacers: [])
            request.urlPath = request.urlPath + "?type=system"
            let parameter: [String : Any] = ["type": "system"]
            request.parameter = parameter

            RequestNetworkData.share.text(request: request, complete: { (_) in
                TSCurrentUserInfo.share.unreadCount.system = 0
                TSCurrentUserInfo.share.unreadCount.isHiddenNoticeBadge = true
                if let messageVC = self.superViewController as? MessageViewController {
                    messageVC.badges[1].isHidden = true
                }
            })
        }
    }

    override func loadMore() {
        var request = NoticeNetworkRequest().notiList
        request.urlPath = request.fullPathWith(replacers: [])

        let parameter: [String: Any] = ["limit": 15, "page": page, "type": "system"]
        request.parameter = parameter
        RequestNetworkData.share.text(request: request) { [unowned self] (networkResult) in
            self.page += 1
            self.tableView.mj_header.endRefreshing()
            switch networkResult {
            case .error(_):
                self.page -= 1
                self.show(placeholderView: .network)
            case .failure(let response):
                self.page -= 1
                if let message = response.message {
                    self.show(indicatorA: message, timeInterval: 3)
                    return
                }
                self.show(indicatorA: "提示信息_网络错误".localized, timeInterval: 3)
            case .success(let reponse):
                if let data = reponse.model?.data {
                    self.dataSource = self.dataSource + data
                }
                if self.dataSource.isEmpty {
                    self.show(placeholderView: .empty)
                }
                if let data = reponse.model?.data {
                    if data.count < 15 {
                        self.tableView.mj_footer.isHidden = true
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.isHidden = false
                        self.tableView.mj_footer.resetNoMoreData()
                    }
                }
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeTableViewController", for: indexPath) as! NoticeTableViewCell
        let model = dataSource[indexPath.row]
        cell.selectionStyle = .none
        
        // 解析系统消息
        var content = ""
        if let type = model.data["type"] as? String {
            if (type == "reward") {
                if let sender = model.data["sender"] as? [String:Any] {
                    if let name = sender["name"] {
                        content = "\(name)打赏了你"
                    }
                }
            } else if (type == "reward:feeds") {
                if let sender = model.data["sender"] as? [String:Any] {
                    if let name = sender["name"] {
                        content = "\(name)打赏了你的动态"
                    }
                }
            } else if (type == "reward:news") {
                if let news = model.data["news"] as? [String:Any] {
                    if let sender = model.data["sender"] as? [String:Any] {
                        if let sendername = sender["name"], let newsname = news["title"], let amount = model.data["amount"], let unit = model.data["unit"] {
                            content = "你的资讯《\(newsname)》被\(sendername)打赏了\(amount)\(unit)"
                        }
                    }
                }
            } else if (type == "user-certification") {
                if let state = model.data["state"] as? String, let contentt = model.data["contents"] as? String {
                    if (state == "rejected") {
                        content = "你申请的身份认证已被驳回，驳回理由：\(contentt)";
                    } else {
                        content = "你申请的身份认证已通过"
                    }
                }
            } else if (type == "qa:answer-adoption") {
                content = "你提交的问题回答被采纳"
            } else if (type == "question:answer") {
                content = "你提交的问题回答被采纳"
            } else if (type == "qa:reward") {
                if let sender = model.data["sender"] as? [String:Any], let name = sender["name"] as? String {
                    content = "\(name)打赏了你的回答"
                }
            } else if (type == "qa:invitation") {
                if let question = model.data["question"] as? [String:Any] {
                    if let sender = model.data["sender"] as? [String:Any] {
                        if let sendername = sender["name"], let questionname = question["subject"] {
                            content = "\(sendername)邀请你回答问题「\(questionname)」"
                        }
                    }
                }
            } else if (type == "qa:question-topic:reject") {
                if let topic = model.data["topic_application"] as? [String:Any], let name = topic["name"] {
                    content = "\(name)专题申请被拒绝"
                }
            } else if (type == "qa:question-topic:passed") {
                if let topic = model.data["topic_application"] as? [String:Any], let name = topic["name"] {
                    content = "\(name)专题申请被通过"
                }
            } else if (type == "pinned:feed/comment") {
                if let comment = model.data["comment"] as? [String:Any] {
                    if let name = comment["contents"] {
                        if let state = model.data["state"] as? String {
                            if (state == "rejected") {
                                content = "拒绝用户动态评论「\(name)」的置顶请求"
                            } else {
                                content = "同意用户动态评论「\(name)」的置顶请求"
                            }
                        }
                    }
                }
            } else if (type == "pinned:news/comment") {
                if let comment = model.data["comment"] as? [String:Any] {
                    if let news = model.data["news"] as? [String:Any] {
                        if let commentname = comment["contents"], let newsname = news["title"] {
                            if let state = model.data["state"] as? String {
                                if (state == "rejected") {
                                    content = "拒绝用户关于资讯《\(newsname)》评论「\(commentname)」的置顶请求"
                                } else {
                                    content = "同意用户关于资讯《\(newsname)》评论「\(commentname)」的置顶请求"
                                }
                            }
                        }
                    }
                }
            } else if (type == "group:comment-pinned") {
                if let state = model.data["state"] as? String {
                    if (state == "rejected") {
                        content = "拒绝用户的评论置顶请求"
                    } else {
                        content = "同意用户的评论置顶请求"
                    }
                }
            } else if (type == "group:post-pinned") {
                if let post = model.data["post"] as? [String:Any] {
                    if let name = post["title"] {
                        if let state = model.data["state"] as? String {
                            if (state == "rejected") {
                                content = "拒绝用户帖子「\(name)」的置顶请求"
                            } else {
                                content = "同意用户帖子「\(name)」的置顶请求"
                            }
                        }
                    }
                }
            } else if (type == "group:join") {
                if let group = model.data["group"] as? [String:Any], let groupname = group["name"] {
                    if let state = model.data["state"] as? String {
                        if (state == "rejected") {
                            content = "你被拒绝加入「\(groupname)」圈子"
                        } else {
                            content = "你被同意加入「\(groupname)」圈子"
                        }
                    } else {
                        if let user = model.data["user"] as? [String:Any], let username = user["name"] {
                            content = "\(username)申请加入「\(groupname)」圈子"
                        }
                    }
                }
            } else if (type == "group:send-comment-pinned") {
                if let post = model.data["post"] as? [String:Any] {
                    if let title = post["title"] {
                        content = "用户在你的帖子「\(title)」下申请评论置顶"
                    }
                }
            } else if (type == "group:post-reward") {
                if let sender = model.data["sender"] as? [String:Any], let sendername = sender["name"] as? String {
                    if let post = model.data["post"] as? [String:Any], let postname = post["title"] as? String {
                        content = "\(sendername)打赏了你的帖子「\(postname)」"
                    }
                }
            }
        }
        cell.contentLabel.text = content
        cell.createdDateLabel.text = TSDate().dateString(.normal, nsDate: model.created_at as NSDate)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        
        // 解析系统消息
        if let type = model.data["type"] as? String {
            if (type == "reward") {
                if let sender = model.data["sender"] as? [String:Any], let id = sender["id"] as? Int {
                    let vc = TSHomepageVC(id)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if (type == "reward:feeds") {
                if let feed_id = model.data["feed_id"] as? Int {
                    let detailVC = TSCommetDetailTableView(feedId: feed_id)
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
            } else if (type == "reward:news") {
                if let news = model.data["news"] as? [String:Any], let id = news["id"] as? Int {
                    let vc = TSNewsCommentController(newsId: id)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if (type == "user-certification") {
                let object = TSDatabaseManager().user.getCurrentUserCertificate()!
                // 判断是否显示"认证未通过"提示框
                let isShowPrompt = object.status != 1
                if (object.orgName != "" || object.orgAddress != "") {
                    let vc = TSEnterprisePreviewVC.previewVC()
                    vc.isShowPrompt = isShowPrompt
                    vc.model = object
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = TSPersonalPreviewVC.previewVC()
                    vc.isShowPrompt = isShowPrompt
                    vc.model = object
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if (type == "qa:answer-adoption") {
                if let answer = model.data["answer"] as? [String:Any], let id = answer["id"] as? Int {
                    let vc = TSAnswerDetailController(answerId: id)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if (type == "question:answer") {
                if let answer = model.data["answer"] as? [String:Any], let id = answer["id"] as? Int {
                    let vc = TSAnswerDetailController(answerId: id)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if (type == "qa:reward") {
                if let answer = model.data["answer"] as? [String:Any], let id = answer["id"] as? Int {
                    let vc = TSAnswerDetailController(answerId: id)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if (type == "qa:invitation") {
                if let question = model.data["question"] as? [String:Any], let id = question["id"] as? Int {
                    let quoraDetailVC = TSQuoraDetailController()
                    quoraDetailVC.questionId = id
                    self.navigationController?.pushViewController(quoraDetailVC, animated: true)
                }
            } else if (type == "qa:question-topic:passed") {
                if let topic = model.data["topic_application"] as? [String:Any], let id = topic["id"] as? Int {
                    let topicDetailVC = TopicDetailController(topicId: id)
                    self.navigationController?.pushViewController(topicDetailVC, animated: true)
                }
                
            } else if (type == "pinned:feed/comment") {
                let pendingVC = ReceivePendingController(showType: .momentCommentTop)
                self.navigationController?.pushViewController(pendingVC, animated: true)
            } else if (type == "pinned:news/comment") {
                let pendingVC = ReceivePendingController(showType: .newsCommentTop)
                self.navigationController?.pushViewController(pendingVC, animated: true)
            } else if (type == "group:comment-pinned") {
                let pendingVC = ReceivePendingController(showType: .postCommentTop)
                self.navigationController?.pushViewController(pendingVC, animated: true)
            } else if (type == "group:post-pinned") {
                let pendingVC = ReceivePendingController(showType: .postTop)
                self.navigationController?.pushViewController(pendingVC, animated: true)
            } else if (type == "group:join") {
                if let _ = model.data["state"] as? String {
                    if let group = model.data["group"] as? [String:Any], let id = group["id"] as? Int {
                        FeedListNetworkManager.requestGroupInfo(IDs: [id], complete: { (Infos, messgae) in
                            if messgae == nil {
                                if let Infos = Infos {
                                    for dataDic in Infos {
                                        /// 需要判断是否可以进入圈子详情
                                        if let joinedDic = dataDic["joined"] as? Dictionary<String, Any>, joinedDic.count > 0 {
                                            // 只要加入了的就可以进入详情
                                            let groupVC = GroupDetailVC(groupId: id)
                                            self.navigationController?.pushViewController(groupVC, animated: true)
                                        } else if let mode = dataDic["mode"] as? String, mode != "public" {
                                            let groupPreviewVC = GroupPreviewVC()
                                            groupPreviewVC.groupId = id
                                            self.navigationController?.pushViewController(groupPreviewVC, animated: true)
                                        } else {
                                            let groupVC = GroupDetailVC(groupId: id)
                                            self.navigationController?.pushViewController(groupVC, animated: true)
                                        }
                                    }
                                }
                            }
                        })
                    }
                } else {
                    let pendingVC = ReceivePendingController(showType: .groupAudit)
                    self.navigationController?.pushViewController(pendingVC, animated: true)
                }
            } else if (type == "group:send-comment-pinned") {
                if let post = model.data["post"] as? [String:Any], let id = post["id"] as? Int,
                    let group_id = model.data["group_id"] as? Int {
                    let postDetailVC = TSPostCommentController(groupId: group_id, postId: id)
                    self.navigationController?.pushViewController(postDetailVC, animated: true)
                }
            } else if (type == "group:post-reward") {
                if let post = model.data["post"] as? [String:Any], let id = post["id"] as? Int,
                    let group_id = model.data["group_id"] as? Int {
                    let postDetailVC = TSPostCommentController(groupId: group_id, postId: id)
                    self.navigationController?.pushViewController(postDetailVC, animated: true)
                }
            }
        }
    }
}
