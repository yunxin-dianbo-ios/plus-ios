//
//  TSDateExtension.swift
//  ThinkSNS +
//
//  Created by lip on 2017/4/26.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  时间处理扩展

import UIKit

extension NSDate {
    func convertToSecond() -> Int {
        return Int(self.timeIntervalSince1970)
    }

    func convertToMillisecond() -> Int {
        return Int(self.timeIntervalSince1970 * 1_000)
    }

}

public extension Date {

    /// 格式化输出时间  使用UTC时区表示时间  如：yyyy-MM-dd HH:mm:ss
    public func string(format: String = "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone? = TimeZone.current) -> String {
        let dateFormatter = DateFormatter()
        // 设置 格式化样式
        dateFormatter.dateFormat = format
        // 设置时区
        dateFormatter.timeZone = timeZone
        let strDate = dateFormatter.string(from: self)
        return strDate
    }
}
