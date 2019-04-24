//
//  TSGroupDataViewController.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/22.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher
import ObjectMapper
import Photos
import TZImagePickerController

/// 群成员头像宽高
private let gHeight: CGFloat = 50
/// 群成员布局左右间距
private let space: CGFloat = 15
/// 群成员头像之间间距
private let gSpace: CGFloat = (ScreenWidth - gHeight * 5 - space * 2) / 4.0
/// 每一个头像所需高度
private let faceHeight: CGFloat = 50 + 14 + 10 + 20

class TSGroupDataViewController: TSViewController, TZImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var backScrollView = UIScrollView()

    var groupImageViewBg = UIView()
    var groupImageLabel = UILabel()
    var groupImageView = UIImageView()
    var changeImageButton = UIButton()

    var groupTitleBg = UIView()
    var groupTitleLabel = UILabel()
    var groupTitleL = UILabel()
    var changeNameButton = UIButton()

    var membersView = UIView()
    var membersViewHeight: CGFloat = 159//45 + 20 + (50 + 14 + 10 + 20)

    var groupManagerView = UIView()
    var groupManagerLabel = UILabel()
    var groupManagerIcon = UIImageView()
    var groupManagerIconHeader = UIImageView()
    var groupManagerIconName = UIImageView()
    var groupManagerButton = UIButton()

    var screenView = UIView()
    var screenlabel1 = UILabel()
    var screenlabel2 = UILabel()
    var switchView = UISwitch()

    var cleanBgView = UIView()
    var cleanTitleLabel = UILabel()
    var cleanMessageButton = UIButton()

    var leaveGroupButton = UIButton()

    var originData = NSMutableDictionary()
    var groupMembers = NSMutableArray()
    var chatType: EMConversationType?
    var currentConversattion: EMConversation?
    var isOwner = false
    var conversationID: String? = ""
    var emGroup: EMGroup?

    /// 上传的头像
    var templateImage: UIImage?
    /// 上传中状态
    var loadingShow = TSIndicatorWindowTop(state: .loading, title: "群头像上传中")

    /// 屏幕比例
    let scale = UIScreen.main.scale
    /// 重绘大小的配置
    var resizeProcessor: ResizingImageProcessor {
        let avatarImageSize = CGSize(width: gHeight * scale, height: gHeight * scale)
        return ResizingImageProcessor(referenceSize: avatarImageSize, mode: .aspectFill)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "群聊信息"
        loading() // 加载动画
        NotificationCenter.default.addObserver(self, selector: #selector(reloadGroupInfo), name: NSNotification.Name(rawValue: "reloadgroupdata"), object: nil)
        // 同步方法，会阻塞线程
        var resultError: EMError? = nil
        emGroup = EMClient.shared().groupManager.getGroupSpecificationFromServer(withId: conversationID, error: &resultError)
        getGroupInfo()
        // Do any additional setup after loading the view.
    }

    // MARK: - 创建子视图
    func creatSubView() {
        /// 整个背景滚动视图
        backScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        backScrollView.backgroundColor = UIColor(hex: 0xf4f5f5)
        backScrollView.showsHorizontalScrollIndicator = false
        backScrollView.showsVerticalScrollIndicator = true
        backScrollView.isScrollEnabled = true
        backScrollView.contentSize = CGSize(width: ScreenWidth, height: ScreenHeight * 2)
        self.view.addSubview(backScrollView)

        /// 群头像板块儿
        groupImageViewBg = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 50))
        groupImageViewBg.backgroundColor = UIColor.white
        backScrollView.addSubview(groupImageViewBg)
        groupImageLabel = UILabel(frame: CGRect(x: 15, y: 0, width: ScreenWidth / 2.0, height: 50))
        groupImageLabel.text = "群头像"
        groupImageLabel.font = UIFont.systemFont(ofSize: 15)
        groupImageLabel.textColor = UIColor(hex: 0x333333)
        groupImageLabel.textAlignment = NSTextAlignment.left
        groupImageView = UIImageView(frame: CGRect(x: ScreenWidth - 15 - 25 - 15 - 10, y: 25 / 2.0, width: 25, height: 25))
        groupImageView.clipsToBounds = true
        groupImageView.contentMode = UIViewContentMode.scaleAspectFill
        groupImageView.layer.masksToBounds = true
        groupImageView.layer.cornerRadius = groupImageView.width / 2.0
        groupManagerIconHeader = UIImageView(frame: CGRect(x: ScreenWidth - 15 - 10, y: 30 / 2.0, width: 10, height: 20))
        groupManagerIconHeader.image = UIImage(named: "IMG_ic_arrow_smallgrey")
        groupManagerIconHeader.clipsToBounds = true
        groupManagerIconHeader.contentMode = UIViewContentMode.scaleAspectFill
        groupImageViewBg.addSubview(groupManagerIconHeader)
        if isOwner == false {
            groupImageView.left = ScreenWidth - 15 - 25
            groupManagerIconHeader.isHidden = true
        }
        changeImageButton = UIButton(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 50))
        changeImageButton.backgroundColor = UIColor.clear
        changeImageButton.addTarget(self, action: #selector(changeGroupImage), for: UIControlEvents.touchUpInside)
        groupImageViewBg.addSubview(groupImageLabel)
        groupImageViewBg.addSubview(groupImageView)
        groupImageViewBg.addSubview(changeImageButton)

        /// 群名称板块儿
        groupTitleBg = UIView(frame: CGRect(x: 0, y: groupImageViewBg.bottom + 1, width: ScreenWidth, height: 50))
        groupTitleBg.backgroundColor = UIColor.white
        backScrollView.addSubview(groupTitleBg)
        groupTitleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: ScreenWidth / 2.0, height: 50))
        groupTitleLabel.text = "群名称"
        groupTitleLabel.font = UIFont.systemFont(ofSize: 15)
        groupTitleLabel.textColor = UIColor(hex: 0x333333)
        groupTitleLabel.textAlignment = NSTextAlignment.left
        groupTitleL = UILabel(frame: CGRect(x: 65, y: 0, width: ScreenWidth - 65 - 15 - 15 - 10, height: 50))
        groupTitleL.backgroundColor = UIColor.clear
        groupTitleL.font = UIFont.systemFont(ofSize: 13)
        groupTitleL.textColor = UIColor(hex: 0x999999)
        groupTitleL.textAlignment = NSTextAlignment.right
        groupTitleL.lineBreakMode = .byTruncatingMiddle
        groupTitleL.text = ""
        if self.chatType == EMConversationTypeGroupChat {
            if self.originData.count > 0 {
                let name = self.originData["name"]
                groupTitleL.text = "\(name ?? "")"
                if let faceimage = self.originData["group_face"] {
                    groupImageView.kf.setImage(with: URL(string: "\(faceimage )"), placeholder: UIImage(named: "ico_ts_assistant"), options: nil, progressBlock: nil, completionHandler: nil)
                } else {
                    groupImageView.image = UIImage(named: "ico_ts_assistant")
                }
            }
        }
        groupManagerIconName = UIImageView(frame: CGRect(x: ScreenWidth - 15 - 10, y: 30 / 2.0, width: 10, height: 20))
        groupManagerIconName.image = UIImage(named: "IMG_ic_arrow_smallgrey")
        groupManagerIconName.clipsToBounds = true
        groupManagerIconName.contentMode = UIViewContentMode.scaleAspectFill
        if isOwner == false {
            groupTitleL.width = ScreenWidth - 65 - 15
            groupManagerIconName.isHidden = true
        }
        groupTitleBg.addSubview(groupManagerIconName)
        changeNameButton = UIButton(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 50))
        changeNameButton.backgroundColor = UIColor.clear
        changeNameButton.addTarget(self, action: #selector(changeGroupName), for: UIControlEvents.touchUpInside)
        groupTitleBg.addSubview(groupTitleLabel)
        groupTitleBg.addSubview(groupTitleL)
        groupTitleBg.addSubview(changeNameButton)

        /// 群成员板块儿
        membersView = UIView(frame: CGRect(x: 0, y: groupTitleBg.bottom + 10, width: ScreenWidth, height: membersViewHeight))
        membersView.backgroundColor = UIColor.white
        backScrollView.addSubview(membersView)
        setMembersUI()

        /// 转让群主板块儿
        groupManagerView = UIView(frame: CGRect(x: 0, y: membersView.bottom + 10, width: ScreenWidth, height: 50))
        groupManagerView.backgroundColor = UIColor.white
        backScrollView.addSubview(groupManagerView)
        groupManagerLabel = UILabel(frame: CGRect(x: 15, y: 0, width: ScreenWidth / 2.0, height: 50))
        groupManagerLabel.text = "转让群主"
        groupManagerLabel.font = UIFont.systemFont(ofSize: 15)
        groupManagerLabel.textColor = UIColor(hex: 0x333333)
        groupManagerLabel.textAlignment = NSTextAlignment.left
        groupManagerView.addSubview(groupManagerLabel)
        groupManagerIcon = UIImageView(frame: CGRect(x: ScreenWidth - 15 - 10, y: 30 / 2.0, width: 10, height: 20))
        groupManagerIcon.image = UIImage(named: "IMG_ic_arrow_smallgrey")
        groupManagerIcon.clipsToBounds = true
        groupManagerIcon.contentMode = UIViewContentMode.scaleAspectFill
        groupManagerView.addSubview(groupManagerIcon)
        groupManagerButton = UIButton(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 50))
        groupManagerButton.backgroundColor = UIColor.clear
        groupManagerButton.addTarget(self, action: #selector(enterGroupManager), for: UIControlEvents.touchUpInside)
        groupManagerView.addSubview(groupManagerButton)

        /// 屏蔽群消息板块儿
        screenView = UIView(frame: CGRect(x: 0, y: groupManagerView.bottom + 1, width: ScreenWidth, height: 58))
        if isOwner {
            groupManagerView.isHidden = false
            screenView.frame = CGRect(x: 0, y: groupManagerView.bottom + 1, width: ScreenWidth, height: 58)
        } else {
            groupManagerView.isHidden = true
            screenView.frame = CGRect(x: 0, y: membersView.bottom + 10, width: ScreenWidth, height: 58)
        }
        screenView.backgroundColor = UIColor.white
        backScrollView.addSubview(screenView)
        screenlabel1 = UILabel(frame: CGRect(x: 15, y: 15, width: ScreenWidth / 2.0, height: 15))
        screenlabel1.text = "屏蔽消息"
        screenlabel1.font = UIFont.systemFont(ofSize: 15)
        screenlabel1.textColor = UIColor(hex: 0x333333)
        screenlabel1.textAlignment = NSTextAlignment.left
        screenView.addSubview(screenlabel1)
        screenlabel2 = UILabel(frame: CGRect(x: 15, y: screenlabel1.bottom + 5, width: ScreenWidth / 2.0, height: 10))
        screenlabel2.text = "开启后将不再接受群的消息"
        screenlabel2.font = UIFont.systemFont(ofSize: 10)
        screenlabel2.textColor = UIColor(hex: 0x999999)
        screenlabel2.textAlignment = NSTextAlignment.left
        screenView.addSubview(screenlabel2)
        /// switch 宽高目测是系统固定了，没法修改。
        switchView = UISwitch(frame: CGRect(x: ScreenWidth - 51 - 15, y: 0, width: 51, height: 31))
        switchView.onTintColor = TSColor.main.theme
        switchView.centerY = 58 / 2.0
        switchView.isOn = (emGroup?.isBlocked)!
        screenView.addSubview(switchView)
        /// 环信群主没法屏蔽群消息
        if isOwner {
            switchView.isEnabled = false
        } else {
            switchView.isEnabled = true
        }
        switchView.addTarget(self, action: #selector(blockMessage), for: UIControlEvents.valueChanged)

        /// 清空聊天记录
        cleanBgView = UIView(frame: CGRect(x: 0, y: screenView.bottom + 10, width: ScreenWidth, height: 50))
        if isOwner {
            screenView.isHidden = true
            cleanBgView.frame = CGRect(x: 0, y: groupManagerView.bottom + 10, width: ScreenWidth, height: 50)
        } else {
            screenView.isHidden = false
            cleanBgView.frame = CGRect(x: 0, y: screenView.bottom + 10, width: ScreenWidth, height: 50)
        }
        cleanBgView.backgroundColor = UIColor.white
        backScrollView.addSubview(cleanBgView)
        cleanTitleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: ScreenWidth - 15, height: 50))
        cleanTitleLabel.text = "清空聊天记录"
        cleanTitleLabel.font = UIFont.systemFont(ofSize: 15)
        cleanTitleLabel.textColor = UIColor(hex: 0x333333)
        cleanTitleLabel.textAlignment = NSTextAlignment.left
        cleanBgView.addSubview(cleanTitleLabel)
        cleanMessageButton = UIButton(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 50))
        cleanMessageButton.backgroundColor = UIColor.clear
        cleanMessageButton.addTarget(self, action: #selector(cleanMessageButtonClick), for: UIControlEvents.touchUpInside)
        cleanBgView.addSubview(cleanMessageButton)

        /// 退出群聊
        leaveGroupButton = UIButton(frame: CGRect(x: 0, y: cleanBgView.bottom + 10, width: ScreenWidth, height: 50))
        leaveGroupButton.backgroundColor = UIColor.white
        leaveGroupButton.setTitle("退出群聊", for: .normal)
        if isOwner {
            leaveGroupButton.setTitle("解散群组", for: .normal)
        }
        leaveGroupButton.setTitleColor(UIColor(hex: 0xf4504d), for: .normal)
        leaveGroupButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        leaveGroupButton.titleLabel?.textAlignment = NSTextAlignment.center
        leaveGroupButton.addTarget(self, action: #selector(leaveGroupButtonClick), for: UIControlEvents.touchUpInside)
        backScrollView.addSubview(leaveGroupButton)
        updataScrollViewContentSize()
    }
    // MARK: - 布局成员UI
    func setMembersUI() {
        membersView.removeAllSubViews()
        let memberId = self.originData["owner"]
        // 群主18个+2个图标，成员19个+1个图标
        var groupMemberShowArray: NSMutableArray
        groupMemberShowArray = NSMutableArray(array: groupMembers)
        if isOwner == true && groupMemberShowArray.count > 18 {
            // 只要前18个
            let showArray = NSMutableArray()
            for (index, item) in groupMembers.enumerated() {
                if index < 18 {
                    showArray.append(item)
                } else {
                    break
                }
            }
            groupMemberShowArray = NSMutableArray(array: showArray)
        } else if isOwner == false && groupMembers.count > 19 {
            // 只要前19个
            let showArray = NSMutableArray()
            for (index, item) in groupMembers.enumerated() {
                if index < 19 {
                    showArray.append(item)
                } else {
                    break
                }
            }
            groupMemberShowArray = NSMutableArray(array: showArray)
        }

        for (index, item) in groupMemberShowArray.enumerated() {
            let userInfo = item as? TSUserInfoModel

            /// 当前头像之前要间隔的头像总距离
            let width = CGFloat(index % 5) * gHeight
            let buttonX = space + width + CGFloat(index % 5) * gSpace

            /// 成员头像
            let faceButton = UIButton(frame: CGRect(x: buttonX, y: 20 + CGFloat(index / 5) * faceHeight, width: gHeight, height: gHeight))
            faceButton.backgroundColor = UIColor(hex: 0xf4f5f5)
            faceButton.layer.masksToBounds = true
            faceButton.layer.cornerRadius = gHeight / 2.0
            faceButton.tag = index + 666
            if userInfo?.avatar != nil {
                faceButton.kf.setImage(
                    with: URL(string: TSUtil.praseTSNetFileUrl(netFile: userInfo?.avatar) ?? ""), for: .normal, placeholder: UIImage(named: "IMG_pic_default_secret"), options: [.processor(resizeProcessor)], progressBlock: nil, completionHandler: nil)
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

            /// 成员认证图标
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

            /// 成员昵称
            let nameLabel = UILabel(frame: CGRect(x: 0, y: faceButton.bottom + 10, width: gHeight, height: 14))
            nameLabel.text = "\(userInfo?.name ?? "")"
            nameLabel.textAlignment = NSTextAlignment.center
            nameLabel.font = UIFont.systemFont(ofSize: 12)
            nameLabel.textColor = UIColor(hex: 0x999999)
            nameLabel.centerX = faceButton.centerX
            membersView.addSubview(nameLabel)
            /// 添加一个触控的遮盖层
            let tapView = UIView(frame: CGRect(x: faceButton.frame.origin.x, y: faceButton.frame.origin.y, width: faceButton.frame.size.width, height: faceButton.frame.size.height + 10 + nameLabel.frame.size.height))
            membersView.addSubview(tapView)
            let userItemTap = UITapGestureRecognizer(target: self, action: #selector(userItemDidTap(rec:)))
            tapView.tag = faceButton.tag
            tapView.addGestureRecognizer(userItemTap)
            if index == groupMemberShowArray.count - 1 {
                /// 增加成员按钮
                let addButton = UIButton(frame: CGRect(x: 15, y: 20 + CGFloat(groupMemberShowArray.count / 5) * faceHeight, width: gHeight, height: gHeight))
                addButton.backgroundColor = UIColor(hex: 0xf2f2f2)
                addButton.layer.masksToBounds = true
                addButton.layer.cornerRadius = gHeight / 2.0
                addButton.tag = 555
                addButton.setImage(UIImage(named: "btn_chatdetail_add"), for: .normal)
                if groupMemberShowArray.count % 5 == 0 {
                    addButton.frame = CGRect(x: 15, y: 20 + CGFloat(groupMemberShowArray.count / 5) * faceHeight, width: gHeight, height: gHeight)
                } else {
                    addButton.frame = CGRect(x: faceButton.right + gSpace, y: faceButton.top, width: gHeight, height: gHeight)
                }
                membersView.addSubview(addButton)
                addButton.addTarget(self, action: #selector(addMembersButtonClick), for: UIControlEvents.touchUpInside)
                if isOwner {
                    /// 删除成员按钮
                    let deleteBuuton = UIButton(frame: CGRect(x: 15, y: 20 + CGFloat(groupMemberShowArray.count / 5) * faceHeight, width: gHeight, height: gHeight))
                    deleteBuuton.backgroundColor = UIColor(hex: 0xf2f2f2)
                    deleteBuuton.layer.masksToBounds = true
                    deleteBuuton.layer.cornerRadius = gHeight / 2.0
                    deleteBuuton.tag = 333
                    deleteBuuton.setImage(UIImage(named: "btn_chatdetail_reduce"), for: .normal)
                    if groupMemberShowArray.count % 5 == 4 {
                        deleteBuuton.frame = CGRect(x: 15, y: 20 + CGFloat(groupMemberShowArray.count / 5 + 1) * faceHeight, width: gHeight, height: gHeight)
                    } else {
                        deleteBuuton.frame = CGRect(x: addButton.right + gSpace, y: addButton.top, width: gHeight, height: gHeight)
                    }
                    membersView.addSubview(deleteBuuton)
                    deleteBuuton.addTarget(self, action: #selector(deleteMemberButtonClick), for: UIControlEvents.touchUpInside)
                }
            }
        }
        // 人数够了才显示查看更多,否则不显示
        if (isOwner == true && groupMembers.count > 18) || (isOwner == false && groupMembers.count > 19) {
            /// 分割线
            let lineView = UIView(frame: CGRect(x: 0, y: membersViewHeight - 45, width: ScreenWidth, height: 1))
            lineView.backgroundColor = UIColor(hex: 0xf4f5f5)
            membersView.addSubview(lineView)
            /// 查看成员按钮
            let lookMoreMemberButton = UIButton(frame: CGRect(x: 0, y: membersViewHeight - 44, width: ScreenWidth, height: 44))
            lookMoreMemberButton.backgroundColor = UIColor.white
            lookMoreMemberButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            lookMoreMemberButton.setTitle("查看全部成员", for: .normal)
            lookMoreMemberButton.setTitleColor(UIColor(hex: 0x333333), for: .normal)
            membersView.addSubview(lookMoreMemberButton)
            lookMoreMemberButton.addTarget(self, action: #selector(lookMoreButtonClick), for: UIControlEvents.touchUpInside)
        }
    }

    // MARK: - 计算布局群成员头像所需要的高度(仅仅是群成员头像+增删按钮)
    func canculateHeight() {
        // 群主18个+2个图标，成员19个+1个图标
        var mumberCount = groupMembers.count
        if isOwner {
            if mumberCount > 0 {
                if mumberCount > 18 {
                    mumberCount = 18
                    membersViewHeight = faceHeight * CGFloat(mumberCount / 5) + faceHeight * (mumberCount % 5 > 3 ? 2 : 1) + 45 + 20
                } else {
                    membersViewHeight = faceHeight * CGFloat(mumberCount / 5) + faceHeight * (mumberCount % 5 > 3 ? 2 : 1) + 20
                    if (mumberCount + 2) % 5 == 1 || (mumberCount + 2) % 5 == 2 {
                        // 如果控制按钮刚好换行，为了视觉效果需要减小一个昵称+昵称到头像的高度，否者看上去底部间距就很大
                        membersViewHeight = membersViewHeight - 14 - 10
                    }
                }
            } else {
                membersViewHeight = 159
            }
        } else {
            if mumberCount > 0 {
                if mumberCount > 18 {
                    mumberCount = 18
                    membersViewHeight = faceHeight * CGFloat(mumberCount / 5) + faceHeight * (mumberCount % 5 > 0 ? 1 : 1) + 45 + 20
                } else {
                    membersViewHeight = faceHeight * CGFloat(mumberCount / 5) + faceHeight * (mumberCount % 5 > 0 ? 1 : 1) + 20
                    if (mumberCount + 1) % 5 == 1 {
                        // 如果控制按钮刚好换行，为了视觉效果需要减小一个昵称+昵称到头像的高度，否者看上去底部间距就很大
                        membersViewHeight = membersViewHeight - 14 - 10
                    }
                }
            } else {
                membersViewHeight = 159
            }
        }
    }

    // MARK: - 点击了群头像
    func changeGroupImage() {
        guard isOwner else {
            return
        }
        let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
        let personalIdentyAction = TSAlertAction(title: "选择_相册".localized, style: .default, handler: { [weak self] (_) in
            self?.openLibrary()
        })
        let enterpriseIdentyAction = TSAlertAction(title: "选择_相机".localized, style: .default, handler: { [weak self] (_) in
            self?.openCamera()
        })
        alertVC.addAction(personalIdentyAction)
        alertVC.addAction(enterpriseIdentyAction)
        self.present(alertVC, animated: false, completion: nil)
    }

    // MARK: - 点击了用户头像
    func userItemDidTap(rec: UITapGestureRecognizer) {
        let userInfo = groupMembers[(rec.view?.tag)! - 666] as! TSUserInfoModel
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": userInfo.userIdentity])
    }

    private func openCamera() {
        let isSuccess = TSSetUserInfoVC.checkCamearPermissions()
        guard isSuccess else {
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if (UIDevice.current.systemVersion as NSString).floatValue >= 7.0 {
            imagePicker.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
        }
        imagePicker.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor
        var tzBarItem: UIBarButtonItem?
        var BarItem: UIBarButtonItem?
        tzBarItem = UIBarButtonItem.appearance(whenContainedInInstancesOf: [TZImagePickerController.self])
        BarItem = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIImagePickerController.self])
        let titleTextAttributes = tzBarItem?.titleTextAttributes(for: .normal)
        BarItem?.setTitleTextAttributes(titleTextAttributes, for: .normal)
        let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = sourceType
            if (UIDevice.current.systemVersion as NSString).floatValue >= 9.0 {
                imagePicker.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            }
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            return
        }
//        let cameraVC = TSImagePickerViewController.canCropCamera(cropType: .squart, finish: { [weak self] (image: UIImage) in
//            guard let weakSelf = self else {
//                return
//            }
//            weakSelf.templateImage = image
//            let imageName = (PHAsset().originalFilename)!
//            weakSelf.changeImageRequest(image: image, imageName: imageName, size:  CGSize(width: image.size.width, height: image.size.height))
//        })
//        cameraVC.show()
    }

    private func openLibrary() {
        guard let imagePickerVC = TZImagePickerController(maxImagesCountTSType: 1, columnNumber: 4, delegate: self, pushPhotoPickerVc: true, square: true, shouldPick: true, topTitle: "更换头像", mainColor: TSColor.main.theme)
            else {
                return
        }
        /// 不设置则直接用TZImagePicker的pod中的图片素材
        /// #图片选择列表页面
        /// item右上角蓝色的选中图片
//            imagePickerVC.selectImage = UIImage(named: "msg_box_choose_now")

        imagePickerVC.maxImagesCount = 1
        imagePickerVC.allowCrop = true
        imagePickerVC.isSelectOriginalPhoto = true
        imagePickerVC.allowTakePicture = true
        imagePickerVC.allowPickingImage = true
        imagePickerVC.allowPickingVideo = false
        imagePickerVC.allowPickingGif = false
        imagePickerVC.sortAscendingByModificationDate = false
        imagePickerVC.navigationBar.barTintColor = UIColor.white
        var dic = [String: Any]()
        dic[NSForegroundColorAttributeName] = UIColor.black
        imagePickerVC.navigationBar.titleTextAttributes = dic
        present(imagePickerVC, animated: true)
    }

    //MARK: - 系统拍照选择图片回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let infoDict: NSDictionary = (info as? NSDictionary)!
        let type: String = infoDict.object(forKey: UIImagePickerControllerMediaType) as! String
        if type == "public.image" {
            let photo: UIImage = infoDict.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
            let photoOrigin: UIImage = photo.fixOrientation()
            if photoOrigin != nil {
                let lzImage = LZImageCropping()
                lzImage.cropSize = CGSize(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.width - 80)
                lzImage.image = photoOrigin
                lzImage.isRound = false
                lzImage.titleLabel.text = "更换头像"
                lzImage.didFinishPickingImage = {(image) -> Void in
                    guard let image = image else {
                        return
                    }
                    self.templateImage = image
                    let imageName = (PHAsset().originalFilename)!
                    self.changeImageRequest(image: image, imageName: imageName, size:  CGSize(width: image.size.width, height: image.size.height))
                }
                self.navigationController?.present(lzImage, animated: true, completion: nil)
            }
        }
    }

    // 图片选择回调
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        if photos != nil && photos.count > 0 {
            if picker != nil {
                picker.dismiss(animated: true) {
                }
            }
            let image = photos[0]
            self.templateImage = image
            let imageName = (PHAsset().originalFilename)!
            self.changeImageRequest(image: image, imageName: imageName, size:  CGSize(width: image.size.width, height: image.size.height))
        }
    }

    /// 选择好图片后上传服务器
    ///
    /// - Parameters:
    ///   - image: 图片
    ///   - imageName: 图片名
    ///   - size: 尺寸
    private func changeImageRequest(image: UIImage, imageName: String, size: CGSize) {
        loadingShow = TSIndicatorWindowTop(state: .loading, title: "群头像上传中")
        loadingShow.show()
        // 修改群头像
        TSUploadNetworkManager().uploadImage(image: image) { (imageId, message, status) in
            guard status else {
                self.loadingShow.dismiss()
                self.showUpdateImageFail(indicator: self.loadingShow, message: "群头像上传失败")
                return
            }
            /// 得到图片 id 请求修改群头像修改接口
            self.changeGroupImageRequest(imageId: imageId!)
        }
    }

    // MARK: - 获取图片id后请求群头像修改接口
    func changeGroupImageRequest(imageId: Int) {
        let idString = "\(imageId)"
        guard !idString.isEmpty && idString != "" else {
            return
        }
        /// 准备需要的参数
        let groupName = "\(self.originData["name"] ?? "")"
        let groupid = "\(self.originData["id"] ?? "")"
        let desc = "\(self.originData["description"] ?? "")"
        let ispublic = "\(self.originData["public"] ?? "")"
        let maxusers = "\(self.originData["maxusers"] ?? "")"
        let menbers_only = "\(self.originData["membersonly"] ?? "")"
        let allowinvites = "\(self.originData["allowinvites"] ?? "")"
        TSAccountNetworkManager().changeHyGroup(groupid: groupid, groupname: groupName, desc: desc, ispublic: ispublic, maxusers: maxusers, menbers_only: menbers_only, allowinvites: allowinvites, group_face: idString) { (data, status) in
            self.loadingShow.dismiss()
            guard status else {
                self.showUpdateImageFail(indicator: self.loadingShow, message: "群头像上传失败")
                return
            }
            /// 拿到头像链接和群id,并且增加一个类型是修改群头像还是群昵称的操作，然后发通知告诉会话列表更新数据源UI
            let faceUrl = "\(data!["group_face"] ?? "")"
            var groupInfo = [String: Any]()
            groupInfo.updateValue(groupid, forKey: "id")
            groupInfo.updateValue("image", forKey: "changeType")
            groupInfo.updateValue(faceUrl, forKey: "imageUrl")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "editgroupnameorimage"), object: groupInfo)
            self.groupImageView.image = self.templateImage
        }
    }

    func showUpdateImageFail(indicator: TSIndicatorWindowTop, message: String) {
        indicator.dismiss()
        self.templateImage = nil
        let topShow = TSIndicatorWindowTop(state: .faild, title: message)
        topShow.show()
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
            DispatchQueue.main.async {
                topShow.dismiss()
            }
        })
    }

    // MARK: - 进入群主转让页面
    func enterGroupManager() {
        let vc = TSGroupNewOwnerVC()
        vc.originDataSource = NSMutableArray(array: self.groupMembers)
        vc.originData = NSDictionary(dictionary: self.originData)
        let ownerId = self.originData["owner"]
        let groupOwnerID = "\(ownerId ?? "")"
        vc.ownerId = groupOwnerID
        vc.bePresentVC = self
        self.present(vc, animated: true) {
        }

    }

    // MARK: - 修改群昵称
    func changeGroupName() {
        guard isOwner else {
            return
        }
        let vc = TSGroupNameEditVC()
        let name = self.originData["name"]
        vc.originName = "\(name ?? "")"
        vc.originData = NSDictionary(dictionary: self.originData)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - 清空聊天记录
    func cleanMessageButtonClick() {
        let alertVC = TSAlertController(title: "提示", message: "是否清空聊天记录？", style: .actionsheet)
        let personalIdentyAction = TSAlertAction(title: "清空", style: .default, handler: { [weak self] (_) in
            var resultError: EMError? = nil
            self?.currentConversattion?.deleteAllMessages(&resultError)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadChatDetailVCMessage"), object: nil)
        })
        alertVC.addAction(personalIdentyAction)
        self.present(alertVC, animated: false, completion: nil)
    }

    // MARK: - 屏蔽消息
    func blockMessage(currentSwitchView: UISwitch) {
        let groupid = "\(self.originData["id"] ?? "")"
        if currentSwitchView.isOn {
            // 解除屏蔽
            EMClient.shared().groupManager.blockGroup(emGroup?.groupId, completion: { (currentGroup, error) in
                guard error == nil else {
                    return
                }
                self.emGroup = currentGroup
                currentSwitchView.isOn = (currentGroup?.isBlocked)!
                var groupInfo = [String: Any]()
                groupInfo.updateValue("0", forKey: "hidescreen")
                groupInfo.updateValue(groupid, forKey: "id")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "sendMessageReloadChatListVc"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hidescreen"), object: groupInfo)
            })
        } else {
            // 屏蔽
            EMClient.shared().groupManager.unblockGroup(emGroup?.groupId, completion: { (currentGroup, error) in
                guard error == nil else {
                    return
                }
                self.emGroup = currentGroup
                currentSwitchView.isOn = (currentGroup?.isBlocked)!
                var groupInfo = [String: Any]()
                groupInfo.updateValue("1", forKey: "hidescreen")
                groupInfo.updateValue(groupid, forKey: "id")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "sendMessageReloadChatListVc"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hidescreen"), object: groupInfo)
            })
        }
    }

    // MARK: - 退群或者解散群
    func leaveGroupButtonClick() {
        let groupid = "\(self.originData["id"] ?? "")"
        if isOwner {
            /// 解散群
            let alertVC = TSAlertController(title: "提示", message: "是否解散群组？", style: .actionsheet)
            let personalIdentyAction = TSAlertAction(title: "解散", style: .default, handler: { [weak self] (_) in
                EMClient.shared().groupManager.destroyGroup(self?.emGroup?.groupId, finishCompletion: { (error) in
                    guard error == nil else {
                        return
                    }
                    var groupInfo = [String: Any]()
                    groupInfo.updateValue(groupid, forKey: "id")
                    groupInfo.updateValue("destroyGroup", forKey: "changeType")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "editgroupnameorimage"), object: groupInfo)
                    self?.navigationController?.popToRootViewController(animated: true)
                })
            })
            alertVC.addAction(personalIdentyAction)
            self.present(alertVC, animated: false, completion: nil)
        } else {
            /// 退群
            let alertVC = TSAlertController(title: "提示", message: "是否退出群组？", style: .actionsheet)
            let personalIdentyAction = TSAlertAction(title: "退出", style: .default, handler: { [weak self] (_) in
                EMClient.shared().groupManager.leaveGroup(self?.emGroup?.groupId, completion: { (error) in
                    guard error == nil else {
                        return
                    }
                    var groupInfo = [String: Any]()
                    groupInfo.updateValue(groupid, forKey: "id")
                    groupInfo.updateValue("leaveGroup", forKey: "changeType")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "editgroupnameorimage"), object: groupInfo)
                    self?.navigationController?.popToRootViewController(animated: true)
                })
            })
            alertVC.addAction(personalIdentyAction)
            self.present(alertVC, animated: false, completion: nil)
        }
    }

    // MARK: - 添加成员
    func addMembersButtonClick() {
        let vc = TSChatFriendListViewController()
        vc.ischangeGroupMember = "add"
        vc.originDataSource = self.groupMembers
        vc.currenGroupId = conversationID
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - 删除成员
    func deleteMemberButtonClick() {
        let vc = TSChatFriendListViewController()
        vc.ischangeGroupMember = "delete"
        vc.originDataSource = NSMutableArray(array: self.groupMembers)
        vc.currenGroupId = conversationID
        vc.dataSource = self.groupMembers as! [TSUserInfoModel]
        let ownerId = self.originData["owner"]
        let groupOwnerID = "\(ownerId ?? "")"
        vc.ownerId = groupOwnerID
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - 查看成员
    func lookMoreButtonClick() {
        let vc = TSGroupMembersViewController()
        vc.originData = self.originData
        vc.currenGroupId = self.conversationID
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - 根据退群按钮的UI来调整 scrollview 的 contentsize
    func updataScrollViewContentSize() {
        if (leaveGroupButton.bottom + 10 + 64) > ScreenHeight {
            // 预留10pt的边距
            backScrollView.contentSize = CGSize(width: ScreenWidth, height: leaveGroupButton.bottom + 10 + 64)
        } else {
            backScrollView.contentSize = CGSize(width: ScreenWidth, height: ScreenHeight)
        }
    }

    // MARK: - 请求群信息，这里面涉及到很多权限的字段，必须要请求成功之后才能显示页面，不然缺省图盖上去
    func getGroupInfo() {
        guard conversationID != "" else {
            return
        }
        // 同步方法，会阻塞线程
        if self.emGroup == nil {
            var resultError: EMError? = nil
            self.emGroup = EMClient.shared().groupManager.getGroupSpecificationFromServer(withId: self.conversationID, error: &resultError)
            if self.emGroup == nil {
                // 如果还是没有群信息，就不能显示UI,提供点击重试的按钮
                self.loadFaild(type: LoadingView.FaildType.network)
                return
            }
        }
        /// 这个地方要先请求群信息，然后再确定显示在列表的数据(请求成功加入列表，请求失败不加入)
        TSAccountNetworkManager().getHyGroupInfo(groupid: conversationID!, complete: { (response, result) in
            guard result else {
                self.loadFaild(type: LoadingView.FaildType.network)
                return
            }
            self.endLoading()
            if response == nil {
                // 当前群组不存在了
                /// 删除会话
                TSIndicatorWindowTop.showDefaultTime(state: .faild, title: "提示信息_群聊被删除".localized)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "sendMessageReloadChatListVc"), object: nil)
                EMClient.shared().chatManager.deleteConversation(self.conversationID, isDeleteMessages: true, completion: { (aConversationId, aError) in

                })
                self.navigationController?.popToRootViewController(animated: true)
                return
            }
            let dict = response![0] as? NSDictionary
            self.originData = NSMutableDictionary(dictionary: dict!)
            if self.chatType == EMConversationTypeGroupChat {
                let groupUsers = NSMutableArray(array: (self.originData.object(forKey: "affiliations") as? NSArray)!)
                self.groupMembers.removeAllObjects()
                self.groupMembers.addObjects(from: Mapper<TSUserInfoModel>().mapArray(JSONObject: groupUsers)!)
                if self.originData.count > 0 {
                    let ownerId = self.originData["owner"]
                    let groupOwnerID = "\(ownerId ?? "")"
                    if EMClient.shared().currentUsername != nil {
                        if groupOwnerID == EMClient.shared().currentUsername {
                            self.isOwner = true
                        } else {
                            self.isOwner = false
                        }
                    } else {
                        self.isOwner = false
                    }
                    let dataDic = ["groupInfo": self.originData, "changeType": "groupInfo"] as [String : Any]
                    NotificationCenter.default.post(name: NSNotification.Name.Chat.uploadLocGrupInfo, object: dataDic)
                }
            }
            self.canculateHeight()
            self.creatSubView()
        })
    }

    // MARK: - 重新请求数据再布局ui
    func reloadGroupInfo() {
        backScrollView.removeAllSubViews()
        getGroupInfo()
    }
    override func reloadingButtonTaped() {
        self.reloadGroupInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
