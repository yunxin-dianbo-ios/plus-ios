//
//  TSDiscoverViewController.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/9.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

struct TSDiscoverTableUX {
    /// cell高度
    static let tableCellHeight: CGFloat = 50
    /// section高度
    static let sectionHeaderHeight: CGFloat = 15
}

class TSDiscoverViewController: TSViewController, UITableViewDelegate, UITableViewDataSource {

    /// 列表
    let tableView = UITableView()

    var cellTitleConfig = [TSAppConfig.share.localInfo.quoraSwitch ? ["资讯", "圈子", "问答"] : ["资讯", "圈子"], [ "排行榜", "话题"], ["音乐FM", "找人"]]
    var cellImageConfig = [TSAppConfig.share.localInfo.quoraSwitch ? ["IMG_discover_ico_information", "IMG_discover_ico_channel", "IMG_discover_ico_queansw"] : ["IMG_discover_ico_information", "IMG_discover_ico_channel"], ["IMG_discover_ico_rankinglist", "discover_ico_topic", "IMG_discover_ico_buy", "discover_ico_topic"], ["IMG_discover_ico_music", "IMG_discover_ico_findpeople"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TSColor.inconspicuous.background
        
         cellTitleConfig = [TSAppConfig.share.localInfo.quoraSwitch ? ["资讯", "圈子", "问答"] : ["资讯", "圈子"], [ "排行榜", "话题"], ["音乐FM", "找人"]]
         cellImageConfig = [TSAppConfig.share.localInfo.quoraSwitch ? ["IMG_discover_ico_information", "IMG_discover_ico_channel", "IMG_discover_ico_queansw"] : ["IMG_discover_ico_information", "IMG_discover_ico_channel"], ["IMG_discover_ico_rankinglist", "discover_ico_topic", "IMG_discover_ico_buy", "discover_ico_topic"], ["IMG_discover_ico_music", "IMG_discover_ico_findpeople"]]

        self.makeTabelView()
    }

    // MARK: - UI
    func makeTabelView() {

        let tabbarHeight = self.tabBarController?.tabBar.frame.height
        let navigationBarAndStatusBarHeight = (self.navigationController?.navigationBar.frame.height)! + 20

        self.tableView.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: ScreenSize.ScreenHeight - tabbarHeight! - navigationBarAndStatusBarHeight)
        self.tableView.backgroundColor = .clear
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.view.addSubview(self.tableView)
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellTitleConfig.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionConfig = cellTitleConfig[section]
        return sectionConfig.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section != 0 else {
            return 0.0
        }
        return TSDiscoverTableUX.sectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TSDiscoverTableUX.tableCellHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: TSDiscoverTableUX.sectionHeaderHeight))
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "discoverCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? TSDiscoverCell
        if cell == nil {
            cell = TSDiscoverCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }

        let title = cellTitleConfig[indexPath.section][indexPath.row]
        let imageName = cellImageConfig[indexPath.section][indexPath.row]

        cell?.setCellInfo(title: title, iconName: imageName)
        var isShowLine = false
        if indexPath.row != (cellTitleConfig[indexPath.section].count - 1) {
            isShowLine = true
        }
        cell?.setLineShow(show: isShowLine)

        return cell!
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellTitle = cellTitleConfig[indexPath.section][indexPath.row]
//        let isLogin = TSCurrentUserInfo.share.isLogin
        switch cellTitle {
        case "资讯":
            let newsVC = TSNewsRootViewController()
            self.navigationController?.pushViewController(newsVC, animated: true)
        case "音乐FM":
            let musicVC = TSMusicListVC()
            self.navigationController?.pushViewController(musicVC, animated: true)
        case "圈子":
            let newsVC = GroupHomeController()
            self.navigationController?.pushViewController(newsVC, animated: true)
        case "话题":
            let topicGroup = TSTopicGroupVCViewController()
            self.navigationController?.pushViewController(topicGroup, animated: true)
            break
        case "找人":
            let vc = TSNewFriendsVC.vc()
            navigationController?.pushViewController(vc, animated: true)
        case "问答":
            let vc = TSQuoraHomeController()
            navigationController?.pushViewController(vc, animated: true)
        case "排行榜":
            let vc = RankListController()
            navigationController?.pushViewController(vc, animated: true)
        case "测试":
//            let testVC = TSTestListController()
//            self.navigationController?.pushViewController(testVC, animated: true)
            break
        default:
            assert(false, "发现页面配置错误")
            break
        }
    }

    /// tableView的sectionheader不悬停
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= TSDiscoverTableUX.sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else if scrollView.contentOffset.y >= TSDiscoverTableUX.sectionHeaderHeight {
            scrollView.contentInset = UIEdgeInsets(top: -TSDiscoverTableUX.sectionHeaderHeight, left: 0, bottom: 0, right: 0)
        }
    }
}
