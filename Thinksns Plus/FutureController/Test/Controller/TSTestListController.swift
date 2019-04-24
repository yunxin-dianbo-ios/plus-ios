//
//  TSTestListController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  测试列表界面

import UIKit

/// 测试列表界面
class TSTestListController: UIViewController {

    // MARK: - Internal Property
    // MARK: - Private Property
    fileprivate weak var tableView: UITableView!

    fileprivate var sourceList: [String] = []

    // MARK: - Initialize Function
    // MARK: - Internal Function
    // MARK: - Override Function

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialUI()
        self.initialDataSource()
    }

}

// MARK: - UI

extension TSTestListController {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        self.view.backgroundColor = UIColor.white
        // 1. navigationbar
        self.navigationItem.title = "TestList"
        // 2. tableView
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 250
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.tableView = tableView
    }
}

// MARK: - 数据处理与加载

extension TSTestListController {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        self.sourceList = ["0", "1", "2", "3", "4", "5", "6", "7"]
    }
}

// MARK: - 事件响应

extension TSTestListController {

}

// MARK: - Notification

extension TSTestListController {

}

// MARK: - Delegate Function

// MARK: - UITableViewDataSource

extension TSTestListController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }

        //cell?.preservesSuperviewLayoutMargins = false
        //cell?.layoutMargins = UIEdgeInsets.zero
        cell?.textLabel?.text = "Just Test"
        //cell?.selectionStyle = .none

        return cell!
    }

}

// MARK: - UITableViewDelegate

extension TSTestListController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt\(indexPath.row)")

        switch indexPath.row {
        case 0:
            let testVC = TSTestViewController()
            self.navigationController?.pushViewController(testVC, animated: true)
        case 1:
            let newsEditVC = TSNewsWebEditorController()
            self.navigationController?.pushViewController(newsEditVC, animated: true)
        case 2:
            let postVC = TSPostWebEditorController(groupId: nil, groupName: nil)
            self.navigationController?.pushViewController(postVC, animated: true)
        case 3:
            let answerCollectionVC = TSAnswerCollectionController()
            self.navigationController?.pushViewController(answerCollectionVC, animated: true)
        default:
            break
        }
    }

}
