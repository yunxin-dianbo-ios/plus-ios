//
//  TSMyAnswerListCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  我的回答列表的cell

import UIKit

protocol TSMyAnswerListCellProtocol: class {
    /// 点赞
    func didClickFavorItemInCell(_ cell: TSMyAnswerListCell) -> Void
    /// 评论
    func didClickCommentItemInCell(_ cell: TSMyAnswerListCell) -> Void
}

class TSMyAnswerListCell: UITableViewCell {
    // MARK: - Internal Property

    /// 重用标识符
    static let identifier: String = "TSMyAnswerListCellReuseIdentifier"

    weak var delegate: TSMyAnswerListCellProtocol?
    /// 数据模型，加载数据模型请使用loadAnswer方法
    private(set) var model: TSAnswerListModel?
    /// 工具栏是否可用，主要用于点赞时避免连续请求，且应在重用里恢复设置
    var toolBarEnable: Bool = true {
        didSet {
            self.toolBar.isUserInteractionEnabled = toolBarEnable
        }
    }
    /// 更新toolBar：点赞数/点赞状态/评论数
    func updateToolBar() -> Void {
        guard let model = self.model else {
            return
        }
        // favor
        self.toolBar.setTitle("\(model.likesCount)", At: 0)
        self.toolBar.setImage(model.liked ? "IMG_home_ico_good_high" : "IMG_home_ico_good_normal", At: 0)
        // comment
        self.toolBar.setTitle("\(model.commentsCount)", At: 1)
    }
    /// 点赞/取消点赞操作 - 用于点赞时的临时展示
    var favorOrUnFavor: Bool = false {
        didSet {
            self.toolBar.setImage(favorOrUnFavor ? "IMG_home_ico_good_high" : "IMG_home_ico_good_normal", At: 0)
            var favorCount = 0
            if let likesCount = self.model?.likesCount {
                favorCount = likesCount + (favorOrUnFavor ? 1 : -1)
                favorCount = favorCount > 0 ? favorCount : 0
            }
            self.toolBar.setTitle("\(favorCount)", At: 0)
        }
    }

    // MARK: - Private Property
    private let bottomSeparateH: CGFloat = 5        // 底部分割间距
    private let bottomH: CGFloat = 45               // 底部工具栏高度
    private let leftMargin: CGFloat = 10            // 左侧间距
    private let rightMargin: CGFloat = 10           // 右侧间距
    private let contentTopMargin: CGFloat = 15      // 正文顶部间距
    private let contentBottomMargin: CGFloat = 15   // 正文底部间距 - 正文与底部工具栏之间的间距

    /// 答案视图
    private weak var answerLabel: UILabel!
    /// 底部工具栏
    private weak var toolBar: TSToolbarView!
    /// 发布时间
    private weak var timeLabel: UILabel!
    /// 点赞按钮
    private weak var favorBtn: UIButton!
    /// 评论按钮
    private weak var commentBtn: UIButton!

    // MARK: - Internal Function

    class func cellInTableView(_ tableView: UITableView) -> TSMyAnswerListCell {
        let identifier = TSMyAnswerListCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = TSMyAnswerListCell(style: .default, reuseIdentifier: identifier)
        }
        // 重置位置
        (cell as! TSMyAnswerListCell).resetShow()
        return cell as! TSMyAnswerListCell
    }
    /// 视图重置
    func resetShow() -> Void {
        self.model = nil
        self.timeLabel.text = ""
        self.answerLabel.text = ""
        self.toolBarEnable = true
        self.toolBar.setTitle("\(0)", At: 0)
        self.toolBar.setImage("IMG_home_ico_good_normal", At: 0)
        self.toolBar.setTitle("\(0)", At: 1)
    }
    /// 加载数据
    ///
    /// - Parameters:
    ///   - answer: 待加载的答案，内部会持有该答案
    func loadAnswer(_ answer: TSAnswerListModel) -> Void {
        self.model = answer
        self.setupWithModel(answer)
        self.toolBarEnable = true
    }

    // MARK: - Initialize Function

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Override Function

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        self.contentView.backgroundColor = TSColor.inconspicuous.background
        // mainView - 整体布局，便于扩展，特别是针对分割、背景色、四周间距
        let mainView = UIView()
        self.contentView.addSubview(mainView)
        self.initialMainView(mainView)
        mainView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView).offset(-bottomSeparateH)
        }
    }
    // 主视图布局
    private func initialMainView(_ mainView: UIView) -> Void {
        mainView.backgroundColor = UIColor.white
        // 1. topView - answerContentView
        let topView = UIView()
        mainView.addSubview(topView)
        self.initialTopView(topView)
        topView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(mainView)
        }
        // 2. bottomView
        let bottomView = UIView()
        mainView.addSubview(bottomView)
        self.initialBottomView(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(mainView)
            make.height.equalTo(bottomH)
            make.top.equalTo(topView.snp.bottom)
        }
        // 3. separateLine
        bottomView.addLineWithSide(.inTop, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: 0, margin2: 0)
    }
    /// 顶部布局
    private func initialTopView(_ topView: UIView) -> Void {
        // 答案视图部分
        let answerLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: TSColor.normal.content)
        topView.addSubview(answerLabel)
        answerLabel.numberOfLines = 3
        answerLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(topView).offset(self.leftMargin)
            make.trailing.equalTo(topView).offset(-self.rightMargin)
            make.top.equalTo(topView).offset(self.contentTopMargin)
            make.bottom.equalTo(topView).offset(-self.contentBottomMargin)
        }
        self.answerLabel = answerLabel
    }
    /// 底部布局
    private func initialBottomView(_ bottomView: UIView) -> Void {
        // 1. favorBtn/commentBtn
        let favorItem = TSToolbarItemModel(image: "IMG_home_ico_good_normal", title: "0", index: 0)
        let commentItem = TSToolbarItemModel(image: "IMG_home_ico_comment_normal", title: "0", index: 1)
        let toolBar = TSToolbarView(frame: CGRect(x: leftMargin, y: 0, width: UIScreen.main.bounds.width - leftMargin, height: bottomH), type: .left, items: [favorItem, commentItem])
        bottomView.addSubview(toolBar)
        toolBar.delegate = self
        self.toolBar = toolBar
        // 2. timeLabel
        let timeLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.disabled)
        bottomView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(bottomView)
            make.trailing.equalTo(bottomView).offset(-rightMargin)
        }
        self.timeLabel = timeLabel
    }

    // MARK: - Private  数据加载

    /// 数据加载
    private func setupWithModel(_ model: TSAnswerListModel) -> Void {
        var strDate: String = ""
        if let date = model.createDate {
            strDate = TSDate().dateString(.normal, nsDate: date as NSDate)
        }
        self.timeLabel.text = strDate
        // body_text为新的答案的文本描述字段，之前的为nil，则使用之前的方式处理
        self.answerLabel.text = model.body_text ?? model.body.ts_customMarkdownToNormal()
        // favor
        self.toolBar.setTitle("\(model.likesCount)", At: 0)
        self.toolBar.setImage(model.liked ? "IMG_home_ico_good_high" : "IMG_home_ico_good_normal", At: 0)
        // comment
        self.toolBar.setTitle("\(model.commentsCount)", At: 1)
    }

    // MARK: - Private  事件响应

}

// MARK: - TSToolbarViewDelegate

extension TSMyAnswerListCell: TSToolbarViewDelegate {
    /// item 被点击
    func toolbar(_ toolbar: TSToolbarView, DidSelectedItemAt index: Int) -> Void {
        if nil == self.model {
            return
        }
        switch index {
        // 点赞
        case 0:
            self.delegate?.didClickFavorItemInCell(self)
        // 评论
        case 1:
            self.delegate?.didClickCommentItemInCell(self)
        default:
            break
        }
    }
}
