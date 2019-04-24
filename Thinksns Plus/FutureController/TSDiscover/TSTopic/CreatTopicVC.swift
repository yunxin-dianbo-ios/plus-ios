//
//  CreatTopicVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/23.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher
import TZImagePickerController
import TYAttributedLabel

class CreatTopicVC: TSViewController, TSCustomAcionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, TZImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TYAttributedLabelDelegate {

    /// 导航栏上的下一步按钮
    private weak var nextBtn: UIButton!
    /// 如果有小屏手机适配问题，可以用scrollview去装这些控件
    var faceImageView: UIImageView!
    var cameraIcon: UIImageView!
    var cameraLabel: UILabel!
    var titleButton = UIButton(type: .custom)
    var titleField: UITextField!
    var introtextView: UITextView!
    var countLabel: UILabel!
    var explen: UILabel!
    var placeHolderButton: UILabel!
    var tipsLabel: UILabel!
    var mengcengView: UIView!
    var tyLabel: TYAttributedLabel!
    var isEditPush: Bool = false
    var topicListModel = TopicListControllerModel()
    /// 在编辑话题的时候是否更换了封面图
    var hasChangeFaceImage = false
    var currentKbH: CGFloat = 0
    var isTextField = false
    /// 默认图片压缩后最大物理体积200kb
    fileprivate static let postImageMaxSizeKb: CGFloat = 200

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHideNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fieldBeginEditingNotificationProcess(_:)), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fieldEndEditingNotificationProcess(_:)), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewBeginEditingNotificationProcess(_:)), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewEndEditingNotificationProcess(_:)), name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(textViewDidChanged(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(textFieldDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        creatSubUI()
        checkTitleFieldStatus()
        // Do any additional setup after loading the view.
    }

    // MARK: - Private  UI
    private func initialUI() -> Void {
        self.view.backgroundColor = UIColor.white
        // navigation bar
        if !isEditPush {
            self.navigationItem.title = "创建话题"
            let backItem = UIButton(type: .custom)
            backItem.addTarget(self, action: #selector(backItemClick), for: .touchUpInside)
            self.setupNavigationTitleItem(backItem, title: "显示_导航栏_返回".localized)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backItem)
            let nextItem = UIButton(type: .custom)
            nextItem.addTarget(self, action: #selector(nextItemClick), for: .touchUpInside)
            self.setupNavigationTitleItem(nextItem, title: "创建")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextItem)
            nextItem.setTitleColor(UIColor.lightGray, for: .disabled)
            self.nextBtn = nextItem
        } else {
            self.navigationItem.title = "编辑话题"
            self.navigationItem.hidesBackButton = true
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "topbar_back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(backItemClick))
            self.navigationItem.leftItemsSupplementBackButton = true
            let nextItem = UIButton(type: .custom)
            nextItem.addTarget(self, action: #selector(nextItemClick), for: .touchUpInside)
            self.setupNavigationTitleItem(nextItem, title: "保存")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextItem)
            nextItem.setTitleColor(UIColor.lightGray, for: .disabled)
            self.nextBtn = nextItem
        }
    }

    func creatSubUI() {
        faceImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 188 * 375 / ScreenWidth))
        faceImageView.clipsToBounds = true
        faceImageView.layer.contentMode = .scaleAspectFill
        faceImageView.backgroundColor = UIColor(hex: 0xededed)
        faceImageView.isUserInteractionEnabled = true
        self.view.addSubview(faceImageView)
        let faceTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(faceViewTap))
        faceImageView.addGestureRecognizer(faceTap)

        tyLabel = TYAttributedLabel(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 21))
        tyLabel.text = "      上传话题封面"
        tyLabel.textColor = UIColor(hex: 0xb3b3b3)
        tyLabel.font = UIFont.systemFont(ofSize: 15)
        tyLabel.addImage(withName: "ico_topic_camera", range: NSRange(location: 0, length: 3), size: CGSize(width: 24, height: 21))
        tyLabel.textAlignment = .center
        tyLabel.centerY = faceImageView.centerY
        tyLabel.backgroundColor = UIColor.clear
        tyLabel.addLink(withLinkData: nil, linkColor: UIColor(hex: 0xb3b3b3), underLineStyle: .init(rawValue: 0), range: NSRange(location: 0, length: tyLabel.text.count))
        tyLabel.delegate = self
        self.view.addSubview(tyLabel)

        /// 蒙层
//        mengcengView = UIView(frame: CGRect(x: 0, y: faceImageView.bottom - 15 - 21 - 15, width: ScreenWidth, height: 36 + 15))
//        mengcengView.backgroundColor = UIColor.black
//        mengcengView.alpha = 0.3
//        let faceTap1: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(faceViewTap))
//        mengcengView.addGestureRecognizer(faceTap1)
//        self.view.addSubview(mengcengView)

        cameraIcon = UIImageView(frame: CGRect(x: 21, y: faceImageView.bottom - 15 - 21, width: 24, height: 21))
        cameraIcon.image = #imageLiteral(resourceName: "ico_topic_camera")
        cameraIcon.alpha = 0.2
        self.view.addSubview(cameraIcon)

        cameraLabel = UILabel(frame: CGRect(x: cameraIcon.right + 9, y: 0, width: 75, height: 16))
        cameraLabel.backgroundColor = UIColor.clear
        cameraLabel.text = "更换封面"
        cameraLabel.textColor = UIColor(hex: 0x000000)
        cameraLabel.alpha = 0.2
        cameraLabel.centerY = cameraIcon.centerY
        self.view.addSubview(cameraLabel)

        let titleLine = UIView(frame: CGRect(x: 15, y: faceImageView.bottom + 60, width: ScreenWidth - 30, height: fengeLineHeight))
        titleLine.backgroundColor = UIColor(hex: 0xebebeb)
        self.view.addSubview(titleLine)

        let introLine = UIView(frame: CGRect(x: 15, y: faceImageView.bottom + 157, width: ScreenWidth - 30, height: fengeLineHeight))
        introLine.backgroundColor = UIColor(hex: 0xebebeb)
        self.view.addSubview(introLine)

        titleButton.frame = CGRect(x: 20, y: faceImageView.bottom, width: ScreenWidth - 40, height: 60)
        titleButton.backgroundColor = UIColor.clear
        titleButton.tag = 666
        titleButton.addTarget(self, action: #selector(titleButtonClick(sender:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(titleButton)

        titleField = UITextField(frame: CGRect(x: 20, y: 0, width: ScreenWidth - 40, height: 20))
        titleField.centerY = titleButton.centerY
        titleField.font = UIFont(name: "PingFangSC-Medium", size: 18)
        titleField.textColor = UIColor(hex: 0x333333)
        titleField.isUserInteractionEnabled = true
        titleField.delegate = self
        titleField.placeholder = "输入话题标题，10字以内（必填）"
        self.view.addSubview(titleField)

        let introButton = UIButton(type: .custom)
        introButton.frame = CGRect(x: 20, y: titleLine.bottom, width: ScreenWidth - 40, height: 96)
        introButton.backgroundColor = UIColor.clear
        introButton.tag = 999
        introButton.addTarget(self, action: #selector(titleButtonClick(sender:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(introButton)

        introtextView = UITextView(frame: CGRect(x: 15, y: titleLine.bottom + 10, width: ScreenWidth - 30, height: 96 - 20))
        introtextView.font = UIFont.systemFont(ofSize: 15)
        introtextView.textColor = UIColor(hex: 0x333333)
        introtextView.delegate = self
        introtextView.showsVerticalScrollIndicator = false
        introtextView.isScrollEnabled = false
        introtextView.isUserInteractionEnabled = true
        self.view.addSubview(introtextView)

        placeHolderButton = UILabel(frame: CGRect(x: 20, y: introtextView.top + 10, width: ScreenWidth - 40, height: 15))
        placeHolderButton.text = "简单介绍一下话题内容"
        placeHolderButton.textColor = UIColor(hex: 0x999999)
        placeHolderButton.font = UIFont.systemFont(ofSize: 15)
        placeHolderButton.isUserInteractionEnabled = true
        placeHolderButton.backgroundColor = UIColor.clear
        self.view.addSubview(placeHolderButton)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(placeHolderTap))
        placeHolderButton.addGestureRecognizer(tap)

        countLabel = UILabel(frame: CGRect(x: ScreenWidth - 15 - 100, y: introLine.bottom + 10, width: 100, height: 11))
        countLabel.textAlignment = .right
        countLabel.font = UIFont.systemFont(ofSize: 10)
        countLabel.text = "0/50"
        countLabel.textColor = UIColor(hex: 0x999999)
        self.view.addSubview(countLabel)

        tipsLabel = UILabel(frame: CGRect(x: 15, y: ScreenHeight - 32 - TSNavigationBarHeight, width: ScreenWidth - 30, height: 12))
        tipsLabel.text = "* 话题创建成功后，标题不可更改"
        tipsLabel.font = UIFont.systemFont(ofSize: 12)
        tipsLabel.textColor = UIColor(hex: 0x999999)
        let attribute = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor(hex: 0xce2a2a)]
        let mutable = NSMutableAttributedString(string: tipsLabel.text ?? "")
        mutable.addAttributes(attribute, range: NSRange(location: 0, length: 1))
        tipsLabel.attributedText = mutable
        self.view.addSubview(tipsLabel)

        /// 最后处理逻辑
        if isEditPush {
            if topicListModel.name != "" {
                if topicListModel.coverImage != nil {
                    faceImageView.kf.setImage(with: URL(string: TSUtil.praseTSNetFileUrl(netFile: topicListModel.coverImage) ?? ""), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                }
                titleField.text = topicListModel.name
                titleField.textColor = UIColor(hex: 0x999999)
                introtextView.text = topicListModel.intro
                if introtextView.text.count != 0 {
                    placeHolderButton.isHidden = true
                }
                countLabel.text = "\(introtextView.text.count)/50"
            }
            titleField.isEnabled = false
        }
        showControl(show: faceImageView.image == nil ? false : true)
    }

    func backItemClick() {
        self.view.endEditing(true)
        if !isEditPush && faceImageView.image == nil && titleField.text?.count == 0 && introtextView.text.count == 0 {
            self.backToFront()
        } else {
            if isEditPush {
                let alert = TSAlertController(title: "提示", message: "确认取消编辑话题？", style: .actionsheet, sheetCancelTitle: "继续")
                alert.addAction(TSAlertAction(title: "放弃编辑", style: .default, handler: { (_) in
                    self.backToFront()
                }))
                present(alert, animated: false, completion: nil)
            } else {
                let alert = TSAlertController(title: "提示", message: "确认取消创建话题？", style: .actionsheet, sheetCancelTitle: "继续")
                alert.addAction(TSAlertAction(title: "放弃创建", style: .default, handler: { (_) in
                    self.backToFront()
                }))
                present(alert, animated: false, completion: nil)
            }
        }
    }

    func nextItemClick() {
        self.nextBtn.isEnabled = false
        /// 话题只有标题是必须的
        /// 如果有封面就先上传封面获取封面id然后再创建话题
        guard let topicTitle = self.titleField.text else {
            self.nextBtn.isEnabled = true
            return
        }
        if isEditPush {
            // 3.发起网络请求
            let alert = TSIndicatorWindowTop(state: .loading, title: "保存中...")
            ///编辑的时候检测到更换了封面就先上传封面再编辑，没有更换封面的时候就直接用 topicListModel 传过来的 封面ID 直接编辑
            if self.faceImageView.image != nil {
                // 更换了图片
                if hasChangeFaceImage {
                    guard let imageData = UIImageJPEGRepresentation(self.faceImageView.image!, 1) else {
                        self.nextBtn.isEnabled = true
                        return
                    }
                    // 压缩图片
                    let uploadImageData = TSUtil.compressImageData(imageData: imageData, maxSizeKB: CreatTopicVC.postImageMaxSizeKb)
                    TSUserNetworkingManager().uploadTopicFace(uploadImageData) { (_ faceNode, _ msg, _ status) in
                        if status && (faceNode != nil) {
                            TSUserNetworkingManager().editTopic(faceNode: faceNode, topicIntro: self.introtextView.text, topicId: self.topicListModel.id) { (_ msg, _ status) in
                                alert.dismiss()
                                let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: msg)
                                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                                // 如果创建圈子成功，返回上一页
                                /// 这里需要发通知给话题详情页下拉刷新数据
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTopicDetailVC"), object: nil)
                                self.backToFront()
                            }
                        } else {
                            alert.dismiss()
                            let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: msg)
                            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                            self.nextBtn.isEnabled = true
                        }
                    }
                } else {
                    // 没有更换图片
                    TSUserNetworkingManager().editTopic(faceNode: nil, topicIntro: self.introtextView.text, topicId: self.topicListModel.id) { (_ msg, _ status) in
                        alert.dismiss()
                        let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: msg)
                        resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                        // 如果创建圈子成功，返回上一页
                        if status {
                            /// 这里需要发通知给话题详情页下拉刷新数据
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTopicDetailVC"), object: nil)
                            self.backToFront()
                        } else {
                            self.nextBtn.isEnabled = true
                        }
                    }
                }
            } else {
                TSUserNetworkingManager().editTopic(faceNode: nil, topicIntro: self.introtextView.text, topicId: topicListModel.id) { (_ msg, _ status) in
                    alert.dismiss()
                    let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: msg)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    // 如果创建圈子成功，返回上一页
                    if status {
                        /// 这里需要发通知给话题详情页下拉刷新数据
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTopicDetailVC"), object: nil)
                        self.backToFront()
                    } else {
                        self.nextBtn.isEnabled = true
                    }
                }
            }
        } else {
            // 3.发起网络请求
            let alert = TSIndicatorWindowTop(state: .loading, title: "创建中...")
            if self.faceImageView.image != nil {
                guard let imageData = UIImageJPEGRepresentation(self.faceImageView.image!, 1) else {
                    self.nextBtn.isEnabled = true
                    return
                }
                // 压缩图片
                let uploadImageData = TSUtil.compressImageData(imageData: imageData, maxSizeKB: CreatTopicVC.postImageMaxSizeKb)
                TSUserNetworkingManager().uploadTopicFace(uploadImageData) { (_ faceNode, _ msg, _ status) in
                    if status && (faceNode != nil) {
                        TSUserNetworkingManager().createTopic(faceNode: faceNode, topicTitle: topicTitle, topicIntro: self.introtextView.text) { (_ topicId, _ msg, _ status, _ needReview) in
                            alert.dismiss()
                            let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: msg)
                            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                            // 如果创建圈子成功，返回上一页
                            if status {
                                if needReview {
                                    self.backToFront()
                                } else {
                                    let topicDetailVC = TopicPostListVC(groupId: topicId!)
                                    self.navigationController?.pushViewController(topicDetailVC, animated: true)
                                }
                            } else {
                                self.nextBtn.isEnabled = true
                            }
                        }
                    } else {
                        alert.dismiss()
                        let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: msg)
                        resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                        self.nextBtn.isEnabled = true
                    }
                }
            } else {
                TSUserNetworkingManager().createTopic(faceNode: nil, topicTitle: topicTitle, topicIntro: self.introtextView.text) { (_ topicId, _ msg, _ status, _ needReview) in
                    alert.dismiss()
                    let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: msg)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    // 如果创建圈子成功，返回上一页
                    if status {
                        if needReview {
                            self.backToFront()
                        } else {
                            let topicDetailVC = TopicPostListVC(groupId: topicId!)
                            self.navigationController?.pushViewController(topicDetailVC, animated: true)
                        }
                    } else {
                        self.nextBtn.isEnabled = true
                    }
                }
            }
        }
    }

    /// 返回之前的页面
    fileprivate func backToFront() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }

    // MARK: - TSCustomAcionSheetDelegate
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if view.tag == 250 {
            switch index {
            case 0:
                self.backToFront()  // 返回之前的界面
            case 1:
                break
            default:
                break
            }
        }
    }

    func titleButtonClick(sender: UIButton) {
        if sender.tag == 666 {
            titleField.becomeFirstResponder()
        } else {
            introtextView.becomeFirstResponder()
        }
    }

    func placeHolderTap() {
        introtextView.becomeFirstResponder()
    }

    /// UITextView输入的通知处理
    @objc private func textViewDidChanged(notification: Notification) -> Void {
        // textView判断
        guard let textView = notification.object as? UITextView else {
            return
        }
        if textView != self.introtextView {
            return
        }
        let text = textView.text
        // 占位处理
        placeHolderButton.isHidden = !(nil == text || text!.isEmpty)
        TSAccountRegex.checkAndUplodTextFieldText(textField: textView, stringCountLimit: 50)
        countLabel.text = "\(textView.text.count)/50"
    }

    /// UITextField输入的通知处理
    @objc private func textFieldDidChanged(notification: Notification) -> Void {
        // textView判断
        guard let textField = notification.object as? UITextField else {
            return
        }
        if textField != self.titleField {
            return
        }
        TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: 10)
        checkTitleFieldStatus()
    }

    // MARK: - 封面图点击事件
    func faceViewTap() {
        self.view.endEditing(true)
        let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
        let personalIdentyAction = TSAlertAction(title: "选择_相册".localized, style: .default, handler: { [weak self] (_) in
            self?.openLibrary()
        })
        let enterpriseIdentyAction = TSAlertAction(title: "选择_相机".localized, style: .default, handler: { [weak self] (_) in
            self?.openCamera()
        })
        alertVC.addAction(personalIdentyAction)
        alertVC.addAction(enterpriseIdentyAction)
        self.present(alertVC, animated: false, completion: nil)
    }

    private func openCamera() {
        let isSuccess = TSSetUserInfoVC.checkCamearPermissions()
        guard isSuccess else {
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if (UIDevice.current.systemVersion as NSString).floatValue >= 7.0 {
            imagePicker.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
        }
        imagePicker.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor

        var tzBarItem: UIBarButtonItem?
        var BarItem: UIBarButtonItem?
        tzBarItem = UIBarButtonItem.appearance(whenContainedInInstancesOf: [TZImagePickerController.self])
        BarItem = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIImagePickerController.self])
        let titleTextAttributes = tzBarItem?.titleTextAttributes(for: .normal)
        BarItem?.setTitleTextAttributes(titleTextAttributes, for: .normal)

        let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = sourceType
            if (UIDevice.current.systemVersion as NSString).floatValue >= 9.0 {
                imagePicker.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            }
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            return
        }
    }

    private func openLibrary() {
        guard let imagePickerVC = TZImagePickerController(maxImagesCount: 1, columnNumber: 4, delegate: self, mainColor: TSColor.main.theme)
            else {
                return
        }
        /// 不设置则直接用TZImagePicker的pod中的图片素材
        /// #图片选择列表页面
        /// item右上角蓝色的选中图片
//            imagePickerVC.selectImage = UIImage(named: "msg_box_choose_now")

        //设置默认为中文，不跟随系统
        imagePickerVC.preferredLanguage = "zh-Hans"
        imagePickerVC.maxImagesCount = 1
        imagePickerVC.isSelectOriginalPhoto = true
        imagePickerVC.allowTakePicture = true
        imagePickerVC.allowPickingVideo = false
        imagePickerVC.allowPickingImage = true
        imagePickerVC.allowPickingGif = true
        imagePickerVC.allowPickingMultipleVideo = true
        imagePickerVC.sortAscendingByModificationDate = false
        imagePickerVC.allowPreview = false
        imagePickerVC.navigationBar.barTintColor = UIColor.white
        var dic = [String: Any]()
        dic[NSForegroundColorAttributeName] = UIColor.black
        imagePickerVC.navigationBar.titleTextAttributes = dic
        present(imagePickerVC, animated: true)
    }

    // MARK: - 系统拍照选择图片回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let infoDict: NSDictionary = info as NSDictionary
        let type: String = infoDict.object(forKey: UIImagePickerControllerMediaType) as! String
        if type == "public.image" {
            let photo: UIImage = infoDict.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
            let photoOrigin: UIImage = photo.fixOrientation()
            if photoOrigin != nil {
                self.faceImageView.image = photoOrigin
                hasChangeFaceImage = true
                showControl(show: true)
            }
        }
    }

    // 图片选择回调
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        if photos.count > 0 {
            if picker != nil {
                picker.dismiss(animated: true) {
                }
            }
            self.faceImageView.image = photos[0]
            hasChangeFaceImage = true
            showControl(show: true)
        } else {
            let resultAlert = TSIndicatorWindowTop(state: .faild, title: "图片选择异常,请重试!")
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
        }
    }

    func showControl(show: Bool) {
        if show {
//            mengcengView.isHidden = false
            cameraIcon.isHidden = false
            cameraLabel.isHidden = false
            tyLabel.isHidden = true
        } else {
//            mengcengView.isHidden = true
            cameraIcon.isHidden = true
            cameraLabel.isHidden = true
            tyLabel.isHidden = false
        }
    }

    // MARK: - TYAttributedLabelDelegate
    func attributedLabel(_ attributedLabel: TYAttributedLabel!, textStorageClicked textStorage: TYTextStorageProtocol!, at point: CGPoint) {
        faceViewTap()
    }

    func checkTitleFieldStatus() {
        if self.titleField.text?.count != 0 {
            nextBtn.isEnabled = true
        } else {
            nextBtn.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CreatTopicVC {
    /// 键盘通知响应
    @objc fileprivate func kbWillShowNotificationProcess(_ notification: Notification) -> Void {
        guard let userInfo = notification.userInfo, let kbFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        self.currentKbH = kbFrame.size.height
        if isTextField {
            let kbH: CGFloat = self.currentKbH
            let bottomH: CGFloat = ScreenHeight - titleButton.bottom - 64.0
            if kbH > bottomH {
                UIView.animate(withDuration: 0.25) {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -(kbH - bottomH) - 20.0)
                }
            }
        }
    }

    @objc fileprivate func kbWillHideNotificationProcess(_ notification: Notification) -> Void {
        self.kbProcessReset()
    }

    @objc fileprivate func fieldBeginEditingNotificationProcess(_ notification: Notification) -> Void {
        let kbH: CGFloat = self.currentKbH
        let bottomH: CGFloat = ScreenHeight - titleButton.bottom - 64.0
        if kbH > bottomH {
            isTextField = false
            UIView.animate(withDuration: 0.25) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -(kbH - bottomH) - 20.0)
            }
        }
        if kbH < 1 {
            isTextField = true
        }
    }
    @objc fileprivate func fieldEndEditingNotificationProcess(_ notification: Notification) -> Void {
        self.kbProcessReset()
    }
    @objc fileprivate func viewBeginEditingNotificationProcess(_ notification: Notification) -> Void {
        isTextField = false
        let kbH: CGFloat = self.currentKbH
        let bottomH: CGFloat = ScreenHeight - self.introtextView.bottom - 64.0
        if kbH > bottomH {
            UIView.animate(withDuration: 0.25) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -(kbH - bottomH) - 20.0)
            }
        }
    }
    @objc fileprivate func viewEndEditingNotificationProcess(_ notification: Notification) -> Void {
        self.kbProcessReset()
    }

    /// 键盘相关的复原
    fileprivate func kbProcessReset() -> Void {
        UIView.animate(withDuration: 0.25) {
            self.view.transform = CGAffineTransform.identity
        }
    }
}
