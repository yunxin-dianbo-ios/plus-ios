//
//  FeedCommentListView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表的评论视图

import UIKit

protocol FeedCommentListViewDelegate: class {

    /// 长按了评论视图的评论行
    func feedCommentListView(_ view: FeedCommentListView, didLongPressComment data: FeedCommentListCellModel, at indexPath: IndexPath)

    /// 点击了评论视图的评论行
    func feedCommentListView(_ view: FeedCommentListView, didSelectedComment data: FeedCommentListCellModel, at indexPath: IndexPath)

    /// 点击了查看全部按钮
    func feedCommentListViewDidSelectedSeeAllButton(_ view: FeedCommentListView)

    /// 点击了评论内容中的用户名字
    func feedCommentListView(_ view: FeedCommentListView, didSelectedComment cell: FeedCommentListCell, onUser userId: Int)
}

class FeedCommentListView: UIView, UIGestureRecognizerDelegate {

    /// 代理
    weak var delegate: FeedCommentListViewDelegate?

    /// 数据
    var datas: [FeedCommentListCellModel] = []
    /// 最大显示条数
    var maxShowingCount = 5
    /// 评论真实条数
    var commentsCount = 0

    /// 评论列表
    var table = UITableView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 0)))
    /// 查看全部按钮
    var seeAllButton = UIButton(type: .custom)

    // MARK: - 生命周期
    init() {
        super.init(frame: .zero)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    func setUI() {
        table.separatorStyle = .none
        table.bounces = false
        table.isScrollEnabled = false
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 30
        table.register(FeedCommentListCell.self, forCellReuseIdentifier: FeedCommentListCell.identifier)
        addSubview(table)
        addSubview(seeAllButton)

        // 长按手势
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.addGestureRecognizer(longPressGesture)
    }

    func set(datas: [FeedCommentListCellModel]) {
        self.datas = datas
        table.reloadData()

        var topRecord: CGFloat = 0
        // 1.评论列表
        // 计算评论列表的高度
        var tableHeight: CGFloat = 0
        let dataCount = min(datas.count, maxShowingCount)
        for data in datas[0..<dataCount] {
            var model = data
            FeedCommentListCell().set(model: &model)
            tableHeight += model.cellHeight
        }
        // 设置评论列表的 frame
        table.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: tableHeight))
        if !datas.isEmpty {
            topRecord = table.frame.maxY
        }

        // 2.查看全部按钮
        let buttonOrigin = CGPoint(x: 58, y: table.frame.maxY)
        if commentsCount > maxShowingCount {
            seeAllButton.setTitle("查看全部评论", for: .normal)
            seeAllButton.setTitleColor(UIColor(hex: 0x333333), for: .normal)
            seeAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            seeAllButton.sizeToFit()
            seeAllButton.addTarget(self, action: #selector(seeAllButtonTaped), for: .touchUpInside)
            seeAllButton.frame = CGRect(origin: buttonOrigin, size: CGSize(width: seeAllButton.size.width, height: 36))
            seeAllButton.titleEdgeInsets = UIEdgeInsets(top: -8, left: 0, bottom: 0, right: 0)
        } else {
            seeAllButton.setTitle(nil, for: .normal)
            seeAllButton.frame = CGRect(origin: buttonOrigin, size: CGSize(width: 10, height: 12))
        }
        topRecord = seeAllButton.frame.maxY

        // 3.计算评论视图的 frame
        frame = CGRect(origin: frame.origin, size: CGSize(width: UIScreen.main.bounds.width, height: topRecord))
    }

    // MARK: - Action
    func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: table)
        guard let indexPath = table.indexPathForRow(at: p), longPressGesture.state == UIGestureRecognizerState.began else {
            return
        }
        delegate?.feedCommentListView(self, didLongPressComment: datas[indexPath.row], at: indexPath)
    }

    /// 点击了查看全部按钮
    func seeAllButtonTaped() {
        delegate?.feedCommentListViewDidSelectedSeeAllButton(self)
    }

}

extension FeedCommentListView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(datas.count, maxShowingCount)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return datas[indexPath.row].cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedCommentListCell.identifier, for: indexPath) as! FeedCommentListCell
        var model = datas[indexPath.row]
        cell.set(model: &model)
        cell.delegate = self
        datas[indexPath.row] = model
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = datas[indexPath.row]
        delegate?.feedCommentListView(self, didSelectedComment: data, at: indexPath)
    }
}

// MARK: - cell 代理事件
extension FeedCommentListView: FeedCommentListCellDelegate {
    func feedCommentListCellDidLongPress(_ cell: FeedCommentListCell) {
        guard let indexPath = table.indexPath(for: cell) else {
            return
        }
        delegate?.feedCommentListView(self, didLongPressComment: datas[indexPath.row], at: indexPath)
    }
    /// 点击了 cell 上的用户名
    func feedCommentListCell(_ cell: FeedCommentListCell, didSelectedUser userId: Int) {
        delegate?.feedCommentListView(self, didSelectedComment: cell, onUser: userId)
    }
    /// 点击了cell 上的内容
    func feedCommentListCellDidPress(_ cell: FeedCommentListCell) {
        guard let indexPath = table.indexPath(for: cell) else {
            return
        }
        delegate?.feedCommentListView(self, didSelectedComment: datas[indexPath.row], at: indexPath)
    }
}
