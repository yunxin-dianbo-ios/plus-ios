//
//  TSWebEditorBaseController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 24/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  TSWebEditorView使用的基类

import UIKit
import SnapKit
import PKHUD
import JavaScriptCore
import Kingfisher

class TSWebEditorBaseController: TSViewController {

    // MARK: - Internal Property
    /// 编辑类型，正常还是草稿
    let editType: TSEditType

    // MARK: - Internal Function
    // MARK: - Private Property

    /// 当前插入图片的序号
    var currentImgIndex: Int = 0

    /// 图片记录，序号用于界面查找使用
    /// 注：图片记录可能异常——如果backspace键删除，则无法记录，导致最后的删除异常。可通过判断图片是否存在来进行确认
    var imageMap: [Int : TSWebEditorImageNode] = [Int: TSWebEditorImageNode]()
    /// 是否是草稿箱编辑
    var isEditDraft = false
    /// 右侧按钮
    weak var rightItem: UIButton!
    weak var leftItem: UIButton!
    /// 编辑器 - 编辑视图
    let editorView: TSWebEidtorView = TSWebEidtorView()
    /// 底部工具栏
    weak var editorToolbar: TSEditorToolBar!
    let toolbarHeight: CGFloat = 40

    //    fileprivate var internalHTML: String = ""
    fileprivate var selectedLinkURL: String?
    fileprivate var selectedLinkTitle: String?
    fileprivate var selectedImageURL: String?
    fileprivate var selectedImageAlt: String?

    fileprivate var resourcesLoaded: Bool = false
    fileprivate var editorLoaded: Bool = false
    var currentKbH: CGFloat = 0

    // 草稿中的图片ID
    var draftImageIDs: Array<Int> = []
    /// 选择Emoji的视图
    var emojiView: TSSystemEmojiSelectorView!
    var emojiTap = false
    var emojiButton: UIButton!
    /// 这个只监管表情点击时候编辑器的聚焦时候弹起键盘一瞬间.其他时候全部为 false
    var emojiFocusEditor = false

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
        // 初始化表情选择器
        emojiView = TSSystemEmojiSelectorView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 145 + TSBottomSafeAreaHeight))
        emojiView.bottom = self.view.bottom
        emojiView.delegate = self
        self.view.addSubview(emojiView)
        self.initialUI()
        self.initialDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 键盘的通知处理
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

}

// MARK: - UI

extension TSWebEditorBaseController {
    /// 页面布局
    func initialUI() -> Void {
        self.view.backgroundColor = UIColor.white
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
        self.leftItem = backItem
        self.rightItem = nextItem
        // editorView
        self.view.addSubview(editorView)
        editorView.delegate = self
        editorView.setFooterHeight(10)
        editorView.scrollView.delegate = self
        editorView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(0)
            make.top.equalTo(self.view)
        }
        // toolbar
        // 这样设计的目的是 因为某些情况下需要将这个toolbar里的部分就行悬浮在底部
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

extension TSWebEditorBaseController {
    /// 默认数据加载
    func initialDataSource() -> Void {
        if !self.resourcesLoaded {
            self.editorView.loadData()
        }
        self.rightItem.isEnabled = false
        self.loadDataNoMarkdown()
    }

    /**
     数据加载处理时，子类可重写下面四个方法loadXxxNoMarkdown()和loadXxxWithMarkdown()；
                    也可重写loadDataNoMarkdown()和loadDataForMarkdownContent()这两个方法。
     实际处理时，目前几个子类编辑器都修正为重写重写loadDataNoMarkdown()和loadDataForMarkdownContent()方案。
     */

    /// 加载草稿 非markdown部分
    func loadDraftNoMarkdown() -> Void {
    }
    /// 加载草稿 markdown部分
    func loadDraftWithMarkdown() -> Void {
    }
    /// 加载更新 非markdown部分
    func loadUpdateNoMarkdown() -> Void {
    }
    /// 加载更新 markdown部分
    func loadUpdateWithMarkdown() -> Void {
    }

    /// 加载数据 非markdown部分
    func loadDataNoMarkdown() -> Void {
        switch self.editType {
        case .normal:
            break
        case .draft:
            // 草稿的非markdown相关部分加载
            self.loadDraftNoMarkdown()
            break
        case .update:
            // 更新的非markdown相关部分加载
            self.loadUpdateNoMarkdown()
            break
        }
    }
    /// 加载数据 markdown部分
    func loadDataForMarkdownContent() -> Void {
        switch self.editType {
        case .normal:
            break
        case .draft:
            self.loadDraftWithMarkdown()
        case .update:
            self.loadUpdateWithMarkdown()
        }
    }

    /// 明确markdown进行加载
    func loadDataWithMarkdown(_ markdown: String) -> Void {
        // 有链接的必须这样处理，否则根本就展示不出来
        var customMarkdown = markdown
        customMarkdown.replaceAll(matching: "\"", with: "\'")
        // 判断是否包含图片，进行分别处理
        if !customMarkdown.ts_customMarkdownIsContainImageCode() {
            // 不包含图片，则直接展示
            self.editorView.setContentWithMarkdown(markdown)
            self.couldNextProcess()
        } else {
            // 包含图片，则去下载图片(下载管理中会判断本地是否有该图片)
            let fileIds = customMarkdown.ts_getCustomMarkdownImageId()
            // 记录原草稿中的图片ID，用于保留图片缓存使用
            self.draftImageIDs = fileIds
            self.loading()
            TSWebEditorImageManager.default.downloadImages(fileIds: fileIds, complete: { [weak self] in
                guard let WeakSelf = self else {
                    return
                }
                self?.endLoading()
                // 构建本地的imageMap
                let cacheManager = TSWebEditorImageManager.default
                var index = 0
                for fileId in fileIds {
                    if let cachenode = cacheManager.getImageNode(fileId: fileId), let image = UIImage(contentsOfFile: cachenode.filePath) {
                        self?.imageMap.updateValue(TSWebEditorImageNode(index: index, image: image, name: cachenode.name), forKey: index)
                        self?.imageMap[index]?.fileId = fileId
                        self?.imageMap[index]?.uploaded = true
                    }
                    index += 1
                }
                WeakSelf.currentImgIndex = index
                // 加载内容
                let result = customMarkdown.ts_convertCustomMarkdownToEditMarkdown()
                let content = result.markdown
                self?.editorView.setContentWithMarkdown(content)
                // 给图片添加markdown标记/事件响应
                self?.editorView.markdownLoadedImageProcess(dicArray: result.dicArray)
                self?.couldNextProcess()
            })
        }
    }
}

extension TSWebEditorBaseController {
    /// 获取图片文件id
    func getImageIds() -> [Int] {
        var imageIdList: [Int] = [Int]()
        // 1. imageMap遍历获取
        // 注1：之前imageMap不能记录delete键删除的图片，所以当时采用imageMap + js确认的方案获取。现在可不判断了。
        // 注2：imageMap是字典，直接遍历导致顺序可能异常
//        for (_, imageNode) in self.imageMap {
//            // js判断该图片是否存在
//            if self.editorView.isExistImage(imageIndex: imageNode.index), let fileId = imageNode.fileId {
//                imageIdList.append(fileId)
//            }
//        }
        // 2. markdown正则判定获取
        if let markdown = self.editorView.getContentMarkdown() as? String {
            imageIdList = markdown.ts_getCustomMarkdownImageId()
        }
        return imageIdList
    }

    /// 获取已添加的图片数量
    func getAddedImageCount() -> Int {
        return self.getImageIds().count
    }

    /// 根据markdown中获取的fileId列表进行批量删除
    func removeImageCaches(fileIds: [Int]) -> Void {
        TSWebEditorImageManager.default.deleteImages(fileIds: fileIds)
    }
}

extension TSWebEditorBaseController {
    func couldNext() -> Bool {
        var couldFlag: Bool = true
        guard let markdown = self.editorView.getContentMarkdown(), let summary = self.editorView.getContentText() else {
            return false
        }
        //除去前后空格
        let markdownSpace = markdown.trimmingCharacters(in: .whitespaces)
//        markdown = markdown.trimmingCharacters(in: .whitespaces)
        let isExistImage = markdownSpace.ts_customMarkdownIsContainImageCode()
        // TODO: - iOS9.x 版本的模拟器 在这里获取的值为空，待解决
        // js错误也可能造成这种情况
        // summary 和imageIds不能同时为空
        if markdownSpace.isEmpty || (summary.isEmpty && !isExistImage) {
            couldFlag = false
        }
        return couldFlag
    }

    func couldNextProcess() -> Void {
        self.rightItem.isEnabled = self.couldNext()
    }

    /// 打印内容，用于调试，markdown和html需要格式化
    func nextTest() -> Void {
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

    func nextProcess() -> Void {
        self.nextTest()
    }
}

extension TSWebEditorBaseController {
    /// 保存草稿判断
    func couldSaveDraft() -> Bool {
        let couldFlag: Bool = false
        return couldFlag
    }
    /// 显示保存草稿提示弹窗
    func showSaveDraftDialogView() -> Void {
        let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
        alertVC.addAction(TSAlertAction(title: "选择_放弃编辑".localized, style: .default, handler: { (action) in
            // 需要判断是否是从草稿箱过来的
            // 如果当前是编辑草稿的二次编辑，就清理
            if self.isEditDraft == false {
                self.removeImageCaches(fileIds: self.getImageIds()) // 移除缓存图片
            }
            _ = self.navigationController?.popViewController(animated: true)
        }))
        alertVC.addAction(TSAlertAction(title: "选择_保存至草稿箱".localized, style: .default, handler: { (action) in
            self.saveDraft()
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alertVC, animated: false, completion: nil)
    }
    /// 保存草稿
    func saveDraft() -> Void {

    }
}

// MARK: - 事件响应

extension TSWebEditorBaseController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /// 导航栏左侧按钮点击响应
   func leftItemClick() -> Void {
        self.view.endEditing(true)
        // 根据内容判断是否弹出草稿箱提示弹窗
        if self.couldSaveDraft() {
            self.showSaveDraftDialogView()
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    /// 导航栏右侧按钮点击响应
    func rightItemClick() -> Void {
        self.view.endEditing(true)
        if self.couldNext() {
            self.nextProcess()
        }
    }
}

// MARK: - Extension Function

extension TSWebEditorBaseController {
    /// 聚焦编辑器
    func focusContentEditor() -> Void {
        self.editorView.keyboardDisplayRequiresUserAction = false
        self.editorView.focusContentEditor()
        self.editorToolbar.inputEnable = true
    }
}

extension TSWebEditorBaseController {
    /// 显示链接插入对话框
    func showInsertLinkDialog(url: String?, title: String?) -> Void {
        // 添加 或 编辑 的标题
        let linkVC = TSSuperLinkVC()
        linkVC.show(vc: linkVC, link: url, linkTitle: title, kbHeight: currentKbH)
        linkVC.sendBlock = { (link, linkTitle) in
            var linkUrl = link
            if linkUrl == "" {
                return
            }
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

extension TSWebEditorBaseController {

    func showInsertImageDialog() -> Void {
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
    func openLibrary() -> Void {
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
    func openCamera() -> Void {
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
    func insertImage(_ image: UIImage, url: String, name: String) -> Void {
        // 上传图片
        self.imageMap.updateValue(TSWebEditorImageNode(index: self.currentImgIndex, image: image, name: name), forKey: self.currentImgIndex)
        self.uploadImage(image, index: self.currentImgIndex)
        // 显示图片
        let width = UIScreen.main.bounds.size.width - 15 * 2 - 10 * 2 // 边距
        let height = image.size.height / image.size.width * width
        //self.editorView.insertImage(image, imageIndex: self.currentImgIndex, alt: "", width: width, height: height)
        self.editorView.insertImage(url: url, imageIndex: self.currentImgIndex, alt: "", width: width, height: height)
        // 图片序号修正
        self.currentImgIndex += 1
    }

    /// 上传图片
    func uploadImage(_ image: UIImage, index: Int) -> Void {
        // 上传图片请求
        // 在图片上传前压缩
        HUD.show(.progress)
        TSUploadNetworkManager().uploadImage(image: image) { [weak self](fileId, msg, status) in
            HUD.flash(.progress)
            guard status, let fileId = fileId else {
                //self?.uploadImageFailure(imageIndex: index)
                // 图片上传失败处理 - 提示并移除该图片
                self?.editorView.removeImage(imageIndex: index)
                // 图片缓存处理
                if let name = self?.imageMap[index]?.name {
                    TSWebEditorImageManager.default.deleteImage(name: name)
                }
                self?.imageMap.removeValue(forKey: index)
                TSUtil.showAlert(title: "图片上传失败", message: msg, clickAction: nil)
                return
            }
            print("new fileId: \(fileId)")
            // 图片上传成功
            self?.imageMap[index]?.fileId = fileId
            self?.imageMap[index]?.uploaded = true
            // 图片缓存处理
            if let name = self?.imageMap[index]?.name {
                TSWebEditorImageManager.default.uploadImageSuccess(name: name, fileId: fileId)
            }
            // 界面处理
            self?.editorView.uploadImageSuccess(imageIndex: index, fileId: fileId)
            self?.couldNextProcess()
        }
    }

    /// 重新上传图片
    func reloadImage(index: Int) -> Void {
        guard let node = self.imageMap[index] else {
            return
        }
        /// TODO: - 这里重新上传成功后应对界面进行修正(上传失败标记的隐藏)
        self.uploadImage(node.image, index: index)
    }

    /// 显示图片点击后的弹窗
    func showImageClickDialogView(index: Int, isfailure: Bool) -> Void {
        let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
        let deleteAction = TSAlertAction(title: "选择_删除图片".localized, style: .default, handler: { (action) in
            // html中删除
            self.editorView.removeImage(imageIndex: index)
               self.currentImgIndex -= 1
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
    func imageClick(index: Int) -> Void {
        guard let imagenode = self.imageMap[index] else {
            return
        }
        self.view.endEditing(true)
        self.showImageClickDialogView(index: index, isfailure: imagenode.fileId == nil)
    }
    /// 图片删除响应
    func imageDelete(index: Int) -> Void {
        guard let imagenode = self.imageMap[index] else {
            return
        }

        print("imageDeleted fileId: \(imagenode.fileId!), index: \(imagenode.index)")

        // 图片删除回调响应，不再单独处理
        // 图片删除有两种方式：点击图片，弹出删除选项点击删除；使用delete键在编辑器中通过光标索引删除。
        // 注：目前图片上传失败则直接删除，之后可能会更正为上传失败显示失败标记，可能这里处理时需要注意下

        // 本地记录表中删除
        self.imageMap.removeValue(forKey: index)
        // 缓存图片的删除处理
        TSWebEditorImageManager.default.deleteImage(name: imagenode.name)
    }

}

extension TSWebEditorBaseController {

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

extension TSWebEditorBaseController {
    // 键盘弹出通知处理
    func keyboardWillShowNotificationProcess(_ notification: Notification) -> Void {
        guard let info = notification.userInfo, let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval, let kbEndFrame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        if emojiFocusEditor {
            emojiFocusEditor = false
            return
        }
        if self.emojiButton != nil {
            self.emojiButton.isSelected = false
        }
        let kbHeight: CGFloat = kbEndFrame.size.height
        currentKbH = kbHeight
        let animOptions: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: 0)
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
    }
    // 键盘隐藏通知处理
    func keyboardWillHideNotificationProcess(_ notification: Notification) -> Void {
        guard let info = notification.userInfo, let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval, let kbEndFrame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        if emojiFocusEditor {
            emojiFocusEditor = false
            return
        }
        if self.emojiTap {
            let kbHeight: CGFloat = kbEndFrame.size.height
            currentKbH = kbHeight
            let animOptions: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: 0)
//            self.editorToolbar.hiddenExtension()
            self.emojiView.isHidden = false
            self.emojiView.bottom = self.view.bottom - self.view.origin.y
            UIView.animate(withDuration: duration, delay: 0, options: animOptions, animations: {
                // Toolbar
                self.editorToolbar.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(self.view).offset(-self.emojiView.height)
                })
                // EditorView
                self.editorView.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(self.view).offset(-self.editorToolbar.currentHeight - self.emojiView.height)
                })
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.emojiView.isHidden = true
            let kbHeight: CGFloat = kbEndFrame.size.height
            currentKbH = kbHeight
            let animOptions: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: 0)
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

/// MARK: - WebEditor相关的js回调，用于子类重写
extension TSWebEditorBaseController {
    func editorDebug(_ msg: String) -> Void {
        print("msg: " + msg)
    }
    func editorContentFocus() -> Void {
        self.editorToolbar.inputEnable = true
    }
    func editorContentBlur() -> Void {
        emojiTap = false
        self.editorToolbar.inputEnable = false
        self.editorToolbar.hiddenExtension()
    }
    func editorContentChanged() -> Void {
        self.couldNextProcess()
    }
    func editorImageClick(index: Int) -> Void {
        self.imageClick(index: index)
    }
    func editorImageDelete(index: Int) -> Void {
        self.imageDelete(index: index)
    }
    func editorScrollPostion(_ postion: Double) -> Void {

    }
    func editorEnableEditingStyleItems(strItems: String) -> Void {
        self.nodeProcess(name: strItems)
    }
}

// MARK: - JS回调OC
extension TSWebEditorBaseController {
    /// debug调试
    func jsDebug(_ msg: String) -> Void {
        self.editorDebug(msg)
    }
    /// 正文输入框聚焦
    fileprivate func jsContentFocus() -> Void {
        self.editorContentFocus()
    }
    /// 正文输入框 失去焦点
    fileprivate func jsContentBlur() -> Void {
        self.editorContentBlur()
    }
    /// contentChange
    fileprivate func jsContentChange() -> Void {
        self.editorContentChanged()
    }
    /// imageClick
    fileprivate func jsImageClick(imageIndex: Int) -> Void {
        self.editorImageClick(index: imageIndex)
    }
    /// imageDelete
    fileprivate func jsImageDelete(imageIndex: Int) -> Void {
        self.editorImageDelete(index: imageIndex)
    }
    /// scroll y
    fileprivate func jsScrollPostion(_ position: Double) -> Void {
        self.editorScrollPostion(position)
    }
    /// EnableEditingStyleItems
    fileprivate func jsEnableEditingStyleItems(strItems: String) -> Void {
        self.editorEnableEditingStyleItems(strItems: strItems)
    }
}

// MARK: - Delegate Function

// MARK: - <UIScrollViewDelegate>
extension TSWebEditorBaseController: UIScrollViewDelegate {
    /// 拖动视图时关闭键盘
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        emojiTap = false
        self.view.endEditing(true)
        if !emojiView.isHidden {
            self.emojiView.isHidden = true
            let animOptions: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: 0)
            self.editorToolbar.hiddenExtension()
            UIView.animate(withDuration: 0.3, delay: 0, options: animOptions, animations: {
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

// MARK: - <UIWebViewDelegate>
extension TSWebEditorBaseController: UIWebViewDelegate {

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

        // imageDelete
        let imageDelete: @convention(block)() -> Void = { [unowned self] () -> Void in
            let args = JSContext.currentArguments()
            DispatchQueue.main.async {
                if let value = args?.first as? JSValue {
                    self.jsImageDelete(imageIndex: Int(value.toInt32()))
                }
            }
        }
        context.setObject(unsafeBitCast(imageDelete, to: AnyObject.self), forKeyedSubscript: "appImageDelete" as (NSCopying & NSObjectProtocol))

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

        // 加载数据
        self.loadDataForMarkdownContent()
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
extension TSWebEditorBaseController: TSEditorToolBarProtocol {
    /// 样式点击回调
    func richTextToolBar(toolbar: TSEditorToolBar, didClickTextStyle textStyle: TSEditorTextStyle, withSelectedState state: Bool) -> Void {
        emojiTap = false
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
//            if self.currentImgIndex > 8 {
//                TSIndicatorWindowTop.showDefaultTime(state: .faild, title: "你最多可以选择9张图片")
//                return
//            }
            self.showInsertImageDialog()
        default:
            self.editorView.setTextStyle(textStyle, selectedState: state)
        }
    }
    /// 键盘按钮点击回调
    func didClickKeyboardBtn(in toolbar: TSEditorToolBar) -> Void {
        emojiTap = false
        self.view.endEditing(true)
        if !emojiView.isHidden {
            self.emojiView.isHidden = true
            let animOptions: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: 0)
            self.editorToolbar.hiddenExtension()
            UIView.animate(withDuration: 0.3, delay: 0, options: animOptions, animations: {
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
    /// 高度变化回调
    func didHeightChanged(in toolbar: TSEditorToolBar) {

    }

    func richTextToolBarEmoji(toolbar: TSWebEditorToolBar, didClickTextStyle textStyle: TSEditorTextStyle, withSelectedState state: Bool, emojiButton: UIButton) {
        self.emojiButton = emojiButton
        emojiTap = true
        if state {
            self.editorView.blurContentEditor()
        } else {
            self.editorView.focusContentEditor()
        }
    }
}

// MARK: - <UIImagePickerControllerDelegate>
extension TSWebEditorBaseController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }

        // url: 图片保存到沙盒中的文件
        let imageNode = TSWebEditorImageManager.default.addImage(image)
        picker.dismiss(animated: true) {
            //self.insertImage(image)
            self.insertImage(image, url: imageNode.filePath, name: imageNode.name)
            self.editorContentBlur()
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        //self.focusContentEditor()
    }
}

extension TSWebEditorBaseController: TSSystemEmojiSelectorViewDelegate {
    /// 插入内容的时候需要开启聚焦,但是又要让键盘弹起来,就只能马上关闭聚焦,这样会有一个工具栏上下浮动(Y坐标改变)动画渐变,所以增加了一个 emojiFocusEditor 属性来判断是不是因为点击来表情插入表情的时候开启聚焦弹起键盘.如果是,那么就不改变工具栏的 y 坐标
    /// 备注: 这样做有一个问题就是点击来表情插入表情的时候有延迟,并不是点击来表情就立马显示了表情,会有延迟.
    /// 备注: 必须要对表情进行修饰,不然在插入超链接之后紧跟着插入表情会把表情插入到超链接上
    func emojiViewDidSelected(emoji: String) {
        emojiFocusEditor = true
        self.editorView.prepareInsert()
        self.editorView.focusContentEditor()
        self.editorView.insertHTML("<font>" + emoji + "</font>")
        emojiTap = true
        emojiFocusEditor = true
        self.editorView.blurContentEditor()
    }
}
