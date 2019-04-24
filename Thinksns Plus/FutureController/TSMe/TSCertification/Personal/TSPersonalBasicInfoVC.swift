//
//  TSPersonalBasicInfoVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSPersonalBasicInfoVC: TSTableViewController, UITextViewDelegate {

    /// 真实姓名
    @IBOutlet weak var textfildForName: UITextField!
    /// 身份证号码
    @IBOutlet weak var textfieldForIdcard: UITextField!
    /// 手机号
    @IBOutlet weak var textfieldForPhone: UITextField!
    /// 确定按钮
    @IBOutlet weak var buttonForSure: TSColorLumpButton!
    /// 错误信息提示
    @IBOutlet weak var labelForPrompt: UILabel!

    /// 认证描述
    @IBOutlet weak var textviewForDescription: UITextView!
    /// 认证描述字数
    @IBOutlet weak var labelForWordsCount: UILabel!
    /// 认证描述的占位符
    @IBOutlet weak var labelForDescriptionPlaceholder: UILabel!

    /// 个人认证信息
    var model = TSUserCertificateObject()

    /// 输入框输入状态记录
    /// - 有值为 true, 反之为 false
    var accountUsable = ["name": false, "idcard": false, "phone": false, "description": false]
    /// 认证描述显示 labelForWordsCount 的字数
    let showWordsCountLabelLimit = 170
    /// 认证描述最大字数
    let maxWordsCountForDescription = 200
    /// 机构地址最大字数
    let maxWordsCountForAdress = 50
    /// 真实姓名最大字数
    let maxWordsCountForName = 8
    /// 电话的最大字数
    let maxWordsCountForPhone = 11
    /// 身份证号的最大位数
    let maxWordsCountForIdCard = 18

    // MARK: - Lifecycle
    class func basicInfoVC() -> TSPersonalBasicInfoVC {
        let sb = UIStoryboard(name: "TSPersonalCertification", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TSEnterpriseBasicInfoVC") as! TSPersonalBasicInfoVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    deinit {
        // 增加检测键盘输入状态的通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Custom user interface
    func setUI() {
        // 增加检测键盘输入状态的通知
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)

        title = "基本信息"
        buttonForSure.sizeType = .large
        tableView.mj_header = nil
        tableView.mj_footer = nil
        tableView.estimatedRowHeight = 54
        // 添加点击手势回收键盘
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tableView.addGestureRecognizer(tap)
        textviewForDescription.textContainerInset = UIEdgeInsets.zero
    }

    /// 回收键盘
    func endEditing() {
        view.endEditing(true)
    }

    /// textField 的输入情况发生了改变
    func textFiledDidChanged(notification: Notification) {
        // 输入框输入文字上限
        var stringCountLimit = 999
        // 输入框类型 key
        if let textField = notification.object as? UITextField {
            var stringType: String
            switch textField {
            case textfildForName:
                stringType = "name"
                stringCountLimit = maxWordsCountForName
            case textfieldForIdcard:
                stringType = "idcard"
                stringCountLimit = maxWordsCountForIdCard
            case textfieldForPhone:
                stringType = "phone"
                stringCountLimit = maxWordsCountForPhone
            default:
                return
            }
            if textField.text == nil || textField.text == "" {
                // 更新输入框输入状态
                accountUsable.updateValue(false, forKey: stringType)
            } else {
                accountUsable.updateValue(true, forKey: stringType)
                TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: stringCountLimit)
            }
            updateSureButtonStatus()
        }
    }

    /// 更新确认按钮的点击状态
    func updateSureButtonStatus() {
        buttonForSure.isEnabled = true
        for (_, value) in accountUsable {
            if !value {
                buttonForSure.isEnabled = false
            }
        }
    }

    /// 检查用户输入的信息格式是否正确
    func isMessageFormatterRight() -> Bool {
        labelForPrompt.isHidden = false
        labelForPrompt.text = ""
        if !TSAccountRegex.isPhoneNnumberFormat(textfieldForPhone.text) {
            labelForPrompt.text = "提示信息_手机号格式不正确".localized
            return false
        }
        if !TSAccountRegex.isIdcardFormart(textfieldForIdcard.text) {
            labelForPrompt.text = "提示信息_身份证格式不正确".localized
            return false
        }
        return true
    }

    // MAKR: - IBAction

    /// 点击了确定按钮
    @IBAction func sureButtonTaped() {
        guard isMessageFormatterRight() else {
            return
        }
        // 1.用 model 保存用户输入的信息
        model.name = textfildForName.text!
        model.number = textfieldForIdcard.text!
        model.phone = textfieldForPhone.text!
        model.desc = textviewForDescription.text!
        model.type = "user"
        // 2.跳转到上传资料页
        let vc = TSUploadCertificateVC.uploadVC()
        vc.imageCountMax = 2
        vc.imageCountMin = 2
        // 3.设置上传资料页提交按钮点击结束事件
        vc.finishOperation = { [weak self] (imageIds: [Int], imageSize: [CGSize], alert: TSIndicatorWindowTop?)  in
            guard let weakSelf = self else {
                alert?.dismiss()
                return
            }
            // 3.1 将图片信息添加到 model 中
            for (index, id) in imageIds.enumerated() {
                let imageObj = TSImageObject()
                let size = imageSize[index]
                imageObj.storageIdentity = id
                imageObj.height = size.height
                imageObj.width = size.width
                weakSelf.model.files.append(imageObj)
            }
            // 3.3 通过 obejct 启动 上传用户认证信息 的任务
            TSDataQueueManager.share.userInfoQueue.uploadCertificate(object: weakSelf.model, complete: { [weak self] (isSuccess, message) in
                alert?.dismiss()
                guard let weakSelf = self else {
                    return
                }
                // 4.根据任务结果显示弹窗提示用户
                let alert = TSIndicatorWindowTop(state: isSuccess ? .success : .faild, title: message)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                // 跳转回一开始的界面
                guard var count = weakSelf.navigationController?.childViewControllers.count, isSuccess else {
                    return
                }
                count -= 3
                guard let backVC = weakSelf.navigationController?.childViewControllers[count] else {
                    return
                }
                _ = weakSelf.navigationController?.popToViewController(backVC, animated: true)
            })
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Delegate

    // MARK: UITableViewDelegate, UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row == 3 else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        if labelForWordsCount.isHidden == true {
            if textviewForDescription.isScrollEnabled == true {
                // 90 + 10 + 10
                return 110
            }
            // 10 + 10
            return textviewForDescription.contentSize.height + 20
        }
        // 90 + 10 + (15 * 2)
        return 130 + labelForWordsCount.frame.height
    }

    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        // 0.更新输入框输入状态
        let noSpacingString = textviewForDescription.text?.trimmingCharacters(in: .whitespaces)
        accountUsable.updateValue((noSpacingString?.count)! > 0, forKey: "description")
        updateSureButtonStatus()
        // 2.判断是否隐藏字数提示 label
        let string = textView.text!
        let stringLenth = string.count
        if stringLenth > showWordsCountLabelLimit {
            labelForWordsCount.isHidden = false
        } else {
            labelForWordsCount.isHidden = true
        }
        // 3.限制字数
        if stringLenth > maxWordsCountForDescription {
            TSAccountRegex.checkAndUplodTextFieldText(textField: textviewForDescription, stringCountLimit: maxWordsCountForDescription)
        }
        // 4.设置字数 label 显示内容
        labelForWordsCount.text = "\(stringLenth > 200 ? 200 : stringLenth)/200"
        // 5.根据高度判断 textView 是否可滚动
        let textViewHeight = textviewForDescription.frame.height
        if textViewHeight >= 90 {
            textviewForDescription.isScrollEnabled = true
        }
        if textviewForDescription.contentSize.height < 90 {
            textviewForDescription.isScrollEnabled = false
        }
        textviewForDescription.scrollRangeToVisible(NSRange(location: 0, length: string.count))
        // 1.让 table view 重新计算高度
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    var scrollTag: Int?

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 不允许用户输入换行符
        if text == "\n" {
            return false
        }
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        // 隐藏认证描述 textview 的占位符 label
        labelForDescriptionPlaceholder.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textviewForDescription.text == "" {
            // 显示认证描述 textview 的占位符 label
            labelForDescriptionPlaceholder.isHidden = false
        }
    }

}
