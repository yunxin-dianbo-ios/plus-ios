//
//  TSGroupNameEditVC.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/25.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSGroupNameEditVC: TSViewController, UITextFieldDelegate {

    /// 聊天按钮
    var chatItem: UIButton?
    /// 提示文字 "编辑群名称，2-15个字符"
    var tipLabel = UILabel()
    var nameTextField = UITextField()
    /// 外部传进来的群昵称
    var originName: String? = ""

    /// 输出框内容
    var keyword = ""
    /// 从群信息页面传递过来的群信息原始数据
    var originData = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "编辑群名称"
        self.view.backgroundColor = UIColor(hex: 0xf4f5f5)
        NotificationCenter.default.addObserver(self, selector: #selector(textValueChange(notice:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        creatTopSubView()
        creatSubView()
        // Do any additional setup after loading the view.
    }

    // MARK: - 创建顶部视图
    func creatTopSubView() {

        chatItem = UIButton(type: .custom)
        chatItem?.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.setupNavigationTitleItem(chatItem!, title: "完成")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: chatItem!)

    }

    // MARK: - 子视图布局
    func creatSubView() {
        tipLabel = UILabel(frame: CGRect(x: 15, y: 0, width: ScreenWidth - 15, height: 30))
        tipLabel.text = "编辑群名称，2-15个字符"
        tipLabel.font = UIFont.systemFont(ofSize: 12)
        tipLabel.textColor = UIColor(hex: 0xb3b3b3)
        tipLabel.textAlignment = .left
        self.view.addSubview(tipLabel)

        nameTextField = UITextField(frame: CGRect(x: 0, y: tipLabel.bottom, width: ScreenWidth, height: 50))
        nameTextField.font = UIFont.systemFont(ofSize: 15)
        nameTextField.textColor = UIColor(hex: 0x333333)
        // 只显示前15个字符
        if (originName?.count)! > 15 {
            let index = originName?.index((originName?.startIndex)!, offsetBy: 15)
            nameTextField.text = originName?.substring(to: index!)
        } else {
            nameTextField.text = originName
        }
        nameTextField.backgroundColor = UIColor.white
        nameTextField.delegate = self

        let leftView = UIImageView()
        leftView.image = nil
        leftView.contentMode = .center
        leftView.backgroundColor = UIColor.white
        leftView.frame = CGRect(x: 0, y: 0, width: 15, height: 50)
        nameTextField.leftView = leftView
        nameTextField.leftViewMode = .always
        self.view.addSubview(nameTextField)
    }

    func rightButtonClick() {
        keyword = nameTextField.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        if keyword == "" || keyword == originName {
            navigationController?.popViewController(animated: true)
            return
        }
        /// 准备需要的参数
        let groupName = keyword
        let groupid = "\(self.originData["id"] ?? "")"
        let desc = "\(self.originData["description"] ?? "")"
        let ispublic = "\(self.originData["public"] ?? "")"
        let maxusers = "\(self.originData["maxusers"] ?? "")"
        let menbers_only = "\(self.originData["membersonly"] ?? "")"
        let allowinvites = "\(self.originData["allowinvites"] ?? "")"
        TSAccountNetworkManager().changeHyGroup(groupid: groupid, groupname: groupName, desc: desc, ispublic: ispublic, maxusers: maxusers, menbers_only: menbers_only, allowinvites: allowinvites, group_face: "") { (data, status) in
            guard status else {
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadgroupdata"), object: nil)

            /// 修改成功之后用群名称和群id,并且增加一个类型是修改群头像还是群昵称的操作，然后发通知告诉会话列表更新数据源UI
            var groupInfo = [String: Any]()
            groupInfo.updateValue(groupid, forKey: "id")
            groupInfo.updateValue("name", forKey: "changeType")
            groupInfo.updateValue(groupName, forKey: "name")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "editgroupnameorimage"), object: groupInfo)
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - 监听输入框文字变化
    func textValueChange(notice: NSNotification) {
        guard let textField = notice.object as? UITextField else {
            return
        }
        if textField == nameTextField {
            let str = nameTextField.text
            if !self.isInputRuleAndBlank(str: str!) {
                textField.text = self.disable_emoji(str: str!)
            }
            // 输入框文字字数上限
            let stringCountLimit = 15
            TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: stringCountLimit)
            let textA: NSString = textField.text as! NSString
            if textA.length >= 2 {
                chatItem?.isEnabled = true
                chatItem?.setTitleColor(TSColor.main.theme, for: .normal)
            } else {
                chatItem?.isEnabled = false
                chatItem?.setTitleColor(UIColor(hex: 0xb2b2b2), for: .normal)
            }
        }
    }

    //MARK - 过滤emoji
    func disable_emoji(str: String) -> String {

        let regex = try!NSRegularExpression(pattern: "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]", options: .caseInsensitive)

        let modifiedString = regex.stringByReplacingMatches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: str.count), withTemplate: "")

        return modifiedString
    }

    // MARK: - 匹配字母数字中文下划线等
    func isInputRuleAndBlank(str: String) -> Bool {
        let pattern = "^[a-zA-Z\\u4E00-\\u9FA5\\d\\s]*$"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        let isMatch = pred.evaluate(with: str)
        return isMatch
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
