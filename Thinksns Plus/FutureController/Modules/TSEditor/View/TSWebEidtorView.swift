//
//  TSWebEidtorView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 22/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  使用UIWebView实现的编辑器

import UIKit
import JavaScriptCore

/// 编辑器协议
protocol TSEditorProtocol {

}

/// WbeView编辑器
class TSWebEidtorView: UIWebView {

    // MARK: - Internal Property

    // MARK: - Private Property

    /// 是否格式化html标记
    fileprivate var formatHTML: Bool = false
    /// html相关是否加载，用于加载数据时判断
    fileprivate var resourcesLoaded: Bool = false
    /// 编辑器是否加载，用于直接设置html代码时判断
    fileprivate var editorLoaded: Bool = false
    ///
    fileprivate var internalHTML: String = ""

    // MARK: - Initialize Function
    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        self.hidesInputAccessoryView = true
        self.keyboardDisplayRequiresUserAction = false
        self.scalesPageToFit = true
        //self.dataDetectorTypes = UIDataDetectorTypeNone(rawValue: 0)
        self.backgroundColor = UIColor.white
        self.scrollView.bounces = false
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        self.scrollView.alwaysBounceHorizontal = false
    }

}

// MARK: - Private  数据加载

extension TSWebEidtorView {
    /// 加载数据
    func loadData() -> Void {
        if !self.resourcesLoaded {
            self.loadLocalHtmlData()
        }
        //self.formatHTML = true
    }

    /// 加载本地网页数据
    fileprivate func loadLocalHtmlData() -> Void {
        guard let htmlPath = Bundle.main.path(forResource: "common_editor", ofType: "html"), let jsPath = Bundle.main.path(forResource: "common_editor", ofType: "js") else {
            return
        }
        let htmlData: Data = try! Data(contentsOf: URL(fileURLWithPath: htmlPath))
        let jsData: Data = try! Data(contentsOf: URL(fileURLWithPath: jsPath))

        if var htmlString = String(data: htmlData, encoding: String.Encoding.utf8), let jsString = String(data: jsData, encoding: String.Encoding.utf8) {
            if let type = UserDefaults.standard.object(forKey: "webEditorType") as? String {
                if (type == "question") {
                    htmlString = htmlString.replacingOccurrences(of: "输入要说的话，图文结合更精彩哦", with: "详情描述你的问题，有助于受到准确的回答")
                } else if (type == "reply") {
                    htmlString = htmlString.replacingOccurrences(of: "输入要说的话，图文结合更精彩哦", with: "请输入你的回答")
                }
                UserDefaults.standard.removeObject(forKey: "webEditorType")
                UserDefaults.standard.synchronize()
            }
            let html = htmlString.replacingOccurrences(of: "<!--editor-->", with: jsString)
            self.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
            self.resourcesLoaded = true
        }
        //self.loadCustomCss()
    }
    /// 加载自定义CSS文件
    fileprivate func loadCustomCss() -> Void {
        guard let cssPath = Bundle.main.path(forResource: "common_editor", ofType: "css") else {
            return
        }
        let cssData: Data = try! Data(contentsOf: URL(fileURLWithPath: cssPath))
        if let cssString = String(data: cssData, encoding: String.Encoding.utf8) {
            let js = String(format: "webeditor.setCustomCSS(\"%@\");", cssString)
            self.executeJS(js)
        }
    }

}

// MARK: - Internal Function

extension TSWebEidtorView {
    /// 执行js
    @discardableResult
    func executeJS(_ js: String) -> String? {
        TSLogCenter.log.debug(js)
        let jsResult = self.stringByEvaluatingJavaScript(from: js)
        TSLogCenter.log.debug(jsResult)
        return jsResult
    }

    func prepareInsert() -> Void {
        let js = "webeditor.prepareInsert();"
        self.executeJS(js)
    }
}

// MARK: - Html

extension TSWebEidtorView {

    func setHTML(_ html: String) -> Void {
        self.internalHTML = html
        if self.editorLoaded {
            self.updateHTML()
        }
    }

    func updateHTML() -> Void {
        let html = self.internalHTML
        let cleanedHTML = self.removeQuotesFromHTML(html)
        let trigger = String(format: "webeditor.setHTML(\"%@\");", cleanedHTML)
        self.stringByEvaluatingJavaScript(from: trigger)
    }

    func getHTML() -> String? {
        if var html = self.stringByEvaluatingJavaScript(from: "webeditor.getHTML();") {
            html = self.removeQuotesFromHTML(html)
            html = self.tidyHTML(html)
            return html
        }
        return nil
    }

    func insertHTML(_ html: String) -> Void {
        let cleanedHTML = self.removeQuotesFromHTML(html)
        let trigger = String(format: "webeditor.insertHTML(\"%@\");", cleanedHTML)
        self.executeJS(trigger)
    }
}

// MARK: - setContent

extension TSWebEidtorView {
    func setContentWithMarkdown(_ markdown: String) -> Void {
        let js: String = String(format: "webeditor.setContentWithMarkdown(\"%@\");", markdown)
        self.executeJS(js)
    }
    /// markdown加载完成后的图片响应事件添加
    func markdownLoadedImageActionProcess() -> Void {
        let js: String = String(format: "webeditor.loadedImageActionProcess()")
        self.executeJS(js)
    }
    /// markdown加载加载完成后图片markdown字段添加
    func markdownLoadedImageProcess(dicArray: [[String: Int]]) -> Void {
        for dic in dicArray {
            if let index = dic["index"], let fileId = dic["fileId"] {
                let js: String = String(format: "webeditor.loadedImageProcess(\"%d\", \"%d\");", index, fileId)
                self.executeJS(js)
            }
        }
    }
}

// MARK: - 高度

extension TSWebEidtorView {
    func setFooterHeight(_ height: CGFloat) -> Void {
        let js: String = String(format: "webeditor.setFooterHeight(\"%f\");", height)
        self.executeJS(js)
    }
    func setContentHeight(_ height: CGFloat) -> Void {
        let js: String = String(format: "webeditor.contentHeight = %f;", height)
        self.executeJS(js)
    }
    func setContentMinHeight(_ height: CGFloat) -> Void {
        let js: String = String(format: "webeditor.setContentMinHeight(\"%f\")", height)
        self.executeJS(js)
    }
}

// MARK: - 光标 聚焦

extension TSWebEidtorView {
    func focusContentEditor() -> Void {
        let js: String = String(format: "webeditor.focusEditor();")
        self.executeJS(js)
    }
    func blurContentEditor() -> Void {
        let js: String = String(format: "webeditor.blurEditor();")
        self.executeJS(js)
    }
}

// MARK: - 内容

extension TSWebEidtorView {

    func setPlaceholderText(_ placeholder: String) -> Void {
        let js: String = String(format: "webeditor.setPlaceholder(\"%@\");", placeholder)
        self.executeJS(js)
    }

    func getContentMarkdown() -> String? {
        let trigger = String(format: "webeditor.getContentMarkdown();")
        return self.executeJS(trigger)
    }
    func getContentText() -> String? {
        let trigger = "webeditor.getContentText();"
        return self.executeJS(trigger)
    }

}

// MARK: - TWRichTextStyle样式

extension TSWebEidtorView {

    func setTextStyle(_ textStyle: TSEditorTextStyle, selectedState: Bool) -> Void {
        switch textStyle {
        case .bold:
            self.setBold()
        case .italic:
            self.setItalic()
        case .strikethrough:
            self.setStrikethrough()
        case .h1:
            self.heading1()
        case .h2:
            self.heading2()
        case .h3:
            self.heading3()
        case .h4:
            self.heading4()
        case .hr:
            self.setHR()
        case .undo:
            self.undo()
        case .redo:
            self.redo()
        case .blockquote:
            if selectedState {
                self.removeBlockquote()
            } else {
                self.setBlockquote()
            }
        default:
            break
        }
    }

}
/// TWRichTextStyle下的style支持
extension TSWebEidtorView {

    func setBold() -> Void {
        let js: String = String(format: "webeditor.setBold();")
        self.executeJS(js)
    }

    func setItalic() -> Void {
        let js: String = String(format: "webeditor.setItalic();")
        self.executeJS(js)
    }

    func setUnderline() -> Void {
        let js: String = String(format: "webeditor.setUnderline();")
        self.executeJS(js)
    }

    func setStrikethrough() -> Void {
        let js: String = String(format: "webeditor.setStrikeThrough();")
        self.executeJS(js)
    }

    func setHR() -> Void {
        //let js: String = String(format: "webeditor.setHorizontalRule();")
        //self.executeJS(js)
        self.insertHTML("<div><hr /><br /></div>")
    }

    func setBlockquote() -> Void {
        let js: String = String(format: "webeditor.setBlockquote();")
        self.executeJS(js)
    }

    func removeBlockquote() -> Void {
        let js: String = String(format: "webeditor.removeBlockquote();")
        self.executeJS(js)
    }

    func heading1() -> Void {
        let js: String = String(format: "webeditor.setHeading('h1');")
        self.executeJS(js)
    }
    func heading2() -> Void {
        let js: String = String(format: "webeditor.setHeading('h2');")
        self.executeJS(js)
    }
    func heading3() -> Void {
        let js: String = String(format: "webeditor.setHeading('h3');")
        self.executeJS(js)
    }
    func heading4() -> Void {
        let js: String = String(format: "webeditor.setHeading('h4');")
        self.executeJS(js)
    }
    func heading5() -> Void {
        let js: String = String(format: "webeditor.setHeading('h5');")
        self.executeJS(js)
    }
    func heading6() -> Void {
        let js: String = String(format: "webeditor.setHeading('h6');")
        self.executeJS(js)
    }

    func undo() -> Void {
        let js: String = String(format: "webeditor.undo();")
        self.executeJS(js)
    }
    func redo() -> Void {
        let js: String = String(format: "webeditor.redo();")
        self.executeJS(js)
    }

}

// MARK: - Other Style

extension TSWebEidtorView {
    func removeFormat() -> Void {
        let js: String = String(format: "webeditor.removeFormating();")
        self.executeJS(js)
    }

    func alignLeft() -> Void {
        let js: String = String(format: "webeditor.setJustifyLeft();")
        self.executeJS(js)
    }
    func alignCenter() -> Void {
        let js: String = String(format: "webeditor.setJustifyCenter();")
        self.executeJS(js)
    }
    func alignRight() -> Void {
        let js: String = String(format: "webeditor.setJustifyRight();")
        self.executeJS(js)
    }
    func alignFull() -> Void {
        let js: String = String(format: "webeditor.setJustifyFull();")
        self.executeJS(js)
    }

    func setUnorderedList() -> Void {
        let js: String = String(format: "webeditor.setUnorderedList();")
        self.executeJS(js)
    }
    func setOrderedList() -> Void {
        let js: String = String(format: "webeditor.setOrderedList();")
        self.executeJS(js)
    }

    func setSubscript() -> Void {
        let js: String = String(format: "webeditor.setSubscript();")
        self.executeJS(js)
    }
    func setSuperscript() -> Void {
        let js: String = String(format: "webeditor.setSuperscript();")
        self.executeJS(js)
    }

    func setIndent() -> Void {
        let js: String = String(format: "webeditor.setIndent();")
        self.executeJS(js)
    }
    func setOutdent() -> Void {
        let js: String = String(format: "webeditor.setOutdent();")
        self.executeJS(js)
    }

    func paragraph() -> Void {
        let js: String = String(format: "webeditor.setParagraph();")
        self.executeJS(js)
    }

}

// MARK: - 链接

extension TSWebEidtorView {
    /// 插入链接
    func insertLink(url: String, title: String) -> Void {
//        self.executeJS("webeditor.prepareInsert();")
        // 注意：上面注释部分需要再键盘关闭之前使用，否则插入失败。同理，插入图片、插入html代码都一样。
        // url校验，scheme + 服务器，不符合该格式则添加"zhiyi"格式的scheme。
        // js里插入链接时校验 "[\\s\\S]+:[\\s\\S]+"
        let js = String(format: "webeditor.insertLink(\"%@\", \"%@\");", url, title)
        self.executeJS(js)
    }

    /// 修改链接
    func updateLink(url: String, title: String) -> Void {
//        self.executeJS("webeditor.prepareInsert();")
        let js = String(format: "webeditor.updateLink(\"%@\", \"%@\");", url, title)
        self.executeJS(js)
    }

    /// 移除链接
    func removeLink() -> Void {
        self.executeJS("webeditor.unlink();")
    }

    /// quickLink
    func quickLink() -> Void {
        self.executeJS("webeditor.quickLink();")
    }
}

// MARK: - 图片

extension TSWebEidtorView {
    func insertImage(url: String, alt: String) -> Void {
        self.executeJS("webeditor.prepareInsert();")
        let trigger = String(format: "webeditor.insertImage(\"%@\", \"%@\");", url, alt)
        self.executeJS(trigger)
    }

    func updateImage(url: String, alt: String) -> Void {
        self.executeJS("webeditor.prepareInsert();")
        let trigger = String(format: "webeditor.updateImage(\"%@\", \"%@\");", url, alt)
        self.executeJS(trigger)
    }

    func insertImage(url: String, imageIndex: Int, alt: String, width: CGFloat, height: CGFloat) -> Void {
        self.executeJS("webeditor.prepareInsert();")
        let trigger = String(format: "webeditor.insertImageUrl(\"%@\", \"%d\", \"%@\", \"%f\", \"%f\");", url, imageIndex, alt, width, height)
        self.executeJS(trigger)
    }

    func insertImage(_ image: UIImage, imageIndex: Int, alt: String, width: CGFloat, height: CGFloat) -> Void {
        // 若需查看html源码，base64太长，不便于查看html结构
        //let base64String = "base64ForJpgImage"
        let base64String = self.base64ForJpgImage(image)
        self.insertImage(base64String: base64String, imageIndex: imageIndex, alt: alt, width: width, height: height)
    }
    func insertImage(base64String: String, imageIndex: Int, alt: String, width: CGFloat, height: CGFloat) -> Void {
        self.executeJS("webeditor.prepareInsert();")
        let trigger = String(format: "webeditor.insertImageBase64String(\"%@\", \"%d\", \"%@\", \"%f\", \"%f\");", base64String, imageIndex, alt, width, height)
        self.executeJS(trigger)
    }

    func removeImage(imageIndex: Int) -> Void {
        let trigger = String(format: "webeditor.removeImage(\"%d\")", imageIndex)
        self.executeJS(trigger)
    }

    /// 上传图片成功
    func uploadImageSuccess(imageIndex: Int, fileId: Int) -> Void {
        let trigger = String(format: "webeditor.uploadImageSuccess(\"%d\", \"%d\")", imageIndex, fileId)
        self.executeJS(trigger)
    }
    /// 上传图片失败
    func uploadImageFailure(imageIndex: Int) -> Void {
        /// html界面展示处理
        let trigger = String(format: "webeditor.uploadImageFailure(\"%d\")", imageIndex)
        self.executeJS(trigger)
    }

    func base64SourceForJpegImage(_ image: UIImage) -> String {
        guard let imgData = UIImageJPEGRepresentation(image, 1.0) else {
            return ""
        }
        let imageSource = String(format: "data:image/jpg;base64,%@", imgData.base64EncodedString())
        return imageSource
    }
    func base64ForJpgImage(_ image: UIImage) -> String {
        guard let imgData = UIImageJPEGRepresentation(image, 1.0) else {
            return ""
        }
        return imgData.base64EncodedString()
    }

    /// 根据图片索引id判断该图片是否存在
    func isExistImage(imageIndex: Int) -> Bool {
        let trigger = String(format: "webeditor.isExistImage(\"%d\");", imageIndex)
        var isExistFlag: Bool = false

        if let result = self.executeJS(trigger), result == "1" {
            isExistFlag = true
        }
        return isExistFlag
    }
}

// MARK: - Utilities
extension TSWebEidtorView {
    fileprivate func removeQuotesFromHTML(_ html: String) -> String {
        var result: String = html.replacingOccurrences(of: "\"", with: "\\\"")
        result = result.replacingOccurrences(of: "", with: "")
        result = result.replacingOccurrences(of: "“", with: "&quot;")
        result = result.replacingOccurrences(of: "”", with: "&quot;")
        result = result.replacingOccurrences(of: "\r", with: "\\r")
        result = result.replacingOccurrences(of: "\n", with: "\\n")
        return result
    }
    fileprivate func tidyHTML(_ html: String) -> String {
        var result: String = html.replacingOccurrences(of: "<br>", with: "<br />")
        result = result.replacingOccurrences(of: "<hr>", with: "<hr />")
        if self.formatHTML {
            let js = String(format: "style_html(\"%@\");", html)
            result = self.stringByEvaluatingJavaScript(from: js) ?? ""
        }
        return result
    }
}

extension TSWebEidtorView {

    func decodingURLFormat(url: String) -> String {
        var result: String = url.replacingOccurrences(of: "+", with: " ")
        result = result.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        return result
    }

}
