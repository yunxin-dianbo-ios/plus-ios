//
//  TSMusicCommentController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 09/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  音乐评论控制器，测试完成后，将代码覆盖到 TSMusicCommentVC
//  注：评论选中处理 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)

import UIKit

class TSMusicCommentController: TSCommentListController {

    let musicType: TSMusicCommentType

    /// 评论框
    fileprivate var commentToolView: TSMusicCommentToolView!
    /// 介绍模型，外界可传入，也可不传，不传时则自己内部请求详细信息
    fileprivate var introModel: TSMusicCommentIntroModel?

    fileprivate let kbBgView: UIView = UIView(frame: UIScreen.main.bounds)
    fileprivate let commentToolH: CGFloat = 44
    fileprivate let cellIdentifierMusicIntro = "TSMusicIntroTableViewCellReuseIdentifier"

    init(musicType: TSMusicCommentType, sourceId: Int, introModel: TSMusicCommentIntroModel? = nil) {
        self.musicType = musicType
        self.introModel = introModel
        let commentType: TSCommentType = (musicType == .album) ?  .album : .song
        super.init(type: commentType, sourceId: sourceId, groupId: nil)
        self.commentCount = introModel?.commentCount ?? 0
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configKeyBoard()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Typist.shared.stop()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.hiddnKeyBoard()
    }

    override func requestData(_ type: TSListDataLoadType) -> Void {
        var isNeedRequestDetail: Bool = true
        if self.introModel != nil && type == .initial {
            isNeedRequestDetail = false
        }
        switch type {
        case .initial:
            self.loading()
            fallthrough
        case .refresh:
            self.afterId = 0
            // 请求数据            
            TSMusicTaskManager().getMusicCommentData(type: self.musicType, sourceId: self.sourceId, isNeedRequestDetail: isNeedRequestDetail, limit: self.limit, complete: { [weak self](introModel, commentList, msg, status) in
                guard let WeakSelf = self else {
                    return
                }
                // 注：这里并没有判断introModel，因为需要请求introModel时有commentList则有introModel；不需要请求时则不需要判断introModel
                guard status, let commentList = commentList else {
                    switch type {
                    case .initial:
                        self?.loadFaild(type: .network)
                    case .refresh:
                        self?.tableView.mj_header.endRefreshing()
                        let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    case .loadmore:
                        break
                    }
                    return
                }
                // 注：这个应放在网络出错之前，因为endLoading和loadFaild只能两个显示一个。
                switch type {
                case .initial:
                    self?.endLoading()
                case .refresh:
                    self?.tableView.mj_header.endRefreshing()
                case .loadmore:
                    break
                }
                // 注：评论总数还需加上失败的本地评论，且这里也可能并不存在introModel。待修正
                if let introModel = introModel {
                    self?.introModel = introModel
                    self?.navigationItem.title = "评论(\(introModel.commentCount))"
                    self?.commentCount = introModel.commentCount
                }
                // 注：别的地方重新加载列表时，调用下拉刷新操作，若将移除代码放置在请求前，可能导致崩溃，因数据被移除但另外那边正在重新加载列表。
                self?.sourceList.removeAll()
                let faildList = TSDatabaseManager().commentManager.getAllFailedComments(type: WeakSelf.type, sourceId: WeakSelf.sourceId)
                self?.sourceList += TSCommentHelper.convertToSimple(faildList)
                self?.sourceList += commentList
                self?.cellHeightList = TSDetailCommentTableViewCell().setCommentHeight(comments: WeakSelf.sourceList, width: ScreenWidth)
                self?.afterId = commentList.last?.id ?? WeakSelf.afterId
                self?.tableView.mj_footer.isHidden = commentList.count != WeakSelf.limit
                self?.tableView.reloadData()
            })
        case .loadmore:
            // 加载更多评论
            super.requestData(.loadmore)
        }
    }

}

// MARK: - UI加载

extension TSMusicCommentController {
    override func initialUI() {
        super.initialUI()

        if let commentCount = self.introModel?.commentCount {
            self.navigationItem.title = "评论(\(commentCount))"
        } else {
            self.navigationItem.title = "评论"
        }

        self.tableView.snp.remakeConstraints { (make) in
            make.top.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-commentToolH)
        }
        self.tableView.register(UINib(nibName: "TSMusicCommentIntroCell", bundle: nil), forCellReuseIdentifier: self.cellIdentifierMusicIntro)

        self.initialCommentToolView()
    }

    func initialCommentToolView() -> Void {
        // 文字输入工具栏
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
    }
}

// MARK: - 键盘弹窗相关

extension TSMusicCommentController {
    // keyBoardCongfig
    func configKeyBoard() {
        Typist.shared
            .on(event: Typist.KeyboardEvent.willShow) { (options) in
                self.view.addSubview(self.kbBgView)
                self.view.bringSubview(toFront: self.commentToolView)
                self.commentToolView.commentToolView?.smileButton.isSelected = false
                self.commentToolView.commentToolView?.changeFrame(show: true)
                self.commentToolView.commentToolView?.emojiView.isHidden = true
                let newSize = self.commentToolView.commentToolView?.sendTextView.sizeThatFits(CGSize(width: (self.commentToolView.commentToolView?.sendTextView.frame.size.width)!, height: CGFloat(MAXFLOAT)))
                let currentComponentHeight = 8 + 0.5 + (newSize?.height)!
                UIView.animate(withDuration: 0.25) {
                    if currentComponentHeight >= 120 {
                        self.commentToolView.snp.updateConstraints({ (make) in
                            make.bottom.equalTo(self.view).offset(-options.endFrame.size.height)
                            make.height.equalTo(120 - 20)
                        })
                    } else {
                        self.commentToolView.snp.updateConstraints({ (make) in
                            make.bottom.equalTo(self.view).offset(-options.endFrame.size.height)
                            make.height.equalTo(currentComponentHeight)
                        })
                    }
                    self.view.updateConstraintsIfNeeded()
                }
            }
            .on(event: .willHide, do: { (_) in
                self.commentToolView.commentToolView?.smileButton.isSelected = true
                self.commentToolView.commentToolView?.changeFrame(show: false)
                self.commentToolView.commentToolView?.emojiView.isHidden = false
                let newSize = self.commentToolView.commentToolView?.sendTextView.sizeThatFits(CGSize(width: (self.commentToolView.commentToolView?.sendTextView.frame.size.width)!, height: CGFloat(MAXFLOAT)))
                let currentComponentHeight = 8 + 0.5 + (newSize?.height)! + 145 + TSBottomSafeAreaHeight
                UIView.animate(withDuration: 0.25, animations: {
                    if currentComponentHeight >= 120 + 145 + TSBottomSafeAreaHeight {
                        self.commentToolView.snp.updateConstraints({ (make) in
                            make.bottom.equalTo(self.view).offset(0)
                            make.height.equalTo(120 + 145 + TSBottomSafeAreaHeight - 20)
                        })
                    } else {
                        self.commentToolView.snp.updateConstraints({ (make) in
                            make.bottom.equalTo(self.view).offset(0)
                            make.height.equalTo(currentComponentHeight)
                        })
                    }
                    self.view.updateConstraintsIfNeeded()
                }, completion: { (_) in
                })
            })
            .start()
    }

    func hiddnKeyBoard() {
        self.commentModel = nil
        self.commentToolView?.setPlaceHolderText(text: "显示_说点什么吧".localized)
        self.commentToolView.commentToolView?.smileButton.isSelected = false
        self.commentToolView.commentToolView?.setInBottom()
        let newSize = self.commentToolView.commentToolView?.sendTextView.sizeThatFits(CGSize(width: (self.commentToolView.commentToolView?.sendTextView.frame.size.width)!, height: CGFloat(MAXFLOAT)))
        let currentComponentHeight = 8 + 0.5 + (newSize?.height)!
        UIView.animate(withDuration: 0.25, animations: {
            if currentComponentHeight >= 120 {
                self.commentToolView.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(self.view).offset(-TSBottomSafeAreaHeight)
                    make.height.equalTo(120 - 20)
                })
            } else {
                self.commentToolView.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(self.view).offset(-TSBottomSafeAreaHeight)
                    make.height.equalTo(currentComponentHeight)
                })
            }
            self.view.updateConstraintsIfNeeded()
        }, completion: { (_) in
            self.kbBgView.removeFromSuperview()
        })
    }
}

// MARK: - Delegate UITableViewDataSource

extension TSMusicCommentController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }

        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }

        if nil == self.introModel {
            return nil
        }
        self.commentCount = self.introModel?.commentCount ?? 0
        return super.tableView(tableView, viewForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if 0 == indexPath.section {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifierMusicIntro) as! TSMusicCommentIntroCell
            if let introModel = self.introModel {
                cell.reloadData(title: introModel.title!, testCount: introModel.listenedCount, strogeID: introModel.strogeId!)
            }
            return cell
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
}

// MARK: - Delegate UITableViewDelegate

extension TSMusicCommentController {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= CommentCountsViewUX.viewHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else if scrollView.contentOffset.y >= CommentCountsViewUX.viewHeight {
            scrollView.contentInset = UIEdgeInsets(top: -CommentCountsViewUX.viewHeight, left: 0, bottom: 0, right: 0)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if 0 == indexPath.section {
            return TSMusicCommentVCUX.introCellHeight
        }
        if self.sourceList.isEmpty {
            return ScreenHeight - TSMusicCommentVCUX.introCellHeight - commentToolH
        }
        return self.cellHeightList[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if 0 == section {
            return 0.01
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return super.tableView(tableView, heightForFooterInSection: section)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if 0 == indexPath.section {
            return
        }
        // 不能使用父类的处理方案，因为父类处理的都没有底部的输入框。使用父类的处理方案，会导致回复他人时的输入框紊乱。
        if self.sourceList.isEmpty {
            return
        }
        let cell = tableView.cellForRow(at: indexPath) as? TSDetailCommentTableViewCell
        if !(cell?.nothingImageView.isHidden)! {
            return
        }
        // 未登录处理
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        let comment = self.sourceList[indexPath.row]
        TSKeyboardToolbar.share.keyboarddisappear()
        if let commentUserId = comment.userInfo?.userIdentity, let userId = TSCurrentUserInfo.share.userInfo?.userIdentity, userId == commentUserId {
            // 自己的评论，则弹出删除选项
            self.index = indexPath.row
            let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
            alertVC.addAction(TSAlertAction(title: "选择_删除".localized, style: .default, handler: { (_) in
                self.showCommentDeleteConfirmAlert(commentIndex: self.index)
            }))
            // 注：该操作需要使用主线程，否则可能导致弹窗间隔，即弹窗一次下次又没有弹窗，需要点击别的地方才会触发上次的弹窗.
            DispatchQueue.main.async(execute: {
                self.present(alertVC, animated: false, completion: nil)
            })
            return
        }
        // 和父类不同处：回复他人时的
        //self.writeComment(replyComment: self.sourceList[indexPath.row], cell: cell)
        self.commentToolView.setPlaceHolderText(text: "回复: \((comment.userInfo?.name)!)")
        self.commentModel = comment
        self.commentToolView.showView()
    }
}

// MARK: - Delegate TSMusicCommentToolViewDelegate

extension TSMusicCommentController: TSMusicCommentToolViewDelegate {
    func sendMessage(text: String) {
        self.sendComment(text)
    }

    func commentViewResignFirstResponder() {
        self.hiddnKeyBoard()
    }
}
