//
//  ServerResponseDataTransforms.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  服务器响应数据转换

import Foundation
import ObjectMapper

class NumberArrayTransform: TransformType {

    func transformFromJSON(_ value: Any?) -> [Int]? {
        if let stringArray = value as? [String] {
            var intArray: [Int] = []
            for string in stringArray {
                guard let intItem = Int(string) else {
                    continue
                }
                intArray.append(intItem)
            }
            return intArray
        }
        if let intArray = value as? [Int] {
            return intArray
        }
        return []
    }

    func transformToJSON(_ value: [Int]?) -> [Int]? {
        return value
    }
}

// 处理单个字符串和Int的相互转换
class SingleStringTransform: TransformType {
    public typealias Object = Int
    public typealias JSON = String

    public init() {}
    func transformFromJSON(_ value: Any?) -> Int? {
        if let value = value as? String {
            return Int(value)
        } else if let value = value as? Int {
            return value
        }
        return nil
    }

    func transformToJSON(_ value: Int?) -> String? {
        if let value = value {
            return "\(value)"
        }
        return nil
    }
}

/// 评论的来源类型
///
/// - feed: 动态
/// - group: 圈子
/// - news: 资讯
/// - musicAlbum: 音乐专辑
/// - song: 歌曲
/// - question: 问题
/// - answers: 答案
enum ReceiveInfoSourceType: String {
    case feed = "feeds"
    case group = "group-posts"
    case news = "news"
    case musicAlbum = "music_specials"
    case song = "musics"
    case question = "questions"
    case answers = "question-answers"
}

class ReceiveInfoSourceTypeTransform: TransformType {
    public typealias Object = ReceiveInfoSourceType
    public typealias JSON = String

    open func transformFromJSON(_ value: Any?) -> ReceiveInfoSourceType? {
        if let type = value as? String {
            return ReceiveInfoSourceType(rawValue: type)
        }
        return nil
    }

    open func transformToJSON(_ value: ReceiveInfoSourceType?) -> String? {
        if let type = value {
            return type.rawValue
        }
        return nil
    }
}

/// CGSize 转换
///
/// - Note: "100x100" 和 CGSize(100, 100) 的相互转换
/// - Warning: 只能处理正整数
class CGSizeTransform: TransformType {
    public typealias Object = CGSize
    public typealias JSON = String

    public init() {}

    open func transformFromJSON(_ value: Any?) -> CGSize? {
        if let sizeString = value as? String {
            let sizeArray = sizeString.components(separatedBy: "x").map { Int($0) ?? NSNotFound }
            guard sizeArray.count == 2 else {
                assert(sizeArray.count == 2, "出现了无法解析的数据")
                return CGSize.zero
            }
            for i in sizeArray {
                assert(i != NSNotFound, "出现了无法解析的数据")
                guard i > 0 else {
                    return CGSize.zero
                }
            }
            return CGSize(width: sizeArray[0], height: sizeArray[1])
        }

        return nil
    }

    open func transformToJSON(_ value: Object?) -> String? {
        if let cgSize = value {
            return String(format: "%dx%d", cgSize.width, cgSize.height)
        }
        return nil
    }
}

/// 字符串数组处理 "1,2,3" 或者 "1,2,3,"转换为 [1, 2, 3]
class StringArrayTransfrom: TransformType {
    public typealias Object = Array<Int>
    public typealias JSON = String

    func transformFromJSON(_ value: Any?) -> Object? {
        if let string = value as? String {
            return string.convertedArray()
        }
        return nil
    }

    func transformToJSON(_ value: Object?) -> JSON? {
        if let array = value {
            var tempString = ""
            for element in array {
                tempString = tempString + "\(element),"
            }
            return tempString
        }
        return nil
    }
}

/// 字符串数组处理 "1,2,3" 或者 "1,2,3,"转换为 ["1", "2", "3"]
class StringArrayTransfromStrings: TransformType {
    public typealias Object = Array<String>
    public typealias JSON = String

    func transformFromJSON(_ value: Any?) -> Object? {
        if let string = value as? String {
            return string.convertedStringArray()
        }
        return nil
    }

    func transformToJSON(_ values: Object?) -> JSON? {
        if let array = values {
            var tempString = ""
            for value in array {
                tempString = tempString + value
            }
            return tempString
        }
        return nil
    }
}

/// 时间的相互转化处理, "2017-08-02 09:08:51" 和 Date
class TSDateTransfrom: TransformType {
    public typealias Object = Date
    public typealias JSON = String

    func transformFromJSON(_ value: Any?) -> Date? {
        if let dateString = value as? String {
            return dateString.dateConvertTo()
        }
        return nil
    }

    func transformToJSON(_ value: Object?) -> JSON? {
        if let date = value {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "GMT")
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter.string(from: date)
        }
        return nil
    }
}
/// 时间的相互转化处理, "2017-08-02 09:08:51" 和 Date
let TSDateTransform = TransformOf<Date, String>(fromJSON: { (value: String?) -> Date? in
    if let dateString = value {
        return dateString.dateConvertTo()
    }
    return nil
}) { (date: Date?) -> String? in
    if let date = date {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    return nil
}
let TSNSDateTransform = TransformOf<NSDate, String>(fromJSON: { (value: String?) -> NSDate? in
    if let dateString = value {
        return dateString.convertToDate()
    }
    return nil
}) { (date: NSDate?) -> String? in
    return date?.string(withFormat: "yyyy-MM-dd HH:mm:ss")
}

extension String {
    fileprivate func dateConvertTo(format: String = "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone? = TimeZone(identifier: "GMT")) -> Date? {
        let dateFormatter = DateFormatter()
        var date: Date?
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format
        //兼容新的时间格式
        // 2018-08-28T07:21:56Z
        if self.hasSuffix("Z") == true {
            var tempStr = self
            tempStr = tempStr.replacingAll(matching: "T", with: " ")
            tempStr = tempStr.replacingAll(matching: "Z", with: "")
            date = dateFormatter.date(from: tempStr)
        } else {
            date = dateFormatter.date(from: self)
        }
        return date
    }

    fileprivate func convertedArray() -> Array<Int>? {
        let stringArray = self.components(separatedBy: ",")
        var uids: Array<Int> = []
        if stringArray.isEmpty {
            return nil
        }
        for string in stringArray {
            if string == "" {
                continue
            }
            if let num = Int(string) {
                uids.append(num)
            }
        }
        return uids
    }

    fileprivate  func convertedStringArray() -> Array<String>? {
        let stringArray = self.components(separatedBy: ",")
        var strings: Array<String> = []
        if stringArray.isEmpty {
            return nil
        }
        for string in strings {
            if string == "" {
                continue
            }
            strings.append(string)
        }
        return strings
    }
}
