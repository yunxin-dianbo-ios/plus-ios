//
//  PostCapabilityController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class PostCapabilityController: UITableViewController {

    /// 数据
    var datas: [(PostCapability, Bool)] = [(.all, false), (.onlyMaster, false), (.masterAndManager, false)]
    /// 圈子 id
    var groupId = 0
    /// 发帖权限
    var capability = PostCapability.all {
        didSet {
            for index in 0..<datas.count {
                let (title, _) = datas[index]
                datas[index] = (title, title == capability)
            }
            tableView.reloadData()
        }
    }
    /// 是否正在发起改变发帖权限的网络请求
    var isLoading = false

    // MARK: - Lifecycle

    init(groupId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.groupId = groupId
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loading()
        loadData()
    }

    func setUI() {
        tableView.backgroundColor = TSColor.inconspicuous.background
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PostcapabilityCell", bundle: nil), forCellReuseIdentifier: PostcapabilityCell.identifier)
        self.title = "标题信息_发帖权限设置".localized
    }

    func loadData() {
        GroupNetworkManager.getGroupInfo(groupId: groupId) { [weak self] (model, message, status) in
            guard let model = model else {
                self?.loadFaild(type: .network)
                return
            }
            self?.endLoading()
            self?.capability = model.getPostCapabilityType()
        }
    }
}

extension PostCapabilityController: LoadingViewDelegate {
    func reloadingButtonTaped() {
        loadData()
    }

    func loadingBackButtonTaped() {
        navigationController?.popViewController(animated: true)
    }
}

extension PostCapabilityController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostcapabilityCell.identifier, for: indexPath) as! PostcapabilityCell
        let (title, isSelected) = datas[indexPath.row]
        cell.set(title: title.rawValue, isSelected: isSelected)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 获取数据
        let (title, isSelected) = datas[indexPath.row]
        // 如果没有在“修改权限”的网络请求中，并且该权限和当前设置的不一样，则发起“修改权限”的网络请求
        guard !isLoading, !isSelected else {
            return
        }
        // 设置请求数据
        var permission: [String]
        switch title {
        case .all:
            permission = ["administrator", "member", "founder"]
        case .onlyMaster:
            permission = ["founder"]
        case .masterAndManager:
            permission = ["administrator", "founder"]
        }
        // 3.发起网络请求
        let alert = TSIndicatorWindowTop(state: .loading, title: "修改中...")
        alert.show()
        GroupNetworkManager.changPostCapability(groupId: groupId, permission: permission) { [weak self] (status, message) in
            alert.dismiss()
            let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message)
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            self?.capability = title
        }
    }
}
