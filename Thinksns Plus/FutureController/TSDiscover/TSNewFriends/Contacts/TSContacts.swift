//
//  TSContacts.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  通讯录相关

import Contacts
import MessageUI

class TSContacts: NSObject {

    let store = CNContactStore()

}

// MARK: - 通讯录信息
extension TSContacts {

    /// 获取通讯录的访问权限
    func getAuthority() -> Bool {
        let authority = CNContactStore.authorizationStatus(for: .contacts)
        switch authority {
        case .authorized:
            // 有权限访问
            return true
        case .denied:
            // 用户明确拒绝访问权限
            let appName = TSAppConfig.share.localInfo.appDisplayName
            TSErrorTipActionsheetView().setWith(title: "通讯录权限设置", TitleContent: "该功能会使用到你的通讯录，是否允许\(appName)访问你的通讯录？", doneButtonTitle: ["允许", "取消"], complete: { (_) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.openURL(url!)
                }
            })
            return false
        case .notDetermined:
            // 用户没有决定 app 是否可以访问
            store.requestAccess(for: .contacts, completionHandler: { (_, _) in
            })
            return false
        case .restricted:
            // 用户无法更改访问状态，比如处于家长控制
            return false
        }
    }

    /// 获取通讯录的所有联系人信息
    func getContactsInfo() -> [TSContactModel] {
        do {
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName),CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey,CNContactGivenNameKey,CNContactFamilyNameKey] as [Any]
            let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
            var contacts = [CNContact]()
            do {
                try store.enumerateContacts(with: fetchRequest, usingBlock: { ( contact, stop) -> Void in
                    contacts.append(contact)
                })
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
            var models: [TSContactModel?] = []
            for contact in contacts {
                let model = TSContactModel(contact: contact)
                models.append(model)
            }
            return models.flatMap { $0 }
        } catch {
            TSLogCenter.log.debug(error)
            return []
        }
    }
}

// MARK: - 发送短信
extension TSContacts: MFMessageComposeViewControllerDelegate {

    /// 判断用户的设备能否发送短信
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }

    /// 发送短信视图控制器
    func getMessageVC() -> MFMessageComposeViewController {
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        return messageController
    }

    /// 发送短信视图控制器
    func getMessageVC(message: String, phones: [String]) -> MFMessageComposeViewController {
        let vc = getMessageVC()
        vc.recipients = phones
        vc.body = message
        return vc
    }

    // MARK: MFMessageComposeViewControllerDelegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        print(result)
        controller.dismiss(animated: true, completion: nil)
    }
}
