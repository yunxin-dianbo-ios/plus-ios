//
//  NewsVerifyState.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

/// 资讯审核状态
///
/// - normal: 正常
/// - waitVerify: 等待审核
/// - draft: 稿件
/// - rejected: 驳回
/// - deleted: 删除
/// - refund: 退款
enum NewsVerifyState: Int {
    case normal = 0
    case waitVerify
    case draft
    case rejected
    case deleted
    case refund
}

/// 审核状态和数字的相互转换
class TSNewsVerifyStateTransfrom: TransformType {
    public typealias Object = NewsVerifyState
    public typealias JSON = Int

    func transformFromJSON(_ value: Any?) -> Object? {
        if let json = value as? Int {
            return NewsVerifyState(rawValue: json)
        }
        return nil
    }

    func transformToJSON(_ value: Object?) -> JSON? {
        if let object = value {
            return object.rawValue
        }
        return nil
    }
}
