//
//  TSSetUserInfoVC.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/1/19.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  修改个人资料

import UIKit
import KMPlaceholderTextView
import Photos
import IQKeyboardManagerSwift
import CoreGraphics
import Kingfisher
import TZImagePickerController

protocol SendSuccessImageDelegate: NSObjectProtocol {
    /// 上传成功后的头像返回到上个界面
    func sendImageWithTemplate(image: UIImage)
}

class TSSetUserInfoVC: TSViewController, UITextViewDelegate, UITextFieldDelegate, TSCustomAcionSheetDelegate, UIScrollViewDelegate, TSUserInfoLabelDelegate, TZImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// 滚动高度的设置
    @IBOutlet weak var scrollContentSizeHeight: NSLayoutConstraint!
    /// 当前偏移量
    private var currentOffset: CGFloat = 0
    /// 最大简介字数
    private  let textViewMaximumWordLimit: Int = 50
    /// 显示的字数 最大的2/3向下取整
    private let textFiledMaximumWordLimit: Int = 33
    // 图片数据
    private var imageId: Int = 0
    // 昵称
    private var nickName: String?
    // 个人简介
    private var intro: String?
    // 获取用户信息
    public var userModel: TSUserInfoModel?
    /// 滚动视图
    @IBOutlet weak var mainScrollView: UIScrollView!
    // 头像
    @IBOutlet weak var buttonForAvatar: AvatarView!
    // 昵称
    @IBOutlet weak var nicknameTextField: TSAccountTextField!
    // 个人简介
    @IBOutlet weak var personalProfileTextView: KMPlaceholderTextView!
    // 个人信息高度
    @IBOutlet weak var personalpProfileTextViewHeight: NSLayoutConstraint!
    // 当前字数
    @IBOutlet weak var currentTextNumberLabel: UILabel!
    // 性别
    @IBOutlet weak var sexTextField: UITextField!
    // 城市
    @IBOutlet weak var cityTextField: UITextField!
    /// 个人简介和计数label的相对距离约束
    @IBOutlet weak var personalProfileWithCountLabelOfTop: NSLayoutConstraint!
    /// 个人简介和父视图的底部约束
    @IBOutlet weak var personalpProfileWithSuperViewOfBottom: NSLayoutConstraint!

    /// 展示视图
    @IBOutlet weak var contentView: UIView!
    /// 代理
    weak var delegate: SendSuccessImageDelegate?
    /// 上传的头像
    var templateImage: UIImage?

    @IBOutlet weak var userLabelBGView: UIView!

    @IBOutlet weak var userLabelBGViewHight: NSLayoutConstraint!
    @IBOutlet weak var userLabelBGviewArrowSmallGrey: UIImageView!

    weak var userInfoLabelCollectionView: TSUserInfoLabel!
    weak var tagBgView: UIView!

    /// 区域选择返回值带空格如下
    /// - "中国 四川 成都"
    var locationStr: String = ""
    /// 昵称最大字符长度
    fileprivate let nicknameMaxCount = 24
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        // 展示当前用户的信息
        self.userModel = TSCurrentUserInfo.share.userInfo?.convert()
        self.setShowData()
        self.setRightButton(title: "显示_完成".localized, img: nil)
        self.rightButtonEnable(enable: false)
        self.currentTextNumberLabel.textColor = UIColor.gray
    }

    /// 获取性别
    ///
    /// - Parameter type: 参数
    /// - Returns: 字符串
    func setSexType(type: Int) -> String {
        switch type {
        case 1:
            return "男"
        case 2:
            return "女"
        default:
            return "保密"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setRightButton(title: "显示_完成".localized, img: nil)
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().enable = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollContentSizeHeight.constant = mainScrollView.bounds.size.height - contentView.bounds.size.height - 79
        // 增加检测键盘输入状态的通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.textFiledDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        TSUserLabelNetworkManager().getAuthUserTags(complete: { (models) in
            guard models != nil else {
                return
            }
            var data: Array<String> = []
            for model in models! {
                data.append(model.tagName)
            }
//            self.userInfoLabelCollectionView.setData(data: data)
            self.updataTagUI(data: data)
            guard data.isEmpty else {
                return
            }
            self.userLabelBGViewHight.constant = 50
        })
    }

    func updataTagUI(data: Array<String>) {
        self.tagBgView?.removeAllSubViews()
        var XX: CGFloat = 0
        var YY: CGFloat = 0
        let labelHeight: CGFloat = 24.0
        let inSpace: CGFloat = 10
        let outSpace: CGFloat = 5
        let maxWidth: CGFloat = self.userLabelBGView.width
        var tagBgViewHeight: CGFloat = 0
        if !data.isEmpty {
            for (index, item) in data.enumerated() {
                var labelWidth = item.sizeOfString(usingFont: UIFont.systemFont(ofSize: 12)).width
                labelWidth = labelWidth + inSpace * 2
                if labelWidth > maxWidth {
                    labelWidth = maxWidth
                }
                let tagLabel: UILabel = UILabel()
                tagLabel.frame = CGRect(x: XX, y: YY, width: labelWidth, height: labelHeight)
                XX = tagLabel.right + outSpace
                if tagLabel.right > maxWidth {
                    XX = 0
                    YY = tagLabel.bottom + outSpace
                    tagLabel.frame = CGRect(x: XX, y: YY, width: labelWidth, height: labelHeight)
                    XX = tagLabel.right + outSpace
                }
                tagLabel.backgroundColor = UIColor(hex: 0xf4f5f5)
                tagLabel.textColor = UIColor(hex: 0x666666)
                tagLabel.layer.cornerRadius = 2
                tagLabel.text = item
                tagLabel.font = UIFont.systemFont(ofSize: 12)
                tagLabel.textAlignment = .center
                self.tagBgView?.addSubview(tagLabel)
                if index == (data.count - 1) {
                    tagBgViewHeight = tagLabel.bottom
                }
            }
        } else {
            let noTaglabel = UILabel(frame: CGRect(x: 12, y: 0, width: maxWidth, height: 50 - 13 - 16))
            noTaglabel.text = "标题_选择标签".localized
            noTaglabel.textColor = TSColor.normal.disabled
            noTaglabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
            tagBgViewHeight = noTaglabel.height
            self.tagBgView.addSubview(noTaglabel)
        }
        self.tagBgView?.frame = CGRect(x: 0, y: 13, width: maxWidth, height: tagBgViewHeight)
        if data.isEmpty {
            self.userLabelBGViewHight.constant = 50
        } else {
            self.userLabelBGViewHight.constant = tagBgViewHeight + 13 + 16
        }
        self.userLabelBGView.updateConstraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = false
        useResignFirstResponder()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    // MARK: - Custom user interface
    private func setUI() {
        self.title = "显示_个人资料".localized
        buttonForAvatar.showBoardLine = false
        personalProfileTextView.placeholder = "占位符_编辑简介".localized
        personalProfileTextView.placeholderColor = TSColor.normal.disabled
        personalProfileTextView.layoutManager.allowsNonContiguousLayout = false
        nicknameTextField.textColor = TSColor.normal.blackTitle
        sexTextField.textColor = TSColor.normal.blackTitle
        cityTextField.textColor = TSColor.normal.blackTitle
        nicknameTextField.delegate = self
        personalProfileTextView.textColor = TSColor.normal.blackTitle
        nicknameTextField.placeholder = "占位符_请输入用户名".localized
        sexTextField.placeholder = "占位符_选择性别".localized
        cityTextField.placeholder = "占位符_选择居住地".localized
        self.userLabelBGviewArrowSmallGrey.snp.makeConstraints { (make) in
            make.right.equalTo(self.userLabelBGView.snp.right).offset(-12)
            make.centerY.equalTo(self.userLabelBGView)
        }
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let userInfoLabelCollectionView = TSUserInfoLabel(frame: CGRect.zero, collectionViewLayout: layout)
        userInfoLabelCollectionView.TSUserInfoLabelDelegate = self
        self.userInfoLabelCollectionView = userInfoLabelCollectionView
//        self.userLabelBGView.addSubview(userInfoLabelCollectionView)
//        userInfoLabelCollectionView.snp.makeConstraints { (make) in
//            make.top.equalTo(self.userLabelBGView).offset(10)
//            make.left.equalTo(self.userLabelBGView)
//            make.bottom.equalTo(self.userLabelBGView).offset(1)
//            make.right.equalTo(self.userLabelBGView).offset(-22)
//        }
        let tagBgView = UIView()
        self.tagBgView = tagBgView
        self.userLabelBGView.addSubview(self.tagBgView)
        tagBgView.snp.makeConstraints { (make) in
            make.top.equalTo(self.userLabelBGView).offset(13)
            make.left.equalTo(self.userLabelBGView)
            make.bottom.equalTo(self.userLabelBGView).offset(16)
            make.right.equalTo(self.userLabelBGView).offset(-22)
        }
        let line = UIView()
        line.backgroundColor = TSColor.inconspicuous.disabled
        self.userLabelBGView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.userLabelBGView).offset(-0.5)
            make.left.right.equalTo(self.userLabelBGView)
            make.height.equalTo(0.5)
        }
        let userLabelBtn = UIButton(type: .system)
        userLabelBtn.setTitle(nil, for: .normal)
        userLabelBtn.backgroundColor = UIColor.clear
        userLabelBtn.addTarget(self, action: #selector(toSettingUserLabelVC), for: .touchUpInside)
        self.userLabelBGView.addSubview(userLabelBtn)
        userLabelBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self.userLabelBGView).inset(UIEdgeInsets.zero)
        }
    }

    /// 设置数据
    func setShowData() {
        guard let userModel = self.userModel else {
            return
        }
        buttonForAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: userModel.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: userModel.avatar)
        avatarInfo.verifiedIcon = userModel.verified?.icon ?? ""
        avatarInfo.verifiedType = userModel.verified?.type ?? ""
        buttonForAvatar.avatarInfo = avatarInfo
        nicknameTextField.text = userModel.name
        sexTextField.text = setSexType(type: userModel.sex)
        if userModel.location == nil || userModel.location == "" {
            cityTextField.text = userModel.location
        } else {
            cityTextField.text = self.filterShowCity(locationStr: userModel.location!)
        }
        if let bio = userModel.bio {
            personalProfileTextView.text = bio
            setCountLabel(intro: bio)
        }
        textViewDidChange(personalProfileTextView)
    }

    // MARK: - avatarTaped
    @IBAction func avatarTaped() {
        useResignFirstResponder()
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

    // MARK: - 设置完成按钮状态
    fileprivate func setFinishButtonState(textField: UITextField) {
        if imageId != 0 {
            enable()
            return
        }
        switch textField {
        case self.sexTextField:
            if let userModel = self.userModel {
                if textField.text != setSexType(type: userModel.sex) {
                    enable()
                } else {
                    disable()
                }
            }
        case self.cityTextField:
            if locationStr != "" && locationStr != userModel?.location {
                enable()
            } else {
                disable()
            }
        case self.nicknameTextField:
            if textField.text != userModel?.name {
                enable()
            } else {
                disable()
            }
        case personalProfileTextView:
            if textField.text != userModel?.bio {
                enable()
            } else {
                disable()
            }
        default:
            break
        }
    }

    // MARK: - textField点击返回后
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - 限制字数
    func textFiledDidChanged(notification: Notification) {
        guard let textField = notification.object! as? UITextField else {
            return
        }
        if textField == nicknameTextField {
            TSAccountRegex.checkAndUplodTextField(textField: textField, byteLimit: nicknameMaxCount)
        } else {
            TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: textFiledMaximumWordLimit)
        }
        setFinishButtonState(textField: textField)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
       useResignFirstResponder()
    }

    // MARK: - 设置TextView高度
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > textViewMaximumWordLimit {
            TSAccountRegex.checkAndUplodTextFieldText(textField: textView, stringCountLimit: textViewMaximumWordLimit)
        }
        setCountLabel(intro: (textView.text)!)
        self.setAllComponenSize(textView: textView)
        if imageId != 0 {
            enable()
            return
        }
        if textView.text != userModel?.shortDesc() {
            enable()
        } else {
            disable()
        }
    }

    internal func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" || text == "\n\r" {
            useResignFirstResponder()
            return false
        }
        return true
    }

    func setAllComponenSize(textView: UITextView) {
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(MAXFLOAT)))
        TSLogCenter.log.debug(newSize)
        if textView.text.count > textFiledMaximumWordLimit {
            //如果需要显示提示文字，需要加高一个提示文字的高度
            personalpProfileTextViewHeight.constant = newSize.height + 15
        } else {
            personalpProfileTextViewHeight.constant = newSize.height
        }
    }

    // MARK: - 点击性别选择器
    @IBAction func sexSelectorTap(_ sender: UITapGestureRecognizer) {
        nicknameTextField.resignFirstResponder()
        personalProfileTextView.resignFirstResponder()
        let sexSelectorView = TSCustomActionsheetView(titles: ["选择_男".localized, "选择_女".localized, "选择_保密".localized])
        sexSelectorView.delegate = self
        sexSelectorView.show()

    }

    // MARK: - 点击头像， 性别选择回调
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if view.tag == 10 {
            switch index {
            case 0:
                openLibrary()
            default:
                openCamera()
            }
            return
        }

        self.sexTextField.text = title
        if let userModel = self.userModel {
            if self.sexTextField.text != setSexType(type: userModel.sex) {
                enable()
            } else {
                disable()
            }
        }

    }

    // MARK: - 点击城市
    @IBAction func citySelectorTap(_ sender: UITapGestureRecognizer) {
        useResignFirstResponder()
        let vc = TSSelectAreaViewController()
        vc.setFinishOpration { (str) in
            guard str != "" else {
                return
            }
            self.cityTextField.text = self.filterShowCity(locationStr: str)
            self.locationStr = self.cityTextField.text!
            self.setFinishButtonState(textField: self.cityTextField)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Button click
    override func rightButtonClicked() {
        disable()
        self.mainScrollView.isUserInteractionEnabled = false
        // 检查昵称
        if TSAccountRegex.countShortFor(userName: self.nicknameTextField.text) == true {
            let topShow = TSIndicatorWindowTop(state: .faild, title: "提示信息_昵称长度过短错误".localized)
            topShow.show()
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                DispatchQueue.main.async {
                    topShow.dismiss()
                }
            })
            enable()
            self.mainScrollView.isUserInteractionEnabled = true
            return
        }
        if TSAccountRegex.lenthOf(userName: self.nicknameTextField.text) > nicknameMaxCount {
            let topShow = TSIndicatorWindowTop(state: .faild, title: "提示信息_昵称长度超过长度错误".localized)
            topShow.show()
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                DispatchQueue.main.async {
                    topShow.dismiss()
                }
            })
            enable()
            self.mainScrollView.isUserInteractionEnabled = true
            return
        }
        if TSAccountRegex.isUserNameStartWithNumber(self.nicknameTextField.text!) {
            let topShow = TSIndicatorWindowTop(state: .faild, title: "提示信息_昵称以数字开头".localized)
            topShow.show()
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                DispatchQueue.main.async {
                    topShow.dismiss()
                }
            })
            enable()
            self.mainScrollView.isUserInteractionEnabled = true
            return
        }
        if self.personalProfileTextView.text!.count.isEqualZero {
            let topShow = TSIndicatorWindowTop(state: .faild, title: "请输入简介")
            topShow.show()
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                DispatchQueue.main.async {
                    topShow.dismiss()
                }
            })
            enable()
            self.mainScrollView.isUserInteractionEnabled = true
            return
        }

        if TSAccountRegex.chanageUserName(self.nicknameTextField.text!) {
            let topShow = TSIndicatorWindowTop(state: .faild, title: "提示信息_昵称含有不合法字符".localized)
            topShow.show()
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                DispatchQueue.main.async {
                    topShow.dismiss()
                }
            })
            enable()
            self.mainScrollView.isUserInteractionEnabled = true
            return
        }

        // 修改用户基本资料
        let name = self.nicknameTextField.text!
        let sex = self.sexTextField.text!
        let location = self.locationStr
        let bio = self.personalProfileTextView.text!
        TSDataQueueManager.share.userInfoQueue.updateUserBaseInfo(name: name, sex: sex, bio: bio, location: location) { (msg, status) in
            if status {
                let topShow = TSIndicatorWindowTop(state: .success, title: "提示信息_修改成功!".localized)
                topShow.show()
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                    DispatchQueue.main.async {
                        topShow.dismiss()
                        let _ = self.navigationController?.popViewController(animated: true)
                    }
                })
                return
            } else {
                let errorTitle = msg ?? "修改失败"
                let topShow = TSIndicatorWindowTop(state: .faild, title: errorTitle)
                topShow.show()
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                    DispatchQueue.main.async {
                        topShow.dismiss()
                        self.mainScrollView.isUserInteractionEnabled = true
                        self.enable()
                    }
                })
            }
        }

    }

    // [长期注释] 性别修改未完成修改，暂时不删除 2017年08月04日17:44:15
//    func setSendParam() -> [String : Any] {
//        var params = Dictionary<String, Any>()
//        var sexValue: Int?
//        if let sex = sexTextField.text {
//            switch sex {
//            case "男":
//                sexValue = 1
//            case "女":
//                sexValue = 2
//            case "未知":
//                fallthrough
//            default:
//                sexValue = 0
//            }
//        }
//
//        if sexValue != nil {
//            params["sex"] = sexValue
//        }
//
//        if let province = provinceName, let cityName = cityName {
//            params["province"] = province
//            params["city"] = cityName
//            params["location"] = province + cityName
//        }
//
//        if personalProfileTextView.text != userModel?.shortDesc() {
//            params["intro"] = personalProfileTextView.text
//        }
//
//        if nicknameTextField.text != userModel?.name && userModel != nil {
//            params["name"] = nicknameTextField.text
//        }
//
//        if self.imageId != 0 {
//            params["storage_task_id"] = self.imageId
//        }
//
//        return params
//    }

    @IBAction func tapScroll(_ sender: Any) {
        useResignFirstResponder()
    }
    // MARK: - Private

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
//        let cameraVC = TSImagePickerViewController.canCropCamera(cropType: .squart, finish: { [weak self] (image: UIImage) in
//            guard let weakSelf = self else {
//                return
//            }
//            weakSelf.templateImage = image
//            let imageName = (PHAsset().originalFilename)!
//            weakSelf.changeImageRequest(image: image, imageName: imageName, size:  CGSize(width: image.size.width, height: image.size.height))
//            weakSelf.buttonForAvatar.buttonForAvatar.setImage(image, for: .normal)
//        })
//        cameraVC.show()
    }

    private func openLibrary() {
        guard let imagePickerVC = TZImagePickerController(maxImagesCountTSType: 1, columnNumber: 4, delegate: self, pushPhotoPickerVc: true, square: true, shouldPick: true, topTitle: "更换头像", mainColor: TSColor.main.theme)
            else {
                return
        }
        /// 不设置则直接用TZImagePicker的pod中的图片素材
        /// #图片选择列表页面
        /// item右上角蓝色的选中图片
//            imagePickerVC.selectImage = UIImage(named: "msg_box_choose_now")

        imagePickerVC.maxImagesCount = 1
        imagePickerVC.allowCrop = true
        imagePickerVC.isSelectOriginalPhoto = true
        imagePickerVC.allowTakePicture = true
        imagePickerVC.allowPickingImage = true
        imagePickerVC.allowPickingVideo = false
        imagePickerVC.allowPickingGif = false
        imagePickerVC.sortAscendingByModificationDate = false
        imagePickerVC.navigationBar.barTintColor = UIColor.white
        var dic = [String: Any]()
        dic[NSForegroundColorAttributeName] = UIColor.black
        imagePickerVC.navigationBar.titleTextAttributes = dic
        present(imagePickerVC, animated: true)
    }

    // MARK: - 系统拍照选择图片回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let infoDict = info as! NSDictionary
        let type: String = infoDict.object(forKey: UIImagePickerControllerMediaType) as! String
        if type == "public.image" {
            let photo: UIImage = infoDict.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
            let photoOrigin: UIImage = photo.fixOrientation()
            if photoOrigin != nil {
                let lzImage = LZImageCropping()
                lzImage.cropSize = CGSize(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.width - 80)
                lzImage.image = photoOrigin
                lzImage.isRound = false
                lzImage.titleLabel.text = "更换头像"
                lzImage.didFinishPickingImage = {(image) -> Void in
                    guard let image = image else {
                        return
                    }
                    self.templateImage = image
                    let imageName = (PHAsset().originalFilename)!
                    self.changeImageRequest(image: image, imageName: imageName, size:  CGSize(width: image.size.width, height: image.size.height))
                    self.buttonForAvatar.buttonForAvatar.setImage(image, for: .normal)
                }
                self.navigationController?.present(lzImage, animated: true, completion: nil)
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
            self.templateImage = photos[0]
            let imageName = (PHAsset().originalFilename)!
            self.changeImageRequest(image: self.templateImage!, imageName: imageName, size:  CGSize(width: (self.templateImage?.size.width)!, height: (self.templateImage?.size.height)!))
            self.buttonForAvatar.buttonForAvatar.setImage(self.templateImage!, for: .normal)
        } else {
            let resultAlert = TSIndicatorWindowTop(state: .faild, title: "图片选择异常,请重试!")
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
        }
    }

    /// 选择好图片后上传服务器
    ///
    /// - Parameters:
    ///   - image: 图片
    ///   - imageName: 图片名
    ///   - size: 尺寸
    private func changeImageRequest(image: UIImage, imageName: String, size: CGSize) {
        let loadingShow = TSIndicatorWindowTop(state: .loading, title: "提示信息_头像上传中".localized)
        loadingShow.show()
        // 对用户头像进行处理(服务器限制：头像必须是正方形，宽高必须在 100px - 500px 之间)
        let rect = CGRect(x: 0, y: 0, width: 150, height: 150) //创建框
        UIGraphicsBeginImageContext(rect.size) //根据size大小创建一个基于位图的图形上下文
        let context = UIGraphicsGetCurrentContext() //获取当前quartz 2d绘图环境
        context?.saveGState()
        // 翻转---上下颠倒
        context?.translateBy(x: 0, y: 150)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.clip(to: rect) //设置当前绘图环境到矩形框
        context?.draw(image.cgImage!, in: rect) //绘图
        context?.restoreGState()
        let cropped: UIImage = UIGraphicsGetImageFromCurrentImageContext()! //获得图片
        UIGraphicsEndImageContext() //从当前堆栈中删除quartz 2d绘图环境
        let imageData = UIImageJPEGRepresentation(cropped, 1.0)!
        // 修改用户头像
        TSUserNetworkingManager().updateUserAvatar(imageData) { (_, status) in
            loadingShow.dismiss()
            if status {
                self.delegate?.sendImageWithTemplate(image: image)
                let succShow = TSIndicatorWindowTop(state: .success, title: "提示信息_头像上传成功".localized)
                succShow.show()
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                    DispatchQueue.main.async {
                        succShow.dismiss()
                    }
                })
                // 单张图片的kf缓存更新
                if let key = TSUtil.praseTSNetFileUrl(netFile: TSCurrentUserInfo.share.userInfo?.avatar) {
                    // 注：这里这样使用的原因是后台关于头像的链接，若存在，则是唯一且一定的，修改接口只更新内容，但原链接仍然不变，因此需要对之前的缓存进行清理，避免缓存不同步的干扰。直接清理会导致闪烁问题，因此进一步更新缓存解决闪烁问题。
                    // 清除之前的缓存
                    ImageCache.default.removeImage(forKey: key)
                    // 更新缓存内容
                    ImageCache.default.store(cropped, forKey: key)
                }
            } else {
                self.showUpdateImageFail(indicator: loadingShow)
            }
        }
    }

    func showUpdateImageFail(indicator: TSIndicatorWindowTop) {
        indicator.dismiss()
        self.templateImage = nil
        let topShow = TSIndicatorWindowTop(state: .faild, title: "提示信息_头像上传失败".localized)
        topShow.show()
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
            DispatchQueue.main.async {
                topShow.dismiss()
            }
        })
    }

    /// 设置字符统计
    ///
    /// - Parameters:
    ///   - intro: 简介
    private func setCountLabel(intro: String) {
        if intro.count > textFiledMaximumWordLimit {
            personalProfileWithCountLabelOfTop.priority = UILayoutPriorityDefaultHigh
            personalpProfileWithSuperViewOfBottom.priority = UILayoutPriorityDefaultLow
            currentTextNumberLabel.isHidden = false
            currentTextNumberLabel.text = "\(intro.count)/\(textViewMaximumWordLimit)"
        } else {
            personalProfileWithCountLabelOfTop.priority = UILayoutPriorityDefaultLow
            personalpProfileWithSuperViewOfBottom.priority = UILayoutPriorityDefaultHigh
            currentTextNumberLabel.isHidden = true
        }
        scrollContentSizeHeight.constant = mainScrollView.bounds.size.height - contentView.bounds.size.height - 79 + 10
        IQKeyboardManager.sharedManager().reloadLayoutIfNeeded()
    }

    private func enable() {
        self.rightButtonEnable(enable: true)
    }

    private func disable() {
        self.rightButtonEnable(enable: false)
    }

    private func useResignFirstResponder() {
        nicknameTextField.resignFirstResponder()
        personalProfileTextView.resignFirstResponder()
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            DispatchQueue.main.async {
                self.scrollContentSizeHeight.constant = UIScreen.main.bounds.size.height - 64 - self.contentView.bounds.size.height - 79
            }
        })
    }

    /// 检测相机
    ///
    /// - Returns: 是否允许
    class func PhotoLibraryPermissions() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .denied, .restricted:
            let appName = TSAppConfig.share.localInfo.appDisplayName
            TSErrorTipActionsheetView().setWith(title: "相册权限设置", TitleContent: "请为\(appName)开放相册权限：手机设置-隐私-相册-\(appName)(打开)", doneButtonTitle: ["去设置", "取消"], complete: { (_) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.openURL(url!)
                }
            })
            return false
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (granted) in
                print("album", granted)
            })
            return false
        case .authorized:
            return true
        }
    }

    /// 检测相册
    ///
    /// - Returns: 是否允许
    class func checkCamearPermissions() -> Bool {
        // 1.获取相机授权状态
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .denied, .restricted:
            // 2.取消了授权
            let appName = TSAppConfig.share.localInfo.appDisplayName
            TSErrorTipActionsheetView().setWith(title: "相册权限设置", TitleContent: "请为\(appName)开放相册权限：手机设置-隐私-相册-\(appName)(打开)", doneButtonTitle: ["去设置", "取消"], complete: { (_) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.openURL(url!)
                }
            })
            return false
        case .notDetermined:
            // 3.还没有授权，可以询问一次
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                print("camera", granted)
            })
            return false
        case .authorized:
            // 4.有授权，前往相机
            return true
        }
    }

    // MARK: - 标签那一行的代理
    func selfContentSizeHight(hight: CGFloat) {
        guard hight > 50 else {
            return
        }
        self.userLabelBGViewHight.constant = hight + 11
    }

    func toSettingUserLabelVC() {
        // 进入标签选择界面
        let labelVC = TSUserLabelSetting(type: .setting)
        labelVC.labelChangedAction = { (selectedTagList) in
            var data: Array<String> = []
            for model in selectedTagList {
                data.append(model.tagName)
            }
//            self.userInfoLabelCollectionView.setData(data: data)
            self.updataTagUI(data: data)
            if data.isEmpty {
                self.userLabelBGViewHight.constant = 50
            }
        }
        self.navigationController?.pushViewController(labelVC, animated: true)
    }

    /// 城市数据展示
    func filterShowCity(locationStr: String) -> String {
        var str: String = ""
        let locationStrArray = locationStr.components(separatedBy: " ")
        if locationStrArray.count >= 3 {
            str = locationStrArray[1] + " " + locationStrArray[2]
        } else if locationStrArray.count == 2 {
            str = locationStrArray[0] + " " + locationStrArray[1]
        }
        return str
    }
}

extension TSSetUserInfoVC {
    // MARK: - 键盘放弃响应,编辑完成后让完成变成可以点击
    func textFieldDidEndEditing(_ textField: UITextField) {
        setFinishButtonState(textField: textField)
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        setFinishButtonState(textField: textField)
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.isEqual(nicknameTextField) {
            personalProfileTextView.resignFirstResponder()
        }
    }
}
