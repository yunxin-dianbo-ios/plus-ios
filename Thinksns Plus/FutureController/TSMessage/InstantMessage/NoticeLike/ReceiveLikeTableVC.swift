//
// Created by lip on 2017/9/16.
// Copyright (c) 2017 ZhiYiCX. All rights reserved.
//
// 收到的喜欢表格视图控制器

import Foundation

class ReceiveLikeTableVC: TSTableViewController, NoticePendingProtocol {
    // MARK: - property
    var dataSource: [ReceiveLikeModel] = []
    /// 翻页
    var page = 1

    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "收到的赞"
        tableView.register(NoticeContentCell.self, forCellReuseIdentifier: "NoticePendingCell")
        tableView.mj_header.beginRefreshing()
        tableView.mj_footer.isHidden = true
    }
    // MARK: - Delegete
    // MARK: Refresh delegate
    override func refresh() {
        /// 清除对应的小红点
        var request = UserNetworkRequest().readCounts
        request.urlPath = request.fullPathWith(replacers: [])
        request.urlPath = request.urlPath + "?type=like"
        RequestNetworkData.share.text(request: request) { (_) in
            // 直接清理本地的数据
            TSCurrentUserInfo.share.unreadCount.like = 0
        }
        page = 1
        NoticeReceiveInfoNetworkManager.receiveLikeList(after: page) { [weak self] (models, _) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tableView.mj_header.endRefreshing()
            weakSelf.page += 1
            guard let models = models else {
                weakSelf.page -= 1
                weakSelf.show(placeholderView: .network)
                return
            }
            if models.isEmpty {
                weakSelf.show(placeholderView: .empty)
                return
            }
            weakSelf.dataSource = models
            weakSelf.tableView.mj_footer.isHidden = models.count < TSAppConfig.share.localInfo.limit
            weakSelf.tableView.reloadData()
        }
    }

    // MARK: LoadMoreFooterDelegate
    override func loadMore() {
        guard let _ = self.dataSource.last else {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
            return
        }
        NoticeReceiveInfoNetworkManager.receiveLikeList(after: page) { [weak self] models, _ in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tableView.mj_footer.endRefreshing()
            weakSelf.page += 1
            guard let models = models else {
                weakSelf.page -= 1
                weakSelf.show(placeholderView: .network)
                return
            }
            if models.isEmpty {
                weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            weakSelf.dataSource += models
            if models.count < TSAppConfig.share.localInfo.limit {
                weakSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            weakSelf.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticePendingCell") as! NoticePendingCell
        cell.config = dataSource[indexPath.row].convert()
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }

    // MARK: - did click
    func notice(pendingCell: NoticePendingCell, didClickRegion: NoticePendingCellClickRegion) {
        let model = dataSource[pendingCell.indexPath.row]
        switch didClickRegion {
        case .avatar, .title:
            let userHomPage = TSHomepageVC(model.userId)
            navigationController?.pushViewController(userHomPage, animated: true)
        case .subTitle:
            break // 该页面没有使用这个区域.不应该出现该类型回调
        case .content:
            break // 该页面没有使用这个区域.不应该出现该类型回调
        case .pending:
            break // 该页面没有使用这个区域.不应该出现该类型回调
        case .exten:
            didClickExtenRegion(model)
        }
    }

    private func didClickExtenRegion(_ model: ReceiveLikeModel) {
        // 点赞列表中，资源被删除时 仍需显示点赞对象，不过内容为"该资源已删除"，点击时会走这里
        guard  let exten = model.exten, let targetId = exten.targetId else {
            //assert(false, "点击了页面的扩展区域,但是查询到的数据没有扩展数据")
            return
        }
        switch model.sourceType {
        case .feed:
            let detailVC = TSCommetDetailTableView(feedId: targetId)
            navigationController?.pushViewController(detailVC, animated: true)
        case .group:
            if let groupId = exten.groupId {
                let postDetailVC = PostDetailController(groupId: groupId, postId: targetId)
                self.navigationController?.pushViewController(postDetailVC, animated: true)
            }
        case .song:
            let commentVC = TSMusicCommentVC(musicType: .song, sourceId: targetId)
            navigationController?.pushViewController(commentVC, animated: true)
        case .musicAlbum:
            let commentVC = TSMusicCommentVC(musicType: .album, sourceId: targetId)
            navigationController?.pushViewController(commentVC, animated: true)
        case .news:
            let newsDetailVC = TSNewsDetailViewController(newsId: targetId)
            self.navigationController?.pushViewController(newsDetailVC, animated: true)
        case .question:
            let quoraDetailVC = TSQuoraDetailController()
            quoraDetailVC.questionId = targetId
            navigationController?.pushViewController(quoraDetailVC, animated: true)
        case .answers:
            let answerDetailVC = TSAnswerDetailController(answerId: targetId)
            navigationController?.pushViewController(answerDetailVC, animated: true)
        }
    }
}
