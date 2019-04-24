//
//  TSChatSingleAddMemberVC.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/26.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher

class TSChatSingleAddMemberVC: TSViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, TSChatChooseFriendCellDelegate {
    var currentConversattion: EMConversation?
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
    var address: String?
    var titleStr: String?
    var latitude: Float = 0.0
    var longitude: Float = 0.0
    var image: UIImage?

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
    /// 是否是第一次自动搜索（增加这个属性的原因：参见#1418 后台若没有推荐用户，刚进入搜索页时应该显示空白页，不应该显示缺省图）
    var firstLoad = true
    /// 是否是增删成员才进入这个页面的 "" 为正常创建聊天 add 为增加成员  delete 为删减成员
    var ischangeGroupMember: String? = ""
    /// 右上角按钮显示内容文字（增加页面 “添加“ 删减页面 “删除” 创建聊天页面 “聊天” 默认是 “聊天”）
    var rightButtonTitle: String = "聊天"
    /// 如果是删除群成员的页面，这个群主 ID 必须传
    var ownerId: String = ""
    /// 当前正在聊天的对象的信息
    var hyUserInfo: TSUserInfoObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        if self.image != nil {
            rightButtonTitle = "发送"
        } else {
            rightButtonTitle = "聊天"
        }
        title = "选择好友"
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
        searchTextfield.backgroundColor = TSColor.normal.placeholder
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
        friendListTableView = TSTableView(frame: CGRect(x: 0, y:49.5, width: ScreenWidth, height: ScreenHeight - 49.5 - 64), style: UITableViewStyle.plain)
        friendListTableView.delegate = self
        friendListTableView.dataSource = self
        friendListTableView.separatorStyle = .none
        friendListTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        friendListTableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.view.addSubview(friendListTableView)
        friendListTableView.mj_footer.isAutomaticallyHidden = true
        friendListTableView.mj_header.beginRefreshing()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friendListTableView.mj_footer.isHidden = dataSource.count < TSNewFriendsNetworkManager.limit
        if !dataSource.isEmpty {
            occupiedView.removeFromSuperview()
        }
        return dataSource.count
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
        cell?.setUserInfoData(model: dataSource[indexPath.row])
        cell?.delegate = self
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.5
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell: TSChatChooseFriendCell = tableView.cellForRow(at: indexPath) as! TSChatChooseFriendCell
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
    }

    func refresh() {
        keyword = searchTextfield.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        view.endEditing(true)
        TSUserNetworkingManager().friendList(offset: nil, keyWordString: keyword, complete: { (userModels, networkError) in
            // 如果是第一次进入
            self.friendListTableView.mj_header.endRefreshing()
            self.processRefresh(datas: userModels, message: networkError)
        })
    }

    func loadMore() {
        TSUserNetworkingManager().friendList(offset: dataSource.count, keyWordString: nil, complete: { (userModels, networkError) in
            guard var datas = userModels else {
                self.friendListTableView.mj_footer.endRefreshing()
                return
            }
            if datas.count < TSNewFriendsNetworkManager.limit {
                self.friendListTableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.friendListTableView.mj_footer.endRefreshing()
            }
            for (index, item) in datas.enumerated().reversed() {
                if item.userIdentity == self.hyUserInfo?.userIdentity {
                    datas.remove(at: index)
                }
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
        if var datas = datas {
            for (index, item) in datas.enumerated().reversed() {
                if item.userIdentity == self.hyUserInfo?.userIdentity {
                    datas.remove(at: index)
                }
            }
            dataSource = datas
            if dataSource.isEmpty {
                showOccupiedView(type: .empty)
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
        creatNewChat()
    }

    // MARK: - 新创建聊天
    func creatNewChat() {
        if choosedDataSource.count > 0 {
            if !EMClient.shared().isLoggedIn {
                let appDeleguate = UIApplication.shared.delegate as! AppDeleguate
                appDeleguate.getHyPassword()
                chatItem?.isUserInteractionEnabled = true
                return
            }
            if choosedDataSource.count == 1 && self.image != nil {
                //创建单聊
                let model = choosedDataSource[0] as! TSUserInfoModel
                let idSt: String = String(model.userIdentity)
                let vc = ChatDetailViewController(conversationChatter: idSt, conversationType:EMConversationTypeChat)
                TSLogCenter.log.debug(self.image)
                vc?.chatTitle = model.name
                vc?.image = self.image
                vc?.latitude = self.latitude
                vc?.longitude = self.longitude
                vc?.titleStr = self.titleStr
                vc?.address = self.address
                vc?.uid = idSt
                navigationController?.pushViewController(vc!, animated: true)
                return
            }
            if choosedDataSource.count > 1 && self.image != nil {
                //群聊
                let group = DispatchGroup()
             TSIndicatorWindowTop.showDefaultTime(state: .loading, title: "正在发送")
                for model in choosedDataSource {
                    let model = model as! TSUserInfoModel
                    let idSt: String = String(model.userIdentity)
                    let info: NSDictionary = [ "address": self.address ?? "", "title": self.titleStr ?? "", "image": "1", "latitude": String(self.latitude), "longitude": String(self.longitude)]
                    let message = EaseSDKHelper.getImageMessage(with: self.image, to: idSt, messageType: EMChatTypeChat, messageExt: info as! [AnyHashable : Any])
                    group.enter()
                    EMClient.shared().chatManager.send(message, progress: nil) { (message, error) in
                        group.leave()
                    }
                }
                group.notify(queue: DispatchQueue.main) {
                    TSIndicatorWindowTop.showDefaultTime(state: .success, title: "发送成功")
                    for vc in (self.navigationController?.viewControllers)! {
                        if vc.isKind(of:ChatDetailViewController.self) {
                            self.navigationController?.popToViewController(vc, animated: true)
                        }
                    }
                    return
                }
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
            //conversationId
            //          self.currentConversattion?.conversationId
            guard let currentChatId = hyUserInfo?.userIdentity  else {
                return
            }
            let chatId = String(currentChatId)
            guard let currentChatName = hyUserInfo?.name else {
                return
            }

            /// 先加上自己 和 当前聊天对象
            if groupname == "" {
                groupname = "\(username)、\(currentChatName)"
            } else {
                groupname = "\(groupname)、\(username)、\(currentChatName)"
            }
            if menbers == "" {
                menbers = "\(userId),\(chatId)"
            } else {
                menbers = "\(menbers),\(userId),\(chatId)"
            }

            for  item in choosedDataSource {
                let model = item as! TSUserInfoModel
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

            TSAccountNetworkManager().creatHyGroup(groupname: groupname, desc: desc, ispublic: ispublic, maxusers: maxusers, menbers_only: menbers_only, allowinvites: allowinvites, owner: owner, menbers: menbers, complete: { (data, status) in
                guard status else {
                    self.chatItem?.isUserInteractionEnabled = true
                    return
                }
                guard let groupId = data?.object(forKey: "im_group_id") else {
                    self.chatItem?.isUserInteractionEnabled = true
                    return
                }
                let converId = "\(groupId)"
                /// 获取群信息
                TSAccountNetworkManager().getHyGroupInfo(groupid: converId, complete: { (response, result) in
                    self.chatItem?.isUserInteractionEnabled = true
                    guard result else {
                        return
                    }
                    let dict = response![0] as? NSDictionary
                    let chatname = dict?.object(forKey: "name") as? String
                    let vc = ChatDetailViewController(conversationChatter: converId, conversationType:EMConversationTypeGroupChat)
                    vc?.chatTitle = chatname ?? ""
                    vc?.groupOriginData = dict!
                    self.navigationController?.pushViewController(vc!, animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "singleChatSwithGroup"), object: nil)
                })
            })
        } else {
            chatItem?.isUserInteractionEnabled = true
            return
        }
    }

    // MARK: - TSChatChooseFriendCellDelegate
    func chatButtonClick(chatbutton: UIButton, userModel: TSUserInfoModel) {
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
        } else {
            choosedWidth = chooseArray.count * headerWidth + (chooseArray.count - 1) * headerSpace
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
        choosedScrollView.contentSize = CGSize(width: choosedWidth, height: 49)

        /// 依次布局头像视图
        for (index, model) in chooseArray.enumerated() {
            let usermodel: TSUserInfoModel = model as! TSUserInfoModel
            let headerButton: UIButton = UIButton(frame: CGRect(x: index * (headerWidth + headerSpace), y: (49 - headerWidth) / 2, width: headerWidth, height: headerWidth))
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
        TSUserNetworkingManager().friendList(offset: nil, keyWordString: keyword, complete: { (userModels, networkError) in
            // 如果是第一次进入
            if self.firstLoad == true {
                self.firstLoad = false
                // 需求：如果第一次进入（自动刷新），获取后台推荐用户是空的，就显示空白页，不显示缺省图
                if userModels?.isEmpty == true {
                    return
                }
            }
            self.processRefresh(datas: userModels, message: networkError)
        })
        return true
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
