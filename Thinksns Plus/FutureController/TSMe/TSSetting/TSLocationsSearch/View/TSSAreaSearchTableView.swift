//
//  TSSAreaSearchTableView.swift
//  date
//
//  Created by Fiction on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  搜索结果展示tableview

import UIKit

protocol TSSAreaSearchTableViewDelegate: NSObjectProtocol {
    /// 回调搜索点击tableview.row所拥有的string
    /// - TSSAreaSearchTableViewDelegate
    func stringOfRow(str: String)
}

class TSSAreaSearchTableView: TSTableView, UITableViewDelegate, UITableViewDataSource {

    let cellID = "AreaSearchTableView"
    var areaSearchDataSource: Array<String> = []
    weak var TSSAreaSearchTableViewDelegate: TSSAreaSearchTableViewDelegate? = nil

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func refresh() {
    }

    override func loadMore() {
    }

    func setUI() {
        self.delegate = self
        self.dataSource = self
        self.separatorStyle = .singleLine
        self.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        self.tableFooterView = UIView()
        self.mj_header.isHidden = true
        self.mj_footer.isHidden = true
    }

    // MARK: - tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areaSearchDataSource.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
        }
        cell?.textLabel?.textColor = TSColor.main.content
        cell?.textLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        var str: String? = areaSearchDataSource[indexPath.row]
        if !(str?.isEmpty)! {
             str!.remove(at: str!.startIndex)
        }
        cell?.textLabel?.text = str
        cell?.textLabel?.lineBreakMode = .byTruncatingHead
        cell?.selectionStyle = .none
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str: String? = areaSearchDataSource[indexPath.row]
        /// 删除分割的逗号
        var locationsStr: String = str!
        locationsStr.remove(at: locationsStr.startIndex)
        for _ in 1...5 {
            if let i = locationsStr.index(of: "，") {
                locationsStr.remove(at: i)
                locationsStr.insert(" ", at: i)
            }
        }
        self.TSSAreaSearchTableViewDelegate?.stringOfRow(str: locationsStr)
    }

    /// 设置tableview数据方法
    public func setAreaSearchDataSource(data: Array<String>) {
        self.areaSearchDataSource.removeAll()
        self.areaSearchDataSource = data
        self.reloadData()
        if data.isEmpty {
            self.show(placeholderView: .empty)
        }
    }
}
