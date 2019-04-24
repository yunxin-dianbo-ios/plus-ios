//
//  TSGroupNewOwnerVC.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/26.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSGroupNewOwnerVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    var dismissBlock: (() -> Void)?
    /// 进入当前页面之前就已经选择的数据（主要是存储从群详情页和查看群成员页面跳转过来的时候一并传递过来的已有群成员数据）
    var originDataSource = NSMutableArray()
    /// 删除成员时候自己检索出来的成员数据数组
    var searchDataSource = NSMutableArray()
    /// 当前操作之前的群 ID
    var currenGroupId: String? = ""
    /// 从群信息页面传递过来的群信息原始数据
    var originData = NSDictionary()
    /// 如果是删除群成员的页面，这个群主 ID 必须传
    var ownerId: String = ""
    /// 模态弹出的VC 因为一时不知道怎么获取那就直接传吧
    var bePresentVC: UIViewController?

    /// 占位图
    let occupiedView = UIImageView()
    /// 搜索关键词
    var keyword = ""

    var friendListTableView: TSTableView!
    var searchbarView = TSSearchBarView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TSColor.inconspicuous.background
        title = "选择新群主"
        /// 剔除群主自己
        for (index, item) in originDataSource.enumerated().reversed() {
            let userinfo: TSUserInfoModel = item as! TSUserInfoModel
            if userinfo.userIdentity == Int(ownerId) {
                originDataSource.removeObject(at: index)
            }
        }
        searchDataSource.addObjects(from: originDataSource as! [Any])
        creatSubView()
        // Do any additional setup after loading the view.
    }

    // MARK: - 布局子视图
    func creatSubView() {
        searchbarView = TSSearchBarView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 64))
        self.view.addSubview(searchbarView)
        searchbarView.rightButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        searchbarView.searchTextFiled.placeholder = "搜索"
        searchbarView.searchTextFiled.returnKeyType = .search
        searchbarView.searchTextFiled.delegate = self
        let noticeLab = TSLabel(frame: CGRect(x: 14, y: self.searchbarView.bottom, width: ScreenWidth - 14, height: 36))
        self.view.addSubview(noticeLab)
        noticeLab.backgroundColor = TSColor.inconspicuous.background
        noticeLab.textColor = TSColor.normal.minor
        noticeLab.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        noticeLab.text = "选择新群主"
        friendListTableView = TSTableView(frame: CGRect(x: 0, y:noticeLab.bottom, width: ScreenWidth, height: ScreenHeight - 64 - 36), style: UITableViewStyle.plain)
        friendListTableView.delegate = self
        friendListTableView.dataSource = self
        friendListTableView.separatorStyle = .none
        friendListTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.view.addSubview(friendListTableView)
        friendListTableView.mj_footer = nil
        friendListTableView.mj_header.beginRefreshing()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchDataSource.count > 0 {
            occupiedView.removeFromSuperview()
        }
        return searchDataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "changegroupownercell"
        var cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as? TSGroupNewOwnerCell
        if cell == nil {
            cell = TSGroupNewOwnerCell(style: UITableViewCellStyle.default, reuseIdentifier: indentifier)
        }
        cell?.setUserInfoData(model: searchDataSource[indexPath.row] as! TSUserInfoModel)
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.5
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actionsheetView = TSCustomActionsheetView(titles: ["提示信息_群主转让确认".localized, "提示信息_确定".localized])
        actionsheetView.setColor(color: TSColor.main.warn, index: 1)
        actionsheetView.notClickIndexs = [0]
        actionsheetView.show()
        actionsheetView.finishBlock = { (actionsheet: TSCustomActionsheetView, title: String, btnTag: Int) in
            if btnTag == 1 {
                let userinfo: TSUserInfoModel = self.searchDataSource[indexPath.row] as! TSUserInfoModel
                self.changeHyGroupNewOwner(userinfo: userinfo)
            }
        }
    }

    func refresh() {
        keyword = searchbarView.searchTextFiled.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        view.endEditing(true)
        if keyword == "" {
            self.friendListTableView.mj_header.endRefreshing()
            searchDataSource.removeAllObjects()
            searchDataSource.addObjects(from: originDataSource as! [Any])
            friendListTableView.reloadData()
        } else {
            self.friendListTableView.mj_header.endRefreshing()
            searchDataSource.removeAllObjects()
            for (index, item) in originDataSource.enumerated() {
                let usermodel: TSUserInfoModel = item as! TSUserInfoModel
                if usermodel.name.range(of: keyword) != nil {
                    searchDataSource.add(usermodel)
                }
            }
            friendListTableView.reloadData()
        }
    }

    /// 显示占位图
    func showOccupiedView(type: TSTableViewController.OccupiedType) {
        var image = ""
        switch type {
        case .empty:
            image = "IMG_img_default_search"
        case .network:
            image = "IMG_img_default_internet"
        }
        occupiedView.image = UIImage(named: image)
        if occupiedView.superview == nil {
            occupiedView.frame = friendListTableView.bounds
            friendListTableView.addSubview(occupiedView)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyword = searchbarView.searchTextFiled.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        view.endEditing(true)
        if keyword == "" {
            searchDataSource.removeAllObjects()
            searchDataSource.addObjects(from: originDataSource as! [Any])
            friendListTableView.reloadData()
        } else {
            searchDataSource.removeAllObjects()
            for (index, item) in originDataSource.enumerated() {
                let usermodel: TSUserInfoModel = item as! TSUserInfoModel
                if usermodel.name.range(of: keyword) != nil {
                    searchDataSource.add(usermodel)
                }
            }
            friendListTableView.reloadData()
        }
        self.view.endEditing(true)
        return true
    }
    // MARK: - 执行转让操作
    func changeHyGroupNewOwner(userinfo: TSUserInfoModel) {
        let groupid = "\(self.originData["id"] ?? "")"
        let desc = "\(self.originData["description"] ?? "")"
        let ispublic = "\(self.originData["public"] ?? "")"
        let maxusers = "\(self.originData["maxusers"] ?? "")"
        let menbers_only = "\(self.originData["membersonly"] ?? "")"
        let allowinvites = "\(self.originData["allowinvites"] ?? "")"
        let groupName = "\(self.originData["name"] ?? "")"
        let newowner = String(userinfo.userIdentity)
        /// 转让群
        TSAccountNetworkManager().changeHyGroupNewOwner(groupid: groupid, groupname: groupName, desc: desc, ispublic: ispublic, maxusers: maxusers, menbers_only: menbers_only, allowinvites: allowinvites, newowner: newowner) { (data, status) in
            guard status else {
                return
            }
            // 刷新群设置页的数据
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadgroupdata"), object: nil)
            self.dismissVC()
            self.dismissBlock?()
        }
    }

    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
