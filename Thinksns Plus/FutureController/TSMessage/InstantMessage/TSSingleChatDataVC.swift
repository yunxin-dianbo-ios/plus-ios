//
//  TSSingleChatDataVC.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/26.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher

/// 群成员头像宽高
private let gHeight: CGFloat = 50
/// 群成员布局左右间距
private let space: CGFloat = 15
/// 群成员头像之间间距
private let gSpace: CGFloat = (ScreenWidth - gHeight * 5 - space * 2) / 4.0
/// 每一个头像所需高度
private let faceHeight: CGFloat = 50 + 14 + 10 + 20 + 20

class TSSingleChatDataVC: TSViewController {

    var membersView = UIView()

    var cleanBgView = UIView()
    var cleanTitleLabel = UILabel()
    var cleanMessageButton = UIButton()

    var currentConversattion: EMConversation?
    var hyUserInfo: TSUserInfoObject?

    /// 屏幕比例
    let scale = UIScreen.main.scale
    /// 重绘大小的配置
    var resizeProcessor: ResizingImageProcessor {
        let avatarImageSize = CGSize(width: gHeight * scale, height: gHeight * scale)
        return ResizingImageProcessor(referenceSize: avatarImageSize, mode: .aspectFill)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "聊天信息"
        self.view.backgroundColor = UIColor(hex: 0xf4f5f5)
        let idSt: String = (currentConversattion!.conversationId)!
        let idInt: Int = Int(idSt)!
        if TSDatabaseManager().user.get(idInt) != nil {
            hyUserInfo = TSDatabaseManager().user.get(idInt)
            creatSubView()
        } else {
            /// 请求用户信息接口获取需要的数据(头像 昵称 ID)
        }
        // Do any additional setup after loading the view.
    }

    // MARK: - 创建子视图
    func creatSubView() {

        /// 群成员板块儿
        membersView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: faceHeight))
        membersView.backgroundColor = UIColor.white
        self.view.addSubview(membersView)
        setMembersUI()

        /// 清空聊天记录
        cleanBgView = UIView(frame: CGRect(x: 0, y: membersView.bottom + 10, width: ScreenWidth, height: 50))
        cleanBgView.backgroundColor = UIColor.white
        self.view.addSubview(cleanBgView)
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

    }

    // MARK: - 聊天成员UI
    func setMembersUI() {
        /// 成员头像
        let faceButton = UIButton(frame: CGRect(x: 15, y: 20, width: gHeight, height: gHeight))
        faceButton.backgroundColor = UIColor.red
        faceButton.layer.masksToBounds = true
        faceButton.layer.cornerRadius = gHeight / 2.0
        faceButton.tag = 666
        if hyUserInfo?.avatar != nil {
            faceButton.kf.setImage(
                with: URL(string: TSUtil.praseTSNetFileUrl(netFile: hyUserInfo?.avatar) ?? ""), for: .normal, placeholder: UIImage(named: "IMG_pic_default_secret"), options: [.processor(resizeProcessor)], progressBlock: nil, completionHandler: nil)
        } else {
            if hyUserInfo?.sex == 1 {
                faceButton.setImage(UIImage(named: "IMG_pic_default_man"), for: .normal)
            } else if hyUserInfo?.sex == 2 {
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
        if hyUserInfo?.verified?.type == "" {
            iconImage.isHidden = true
        } else {
            iconImage.isHidden = false
            if hyUserInfo?.verified?.icon == "" {
                switch hyUserInfo?.verified?.type {
                case "user"?:
                    iconImage.image = UIImage(named: "IMG_pic_identi_individual")
                case "org"?:
                    iconImage.image = UIImage(named: "IMG_pic_identi_company")
                default:
                    iconImage.image = UIImage(named: "")
                }
            } else {
                let resize = ResizingImageProcessor(referenceSize: iconImage.frame.size, mode: .aspectFit)
                let urlString = hyUserInfo?.verified?.icon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let iconURL = URL(string: urlString ?? "")
                iconImage.kf.setImage(with: iconURL, placeholder: nil, options: [.processor(resize)], progressBlock: nil, completionHandler: nil)
            }
        }
        membersView.addSubview(iconImage)

        /// 成员昵称
        let nameLabel = UILabel(frame: CGRect(x: 0, y: faceButton.bottom + 10, width: gHeight, height: 14))
        nameLabel.text = "\(hyUserInfo?.name ?? "")"
        nameLabel.textAlignment = NSTextAlignment.center
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = UIColor(hex: 0x999999)
        nameLabel.centerX = faceButton.centerX
        membersView.addSubview(nameLabel)

        /// 增加成员按钮
        let addButton = UIButton(frame: CGRect(x: faceButton.right + gSpace, y: faceButton.top, width: gHeight, height: gHeight))
        addButton.backgroundColor = UIColor(hex: 0xf2f2f2)
        addButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = gHeight / 2.0
        addButton.tag = 555
        addButton.setImage(UIImage(named: "btn_chatdetail_add"), for: .normal)
        membersView.addSubview(addButton)
        addButton.addTarget(self, action: #selector(addMembersButtonClick), for: UIControlEvents.touchUpInside)
    }

    // MARK: - 清空聊天记录
    func cleanMessageButtonClick() {
        let alertVC = TSAlertController(title: "提示", message: "是否清空聊天记录？", style: .actionsheet)
        let personalIdentyAction = TSAlertAction(title: "清空", style: .default, handler: { [weak self] (_) in
            var resultError: EMError? = nil
            self?.currentConversattion?.deleteAllMessages(&resultError)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadChatDetailVCMessage"), object: nil)
            // 如果是小助手被清理就记录当前登录的ID，防止下次登录再次发送提示语
            var tsHelper: Bool = false
            if TSAppConfig.share.localInfo.imHelper != nil {
                tsHelper = true
            }
            if tsHelper == true {
                guard let imHelperUid = TSAppConfig.share.localInfo.imHelper else {
                    return
                }
                // 当前用户不是聊天助手用户则不用这么处理
                if imHelperUid != Int((self?.currentConversattion?.conversationId)!) {
                    return
                }
                let hyLoginUid = String(imHelperUid)
                let hyConversation = EMClient.shared().chatManager.getConversation(hyLoginUid, type: EMConversationTypeChat, createIfNotExist: true)
                hyConversation?.deleteAllMessages(nil)
                let clearedIMHelperUserArray = UserDefaults.standard.array(forKey: "clearedIMHelperUserArrayKey")
                if clearedIMHelperUserArray != nil {
                    let userArray: Array<String> = clearedIMHelperUserArray as! Array<String>
                    if userArray.contains(where: { (uid) -> Bool in
                        return uid == hyLoginUid
                    }) {
                        // 当前账号已经清理过就不添加记录
                    } else {
                        let currentUID = String((TSCurrentUserInfo.share.userInfo?.userIdentity)!)
                        UserDefaults.standard.set([currentUID], forKey: "clearedIMHelperUserArrayKey")
                        UserDefaults.standard.synchronize()
                    }
                } else {
                    let currentUID = String((TSCurrentUserInfo.share.userInfo?.userIdentity)!)
                    UserDefaults.standard.set([currentUID], forKey: "clearedIMHelperUserArrayKey")
                    UserDefaults.standard.synchronize()
                }
            }
            // 刷新会话列表
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendMessageReloadChatListVc"), object: nil)
        })
        alertVC.addAction(personalIdentyAction)
        self.present(alertVC, animated: false, completion: nil)
    }

    // MARK: - 添加成员
    func addMembersButtonClick() {
        let vc = TSChatSingleAddMemberVC()
        vc.ischangeGroupMember = "singleswitchgroup"
        vc.hyUserInfo = self.hyUserInfo
        navigationController?.pushViewController(vc, animated: true)
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
