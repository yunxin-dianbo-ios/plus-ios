//
//  TSMusicCommentVC.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

struct TSMusicCommentVCUX {
    /// 简介cell的高度
    static let introCellHeight: CGFloat = 100
    /// 回复框的高度
    static let commentToolViewHeight: CGFloat = 44
    /// 没有评论时 缺省视图的高度
    static let noCommentCellHeight: CGFloat = 80
}

/// 音乐评论页面展示相关需要的视图模型
class TSMusicCommentIntroModel {
    /// 音乐展示标题，非导航栏标题，用于介绍音乐。
    var title: String? // = ""
    /// 封面id
    var strogeId: Int?
    /// 收听人数
    var listenedCount: Int = 0
    /// 评论总数
    var commentCount: Int = 0

    init(title: String, storageId: Int?, listenedCount: Int, commentCount: Int) {
        self.title = title
        self.strogeId = storageId
        self.listenedCount = listenedCount
        self.commentCount = commentCount
    }
    init(album: TSAlbumDetailModel) {
        self.title = album.title
        self.strogeId = album.storage?.id
        self.listenedCount = album.tasteCount
        self.commentCount = album.commentCount
    }
    init(song: TSAlbumMusicModel) {
        self.title = song.title
        //self.strogeId = song.storage?.id
        self.strogeId = song.singer?.cover?.id
        self.commentCount = song.commentCount
    }
}

/**
 * 注：音乐评论页暂时使用TSMusicCommentController代替，等测试测试完毕后再用TSMusicCommentController代替本页中的注释代码
 这样做，可以避免出现一些bug时，无从下手或者不好解决时，可以参照之前的代码。
 甚至出现短期解决麻烦的代码时，完全可以使用注释中的代码。因为注释中的代码是完全可用的，且评论部分也已被替换。
 **/
typealias TSMusicCommentVC = TSMusicCommentController

/***
 
private let cellIdentifier_Intro = "intro"
private let cellIdentifier_comment = "comment"

class TSMusicCommentVC: TSViewController {

    /// 列表
    var tableView: TSTableView? = nil
    /// 评论框
    var commentToolView: TSMusicCommentToolView? = nil
    /// 评论的数据
    var sendingCommentList: [TSSimpleCommentModel] = [TSSimpleCommentModel]()   // 发送中的列表(无结果，默认展示再最前面)
    var failedCommentList: [TSSimpleCommentModel] = [TSSimpleCommentModel]()    // 发送失败的列表(也可能来自数据库)
    var normalCommentList: [TSSimpleCommentModel] = [TSSimpleCommentModel]()    // 正常的评论列表
    var commentArray: [TSSimpleCommentModel] = []
    /// 评论的cell高度缓存
    var commentCellHeight: [CGFloat] = []
    /// 资源id
    var sourceId: Int
    /// 类型
    let type: TSMusicCommentType
    /// 介绍模型，外界可传入，也可不传，不传时则自己内部请求详细信息
    var introModel: TSMusicCommentIntroModel?

    /// 分页标记
    var maxID: Int = 0
    /// 每页数据条数
    let limit: Int = 15
    /// 记录输入框的Y坐标
    var keyBoardViewY: CGFloat = 0

    var commentModel: TSSimpleCommentModel? = nil

    let BlackBGView: UIView = UIView(frame: CGRect(x: 0, y: -64, width: ScreenSize.ScreenWidth, height: ScreenSize.ScreenHeight))

    var index: Int = -1

    // MARK: - Initialization Function

    init(musicType: TSMusicCommentType, sourceId: Int, introModel: TSMusicCommentIntroModel? = nil) {
        self.type = musicType
        self.introModel = introModel
        self.sourceId = sourceId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - lifeCycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configKeyBoard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Typist.shared.stop()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        creatTableView()
        creatCommentView()
        if let commentCount = self.introModel?.commentCount {
            self.navigationItem.title = "评论(\(commentCount))"
        } else {
            self.navigationItem.title = "评论"
        }
        self.loadData(operation: .initial)
    }

    // MARK: - UI
    func creatTableView() {
        let navigationHeightAndStatusBarHeight = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height
        self.tableView = TSTableView(frame: CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: ScreenSize.ScreenHeight - TSMusicCommentVCUX.commentToolViewHeight - navigationHeightAndStatusBarHeight), style: .plain)
        self.tableView?.backgroundColor = .clear
        self.tableView?.tableFooterView = UIView()
        self.tableView?.separatorStyle = .none
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.register(UINib(nibName: "TSMusicCommentIntroCell", bundle: nil), forCellReuseIdentifier: cellIdentifier_Intro)
        self.tableView?.register(UINib(nibName: "TSDetailCommentTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier_comment)
        self.tableView?.mj_header = TSRefreshHeader(refreshingBlock: {
            self.refresh()
        })
        self.tableView?.mj_footer = TSRefreshFooter(refreshingBlock: {
            self.loadMore()
        })
        self.tableView?.mj_footer.isHidden = true

        self.view.addSubview(self.tableView!)
    }

    func creatCommentView() {
        self.commentToolView = TSMusicCommentToolView(frame: CGRect(x: 0, y: (self.tableView?.frame.maxY)!, width: ScreenSize.ScreenWidth, height: TSMusicCommentVCUX.commentToolViewHeight))
        self.commentToolView?.delegate = self
        self.BlackBGView.backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddnKeyBoard))
        self.BlackBGView.addGestureRecognizer(tap)
        self.view.addSubview(self.commentToolView!)
        configKeyBoard()
    }

    // MARK: - keyBaordCongfig
    func configKeyBoard() {
        Typist.shared
            .on(event: Typist.KeyboardEvent.willShow) { (options) in
                self.view.addSubview(self.BlackBGView)
                self.view.bringSubview(toFront: self.commentToolView!)
                UIView.animate(withDuration: 0.25) {
                    var frame = self.commentToolView?.frame
                    frame!.origin.y = self.view.frame.height - (options.endFrame.size.height + frame!.size.height)
                    self.commentToolView?.frame = frame!
                    self.keyBoardViewY = frame!.origin.y
                }
            }
            .on(event: .willHide, do: { (_) in
                UIView.animate(withDuration: 0.25, animations: {
                    var frame = self.commentToolView?.frame
                    frame!.origin.y = self.view.frame.height - frame!.size.height
                    self.commentToolView?.frame = frame!
                    self.keyBoardViewY = frame!.origin.y
                }, completion: { (_) in
                    self.BlackBGView.removeFromSuperview()
                })

            })
            .start()
    }

    func hiddnKeyBoard() {
        self.commentModel = nil
        self.commentToolView?.setPlaceHolderText(text: "占位符_评论".localized)
        self.commentToolView?.hiddenView()
    }

    // MARK: - refresh
    func refresh() {
        self.loadData(operation: .refresh)
    }
    func loadMore() {
        self.loadData(operation: .loadmore)
    }
    func endRefresh() {
        if (self.tableView?.mj_header.isRefreshing())! {
            self.tableView?.mj_header.endRefreshing()
        }
        if (self.tableView?.mj_footer.isRefreshing())! {
            self.tableView?.mj_footer.endRefreshing()
        }
    }

    func loadData(operation: TSListDataLoadOperate) -> Void {
        let isNeedRequestDetail: Bool = (nil == self.introModel) ? true : false
        let commentType: TSCommentType = (self.type == .album) ? .album : .song
        switch operation {
        case .initial:
            // 加载本地失败的评论列表
            let failedCommentList = TSDatabaseManager().commentManager.getAllFailedComments(type: commentType, sourceId: sourceId)
            self.failedCommentList = TSCommentHelper.convertToSimple(failedCommentList)
            self.loading()
            fallthrough
        case .refresh:
            self.maxID = 0
            // 请求数据
            TSMusicTaskManager().getMusicCommentData(type: self.type, sourceId: self.sourceId, isNeedRequestDetail: isNeedRequestDetail, limit: self.limit, complete: { [weak self](introModel, commentList, msg, status) in
                guard let WeakSelf = self else {
                    return
                }
                switch operation {
                case .initial:
                    self?.endLoading()
                case .refresh:
                    self?.endRefresh()
                default:
                    break
                }
                // 注：这里并没有判断introModel，因为需要请求introModel时有commentList则有introModel；不需要请求时则不需要判断introModel
                guard status, let commentList = commentList else {
                    // 提示加载错误
                    let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    // 显示错误
                    self?.loadFaild(type: LoadingView.FaildType.network)
                    return
                }
                if let introModel = introModel {
                    self?.introModel = introModel
                    self?.navigationItem.title = "评论(\(introModel.commentCount))"
                }
                self?.normalCommentList = commentList
                self?.commentArray = WeakSelf.failedCommentList + commentList
                if !commentList.isEmpty {
                    self?.maxID = commentList.last!.id
                }
                self?.tableView?.mj_footer.isHidden = commentList.count >= WeakSelf.limit ? false : true
                self?.commentCellHeight = TSDetailCommentTableViewCell().setCommentHeight(comments: WeakSelf.commentArray, width: ScreenSize.ScreenWidth)
                self?.tableView?.reloadData()
            })
        case .loadmore:
            // 加载更多评论列表
            TSCommentTaskQueue.getCommentList(type: commentType, sourceId: self.sourceId, afterId: self.maxID, limit: self.limit, complete: { (simpleList, msg, status) in
                self.endRefresh()
                guard status, let simpleList = simpleList else {
                    // 提示加载错误
                    let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    //self.loadFaild(type: .network)
                    return
                }
                self.normalCommentList = self.normalCommentList + simpleList
                self.commentArray = self.failedCommentList + self.normalCommentList
                if !self.normalCommentList.isEmpty {
                    self.maxID = self.normalCommentList.last!.id
                }
                self.tableView?.mj_footer.isHidden = simpleList.count >= self.limit ? false : true
                self.commentCellHeight = TSDetailCommentTableViewCell().setCommentHeight(comments: self.commentArray, width: ScreenSize.ScreenWidth)
                self.tableView?.reloadData()
            })
        }
    }
}

// MARK: - Delegate UITableViewDataSource

extension TSMusicCommentVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return 1
        }

        if commentArray.isEmpty {
            return 1
        }
        return commentArray.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }

        if nil == self.introModel || self.commentArray.isEmpty {
            return nil
        }
        let headerView = TSMusicCommentSectionHeader.headerInTableView(tableView)
        let count = self.introModel!.commentCount
        headerView.titleLabel.text = String(format: "%d人评论", count)
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier_Intro) as! TSMusicCommentIntroCell
            if let introModel = self.introModel {
                cell.reloadData(title: introModel.title!, testCount: introModel.listenedCount, strogeID: introModel.strogeId!)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier_comment) as! TSDetailCommentTableViewCell
        cell.cellDelegate = self
        if !self.commentArray.isEmpty {
            cell.commnetModel = self.commentArray[indexPath.row]
            cell.detailCommentcellType = .normal
            cell.setDatas(width: tableView.bounds.size.width)
        } else {
            cell.detailCommentcellType = .nothing
            cell.setDatas(width: tableView.bounds.size.width)
        }
        return cell
    }
}

// MARK: - Delegate UITableViewDelegate

extension TSMusicCommentVC: UITableViewDelegate {
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= CommentCountsViewUX.viewHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else if scrollView.contentOffset.y >= CommentCountsViewUX.viewHeight {
            scrollView.contentInset = UIEdgeInsets(top: -CommentCountsViewUX.viewHeight, left: 0, bottom: 0, right: 0)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        let cell = tableView.cellForRow(at: indexPath) as? TSDetailCommentTableViewCell
        if !(cell?.nothingImageView.isHidden)! {
            return
        }

        let userId = self.commentArray[indexPath.row].userInfo?.userIdentity
        if userId == (TSCurrentUserInfo.share.accountToken?.userIdentity)! {
            let customAction = TSCustomActionsheetView(titles: ["选择_删除".localized])
            self.index = indexPath.row
            customAction.delegate = self
            customAction.show()
            return
        }

        self.commentModel = self.commentArray[indexPath.row]
        self.commentToolView?.setPlaceHolderText(text: "回复: \((self.commentModel?.userInfo?.name)!)")
        self.commentToolView?.showView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        }

        if self.commentArray.isEmpty {
            return CommentCountsViewUX.top
        }
        return TSMusicCommentSectionHeader.headerHeight
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return TSMusicCommentVCUX.introCellHeight
        }

        if self.commentArray.isEmpty {
            return TSMusicCommentVCUX.noCommentCellHeight + (UIImage(named: "IMG_img_default_nothing")?.size.height)!
        }
        return commentCellHeight[indexPath.row]
    }
}

// MARK: - TSMusicCommentToolViewDelegate

extension TSMusicCommentVC: TSMusicCommentToolViewDelegate {
    // MARK: - toolViewDelehate
    func sendMessage(text: String) {
        var replayID: Int? = nil
        if self.commentModel != nil {
            replayID = self.commentModel?.userInfo?.userIdentity
        }
        // 默认展示，放置该数据到评论列表开头
        let sendingComment = TSSimpleCommentModel(content: text, replyUserId: replayID, status: 2)
        self.sendingCommentList.insert(sendingComment, at: 0)
        self.commentArray = self.sendingCommentList + self.failedCommentList + self.normalCommentList
        self.commentCellHeight = TSDetailCommentTableViewCell().setCommentHeight(comments: self.commentArray, width: ScreenSize.ScreenWidth)
        /// 更新VC数据
        self.commentModel = nil
        if let introModel = self.introModel {
            introModel.commentCount += 1
            self.navigationItem.title = "评论(\(introModel.commentCount))"
        }
        self.tableView?.reloadData()
        // 网络请求
        let commentType: TSCommentType = (self.type == .album) ? .album : .song
        TSCommentTaskQueue.submitComment(for: commentType, content: text, sourceId: self.sourceId, replyUserId: replayID) { (successModel, faildModel, _, _) in
            // 发送成功
            // 需要对sendingCommentList里进行移除，否则会对别的地方造成影响
            for (index, comment) in self.sendingCommentList.enumerated() {
                if comment.content == sendingComment.content && comment.createdAt == sendingComment.createdAt && comment.replyUserInfo?.userIdentity == sendingComment.replyUserInfo?.userIdentity {
                    self.sendingCommentList.remove(at: index)
                    break
                }
            }
            if let successModel = successModel {
                self.introModel?.commentCount += 1
                // 使用该评论代替之前的伪造评论
                self.normalCommentList.insert(successModel.simpleModel(), at: 0)
                self.commentArray = self.failedCommentList + self.normalCommentList
                self.tableView?.reloadData()
                return
            }
            // 发送失败
            if let faildModel = faildModel {
                // TODO: MusicUpdate - 音乐模块更新中，To be done
                // 发送失败的提示
                self.failedCommentList.insert(faildModel.simpleModel(), at: 0)
                self.commentArray = self.failedCommentList + self.normalCommentList
                self.tableView?.reloadData()
                return
            }
        }
    }
}

// MARK: - Delegate TSDetailCommentTableViewCellDelegate

extension TSMusicCommentVC: TSDetailCommentTableViewCellDelegate {

    func repeatTap(cell: TSDetailCommentTableViewCell, commnetModel: TSSimpleCommentModel) {
        // 获取修改处的数据
        let indexPath = self.tableView?.indexPath(for: cell)
        let content = self.commentArray[indexPath!.row].content
        let faildModel = self.failedCommentList[indexPath!.row - self.sendingCommentList.count]
        // 从数据库中移除
        TSDatabaseManager().commentManager.deleteFaildComment(commentId: faildModel.id)
        // 从当前列表中移除
        self.failedCommentList.remove(at: indexPath!.row - self.sendingCommentList.count)
        self.commentArray.remove(at: indexPath!.row)
        // 重新发送
        self.sendMessage(text: content)

        /**
         Remark: - 上述方法缺陷：
         1. 发送中关闭app时，数据库移除，且没有发送成功或失败的处理；
         2. 数据库中id没必要的增加
         可考虑优化，参考之前的做法
         */

    }

    func didSelectName(userId: Int) {
        let userHomPage = TSHomepageVC(userId)
        if let navigationController = navigationController {
            navigationController.pushViewController(userHomPage, animated: true)
        }
    }

    func didSelectHeader(userId: Int) {
        let userHomPage = TSHomepageVC(userId)
        if let navigationController = navigationController {
            navigationController.pushViewController(userHomPage, animated: true)
        }
    }
}

// MARK: - Delegate TSCustomAcionSheetDelegate

extension TSMusicCommentVC: TSCustomAcionSheetDelegate {

    // MARK: - TSCustomAcionSheetDelegate
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if index == 1 {
            return
        }
        /// 删除tableview数据
        let model = self.commentArray[self.index]
        self.commentArray.remove(at: self.index)
        if let introModel = self.introModel {
            introModel.commentCount -= 1
            self.navigationItem.title = "评论(\(introModel.commentCount))"
        }
        // 发送中的
        if 2 == model.status {
            self.sendingCommentList.remove(at: self.index)
        }
            // 本地保存的发送失败的
        else if 1 == model.status {
            self.failedCommentList.remove(at: self.index - self.sendingCommentList.count)
            TSDatabaseManager().commentManager.deleteFaildComment(commentId: model.id)
        }
            // 发送成功的
        else if 0 == model.status {
            self.normalCommentList.remove(at: self.index - self.sendingCommentList.count - self.failedCommentList.count)
            let commentType: TSCommentType = (self.type == .album) ? .album : .song
            TSCommentNetWorkManager.deleteComment(for: commentType, commentId: model.id, sourceId: self.sourceId, groupId: nil, complete: { (msg, status) in
                if !status {
                    let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            })
        }
        self.tableView?.reloadData()
    }

}

 **/
