//
//  TSUUIDManager.swift
//  Thinksns Plus
//
//  Created by lip on 2017/1/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  UUID 管理

import UIKit
import KeychainAccess

class TSUUIDManager: NSObject {

    let UUIDKEY = "UUIDKey"
    let APPSERVICE = "com.zhiyicx.Thinksns-Plus.server-token"

    /// 存储UUID
    ///
    /// - Parameter UUID: 需要存储UUID信息
    func saveUUID(UUID: String) {
        let keychain = Keychain(service: APPSERVICE)
        keychain[UUIDKEY] = UUID
    }

    /// 读取设备的UUID
    ///
    /// - Returns: 返回读取到的UUID信息
    /// - warning: 默认首先读取UUID,如果读取为空的情况下,再获取并且存储UUID
    func readUUID() -> String? {
        let keychain = Keychain(service: APPSERVICE)
        return keychain[UUIDKEY]
    }

    /// 重置UUID
    func resetUUID() {
        let keychain = Keychain(service: APPSERVICE)
        keychain[UUIDKEY] = nil
    }

}
