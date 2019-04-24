//
//  TSTransationDetailVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/6/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  交易详情信息 视图控制器

import UIKit
import Kingfisher

class TSWalletTransationDetailVC: UITableViewController {

    /// 交易结果
    @IBOutlet weak var labelForResult: TSLabel!
    /// 交易金额
    @IBOutlet weak var labelForMoney: TSLabel!
    /// 交易人类型（付款人 or 收款人）
    @IBOutlet weak var labelForUserType: TSLabel!
    /// 头像
    @IBOutlet weak var buttonForAvatar: AvatarView!
    /// 用户名
    @IBOutlet weak var labelForUsername: TSLabel!
    /// 交易说明
    @IBOutlet weak var labelForDescription: TSLabel!
    /// 交易账户
    @IBOutlet weak var labelForAccount: TSLabel!
    /// 交易时间
    @IBOutlet weak var labelForTime: TSLabel!

    /// 视图数据模型
    var viewModel: TSWalletTransationDetailModel?

    // MARK: - Lifecycle

    class func vc() -> TSWalletTransationDetailVC {
        let sb = UIStoryboard(name: "TSWalletTransationDetailVC", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! TSWalletTransationDetailVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let model = viewModel else {
            return
        }
        setInfo(model: model)
    }

    // MARK: - Custom user interface
    func setUI() {
        title = "显示_账单详情".localized
        tableView.estimatedRowHeight = 50
        tableView.allowsSelection = false
    }

    // MARK: - Public
    func setInfo(model: TSWalletTransationDetailModel) {

        /// 交易结果
        labelForResult.text = model.resultString
        /// 交易金额
        labelForMoney.text = model.moneyString
        /// 付款人
        if let userIdentity = model.userIdentity {
            /// 交易人类型（付款人 or 收款人）
            labelForUserType.text = model.userType
            /// 交易人信息
            TSDataQueueManager.share.userInfoQueue.getData(userIds: [userIdentity], isQueryDB: false, isMust: false, complete: { [weak self] (datas: Array<TSUserInfoObject>?, _) in
                guard let weakSelf = self, let data = datas?.first else {
                    return
                }
                // TODO: UserInfoModelUpdate - 用户数据模型更改，这里需同步更改
                /// 头像
                weakSelf.buttonForAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: data.sex)
                let avatarInfo = AvatarInfo()
                avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: data.avatar)
                avatarInfo.verifiedIcon = data.verified?.icon ?? ""
                avatarInfo.verifiedType = data.verified?.type ?? ""
                weakSelf.buttonForAvatar.avatarInfo = avatarInfo
                /// 用户名
                weakSelf.labelForUsername.text = data.name
            })
        }
        /// 交易说明
        labelForDescription.text = model.descriptionString
        /// 交易账户
        labelForAccount.text = model.accountString
        /// 交易时间
        labelForTime.text = model.dateString
    }

    // MARK: - Delegate

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let model = viewModel else {
            return UITableViewAutomaticDimension
        }
        // 1.如果是用户交易和系统交易，显示收付款人栏，隐藏交易账号栏
        if model.accountString.isEmpty {
            if indexPath.row == 2 {
                return 0
            }
        }
        // 2.如果是支付宝交易，显示交易账号栏，隐藏收付款人栏
        if model.userIdentity == nil {
            if indexPath.row == 0 {
                return 0
            }
        }
        return  UITableViewAutomaticDimension
    }
}
