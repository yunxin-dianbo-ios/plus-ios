//
//  DataProcess.swift
//  
//
//  Created by lip on 2017/5/10.
//
//  服务器数据处理

import UIKit

extension Array {
    /// 将数组转为 字符串
    ///
    /// - Note: 
    ///     - 例如:[1,2,3] -> "1,2,3"
    ///     - 返回的字符串均以`,`分割,且末尾带字符
    /// - Warning: 只允许在和服务器通讯时,使用此类字符串
    public func convertToString() -> String? {
        if self.isEmpty {
            return nil
        }
        var tempArray: Array<String> = [String]()
        for number in self {
            tempArray.append("\(number)")
        }
        return tempArray.joined(separator: ",")
    }
}

extension Set {
    /// 将集合转为 字符串
    ///
    /// - Note:
    ///     - 例如:[1,2,3] -> "1,2,3"
    ///     - 返回的字符串均以`,`分割,且末尾带字符
    /// - Warning: 只允许在和服务器通讯时,使用此类字符串
    public func convertToString() -> String? {
        if self.isEmpty {
            return nil
        }
        var tempArray: Array<String> = [String]()
        for number in self {
            tempArray.append("\(number)")
        }
        return tempArray.joined(separator: ",")
    }
}
