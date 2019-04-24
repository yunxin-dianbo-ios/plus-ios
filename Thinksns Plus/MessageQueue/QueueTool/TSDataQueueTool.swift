//
//  TSTSMessageQueueTool.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSDataQueueTool: NSObject {

    /// 拼接url
    ///
    /// - Parameters:
    ///   - currentUrl: 当前请求链接
    ///   - stitchFirstString: 第一段需要拼接的字段
    ///   - stitchSecondString: 第二段需要拼接的字段（没有第二段就传nil或者空字符串）
    /// - Returns: 返回拼接好的字段
    class func handleCharacterStitching(currentUrl: String, stitchFirstId: Int) -> String {

        let str = currentUrl + "/" + "\(stitchFirstId)"
        return str
    }
}
