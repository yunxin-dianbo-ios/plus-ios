//
//  TSReleaseDynamicViewController.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  发布动态界面
// 图片付费的信息绑定思路:
//

import UIKit
import KMPlaceholderTextView
import Photos
import CoreLocation
import Kingfisher
import TZImagePickerController

class TSReleasePulseViewController: TSViewController, UITextViewDelegate, didselectCellDelegate, TSCustomAcionSheetDelegate, UIGestureRecognizerDelegate, TSSettingImgPriceVCDelegate, TZImagePickerControllerDelegate {
    /// 主承载视图
    @IBOutlet weak var mainView: UIView!
    // 滚动视图高度
    @IBOutlet weak var scrollContentSizeHeight: NSLayoutConstraint!
    // 字数Lable 和 父视图的相对位置
    @IBOutlet weak var showLabelWithSuperViewConstraint: NSLayoutConstraint!
    // contentTextView 和 父视图的相对位置
    @IBOutlet weak var contentTextViewWithSuperViewConstraint: NSLayoutConstraint!
    // 字数Label 和 contentTextView相对的位置
    @IBOutlet weak var showLabelWithContentTextViewConstrraint: NSLayoutConstraint!
    // 图片展示视图 和 contentTextView相对的位置
    @IBOutlet weak var collectionWithContentTextViewConstrraint: NSLayoutConstraint!
    // 图片查看器的高度
    @IBOutlet weak var releaseDynamicCollectionViewHeight: NSLayoutConstraint!
    // 发布内容
    @IBOutlet weak var contentTextView: KMPlaceholderTextView!
    @IBOutlet weak var atView: UIView!
    /// 修饰后的发布内容
    var releasePulseContent: String {
        return contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    // 展示图片CollectionView
    @IBOutlet weak var showImageCollectionView: TSReleasePulseCollectionView!
    // 滚动视图
    @IBOutlet weak var mainScrollView: UIScrollView!
    // 展示文本字数
    @IBOutlet weak var showWordsCountLabel: UILabel!
    @IBOutlet weak var switchPayInfoView: TSSwitchPayInfoView!
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var topicViewHeight: NSLayoutConstraint!
    @IBOutlet weak var repostBgView: UIView!
    /// 不同的显示样式需要的高度不同，详细见模型解析处
    @IBOutlet weak var repostBgViewHC: NSLayoutConstraint!
    // cell个数
    let cellCount: CGFloat = 4.0
    // cell行间距
    let spacing: CGFloat = 5.0
    // 最大标题字数
    let maxtitleCount: Int = 30
    // 最大内容字数
    let maxContentCount: Int = 255
    // 显示字数时机
    let showWordsCount: Int = 200
    // contentTextView是否滚动的行数
    let contentTextViewScrollNumberLine = 7
    // 发布按钮（还没判断有无图片时的点击逻辑）
    // 最大图片张叔
    let maxPhotoCount: Int = 9
    var releaseButton = TSTextButton.initWith(putAreaType: .top)
    // 记录collection高度
    var releaseDynamicCollectionViewSourceHeight: CGFloat = 0.0
    /// 选择图片数据对应数据
    var selectedPHAssets: [PHAsset] = []
    /// 支付信息
//    var imagesPayInfo: [TSImgPrice] = [TSImgPrice]()
    // 是否隐藏CollectionView
    var isHiddenshowImageCollectionView = false
    // 是否开启图片支付
    var isOpenImgsPay = false

    var currentKbH: CGFloat = 0

    ///从话题进入的发布页面自带一个不能删除的话题
    var chooseModel: TopicCommonModel?

    /// 话题信息
    var topics: [TopicCommonModel] = []
    /// 转发信息
    var repostModel: TSRepostModel?

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

    init(isHiddenshowImageCollectionView: Bool) {
        super.init(nibName: "TSReleasePulseViewController", bundle: nil)
        self.isHiddenshowImageCollectionView = isHiddenshowImageCollectionView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHideNotificationProcess(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fieldBeginEditingNotificationProcess(_:)), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fieldEndEditingNotificationProcess(_:)), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(topicChooseNotice(notice:)), name: NSNotification.Name(rawValue: "passPublishTopicData"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(topicChooseNotice(notice:)), name: NSNotification.Name(rawValue: "passPublishTopicData"), object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - setUI
    fileprivate func setUI() {
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

        switchPayInfoView.isHidden = !TSAppConfig.share.localInfo.isFeedPay
        /// 限制输入文本框字数
        contentTextView.placeholder = isHiddenshowImageCollectionView ? "占位符_输入要说的话".localized : "占位符_输入要说的话，图文结合更精彩哦".localized
        contentTextView.returnKeyType = .default    // 键盘的return键为换行样式
        contentTextView.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        contentTextView.placeholderColor = TSColor.normal.disabled
        contentTextView.placeholderFont = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        contentTextView.delegate = self
        contentTextView.textAlignment = .left
        showImageCollectionView.didselectCellDelegate = self
        releaseDynamicCollectionViewSourceHeight = (UIScreen.main.bounds.size.width - 40 - spacing * 3) / cellCount + 1
        releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight

        showImageCollectionView.isHidden = isHiddenshowImageCollectionView
        if isHiddenshowImageCollectionView {
            showLabelWithSuperViewConstraint.priority = UILayoutPriorityDefaultLow
            contentTextViewWithSuperViewConstraint.priority = UILayoutPriorityDefaultHigh
        }
        contentTextView.becomeFirstResponder()
        // set btns
        let cancelButton = TSTextButton.initWith(putAreaType: .top)
        cancelButton.setTitle("选择_取消".localized, for: .normal)
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.addTarget(self, action: #selector(tapCancelButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        releaseButton.setTitle("显示_发布".localized, for: .normal)
        releaseButton.addTarget(self, action: #selector(releasePulse), for: .touchUpInside)
        releaseButton.contentHorizontalAlignment = .right
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: releaseButton)
        releaseButton.isEnabled = false
        showImageCollectionView.maxImageCount = maxPhotoCount
        setTopicViewUI(showTopic: true, topicData: topics)
        let atViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapAtView))
        atView.addGestureRecognizer(atViewTap)
        let repostView = TSRepostView(frame: CGRect.zero)
        repostBgView.addSubview(repostView)
        repostView.cardShowType = .postView
        // 有转发内容
        if let model = self.repostModel {
            /// 每一个分享卡片所需要的高度都不一样，所以需要单独设置
            if model.type == .postWord {
                repostBgViewHC.constant = TSRepostViewUX.postUIPostWordCardHeight + 15
            } else if model.type == .postVideo || model.type == .postImage {
                repostBgViewHC.constant = TSRepostViewUX.postUIPostVideoCardHeight + 15
            } else if model.type == .group {
                repostBgViewHC.constant = TSRepostViewUX.postUIGroupCardHeight + 15
            } else if model.type == .groupPost {
                repostBgViewHC.constant = TSRepostViewUX.postUIGroupPostCardHeight + 15
            } else if model.type == .news {
                repostBgViewHC.constant = TSRepostViewUX.postUINewsCardHeight + 15
            } else if model.type == .question {
                repostBgViewHC.constant = TSRepostViewUX.postUIQuestionCardHeight + 15
            } else if model.type == .questionAnswer {
                repostBgViewHC.constant = TSRepostViewUX.postUIQuestionAnswerCardHeight + 15
            }
            self.updateViewConstraints()
            repostView.updateUI(model: model)
            // 隐藏付费选择器
            switchPayInfoView.isHidden = true
            // 增加底部分割线
            let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
            topicBottomline.backgroundColor = TSColor.inconspicuous.disabled
            topicView.addSubview(topicBottomline)
        } else {
           // 普通发布
            repostBgViewHC.constant = 0
            self.updateViewConstraints()
        }
    }

    @IBAction func tapScrollView(_ sender: UITapGestureRecognizer) {
        textViewResignFirstResponder()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        isTapOtherView = true
        if !contentTextView.isFirstResponder && !toolView.isHidden {
            toolView.isHidden = true
        }
        if touch.view == mainScrollView || touch.view == showImageCollectionView {
            return true
        }
        return false
    }

    fileprivate func calculationCollectionViewHeight() {
        switch selectedPHAssets.count {
        case 0...3:
            releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight
        case 4...7:
            releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 2 + spacing
        case 8...9:
            releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 3 + 2 * spacing
        default:
            break
        }
    }

    /// 发布按钮是否可点击
    fileprivate func setReleaseButtonIsEnabled() {
        if !releasePulseContent.isEmpty || !selectedPHAssets.isEmpty {
            releaseButton.isEnabled = true
        } else {
            releaseButton.isEnabled = false
        }
    }

    /// 设置视图相对的位置
    ///
    /// - Parameter change: 还要看showLabel的心情
    fileprivate func setViewsConstraint(change: Bool) {
        /**
         注：修改此处代码时，请先参考原始代码，再参考xib的约束绑定，理解约束的具体内容 。
            这里将原始的约束优先级调整变成约束数值调整，是为了解决文字发布状态时：字数达到指定要求显示字数统计时，收费栏下移的bug。
            关于为何将数值调整为65何35，是通过猜测调整的，最初是60与40，至于为啥😯，猜的呗😁
         */
        switch change {
        case true:
            if showImageCollectionView.isHidden {
                self.showLabelWithSuperViewConstraint.constant = 65
                self.contentTextViewWithSuperViewConstraint.constant = 35
            } else {
                showLabelWithContentTextViewConstrraint.priority = UILayoutPriorityDefaultHigh
                collectionWithContentTextViewConstrraint.priority = UILayoutPriorityDefaultLow
            }
        default:
            if showImageCollectionView.isHidden {
                self.showLabelWithSuperViewConstraint.constant = 10
                self.contentTextViewWithSuperViewConstraint.constant = 10
            } else {
                showLabelWithContentTextViewConstrraint.priority = UILayoutPriorityDefaultLow
                collectionWithContentTextViewConstrraint.priority = UILayoutPriorityDefaultHigh
            }
        }
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            DispatchQueue.main.async {
                if self.mainView.frame.size.height > self.mainScrollView.bounds.height {
                } else {
                    self.scrollContentSizeHeight.constant = self.mainScrollView.bounds.size.height - self.mainView.bounds.size.height + 1
                }
                self.updateViewConstraints()
            }
        })
    }

    // MARK: - tapButton
    @objc fileprivate func tapCancelButton() {
        textViewResignFirstResponder()
        if !releasePulseContent.isEmpty || !selectedPHAssets.isEmpty {
            let actionsheetView = TSCustomActionsheetView(titles: ["提示信息_你还有没发布的内容,是否放弃发布?".localized, "选择_确定".localized])
            actionsheetView.delegate = self
            actionsheetView.tag = 2
            actionsheetView.notClickIndexs = [0]
            actionsheetView.show()
        } else {
            let _ = self.navigationController?.dismiss(animated: true, completion: {})
        }
    }

    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if view.tag == 2 {
            let _ = self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - tapSend
    fileprivate  func textViewResignFirstResponder() {
        contentTextView.resignFirstResponder()
        packUpKey()
        switchPayInfoView.priceTextFieldResignFirstResponder()
    }

    fileprivate  func setShowImages() {
        self.showImageCollectionView.imageDatas.removeAll()
        var payinfos: [TSImgPrice] = []
        for item in selectedPHAssets {
            // 判断是不是GIF，并通过扩展添加到UIImage的MIMEType属性
            // 方便collection内的gif表示展示
            var image: UIImage!
            PhotosDataManager.cover(assets: [item], disPlayWidth: 150, complete: { (imgs) in
                image = imgs[0]
            })
            // 上述方法获取不到MIMEType，通过以下方式单独获取
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            manager.requestImageData(for: item, options: option) { (imageData, type, orientation, info) in
                image.TSImageMIMEType = type!
            }
            self.showImageCollectionView.imageDatas.append(image)
            payinfos.append(item.payInfo)
        }
        self.showImageCollectionView.payInfoArray = payinfos
        let pi: UIImage? = selectedPHAssets.count < maxPhotoCount ? UIImage(named: "IMG_edit_photo_frame") : nil
        if let pi = pi {
            self.showImageCollectionView.imageDatas.append(pi)
            self.showImageCollectionView.payInfoArray.append(nil)
        }
        self.showImageCollectionView.shoudSetPayInfo = self.isOpenImgsPay
        self.showImageCollectionView.reloadData()
        self.calculationCollectionViewHeight()
    }

    // MARK: - 点击了相册按钮
    func didSelectCell(index: Int) {
        textViewResignFirstResponder()
        if isOpenImgsPay == false {
            clearImgPayInfo()
        }
        if index + 1 > selectedPHAssets.count { // 点击了相册选择器,进入图片查看器
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
            imagePickerVC.maxImagesCount = maxPhotoCount
            imagePickerVC.isSelectOriginalPhoto = true
            imagePickerVC.allowTakePicture = true
            imagePickerVC.allowPickingVideo = false
            imagePickerVC.allowPickingImage = true
            imagePickerVC.allowPickingGif = true
            imagePickerVC.allowPickingMultipleVideo = true
            imagePickerVC.sortAscendingByModificationDate = false
            imagePickerVC.selectedAssets = NSMutableArray(array: selectedPHAssets)
            imagePickerVC.navigationBar.barTintColor = UIColor.white
            var dic = [String: Any]()
            dic[NSForegroundColorAttributeName] = UIColor.black
            imagePickerVC.navigationBar.titleTextAttributes = dic
            present(imagePickerVC, animated: true)
        } else {
            if self.isOpenImgsPay == true {
                openImgsPayEnterPreViewVC(index: index)
            } else {
                closeImgsPayEnterPreViewVC(index: index)
            }
        }
    }

    func didSelectedPayInfoBtn(btn: UIButton) {
        let index = btn.tag
        let payInfo = selectedPHAssets[index].payInfo
        pushToPaySetting(imagePrice: payInfo, index: index)
    }

    func closeImgsPayEnterPreViewVC(index: Int) {
        var imagesPayInfo: [TSImgPrice] = []
        for item in selectedPHAssets {
            imagesPayInfo.append(item.payInfo)
        }
        let previewController = CustomPHPreViewVC(currentIndex: index, assets: selectedPHAssets, isShowSettingPay: isOpenImgsPay, payInfo: imagesPayInfo)
        previewController.setFinish { [unowned self] in
            self.selectedPHAssets = previewController.selectedAssets
            self.setShowImages()
            let _ = self.navigationController?.popViewController(animated: true)
        }
        previewController.setDismiss {
            // 根据旧的支付信息显示旧的支付配置和图片
        }
        navigationController?.pushViewController(previewController, animated: true)
    }

    func openImgsPayEnterPreViewVC(index: Int) {
        var imagesPayInfo: [TSImgPrice] = []
        for item in selectedPHAssets {
            imagesPayInfo.append(item.payInfo)
        }
        let previewController = CustomPHPreViewVC(currentIndex: index, assets: selectedPHAssets, isShowSettingPay: isOpenImgsPay, payInfo: imagesPayInfo)
        previewController.setFinish { [unowned self] in
            self.selectedPHAssets = previewController.selectedAssets
            for (index, item) in previewController.payInfo.enumerated() {
                let imageAsset = self.selectedPHAssets[index]
                imageAsset.payInfo = item
            }
            self.showImageCollectionView.payInfoArray = imagesPayInfo
            // 有图 显示图
            if self.selectedPHAssets.isEmpty == false {
                self.setShowImages()
            } else {
                // 没图 关闭支付模式
                self.isOpenImgsPay = false
                self.switchPayInfoView.paySwitch.isOn = false
                self.selectedPHAssets = []
                self.setShowImages()
            }
            let _ = self.navigationController?.popViewController(animated: true)
        }
        previewController.setDismiss {
            // 根据旧的支付信息显示旧的支付配置和图片
        }
        navigationController?.pushViewController(previewController, animated: true)
    }

    // MARK: - packageImagesPayInfo
    fileprivate func imagesPayInfoConvert(shouldPay: Bool) {
        var payInfoArray = [TSImgPrice?]()
        for _ in selectedPHAssets {
            if shouldPay == true {
                payInfoArray.append(TSImgPrice(paymentType: .not, sellingPrice: 0))
            } else {
                payInfoArray.append(nil)
            }
        }
        let pi: UIImage? = selectedPHAssets.count < maxPhotoCount ? UIImage(named: "IMG_edit_photo_frame") : nil
        if pi != nil {
            payInfoArray.append(nil)
        }
        self.showImageCollectionView.payInfoArray = payInfoArray
        self.showImageCollectionView.shoudSetPayInfo = self.isOpenImgsPay
    }

    // MARK: - 图片支付信息相关
    func clearImgPayInfo() {
        for item in selectedPHAssets {
            let imgPrice = TSImgPrice(paymentType: .not, sellingPrice: 0)
            item.payInfo = imgPrice
        }
    }
    // MARK: - 设置了付费信息
    func setsPrice(price: TSImgPrice, index: Int) {
        let imageAssets = selectedPHAssets[index]
        imageAssets.payInfo = price
        self.setShowImages()
    }
    // MARK: - TZImagePickerControllerDelegate
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        self.selectedPHAssets = assets as! [PHAsset]
        self.setShowImages()
    }
    func emojiBtnClick() {
        smileButton.isSelected = !smileButton.isSelected
        if smileButton.isSelected {
            isTapOtherView = false
            contentTextView.resignFirstResponder()
        } else {
            contentTextView.becomeFirstResponder()
        }
    }
    func packUpKey() {
        smileButton.isSelected = false
        contentTextView.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.toolView.isHidden = true
        }
    }
}

// MARK: - TSSwitchPayInfoViewDelegate
extension TSReleasePulseViewController: TSSwitchPayInfoViewDelegate {
    func paySwitchValueChanged(_ paySwitch: UISwitch) {
        if isHiddenshowImageCollectionView {
            if paySwitch.isOn {
                view.endEditing(true)
            }
            return
        }
        isOpenImgsPay = paySwitch.isOn
        if paySwitch.isOn {
            imagesPayInfoConvert(shouldPay: true)
            // 切换到支付模式时，设置支付为空
            clearImgPayInfo()
        } else {
            imagesPayInfoConvert(shouldPay: false)
        }
        setShowImages()
    }
    // 点击了收费配置按钮
    func pushToPaySetting(imagePrice: TSImgPrice, index: Int) {
        // 读取旧的支付信息，然后传递给支付页面
        let settingPriceVC = TSSettimgPriceViewController(imagePrice: imagePrice)
        settingPriceVC.delegate = self
        settingPriceVC.enterIndex = index
        self.navigationController?.pushViewController(settingPriceVC, animated: true)
    }
}

// MARK: - Release btn tap
extension TSReleasePulseViewController {
    @objc fileprivate func releasePulse() {
        /// 需要全文匹配at
        // let pulseContent = TSUtil.replaceEditAtString(inputStr: self.releasePulseContent)
        let pulseContent = self.releasePulseContent
        textViewResignFirstResponder()
        if switchPayInfoView.paySwitchIsOn && selectedPHAssets.isEmpty { // 文字付费
            if switchPayInfoView.payPrice > 0 {
                if pulseContent.count <= TSAppConfig.share.localInfo.feedLimit {
                    let str = "注：超过" + "\(TSAppConfig.share.localInfo.feedLimit)" + "字部分内容收费"
                    let actionsheetView = TSCustomActionsheetView(titles: [str])
                    actionsheetView.delegate = self
                    actionsheetView.tag = 99
                    actionsheetView.notClickIndexs = [0]
                    actionsheetView.show()
                    return
                }
                releaseButton.isEnabled = false
                releasePricePulse()
                return
            }
            // 提示输入支付金额
            let actionsheetView = TSCustomActionsheetView(titles: ["设置收费金额"])
            actionsheetView.delegate = self
            actionsheetView.tag = 99
            actionsheetView.notClickIndexs = [0]
            actionsheetView.show()
            return
        }
        if switchPayInfoView.paySwitchIsOn && !selectedPHAssets.isEmpty { // 图片付费
            var setPayPrice = false
            for item in selectedPHAssets {
                let payInfo = item.payInfo
                if payInfo.paymentType != .not {
                    setPayPrice = true
                }
            }
            if setPayPrice == true {
                releaseButton.isEnabled = false
                releaseImgPricePulse()
                return
            }
            // 提示输入支付金额
            let actionsheetView = TSCustomActionsheetView(titles: ["应配置至少一张图片收费"])
            actionsheetView.delegate = self
            actionsheetView.tag = 99
            actionsheetView.notClickIndexs = [0]
            actionsheetView.show()
            return
        }
        releaseButton.isEnabled = false
        let postPHAssets = selectedPHAssets
        let postPulseContent = pulseContent

        let top = TSIndicatorWindowTop(state: .loading, title: "处理中...")
        top.show()
        releaseStart(phAssets: postPHAssets, feedContent: postPulseContent, topicsInfo: topics, repostModel: self.repostModel) { [weak self] (obj) in
            top.dismiss()
            let feedIdentity = (obj).feedIdentity
            let moment = obj
            let _ = self?.navigationController?.dismiss(animated: true, completion: {
                /// 判断到底是话题进入的发布页面还是其他情况进入的发布页面
                if self?.chooseModel != nil {
                    NotificationCenter.default.post(name: NSNotification.Name.Moment.TopicAddNew, object: nil, userInfo: ["newFeedId": feedIdentity])
                } else if let repostModel = self?.repostModel, repostModel.id > 0 {
                    NotificationCenter.default.post(name: NSNotification.Name.Moment.AddNew, object: nil, userInfo: ["newFeedId": feedIdentity, "isRepost": true])
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name.Moment.AddNew, object: nil, userInfo: ["newFeedId": feedIdentity])
                }
                TSMomentTaskQueue().releasePulseImages(momentListObject: moment, isTopicPublish: self?.chooseModel != nil ? true : false)
            })
        }
    }

    @objc fileprivate func releasePricePulse() {
        let postPHAssets = selectedPHAssets
        let postPulseContent = TSUtil.replaceEditAtString(inputStr: releasePulseContent)
        let postPayPrice = switchPayInfoView.payPrice
        let top = TSIndicatorWindowTop(state: .loading, title: "处理中...")
        top.show()
        releaseStart(phAssets: postPHAssets, feedContent: postPulseContent, textPrice: postPayPrice, topicsInfo: topics) { [weak self] (obj) in
            top.dismiss()
            let feedIdentity = (obj).feedIdentity
            let moment = obj
            let _ = self?.navigationController?.dismiss(animated: true, completion: {
                /// 判断到底是话题进入的发布页面还是其他情况进入的发布页面
                if self?.chooseModel != nil {
                    NotificationCenter.default.post(name: NSNotification.Name.Moment.TopicAddNew, object: nil, userInfo: ["newFeedId": feedIdentity])
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name.Moment.AddNew, object: nil, userInfo: ["newFeedId": feedIdentity])
                }
                TSMomentTaskQueue().releasePulseImages(momentListObject: moment, isTopicPublish: self?.chooseModel != nil ? true : false)
            })
        }
    }

    func releaseImgPricePulse() {
        // 发布时移除掉最后一个多余的为了让UI显示用的支付配置
        var imagesPayInfo: [TSImgPrice] = []
        for item in selectedPHAssets {
            imagesPayInfo.append(item.payInfo)
        }
        let postPHAssets = selectedPHAssets
        let postPulseContent = TSUtil.replaceEditAtString(inputStr: releasePulseContent)
        let postPayPrice = imagesPayInfo

        let top = TSIndicatorWindowTop(state: .loading, title: "处理中...")
        top.show()
        releaseStart(phAssets: postPHAssets, feedContent: postPulseContent, imagePrice: postPayPrice, topicsInfo: topics) { [weak self] (obj) in
            top.dismiss()
            let feedIdentity = (obj).feedIdentity
            let moment = obj
            let _ = self?.navigationController?.dismiss(animated: true, completion: {
                /// 判断到底是话题进入的发布页面还是其他情况进入的发布页面
                if self?.chooseModel != nil {
                    NotificationCenter.default.post(name: NSNotification.Name.Moment.TopicAddNew, object: nil, userInfo: ["newFeedId": feedIdentity])
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name.Moment.AddNew, object: nil, userInfo: ["newFeedId": feedIdentity])
                }
                TSMomentTaskQueue().releasePulseImages(momentListObject: moment, isTopicPublish: self?.chooseModel != nil ? true : false)
            })
        }
    }
}

// MARK: - TextViewDelegate
extension TSReleasePulseViewController {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > maxContentCount {
            TSAccountRegex.checkAndUplodTextFieldText(textField: textView, stringCountLimit: maxContentCount)
        }
        setReleaseButtonIsEnabled()
        TSReleasePulseTool.setShowWordsCountLabelContent(textView: textView, showWordsCountLabel: showWordsCountLabel, showWordsCount: showWordsCount, maxContentCount: maxContentCount)
        setViewsConstraint(change: textView.text.count >= showWordsCount)
        // At
        let selectedRange = textView.markedTextRange
        if selectedRange == nil {
            let range = textView.selectedRange
            let attString = NSMutableAttributedString(string: textView.text)
            attString.addAttributes([NSForegroundColorAttributeName: UIColor.black], range: NSRange(location: 0, length: attString.length))
            attString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)], range:  NSRange(location: 0, length: attString.length))
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
}

// MARK: - Lifecycle
extension TSReleasePulseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        // 初始化时创建配置信息都为空
        imagesPayInfoConvert(shouldPay: false)
        if !selectedPHAssets.isEmpty {
            setShowImages()
        }
        switchPayInfoView.delegate = self
        switchPayInfoView.isHiddenMoreInfo = !isHiddenshowImageCollectionView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "发布动态"
        setReleaseButtonIsEnabled()
        if mainView.frame.size.height > mainScrollView.bounds.height {
        } else {
            scrollContentSizeHeight.constant = mainScrollView.bounds.size.height - mainView.bounds.size.height + 1
        }
        self.updateViewConstraints()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension TSReleasePulseViewController {
    func releaseStart(phAssets: [PHAsset], feedContent: String, textPrice: Int? = nil, imagePrice: [TSImgPrice]? = nil, topicsInfo: [TopicCommonModel]? = [], repostModel: TSRepostModel? = nil, complete: @escaping((_ momentListObj: TSMomentListObject) -> Void)) {
        guard phAssets.isEmpty == false else {
            /// 转发只能发纯文本
            let momentListObject = TSDatabaseManager().moment.save(feedID: nil, feedContent: feedContent, feedTitle: nil, repostModel: repostModel, coordinate: nil, imageCacheKeys: [], imageSizes: [], imageMimeTypes: [], userId: TSCurrentUserInfo.share.userInfo!.userIdentity, nsDate: NSDate(), textPrice: textPrice, imagePrice: imagePrice, topicsInfo: topicsInfo)
            momentListObject.sendState = 0 ///< 发送中
            TSDatabaseManager().moment.save(momentRelease: momentListObject)
            complete(momentListObject)
            return
        }
        DispatchQueue.global(qos: .background).async {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var imageCacheKeys: [String] = []
            var imageSizes: [CGSize] = []
            var imageMimeType: [String] = []
            option.isSynchronous = true
            for asset in phAssets {
                let resources = PHAssetResource.assetResources(for: asset)
                let cacheKey = resources[0].originalFilename + "\(TSCurrentUserInfo.share.createResourceID())"
                imageCacheKeys.append(cacheKey)
                imageSizes.append(CGSize(width: asset.pixelWidth, height: asset.pixelHeight))

                manager.requestImageData(for: asset, options: option) { (imageData, type, orientation, info) in
                    if type == kUTTypeGIF as String, let imageData = imageData, let image = DefaultImageProcessor.default.process(item: .data(imageData), options: []) {
                        imageMimeType.append("image/gif")
                        print("存储时imageData: \(imageData.count)")
                        ImageCache.default.store(image, original: imageData, forKey: cacheKey, toDisk: true, completionHandler: nil)
                    } else if let data = imageData, let image = UIImage(data: data) {
                        imageMimeType.append("image/jpeg")
                        let sendImage = image.fixOrientation()
                        ImageCache.default.store(sendImage, original: data, forKey: cacheKey, toDisk: true)
                    }
                }
            }

            DispatchQueue.main.async {
                // 后续任务
                let momentListObject = TSDatabaseManager().moment.save(feedID: nil, feedContent: feedContent, feedTitle: nil, coordinate: nil, imageCacheKeys: imageCacheKeys, imageSizes: imageSizes, imageMimeTypes: imageMimeType, userId: TSCurrentUserInfo.share.userInfo!.userIdentity, nsDate: NSDate(), textPrice: textPrice, imagePrice: imagePrice, topicsInfo: topicsInfo)
                momentListObject.sendState = 0
                TSDatabaseManager().moment.save(momentRelease: momentListObject)
                complete(momentListObject)
            }
        }
    }
}

// MARK: - Notification

extension TSReleasePulseViewController {
    /// 键盘通知响应
    @objc fileprivate func kbWillShowNotificationProcess(_ notification: Notification) -> Void {
        guard let userInfo = notification.userInfo, let kbFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        self.currentKbH = kbFrame.size.height
        if isPriceTextFiledTap {
            self.toolView.isHidden = true
        } else {
            self.toolView.isHidden = false
            self.smileButton.isSelected = false
            self.toolView.top = kbFrame.origin.y - (TSBottomSafeAreaHeight + 41 + 64.0)
        }
    }
    @objc fileprivate func kbWillHideNotificationProcess(_ notification: Notification) -> Void {
        self.kbProcessReset()
        self.toolView.top = ScreenHeight - toolHeight - 64.0 - TSBottomSafeAreaHeight
        self.smileButton.isSelected = true
        self.toolView.isHidden = isTapOtherView
    }

    @objc fileprivate func fieldBeginEditingNotificationProcess(_ notification: Notification) -> Void {
        isPriceTextFiledTap = true
        if !self.switchPayInfoView.paySwitch.isOn || !self.switchPayInfoView.priceTextField.isFirstResponder {
            return
        }
        let kbH: CGFloat = self.currentKbH
        let bottomH: CGFloat = ScreenHeight - self.mainView.bounds.size.height - 64.0
        if kbH > bottomH {
            UIView.animate(withDuration: 0.25) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -(kbH - bottomH) - 20.0)
            }
        }
    }
    @objc fileprivate func fieldEndEditingNotificationProcess(_ notification: Notification) -> Void {
        isPriceTextFiledTap = false
        self.kbProcessReset()
    }

    /// 键盘相关的复原
    fileprivate func kbProcessReset() -> Void {
        UIView.animate(withDuration: 0.25) {
            self.view.transform = CGAffineTransform.identity
        }
    }

}

// MARK: - 话题板块儿
extension TSReleasePulseViewController {
    /// 布局话题板块儿
    func setTopicViewUI(showTopic: Bool, topicData: [TopicCommonModel]) {
        topicView.removeAllSubViews()
        if showTopic {
            let topLine = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 0.5))
            topLine.backgroundColor = TSColor.inconspicuous.disabled
            topicView.addSubview(topLine)

            if topicData.isEmpty {
                let addTopicLabel = UILabel(frame: CGRect(x: 25, y: 0.5, width: 100, height: 49))
                addTopicLabel.text = "添加话题"
                addTopicLabel.textColor = UIColor(hex: 0x333333)
                addTopicLabel.font = UIFont.systemFont(ofSize: 15)
                topicView.addSubview(addTopicLabel)

                let rightIcon = UIImageView(frame: CGRect(x: ScreenWidth - 15 - 10, y: 0, width: 10, height: 20))
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
            }
        } else {
            topicViewHeight.constant = 0
            topicView.updateConstraints()
        }
    }

// MARK: - 搜索话题页面选择话题之后发通知处理话题板块儿
    func topicChooseNotice(notice: Notification) {
        let dict: NSDictionary = notice.userInfo! as NSDictionary
        let model: TopicListModel = dict["topic"] as! TopicListModel
        let changeModel: TopicCommonModel = TopicCommonModel(topicListModel: model)
        /// 先检测已选的话题里面是不是已经有了当前选择的那个话题，如果有，不作处理（不添加到 topics数组里面），如果没有，直接添加进去
        var hasTopic = false
        if !topics.isEmpty {
            for (_, item) in topics.enumerated() {
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

// MARK: - 话题板块儿选择话题跳转到搜索话题页面
    func jumpToTopicSearchVC() {
        let searchVC = TopicSearchVC.vc()
        searchVC.jumpType = "publish"
        navigationController?.pushViewController(searchVC, animated: true)
    }

// MARK: - 话题板块儿删除话题按钮点击事件
    func deleteTopic(tap: UIGestureRecognizer) {
        if !topics.isEmpty {
            topics.remove(at: (tap.view?.tag)! - 999)
            setTopicViewUI(showTopic: true, topicData: topics)
        }
    }

// MARK: - 话题板块儿点击话题按钮删除话题
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

// MARK: - 话题板块儿获取当前已选择的话题 id 然后组装成一个 id 数组（用于发布接口传值）
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
extension TSReleasePulseViewController {
    /// 点击了atView
    func didTapAtView() {
        self.pushAtSelectedList()
    }
    /// 跳转到可选at人的列表
    func pushAtSelectedList() {
        let atselectedListVC = TSAtSelectListVC()
        atselectedListVC.selectedBlock = { (userInfo) in
            /// 先移除光标所在前一个at
            self.contentTextView = TSCommonTool.atMeTextViewEdit(self.contentTextView) as! KMPlaceholderTextView!
            let spStr = String(data: ("\u{00ad}".data(using: String.Encoding.unicode))!, encoding: String.Encoding.unicode)
            let insertStr = spStr! + "@" + userInfo.name + spStr! + " "
            if self.contentTextView.text.count + insertStr.count > self.maxContentCount {
            } else {
                self.contentTextView.insertText(insertStr)
            }
        }
        self.navigationController?.pushViewController(atselectedListVC, animated: true)
    }
}

extension TSReleasePulseViewController: TSSystemEmojiSelectorViewDelegate {
    func emojiViewDidSelected(emoji: String) {
        self.contentTextView.insertText(emoji)
        self.contentTextView.scrollRangeToVisible(self.contentTextView.selectedRange)
    }
}
