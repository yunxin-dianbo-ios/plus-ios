//
//  TSAccountCellShowsSearchResults.swift
//  date
//
//  Created by Fiction on 2017/7/26.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 搜索结果tableview

import UIKit

protocol didSelectShowsSearchResultsCellDelegate: NSObjectProtocol {
    /// 点击搜索显示的cell返回一个字符串
    func didSelectShowsSearchResultsCell(rowStr: String)
}

struct AccountCellType {
    let cellHight: CGFloat = 40
    let lastCellHigt: CGFloat = 20
}

class TSAccountCellShowsSearchResults: UITableView, UITableViewDelegate, UITableViewDataSource {
    var searchDataSource: NSArray? = nil
    weak var didSelectShowsSearchResultsCellDelegate: didSelectShowsSearchResultsCellDelegate? = nil

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        self.delegate = self
        self.dataSource = self
        self.separatorStyle = .none
        self.bounces = false
    }

    // MARK: - tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchDataSource?.count ?? 0
    }// 多少行
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AccountCellType().cellHight
    }// 每行高度
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TSShowsSearchResultsCell
        if cell == nil {
            cell = TSShowsSearchResultsCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.label.text = searchDataSource?[indexPath.row] as! String?
        cell?.selectionStyle = .none
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str = searchDataSource?[indexPath.row] as! String
        self.didSelectShowsSearchResultsCellDelegate?.didSelectShowsSearchResultsCell(rowStr: str)
    }

    // MARK: - 改变数据源方法
    func changeData(_ arry: NSArray) {
        searchDataSource = arry
        self.reloadData()
    }
}
