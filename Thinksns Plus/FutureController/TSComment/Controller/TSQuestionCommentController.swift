//
//  TSQuestionCommentController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 10/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题评论列表控制器，测试完成后将代码覆盖到 TSQuestionCommentListController
//  评论总数的问题，需要重新解决
//  没有评论时，该页面的展示效果不同于别的页面。

import UIKit

class TSQuestionCommentController: TSCommentListController {
    /// 评论框
    fileprivate var commentToolView: TSMusicCommentToolView!

    fileprivate let kbBgView: UIView = UIView(frame: UIScreen.main.bounds)
    fileprivate let commentToolH: CGFloat = 44

    // MARK: - Initialize Function

    init(questionId: Int, commentCount: Int) {
        super.init(type: .question, sourceId: questionId, emptyType: .tableView)
        self.commentCount = commentCount
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function
    override func viewDidAppear(_ animated: Bool) {
        if TSKeyboardToolbar.share.isAtActionPush == false {
            self.configKeyBoard()
        } else {
            TSKeyboardToolbar.share.isAtActionPush = false
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        if TSKeyboardToolbar.share.isAtActionPush == false {
            Typist.shared.stop()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.hiddnKeyBoard()
    }
}

// MARK: - UI加载

extension TSQuestionCommentController {
    override func initialUI() {
        super.initialUI()
        // 1. navigationbar
        self.navigationItem.title = "评论(\(self.commentCount))"
        // 2. 文字输入工具栏
        self.initialCommentToolView()
        // 3. tableView
        self.tableView.snp.remakeConstraints { (make) in
            make.top.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-(commentToolH + TSBottomSafeAreaHeight))
        }
    }

    func initialCommentToolView() -> Void {
        // 文字输入工具栏
        let commentToolView = TSMusicCommentToolView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: commentToolH))
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: commentToolView.width, height: commentToolView.height + TSBottomSafeAreaHeight))
        bgView.backgroundColor = UIColor.white
        commentToolView.addSubview(bgView)
        commentToolView.sendSubview(toBack: bgView)
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
            // 键盘弹起时约束变化
            make.bottom.equalTo(self.view).offset(-TSBottomSafeAreaHeight)
        }
        self.commentToolView = commentToolView
        self.configKeyBoard()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddnKeyBoard))
        self.kbBgView.addGestureRecognizer(tap)
    }
}

// MARK: - 键盘弹窗相关

extension TSQuestionCommentController {
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

// MARK: - Delegate TSMusicCommentToolViewDelegate

extension TSQuestionCommentController: TSMusicCommentToolViewDelegate {
    func sendMessage(text: String) {
        self.sendComment(text)
    }

    func commentViewResignFirstResponder() {
        self.hiddnKeyBoard()
    }
}

// MARK: - Delegate UITableViewDelegate

extension TSQuestionCommentController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    override func sendComment(_ content: String) {
        super.sendComment(content)
        self.hiddnKeyBoard()
    }
}
