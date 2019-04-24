//
//  PostDetailController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 08/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  帖子详情页
//  该页面主要用来测试帖子详情视图，实际请使用TSPostCommentController。

import UIKit

typealias PostDetailController = TSPostCommentController
//class PostDetailController: TSViewController
//{
//
//    // MARK: - Internal Property
//
//    /// 圈子Id
//    let groupId: Int
//    /// 帖子Id
//    let postId: Int
//
//    // MARK: - Private Property
//    fileprivate weak var tableView: UITableView!
//    fileprivate weak var headerView: PostDetailView!
//
//    var detailModel: PostDetailModel?
//
//    // MARK: - Internal Function
//
//    // MARK: - Initialize Function
//
//    init(groupId: Int, postId: Int) {
//        self.groupId = groupId
//        self.postId = postId
//        super.init(nibName: nil, bundle: nil)
//    }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Override Function
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.initialUI()
//        self.initialDataSource()
//    }
//
//    // MARK: - Private  UI
//
//    fileprivate func initialUI() -> Void {
//        self.navigationItem.title = "帖子详情"
//
//        let tableView = UITableView(frame: CGRect.zero, style: .plain)
//        self.view.addSubview(tableView)
//        tableView.dataSource = self
//        tableView.delegate = self
//        //tableView.separatorStyle = .none
//        tableView.tableFooterView = UIView()
//        tableView.frame = self.view.bounds
//        self.tableView = tableView
//        let detailView = PostDetailView()
//        tableView.tableHeaderView = detailView
//        self.headerView = detailView
//    }
//
//    // MARK: - Private  数据处理与加载
//
//    fileprivate func initialDataSource() -> Void {
//        // 获取帖子详情
//        self.loading()
//        GroupNetworkManager.postDetail(postId: self.postId, groupId: self.groupId) { [weak self](postDetail, msg, status) in
//            guard status, let postDetail = postDetail else {
//                self?.loadFaild(type: .network)
//                return
//            }
//            self?.detailModel = postDetail
//            self?.headerView.loadModel(postDetail, complete: { (height) in
//                self?.endLoading()
//                self?.headerView.bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: height)
//                self?.tableView.reloadData()
//            })
//        }
//    }
//
//    // MARK: - Private  事件响应
//
//    // MARK: - Delegate Function
//
//    // MARK: - Notification
//}
//
//// MARK: - UITableViewDataSource
//
//extension PostDetailController: UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 25
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let identifier = "CellIdentifier"
//        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
//        if nil == cell {
//            cell = UITableViewCell.init(style: .default, reuseIdentifier: identifier)
//        }
//
//        cell?.textLabel?.text = "Just Test"
//        //cell?.selectionStyle = .none
//
//        return cell!
//    }
//}
//
//// MARK: - UITableViewDelegate
//
//extension PostDetailController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 44
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("didSelectRowAt\(indexPath.row)")
//    }
//
//}
//
