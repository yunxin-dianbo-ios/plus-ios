//
//  TSWebEditorSampleController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 22/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  TSWebEditorView的使用示例

import UIKit
import SnapKit
import PKHUD
import JavaScriptCore
import Kingfisher

/// web编辑器的编辑类型
enum TSEditType: Int {
    /// 正常的编辑
    case normal
    /// 草稿编辑
    case draft
    /// 更新
    case update
}

/// Web编辑器的示例
class TSWebEditorSampleController: TSViewController {

    // MARK: - Internal Property

    /// 保存草稿的回调
//    var saveDraftAction: ((_ draftModel: TSPostDraftModel) -> Void)?

    // MARK: - Internal Function
    // MARK: - Private Property

    /// 编辑类型，正常还是草稿
    fileprivate let editType: TSEditType

    /// 待编辑的帖子草稿
//    fileprivate var editedDraft: TSPostDraftModel?

    /// 当前插入图片的序号
    fileprivate var currentImgIndex: Int = 0

    /// 图片记录，序号用于界面查找使用
    /// 注：图片记录可能异常——如果backspace键删除，则无法记录，导致最后的删除异常。可通过判断图片是否存在来进行确认
    fileprivate var imageMap: [Int : TSWebEditorImageNode] = [Int: TSWebEditorImageNode]()

    /// 右侧按钮
    fileprivate weak var rightItem: UIButton!
    /// 编辑器 - 编辑视图
    fileprivate weak var editorView: TSWebEidtorView!
    /// 底部工具栏
    fileprivate weak var editorToolbar: TSEditorToolBar!
    fileprivate let toolbarHeight: CGFloat = 40

//    fileprivate var internalHTML: String = ""
    fileprivate var selectedLinkURL: String?
    fileprivate var selectedLinkTitle: String?
    fileprivate var selectedImageURL: String?
    fileprivate var selectedImageAlt: String?

    fileprivate var resourcesLoaded: Bool = false
    fileprivate var editorLoaded: Bool = false
    var currentKbH: CGFloat = 0

    // MARK: - Initialize Function

    init(editType: TSEditType = .normal) {
        self.editType = editType
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowOrHideNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowOrHideNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

}

// MARK: - UI

extension TSWebEditorSampleController {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        // navigationbar
        self.navigationItem.title = "Web编辑器"
        let backItem = UIButton(type: .custom)
        backItem.addTarget(self, action: #selector(leftItemClick), for: .touchUpInside)
        self.setupNavigationTitleItem(backItem, title: "显示_导航栏_返回".localized)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backItem)
        let nextItem = UIButton(type: .custom)
        nextItem.addTarget(self, action: #selector(rightItemClick), for: .touchUpInside)
        self.setupNavigationTitleItem(nextItem, title: "显示_发布".localized)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextItem)
        nextItem.setTitleColor(UIColor.lightGray, for: .disabled)
        self.rightItem = nextItem
        // editorView
        let editorView = TSWebEidtorView()
        self.view.addSubview(editorView)
        editorView.delegate = self
        editorView.setFooterHeight(10)
        editorView.scrollView.delegate = self
        editorView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(0)
            make.top.equalTo(self.view)
        }
        self.editorView = editorView
        // toolbar
        let toolbar = TSEditorToolBar()
        self.view.addSubview(toolbar)
        toolbar.delegate = self
        toolbar.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(toolbar.currentHeight)
        }
        self.editorToolbar = toolbar
    }
}

// MARK: - 数据处理与加载

extension TSWebEditorSampleController {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        if !self.resourcesLoaded {
            self.editorView.loadData()
        }
        self.rightItem.isEnabled = false

        // 草稿加载
        if self.editType == .draft {

        }
    }

    /// 判断是否可以下一步
    fileprivate func couldNext() -> Bool {
        var couldFlag: Bool = true
        guard let markdown = self.editorView.getContentMarkdown(), let summary = self.editorView.getContentText() else {
            return false
        }
        let isExistImage = markdown.ts_customMarkdownIsContainImageCode()
        // TODO: - iOS9.x 版本的模拟器 在这里获取的值为空，待解决
        // js错误也可能造成这种情况
        // summary 和imageIds不能同时为空
        if markdown.isEmpty || (summary.isEmpty && !isExistImage) {
            couldFlag = false
        }
        return couldFlag
    }
    func couldNextProcess() -> Void {
        self.rightItem.isEnabled = self.couldNext()
    }

    /// 是否可以保存草稿箱
    fileprivate func couldSaveDraft() -> Bool {
        var couldFlag: Bool = true

        var markdownFlag: Bool = false
        var summaryFlag: Bool = false
        var imageFlag: Bool = false

        if let markdown = self.editorView.getContentMarkdown(), !markdown.isEmpty {
            markdownFlag = true
            imageFlag = markdown.ts_customMarkdownIsContainImageCode()
        }
        if let summary = self.editorView.getContentText(), !summary.isEmpty {
            summaryFlag = true
        }

        if !markdownFlag && !summaryFlag && !imageFlag {
            couldFlag = false
        }

        return couldFlag
    }
    /// 保存草稿箱 弹窗
    fileprivate func showSaveDraftDialogView() -> Void {
        let alertVC = TSAlertController(title: nil, message: "", style: .actionsheet)
        alertVC.addAction(TSAlertAction(title: "放弃编辑", style: .default, handler: { (action) in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        alertVC.addAction(TSAlertAction(title: "保存至草稿箱", style: .default, handler: { (action) in
            self.saveDraft()
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alertVC, animated: false, completion: nil)
    }
    /// 保存草稿箱
    fileprivate func saveDraft() -> Void {
        // 草稿保存
        // 图片保存
        // 保存草稿的回调
    }

    /// 获取图片文件id
    fileprivate func getImageIds() -> [Int] {
        // imageMap不能记录使用delete键删除的图片，
        // 所以 1.使用markdown的来获取
        //     2.遍历imageMap+js来确认该图片是否存在
        //  这里采用第2种方案，但只有在发布和保存草稿时才获取，其余时候都是通过markdown判断是否有图片，所以这里无需移除不存在的imageNode，
        // 如果是content内容变更都调用这里来判断图片的话，建议移除不存在的，且注意插入图片时的先后顺序
        var imageIdList: [Int] = [Int]()
        for (_, imageNode) in self.imageMap {
            // js判断该图片是否存在
            if self.editorView.isExistImage(imageIndex: imageNode.index), let fileId = imageNode.fileId {
                imageIdList.append(fileId)
            }
        }
        return imageIdList
    }

    func contentChanged() -> Void {
        self.couldNextProcess()
    }
}

// MARK: - 事件响应

extension TSWebEditorSampleController {
    /// 导航栏左侧按钮点击响应
    @objc fileprivate func leftItemClick() -> Void {
        self.view.endEditing(true)
        // 根据内容判断是否弹出草稿箱提示弹窗
        if self.couldSaveDraft() {
            self.showSaveDraftDialogView()
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    /// 导航栏右侧按钮点击响应
    @objc fileprivate func rightItemClick() -> Void {
        self.view.endEditing(true)
        if self.couldNext() {
            self.nextTest()
        }
    }

    /// 打印内容，用于调试，markdown和html需要格式化
    fileprivate func nextTest() -> Void {
        let html = self.editorView.getHTML()
        let markdown = self.editorView.getContentMarkdown()
        let summary = self.editorView.getContentText()?.ts_customMarkdownToNormal()
        let content = self.editorView.getContentText()
        print("\n===========Html Start=============\n")
        if let html = html {
            print(html)
        }
        print("\n===========Html End=============\n")

        print("\n===========Markdown Start=============\n")
        if let markdown = markdown {
            print(markdown)
        }
        print("\n===========Markdown End=============\n")

        print("\n===========Summary Start=============\n")
        if let summary = summary {
            print(summary)
        }
        print("\n===========Summary End=============\n")

        print("\n===========Content Start=============\n")
        if let content = content {
            print(content)
        }
        print("\n===========Content End=============\n")
    }

}

// MARK: - Extension Function

extension TSWebEditorSampleController {
    /// 编辑器聚焦
    fileprivate func focusContentEditor() -> Void {
        self.editorView.keyboardDisplayRequiresUserAction = false
        self.editorView.focusContentEditor()
        self.editorToolbar.inputEnable = true
    }
}
extension TSWebEditorSampleController {
    /// 显示链接插入对话框
    fileprivate func showInsertLinkDialog(url: String?, title: String?) -> Void {
        // 添加 或 编辑 的标题
        self.editorView.resignFirstResponder()
        let linkVC = TSSuperLinkVC()
        linkVC.show(vc: linkVC, link: url, linkTitle: title, kbHeight: currentKbH)
        linkVC.sendBlock = { (link, linkTitle) in
            if link == "" {
                return
            }
            var linkUrl = link
            let regex = "^http://[\\s\\S]+"
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            let isValid = predicate.evaluate(with: linkUrl)
            if !isValid {
                linkUrl = "http://" + linkUrl
            }
            if nil == self.selectedLinkURL {
                self.editorView.insertLink(url: linkUrl, title: linkTitle)
            } else {
                self.editorView.updateLink(url: linkUrl, title: linkTitle)
            }
        }
    }
}

extension TSWebEditorSampleController {

    fileprivate func showInsertImageDialog() -> Void {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "相机", style: .default, handler: { (action) in
            self.openCamera()
        }))
        alertVC.addAction(UIAlertAction(title: "相册", style: .default, handler: { (action) in
            self.openLibrary()
        }))
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    fileprivate func openLibrary() -> Void {
        let sourceType: UIImagePickerControllerSourceType = .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let pickerVC = UIImagePickerController()
            pickerVC.sourceType = sourceType
            //pickerVC.mediaTypes = []
            //pickerVC.allowsEditing = false
            pickerVC.delegate = self
            self.present(pickerVC, animated: true, completion: nil)
        }
    }
    fileprivate func openCamera() -> Void {
        let sourceType: UIImagePickerControllerSourceType = .camera
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let pickerVC = UIImagePickerController()
            pickerVC.sourceType = sourceType
            //pickerVC.mediaTypes = []
            //pickerVC.allowsEditing = false
            pickerVC.delegate = self
            self.present(pickerVC, animated: true, completion: nil)
        }
    }

    /// 插入图片 - selectImageProcess
    fileprivate func insertImage(_ image: UIImage) -> Void {
        // 上传图片
        self.imageMap.updateValue(TSWebEditorImageNode(index: self.currentImgIndex, image: image, name: ""), forKey: self.currentImgIndex)
        self.uploadImage(image, index: self.currentImgIndex)
        // 显示图片
        let width = UIScreen.main.bounds.size.width - 15 * 2 - 10 * 2 // 边距
        let height = image.size.height / image.size.width * width
        self.editorView.insertImage(image, imageIndex: self.currentImgIndex, alt: "", width: width, height: height)
        // 图片序号修正
        self.currentImgIndex += 1
    }

    /// 上传图片
    fileprivate func uploadImage(_ image: UIImage, index: Int) -> Void {
        // 上传图片请求
        HUD.show(.progress)
        TSUploadNetworkManager().uploadImage(image: image) { [weak self](fileId, msg, status) in
            HUD.flash(.progress)
            guard status, let fileId = fileId else {
                //self?.uploadImageFailure(imageIndex: index)
                // 图片上传失败处理 - 提示并移除该图片
                self?.editorView.removeImage(imageIndex: index)
                self?.imageMap.removeValue(forKey: index)
                TSUtil.showAlert(title: "图片上传失败", message: msg, clickAction: nil)
                return
            }
            print("new fileId: \(fileId)")
            // 图片上传成功
            self?.imageMap[index]?.fileId = fileId
            self?.imageMap[index]?.uploaded = true
            // 界面处理
            self?.editorView.uploadImageSuccess(imageIndex: index, fileId: fileId)
        }
    }

    /// 重新上传图片
    fileprivate func reloadImage(index: Int) -> Void {
        guard let node = self.imageMap[index] else {
            return
        }
        /// TODO: - 这里重新上传成功后应对界面进行修正(上传失败标记的隐藏)
        self.uploadImage(node.image, index: index)
    }

    /// 显示图片点击后的弹窗
    fileprivate func showImageClickDialogView(index: Int, isfailure: Bool) -> Void {
        let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
        let deleteAction = TSAlertAction(title: "选择_删除图片".localized, style: .default, handler: { (action) in
            // html中删除
            self.editorView.removeImage(imageIndex: index)
            // 本地记录表中删除
            self.imageMap.removeValue(forKey: index)
        })
        let reuploadAction = TSAlertAction(title: "选择_重新上传".localized, style: .default) { (action) in
            self.reloadImage(index: index)
        }
        alertVC.addAction(deleteAction)
        if isfailure {
            alertVC.addAction(reuploadAction)
        }
        self.present(alertVC, animated: false, completion: nil)
    }
    /// 图片点击响应
    fileprivate func imageClick(index: Int) -> Void {
        guard let imagenode = self.imageMap[index] else {
            return
        }
        self.view.endEditing(true)
        self.showImageClickDialogView(index: index, isfailure: imagenode.fileId == nil)
    }

}

extension TSWebEditorSampleController {

    func decodingURLFormat(url: String) -> String {
        var result: String = url.replacingOccurrences(of: "+", with: " ")
        result = result.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        return result
    }

    func nodeProcess(name: String) -> Void {
        // Items that are enabled
        let itemNames = name.components(separatedBy: ",")

        var enableItems = [TSEditorTextStyle]()
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

            if let styleItem = TSEditorTextStyle(rawValue: linkItem.lowercased()) {
                enableItems.append(styleItem)
            }
        }
        self.editorToolbar.setEnableItems(enableItems)
    }

}

// MARK: - Notification

extension TSWebEditorSampleController {

    @objc fileprivate func keyboardWillShowOrHideNotificationProcess(_ notification: Notification) -> Void {
        guard let info = notification.userInfo, let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval, let curve = info[UIKeyboardAnimationCurveUserInfoKey] as? Int, let kbEndFrame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let kbHeight: CGFloat = kbEndFrame.size.height
        currentKbH = kbHeight
        //let animOptions: UIViewAnimationOptions = UIViewAnimationOptions.init(rawValue: curve << 16)
        let animOptions: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: 0)
        if notification.name == Notification.Name.UIKeyboardWillShow {
            UIView.animate(withDuration: duration, delay: 0, options: animOptions, animations: {
                // Toolbar
                self.editorToolbar.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(self.view).offset(-kbHeight)
                })
                // EditorView
                let bottomOffset = kbHeight + self.editorToolbar.currentHeight
                self.editorView.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(self.view).offset(-bottomOffset)
                })
                self.view.layoutIfNeeded()
                // Provide editor with keyboard height and editor view height

                // 应判断是否有导航栏 或者 传入高度
                let editorViewHeight = self.view.bounds.size.height - bottomOffset - 64

//                self.editorView.setContentHeight(editorViewHeight)

            }, completion: nil)
        } else if notification.name == Notification.Name.UIKeyboardWillHide {
            self.editorToolbar.hiddenExtension()
            UIView.animate(withDuration: duration, delay: 0, options: animOptions, animations: {
                // Toolbar
                self.editorToolbar.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(self.view).offset(self.editorToolbar.currentHeight)
                })
                // EditorView
                self.editorView.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(self.view).offset(0)
                })
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}

// MARK: - JS回调OC
extension TSWebEditorSampleController {
    /// debug调试
    fileprivate func jsDebug(_ msg: String) -> Void {
        print("msg: " + msg)
    }
    /// 正文输入框聚焦
    fileprivate func jsContentFocus() -> Void {
        self.editorToolbar.inputEnable = true
    }
    /// 正文输入框 失去焦点
    fileprivate func jsContentBlur() -> Void {
        self.editorToolbar.inputEnable = false
        self.editorToolbar.hiddenExtension()
    }
    /// contentChange
    fileprivate func jsContentChange() -> Void {
        self.contentChanged()
    }
    /// imageClick
    fileprivate func jsImageClick(imageIndex: Int) -> Void {
        self.imageClick(index: imageIndex)
    }
    /// scroll y
    fileprivate func jsScrollPostion(_ postion: Double) -> Void {
        //        self.imageClick(index: imageIndex)
    }
    /// EnableEditingStyleItems
    fileprivate func jsEnableEditingStyleItems(strItems: String) -> Void {
        self.nodeProcess(name: strItems)
    }
}

// MARK: - Delegate Function

// MARK: - <UIScrollViewDelegate>
extension TSWebEditorSampleController: UIScrollViewDelegate {
    /// 拖动视图时关闭键盘
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

// MARK: - <UIWebViewDelegate>
extension TSWebEditorSampleController: UIWebViewDelegate {

    /// js回调Swift，可考虑使用协议优化
    fileprivate func initialJSContent(with webView: UIWebView) -> Void {
        guard let context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext else {
            return
        }
        // 打印异常,由于JS的异常信息是不会在OC中被直接打印的,所以我们在这里添加打印异常信息,
        context.exceptionHandler = { (context: JSContext?, exception: JSValue?) -> Void in
            print(exception.debugDescription)
        }

        // debug
        let debug: @convention(block)() -> Void = { [unowned self] () -> Void in
            let args = JSContext.currentArguments()
            DispatchQueue.main.async {
                if let msg = args?.first as? JSValue {
                    self.jsDebug(msg.toString())
                }
            }
        }
        context.setObject(unsafeBitCast(debug, to: AnyObject.self), forKeyedSubscript: "appDebug" as (NSCopying & NSObjectProtocol))

        // contentFocus
        let contentFocus: @convention(block)() -> Void = { [unowned self] () -> Void in
            DispatchQueue.main.async {
                self.jsContentFocus()
            }
        }
        context.setObject(unsafeBitCast(contentFocus, to: AnyObject.self), forKeyedSubscript: "appContentFocus" as (NSCopying & NSObjectProtocol))

        // contentBlur
        let contentBlur: @convention(block)() -> Void = { [unowned self] () -> Void in
            DispatchQueue.main.async {
                self.jsContentBlur()
            }
        }
        context.setObject(unsafeBitCast(contentBlur, to: AnyObject.self), forKeyedSubscript: "appContentBlur" as (NSCopying & NSObjectProtocol))

        // contentChange
        let contentChange: @convention(block)() -> Void = { [unowned self] () -> Void in
            DispatchQueue.main.async {
                self.jsContentChange()
            }
        }
        context.setObject(unsafeBitCast(contentChange, to: AnyObject.self), forKeyedSubscript: "appContentChange" as (NSCopying & NSObjectProtocol))

        // imageClick
        let imageClick: @convention(block)() -> Void = { [unowned self] () -> Void in
            let args = JSContext.currentArguments()
            DispatchQueue.main.async {
                if let value = args?.first as? JSValue {
                    self.jsImageClick(imageIndex: Int(value.toInt32()))
                }
            }
        }
        context.setObject(unsafeBitCast(imageClick, to: AnyObject.self), forKeyedSubscript: "appImageClick" as (NSCopying & NSObjectProtocol))

        // scrollPosition
        let scrollPosition: @convention(block)() -> Void = { [unowned self] () -> Void in
            let args = JSContext.currentArguments()
            DispatchQueue.main.async {
                if let value = args?.first as? JSValue {
                    self.jsScrollPostion(value.toDouble())
                }
            }
        }
        context.setObject(unsafeBitCast(scrollPosition, to: AnyObject.self), forKeyedSubscript: "appScrollPosition" as (NSCopying & NSObjectProtocol))

        // EnableEditingStyleItems
        let enableEditingStyle: @convention(block)() -> Void = { [unowned self] () -> Void in
            let args = JSContext.currentArguments()
            DispatchQueue.main.async {
                if let value = args?.first as? JSValue {
                    self.jsEnableEditingStyleItems(strItems: value.toString())
                } else {
                    self.jsEnableEditingStyleItems(strItems: "")
                }
            }
        }
        context.setObject(unsafeBitCast(enableEditingStyle, to: AnyObject.self), forKeyedSubscript: "appEnableEditingStyleItems" as (NSCopying & NSObjectProtocol))

    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.initialJSContent(with: webView)
        let topH: CGFloat = 64.0
        //let minH: CGFloat = ScreenHeight - topH - 70 // 需减去标题输入框的高度，但高度不确定，大概随便填写个
        let minH: CGFloat = ScreenHeight - topH
        self.editorView.setContentMinHeight(minH)

        // 草稿编辑，则填充数据
        if self.editType == .draft {

            // 有链接的必须这样处理，否则根本就展示不出来
            //markdown.replaceAll(matching: "\"", with: "\'")

            // 有图片，则下载图片

            self.rightItem.isEnabled = self.couldNext()

        }
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let urlString = request.url?.absoluteString else {
            return false
        }
        if navigationType == .linkClicked {
            return false
        }
        print("url: " + urlString)

        //        // nodeProcess 和 scroll使用url回调，其余使用JSContext回调。
        //        if let callRange = urlString.range(of: "callback://0/") {
        //            // We recieved the callback
        //            let className = urlString.replacingOccurrences(of: "callback://0/", with: "")
        //            self.nodeProcess(name: className)
        //        } else if let scrollRange = urlString.range(of: "scroll://") {
        //            let position = urlString.replacingOccurrences(of: "scroll://", with: "")
        //            print(position)
        //        }
        //        else if let debugRange = urlString.range(of: "debug://") {
        //            // We recieved the callback
        //            var debug = urlString.replacingOccurrences(of: "debug://", with: "")
        //            // 注：这里同OC部分差异很大
        //            debug = debug.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        //            print(debug)
        //        } else if nil != urlString.range(of: "contentclick://") || nil != urlString.range(of: "contentfocus://") || nil != urlString.range(of: "contenttouchend://") {
        //            // 正文输入框聚焦 - 其实监听click事件即可
        //            self.editorToolbar.inputEnable = true
        //        } else if nil != urlString.range(of: "titleclick://") || nil != urlString.range(of: "titlefocus://") {
        //            // 标题输入框聚焦
        //            self.editorToolbar.inputEnable = false
        //            self.editorToolbar.hiddenTextStyle = true
        //            self.editorView.removeFormat()
        //        } else if nil != urlString.range(of: "titleblur://") {
        //            // 标题输入框失去焦点
        //        } else if nil != urlString.range(of: "contentblur://") {
        //            // 正文输入框失去焦点
        //            self.editorToolbar.inputEnable = false
        //            self.editorToolbar.hiddenTextStyle = true
        //        } else if nil != urlString.range(of: "titlechange://") || nil != urlString.range(of: "titleinput://") {
        //            self.titleChanged()
        //        } else if nil != urlString.range(of: "contentchange://") || nil != urlString.range(of: "contentinput://") {
        //            self.contentChanged()
        //        } else if let range = urlString.range(of: "imageclick://") {
        //            let imageIndexStr = urlString.replacingOccurrences(of: "imageclick://", with: "")
        //            if let imageIndex = Int(imageIndexStr) {
        //                self.imageClick(index: imageIndex)
        //            }
        //        }

        return true
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        //        self.editorLoaded = YES;
        //        [self setPlaceholderText];
        //        if (!self.internalHTML) {
        //            self.internalHTML = @"";
        //        }
        //        [self updateHTML];
        //        if (self.shouldShowKeyboard) {
        //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //                [self focusTextEditor];
        //                });
        //        }
    }
}

// MARK: - <TSEditorToolBarProtocol>
extension TSWebEditorSampleController: TSEditorToolBarProtocol {
    /// 样式点击回调
    func richTextToolBar(toolbar: TSEditorToolBar, didClickTextStyle textStyle: TSEditorTextStyle, withSelectedState state: Bool) -> Void {
        // 注：如果此处要关闭键盘，则需注意两点
        // 1. prepareInsert与endEditing的先后顺序，如果顺序颠倒则根本就不会插入
        // 2. 需要处理插入后重新聚焦的问题，即再中间插入后光标位置问题，之前采用光标位于尾部聚焦方案或者不关闭键盘
        switch textStyle {
        case .link:
            // 注意先后顺序，否则根本就不会插入
            self.editorView.prepareInsert()
            //self.view.endEditing(true)
            self.showInsertLinkDialog(url: self.selectedLinkURL, title: self.selectedLinkTitle)
        //self.showInsertLinkDialog(url: nil, title: nil)
        case .image:
            // 注意先后顺序，否则根本就不会插入
            self.editorView.prepareInsert()
            //self.view.endEditing(true)
            self.showInsertImageDialog()
        default:
            self.editorView.setTextStyle(textStyle, selectedState: state)
        }
    }
    /// 键盘按钮点击回调
    func didClickKeyboardBtn(in toolbar: TSEditorToolBar) -> Void {
        self.view.endEditing(true)
    }
    /// 高度变化回调
    func didHeightChanged(in toolbar: TSEditorToolBar) {

    }

    func richTextToolBarEmoji(toolbar: TSWebEditorToolBar, didClickTextStyle textStyle: TSEditorTextStyle, withSelectedState state: Bool, emojiButton: UIButton) {

    }
}

// MARK: - <UIImagePickerControllerDelegate>
extension TSWebEditorSampleController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        picker.dismiss(animated: true) {
            self.insertImage(image)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        //self.focusContentEditor()
    }
}
