//
//  TSFeedBackTableview.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSFeedBackTableview: UIView, UITableViewDataSource, UITableViewDelegate {
    // 假数据
    var questiondatasource: Array<Array<String>>? = nil
    // tableview
    var questionTableView: UITableView! = nil
    // cellid
    let cellid = "QuestionID"

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        setData()
        setUI()
    }
    func setData() {
        let arry1: Array<String> = ["显示_不想看到未关注的动态，怎么关闭？".localized]
        let arry2: Array<String> = [String(format: "显示_在3G / 4G下不能使用App".localized, TSAppSettingInfoModel().appDisplayName)]
        let arry3: Array<String> = ["显示_怎样跟换个人主页相册封面？".localized]
        questiondatasource = [arry1, arry2, arry3]
    }
    func setUI() {
        setTitleAndTabel()
    }
    func setTitleAndTabel() {
        let title = UILabel()
        title.text = "显示_常见问题".localized
        title.textColor = TSColor.normal.minor
        title.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        self.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(14)
            make.left.equalTo(self).offset(14.5)
            make.height.equalTo(12.5)
            make.width.equalTo(51.5)
        }

        questionTableView = UITableView(frame: CGRect.zero, style: .grouped)
        questionTableView.separatorStyle = .none
        questionTableView.delegate = self
        questionTableView.dataSource = self
        questionTableView.scrollsToTop = false
        questionTableView.isScrollEnabled = false
        questionTableView.tableFooterView = UIView()
        self.addSubview(questionTableView)
        questionTableView.snp.updateConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(title.snp.bottom).offset(10)
            make.bottom.equalTo(self)
        }
    }
    // MARK: - tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowdata = questiondatasource?[section]
        return rowdata?.count ?? 0
    }// 多少行
    func numberOfSections(in tableView: UITableView) -> Int {
        return questiondatasource?.count ?? 1
    }// 多少组
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }// 每行高度
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }// 每组脚高
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }// 每组头高
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellid)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellid)
        }
        let rowdata = questiondatasource?[indexPath.section]
        cell?.textLabel?.text = rowdata?[indexPath.row]
        cell?.textLabel?.textColor = TSColor.main.content
        cell?.textLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
