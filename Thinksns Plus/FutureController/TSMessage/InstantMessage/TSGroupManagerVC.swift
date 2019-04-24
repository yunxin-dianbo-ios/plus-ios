//
//  TSGroupManagerVC.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/26.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSGroupManagerVC: TSViewController {

    var groupManagerView = UIView()
    var groupManagerLabel = UILabel()
    var groupManagerIcon = UIImageView()
    var groupManagerButton = UIButton()

    var screenView = UIView()
    var screenlabel1 = UILabel()
    var screenlabel2 = UILabel()
    var switchView = UISwitch()
    var emGroup: EMGroup?
    /// 从群信息页面传递过来的群信息原始数据
    var originData = NSDictionary()
    /// 进入当前页面之前就已经选择的数据（主要是存储从群详情页和查看群成员页面跳转过来的时候一并传递过来的已有群成员数据）
    var originDataSource = NSMutableArray()
    /// 如果是删除群成员的页面，这个群主 ID 必须传
    var ownerId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "群管理"
        self.view.backgroundColor = UIColor(hex: 0xf4f5f5)
        creatSubViews()
        // Do any additional setup after loading the view.
    }

    // MARK: - 配置子视图
    func creatSubViews() {
        /// 群管理板块儿
        groupManagerView = UIView(frame: CGRect(x: 0, y: 10, width: ScreenWidth, height: 50))
        groupManagerView.backgroundColor = UIColor.white
        self.view.addSubview(groupManagerView)
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
        groupManagerButton.addTarget(self, action: #selector(changeGroupOwner), for: UIControlEvents.touchUpInside)
        groupManagerView.addSubview(groupManagerButton)

        /// 开启进群审核(由于环信并没有开启进群审核的功能和接口，暂时隐藏)
        /*
         screenView = UIView.init(frame: CGRect.init(x: 0, y: groupManagerView.bottom + 10, width: ScreenWidth, height: 50))
        screenView.backgroundColor = UIColor.white
        self.view.addSubview(screenView)
        screenlabel1 = UILabel.init(frame: CGRect.init(x: 15, y: 0, width: ScreenWidth / 2.0, height: 50))
        screenlabel1.text = "开启进群审核"
        screenlabel1.font = UIFont.systemFont(ofSize: 15)
        screenlabel1.textColor = UIColor(hex: 0x333333)
        screenlabel1.textAlignment = NSTextAlignment.left
        screenView.addSubview(screenlabel1)
        /// switch 宽高目测是系统固定了，没法修改。
        switchView = UISwitch.init(frame: CGRect.init(x: ScreenWidth - 51 - 15, y: 0, width: 51, height: 31))
        switchView.onTintColor = TSColor.main.theme
        switchView.centerY = 50 / 2.0
        switchView.isOn = (emGroup?.isBlocked)!
        screenView.addSubview(switchView)
        switchView.addTarget(self, action: #selector(blockMessage), for: UIControlEvents.valueChanged)
         */
    }

    // MARK: - 开启进群审核
    func blockMessage(switchView: UISwitch) {

    }

    // MARK: - 转让群主
    func changeGroupOwner() {
        let vc = TSGroupNewOwnerVC()
        vc.originDataSource = NSMutableArray(array: self.originDataSource)
        vc.originData = NSDictionary(dictionary: self.originData)
        let ownerId = self.originData["owner"]
        let groupOwnerID = "\(ownerId ?? "")"
        vc.ownerId = groupOwnerID
        vc.bePresentVC = self
        self.present(vc, animated: true) {
        }
        vc.dismissBlock = {
            /// 返回到聊天详情页面
            if let childVCList = self.navigationController?.childViewControllers {
                for (_, childVC) in childVCList.enumerated() {
                    if childVC is TSGroupDataViewController {
                        self.navigationController?.popToViewController(childVC, animated: true)
                        break
                    }
                }
            }
        }
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
