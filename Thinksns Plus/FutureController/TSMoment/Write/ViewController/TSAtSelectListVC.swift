//
//  TSAtSelectedListVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/22.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSAtSelectListVC: TSFriendsListVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    // MARK: - 创建搜索一系列视图
   override func creatSubView() {
        searchView = UIView(frame: CGRect(x: 50, y: 0, width: ScreenWidth - 50, height: 44))
        searchView.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.addSubview(searchView)

        searchTextfield = UITextField(frame: CGRect(x: 15, y: 5, width: searchView.width - 15 * 2, height: 34))
        searchTextfield.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        searchTextfield.textColor = TSColor.normal.minor
        searchTextfield.placeholder = "搜索"
        searchTextfield.backgroundColor = TSColor.normal.placeholder
        searchTextfield.layer.cornerRadius = 5
        searchTextfield.delegate = self
        searchTextfield.returnKeyType = .search

        let searchIcon = UIImageView()
        searchIcon.image = #imageLiteral(resourceName: "IMG_search_icon_search")
        searchIcon.contentMode = .center
        searchIcon.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        searchTextfield.leftView = searchIcon
        searchTextfield.leftViewMode = .always
        searchView.addSubview(searchTextfield)

        let lineViw = UIView(frame: CGRect(x: 0, y: 43.5, width: ScreenWidth, height: 0.5))
        lineViw.backgroundColor = TSColor.inconspicuous.disabled
        searchView.addSubview(lineViw)

        // 占位图
        occupiedView.backgroundColor = UIColor.white
        occupiedView.contentMode = .center
    }

    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        /// 执行搜索API
        TSNewFriendsNetworkManager.searchUsers(keyword: textField.text!, offset: 0) { [weak self] (datas: [TSUserInfoModel]?, message: String?, _) in
            self!.processRefresh(datas: datas, message: nil)
        }
        searchTextfield.resignFirstResponder()
        return true
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "fiendlistcell"
        var cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as? TSMyFriendListCell
        if cell == nil {
            cell = TSMyFriendListCell(style: UITableViewCellStyle.default, reuseIdentifier: indentifier)
        }
        cell?.setUserInfoData(model: dataSource[indexPath.row])
        cell?.delegate = self
        cell?.chatButton.isHidden = true
        return cell!
    }

    override func pushSearchPeopleVC() {
        let vc = TSNewFriendsSearchVC.vc()
        vc.isJustSearchFriends = false
        self.navigationController?.pushViewController(vc, animated: true)
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
