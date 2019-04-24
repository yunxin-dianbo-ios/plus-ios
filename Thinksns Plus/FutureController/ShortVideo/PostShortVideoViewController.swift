//
//  PostShortVideoViewController.swift
//  ThinkSNSPlus
//
//  Created by lip on 2018/3/27.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
//  【坑】视频发布成功后，充发成功后，预览页选择删除后都没有删除沙盒内导出的本地视频文件（文件分两种，相册导出和录制导出）
//  视频发送成功后，标记本地的视频备份数据为成功，每次启动APP的时候检查下本地标记为发送成功的视频备份 超过12小时的会被删除
//  用户手动点击清理缓存时，也需要主动删除一次已标记为成功的视频备份

import UIKit
import KMPlaceholderTextView
import TZImagePickerController
import AVKit
import SCRecorder

struct ShortVideoAsset {
    let coverImage: UIImage?
    let asset: PHAsset?
    let recorderSession: SCRecordSession?
    let videoFileURL: URL?
}

class PostShortVideoViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: KMPlaceholderTextView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var reRecorderViewLayout: NSLayoutConstraint!
    @IBOutlet weak var insetCountLabel: UILabel!
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var topicViewHeight: NSLayoutConstraint!
    var playerViewController: AVPlayerViewController?
    @IBOutlet weak var atView: UIView!
    // 发布按钮
    var postBtn = TSTextButton.initWith(putAreaType: .top)
    // 最大内容字数
    let maxContentCount: Int = 255
    // 显示字数时机
    let showWordsCount: Int = 200
    ///从话题进入的发布页面自带一个不能删除的话题
    var chooseModel: TopicCommonModel?
    /// 话题信息
    var topics: [TopicCommonModel] = []

    /// 输入框顶部工具栏
    // 整个容器
    var toolView = UIView()
    // 下分割线
    var bottomLine = UIView()
    // 上分割线
    var topLine = UIView()
    /// 表情按钮
    var smileButton = UIButton(type: .custom)
    /// 收起按钮
    var packUpButton = UIButton(type: .custom)
    /// 选择Emoji的视图
    var emojiView: TSSystemEmojiSelectorView!
    var toolHeight: CGFloat = 145 + TSBottomSafeAreaHeight + 41
    var isTapOtherView = false
    var isPriceTextFiledTap = false

    /// 短视频资源
    ///
    /// - Note: 录制的视频 (outputURL 和 coverImage) 或者 相册选择的视频 (outputURL 和 coverImage)
    var shortVideoAsset: ShortVideoAsset? {
        didSet {
            reloadShortVideoAsset()
        }
    }

    /// TODO: 录制或者相册选择都用一个outputURL 重复覆盖 然后上传成功删除
    //
    // 进入视频预览页面 用 outputURL预览 如果撤销的话 那么就 删除outputURL 对应的文件
    func reloadShortVideoAsset() {
        guard let reRecorderViewLayout = reRecorderViewLayout else {
            return
        }
        guard let shortVideoAsset = shortVideoAsset else {
            reRecorderViewLayout.constant = 25
            return
        }
        reRecorderViewLayout.constant = 108
        if let coverImage = shortVideoAsset.coverImage {
            previewImageView.image = coverImage
        } else if let image = shortVideoAsset.recorderSession?.segments[0].thumbnail {
            previewImageView.image = image
        }
    }

    // 通过判断约束来判断目前是否显示了短视频
    private func isContainShortVideo() -> Bool {
        return reRecorderViewLayout.constant == 108
    }

    func checkPostStatus() {
        // 有视频就一定能发,没有视频就一定不能发
        postBtn.isEnabled = isContainShortVideo()
    }

    func postShortVideo(_ btn: UIButton) {
        guard let shortVideoAsset = shortVideoAsset else {
            assert(false)
            return
        }
        // 导出视频
        textView.resignFirstResponder()
        btn.isEnabled = false
        // 导出视频
        if let asset = shortVideoAsset.asset {
            let str = self.textView.text
            let indicator = TSIndicatorWindowTop(state: .loading, title: "视频处理中")
            indicator.show()
            TZImageManager.default().getVideoOutputPath(withAsset: asset, presetName: AVAssetExportPreset640x480, success: { (url) in
                indicator.dismiss()
                self.navigationController?.dismiss(animated: true, completion: {
                    /// 判断到底是话题进入的发布页面还是其他情况进入的发布页面
                    if self.chooseModel == nil {
                        TSRootViewController.share.tabbarVC?.selectedIndex = 0
                    }
                    TSMomentTaskQueue().postShortVideo(urlPath: url!, coverImage: shortVideoAsset.coverImage!, feedContent: str, topicsInfo: self.topics, isTopicPublish: self.chooseModel != nil ? true : false)
                })
            }, failure: { (errorMessage, error) in
                indicator.dismiss()
                btn.isEnabled = true
                let error = TSIndicatorWindowTop(state: .faild, title: errorMessage)
                error.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            })
        } else if let recorderSession = shortVideoAsset.recorderSession {
            // 直接上传即可,录制视频在之前已经导出到沙盒了
            let str = self.textView.text
            self.navigationController?.dismiss(animated: true, completion: {
                /// 判断到底是话题进入的发布页面还是其他情况进入的发布页面
                if self.chooseModel == nil {
                    TSRootViewController.share.tabbarVC?.selectedIndex = 0
                }
                TSMomentTaskQueue().postShortVideo(urlPath: recorderSession.outputUrl.absoluteString, coverImage: shortVideoAsset.coverImage!, feedContent: str, topicsInfo: self.topics, isTopicPublish: self.chooseModel != nil ? true : false)
            })
        } else if let url = shortVideoAsset.videoFileURL {
            let str = self.textView.text
            self.navigationController?.dismiss(animated: true, completion: {
                /// 判断到底是话题进入的发布页面还是其他情况进入的发布页面
                if self.chooseModel == nil {
                    TSRootViewController.share.tabbarVC?.selectedIndex = 0
                }
                TSMomentTaskQueue().postShortVideo(urlPath: url.absoluteString, coverImage: shortVideoAsset.coverImage!, feedContent: str, topicsInfo: self.topics, isTopicPublish: self.chooseModel != nil ? true : false)
            })
        }
    }

    private func deleteShortVideoFile() {
        // 清理硬盘中缓存的视频
        // 导入新的过来 如果是视频 就删除掉上一个的文件
//        let fileManager = FileManager.default
//        guard let url = shortVideoAsset?.outputURL else {
//            assert(false, "需要删除文件但是没有路径")
//            return
//        }
//        if fileManager.fileExists(atPath: url.path) {
//            try? fileManager.removeItem(at: url)
//        }
    }

    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(topicChooseNotice(notice:)), name: NSNotification.Name(rawValue: "passPublishTopicData"), object: nil)
        setupUI()
        let tap = UITapGestureRecognizer { (_) in
            self.isTapOtherView = true
            if !self.textView.isFirstResponder && !self.toolView.isHidden {
                self.toolView.isHidden = true
            }
            self.textView.resignFirstResponder()
        }
        self.scrollView.addGestureRecognizer(tap)
        let atViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapAtView))
        atView.addGestureRecognizer(atViewTap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHideNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.navigationController?.isNavigationBarHidden = false
        reloadShortVideoAsset()
        checkPostStatus()
    }

    func setupUI() {
        /// 初始化键盘顶部工具视图
        toolView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: toolHeight)
        toolView.backgroundColor = UIColor.white
        self.view.addSubview(toolView)
        toolView.isHidden = true

        topLine.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 0.5)
        topLine.backgroundColor = TSColor.normal.keyboardTopCutLine
        toolView.addSubview(topLine)

        packUpButton.frame = CGRect(x: 25, y: 0, width: 22, height: 22)
        packUpButton.setImage(#imageLiteral(resourceName: "sec_nav_arrow"), for: .normal)
        packUpButton.centerY = 41 / 2.0
        toolView.addSubview(packUpButton)
        packUpButton.addTarget(self, action: #selector(packUpKey), for: UIControlEvents.touchUpInside)

        smileButton.frame = CGRect(x: ScreenWidth - 50, y: 0, width: 25, height: 25)
        smileButton.setImage(#imageLiteral(resourceName: "ico_chat_keyboard_expression"), for: .normal)
        smileButton.setImage(#imageLiteral(resourceName: "ico_chat_keyboard"), for: .selected)
        smileButton.centerY = packUpButton.centerY
        toolView.addSubview(smileButton)
        smileButton.addTarget(self, action: #selector(emojiBtnClick), for: UIControlEvents.touchUpInside)

        emojiView = TSSystemEmojiSelectorView(frame: CGRect(x: 0, y: 41, width: ScreenWidth, height: 0))
        emojiView.delegate = self
        toolView.addSubview(emojiView)
        emojiView.frame = CGRect(x: 0, y: 41, width: ScreenWidth, height: toolHeight - 41)

        bottomLine.frame = CGRect(x: 0, y: 40, width: ScreenWidth, height: 1)
        bottomLine.backgroundColor = UIColor(hex: 0x667487)
        toolView.addSubview(bottomLine)

        self.title = "发布动态"
        textView.becomeFirstResponder()
        // 键盘的return键为换行样式
        textView.returnKeyType = .default
        textView.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        textView.placeholderColor = TSColor.normal.disabled
        textView.placeholderFont = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        textView.delegate = self
        // 设置右边的发送 控制发送按钮的显示与否
        postBtn.setTitle("显示_发布".localized, for: .normal)
        postBtn.addTarget(self, action: #selector(postShortVideo(_:)), for: .touchUpInside)
        postBtn.contentHorizontalAlignment = .right
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: postBtn)
        postBtn.isEnabled = false

        let backBarItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backBtnAction(_:)))
        self.navigationItem.leftBarButtonItem = backBarItem

        previewImageView.contentScaleFactor = UIScreen.main.scale
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        previewImageView.clipsToBounds = true
        setTopicViewUI(showTopic: true, topicData: topics)
    }

    // MARK: action
    func backBtnAction(_ btn: UIButton) {
        textView.resignFirstResponder()
        if self.textView.text.count > 0 || (shortVideoAsset != nil) {
            let actionsheetView = TSCustomActionsheetView(titles: ["提示信息_你还有没发布的内容,是否放弃发布?".localized, "选择_确定".localized])
            actionsheetView.delegate = self
            actionsheetView.tag = 2
            actionsheetView.notClickIndexs = [0]
            actionsheetView.show()
        } else {
            navigationController?.dismiss(animated: true)
        }
    }

    @IBAction func previewBtnAction(_ sender: Any) {
        guard let shortVideoAsset = shortVideoAsset else {
            return
        }
        if let asset = shortVideoAsset.asset {
            TZImageManager.default().getVideoWithAsset(asset) { [weak self] item, dictionary in
                guard let `self` = self, let item = item else {
                    return
                }
                DispatchQueue.main.async {
                    let vc = PreviewVideoVC(nibName: "PreviewVideoVC", bundle: nil)
                    vc.avasset = item.asset
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else if let asset = shortVideoAsset.recorderSession?.assetRepresentingSegments() {
            let vc = PreviewVideoVC(nibName: "PreviewVideoVC", bundle: nil)
            vc.avasset = asset
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        } else  if let url = shortVideoAsset.videoFileURL {
            let vc = PreviewVideoVC(nibName: "PreviewVideoVC", bundle: nil)
            vc.avasset = AVAsset(url: url)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func reRecorderBtnAction(_ sender: Any) {
        showShortVideoPickerVC()
    }

    private func showShortVideoPickerVC() {
        guard let imagePickerVC = TZImagePickerController(maxImagesCount: 1, columnNumber: 4, delegate: self, pushPhotoPickerVc: true, mainColor: TSColor.main.theme) else {
            return
        }
        /// 不设置则直接用TZImagePicker的pod中的图片素材
        /// #视频选择列表页面
        /// item右上角蓝色的选中图片、视频拍摄按钮
//            imagePickerVC.selectImage = UIImage(named: "msg_box_choose_now")
//        imagePickerVC.takeVideo = UIImage(named: "pic_shootvideo")
        /// #视频裁剪页面
        /// 返回按钮、视频长度截取左侧选择滑块、视频长度截取右侧选择滑块
//        imagePickerVC.backImage = UIImage(named: "ico_title_back_black")
//        imagePickerVC.editFaceLeft = UIImage(named: "pic_eft")
//        imagePickerVC.editFaceRight = UIImage(named: "pic_right")
        /// #封面选择页面
        /// 封面选择滑块
//        imagePickerVC.picCoverImage = UIImage(named: "pic_cover_frame")

        imagePickerVC.isSelectOriginalPhoto = false
        imagePickerVC.allowTakePicture = true
        imagePickerVC.allowPickingVideo = true
        imagePickerVC.allowPickingImage = false
        imagePickerVC.allowPickingGif = false
        imagePickerVC.allowPickingMultipleVideo = false
        imagePickerVC.sortAscendingByModificationDate = false
        imagePickerVC.navigationBar.barTintColor = UIColor.white
        var dic = [String: Any]()
        dic[NSForegroundColorAttributeName] = UIColor.black
        imagePickerVC.navigationBar.titleTextAttributes = dic
        present(imagePickerVC, animated: true)
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > maxContentCount {
            TSAccountRegex.checkAndUplodTextFieldText(textField: textView, stringCountLimit: maxContentCount)
        }
        checkPostStatus()
        TSReleasePulseTool.setShowWordsCountLabelContent(textView: textView, showWordsCountLabel: insetCountLabel, showWordsCount: showWordsCount, maxContentCount: maxContentCount)
        // At
        let selectedRange = textView.markedTextRange
        if selectedRange == nil {
            let range = textView.selectedRange
            let attString = NSMutableAttributedString(string: textView.text)
            attString.addAttributes([NSForegroundColorAttributeName: UIColor.black], range: NSRange(location: 0, length: attString.length))
            attString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)], range:  NSRange(location: 0, length: attString.length))
            attString.addAttributes([NSForegroundColorAttributeName: UIColor.black], range: NSRange(location: 0, length: attString.length))
            let matchs = TSUtil.findAllTSAt(inputStr: textView.text)
            for item in matchs {
                attString.addAttributes([NSForegroundColorAttributeName: TSColor.main.theme], range: NSRange(location: item.range.location, length: item.range.length - 1))
            }
            textView.attributedText = attString
            textView.selectedRange = range
            return
        }
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        /// 整体不可编辑
        // 联想文字则不修改
        let range = textView.selectedRange
        if range.length > 0 {
            return
        }
        let matchs = TSUtil.findAllTSAt(inputStr: textView.text)
        for match in matchs {
            let newRange = NSRange(location: match.range.location + 1, length: match.range.length - 1)
            if NSLocationInRange(range.location, newRange) {
                textView.selectedRange = NSRange(location: match.range.location + match.range.length, length: 0)
                break
            }
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" {
            let selectRange = textView.selectedRange
            if selectRange.length > 0 {
                return true
            }
            // 整体删除at的关键词，修改为整体选中
            var isEditAt = false
            var atRange = selectRange
            let mutString = NSMutableString(string: textView.text)
            let matchs = TSUtil.findAllTSAt(inputStr: textView.text)
            for match in matchs {
                let newRange = NSRange(location: match.range.location + 1, length: match.range.length - 1)
                if NSLocationInRange(range.location, newRange) {
                    isEditAt = true
                    atRange = match.range
                    break
                }
            }
            if isEditAt {
                textView.text = String(mutString)
                textView.selectedRange = atRange
                return false
            }
        } else if text == "@" {
            // 跳转到at列表
            self.pushAtSelectedList()
            // 手动输入的at在选择了用户的block中会先移除掉,如果跳转后不选择用户就不做处理
            return true
        }
        return true
    }

    func emojiBtnClick() {
        smileButton.isSelected = !smileButton.isSelected
        if smileButton.isSelected {
            isTapOtherView = false
            textView.resignFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
    }

    func packUpKey() {
        smileButton.isSelected = false
        textView.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.toolView.isHidden = true
        }
    }
}

extension PostShortVideoViewController: PreviewVideoVCDelegate {
    func previewDeleteVideo() {
        self.shortVideoAsset = nil
    }
}

extension PostShortVideoViewController: TZImagePickerControllerDelegate {
    func imagePickerController(_ picker: TZImagePickerController!, didFinishEditVideoCover coverImage: UIImage!, videoURL: Any!) {
        self.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, recorderSession: nil, videoFileURL: videoURL as! URL)
    }
    func imagePickerControllerDidClickTakePhotoBtn(_ picker: TZImagePickerController!) {
        // push 录制控制器
        let vc = RecorderViewController(minDuration: TSAppConfig.share.localInfo.postMomentsRecorderVideoMinDuration, maxDuration: TSAppConfig.share.localInfo.postMomentsRecorderVideoMaxDuration)
        vc.delegate = self
        vc.isDismissOrPop = false
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // 视频长度超过5分钟少于4秒钟的都不显示
    func isAssetCanSelect(_ asset: Any!) -> Bool {
        guard let asset = asset as? PHAsset else {
            return false
        }
        if asset.mediaType == .video {
            return asset.duration < 5 * 60 && asset.duration > 3
        }
        return false
    }
}

extension PostShortVideoViewController: RecorderVCDelegate {
    func finishRecorder(recordSession: SCRecordSession, coverImage: UIImage) {
        self.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, recorderSession: recordSession, videoFileURL: nil)
    }
}

extension PostShortVideoViewController: UIScrollViewDelegate {
    // 如果动了 撤销掉输入框焦点
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != textView {
            textView.resignFirstResponder()
        }
    }
}

// MARK: - 话题板块儿
extension PostShortVideoViewController {
    // 布局话题板块儿
    func setTopicViewUI(showTopic: Bool, topicData: [TopicCommonModel]) {
        topicView.removeAllSubViews()
        if showTopic {
            let topLine = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 0.5))
            topLine.backgroundColor = TSColor.inconspicuous.disabled
            topicView.addSubview(topLine)

            if topicData.isEmpty {
                let addTopicLabel = UILabel(frame: CGRect(x: 20, y: 1, width: 100, height: 49))
                addTopicLabel.text = "添加话题"
                addTopicLabel.textColor = UIColor(hex: 0x333333)
                addTopicLabel.font = UIFont.systemFont(ofSize: 15)
                topicView.addSubview(addTopicLabel)

                let rightIcon = UIImageView(frame: CGRect(x: ScreenWidth - 20 - 10, y: 0, width: 10, height: 20))
                rightIcon.clipsToBounds = true
                rightIcon.contentMode = .scaleAspectFill
                rightIcon.image = #imageLiteral(resourceName: "IMG_ic_arrow_smallgrey")
                rightIcon.centerY = addTopicLabel.centerY
                topicView.addSubview(rightIcon)

                /// 外加一个点击事件button
                let addButton = UIButton(type: .custom)
                addButton.backgroundColor = UIColor.clear
                addButton.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 50)
                addButton.addTarget(self, action: #selector(jumpToTopicSearchVC), for: UIControlEvents.touchUpInside)
                topicView.addSubview(addButton)
                topicViewHeight.constant = 50
                topicView.updateConstraints()
                let bottomLine = UIView(frame: CGRect(x: 0, y: topicViewHeight.constant - 0.5, width: ScreenWidth, height: 0.5))
                bottomLine.backgroundColor = TSColor.inconspicuous.disabled
                topicView.addSubview(bottomLine)
            } else {
                var XX: CGFloat = 15
                var YY: CGFloat = 14
                let labelHeight: CGFloat = 24
                let inSpace: CGFloat = 8
                let outSpace: CGFloat = 20
                let maxWidth: CGFloat = ScreenWidth - 30
                var tagBgViewHeight: CGFloat = 0
                for (index, item) in topicData.enumerated() {
                    var labelWidth = item.name.sizeOfString(usingFont: UIFont.systemFont(ofSize: 10)).width
                    labelWidth = labelWidth + inSpace * 2
                    if labelWidth > maxWidth {
                        labelWidth = maxWidth
                    }
                    let tagLabel: UIButton = UIButton(type: .custom)
                    let bgView: UIImageView = UIImageView()
                    tagLabel.frame = CGRect(x: XX, y: YY, width: labelWidth, height: labelHeight)
                    XX = tagLabel.right + outSpace
                    if tagLabel.right > maxWidth {
                        XX = 15
                        YY = tagLabel.bottom + outSpace
                        tagLabel.frame = CGRect(x: XX, y: YY, width: labelWidth, height: labelHeight)
                        XX = tagLabel.right + outSpace
                    }
                    tagLabel.backgroundColor = UIColor(hex: 0xe6e6e6)
                    tagLabel.setTitleColor(UIColor.white, for: .normal)
                    tagLabel.layer.cornerRadius = 3
                    tagLabel.setTitle(item.name, for: .normal)
                    tagLabel.titleLabel?.font = UIFont.systemFont(ofSize: 10)
                    tagLabel.tag = 666 + index
                    tagLabel.addTarget(self, action: #selector(deleteTopicButton(sender:)), for: UIControlEvents.touchUpInside)
                    topicView.addSubview(tagLabel)

                    bgView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 16, height: 16))
                    bgView.center = CGPoint(x: tagLabel.origin.x + 3, y: tagLabel.origin.y + 3)
                    bgView.layer.cornerRadius = 8
                    bgView.image = #imageLiteral(resourceName: "ico_topic_close")
                    bgView.tag = 999 + index
                    bgView.isUserInteractionEnabled = true
                    let deleteTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteTopic(tap:)))
                    bgView.addGestureRecognizer(deleteTap)
                    topicView.addSubview(bgView)
                    bgView.isHidden = false
                    if chooseModel != nil {
                        if item.id == chooseModel?.id {
                            bgView.isHidden = true
                        }
                    }

                    if topicData.count < 5 {
                        if index == (topicData.count - 1) {
                            // 需要增加一个添加话题按钮
                            let addImage = UIImageView()
                            addImage.frame = CGRect(x: XX, y: YY, width: 42, height: 24)
                            if addImage.right > maxWidth {
                                XX = 15
                                YY = tagLabel.bottom + outSpace
                                addImage.frame = CGRect(x: XX, y: YY, width: 42, height: 24)
                                XX = addImage.right + outSpace
                            }
                            addImage.clipsToBounds = true
                            addImage.layer.cornerRadius = 3
                            addImage.contentMode = .scaleAspectFill
                            addImage.image = #imageLiteral(resourceName: "ico_add_topic")
                            addImage.isUserInteractionEnabled = true
                            let addTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(jumpToTopicSearchVC))
                            addImage.addGestureRecognizer(addTap)
                            topicView.addSubview(addImage)
                            tagBgViewHeight = addImage.bottom + 14
                        }
                    } else {
                        if index == (topicData.count - 1) {
                            tagBgViewHeight = tagLabel.bottom + 14
                        }
                    }
                }
                topicViewHeight.constant = tagBgViewHeight
                topicView.updateConstraints()
                let bottomLine = UIView(frame: CGRect(x: 0, y: tagBgViewHeight - 0.5, width: ScreenWidth, height: 0.5))
                bottomLine.backgroundColor = TSColor.inconspicuous.disabled
                topicView.addSubview(topLine)
            }
        } else {
            topicViewHeight.constant = 0
            topicView.updateConstraints()
        }
    }

    /// 搜索话题页面选择话题之后发通知处理话题板块儿
    func topicChooseNotice(notice: Notification) {
        let dict: NSDictionary = notice.userInfo! as NSDictionary
        let model: TopicListModel = dict["topic"] as! TopicListModel
        let changeModel: TopicCommonModel = TopicCommonModel(topicListModel: model)
        /// 先检测已选的话题里面是不是已经有了当前选择的那个话题，如果有，不作处理（不添加到 topics数组里面），如果没有，直接添加进去
        var hasTopic = false
        if !topics.isEmpty {
            for item in topics {
                if item.id == changeModel.id {
                    hasTopic = true
                    break
                }
            }
            if hasTopic {
                return
            } else {
                topics.append(changeModel)
                setTopicViewUI(showTopic: true, topicData: topics)
            }
        } else {
            topics.append(changeModel)
            setTopicViewUI(showTopic: true, topicData: topics)
        }
    }

    /// 话题板块儿选择话题跳转到搜索话题页面
    func jumpToTopicSearchVC() {
        let searchVC = TopicSearchVC.vc()
        searchVC.jumpType = "publish"
        navigationController?.pushViewController(searchVC, animated: true)
    }

    /// 话题板块儿删除话题按钮点击事件
    func deleteTopic(tap: UIGestureRecognizer) {
        if !topics.isEmpty {
            topics.remove(at: (tap.view?.tag)! - 999)
            setTopicViewUI(showTopic: true, topicData: topics)
        }
    }

    /// 话题板块儿点击话题按钮删除话题
    func deleteTopicButton(sender: UIButton) {
        if !topics.isEmpty {
            if chooseModel != nil {
                let model = topics[sender.tag - 666]
                if model.id == chooseModel?.id {
                    return
                }
            }
            topics.remove(at: sender.tag - 666)
            setTopicViewUI(showTopic: true, topicData: topics)
        }
    }

    /// 话题板块儿获取当前已选择的话题 id 然后组装成一个 id 数组（用于发布接口传值）
    /// 没选择话题的情况下发布接口对应的话题字段就不传，如果有就传话题 ID 数组
    func getCurrentTopicIdArray() -> NSArray {
        let pass = NSMutableArray()
        if !topics.isEmpty {
            for item in topics {
                pass.append(item.id)
            }
        }
        return pass
    }
}

// MARK: - at人
extension PostShortVideoViewController {
    /// 点击了atView
    func didTapAtView() {
        self.pushAtSelectedList()
    }
    /// 跳转到可选at人的列表
    func pushAtSelectedList() {
        let atselectedListVC = TSAtSelectListVC()
        atselectedListVC.selectedBlock = { (userInfo) in
            /// 先移除光标所在前一个at
            self.textView = TSCommonTool.atMeTextViewEdit(self.textView) as! KMPlaceholderTextView!
            let spStr = String(data: ("\u{00ad}".data(using: String.Encoding.unicode))!, encoding: String.Encoding.unicode)
            let insertStr = spStr! + "@" + userInfo.name + spStr! + " "
            self.textView.insertText(insertStr)
        }
        self.navigationController?.pushViewController(atselectedListVC, animated: true)
    }
}

// MARK: - TSCustomAcionSheetDelegate
extension PostShortVideoViewController: TSCustomAcionSheetDelegate {
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if view.tag == 2 {
            let _ = self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
}

extension PostShortVideoViewController {
    /// 键盘通知响应
    @objc fileprivate func kbWillShowNotificationProcess(_ notification: Notification) -> Void {
        guard let userInfo = notification.userInfo, let kbFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        if isPriceTextFiledTap {
            self.toolView.isHidden = true
        } else {
            self.toolView.isHidden = false
            self.smileButton.isSelected = false
            self.toolView.top = kbFrame.origin.y - (TSBottomSafeAreaHeight + 41 + 64.0)
        }
    }
    @objc fileprivate func kbWillHideNotificationProcess(_ notification: Notification) -> Void {
        self.toolView.top = ScreenHeight - toolHeight - 64.0 - TSBottomSafeAreaHeight
        self.smileButton.isSelected = true
        self.toolView.isHidden = isTapOtherView
    }
}

extension PostShortVideoViewController: TSSystemEmojiSelectorViewDelegate {
    func emojiViewDidSelected(emoji: String) {
        self.textView.insertText(emoji)
        self.textView.scrollRangeToVisible(self.textView.selectedRange)
    }
}
