//
//  TSSimpleCommentTableView.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  简易的评论列表

import UIKit

protocol TSSimpleCommentTableViewDelegate: NSObjectProtocol {

    /// 点击选择的评论内容
    ///
    /// - Parameter CommentModel: 当前行的数据模型
    func didSelectCommentRow(CommentModel: TSSimpleCommentModel, sendType: SendCommentType)

    /// 点击了名字
    ///
    /// - Parameter userId: 用户Id
    func didSelectName(userId: Int)

    /// 点击了查看更多
    func tapMore()
}

enum SendCommentType {
    /// 删除状态
    case delete
    /// 发送状态
    case send
    /// 回复状态
    case replySend
    /// 重新发送状态
    case reSend
    /// 获取评论列表
    case getList
    /// 置顶评论
    case top
}

class TSSimpleCommentTableView: UITableView, UITableViewDelegate, UITableViewDataSource, TSCustomAcionSheetDelegate, TSSimpleCommentTableViewCellDelegate {

    /// 能否显示申请评论置顶，用于外界传入，不可内部更改
    let showCommentApplyTopFlag: Bool
    /// 是否要隐藏置顶(内部判断，可内部更改)
    fileprivate var shouldHiddenTop = false

    /// 限制行数
    private let limitCount = 5
    /// footView高度
    private let footViewHeight: CGFloat = 30.0
    /// 评论人数
    public var commentCount = 0
    /// 代理
    weak var commentTableViewDelegate: TSSimpleCommentTableViewDelegate?
    /// 评论数据
    var commentListDatas: [TSSimpleCommentModel] = Array() {
        didSet {
            self.bounds.size = CGSize(width: self.bounds.size.width, height: setCommentHeight(comments: commentListDatas, width: self.tableToCellWidth))
            self.tableFooterView = commentCount >= limitCount ? setFootView() : nil
            self.reloadData()
        }
    }

    /// 删除的行数
    var cellIndex: Int?

    /// tableView传给cell的宽度
    var tableToCellWidth: CGFloat = 0

    // MARK: - 设置tableView的高度
    /// 设置tableView的高度
    ///
    /// - Parameters:
    ///   - comments: 数据
    ///   - width: 当前宽度
    /// - Returns: 高度
    private func setCommentHeight(comments: [TSSimpleCommentModel], width: CGFloat) -> CGFloat {
        var cellHeight: CGFloat = 0
        for (index, item) in comments.enumerated() {
            if (index + 1) > limitCount {
                break
            }
            let label: TSCommentLabel = TSCommentLabel(commentModel: item, type: .simple)
            label.linesSpacing = 4
            cellHeight += label.getSizeWithWidth(width).height
            cellHeight += 7
        }
        var footViewHeight: CGFloat = self.footViewHeight
        if commentCount <= limitCount {
            footViewHeight = 0
        }
        return cellHeight + footViewHeight
    }

    // MARK: - Lifecycle
    ///
    /// - Parameters:
    ///   - frame: 尺寸
    ///   - style: 样式
    ///   - commentDatas: 数据
    init(width: CGFloat, commentDatas: [TSSimpleCommentModel]?, showCommentApplyTop: Bool = true) {
        self.showCommentApplyTopFlag = showCommentApplyTop
        super.init(frame: CGRect.zero, style: .plain)
        self.tableToCellWidth = width - 22
        if let commentDatas = commentDatas {
            commentListDatas = commentDatas
        }
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 设置UI
    /// 设置UI
    func setUI() {
        self.bounds = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: setCommentHeight(comments: commentListDatas, width: self.tableToCellWidth))
        self.tableFooterView = commentListDatas.count >= limitCount ? setFootView() : nil
        self.delegate = self
        self.dataSource = self
        self.isScrollEnabled = false
        self.estimatedRowHeight = 20
        self.separatorStyle = .none
        self.rowHeight = UITableViewAutomaticDimension
        self.register(UINib(nibName: "TSSimpleCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }

    // MARK: - tableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if commentListDatas.count >= limitCount {
            return limitCount
        }
        return self.commentListDatas.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // 如果是游客模式，触发登录注册操作
        if TSCurrentUserInfo.share.isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }

        let userInfo = commentListDatas[indexPath.row].userInfo
        let userId = userInfo?.userIdentity

        if userId == (TSCurrentUserInfo.share.userInfo?.userIdentity)! {
            let commentData = commentListDatas[indexPath.row]
            // 状态 0：已成功的 1：未成功的 2 : 正在发送中
            switch commentData.status {
            case 0:
                shouldHiddenTop = false
            case 1:
                shouldHiddenTop = true
            case 2:
                return
            default:
                return
            }
            // 如果外界传入不显示申请置顶，则隐藏申请置顶选项
            if !self.showCommentApplyTopFlag {
                shouldHiddenTop = true
            }
            cellIndex = indexPath.row
            let actionTitles = shouldHiddenTop ? ["选择_删除".localized] : ["申请评论置顶", "选择_删除".localized]
            let customAction = TSCustomActionsheetView(titles: actionTitles)
            customAction.delegate = self
            customAction.show()
            TSKeyboardToolbar.share.keyboarddisappear()
            return
        }
        self.commentTableViewDelegate?.didSelectCommentRow(CommentModel: commentListDatas[indexPath.row], sendType: .send)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TSSimpleCommentTableViewCell
        cell?.selectionStyle = .none
        cell?.superWidth = self.tableToCellWidth
        cell?.commnetObject = commentListDatas[indexPath.row]
        cell?.cellDelegate = self
        return cell!
    }

    // MARK: - 删除和添加动作
    /// 删除评论
    ///
    /// - Parameters:
    ///   - view: actionsheetView
    ///   - title: 点击的内容
    ///   - index: 点击的行数
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        switch title {
        case "申请评论置顶":
            self.commentTableViewDelegate?.didSelectCommentRow(CommentModel:  commentListDatas[cellIndex!], sendType: .top)
        case "选择_删除".localized:
            self.commentTableViewDelegate?.didSelectCommentRow(CommentModel:  commentListDatas[cellIndex!], sendType: .delete)
        default:
            break
        }
    }

    /// 添加数据
    ///
    /// - Parameters:
    ///   - commnetObject: 评论的数据
    ///   - isRemove: 是否是删除
    public func addComment(commnetObject: TSSimpleCommentModel) {
        commentListDatas.insert(commnetObject, at: 0)
        self.reloadData()
    }

    // MARK: - setFootView
    /// 设置尾部视图
    ///
    /// - Returns: 返回的视图
    private func setFootView() -> UIView {
        let footView = UIView()
        footView.frame = CGRect(x: 22, y: 0, width: self.bounds.size.width - 22, height: footViewHeight)
        let button = TSButton(type: .custom)
        let title = "显示_查看全部评论".localized
        let size = title.heightWithConstrainedWidth(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT), font: UIFont.systemFont(ofSize: TSFont.ContentText.sectionTitle.rawValue))
        button.frame = CGRect(x: 0, y: footViewHeight / 2 - (footViewHeight / 4), width: size.width, height: footViewHeight / 2)
        button.setTitle(title, for: .normal)
        button.setTitleColor(TSColor.main.content, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.sectionTitle.rawValue)
        button.addTarget(self, action: #selector(tapMore), for: .touchUpInside)
        footView.addSubview(button)
        return footView
    }

    // MARK: - 重新发送
    /// 点击重新发送按钮
    ///
    /// - Parameter commnetModel: 数据模型
    internal func repeatTap(cell: TSSimpleCommentTableViewCell, commnetModel: TSSimpleCommentModel) {
        let indexPath = self.indexPath(for: cell)
        self.commentTableViewDelegate?.didSelectCommentRow(CommentModel:  commentListDatas[(indexPath?.row)!], sendType: .reSend)
    }

    // MARK: - 查看更多
    func tapMore() {
        self.commentTableViewDelegate?.tapMore()
    }

    /// 点击了名字
    func didSelectName(userId: Int) {
        self.commentTableViewDelegate?.didSelectName(userId: userId)
    }
}
