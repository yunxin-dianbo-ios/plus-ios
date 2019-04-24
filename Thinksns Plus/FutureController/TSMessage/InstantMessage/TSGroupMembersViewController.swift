//
//  TSGroupMembersViewController.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/23.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher
import ObjectMapper

/// 群成员头像宽高
private let gHeight: CGFloat = 50
/// 群成员布局左右间距
private let space: CGFloat = 15
/// 群成员头像之间间距
private let gSpace: CGFloat = (ScreenWidth - gHeight * 5 - space * 2) / 4.0
/// 每一个头像所需高度
private let faceHeight: CGFloat = 50 + 14 + 10 + 20
private var firstLineUserCount: Int = 3 //首行的用户数量，群主显示2+3个 普通用户1+4个
private var isGroupOwner: Bool = false

class TSGroupMembersViewController: TSViewController {

    var backScrollView = UIScrollView()
    var membersView = UIView()
    var membersViewHeight: CGFloat = 94//(50 + 14 + 10 + 20)

    var originData = NSMutableDictionary()
    /// 里面装的应该是 TS+ 的用信息模型类的元素
    var groupMembers = NSMutableArray()
    /// 当前操作之前的群 ID
    var currenGroupId: String? = ""
    /// 当前操作之前的群 ID
    var currentAddOrDelete: String? = ""

    /// 屏幕比例
    let scale = UIScreen.main.scale
    /// 重绘大小的配置
    var resizeProcessor: ResizingImageProcessor {
        let avatarImageSize = CGSize(width: gHeight * scale, height: gHeight * scale)
        return ResizingImageProcessor(referenceSize: avatarImageSize, mode: .aspectFill)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "全部成员"
        NotificationCenter.default.addObserver(self, selector: #selector(reloadGroupMemberInfo), name: NSNotification.Name(rawValue: "reloadgroupmemberdata"), object: nil)
        let groupUsers = NSMutableArray(array: (originData.object(forKey: "affiliations") as? NSArray)!)
        groupMembers.removeAllObjects()
        groupMembers.addObjects(from: Mapper<TSUserInfoModel>().mapArray(JSONObject: groupUsers)!)
        //初始化群主信息
        let memberId = self.originData["owner"]
        if Int(memberId as! String) == TSCurrentUserInfo.share.userInfo?.userIdentity {
            isGroupOwner = true
            firstLineUserCount = 3
        } else {
            isGroupOwner = false
            firstLineUserCount = 4
        }
        canculateHeight()
        creatSubView()
        // Do any additional setup after loading the view.
    }

    func creatSubView() {
        backScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        backScrollView.backgroundColor = UIColor(hex: 0xf4f5f5)
        backScrollView.showsHorizontalScrollIndicator = false
        backScrollView.showsVerticalScrollIndicator = true
        backScrollView.isScrollEnabled = true
        backScrollView.contentSize = CGSize(width: ScreenWidth, height: ScreenHeight * 2)
        self.view.addSubview(backScrollView)
        membersView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: membersViewHeight))
        membersView.backgroundColor = UIColor.white
        backScrollView.addSubview(membersView)
        setMembersUI()
    }

    // MARK: - 布局成员UI
    func setMembersUI() {
        membersView.removeAllSubViews()
        let memberId = self.originData["owner"]
        /// 添加按钮
        let addButton = UIButton(frame: CGRect(x: 15, y: 20, width: gHeight, height: gHeight))
        addButton.backgroundColor = UIColor(hex: 0xf2f2f2)
        addButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = gHeight / 2.0
        addButton.tag = 333
        addButton.setImage(UIImage(named: "btn_chatdetail_add"), for: .normal)
        membersView.addSubview(addButton)
        addButton.addTarget(self, action: #selector(addMember), for: UIControlEvents.touchUpInside)

        /// 删除按钮
        let deleteButton = UIButton(frame: CGRect(x: addButton.right + gSpace, y: 20, width: gHeight, height: gHeight))
        deleteButton.backgroundColor = UIColor(hex: 0xf2f2f2)
        deleteButton.layer.masksToBounds = true
        deleteButton.layer.cornerRadius = gHeight / 2.0
        deleteButton.tag = 555
        deleteButton.setImage(UIImage(named: "btn_chatdetail_reduce"), for: .normal)
        membersView.addSubview(deleteButton)
        deleteButton.addTarget(self, action: #selector(deleteMember), for: UIControlEvents.touchUpInside)

        if isGroupOwner == false {
            // 当前登录用户不是管理员,不添加删除按钮
            deleteButton.frame = CGRect(x: addButton.right, y: 20, width: 0.01, height: gHeight)
            deleteButton.isHidden = true
        }
        for (index, item) in groupMembers.enumerated() {
            let userInfo = item as? TSUserInfoModel
            var width = CGFloat(index % 5) * gHeight
            var buttonX = space + width + CGFloat((index - firstLineUserCount) % 5) * gSpace
            /// 第一排布局头像x坐标
            let firstLineButtonX = gSpace * CGFloat(index + 1) + width
//            /// 第一排之后的布局头像x坐标
//            let otherWidth = CGFloat(index % 5) * gHeight
//            let otherButtonX = space + otherWidth + CGFloat(index) * gSpace

            let faceButton = UIButton(frame: CGRect(x: buttonX, y: 20 + CGFloat(index / 5) * faceHeight, width: gHeight, height: gHeight))
            faceButton.addTarget(self, action: #selector(interUsersHomePage(btn:)), for: .touchUpInside)
            if index < firstLineUserCount {
                faceButton.frame = CGRect(x: deleteButton.right + firstLineButtonX, y: 20, width: gHeight, height: gHeight)
            } else {
                width = CGFloat((index - firstLineUserCount) % 5) * gHeight
                buttonX = space + width + CGFloat((index - firstLineUserCount) % 5) * gSpace
                faceButton.frame = CGRect(x: buttonX, y: 20 + CGFloat((index - firstLineUserCount) / 5) * faceHeight + faceHeight, width: gHeight, height: gHeight)
            }
            faceButton.backgroundColor = UIColor(hex: 0xf4f5f5)
            faceButton.layer.masksToBounds = true
            faceButton.layer.cornerRadius = gHeight / 2.0
            faceButton.tag = index + 666
            if userInfo?.avatar != nil {
                faceButton.kf.setImage(with: URL(string:TSUtil.praseTSNetFileUrl(netFile:userInfo?.avatar) ?? ""), for: .normal, placeholder: UIImage(named: "IMG_pic_default_secret"), options: [.processor(resizeProcessor)], progressBlock: nil, completionHandler: nil)
            } else {
                if userInfo?.sex == 1 {
                    faceButton.setImage(UIImage(named: "IMG_pic_default_man"), for: .normal)
                } else if userInfo?.sex == 2 {
                    faceButton.setImage(UIImage(named: "IMG_pic_default_woman"), for: .normal)
                } else {
                    faceButton.setImage(UIImage(named: "IMG_pic_default_secret"), for: .normal)
                }
            }
            membersView.addSubview(faceButton)
            let iconImage: UIImageView = UIImageView(frame: CGRect(x: faceButton.left + faceButton.frame.width * 0.65, y: faceButton.top + faceButton.frame.width * 0.65, width: faceButton.frame.width * 0.35, height: faceButton.frame.width * 0.35))
            iconImage.layer.masksToBounds = true
            iconImage.layer.cornerRadius = faceButton.frame.width * 0.35 / 2.0
            if userInfo?.verified?.type == "" {
                iconImage.isHidden = true
            } else {
                iconImage.isHidden = false
                if userInfo?.verified?.icon == "" {
                    switch userInfo?.verified?.type {
                    case "user"?:
                        iconImage.image = UIImage(named: "IMG_pic_identi_individual")
                    case "org"?:
                        iconImage.image = UIImage(named: "IMG_pic_identi_company")
                    default:
                        iconImage.image = UIImage(named: "")
                    }
                } else {
                    let urlString = userInfo?.verified?.icon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    let iconURL = URL(string: urlString ?? "")
                    iconImage.kf.setImage(with: iconURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                }
            }
            membersView.addSubview(iconImage)

            if userInfo?.userIdentity == Int("\(memberId ?? "")") {
                /// 宽36 高16 fca308 10字体
                let groupOwnerLabel = UILabel(frame: CGRect(x: 0, y: faceButton.top, width: 36, height: 16))
                groupOwnerLabel.layer.masksToBounds = true
                groupOwnerLabel.layer.cornerRadius = 16 / 2.0
                groupOwnerLabel.backgroundColor = UIColor(hex: 0xfca308)
                groupOwnerLabel.textColor = UIColor.white
                groupOwnerLabel.font = UIFont.systemFont(ofSize: 10)
                groupOwnerLabel.textAlignment = .center
                groupOwnerLabel.text = "群主"
                groupOwnerLabel.centerX = faceButton.centerX
                membersView.addSubview(groupOwnerLabel)
            }

            let nameLabel = UILabel(frame: CGRect(x: 0, y: faceButton.bottom + 10, width: gHeight, height: 14))
            nameLabel.text = "\(userInfo?.name ?? "")"
            nameLabel.textAlignment = NSTextAlignment.center
            nameLabel.font = UIFont.systemFont(ofSize: 12)
            nameLabel.textColor = UIColor(hex: 0x999999)
            nameLabel.centerX = faceButton.centerX
            membersView.addSubview(nameLabel)
        }
        updataScrollViewContentSize()
    }

    // MARK: - 计算布局群成员头像所需要的高度(仅仅是群成员头像+增删按钮)
    func canculateHeight() {
        if groupMembers.count > 0 {
            membersViewHeight = faceHeight * CGFloat(groupMembers.count / 5) + faceHeight * (groupMembers.count % 5 > firstLineUserCount ? 2 : 1) + 20
        } else {
            membersViewHeight = 94
        }
    }

    // MARK: - 调整 scrollview 的 contentsize
    func updataScrollViewContentSize() {
        if membersView.bottom > ScreenHeight {
            backScrollView.contentSize = CGSize(width: ScreenWidth, height: membersView.bottom)
        } else {
            backScrollView.contentSize = CGSize(width: ScreenWidth, height: ScreenHeight)
        }
    }

    // MARK: - 添加成员
    func addMember() {
        let vc = TSChatFriendListViewController()
        vc.ischangeGroupMember = "add"
        vc.originDataSource = self.groupMembers
        vc.currenGroupId = self.currenGroupId
        navigationController?.pushViewController(vc, animated: true)
        currentAddOrDelete = "add"
    }

    // MARK: - 删除成员
    func deleteMember() {
        let ownerId = self.originData["owner"]
        let groupOwnerID = "\(ownerId ?? "")"
        guard TSCurrentUserInfo.share.userInfo?.userIdentity == Int(groupOwnerID) else {
            return
        }
        let vc = TSChatFriendListViewController()
        vc.ischangeGroupMember = "delete"
        vc.originDataSource = NSMutableArray(array: self.groupMembers)
        vc.currenGroupId = self.currenGroupId
        vc.dataSource = self.groupMembers as! [TSUserInfoModel]
        vc.ownerId = groupOwnerID
        navigationController?.pushViewController(vc, animated: true)
        currentAddOrDelete = "delete"
    }

    // MARK: - 刷新群成员的数据再布局ui
    func reloadGroupMemberInfo(notice: Notification) {
        let dict = notice.object as? NSDictionary
        let changedMember = dict!["members"] as? NSMutableArray
        for (_, item) in (changedMember?.enumerated())! {
            let userInfo = item as? TSUserInfoModel
            guard currentAddOrDelete != "" else {
                return
            }
            if currentAddOrDelete == "add" {
                groupMembers.add(userInfo as Any)
            } else if currentAddOrDelete == "delete" {
                for (originIndex, originItem) in groupMembers.enumerated().reversed() {
                    let originUserInfo = originItem as? TSUserInfoModel
                    if userInfo?.userIdentity == originUserInfo?.userIdentity {
                        groupMembers.removeObject(at: originIndex)
                    }
                }
            }
        }
        self.view.removeAllSubViews()
        canculateHeight()
        creatSubView()
    }
    // MARK: - 进去个人中心
    func interUsersHomePage(btn: Button) {
        let userInfo = groupMembers[btn.tag - 666] as! TSUserInfoModel
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": userInfo.userIdentity])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
