//
//  ChatDetailViewController.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/4.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher

class ChatDetailViewController: EaseMessageViewController, EaseMessageViewControllerDelegate, EMGroupManagerDelegate, TSMessageShareInfoCellDelegate {

    /// 由外部传进来的群详情
    var groupOriginData = NSDictionary()
    var chatTitle: String?
    var singleChatId: String?
    var singleChatSwithGroup: String? = ""
    var popToRootVC = false

    var hidScreen = true
    var image: UIImage?
    var address: String?
    var titleStr: String?
    var latitude: Float = 0.0
    var longitude: Float = 0.0
    var uid: String?
    var sendSuccess: Bool = false
    /// 进入更多页面按钮
    fileprivate weak var chatButton: UIButton!
    /// 屏蔽icon
    var screenImage: UIImageView!
    /// 房间名称Lab
    /// 由于nav自带的title不方便调整具体的位置，所以没有使用系统的
    /// 需要注意Lab的移除和添加时机
    var roomTitleLab: UILabel!

    override init!(conversationChatter: String!, conversationType: EMConversationType) {
        super.init(conversationChatter: conversationChatter, conversationType: conversationType)
        if conversationType == EMConversationTypeChat {
            self.hidScreen = true
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    deinit {
        EMClient.shared().groupManager.removeDelegate(self)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.dataArray.object(at: indexPath.row)
        if object is String {
            let cell = super.tableView(self.tableView, cellForRowAt: indexPath)
            if cell is EaseMessageTimeCell {
                let cellIdentifier = String(EaseMessageTimeCell.cellIdentifier())
                var timeCell: EaseMessageTimeCell
                if tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) == nil {
                    timeCell = EaseMessageTimeCell(style: .default, reuseIdentifier: cellIdentifier)
                    timeCell.selectionStyle = UITableViewCellSelectionStyle.none
                } else {
                    timeCell = cell as! EaseMessageTimeCell
                }
                timeCell.title = object as! String
                // 系统通知的左右最远位置为头像的X轴中心点
                let maxTitileWidth = ScreenWidth - (10 + 40 / 2.0) * 2
                // bgLabel top bottom均为3
                let titleHeight = timeCell.title.heightWithConstrainedWidth(width: maxTitileWidth, font: UIFont.systemFont(ofSize: 10)) + 3 * 2
                var titleWidth: CGFloat = timeCell.title.sizeOfString(usingFont: UIFont.systemFont(ofSize: 10)).width + 5 * 2
                // 如果title超过屏幕宽度就按照左右10pt计算
                titleWidth = titleWidth > maxTitileWidth ? maxTitileWidth : titleWidth
                timeCell.bgLabel.frame = CGRect(x: (ScreenWidth - titleWidth) / 2.0, y: 5, width: titleWidth, height: titleHeight)
                timeCell.bgLabel.backgroundColor = UIColor(hex: 0xd9d9d9)
                return timeCell
            } else {
                return super.tableView(self.tableView, cellForRowAt: indexPath)
            }
        } else {
            let model: IMessageModel = object as! IMessageModel
            TSLogCenter.log.debug(model.message.ext)
            let cell = super.tableView(self.tableView, cellForRowAt: indexPath)
            if cell is EaseBaseMessageCell {
                let cellIdentifier = String(EaseMessageCell.cellIdentifier(withModel: model))
                var sendCell: EaseBaseMessageCell
                if tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) == nil {
                    sendCell = EaseBaseMessageCell(style: .default, reuseIdentifier: cellIdentifier, model: model)
                    sendCell.selectionStyle = UITableViewCellSelectionStyle.none
                } else {
                    sendCell = cell as! EaseBaseMessageCell
                }
                let idSt: String = (model.message.from)!
                let idInt: Int = Int(idSt)!
                if TSDatabaseManager().user.get(idInt) != nil {
                    model.nickname = TSDatabaseManager().user.get(idInt)?.name
                    model.avatarURLPath = TSUtil.praseTSNetFileUrl(netFile: TSDatabaseManager().user.get(idInt)?.avatar)
                    if TSDatabaseManager().user.get(idInt)?.avatar == nil {
                        if TSDatabaseManager().user.get(idInt)?.sex == 1 {
                            model.avatarImage = UIImage(named: "IMG_pic_default_man")
                        } else if TSDatabaseManager().user.get(idInt)?.sex == 2 {
                            model.avatarImage = UIImage(named: "IMG_pic_default_woman")
                        } else {
                            model.avatarImage = UIImage(named: "IMG_pic_default_secret")
                        }
                    }
//                    if tsHelper {
//                        model.avatarImage = UIImage.init(named: "ico_ts_assistant")
//                    }
                    let iconString: String = TSDatabaseManager().user.get(idInt)?.verified?.icon ?? ""
                    let iconType: String = TSDatabaseManager().user.get(idInt)?.verified?.type ?? ""
                    model.authenticationIcon = iconString
                    model.authenticationType = iconType
                    sendCell.model = model
                    sendCell.delegate = self
                    if model.isSender {
                        sendCell.iconView.frame = CGRect(x: ScreenWidth - 10 - 40 * 0.35, y: 10 + 40 * 0.65, width: 40 * 0.35, height: 40 * 0.35)
                    } else {
                        sendCell.iconView.frame = CGRect(x: 10 + 40 * 0.65, y: 10 + 40 * 0.65, width: 40 * 0.35, height: 40 * 0.35)
                    }
                    if iconType == "" {
                        sendCell.iconView.isHidden = true
                    } else {
                        sendCell.iconView.isHidden = false
                        if iconString.isEmpty {
                            switch iconType {
                            case "user":
                                sendCell.iconView.image = UIImage(named: "IMG_pic_identi_individual")
                            case "org":
                                sendCell.iconView.image = UIImage(named: "IMG_pic_identi_company")
                            default:
                                sendCell.iconView.image = UIImage(named: "")
                            }
                        } else {
                            let urlString = iconString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                            let iconURL = URL(string: urlString ?? "")
                            sendCell.iconView.kf.setImage(with: iconURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                        }
                    }
                    sendCell.iconView.layer.cornerRadius = 40 * 0.35 / 2.0
                    return sendCell
                } else {
                    TSUserNetworkingManager().getUsersInfo(usersId: [idInt], complete: { (usermodel, textString, succuce) in
                        if succuce && usermodel?.count != nil {
                            let userInfo: TSUserInfoModel = usermodel![0]
//                            if tsHelper {
//                                model.nickname = TSDatabaseManager().user.get(idInt)?.name
//                                model.avatarImage = UIImage.init(named: "ico_ts_assistant")
//                            } else {
//                                model.avatarURLPath = userInfo.avatar
//                            }
                            model.avatarURLPath = TSUtil.praseTSNetFileUrl(netFile:userInfo.avatar)
                            model.nickname = userInfo.name
                            TSDatabaseManager().user.saveUserInfo(userInfo)
                            sendCell.model = model
                        }
                    })
                    sendCell.delegate = self
                    return sendCell
                }
            } else if cell is TSMessageShareInfoCell {
                let cellIdentifier = "TSMessageShareInfoCell"
                var sendCell: TSMessageShareInfoCell
                if tableView.dequeueReusableCell(withIdentifier: cellIdentifier) == nil {
                    sendCell = TSMessageShareInfoCell(style: .default, reuseIdentifier: cellIdentifier)
                    sendCell.selectionStyle = UITableViewCellSelectionStyle.none
                } else {
                    sendCell = cell as! TSMessageShareInfoCell
                }
                sendCell.delegate = self
                let idSt: String = (model.message.from)!
                let idInt: Int = Int(idSt)!
                if TSDatabaseManager().user.get(idInt) != nil {
                    model.nickname = TSDatabaseManager().user.get(idInt)?.name
                    model.avatarURLPath = TSUtil.praseTSNetFileUrl(netFile:TSDatabaseManager().user.get(idInt)?.avatar)
                    if TSDatabaseManager().user.get(idInt)?.avatar == nil {
                        if TSDatabaseManager().user.get(idInt)?.sex == 1 {
                            model.avatarImage = UIImage(named: "IMG_pic_default_man")
                        } else if TSDatabaseManager().user.get(idInt)?.sex == 2 {
                            model.avatarImage = UIImage(named: "IMG_pic_default_woman")
                        } else {
                            model.avatarImage = UIImage(named: "IMG_pic_default_secret")
                        }
                    }
                    //                    if tsHelper {
                    //                        model.avatarImage = UIImage.init(named: "ico_ts_assistant")
                    //                    }
                    let iconString: String = TSDatabaseManager().user.get(idInt)?.verified?.icon ?? ""
                    let iconType: String = TSDatabaseManager().user.get(idInt)?.verified?.type ?? ""
                    model.authenticationIcon = iconString
                    model.authenticationType = iconType
                    sendCell.updataInfoModel(model)
                    if iconType == "" {
                        sendCell.userIconView.isHidden = true
                    } else {
                        sendCell.userIconView.isHidden = false
                        if iconString.isEmpty {
                            switch iconType {
                            case "user":
                                sendCell.userIconView.image = UIImage(named: "IMG_pic_identi_individual")
                            case "org":
                                sendCell.userIconView.image = UIImage(named: "IMG_pic_identi_company")
                            default:
                                sendCell.userIconView.image = UIImage(named: "")
                            }
                        } else {
                            let urlString = iconString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                            let iconURL = URL(string: urlString ?? "")
                            sendCell.userIconView.kf.setImage(with: iconURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                        }
                    }
                    return sendCell
                } else {
                    TSUserNetworkingManager().getUsersInfo(usersId: [idInt], complete: { (usermodel, textString, succuce) in
                        if succuce && usermodel?.count != nil {
                            let userInfo: TSUserInfoModel = usermodel![0]
                            model.avatarURLPath = TSUtil.praseTSNetFileUrl(netFile: userInfo.avatar)
                            model.nickname = userInfo.name
                            TSDatabaseManager().user.saveUserInfo(userInfo)
                            sendCell.updataInfoModel(model)
                        }
                    })
//                    sendCell.delegate = self
                    return sendCell
                }
            }
            else if cell is EaseCallRecordMessageCell {
                let cellIdentifier = String(EaseCallRecordMessageCell.cellIdentifier(withModel: model))
                var sendCell: EaseCallRecordMessageCell
                if tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) == nil {
                    sendCell = EaseCallRecordMessageCell(style: .default, reuseIdentifier: cellIdentifier, model: model)
                    sendCell.selectionStyle = UITableViewCellSelectionStyle.none
                } else {
                    sendCell = cell as! EaseCallRecordMessageCell
                }
                let idSt: String = (model.message.from)!
                let idInt: Int = Int(idSt)!
//                sendCell.callTagImage.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20)
                if TSDatabaseManager().user.get(idInt) != nil {
                    model.nickname = TSDatabaseManager().user.get(idInt)?.name
                    model.avatarURLPath = TSUtil.praseTSNetFileUrl(netFile: TSDatabaseManager().user.get(idInt)?.avatar)
                    if TSDatabaseManager().user.get(idInt)?.avatar == nil {
                        if TSDatabaseManager().user.get(idInt)?.sex == 1 {
                            model.avatarImage = UIImage(named: "IMG_pic_default_man")
                        } else if TSDatabaseManager().user.get(idInt)?.sex == 2 {
                            model.avatarImage = UIImage(named: "IMG_pic_default_woman")
                        } else {
                            model.avatarImage = UIImage(named: "IMG_pic_default_secret")
                        }
                    }
                    let iconString: String = TSDatabaseManager().user.get(idInt)?.verified?.icon ?? ""
                    let iconType: String = TSDatabaseManager().user.get(idInt)?.verified?.type ?? ""
                    model.authenticationIcon = iconString
                    model.authenticationType = iconType
                    sendCell.model = model
                    sendCell.delegate = self
                    if model.isSender {
                        sendCell.iconView.frame = CGRect(x: ScreenWidth - 10 - 40 * 0.35, y: 10 + 40 * 0.65, width: 40 * 0.35, height: 40 * 0.35)
                    } else {
                        sendCell.iconView.frame = CGRect(x: 10 + 40 * 0.65, y: 10 + 40 * 0.65, width: 40 * 0.35, height: 40 * 0.35)
                    }
                    if iconType == "" {
                        sendCell.iconView.isHidden = true
                    } else {
                        sendCell.iconView.isHidden = false
                        if iconString.isEmpty {
                            switch iconType {
                            case "user":
                                sendCell.iconView.image = UIImage(named: "IMG_pic_identi_individual")
                            case "org":
                                sendCell.iconView.image = UIImage(named: "IMG_pic_identi_company")
                            default:
                                sendCell.iconView.image = UIImage(named: "")
                            }
                        } else {
                            let resize = ResizingImageProcessor(referenceSize: sendCell.iconView.frame.size, mode: .aspectFit)
                            let urlString = iconString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                            let iconURL = URL(string: urlString ?? "")
                            sendCell.iconView.kf.setImage(with: iconURL, placeholder: nil, options: [.processor(resize)], progressBlock: nil, completionHandler: nil)
                        }
                    }
                    sendCell.iconView.layer.cornerRadius = 40 * 0.35 / 2.0
                    return sendCell
                } else {
                    TSUserNetworkingManager().getUsersInfo(usersId: [idInt], complete: { (usermodel, textString, succuce) in
                        if succuce && usermodel?.count != nil {
                            let userInfo: TSUserInfoModel = usermodel![0]
//                            if tsHelper {
//                                model.nickname = TSDatabaseManager().user.get(idInt)?.name
//                                model.avatarImage = UIImage.init(named: "ico_ts_assistant")
//                            } else {
//                                model.avatarURLPath = userInfo.avatar
//                            }
                            model.avatarURLPath = TSUtil.praseTSNetFileUrl(netFile: userInfo.avatar)
                            model.nickname = userInfo.name
                            TSDatabaseManager().user.saveUserInfo(userInfo)
                            sendCell.model = model
                        }
                    })
                    sendCell.delegate = self
                    return sendCell
                }
            } else if cell is EaseMessageTimeCell {
                let cellIdentifier = String(EaseMessageTimeCell.cellIdentifier())
                var timeCell: EaseMessageTimeCell
                if tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) == nil {
                    timeCell = EaseMessageTimeCell(style: .default, reuseIdentifier: cellIdentifier)
                    timeCell.selectionStyle = UITableViewCellSelectionStyle.none
                } else {
                    timeCell = cell as! EaseMessageTimeCell
                }
                timeCell.title = model.text
                // 系统通知的左右最远位置为头像的X轴中心点
                let maxTitileWidth = ScreenWidth - (10 + 40 / 2.0) * 2
                // bgLabel top bottom均为3
                let titleHeight = timeCell.title.heightWithConstrainedWidth(width: maxTitileWidth, font: UIFont.systemFont(ofSize: 10)) + 3 * 2
                var titleWidth: CGFloat = timeCell.title.sizeOfString(usingFont: UIFont.systemFont(ofSize: 10)).width + 5 * 2
                // 如果title超过屏幕宽度就按照左右10pt计算
                titleWidth = titleWidth > maxTitileWidth ? maxTitileWidth : titleWidth
                timeCell.bgLabel.frame = CGRect(x: (ScreenWidth - titleWidth) / 2.0, y: 5, width: titleWidth, height: titleHeight)
                timeCell.bgLabel.backgroundColor = UIColor(hex: 0xd9d9d9)
                return timeCell
            } else if cell is EaseMessageActionStringCell {
                let cellIdentifier = String(EaseMessageActionStringCell.cellIdentifier())
                var actionStringCell: EaseMessageActionStringCell
                if tableView.dequeueReusableCell(withIdentifier: cellIdentifier!) == nil {
                    actionStringCell = EaseMessageActionStringCell(style: .default, reuseIdentifier: cellIdentifier)
                    actionStringCell.selectionStyle = UITableViewCellSelectionStyle.none
                } else {
                    actionStringCell = cell as! EaseMessageActionStringCell
                }
                actionStringCell.noticeLabel.centerX = ScreenWidth / 2.0
                actionStringCell.noticeLabel.centerY = 30 / 2.0
                actionStringCell.noticeLabel.backgroundColor = UIColor(hex: 0xd9d9d9)
                actionStringCell.actionBtn.centerX = ScreenWidth / 2.0 - 22 / 2.0
                actionStringCell.actionBtn.centerY = 30 / 2.0
                return actionStringCell
            } else {
                return super.tableView(self.tableView, cellForRowAt: indexPath)
            }
        }
    }
    override func statusButtonSelcted(_ model: IMessageModel!, with messageCell: EaseMessageCell!) {
        if model.messageStatus != EMMessageStatusFailed && model.messageStatus != EMMessageStatusPending {
            return
        }
        weak var weakSelf = self
        EMClient.shared().chatManager.resend(model.message, progress: { (nil) in

        }) { (message, error) in
            if error == nil {
                weakSelf?.refresh(afterSentMessage: message)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "sendMessageReloadChatListVc"), object: nil)
            } else {
                weakSelf?.tableView.reloadData()
            }
        }
        self.tableView.reloadData()
    }

    // MARK: - 头像点击事件
    override func avatarViewSelcted(_ model: IMessageModel!) {
        // 头像默认点击事件
        let idSt: String = (model.message.from)!
        let idInt: Int = Int(idSt)!
        if idSt.isEmpty {
            return
        } else {
            NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": idInt])
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updataGroupInfo), name: Notification.Name(rawValue: "editgroupnameorimage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAllOtherVC), name: Notification.Name(rawValue: "singleChatSwithGroup"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenHide(notice:)), name: NSNotification.Name(rawValue: "hidescreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updataGroupInfo), name: Notification.Name.Chat.uploadLocGrupInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getGroupInfo), name: Notification.Name.Chat.uploadGrupInfo, object: nil)
        EMClient.shared().groupManager.add(self as EMGroupManagerDelegate, delegateQueue: nil)
        roomTitleLab = TSLabel(frame: CGRect(x: 90, y: 0, width: ScreenWidth - 90 * 2, height: 40))
        roomTitleLab.font = UIFont.systemFont(ofSize: TSFont.Navigation.headline.rawValue)
        if self.groupOriginData.count != 0 {
            let roomName = self.groupOriginData["name"] as! String
            let memberCount = self.groupOriginData["affiliations_count"] as! Int?
            roomTitleLab.text = roomName + "(\(memberCount!))"
        } else {
            roomTitleLab.text = self.chatTitle
        }
        /// 传递给基类的聊天室标题
        self.roomTitle = roomTitleLab.text
        /// 监听标题的变化
        self.roomTitleLab.addObserverBlock(forKeyPath: "text") { (obj, oldValue, newValue) in
            self.roomTitle = newValue as? String
            self.chatTitle = newValue as? String
        }

        roomTitleLab.textAlignment = .center
        roomTitleLab.lineBreakMode = .byTruncatingMiddle
        self.navigationController?.navigationBar.addSubview(roomTitleLab)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "topbar_back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        self.navigationItem.leftItemsSupplementBackButton = true
        let chatItem = UIButton(type: .custom)
        chatItem.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.setupNavigationTitleItem(chatItem, title: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: chatItem)
        self.screenImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.screenImage.image = UIImage(named: "ico_details_shield")
        self.chatButton = chatItem
        self.chatButton.setImage(UIImage(named: "IMG_topbar_more_black"), for: UIControlState.normal)
        self.chatButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.chatButton.width - (self.chatButton.currentImage?.size.width)!, bottom: 0, right: 0)
        self.screenImage.centerY = self.chatButton.frame.size.height / 2.0
        self.screenImage.centerX = self.chatButton.width - (self.chatButton.currentImage?.size.width)! - 12 - 18
        self.chatButton.addSubview(self.screenImage)
        self.screenImage.isHidden = self.hidScreen

        removeChatFriendListVC()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        roomTitleLab.removeFromSuperview()
        /// 注销仅在当前页面接收的通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Chat.clickEditGroupBtn, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Chat.tapChatDetailImage, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Chat.showNotice, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if roomTitleLab.superview == nil {
            self.navigationController?.navigationBar.addSubview(roomTitleLab)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.conversation == nil {
            TSIndicatorWindowTop.showDefaultTime(state: .faild, title: "当前聊天已经不存在")
            self.navigationController?.popViewController(animated: true)
            return
        } else if self.conversation.type == EMConversationTypeGroupChat && self.groupOriginData.count == 0 {
            /// 当前为群聊，并且没有群信息-->从TS服务器拉取
            self.getGroupInfo()
        }
        if self.image != nil && self.sendSuccess == false {
            self.sendLocationV2Latitude(Double(self.latitude), longitude: Double(self.longitude), address: self.address, title: self.titleStr, image: image, uid: self.uid)
            self.sendSuccess = true
        }
        /// 添加仅在当前页面接收的通知
        NotificationCenter.default.addObserver(self, selector: #selector(notiResDidClickEditGroupActionBtn(noti:)), name: NSNotification.Name.Chat.clickEditGroupBtn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notiResShowImageViewBrower(noti:)), name: NSNotification.Name.Chat.tapChatDetailImage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showIndicatorWindowTop(noti:)), name: Notification.Name.Chat.showNotice, object: nil)
    }
    func removeChatFriendListVC() {
        for (index, vc) in (self.navigationController?.viewControllers)!.enumerated() {
            if vc is TSChatFriendListViewController {
                self.navigationController?.viewControllers.remove(at: index)
            }
        }
    }

    // MARK: - 移除掉单聊、单聊信息、单聊转换群聊选择好友页面（目的就是为了单聊转换到群聊之后创建群聊成功之后进入群聊天详情页时候，返回是返回到会话列表 的效果）
    func removeAllOtherVC() {
        popToRootVC = true
    }

    // MARK: - 右上角按钮点击事件
    func rightButtonClick() {
        if self.conversation.type == EMConversationTypeGroupChat {
//            vc.originData = NSMutableDictionary.init(dictionary: self.groupOriginData)
            let vc = TSGroupDataViewController()
            vc.conversationID = self.conversation.conversationId
            vc.chatType = self.conversation.type
            vc.currentConversattion = self.conversation
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.conversation.type == EMConversationTypeChat {
            let vc = TSSingleChatDataVC()
            vc.currentConversattion = self.conversation
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            return
        }
    }

    func setupNavigationTitleItem(_ button: UIButton, title: String?) -> Void {
        let font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(TSColor.main.theme, for: .normal)
        button.titleLabel?.font = font
        button.setTitle(title, for: .normal)
        // Remark: - 关于这里的长度，应重新设计一下，特别是牵扯到右侧可能有音乐图标时
        // 音乐图标包括在内,导航栏右侧按钮做多只能出现3个
        if let size = title?.size(maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), font: font) {
            button.bounds = CGRect(x: 0, y: 0, width: size.width + 10, height: 44)
        } else {
            button.bounds = CGRect(x: 0, y: 0, width: TSViewRightCustomViewUX.MaxWidth, height: 44)
        }
    }

    func updataGroupInfo(notice: Notification) {
        let dict = notice.object as? NSDictionary
        let noticeType = "\(dict!["changeType"] ?? "")"
        if noticeType == "name" {
            var noticeName = "\(dict!["name"] ?? "")"
            if self.groupOriginData != nil, let numberCount = self.groupOriginData["affiliations_count"] {
                noticeName = noticeName + "(\(numberCount))"
                self.roomTitleLab.text = noticeName
            } else {
                    self.getGroupInfo()
            }
        } else if noticeType == "groupInfo" {
            self.groupOriginData = dict!["groupInfo"] as! NSDictionary
            let roomName = self.groupOriginData["name"] as! String
            let memberCount = self.groupOriginData["affiliations_count"] as! Int?
            roomTitleLab.text = roomName + "(\(memberCount!))"
        }
    }

    func goBack() {
        if popToRootVC {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    override func urlTouch(_ urlString: String!) {
        TSUtil.pushURLDetail(url: URL(string: urlString)!, currentVC: self)
    }

    func screenHide(notice: NSNotification) {
        let dict = notice.object as? NSDictionary
        let hideString = "\(dict!["hidescreen"] ?? "")"
        let noticeId = "\(dict!["id"] ?? "")"
        if noticeId == self.conversation.conversationId {
            if hideString == "1" {
                self.screenImage.isHidden = true
            } else if hideString == "0" {
                self.screenImage.isHidden = false
            }
        }
    }
    // MARK: - 显示图片查看器
    // 用于聊天详情查看大图
    func notiResShowImageViewBrower(noti: NSNotification) {
        self.view.endEditing(true)
        // Image信息组
        let imageInfoArray = noti.object as! NSArray
        // TSImage
        var tsImageObjectArray: [TSImageObject] = Array()
        // Image
        var imageObjectArray: [UIImage] = Array()
        // Frame
        var framesObjectArray: [CGRect] = Array()
        for item in imageInfoArray {
            let imageItemDiction = item as! NSDictionary

            let imageItem = imageItemDiction["image"] as! UIImage
            let frameStr = imageItemDiction["frame"]  as! String
            let imageItemFrame = CGRectFromString(frameStr)

            let imageObject = imageItem.imageToTSImageObject()
            imageObjectArray.append(imageItem)
            tsImageObjectArray.append(imageObject)
            framesObjectArray.append(imageItemFrame)
        }
        let imagePreviewVC = TSPicturePreviewVC(objects: tsImageObjectArray, imageFrames: framesObjectArray, images: imageObjectArray as [UIImage?], At: 0)
        imagePreviewVC.show()
    }
    // MARK: - 点击了 快速编辑群名称，开启群聊 按钮
    // 那边是环信的objective-c SDK
    func notiResDidClickEditGroupActionBtn(noti: NSNotification) {
        let alert = TSAlertController(title: "编辑群名称", message: nil, style: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "编辑群名称，2-15个字符"
        })
        alert.addAction(TSAlertAction(title: "取消", style: .theme, handler: { (action) in
        }))
        alert.addAction(TSAlertAction(title: "确定", style: .theme, handler: { (action) in
            let textField = alert.textFields?.first
            var name = textField?.text
            name = name?.replacingOccurrences(of: " ", with: "")
            if (name?.count)! > 1 && (name?.count)! < 16 {
                self.editGroupName(name: name!)
            } else {
                let resultAlert = TSIndicatorWindowTop(state: .faild, title: "请输入2-15个字符")
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            }
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
    }
    override func messageViewController(_ viewController: EaseMessageViewController!, didTapLocationCardInfo locationInfo: [AnyHashable : Any]!, image: UIImage!) {
        if let title = locationInfo["title"] as? String, let address: String = locationInfo["address"] as? String, let latitude = locationInfo["latitude"] as? String, let longitude = locationInfo["longitude"] as? String {
            let showLocationVC = TSShowLocationVC()
            showLocationVC.longitude = Float(longitude)!
            showLocationVC.latitude = Float(latitude)!
            showLocationVC.titleStr = title
            showLocationVC.address = address
            showLocationVC.image = image
            showLocationVC.currentConversattion = self.conversation
            self.navigationController?.pushViewController(showLocationVC, animated: true)
    }
    }
    /// 修改群名称
    func editGroupName(name: String) {
        /// 准备需要的参数
        let groupName = name
        let groupid = self.conversation.conversationId!
        let desc = "还没填写任何群简介"
        let ispublic = "0"
        let maxusers = "300"
        let menbers_only = "0"

        TSAccountNetworkManager().changeHyGroup(groupid: groupid, groupname: groupName, desc: desc, ispublic: ispublic, maxusers: maxusers, menbers_only: menbers_only, allowinvites: "", group_face: "") { (data, status) in
            guard status else {
                return
            }
            var groupInfo = [String: Any]()
            groupInfo.updateValue(groupid, forKey: "id")
            groupInfo.updateValue(groupName, forKey: "name")
            groupInfo.updateValue("name", forKey: "changeType")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "editgroupnameorimage"), object: groupInfo)
        }
    }
    // MARK: - 请求群信息
    func getGroupInfo() {
        TSAccountNetworkManager().getHyGroupInfo(groupid: self.conversation.conversationId, complete: { (response, result) in
            guard result else {
                return
            }
            if let responseArray = response {
                let dict = responseArray[0] as? NSDictionary
                self.groupOriginData = NSMutableDictionary(dictionary: dict!)
                let roomName = self.groupOriginData["name"] as! String
                let memberCount = self.groupOriginData["affiliations_count"] as! Int?
                self.roomTitleLab.text = roomName + "(\(memberCount!))"
            }
        })
    }

     func didReceiveLeavedGroup(_ aGroup: EMGroup!, reason aReason: EMGroupLeaveReason) {
        /// 已经不在当前聊天哪
        /// 如果当前页在显示，就pop出去
        /// 如果没有未显示就等待返回后提示并pop
        self.conversation = nil
        if self.navigationController?.viewControllers.last == self {
            self.navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - 显示顶部弹窗提示
    func showIndicatorWindowTop(noti: Notification) {
        let noticeDic = noti.object as? Dictionary<String, String>
        let noticeStr = noticeDic!["msg"]
        let resultAlert = TSIndicatorWindowTop(state: .faild, title: noticeStr)
        resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func didTap(_ cell: TSMessageShareInfoCell!, model: IMessageModel!) {
        // 点击了分享的卡片，直接处理跳转事件
        let typeStr = model.message.ext["letter"] as? String
        let shareIDStr = model.message.ext["letter_id"] as? String
        let groupIDStr = model.message.ext["circle_id"] as? String
        if let type = typeStr, let shareId = shareIDStr, let shareID = Int(shareId) {
            if type == "dynamic" {
                // 动态
                let detailVC = TSCommetDetailTableView(feedId: shareID)
                self.navigationController?.pushViewController(detailVC, animated: true)
            } else if type == "info" {
                // 资讯
                let infoVC = TSNewsCommentController(newsId: shareID)
                self.navigationController?.pushViewController(infoVC, animated: true)
            } else if type == "circle" {
                // 圈子
                let groupVC = GroupDetailVC(groupId: shareID)
                self.navigationController?.pushViewController(groupVC, animated: true)
            } else if type == "post" {
                // 帖子
                if let groupId = groupIDStr, let groupID = Int(groupId) {
                    let postDetailVC = TSPostCommentController(groupId: groupID, postId: shareID)
                    self.navigationController?.pushViewController(postDetailVC, animated: true)
                }
            } else if type == "questions" {
                let questionDetailVC = TSQuestionDetailController()
                questionDetailVC.questionId = shareID
                self.navigationController?.pushViewController(questionDetailVC, animated: true)
            } else if type == "question-answers" {
                let answerDetailVC = TSAnswerDetailController(answerId: shareID)
                self.navigationController?.pushViewController(answerDetailVC, animated: true)
            }
        }
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
