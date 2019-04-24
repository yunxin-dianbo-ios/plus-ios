//
//  TSCurrentUserInfoSave.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/11/27.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSCurrentUserInfoSave: NSObject {

    /// 动态删除权限
    static let TSAccountManagerAuthority = "TSAccountManagerAuthority"
    var deleteFeed = false
    /// 问题删除权限
    static let TSAccounQuestionManagerAuthority = "TSAccounQuestionManagerAuthority"
    var deleteQuestion = false
    /// 回答删除权限
    static let TSAccounAnswerManagerAuthority = "TSAccounAnswerManagerAuthority"
    var deleteAnswer = false
    /// 资讯删除权限
    static let TSAccounNewManagerAuthority = "TSAccounNewManagerAuthority"
    var deleteNew = false
    
    func save() {
        UserDefaults.standard.setValue(self.deleteFeed, forKey: TSCurrentUserInfoSave.TSAccountManagerAuthority)
        UserDefaults.standard.setValue(self.deleteQuestion, forKey: TSCurrentUserInfoSave.TSAccounQuestionManagerAuthority)
        UserDefaults.standard.setValue(self.deleteAnswer, forKey: TSCurrentUserInfoSave.TSAccounAnswerManagerAuthority)
        UserDefaults.standard.setValue(self.deleteNew, forKey: TSCurrentUserInfoSave.TSAccounNewManagerAuthority)
        UserDefaults.standard.synchronize()
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: TSCurrentUserInfoSave.TSAccountManagerAuthority)
        UserDefaults.standard.removeObject(forKey: TSCurrentUserInfoSave.TSAccounQuestionManagerAuthority)
        UserDefaults.standard.removeObject(forKey: TSCurrentUserInfoSave.TSAccounAnswerManagerAuthority)
        UserDefaults.standard.removeObject(forKey: TSCurrentUserInfoSave.TSAccounNewManagerAuthority)
    }

    /// 通过沙盒内数据初始化
    // invalid redeclaration of init
    func getData() -> Bool {
        let token = UserDefaults.standard.bool(forKey: TSCurrentUserInfoSave.TSAccountManagerAuthority)
        self.deleteFeed = token
        return self.deleteFeed
    }

    // MARK: - 初始化问题管理权限
    func getQuestionManager() -> Bool {
        let token = UserDefaults.standard.bool(forKey: TSCurrentUserInfoSave.TSAccounQuestionManagerAuthority)
        self.deleteQuestion = token
        return self.deleteQuestion
    }

    // MARK: - 初始化回答管理权限
    func getAnswerManager() -> Bool {
        let token = UserDefaults.standard.bool(forKey: TSCurrentUserInfoSave.TSAccounAnswerManagerAuthority)
        self.deleteAnswer = token
        return self.deleteAnswer
    }

    // MARK: - 初始化资讯管理权限
    func getNewManager() -> Bool {
        let token = UserDefaults.standard.bool(forKey: TSCurrentUserInfoSave.TSAccounNewManagerAuthority)
        self.deleteNew = token
        return self.deleteNew
    }
}
