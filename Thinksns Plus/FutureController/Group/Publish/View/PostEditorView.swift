//
//  PostEditerWebView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 28/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  帖子编辑视图

import Foundation

class PostEditorView: UIWebView {

    // MARK: - Internal Property

    //override var delegate: PostEditorViewProtocol?
    //var editorDelegate: PostEditorViewProtocol?

    // MARK: - Private Property

    fileprivate var formatHTML: Bool = false

    fileprivate var resourcesLoaded: Bool = false
    fileprivate var internalHTML: String = ""
    fileprivate var editorLoaded: Bool = false

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
        //fatalError("init(coder:) has not been implemented")
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

extension PostEditorView {
    /// 加载数据
    func loadData() -> Void {
        if !self.resourcesLoaded {
            self.loadLocalHtmlData()
        }
        //self.formatHTML = true
    }

    /// 加载本地网页数据
    fileprivate func loadLocalHtmlData() -> Void {
        guard let htmlPath = Bundle.main.path(forResource: "ZSS_editor", ofType: "html"), let jsPath = Bundle.main.path(forResource: "ZSS_RichTextEditor", ofType: "js") else {
            return
        }
        let htmlData: Data = try! Data(contentsOf: URL(fileURLWithPath: htmlPath))
        let jsData: Data = try! Data(contentsOf: URL(fileURLWithPath: jsPath))

        if let htmlString = String(data: htmlData, encoding: String.Encoding.utf8), let jsString = String(data: jsData, encoding: String.Encoding.utf8) {
            let html = htmlString.replacingOccurrences(of: "<!--editor-->", with: jsString)
            self.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
            self.resourcesLoaded = true
        }
        //self.loadCustomCss()
    }
    /// 加载自定义CSS文件
    fileprivate func loadCustomCss() -> Void {
        guard let cssPath = Bundle.main.path(forResource: "mao_index", ofType: "css") else {
            return
        }
        let cssData: Data = try! Data(contentsOf: URL(fileURLWithPath: cssPath))
        if let cssString = String(data: cssData, encoding: String.Encoding.utf8) {
            let js = String(format: "zss_editor.setCustomCSS(\"%@\");", cssString)
            self.executeJS(js)
        }
    }

}

// MARK: - Internal Function

extension PostEditorView {
    /// 执行js
    @discardableResult
    func executeJS(_ js: String) -> String? {
        return self.stringByEvaluatingJavaScript(from: js)
    }

    func prepareInsert() -> Void {
        let js = "zss_editor.prepareInsert();"
        self.executeJS(js)
    }
}

// MARK: - Html

extension PostEditorView {

    func setHTML(_ html: String) -> Void {
        self.internalHTML = html
        if self.editorLoaded {
            self.updateHTML()
        }
    }

    func updateHTML() -> Void {
        let html = self.internalHTML
        let cleanedHTML = self.removeQuotesFromHTML(html)
        let trigger = String(format: "zss_editor.setHTML(\"%@\");", cleanedHTML)
        self.stringByEvaluatingJavaScript(from: trigger)
    }

    func getHTML() -> String? {
        if var html = self.stringByEvaluatingJavaScript(from: "zss_editor.getHTML();") {
            html = self.removeQuotesFromHTML(html)
            html = self.tidyHTML(html)
            return html
        }
        return nil
    }

    func insertHTML(_ html: String) -> Void {
        let cleanedHTML = self.removeQuotesFromHTML(html)
        let trigger = String(format: "zss_editor.insertHTML(\"%@\");", cleanedHTML)
        self.executeJS(trigger)
    }

    /**
    func updateHTML() -> Void {
        let html = self.internalHTML
        //let cleanedHTML = self.removeQuotesFromHTML(html)
        //let trigger = String(format: "zss_editor.setHTML(\"%@\");", cleanedHTML)
        let trigger = String(format: "zss_editor.setHTML(\"%@\");", html)
        self.stringByEvaluatingJavaScript(from: trigger)
    }
    
    func getHTML() -> String? {
        if var html = self.stringByEvaluatingJavaScript(from: "zss_editor.getHTML();") {
            //html = self.removeQuotesFromHTML(html)
            //html = self.tidyHTML(html)
            return html
        }
        return nil
    }
    
    func insertHTML(_ html: String) -> Void {
        //let cleanedHTML = self.removeQuotesFromHTML(html)
        //let trigger = String(format: "zss_editor.insertHTML(\"%@\");", cleanedHTML)
        let trigger = String(format: "zss_editor.insertHTML(\"%@\");", html)
        self.executeJS(trigger)
    }
    
    **/
}

// MARK: - setContent

extension PostEditorView {
    func setTitle(_ title: String) -> Void {
        let js: String = String(format: "zss_editor.setTitle(\"%@\");", title)
        self.executeJS(js)
    }
    func setContentWithMarkdown(_ markdown: String) -> Void {
        let js: String = String(format: "zss_editor.setContentWithMarkdown(\"%@\");", markdown)
        self.executeJS(js)
    }
}

// MARK: - 高度

extension PostEditorView {
    func setFooterHeight(_ height: CGFloat) -> Void {
        let js: String = String(format: "zss_editor.setFooterHeight(\"%f\");", height)
        self.executeJS(js)
    }
    func setContentHeight(_ height: CGFloat) -> Void {
        let js: String = String(format: "zss_editor.contentHeight = %f;", height)
        self.executeJS(js)
    }
    func setContentMinHeight(_ height: CGFloat) -> Void {
        let js: String = String(format: "zss_editor.setContentMinHeight(\"%f\")", height)
        self.executeJS(js)
    }
}

// MARK: - 光标 聚焦

extension PostEditorView {
    func focusContentEditor() -> Void {
        let js: String = String(format: "zss_editor.focusEditor();")
        self.executeJS(js)
    }
    func blurContentEditor() -> Void {
        let js: String = String(format: "zss_editor.blurEditor();")
        self.executeJS(js)
    }
}

// MARK: - 内容

extension PostEditorView {

    /// 内容
    func setPlaceholderText(_ placeholder: String) -> Void {
        let js: String = String(format: "zss_editor.setPlaceholder(\"%@\");", placeholder)
        self.executeJS(js)
    }

    func getTitleText() -> String? {
        let trigger = "zss_editor.getTitleText();"
        return self.executeJS(trigger)
    }

    func getContentMarkdown() -> String? {
        let trigger = String(format: "zss_editor.getContentMarkdown();")
        return self.executeJS(trigger)
    }
    func getContentText() -> String? {
        let trigger = "zss_editor.getText();"
        return self.executeJS(trigger)
    }
//    func getContentSummary() -> String? {
//        let trigger = String(format: "zss_editor.getContentSummary();")
//        return self.executeJS(trigger)
//    }
}

// MARK: - 样式

extension PostEditorView {

    /// TWRichTextStyle下的style设置
    func setTextStyle(_ textStyle: TWRichTextStyle, selectedState: Bool) -> Void {
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

    func setBold() -> Void {
        let js: String = String(format: "zss_editor.setBold();")
        self.executeJS(js)
    }

    func setItalic() -> Void {
        let js: String = String(format: "zss_editor.setItalic();")
        self.executeJS(js)
    }

    func setUnderline() -> Void {
        let js: String = String(format: "zss_editor.setUnderline();")
        self.executeJS(js)
    }

    func setStrikethrough() -> Void {
        let js: String = String(format: "zss_editor.setStrikeThrough();")
        self.executeJS(js)
    }

    func setHR() -> Void {
//        let js: String = String(format: "zss_editor.setHorizontalRule();")
//        self.executeJS(js)

        self.insertHTML("<div><hr /><br /></div>")

        //        self.insertHTML("<br />")
        //        self.insertHTML("<hr /><br />")
    }

    func setBlockquote() -> Void {
        let js: String = String(format: "zss_editor.setBlockquote();")
        self.executeJS(js)
    }

    func removeBlockquote() -> Void {
        let js: String = String(format: "zss_editor.removeBlockquote();")
        self.executeJS(js)
    }

    func heading1() -> Void {
        let js: String = String(format: "zss_editor.setHeading('h1');")
        self.executeJS(js)
    }
    func heading2() -> Void {
        let js: String = String(format: "zss_editor.setHeading('h2');")
        self.executeJS(js)
    }
    func heading3() -> Void {
        let js: String = String(format: "zss_editor.setHeading('h3');")
        self.executeJS(js)
    }
    func heading4() -> Void {
        let js: String = String(format: "zss_editor.setHeading('h4');")
        self.executeJS(js)
    }
    func heading5() -> Void {
        let js: String = String(format: "zss_editor.setHeading('h5');")
        self.executeJS(js)
    }
    func heading6() -> Void {
        let js: String = String(format: "zss_editor.setHeading('h6');")
        self.executeJS(js)
    }

    func undo() -> Void {
        let js: String = String(format: "zss_editor.undo();")
        self.executeJS(js)
    }
    func redo() -> Void {
        let js: String = String(format: "zss_editor.redo();")
        self.executeJS(js)
    }

}

// MARK: - Other Style

extension PostEditorView {
    func removeFormat() -> Void {
        let js: String = String(format: "zss_editor.removeFormating();")
        self.executeJS(js)
    }

    func alignLeft() -> Void {
        let js: String = String(format: "zss_editor.setJustifyLeft();")
        self.executeJS(js)
    }
    func alignCenter() -> Void {
        let js: String = String(format: "zss_editor.setJustifyCenter();")
        self.executeJS(js)
    }
    func alignRight() -> Void {
        let js: String = String(format: "zss_editor.setJustifyRight();")
        self.executeJS(js)
    }
    func alignFull() -> Void {
        let js: String = String(format: "zss_editor.setJustifyFull();")
        self.executeJS(js)
    }

    func setUnorderedList() -> Void {
        let js: String = String(format: "zss_editor.setUnorderedList();")
        self.executeJS(js)
    }
    func setOrderedList() -> Void {
        let js: String = String(format: "zss_editor.setOrderedList();")
        self.executeJS(js)
    }

    func setSubscript() -> Void {
        let js: String = String(format: "zss_editor.setSubscript();")
        self.executeJS(js)
    }
    func setSuperscript() -> Void {
        let js: String = String(format: "zss_editor.setSuperscript();")
        self.executeJS(js)
    }

    func setIndent() -> Void {
        let js: String = String(format: "zss_editor.setIndent();")
        self.executeJS(js)
    }
    func setOutdent() -> Void {
        let js: String = String(format: "zss_editor.setOutdent();")
        self.executeJS(js)
    }

    func paragraph() -> Void {
        let js: String = String(format: "zss_editor.setParagraph();")
        self.executeJS(js)
    }

}

// MARK: - 链接

extension PostEditorView {
    /// 插入链接
    func insertLink(url: String, title: String) -> Void {
//        self.executeJS("zss_editor.prepareInsert();")
        // 注意：上面注释部分需要再键盘关闭之前使用，否则插入失败。同理，插入图片、插入html代码都一样。
        // url校验，scheme + 服务器，不符合该格式则添加"zhiyi"格式的scheme。js里插入链接时校验
        // "[\\s\\S]+:[\\s\\S]+"
        let js = String(format: "zss_editor.insertLink(\"%@\", \"%@\");", url, title)
        self.executeJS(js)
    }

    /// 修改链接
    func updateLink(url: String, title: String) -> Void {
//        self.executeJS("zss_editor.prepareInsert();")
        let js = String(format: "zss_editor.updateLink(\"%@\", \"%@\");", url, title)
        self.executeJS(js)
    }

    /// 移除链接
    func removeLink() -> Void {
        self.executeJS("zss_editor.unlink();")
    }

    /// quickLink
    func quickLink() -> Void {
        self.executeJS("zss_editor.quickLink();")
    }
}

// MARK: - 图片

extension PostEditorView {
    func insertImage(url: String, alt: String) -> Void {
        self.executeJS("zss_editor.prepareInsert();")
        let trigger = String(format: "zss_editor.insertImage(\"%@\", \"%@\");", url, alt)
        self.executeJS(trigger)
    }

    func updateImage(url: String, alt: String) -> Void {
        self.executeJS("zss_editor.prepareInsert();")
        let trigger = String(format: "zss_editor.updateImage(\"%@\", \"%@\");", url, alt)
        self.executeJS(trigger)
    }

    func insertImage(_ image: UIImage, imageIndex: Int, alt: String, width: CGFloat, height: CGFloat) -> Void {
        // 若需查看html源码，base64太长，不便于查看html结构
        //let base64String = "base64ForJpgImage"
        let base64String = self.base64ForJpgImage(image)
        self.insertImage(base64String: base64String, imageIndex: imageIndex, alt: alt, width: width, height: height)
    }
    func insertImage(base64String: String, imageIndex: Int, alt: String, width: CGFloat, height: CGFloat) -> Void {
        self.executeJS("zss_editor.prepareInsert();")
        let trigger = String(format: "zss_editor.insertImageBase64String(\"%@\", \"%d\", \"%@\", \"%f\", \"%f\");", base64String, imageIndex, alt, width, height)
        self.executeJS(trigger)
    }

    func removeImage(imageIndex: Int) -> Void {
        let trigger = String(format: "zss_editor.removeImage(\"%d\")", imageIndex)
        self.executeJS(trigger)
    }

    /// 上传图片成功
    func uploadImageSuccess(imageIndex: Int, fileId: Int) -> Void {
        let trigger = String(format: "zss_editor.uploadImageSuccess(\"%d\", \"%d\")", imageIndex, fileId)
        self.executeJS(trigger)
    }
    /// 上传图片失败
    func uploadImageFailure(imageIndex: Int) -> Void {
        /// html界面展示处理
        let trigger = String(format: "zss_editor.uploadImageFailure(\"%d\")", imageIndex)
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
        let trigger = String(format: "zss_editor.isExistImage(\"%d\");", imageIndex)
        var isExistFlag: Bool = false

        if let result = self.executeJS(trigger), result == "1" {
            isExistFlag = true
        }
        return isExistFlag
    }
}

// MARK: - Utilities
extension PostEditorView {
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

extension PostEditorView {

    func decodingURLFormat(url: String) -> String {
        var result: String = url.replacingOccurrences(of: "+", with: " ")
        result = result.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        return result
    }

    /**
    func nodeProcess(name: String) -> Void {
        // Items that are enabled
        let itemNames = name.components(separatedBy: ",")
        
        // Special case for link
        for linkItem in itemNames {
            if linkItem.hasPrefix("link:") {
                self.selectedLinkURL = linkItem.replacingOccurrences(of: "link:", with: "")
            } else if linkItem.hasPrefix("link-title:") {
                self.selectedLinkURL = self.decodingURLFormat(url: linkItem.replacingOccurrences(of: "link-title:", with: ""))
            } else if linkItem.hasPrefix("image:") {
                self.selectedImageURL = linkItem.replacingOccurrences(of: "image:", with: "")
            } else if linkItem.hasPrefix("image-alt:") {
                self.selectedImageAlt = self.decodingURLFormat(url: linkItem.replacingOccurrences(of: "image-alt:", with: ""))
            } else {
                self.selectedLinkURL = nil
                self.selectedLinkTitle = nil
                self.selectedImageURL = nil
                self.selectedImageAlt = nil
            }
        }
    }
     **/

}
