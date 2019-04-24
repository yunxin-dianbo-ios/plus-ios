//
//  TSQuoraCommentListController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 26/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题评论列表界面/问答评论列表界面

import UIKit

/**
 * 注：问题评论列表页暂时使用TSQuestionCommentController代替，等测试测试完毕后再用TSQuestionCommentController代替本页中的注释代码
 这样做，可以避免出现一些bug时，无从下手或者不好解决时，可以参照之前的代码。
 甚至出现短期解决麻烦的代码时，完全可以使用注释中的代码。因为注释中的代码是完全可用的，且评论部分也已被替换。
 **/
typealias TSQuestionCommentListController = TSQuestionCommentController

/***
 
typealias TSQuoraCommentListController = TSQuestionCommentListController
class TSQuestionCommentListController: TSViewController {

    // MARK: - Internal Property
    /// 问题id
    var questionId: Int?
    /// 评论总数
    var commentCount: Int = 0
    // MARK: - Private Property
    /// 评论列表单次请求限制条数
    private let limit: Int = 20
    /// 评论列表加载更多时的分页标记Id
    private var afterId: Int = 0

    fileprivate weak var commentToolView: TSMusicCommentToolView!
    fileprivate weak var tableView: TSTableView!

    private let kbBgView: UIView = UIView(frame: UIScreen.main.bounds)

    private let commentToolH: CGFloat = 44
    fileprivate let cellIdentifier = "TSDetailCommentTableViewCellReuseIdentifier"

    fileprivate var sourceList: [TSSimpleCommentModel] = [TSSimpleCommentModel]()
    fileprivate var cellHeightList: [CGFloat] = [CGFloat]()

    /// 当前弹窗的index
    fileprivate var index: Int = 0
    /// 当前回复的评论
    fileprivate var commentModel: TSSimpleCommentModel?

    // MARK: - Initialize Function
    // MARK: - Internal Function
    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }

    // MARK: - Private  UI

    private func initialUI() -> Void {
        self.view.backgroundColor = UIColor.white
        // 1. navigationbar
        self.navigationItem.title = "评论(\(self.commentCount))"
        // 2. 文字输入工具栏
        let commentToolView = TSMusicCommentToolView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: commentToolH))
        self.view.addSubview(commentToolView)
        commentToolView.delegate = self
        commentToolView.commentToolView?.changeHeightClosure = { [weak self] value in
            commentToolView.snp.updateConstraints({ (make) in
                make.height.equalTo(value)
            })
            self?.view.updateConstraintsIfNeeded()
        }
        commentToolView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            // 内容变化时约束变化
            make.height.equalTo(commentToolH)
            // 键盘谈起时约束变化
            make.bottom.equalTo(self.view).offset(0)
        }
        self.commentToolView = commentToolView
        self.configKeyBoard()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddnKeyBoard))
        self.kbBgView.addGestureRecognizer(tap)
        // 3. tableView
        let tableView = TSTableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "TSDetailCommentTableViewCell", bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
        tableView.mj_header = TSRefreshHeader(refreshingBlock: {
            self.refresh()
        })
        tableView.mj_footer = TSRefreshFooter(refreshingBlock: {
            self.loadMore()
        })
        tableView.mj_footer.isHidden = true
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            // 注：模拟器上需要更正为offset(64)，否则展示异常，但真机没有该问题.
            make.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-commentToolH)
        }
        self.tableView = tableView
    }

    // MARK: - Private  数据处理与加载
    /// 数据初始化
    private func initialDataSource(isRefresh: Bool = false) -> Void {
        // 网络获取
        if isRefresh {
            self.requestCommentList(isInitial: false, isRefresh: isRefresh)
        } else {
            self.requestCommentList(isInitial: true, isRefresh: isRefresh)
        }
    }
    /// 下拉刷新
    private func refresh() -> Void {
        self.initialDataSource(isRefresh: true)
    }
    /// 上拉加载更多
    private func loadMore() -> Void {
        self.requestCommentList(isInitial: false, isRefresh: false)
    }
    // 网络请求评论列表
    /// - isInitial  第一次请求 - 展示初始化动画
    /// - isRefresh  刷新      - 展示刷新动画
    // 注：这里应采用枚举方式，initial/refresh/loadmore三种方式，并可以提取到其他页面也使用。
    private func requestCommentList(isInitial: Bool, isRefresh: Bool) -> Void {
        guard let questionId = self.questionId else {
            return
        }
        if isInitial {
            // 初始加载动画 - loading
            self.loading()
            self.afterId = 0
            self.sourceList.removeAll()
        } else if isRefresh {
            self.afterId = 0
            self.sourceList.removeAll()
        }
        // 获取问题的评论列表
        TSCommentTaskQueue.getCommentList(type: .question, sourceId: questionId, afterId: self.afterId, limit: self.limit) { (commentList, msg, status) in
            // 动画结束
            if isInitial {
                self.endLoading()
            } else if isRefresh {
                self.tableView.mj_header.endRefreshing()
            }
            // 请求异常处理
            guard status, let commentList = commentList else {
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            // 请求成功处理
            if isInitial || isRefresh {
                self.tableView.mj_footer.isHidden = commentList.count < self.limit
            }
            if commentList.isEmpty {
                // 显示空页面
                self.tableView.show(placeholderView: .empty)
            } else {
                self.tableView.removePlaceholderViews()
                self.afterId = commentList.last!.id
            }
            self.sourceList += commentList
            self.cellHeightList = TSDetailCommentTableViewCell().setCommentHeight(comments: self.sourceList, width: ScreenWidth)
            self.tableView.reloadData()
        }
    }

    // MARK: - Private  事件响应

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.hiddnKeyBoard()
    }

    // MARK: - keyBaordCongfig
    func configKeyBoard() {
        Typist.shared
            .on(event: Typist.KeyboardEvent.willShow) { (options) in
                self.view.addSubview(self.kbBgView)
                self.view.bringSubview(toFront: self.commentToolView)
                UIView.animate(withDuration: 0.25) {
                    self.commentToolView.snp.updateConstraints({ (make) in
                        make.bottom.equalTo(self.view).offset(-options.endFrame.size.height)
                    })
                    self.view.updateConstraintsIfNeeded()
                }
            }
            .on(event: .willHide, do: { (_) in
                UIView.animate(withDuration: 0.25, animations: {
                    self.commentToolView.snp.updateConstraints({ (make) in
                        make.bottom.equalTo(self.view).offset(0)
                    })
                    self.view.updateConstraintsIfNeeded()
                }, completion: { (_) in
                    self.kbBgView.removeFromSuperview()
                })

            })
            .start()
    }

    func hiddnKeyBoard() {
        self.commentModel = nil
        self.commentToolView?.setPlaceHolderText(text: "占位符_评论".localized)
        self.commentToolView?.hiddenView()
    }

    // MARK: - Notification
}

// MARK: - UITableViewDataSource

extension TSQuestionCommentListController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as! TSDetailCommentTableViewCell
        cell.commnetModel = self.sourceList[indexPath.row]
        cell.detailCommentcellType = .normal
        cell.setDatas(width: ScreenWidth)
        cell.cellDelegate = self
        return cell
    }

}

// MARK: - UITableViewDataSource

extension TSQuestionCommentListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeightList[indexPath.row]
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 未登录处理
        if !TSCurrentUserInfo.share.isLogin {
            return
        }
        let comment = self.sourceList[indexPath.row]
        let userId = comment.userInfo?.userIdentity
        if userId == (TSCurrentUserInfo.share.accountToken?.userIdentity)! {
            let customAction = TSCustomActionsheetView(titles: ["选择_删除".localized])
            self.index = indexPath.row
            customAction.delegate = self
            customAction.show()
            return
        }
        self.commentToolView.setPlaceHolderText(text: "回复: \((comment.userInfo?.name)!)")
        self.commentModel = comment
        self.commentToolView.showView()
    }
}

// MARK: - TSDetailCommentTableViewCellDelegate

extension TSQuestionCommentListController: TSDetailCommentTableViewCellDelegate {
    func repeatTap(cell: TSDetailCommentTableViewCell, commnetModel: TSSimpleCommentModel) {
        // 获取修改处的数据
        let indexPath = self.tableView?.indexPath(for: cell)
        let content = commnetModel.content
        // 从数据库中移除
        // 从当前列表中移除
        self.sourceList.remove(at: indexPath!.row)
        // 重新发送
        self.sendMessage(text: content)

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

// MARK: - TSMusicCommentToolViewDelegate

extension TSQuestionCommentListController: TSMusicCommentToolViewDelegate {
    /// 发送消息按钮点击回调
    func sendMessage(text: String) {
        guard let questionId = self.questionId else {
            return
        }
        // TODO: - 这里可以进行优化
        var replayID: Int? = nil
        if self.commentModel != nil {
            replayID = self.commentModel?.userInfo?.userIdentity
        }
        // 发送请求
        TSCommentTaskQueue.submitComment(for: .question, content: text, sourceId: questionId, replyUserId: replayID) { (successModel, faildModel, msg, _) in
            if let successModel = successModel {
                // 修改当前页展示的评论数，
                // 更改数据库，待完成
                self.commentCount += 1
                self.navigationItem.title = "评论(\(self.commentCount))"
                self.sourceList.insert(successModel.simpleModel(), at: 0)
                self.cellHeightList = TSDetailCommentTableViewCell().setCommentHeight(comments: self.sourceList, width: ScreenWidth)
                self.tableView.removePlaceholderViews()
                self.tableView?.reloadData()
                return
            }
            // 发送失败
            if let faildModel = faildModel {
                // 发送失败的提示
                let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                self.sourceList.insert(faildModel.simpleModel(), at: 0)
                self.cellHeightList = TSDetailCommentTableViewCell().setCommentHeight(comments: self.sourceList, width: ScreenWidth)
                self.tableView.removePlaceholderViews()
                self.tableView?.reloadData()
                return
            }
        }
    }
}

// MARK: - TSCustomAcionSheetDelegate

extension TSQuestionCommentListController: TSCustomAcionSheetDelegate {
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        guard let questionId = self.questionId else {
            return
        }
        // 删除
        if 0 == index {
            // 移除列表中当前待删除的选项
            let model = self.sourceList.remove(at: self.index)
            self.cellHeightList = TSDetailCommentTableViewCell().setCommentHeight(comments: self.sourceList, width: ScreenWidth)
            self.tableView.reloadData()
            // 根据model的状态分别处理
            if 2 == model.status {
                // 发送中的
            } else if 1 == model.status {
                // 本地保存的发送失败的
                // 注：数据库中移除，数据库处理待添加
            } else if 0 == model.status {
                // 发送成功的
                TSCommentTaskQueue.deleteComment(for: .question, commentId: model.id, sourceId: questionId, complete: { (msg, status) in
                    if status {
                        // 更新title中的评论总数
                        self.commentCount -= 1
                        self.navigationItem.title = "评论(\(self.commentCount))"
                    } else {
                        let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    }
                })
            }
        }
    }
}

 **/
