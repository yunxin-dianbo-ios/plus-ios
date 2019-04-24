//
//  TSFansAndFollowVC.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/14.
//  Copyright © 2017年 LeonFa. All rights reserved.
//
//  粉丝关注列表

import UIKit

protocol TSFansAndFollowVCProtocol: class {
    func fansAndFollowShowFansVC()
}

class TSFansAndFollowVC: TSLabelViewController, ChangeVCStateDelegate {

    /// 用户信息
    var userIdentity: Int? = nil
    /// 粉丝页面
    var fansVC: TSFollowFansListDetailVC
    /// 关注页面
    var followVC: TSFollowFansListDetailVC

    /// 代理
    weak var delegate: TSFansAndFollowVCProtocol?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    init(userIdentity: Int) {
        followVC = TSFollowFansListDetailVC(type: .follow, userId: userIdentity)
        fansVC = TSFollowFansListDetailVC(type: .fans, userId: userIdentity)
        followVC.removeNotic()
        fansVC.removeNotic()
        super.init(labelTitleArray: ["粉丝", "关注"], scrollViewFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - TSNavigationBarHeight))
        self.userIdentity = userIdentity
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        TSTaskQueueTool.getAndSave(userInfo: [(TSCurrentUserInfo.share.userInfo?.userIdentity)!], complete: { (_, _, _) in
        })
    }

    /// 分页切换了
    override func selectedPageChangedTo(index: Int) {
        if index == 0 {
            if let delegate = delegate {
                delegate.fansAndFollowShowFansVC()
            }
        }
    }

    // MARK: - Custom user interface
    func setUI() {
        fansVC.changeVCStateDelegate = self
        followVC.changeVCStateDelegate = self
        add(childViewController: followVC, At: 1)
        add(childViewController: fansVC, At: 0)
    }

    // follower and fans vc delegate
    func changeState(data: TSFollowFansListModel, row: Int, controller: TSFollowFansListDetailVC, isCancel: TSUserIsCancelFollow) {
        if controller.isEqual(fansVC) {
            var isHave = true
            for item in followVC.listData {
                if item.userIdentity == data.userId {
                    isHave = false
                }
            }

            if isHave {
                followVC.refresh()
                return
            }

            followVC.tableView.reloadData()
        } else {
            fansVC.tableView.reloadData()
        }
    }
}
