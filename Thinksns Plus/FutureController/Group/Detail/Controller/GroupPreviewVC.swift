//
//  GroupPreviewVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/9/7.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class GroupPreviewVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    /// 圈子 id
    var groupId = 0
    var groupModel = GroupModel()
    /// 由于显示的cell是通用cell，所以需要转换为FeedListCellModel
    var datas: [FeedListCellModel] = []
    var headerView: GroupPreviewHeaderView!
    let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    let bottomView = UIView()
    let joinBtn = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView.addSubview(joinBtn)
        view.addSubview(bottomView)
        let joinBtnOffset: CGFloat = 40 + TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight() + 20
        bottomView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.bottom).offset(-joinBtnOffset)
            make.height.equalTo(joinBtnOffset)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        bottomView.isHidden = true
        bottomView.backgroundColor = UIColor.white
        joinBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.bottomView.snp.top).offset(10)
            make.height.equalTo(40)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        joinBtn.isHidden = true
        joinBtn.backgroundColor = TSColor.main.theme
        joinBtn.layer.cornerRadius = 5
        joinBtn.addTarget(self, action: #selector(joinBtnClick), for: .touchUpInside)

        tableView.bounces = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FeedListCell.self, forCellReuseIdentifier: FeedListCell.identifier)
        tableView.register(UINib(nibName: "GroupPreviewInfoCell", bundle: nil), forCellReuseIdentifier: "GroupPreviewInfoCell")
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = TSColor.inconspicuous.background
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        self.headerView = GroupPreviewHeaderView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 100))

        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.bottomView.snp.top)
        }
        loadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return datas.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupPreviewInfoCell", for: indexPath) as? GroupPreviewInfoCell
            if indexPath.row == 0 && self.groupModel.summary.count > 0 {
                cell?.titleLab.text = "简介"
                cell?.contentLab.text = self.groupModel.summary
                if self.groupModel.location.count <= 0 && self.groupModel.notice.count <= 0 {
                    cell?.contentLabBC.constant = 15
                } else {
                     cell?.contentLabBC.constant = 0.01
                }
                cell?.updateConstraints()
            } else if indexPath.row == 1 && self.groupModel.location.count > 0 {
                cell?.titleLab.text = "地址"
                cell?.contentLab.text = self.groupModel.location
                if self.groupModel.notice.count <= 0 {
                    cell?.contentLabBC.constant = 15
                } else {
                     cell?.contentLabBC.constant = 0.01
                }
                cell?.updateConstraints()
            } else if indexPath.row == 2 && self.groupModel.notice.count > 0 {
                cell?.titleLab.text = "公告"
                cell?.contentLab.text = self.groupModel.notice
                cell?.contentLabBC.constant = 15
                cell?.updateConstraints()
            } else {
                cell?.titleLab.text = ""
                cell?.contentLab.text = ""
            }
            return cell!
        } else {
            let cell = FeedListCell.cell(for: tableView, at: indexPath)
            let model = datas[indexPath.row]
            cell.model = model
            cell.delegate = self
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 && self.groupModel.summary.count > 0 {
                let bottomHeight: CGFloat = (self.groupModel.location.count <= 0 && self.groupModel.notice.count <= 0) ? 15 :0.01
                return self.groupModel.summary.size(maxSize: CGSize(width: ScreenWidth - 15 * 2, height: 1_100), font: UIFont.systemFont(ofSize: 14)).height + 6 + 42 + bottomHeight
            }
            if indexPath.row == 1 && self.groupModel.location.count > 0 {
                   let bottomHeight: CGFloat = self.groupModel.notice.count <= 0 ? 10 : 0.01
                return self.groupModel.location.size(maxSize: CGSize(width: ScreenWidth - 15 * 2, height: 1_100), font: UIFont.systemFont(ofSize: 14)).height + 6 + 42 + bottomHeight

            }
            if indexPath.row == 2 && self.groupModel.notice.count > 0 {
                return self.groupModel.notice.size(maxSize: CGSize(width: ScreenWidth - 15 * 2, height: 1_100), font: UIFont.systemFont(ofSize: 14)).height + 6 + 42 + 15
            }
            return 0.01
        } else {
            let cellHeight = datas[indexPath.row].cellHeight
            if cellHeight == 0 {
                return UITableViewAutomaticDimension
            }
            return cellHeight
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 && datas.count > 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 41))
            headerView.backgroundColor = UIColor.white
            let tipLabel = UILabel(frame: CGRect(x: 15, y: 25, width: ScreenWidth, height: 16))
            tipLabel.text = "帖子预览"
            tipLabel.font = UIFont.boldSystemFont(ofSize: 14)
            headerView.addSubview(tipLabel)
            return headerView
        } else {
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return datas.count > 0 ? 41 : 0.01
        } else {
            return 0.01
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        } else {
            return 0.01
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footer = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 10))
            footer.backgroundColor = TSColor.inconspicuous.background
            return footer
        } else {
            return nil
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    // MARK: - Data
    func loadData() {
        let requestGroup = DispatchGroup()
        // 1.获取圈子信息
        requestGroup.enter()
        self.requestGroupInfo(requestGroup: requestGroup)
        // 2.获取列表信息
        requestGroup.enter()
       self.requestPreviewPosts(requestGroup: requestGroup)
        requestGroup.notify(queue: DispatchQueue.main) {
            self.uploadJoinBtn()
            self.tableView.reloadData()
        }
    }
    /// 获取圈子信息
    func requestGroupInfo(requestGroup: DispatchGroup?) {
        GroupNetworkManager.getGroupInfo(groupId: groupId) { [weak self] (model, message, status) in
            guard let model = model else {
                self?.loadFaild(type: .network)
                return
            }
            self?.endLoading()
            // 1.设置 model
            self?.groupModel = model
            // 2.加载帖子视图
            self?.headerView.updateUI(detailModel: (self?.groupModel)!)
            self?.tableView.tableHeaderView = (self?.headerView)!
            self?.title = self?.groupModel.name
            if let requestGroup = requestGroup {
                requestGroup.leave()
            } else {
                /// 只请求圈子信息就更新加入按钮的状态
                self?.uploadJoinBtn()
            }
        }
    }
    /// 获取精华帖子列表
    func requestPreviewPosts(requestGroup: DispatchGroup?) {
        GroupNetworkManager.getPreviewPosts(groupId: groupId) { [weak self] (models, message, status) in
            guard let models = models else {
                self?.loadFaild(type: .network)
                return
            }
            for model in models {
                let cellModel = FeedListCellModel(postModel: model)
                self?.datas.append(cellModel)
            }
            self?.endLoading()
            // 2.加载帖子视图
            if let requestGroup = requestGroup {
                requestGroup.leave()
            } else {
                /// 只请求列表的信息就更新列表的数据
                self?.tableView.reloadData()
            }
        }
    }
    /// 更新加入按钮状态
    func uploadJoinBtn() {
        if let joined = groupModel.joined {
            if joined.audit == 0 {
                self.joinBtn.setTitle("审核中", for: .normal)
                self.joinBtn.backgroundColor = TSColor.normal.disabled
                self.joinBtn.isEnabled = false
            } else if joined.audit == 1 {
                /// 已经通过直接进入详情页，可能是某些原因导致错误进入了该页面
                self.pushDetailVC()
            } else if joined.audit == 2 {
                /// 被拒绝,可以重新申请
                self.joinBtn.backgroundColor = TSColor.main.theme
                self.joinBtn.isEnabled = true
                if groupModel.mode == "paid" {
                    self.joinBtn.setTitle(String(groupModel.money) + TSAppConfig.share.localInfo.goldName + "加入圈子", for: .normal)
                    self.joinBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 7)
                    self.joinBtn.setImage(#imageLiteral(resourceName: "IMG_ico_integral"), for: .normal)
                } else {
                    self.joinBtn.setTitle("加入圈子", for: .normal)
                }
            }
        } else {
            self.joinBtn.backgroundColor = TSColor.main.theme
            self.joinBtn.isEnabled = true
            if groupModel.mode == "paid" {
                self.joinBtn.setTitle(String(groupModel.money) + TSAppConfig.share.localInfo.goldName + "加入圈子", for: .normal)
                self.joinBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 7)
                self.joinBtn.setImage(#imageLiteral(resourceName: "IMG_ico_integral"), for: .normal)
            } else {
                self.joinBtn.setTitle("加入圈子", for: .normal)
            }
        }
        self.joinBtn.isHidden = false
        self.bottomView.isHidden = false
    }
    /// 点击了加入按钮
    func joinBtnClick() {
        // 如果是游客模式，触发登录注册操作
        if TSCurrentUserInfo.share.isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 1.如果是加入圈子，先判断是否是付费圈子，如果是，显示付费弹窗
        let mode = self.groupModel.mode
        if mode == "paid" {
            PaidManager.showPaidGroupAlert(price: Double(self.groupModel.money), groupId: self.groupModel.id, groupMode: mode) {
                // 付费的圈子有审核时间,更新一下圈子信息并刷新加入按钮
                self.requestGroupInfo(requestGroup: nil)
            }
            return
        }

        // 2.如果不是付费圈子，直接发起加入申请
        let alert = TSIndicatorWindowTop(state: .loading, title: "正在加入圈子")
        alert.show()
        GroupNetworkManager.joinGroup(groupId: groupId, complete: { [weak self] (isSuccess, message) in
            alert.dismiss()
            guard let weakself = self else {
                return
            }
            // 成功加入
            if isSuccess {
                let successAlert = TSIndicatorWindowTop(state: .success, title: message)
                successAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                // 非公开的圈子，需要审核时间，所以不能马上改变加入状态
                if weakself.groupModel.mode == "public" {
                   weakself.pushDetailVC()
                    NotificationCenter.default.post(name: NSNotification.Name.Group.joined, object: nil, userInfo: ["isJoin": true, "groupInfo": weakself.groupModel])
                } else {
                    weakself.joinBtn.setTitle("审核中", for: .normal)
                    weakself.joinBtn.isEnabled = false
                    weakself.joinBtn.backgroundColor = TSColor.normal.disabled
                }
            } else {
                // 加入失败
                let faildAlert = TSIndicatorWindowTop(state: .faild, title: message ?? "加入失败")
                faildAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        })
    }
    func pushDetailVC() {
        /// 退出当前页面并进入帖子详情页
        if let viewControllers = self.navigationController?.viewControllers, viewControllers.count >= 2 {
            let popToVC = viewControllers[viewControllers.count - 2]
            self.navigationController?.popToViewController(popToVC, animated: false)
            let postListVC = GroupDetailVC(groupId: self.groupId)
            popToVC.navigationController?.pushViewController(postListVC, animated: true)
        } else if let viewControllers = self.navigationController?.viewControllers, viewControllers.count == 1 {
                /// 模态弹出的导航这个页面
            self.navigationController?.dismiss(animated: true, completion: {
                // 弹出完毕
            })
        } else {
            /// 模态弹出的，导航都没有
            self.navigationController?.dismiss(animated: true, completion: {
                // 弹出完毕
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension GroupPreviewVC: LoadingViewDelegate {

    func reloadingButtonTaped() {
        loadData()
    }

    func loadingBackButtonTaped() {
        navigationController?.popViewController(animated: true)
    }
}
// MARK: - FeedListCellDelegate: 动态列表 cell 代理事件
extension GroupPreviewVC: FeedListCellDelegate {

    /// 点击了查看更多跳转到详情页面
    func feedCell(_ cell: FeedListCell, at index: Int) {

    }

    /// 点击了图片
    func feedCell(_ cell: FeedListCell, didSelectedPictures pictureView: PicturesTrellisView, at index: Int) {

    }

    /// 点击了图片上的数量蒙层按钮
    func feedCell(_ cell: FeedListCell, didSelectedPicturesCountMaskButton pictureView: PicturesTrellisView) {

    }

    /// 点击了工具栏
    func feedCell(_ cell: FeedListCell, didSelectedToolbar toolbar: TSToolbarView, at index: Int) {
    }

    /// 点击了评论行
    func feedCell(_ cell: FeedListCell, didSelectedComment commentView: FeedCommentListView, at indexPath: IndexPath) {
    }

    /// 点击了评论行上的用户名
    func feedCell(_ cell: FeedListCell, didSelectedComment commentCell: FeedCommentListCell, onUser userId: Int) {
    }

    /// 长按了评论行
    func feedCell(_ cell: FeedListCell, didLongPressComment commentView: FeedCommentListView, at indexPath: IndexPath) {
    }

    /// 点击了查看全部按钮
    func feedCellDidSelectedSeeAllButton(_ cell: FeedListCell) {
    }

    /// 点击了重发按钮
    func feedCellDidSelectedResendButton(_ cell: FeedListCell) {
    }

    func feedCellDidClickTopic(_ cell: FeedListCell, topicId: Int) {
    }
}
