//
//  TSBindingOrUnbindTableView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  展示是否绑定

import UIKit

protocol TSBindingOrUnbindTableViewDelegate: NSObjectProtocol {
    /// 返回点击cell的结构体数据
    func itemForDataSoruce(item: TSBindingItme)
}

/// 展示绑定信息的tableview
class TSBindingOrUnbindTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    let cellID = "BindingOrUnbindTableView"
    var bindingOrUnbindDataSource: Array<TSBindingItme> = []
    weak var bindingOrUnbindTableViewDelegate: TSBindingOrUnbindTableViewDelegate?
    var isFirstShow: Bool = true

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        self.backgroundColor = UIColor.clear
        self.isScrollEnabled = false
        self.delegate = self
        self.dataSource = self
        self.separatorStyle = .none
        self.tableFooterView = UIView()
    }

    // MARK: - tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bindingOrUnbindDataSource.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? TSBindingOrUnbindTableViewCell
        if cell == nil {
            cell = TSBindingOrUnbindTableViewCell(style: .default, reuseIdentifier: cellID)
        }
        let temp = bindingOrUnbindDataSource[indexPath.row]
        cell?.itemNameLabel.text = temp.nameType.rawValue
        cell?.isBinding(temp.status)
        cell?.selectionStyle = .none
        cell?.bindingOrUnbindLabel.isHidden = isFirstShow
        cell?.accessoryImageView.isHidden = isFirstShow
        if indexPath.row == (bindingOrUnbindDataSource.count - 1) {
            cell?.separatorLine.isHidden = true
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let temp = bindingOrUnbindDataSource[indexPath.row]
        self.bindingOrUnbindTableViewDelegate?.itemForDataSoruce(item: temp)
    }

    /// 设置tableview数据方法
    public func setBindingOrUnbindDataSource(data: Array<TSBindingItme>) {
        self.bindingOrUnbindDataSource.removeAll()
        self.bindingOrUnbindDataSource = data
        self.reloadData()
    }
}
