//
//  TSWalletRuleVCViewController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSWalletRuleVCViewController: UITableViewController {

    var content = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    // MARK: - Custom user interface
    func setUI() {
        view.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = UIScreen.main.bounds.height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }

    // 设置内容
    func set(content string: String) {
        content = string
        tableView.reloadData()
    }

    // MARK: - Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        cell.textLabel?.text = content
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = TSColor.main.content
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }
}
