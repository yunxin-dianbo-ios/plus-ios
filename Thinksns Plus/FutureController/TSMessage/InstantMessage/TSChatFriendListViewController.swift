//
//  TSChatFriendListViewController.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/12.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher

class TSChatFriendListViewController: TSViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, TSChatChooseFriendCellDelegate, UIScrollViewDelegate {

    /// 数据源
    var dataSource: [TSUserInfoModel] = []
    /// 当前页面新选择的数据
    var choosedDataSource = NSMutableArray()
    /// 进入当前页面之前就已经选择的数据（主要是存储从群详情页和查看群成员页面跳转过来的时候一并传递过来的已有群成员数据）
    var originDataSource = NSMutableArray()
    /// 删除成员时候自己检索出来的成员数据数组
    var searchDataSource = NSMutableArray()
    /// 当前操作之前的群 ID
    var currenGroupId: String? = ""

    var friendListTableView: TSTableView!
    var searchView = UIView()
    var searchTextfield = UITextField()
    var choosedScrollView = UIScrollView()
    let headerSpace: Int = 5
    let headerWidth: Int = 25
    /// 屏幕比例
    let scale = UIScreen.main.scale
    /// 重绘大小的配置
    var resizeProcessor: ResizingImageProcessor {
        let avatarImageSize = CGSize(width: CGFloat(headerWidth) * scale, height: CGFloat(headerWidth) * scale)
        return ResizingImageProcessor(referenceSize: avatarImageSize, mode: .aspectFill)
    }
    /// 聊天按钮
    var chatItem: UIButton?
    /// 占位图
    let occupiedView = UIImageView()
    /// 右上确定聊天按钮
    fileprivate weak var chatSureButton: UIButton!

    var chatType: String? = ""
    /// 搜索关键词
    var keyword = ""
    /// 是否是增删成员才进入这个页面的 "" 为正常创建聊天 add 为增加成员  delete 为删减成员
    var ischangeGroupMember: String? = ""
    /// 右上角按钮显示内容文字（增加页面 “添加“ 删减页面 “删除” 创建聊天页面 “聊天” 默认是 “聊天”）
    var rightButtonTitle: String = "聊天"
    /// 如果是删除群成员的页面，这个群主 ID 必须传
    var ownerId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        if ischangeGroupMember == "" {
            rightButtonTitle = "聊天"
            title = "选择好友"
        } else if ischangeGroupMember == "add" {
            rightButtonTitle = "添加"
            title = "添加成员"
        } else if ischangeGroupMember == "map" {
            rightButtonTitle = "发送"
            title = "选择好友"
        } else if ischangeGroupMember == "delete" {
            rightButtonTitle = "删除"
            title = "删除成员"
            for (index, item) in originDataSource.enumerated().reversed() {
                let userinfo: TSUserInfoModel = item as! TSUserInfoModel
                if userinfo.userIdentity == Int(ownerId) {
                    originDataSource.removeObject(at: index)
                }
            }
            searchDataSource.addObjects(from: originDataSource as! [Any])
        }
        let leftItemBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        leftItemBtn.setTitle("取消", for: .normal)
        leftItemBtn.set(font: UIFont.systemFont(ofSize: 16))
        leftItemBtn.setTitleColor(TSColor.main.theme, for: .normal)
        leftItemBtn.setTarget(self, action: #selector(leftBtnClick(btn:)), for: .touchUpInside)
        let letfItem = UIBarButtonItem(customView: leftItemBtn)
        self.navigationItem.leftBarButtonItem = letfItem
        creatTopSubView()
        creatTableView()
    }

    // MARK: - 创建顶部视图
    func creatTopSubView() {
        occupiedView.contentMode = .center
        chatItem = UIButton(type: .custom)
        chatItem?.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.setupNavigationTitleItem(chatItem!, title: rightButtonTitle)
        updateRightButtonStatus()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: chatItem!)

        /// 搜索试图
        searchView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 49.5))
        searchView.backgroundColor = UIColor.white
        self.view.addSubview(searchView)
        searchView.isHidden = true

        choosedScrollView = UIScrollView()
        choosedScrollView.isScrollEnabled = true
        choosedScrollView.isPagingEnabled = true
        choosedScrollView.showsHorizontalScrollIndicator = false
        searchView.addSubview(choosedScrollView)
        choosedScrollView.isHidden = true

        searchTextfield = UITextField(frame: CGRect(x: 15, y: (49 - 34) / 2.0, width: ScreenWidth - 15 * 2, height: 34))
        searchTextfield.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        searchTextfield.textColor = TSColor.normal.minor
        searchTextfield.placeholder = "搜索"
        searchTextfield.returnKeyType = .search
        searchTextfield.backgroundColor = UIColor.clear
        searchTextfield.layer.cornerRadius = 5
        searchTextfield.delegate = self

        let searchIcon = UIImageView()
        searchIcon.image = #imageLiteral(resourceName: "IMG_search_icon_search")
        searchIcon.contentMode = .center
        searchIcon.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        searchTextfield.leftView = searchIcon
        searchTextfield.leftViewMode = .always
        searchView.addSubview(searchTextfield)

        let lineView = UIView(frame: CGRect(x: 0, y: 49, width: ScreenWidth, height: 0.5))
        lineView.backgroundColor = UIColor(hex: 0xdedede)
        searchView.addSubview(lineView)
    }

    func creatTableView() {
        friendListTableView = TSTableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - 64), style: UITableViewStyle.plain)
        friendListTableView.delegate = self
        friendListTableView.dataSource = self
        friendListTableView.separatorStyle = .none
        friendListTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        if ischangeGroupMember != "delete" {
            friendListTableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
            friendListTableView.mj_footer.isAutomaticallyHidden = true
        } else {
            friendListTableView.mj_footer = nil
        }
        self.view.addSubview(friendListTableView)
        friendListTableView.mj_header.beginRefreshing()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ischangeGroupMember == "delete" {
            if searchDataSource.count > 0 {
                occupiedView.removeFromSuperview()
            }
            return searchDataSource.count
        } else {
            friendListTableView.mj_footer.isHidden = dataSource.count < TSNewFriendsNetworkManager.limit
            if !dataSource.isEmpty {
                occupiedView.removeFromSuperview()
            }
            return dataSource.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "chatfiendlistcell"
        var cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as? TSChatChooseFriendCell
        if cell == nil {
            cell = TSChatChooseFriendCell(style: UITableViewCellStyle.default, reuseIdentifier: indentifier)
        }
        cell?.currentChooseArray = choosedDataSource
        cell?.originData = originDataSource
        cell?.ischangeGroupMember = ischangeGroupMember
        cell?.selectionStyle = .none
        if ischangeGroupMember == "delete" {
            cell?.setUserInfoData(model: searchDataSource[indexPath.row] as! TSUserInfoModel)
        } else {
            cell?.setUserInfoData(model: dataSource[indexPath.row])
        }
        cell?.delegate = self
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.5
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell: TSChatChooseFriendCell = tableView.cellForRow(at: indexPath) as! TSChatChooseFriendCell
        /// 需要先判断当前页面是不是增加成员页面
        if ischangeGroupMember == "add" {
            for (_, model) in originDataSource.enumerated() {
                let userinfo: TSUserInfoModel = model as! TSUserInfoModel
                if userinfo.userIdentity == cell.userInfo?.userIdentity {
                    return
                }
            }
        }
        if cell.chatButton.isSelected {
            for (index, model) in choosedDataSource.enumerated() {
                let userinfo: TSUserInfoModel = model as! TSUserInfoModel
                if userinfo.userIdentity == cell.userInfo?.userIdentity {
                    choosedDataSource.removeObject(at: index)
                    break
                }
            }
            updateChoosedScrollViewUI(chooseArray: choosedDataSource)
        } else {
            choosedDataSource.add(cell.userInfo)
            updateChoosedScrollViewUI(chooseArray: choosedDataSource)
        }
        cell.chatButton.isSelected = !cell.chatButton.isSelected
        // 头像默认点击事件
//        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": model.userIdentity])
    }

    func refresh() {
        if ischangeGroupMember == "delete" {
            keyword = searchTextfield.text ?? ""
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
                for (_, item) in dataSource.enumerated() {
                    let usermodel: TSUserInfoModel = item as! TSUserInfoModel
                    if usermodel.name.range(of: keyword) != nil {
                        searchDataSource.add(usermodel)
                    }
                }
                friendListTableView.reloadData()
            }
        } else {
            keyword = searchTextfield.text ?? ""
            keyword = keyword.replacingOccurrences(of: " ", with: "")
            view.endEditing(true)
            TSUserNetworkingManager().friendList(offset: nil, keyWordString: keyword, complete: { (userModels, networkError) in
                // 如果是第一次进入
                self.friendListTableView.mj_header.endRefreshing()
                self.processRefresh(datas: userModels, message: networkError)
            })
        }
    }

    func loadMore() {
        TSUserNetworkingManager().friendList(offset: dataSource.count, keyWordString: nil, complete: { (userModels, networkError) in
            guard let datas = userModels else {
                self.friendListTableView.mj_footer.endRefreshing()
                return
            }
            if datas.count < TSNewFriendsNetworkManager.limit {
                self.friendListTableView.mj_footer.endRefreshingWithNoMoreData()
                let footer = self.friendListTableView.mj_footer as? TSRefreshFooter
                var footerStr: String = ""
                if self.ischangeGroupMember == "" {
                    footerStr = "没有更多好友了"
                } else if self.ischangeGroupMember == "add" {
                    footerStr = "没有更多成员了"
                } else if self.ischangeGroupMember == "delete" {
                    footerStr = "没有更多成员了"
                }
                footer?.detailInfoLabel.text = footerStr
            } else {
                self.friendListTableView.mj_footer.endRefreshing()
            }
            self.dataSource = self.dataSource + datas
            self.friendListTableView.reloadData()
        })
    }

    /// 显示占位图
    func showOccupiedView(type: TSTableViewController.OccupiedType) {
        var image = ""
        switch type {
        case .empty:
            image = "IMG_img_default_nobody"
        case .network:
            image = "IMG_img_default_internet"
        }
        occupiedView.image = UIImage(named: image)
        if occupiedView.superview == nil {
            occupiedView.frame = friendListTableView.bounds
            friendListTableView.addSubview(occupiedView)
        }
    }

    func processRefresh(datas: [TSUserInfoModel]?, message: NetworkError?) {
        friendListTableView.mj_footer.resetNoMoreData()
        // 获取数据成功
        if let datas = datas {
            dataSource = datas
            if dataSource.isEmpty && keyword.isEmpty {
                showOccupiedView(type: .empty)
            } else {
                searchView.isHidden = false
                friendListTableView.frame = CGRect(x: 0, y: 49.5, width: ScreenWidth, height: ScreenHeight - 49.5 - 64)
            }
        }
        // 获取数据失败
        if message != nil {
            dataSource = []
            showOccupiedView(type: .network)
        }
        friendListTableView.reloadData()
    }

    func rightButtonClick() {
        chatItem?.isUserInteractionEnabled = false
        if ischangeGroupMember == "" {
            creatNewChat()
        } else if ischangeGroupMember == "add" {
            addMembersForGroup(addOrDelete: "add")
        } else if ischangeGroupMember == "delete" {
            addMembersForGroup(addOrDelete: "delete")
        } else if ischangeGroupMember == "map" {
              creatNewChat()
        }
    }

    // MARK: - 新创建聊天
    func creatNewChat() {
        if choosedDataSource.count > 0 {
            //chatType == "chat" && choosedDataSource.count == 1
            if choosedDataSource.count == 1 {
                let model: TSUserInfoModel = choosedDataSource[0] as! TSUserInfoModel
                if !EMClient.shared().isLoggedIn {
                    let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
                    appDeleguate.getHyPassword()
                    return
                }
                let idSt: String = String(model.userIdentity)
                let vc = ChatDetailViewController(conversationChatter: idSt, conversationType:EMConversationTypeChat)
                vc?.chatTitle = model.name
                navigationController?.pushViewController(vc!, animated: true)
            } else {

                if !EMClient.shared().isLoggedIn {
                    let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
                    appDeleguate.getHyPassword()
                    chatItem?.isUserInteractionEnabled = true
                    return
                }
                // 群聊创建
                /*群创建字段：
                 groupname//群组名称必填
                 desc//群组简介必填
                 public//是否公开群必填
                 maxusers//群成员最大数量
                 menbers_only//加入群是否需要群主或者群管理员审核默认false
                 allowinvites//是否允许群成员邀请别人加入
                 owner//群组的管理员必填
                 menbers//群组的成员*/
                /// 准备参数
                var groupname = ""
                var menbers = ""
                guard let userId = TSCurrentUserInfo.share.userInfo?.userIdentity else {
                    return
                }
                let owner = String(userId)
                guard let username = TSCurrentUserInfo.share.userInfo?.name else {
                    return
                }
                /// 先加上自己，这样群主直接在最前面
                if groupname == "" {
                    groupname = "\(username)"
                } else {
                    groupname = "\(groupname)、\(username)"
                }
                if menbers == "" {
                    menbers = "\(userId)"
                } else {
                    menbers = "\(menbers),\(userId)"
                }

                for (index, item) in choosedDataSource.enumerated() {
                    let model: TSUserInfoModel = choosedDataSource[index] as! TSUserInfoModel
                    if groupname == "" {
                        groupname = "\(model.name)"
                    } else {
                        groupname = "\(groupname)、\(model.name)"
                    }
                    if menbers == "" {
                        menbers = "\(model.userIdentity)"
                    } else {
                        menbers = "\(menbers),\(model.userIdentity)"
                    }
                }

                let desc = "还没填写任何群简介"
                let ispublic = "0"
                let maxusers = "300"
                let menbers_only = "0"
                let allowinvites = "0"
                loading()
                TSAccountNetworkManager().creatHyGroup(groupname: groupname, desc: desc, ispublic: ispublic, maxusers: maxusers, menbers_only: menbers_only, allowinvites: allowinvites, owner: owner, menbers: menbers, complete: { (data, status) in
                    guard status else {
                        self.endLoading()
                        self.chatItem?.isUserInteractionEnabled = true
                        self.showFialMsg(msg: "创建失败")
                        return
                    }
                    guard let groupId = data?.object(forKey: "im_group_id") else {
                        self.endLoading()
                        self.chatItem?.isUserInteractionEnabled = true
                        self.showFialMsg(msg: "创建失败")
                        return
                    }
                    let converId = "\(groupId)"
                    /// 获取群信息
                    TSAccountNetworkManager().getHyGroupInfo(groupid: converId, complete: { (response, result) in
                        self.endLoading()
                        guard result else {
                            self.chatItem?.isUserInteractionEnabled = true
                            self.showFialMsg(msg: "获取群信息失败")
                            return
                        }
                        /// 需要给自己发一个快速编辑入口的系统消息
                        let hyConversationNew = EMClient.shared().chatManager.getConversation(converId, type: EMConversationTypeGroupChat, createIfNotExist: true)
                        // 提示语
                        let messageBody: EMTextMessageBody = EMTextMessageBody(text: "快速编辑群名称，开启群聊")
                        let messageFrom = "admin"
                        let messageReal = EMMessage(conversationID: hyConversationNew?.conversationId, from: messageFrom, to: EMClient.shared().currentUsername, body: messageBody, ext: nil)
                        messageReal?.chatType = EMChatTypeGroupChat
                        messageReal?.isRead = true
                        messageReal?.direction = EMMessageDirectionReceive
                        messageReal?.status = EMMessageStatusSucceed
                        var resultError: EMError? = nil
                        hyConversationNew?.insert(messageReal, error: &resultError)

                        let dict = response![0] as? NSDictionary
                        let chatname = dict?.object(forKey: "name") as? String
                        let vc = ChatDetailViewController(conversationChatter: converId, conversationType:EMConversationTypeGroupChat)
                        vc?.chatTitle = chatname ?? ""
                        vc?.groupOriginData = dict!
                        vc?.hidScreen = true
                        self.navigationController?.pushViewController(vc!, animated: true)
                    })
                })
            }
        } else {
            chatItem?.isUserInteractionEnabled = true
            return
        }
    }

    // 显示创建失败提示
    func showFialMsg(msg: String) {
        let alert = TSIndicatorWindowTop(state: .faild, title: msg)
        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    // MARK: - 增加群成员
    /*
    移除群成员：
    /easemob/group/member
    delete
    参数：im_group_id
    members      多个用","隔开
    */
    func addMembersForGroup(addOrDelete: String) {
        guard currenGroupId != "" else {
            return
        }
        if choosedDataSource.count > 0 {
            if !EMClient.shared().isLoggedIn {
                let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
                appDeleguate.getHyPassword()
                return
            }
            /// 准备参数
            var menbers = ""
            for (index, _) in choosedDataSource.enumerated() {
                let model: TSUserInfoModel = choosedDataSource[index] as! TSUserInfoModel
                if menbers == "" {
                    menbers = "\(model.userIdentity)"
                } else {
                    menbers = "\(menbers),\(model.userIdentity)"
                }
            }
            /// 添加成员
            TSAccountNetworkManager().addOrDeleteGroupMember(groupid: currenGroupId!, membersId: menbers, typeString: addOrDelete, complete: { (data, status) in
                guard status else {
                    return
                }
                var membersInfo = [String: Any]()
                membersInfo.updateValue(self.choosedDataSource, forKey: "members")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadgroupdata"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadgroupmemberdata"), object: membersInfo)
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            return
        }
    }

    // MARK: - TSChatChooseFriendCellDelegate
    func chatButtonClick(chatbutton: UIButton, userModel: TSUserInfoModel) {
        if ischangeGroupMember == "add" {
            for (_, model) in originDataSource.enumerated() {
                let userinfo: TSUserInfoModel = model as! TSUserInfoModel
                if userinfo.userIdentity == userModel.userIdentity {
                    return
                }
            }
        }
        if chatbutton.isSelected {
            choosedDataSource.remove(userModel)
            updateChoosedScrollViewUI(chooseArray: choosedDataSource)
        } else {
            choosedDataSource.add(userModel)
            updateChoosedScrollViewUI(chooseArray: choosedDataSource)
        }
        chatbutton.isSelected = !chatbutton.isSelected
    }

    // MARK: - 修改已选好友排版视图 choosedScrollView
    func updateChoosedScrollViewUI(chooseArray: NSMutableArray) {
        choosedScrollView.isHidden = false
        /// 首先要把所有子视图移除，避免重复添加
        choosedScrollView.removeAllSubViews()
        /// 处理 scrollView
        var choosedWidth: Int = 0
        if chooseArray.count <= 0 {
            choosedWidth = 0
            searchTextfield.leftViewMode = .always
        } else {
            // 第一个头像左边也得有一个间隔
            choosedWidth = chooseArray.count * headerWidth + (chooseArray.count - 1) * headerSpace + headerSpace
            searchTextfield.leftViewMode = .never
        }
        if choosedWidth > (Int)(ScreenWidth - 90 - 5) {
            choosedScrollView.frame = CGRect(x: 0, y: 0, width: ScreenWidth - 90, height: 49)
            searchTextfield.frame = CGRect(x: choosedScrollView.right + 5, y: (49 - 34) / 2.0, width: 90, height: 34)
        } else {
            choosedScrollView.frame = CGRect(x: 0, y: 0, width: choosedWidth, height: 49)
            if choosedWidth == 0 {
                searchTextfield.frame = CGRect(x: 15, y: (49 - 34) / 2.0, width: ScreenWidth - 15 * 2, height: 34)
            } else {
                searchTextfield.frame = CGRect(x: choosedScrollView.right + 5, y: (49 - 34) / 2.0, width: ScreenWidth - CGFloat(choosedWidth) - 15.0 - 5.0, height: 34)
            }
        }
        choosedScrollView.contentSize = CGSize(width: choosedWidth, height: 0)
        choosedScrollView.scrollToRight()
        /// 依次布局头像视图
        for (index, model) in chooseArray.enumerated() {
            let usermodel: TSUserInfoModel = model as! TSUserInfoModel
            let headerButton: UIButton = UIButton(frame: CGRect(x: index * (headerWidth + headerSpace) + headerSpace, y: (49 - headerWidth) / 2, width: headerWidth, height: headerWidth))
            headerButton.layer.masksToBounds = true
            headerButton.layer.cornerRadius = CGFloat(headerWidth) / 2.0
            if usermodel.avatar != nil {
                headerButton.kf.setImage(with: URL(string: TSUtil.praseTSNetFileUrl(netFile:usermodel.avatar) ?? ""), for: .normal, placeholder: UIImage(named: "IMG_pic_default_secret"), options: [.processor(resizeProcessor)], progressBlock: nil, completionHandler: nil)
            } else {
                if usermodel.sex == 1 {
                    headerButton.setImage(UIImage(named: "IMG_pic_default_man"), for: .normal)
                } else if usermodel.sex == 2 {
                    headerButton.setImage(UIImage(named: "IMG_pic_default_woman"), for: .normal)
                } else {
                    headerButton.setImage(UIImage(named: "IMG_pic_default_secret"), for: .normal)
                }
            }
            let iconImage: UIImageView = UIImageView(frame: CGRect(x: headerButton.left + headerButton.frame.width * 0.65, y: headerButton.top + headerButton.frame.width * 0.65, width: headerButton.frame.width * 0.35, height: headerButton.frame.width * 0.35))
            iconImage.layer.masksToBounds = true
            iconImage.layer.cornerRadius = headerButton.frame.width * 0.35 / 2.0
            if usermodel.verified?.type == "" {
                iconImage.isHidden = true
            } else {
                iconImage.isHidden = false
                if usermodel.verified?.icon == "" {
                    switch usermodel.verified?.type {
                    case "user"?:
                        iconImage.image = UIImage(named: "IMG_pic_identi_individual")
                    case "org"?:
                        iconImage.image = UIImage(named: "IMG_pic_identi_company")
                    default:
                        iconImage.image = UIImage(named: "")
                    }
                } else {
                    let resize = ResizingImageProcessor(referenceSize: iconImage.frame.size, mode: .aspectFit)
                    let urlString = usermodel.verified?.icon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    let iconURL = URL(string: urlString ?? "")
                    iconImage.kf.setImage(with: iconURL, placeholder: nil, options: [.processor(resize)], progressBlock: nil, completionHandler: nil)
                }
            }
            choosedScrollView.addSubview(headerButton)
            choosedScrollView.addSubview(iconImage)
        }
        updateRightButtonStatus()
    }

    func updateRightButtonStatus() {
        if choosedDataSource.count > 0 {
            chatItem?.isEnabled = true
            chatItem?.setTitle("\(rightButtonTitle)(\(choosedDataSource.count))", for: .normal)
            self.setupNavigationTitleItem(chatItem!, title: "\(rightButtonTitle)(\(choosedDataSource.count))")
            chatItem?.setTitleColor(TSColor.main.theme, for: .normal)
        } else {
            chatItem?.isEnabled = false
            chatItem?.setTitle(rightButtonTitle, for: .normal)
            self.setupNavigationTitleItem(chatItem!, title: rightButtonTitle)
            chatItem?.setTitleColor(UIColor(hex: 0xb2b2b2), for: .normal)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyword = searchTextfield.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        view.endEditing(true)
        if ischangeGroupMember == "delete" {
            searchDataSource.removeAllObjects()
            for (_, item) in dataSource.enumerated() {
                let usermodel: TSUserInfoModel = item as TSUserInfoModel
                if usermodel.name.range(of: keyword) != nil {
                    searchDataSource.add(usermodel)
                }
            }
            friendListTableView.reloadData()
            return true
        }
        TSUserNetworkingManager().friendList(offset: nil, keyWordString: keyword, complete: { (userModels, networkError) in
            self.processRefresh(datas: userModels, message: networkError)
        })
        return true
    }

    func leftBtnClick(btn: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
