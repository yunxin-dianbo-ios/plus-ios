//
//  TSStringExtension.swift
//  Thinksns Plus
//
//  Created by GorCat on 16/12/29.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  String 的扩展

import UIKit
import Regex
import Kingfisher

// MARK: - 正则表达式判断

extension String {
    /// 正则匹配判断
    /// TODO: - 这里的正则判断似乎有问题。下面地方一起使用时就会出问题。待研究解决
//    /// 判断是否含有图片
//    func ts_isContainImageNode() -> Bool {
//        let imgRegex = "@!\\[(.*)]\\(([0-9]+)\\)"
//        return self.isMatchRegex(imgRegex)
//    }
    func isMatchRegex(_ regex: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}

// MARK: - 字符串与时间的相互转换

extension String {
    /// 将字符串转换为Date
    @available(*, deprecated, message: "服务器提供的时间格式不允许再使用该方式转换,查看 TransformType")
    func date(format: String = "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone? = TimeZone(identifier: "GMT")) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }

    /// 将时间格式转换为 date
    @available(*, deprecated, message: "服务器提供的时间格式不允许再使用该方式转换,查看 TransformType")
    func convertToDate() -> NSDate {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var date = dateFormatter.date(from: self)
        if date == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            date = dateFormatter.date(from: self)
        }
        return NSDate(timeIntervalSince1970: date!.timeIntervalSince1970)
    }
}

// MARK: - 字符串长宽计算

extension String {

    func size(maxSize: CGSize, font: UIFont, lineMargin: CGFloat = 0) -> CGSize {
        let options: NSStringDrawingOptions = NSStringDrawingOptions.usesLineFragmentOrigin
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineMargin // 行间距
        var attributes = [String: Any]()
        attributes[NSFontAttributeName] = font
        attributes[NSParagraphStyleAttributeName] = paragraphStyle
        let str = self as NSString
        let textBounds = str.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        return textBounds.size
    }

    // MARK: - Old 字符串长宽计算

    /// 获取字符宽度
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSFontAttributeName: font]
        let size = self.size(attributes: fontAttributes)
        return size
    }

    /// 计算属性文本的高度
    /// 注意： 使用此方法计算高度之前请保证你的属性文本是否设置了正确的属性 否则计算结果不准确概不负责
    ///
    /// - Parameters:
    ///   - attributeString: 待计算的文本
    ///   - maxWidth: 最大宽度
    ///   - maxHeight: 最大高度
    /// - Returns: 文本高度
    static func getAttributeStringHeight(attributeString: NSMutableAttributedString, maxWidth: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let strSize = attributeString.boundingRect(with:CGSize(width: maxWidth, height: maxHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        return strSize.height
    }

    /// 获取固定宽度的字符串高度
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.height
    }

    // MARK: - 计算字符串宽高
    func heightWithConstrainedWidth(width: CGFloat, height: CGFloat, font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: width, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.size
    }
}

// MARK: - 其他杂项

extension String {

    /// 本地化字符串
    /// - note 请前往 infoPlist.strings 手动添加各语言信息
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }

    /// 裁切字段
    func subString(with range: NSRange) -> String {
        return TSCommonTool.getStriingFrom(self, rang: range)
    }

    /// 将字符串数组转为 数组
    /// 例如 "1,2,3" -> [1, 2, 3]
    @available(*, deprecated, message: "服务器提供的时间格式不允许再使用该方式转换,查看 TransformType")
    func convertNumberArray() -> Array<Int>? {
        let stringArray = self.components(separatedBy: ",")
        var uids: Array<Int> = []
        if stringArray.isEmpty {
            return nil
        }
        for string in stringArray {
            if string == "" {
                continue
            }
            uids.append(Int(string)!)
        }
        return uids
    }

    /// 快速返回一个缓存目录的路径
    func cacheDir() -> String {
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        return (cachePath as NSString).appendingPathComponent((self as NSString).pathComponents.last!)
    }
}

// MARK: - NSMutableAttributedString

extension String {
    // Remark: - 哪个无聊的人写的下面的方法
    /// 返回自定义属性文本 【字号、行间距】
    ///
    /// - Parameters:
    ///   - string: 原文本
    ///   - font: 字号
    ///   - lineSpacing: 行间距
    ///   - textAlignment: 文本对齐方式
    /// - Returns: 格式化后的属性文本
    static func setStyleAttributeString(string: String, font: UIFont, lineSpacing: CGFloat, textAlignment: NSTextAlignment) -> NSMutableAttributedString {
        let attributeSring = NSMutableAttributedString(string: string)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineSpacing = lineSpacing
        attributeSring .addAttributes([NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: font], range: NSRange(location: 0, length: CFStringGetLength(string as CFString!)))
        return attributeSring
    }
}

extension NSMutableAttributedString {

    /// 两种颜色和尺寸的字体
    ///
    /// - Parameters:
    ///   - first: 第一段文字的各种参数
    ///   - second: 第二段文字的各种参数
    /// - Returns: 返回拼接好的文字
    func differentColorAndSizeString(first : (firstString: NSString, firstColor: UIColor, firstSize: CGFloat), second : (secondString: NSString, secondColor: UIColor, secondSize: CGFloat)) -> NSMutableAttributedString {
        let noteStr = NSMutableAttributedString(string: "\(first.firstString)"+"\(second.secondString)")
        let fStr: NSString = (noteStr.string as NSString?)!
        let fRange: NSRange = (fStr.range(of: first.firstString as String))

        let rangeOne = NSRange(location: fRange.location, length: fRange.length)
        noteStr.addAttribute(NSForegroundColorAttributeName, value: first.firstColor, range: rangeOne)

        let sRange: NSRange = (fStr.range(of: second.secondString as String))
        let rangetwo = NSRange(location: sRange.location, length: sRange.length)
        noteStr.addAttribute(NSForegroundColorAttributeName, value: second.secondColor, range: rangetwo)

        noteStr.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: first.firstSize), range: rangeOne)
        noteStr.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: second.secondSize), range: rangetwo)

        return noteStr
    }

    // 便利构造
    class func attString(str: String, font: UIFont, color: UIColor) -> NSMutableAttributedString {
        let attString = NSMutableAttributedString(string: str)
        let allRange = NSRange(location: 0, length: attString.length)
        attString.addAttributes([NSForegroundColorAttributeName: color], range: allRange)
        attString.addAttributes([NSFontAttributeName: font], range: allRange)
        return attString
    }
    public convenience init(str: String, font: UIFont?, color: UIColor?) {
        self.init(string: str)
        let allRange = NSRange(location: 0, length: self.length)
        if let font = font {
            self.addAttribute(NSFontAttributeName, value: font, range: allRange)
        }
        if let color = color {
            self.addAttribute(NSForegroundColorAttributeName, value: color, range: allRange)
        }
    }
}

// MARK: - TS+相关的特定部分的String扩展，统一使用"ts_"前缀

extension String {
    func ts_serverLinkProcess() -> String {
        var strUrl = self
        let regex = Regex("[<|%3C|%3c](.*?)[>|%3E|%3e]")
        strUrl.replaceAll(matching: regex, with: "$1")
        return strUrl
    }
}

// TODO: - 多图片时的url处理、多图片时的正则处理都是有问题的，待解决。

extension String {
    /// 获取自定义markdown格式的图片正则表达式
    static func ts_customImageMarkdownRegexString() -> String {
        // ".*?" 懒惰匹配
        return "@!\\[(.*?)\\]\\((\\d+)\\)"
    }
    /// 获取标准markdown格式的图片的正则表达式
    static func ts_standardImageMarkdownRegexString() -> String {
        // ".*?" 懒惰匹配
        return "!\\[(.*?)\\]\\((.*?)\\)"
    }

    /// 获取图片的Regex
    static func ts_customImageMarkdownRegex() -> Regex {
        return Regex("@!\\[(.*?)\\]\\((\\d+)\\)")
    }
    static func ts_standardImageMarkdownRegex() -> Regex {
        return Regex("!\\[(.*?)\\]\\((.*?)\\)")
    }

}

extension String {

    /// 自定义的markdown格式的内容转展示的内容：将自定义格式的图片转换成 "[图片]"；将标准格式的图片转换成"[图片]"
    func ts_customMarkdownToNormal() -> String {
        var string: String = self
        // 1. 自定义图片处理
        string = string.ts_customMarkdownToStandard()
        // 2. 图片处理
        string = string.ts_standardMarkdownToNormal()
        return string
    }
    /// 标准markdown格式的内容转换成正常展示的内容，主要是图片处理：将标准格式的图片转换成"[图片]"
    func ts_standardMarkdownToNormal() -> String {
        var string: String = self
        // 1. 图片处理
        let imgRegex = String.ts_standardImageMarkdownRegex()
        string.replaceAll(matching: imgRegex, with: "[图片]")
        return string
    }
    /// 自定义的markdown格式的内容转展示的内容：将自定义格式的图片转换成 ""
    /// 比如帖子列表中内容的自定义标签处理
    func ts_customMarkdownToClearString() -> String {
        var string: String = self
        let imgRegex = String.ts_customImageMarkdownRegex()
        string.replaceAll(matching: imgRegex, with: "")
        return string
    }
    /// 标准markdown格式的内容转换成正常展示的内容，主要是图片处理：将标准格式的图片转换成""
    /// 比如用于非问答类型的markdown发布之前的处理
    func ts_standardMarkdownToClearString() -> String {
        var string: String = self
        string = string.ts_customMarkdownToStandard()
        // 1. 图片处理
        let imgRegex = String.ts_standardImageMarkdownRegex()
        string.replaceAll(matching: imgRegex, with: "")
        return string
    }

    /// 判断自定义markdown是否含有自定义格式图片
    func ts_customMarkdownIsContainImageCode() -> Bool {
        let imageRegex = String.ts_customImageMarkdownRegex()
        return imageRegex.matches(self)
    }
    /// 判断标准markdown是否含有标准格式图片
    func ts_standardMarkdownIsContainImage() -> Bool {
        let imageRegex = String.ts_standardImageMarkdownRegex()
        return imageRegex.matches(self)
    }

    /// 自定义markdown格式转标准markdown格式，主要是图片处理，将自定义格式的图片处理成标准格式的图片
    func ts_customMarkdownToStandard() -> String {
        var string: String = self
        // 图片处理
        let url = TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue
        string.replaceAll(matching: String.ts_customImageMarkdownRegex(), with: String(format:"![$1](%@/$2)", url))
        return string
    }

    /// 获取自定义markdown格式下的图片id
    func ts_getCustomMarkdownImageId() -> [Int] {
        let string = self
        var imageList: [Int] = [Int]()
        let imgRegex = String.ts_customImageMarkdownRegex()
        let results = imgRegex.allMatches(in: string)
        for result in results {
            var strMatched = result.matchedString
            strMatched.replaceAll(matching: String.ts_customImageMarkdownRegex(), with: String(format:"$2"))
            if let imageId = Int(strMatched) {
                imageList.append(imageId)
            }
        }
        return imageList
    }
    /// 获取标准markdown格式中的图片
    func ts_getMarkdownImageUrl() -> [String] {
        let string = self
        var imageList: [String] = [String]()
        let imgRegex = String.ts_standardImageMarkdownRegex()
        let results = imgRegex.allMatches(in: string)
        for result in results {
            var strMatched = result.matchedString
            strMatched.replaceAll(matching: String.ts_standardImageMarkdownRegex(), with: String(format:"$2"))
            imageList.append(strMatched)
        }
        return imageList
    }

    /// 将标准markdown格式，转换成attributeString
    func ts_convertMarkdownToAttributeString(contentW: CGFloat, font: UIFont?, color: UIColor?) -> NSAttributedString? {
        return self.ts_convertStandardMarkdownToAttributeString(contentW: contentW, font: font, color:color)
    }
    /// 将标准markdown格式，转换成attributeString
    func ts_convertStandardMarkdownToAttributeString(contentW: CGFloat, font: UIFont?, color: UIColor?) -> NSAttributedString? {
        let attString = NSMutableAttributedString(string: "")
        var string: String = self
        // 1. 图片处理
        let imgRegex = String.ts_standardImageMarkdownRegex()
        while imgRegex.matches(string) {
            // 图片链接获取
            let result = imgRegex.firstMatch(in: string)!
            var strMatched = result.matchedString
            strMatched.replaceAll(matching: imgRegex, with: String(format:"$2"))
            let strImageUrl = strMatched
            // 图片前面部分的文字
            let frontStr: String = string.substring(to: result.range.lowerBound)
            attString.append(NSMutableAttributedString(str: frontStr, font: font, color: color))
            // 获取缓存中的图片 并 作为附件添加
            let chacheResult = ImageCache.default.isImageCached(forKey: strImageUrl)
            var image: UIImage?
            if chacheResult.cached, let chacheTye = chacheResult.cacheType {
                switch chacheTye {
                case .memory:
                    image = ImageCache.default.retrieveImageInMemoryCache(forKey: strImageUrl)
                case .disk:
                    image = ImageCache.default.retrieveImageInDiskCache(forKey: strImageUrl)
                default:
                    break
                }
            }
            if let image = image {
                // 图片作为附件添加
                let textAttachment = TSImageTextAttachment(data: nil, ofType: nil)
                // 设置附件的图片
                textAttachment.image = image
                // 标记附件
                textAttachment.fileId = strImageUrl.components(separatedBy: "/").last
                // 设置附件大小(图片宽度处理 的一种方案 设置附件的大小为等比例缩放后的尺寸)
                textAttachment.bounds = CGRect(x: 0, y: 0, width: contentW, height: image.size.height / image.size.width * contentW)
                //将附件转成NSAttributedString类型的属性化文本
                let textAttachmentString = NSAttributedString(attachment: textAttachment)
                attString.append(textAttachmentString)
            }

            string.replaceSubrange(result.range, with: "")
            string.replaceSubrange(Range<String.Index>(uncheckedBounds: (lower: string.startIndex, upper: result.range.lowerBound)), with: "")
        }
        // 拼接尾部的文字
        attString.append(NSMutableAttributedString(str: string, font: font, color: color))
        return attString
    }
    /// 从html文本中获取村文本信息
    func ts_filterMarkdownTagsToPlainText() -> String {
        var string: String = self
        string = string.replacingAll(matching: "</n>", with: "")
        string = string.replacingAll(matching: "&nbsp", with: "")
        // 1. 图片处理
        let imgRegex = Regex("<(\"[^\"]*\"|'[^']*'|[^'\">])*>")
        string.replaceAll(matching: imgRegex, with: "")
        return string
    }
}

extension String {

    /// 自定义格式的markdown 转换为 编辑器中markdown格式 - 主要是图片处理
    func ts_convertCustomMarkdownToEditMarkdown() -> (markdown: String, dicArray: [[String: Int]]) {
        var string: String = self
        var dicArray: [[String: Int]] = []
        // 图片处理
        var index = 0
        while String.ts_customImageMarkdownRegex().matches(string) {
            let matchResult = String.ts_customImageMarkdownRegex().firstMatch(in: string)!
            var strMarkdown = matchResult.matchedString
            strMarkdown.replaceAll(matching: String.ts_customImageMarkdownRegex(), with: "$2")
            let fileId = Int(strMarkdown)!
            let html = String.ts_imageHtmlWithFileId(fileId, imageIndex: index)
            string.replaceFirst(matching: String.ts_customImageMarkdownRegex(), with: html)
            let dic: [String : Int] = ["index": index, "fileId": fileId]
            dicArray.append(dic)
            index += 1
        }
        string.replaceAll(matching: "\n", with: "<br />")
        return (string, dicArray)
    }

    static func ts_imageHtmlWithFileId(_ fileId: Int, imageIndex: Int) -> String {
        let defaulthtml = ""
        // 获取缓存中的图片
        let cacheManager = TSWebEditorImageManager.default
        guard let cachenode = cacheManager.getImageNode(fileId: fileId) else {
            // 数据库中不存在处理
            return defaulthtml
        }
        let imageUrl = cachenode.filePath
        guard let image = UIImage(contentsOfFile: imageUrl) else {
            return defaulthtml
        }
        var html = ""
        let alt = ""
        let width = Int(UIScreen.main.bounds.size.width - 15 * 2 - 10 * 2) // 边距
        let height = Int(image.size.height / image.size.width * CGFloat(width))
        html += "<div><div class='image' id='image\(imageIndex)'>"
        html += "<img class='myimg' src='\(imageUrl)' alt='\(alt)' width='\(width)' height='\(height)' />"
        html += "<div class='failure'></div>"
        //html += "<div class='markdown'>@![image](\(fileId))<br /></div>" // 上面的用法造成死循环
        html += "<div class='markdown'></div>"
        html += "</div></div>"
        return html
    }

}
extension String {
  ///  修改某些字符串的颜色以及背景颜色
  ///
  /// - Parameters:
  ///   - loc: 开始位子
  ///   - len: 长度
  ///   - color: 颜色
  ///   - backgroundColor: 背景颜色（可以为nil）
  /// - Returns: 富文本
  func   ts_attrStringloc (loc: NSInteger, len: NSInteger, color: UIColor, backgroundColor: UIColor?) -> NSMutableAttributedString {
    let attriString = NSMutableAttributedString(string: self)
    attriString.addAttributes( [NSForegroundColorAttributeName: color], range: NSRange(location: loc, length: len))
    if backgroundColor != nil {
        attriString.addAttributes([NSBackgroundColorAttributeName: backgroundColor as Any], range: NSRange(location: loc, length: len))
    }
    return attriString
    }

    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from), length: utf16.distance(from: from, to: to))
    }
}
