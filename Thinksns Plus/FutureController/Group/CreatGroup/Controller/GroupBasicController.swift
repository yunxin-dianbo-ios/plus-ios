//
//  CreateGroupController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子信息视图控制器
//
//  这个类作为一个纯 UI 的视图控制器，各种操作事件请在其子类事件

import UIKit

class GroupBasicController: UITableViewController, UITextFieldDelegate {

    /// 子类视图控制器的类型
    enum ChildType {
        /// 创建圈子
        case create
        /// 圈子详情
        case groupInfo
    }

    /// 公告输入框的高度
    @IBOutlet weak var noticeTextViewHeight: NSLayoutConstraint!
    /// 简介输入框的高度
    @IBOutlet weak var introTextViewHeight: NSLayoutConstraint!
    /// 圈子数据
    var model = BuildGroupModel()

    /// 圈名长度限制
    fileprivate let nameLenth = 20
    /// 简介长度限制
    fileprivate let introLenth = 255
    /// 公告长度限制
    fileprivate let noticeLenth = 2_000
    /// 入圈金额的长度限制
    fileprivate let moneyLenth = 8
    /// 公告输入框中，大于多少字数时显示 noticeCountLabel
    fileprivate let showNoticeCountLabelLimit = 170
    /// 简介输入空中，大于多少字数时显示 introCountLabel
    fileprivate let showIntroCountLabelLimit = 170
    /// cells 高度
    var cellHeights = [CGFloat](repeating: UITableViewAutomaticDimension, count: 14)
    /// cells 操作权限
    var cellUserInteraction = [Bool].init(repeating: true, count: 14)
    @IBOutlet weak var nameLab: UILabel!
    /// 详情页是否只展示
    var isJustShowInfo: Bool = true
    /// 圈子封面图
    @IBOutlet weak var coverImageView: UIImageView!
    /// 圈名输入框
    @IBOutlet weak var nameTextField: UITextField!
    /// 地址
    @IBOutlet weak var locationLabel: UILabel!
    /// 简介输入框
    @IBOutlet weak var introTextView: UITextView!
    /// 同步到动态的开关
    @IBOutlet weak var feedSwitch: UISwitch!
    /// 私密圈子的开关
    @IBOutlet weak var privateSwitch: UISwitch!
    /// 收费入圈的金币输入框
    @IBOutlet weak var paidTextField: UITextField!
    /// 金币输入框的金币单位 label
    @IBOutlet weak var paidUnitLabel: UILabel!
    /// 选择收费入圈的按钮
    @IBOutlet weak var choosePaidButton: UIButton!
    /// 选择免费入圈的按钮
    @IBOutlet weak var chooseFreeButton: UIButton!
    /// 分类 label
    @IBOutlet weak var categoryLabel: UILabel!
    /// 公告输入框
    @IBOutlet weak var noticeTextView: UITextView!
    /// 展示模式下 用于显示金币数量
    @IBOutlet weak var justShowPayCountLab: UILabel!
    /// 展示模式下 用于显示圈子付费情况
    @IBOutlet weak var justShowGroupPayTypeLab: UILabel!
    /// 同步圈子的lab 需要修改颜色
    @IBOutlet weak var justShowFeedSynLab: UILabel!
    /// 所有可编辑的右侧的图标
    @IBOutlet weak var headerArrowIcon: UIImageView!
    @IBOutlet weak var typeArrowIcon: UIImageView!
    @IBOutlet weak var userLabArrowIcon: UIImageView!
    @IBOutlet weak var locationArrowIcon: UIImageView!
    /// 导航栏右边按钮
    let rightButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(TSColor.main.theme, for: .normal)
        button.setTitleColor(TSColor.button.disabled, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }()
    /// 支付单位
    /// 简介字数 label
    @IBOutlet weak var introCountLabel: UILabel!
    /// 公告字数 label
    @IBOutlet weak var noticeCountLabel: UILabel!

    /// 简介提示信息
    @IBOutlet weak var introMessage: UILabel!
    /// 公告提示信息
    @IBOutlet weak var noticeMessage: UILabel!
    /// 封面提示信息
    @IBOutlet weak var coverMessage: UILabel!

    /// 圈子类型 Cell：私密圈子还是开放圈子
    @IBOutlet weak var groupTypeCell: UITableViewCell!
    /// 收费入圈 cell
    @IBOutlet weak var paidInfoCell: UITableViewCell!
    /// 免费入圈 cell
    @IBOutlet weak var freeInfoCell: UITableViewCell!
    /// 协议 cell
    @IBOutlet weak var agreementCell: UITableViewCell!
    // 协议 Label
    @IBOutlet weak var agreementLabel: UILabel!
    /// 分类 label 的宽度
    @IBOutlet weak var categoryLabelWidth: NSLayoutConstraint!
    // 复制 setUserInfoVC 的圈子标签的背景视图
    @IBOutlet weak var userLabelBGView: UIView!
    // 复制 setUserInfoVC 的圈子标签视图
    weak var userInfoLabelCollectionView: TSUserInfoLabel!
    // 复制 setUserInfoVC 的圈子标签的背景视图的高度
    @IBOutlet weak var userLabelBGViewHight: NSLayoutConstraint!
    // 已经选择了的标签
    var selectedTags: [TSCategoryIdTagModel] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        self.agreementLabel.text = String(format: "点击创建即代表同意《圈子创建协议》".localized, TSAppSettingInfoModel().appDisplayName)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 增加检测键盘输入状态的通知
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledDidChanged(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 移除检测输入框状态的通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    /// 子视图控制器的类型
    static var type: ChildType = .create
    override func awakeFromNib() {
        super.awakeFromNib()
        switch GroupBasicController.type {
        case .create:
            object_setClass(self, CreateGroupController.self)
        case .groupInfo:
            object_setClass(self, GroupInfoController.self)
        }
        setUI()
    }

    // MARK: - UI

    func setUI() {

        tableView.backgroundColor = UIColor(hex: 0xf4f5f5)
        tableView.estimatedRowHeight = 50

        // 设置钱币单位
        paidUnitLabel.text = TSAppConfig.share.localInfo.goldName

        // 标签展示视图
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let userInfoLabelCollectionView = TSUserInfoLabel(frame: CGRect.zero, collectionViewLayout: layout)
        userInfoLabelCollectionView.isUserInteractionEnabled = false
        userInfoLabelCollectionView.TSUserInfoLabelDelegate = self
        userInfoLabelCollectionView.tipsLabel.text = "最多可选择5个标签"
        self.userInfoLabelCollectionView = userInfoLabelCollectionView
        self.userLabelBGView.addSubview(userInfoLabelCollectionView)
        userInfoLabelCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.userLabelBGView).offset(10)
            make.left.equalTo(self.userLabelBGView)
            make.bottom.equalTo(self.userLabelBGView).offset(1)
            make.right.equalTo(self.userLabelBGView).offset(-22)
        }

        // 收费入圈金额输入框键盘
        paidTextField.keyboardType = UIKeyboardType.numberPad
        nameTextField.delegate = self
        // 字数提醒要到了默认的字数才显示
        noticeCountLabel.isHidden = showNoticeCountLabelLimit > 0
        introCountLabel.isHidden = showIntroCountLabelLimit > 0
    }

    /// 设置分类信息
    func set(categoryName: String) {
        categoryLabel.text = categoryName
        categoryLabel.textColor = UIColor(hex: 0x666666)
        categoryLabel.font = UIFont.systemFont(ofSize: 14)
        categoryLabel.backgroundColor = UIColor.clear
        categoryLabel.sizeToFit()
        categoryLabelWidth.constant = categoryLabel.size.width + 10
    }

    /// 设置定位信息
    func set(locationInfo localString: String) {
        locationLabel.font = UIFont.systemFont(ofSize: 15)
        locationLabel.textColor = UIColor(hex: 0x333333)
        locationLabel.text = localString
    }
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView .isKind(of: UITextView.self) {
            tableView.isScrollEnabled = false
        }
        if  scrollView.isKind(of: UITableView.self) {
            noticeTextView.isScrollEnabled = false
        }
    }
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        noticeTextView.isScrollEnabled = false
        tableView.isScrollEnabled = true
    }

    // MARK: - Action

    /*
     用户操作了界面，model 发生了改变。

     这个方法，在 GroupBasicController 内部调用，由 GroupBasicController 的子类重写来获取“用户操作了界面”的事件
     */
    func userOperated() {
    }

    /// 检测输入框的输入状态
    func textFiledDidChanged(notification: Notification) {
        guard let textField = notification.object as? UITextField else {
            return
        }
        // 输入框文字字数上限
        var stringCountLimit = 9_999
        switch textField {
        case nameTextField:
            // 如果是圈名输入框
            model.name = textField.text ?? ""
            stringCountLimit = nameLenth
        case paidTextField:
            guard let money = Int(textField.text ?? "0") else {
                return
            }
            model.money = money
            stringCountLimit = moneyLenth
        default:
            return
        }
        TSAccountRegex.checkAndUplodTextFieldText(textField: textField, stringCountLimit: stringCountLimit)
        userOperated()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameTextField {
            let lang = textField.textInputMode?.primaryLanguage
            if lang == "zh-Hans" {
                return true
            } else if lang == "emoji" || TSCommonTool.stringContainsEmoji(string) || lang == nil {
                return false
            } else {
                return true
            }
        }
        return true
    }
    /// ”同步至动态“的开关被点击了
    @IBAction func feedSwitchChanged(_ sender: UISwitch) {
        view.endEditing(true)
        model.allowFeed = sender.isOn
        userOperated()
    }

    /// “私密圈子”的开关被点击了
    @IBAction func privateSwitchChanged(_ sender: UISwitch) {
        view.endEditing(true)
        if sender.isOn {
            // 默认免费加入
            model.mode = "private"
            model.money = 0
            paidTextField.text = ""
            choosePaidButton.isSelected = false
            chooseFreeButton.isSelected = true
        } else {
            model.mode = "public"
            model.money = 0
            paidTextField.text = ""
            choosePaidButton.isSelected = false
            chooseFreeButton.isSelected = false
        }
        tableView.reloadData()
        userOperated()
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension GroupBasicController: TZImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /// 如果设置为私密圈子开关是关闭的，隐藏 "收费入圈 cell" 和 "免费入圈 cell"
        let cell = tableView.cellForRow(at: indexPath)
        /// 预览模式关闭可操作性
        if self.isJustShowInfo == false {
            cell?.isUserInteractionEnabled = false
        }
        if !privateSwitch.isOn && (cell == paidInfoCell || cell == freeInfoCell) {
            paidTextField.isHidden = true
            paidUnitLabel.isHidden = true
            return 0
        }
        return cellHeights[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        view.endEditing(true)
        // 1.检查一下操作权限
        guard cellUserInteraction[indexPath.row] else {
            return
        }

        let cell = tableView.cellForRow(at: indexPath)!
        // 点击了头像
        if indexPath.row == 0 {
            showChooseImageAlert()
        }
        // 点击了分类
        if indexPath.row == 2 {
            pushToCategoryChooseVC()
        }
        // 点击了标签
        if indexPath.row == 3 {
            pushToTagsChooseVC()
        }
        /// 点击了位置
        if indexPath.row == 4 {
            pushToLocationVC()
        }
        // 点击了付费入圈
        if cell == paidInfoCell {
            model.mode = "paid"
            choosePaidButton.isSelected = true
            chooseFreeButton.isSelected = false
            paidTextField.isHidden = false
            paidUnitLabel.isHidden = false
        }
        // 点击了免费入圈
        if cell == freeInfoCell {
            model.mode = "private"
            chooseFreeButton.isSelected = true
            choosePaidButton.isSelected = false
            paidTextField.isHidden = true
            paidUnitLabel.isHidden = true
        }
        // 点击了查看协议的 cell
        if cell == agreementCell {
            showBuildAgreement()
        }
        userOperated()
    }

    /// 跳转定位视图控制器
    private func pushToLocationVC() {
        let locationVC = GroupLocationController()
        locationVC.selectedLocationAction = { [weak self] (model) in

            if let model = model {
                self?.model.locationInfo = .location(model.location, model.latitude, model.longitude, model.geoHash)
            } else {
                self?.model.locationInfo = .unshow
            }
            self?.set(locationInfo: model?.location ?? "不显示位置")
            self?.userOperated()
        }
        self.navigationController?.pushViewController(locationVC, animated: true)
    }

    /// 跳转圈子类别选择视图控制器
    private func pushToCategoryChooseVC() {
        let tagsController = ATagsController()
        tagsController.title = "全部圈子"
        // 加载 tags 数据
        tagsController.loading()
        GroupNetworkManager.getGroupCategories(complete: { [weak tagsController] (models, message, status) in
            guard let models = models else {
                tagsController?.loadFaild(type: .network)
                return
            }
            tagsController?.endLoading()
            tagsController?.datas = models.map { ATagModel(categoriesModel: $0) }
            tagsController?.collection.reloadData()
        })
        // 设置 tags 点击事件
        tagsController.tapAction = { (model) in
            self.model.categoryId = model.tagID
            self.set(categoryName: model.name)
            self.tableView.reloadData()
            self.userOperated()
        }
        navigationController?.pushViewController(tagsController, animated: true)
    }

    /// 跳转标签选择视图控制器
    private func pushToTagsChooseVC() {
        // 进入标签选择界面
        let labelVC = TSUserLabelSetting(type: .group)
        labelVC.saveLabelDataSource = selectedTags
        labelVC.labelChangedAction = { (selectedTagList) in
            self.selectedTags = selectedTagList
            let tagNames = selectedTagList.map { $0.tagName }
            let tagIds = selectedTagList.map { $0.tagId }
            self.model.tagIds = tagIds
            self.userInfoLabelCollectionView.setData(data: tagNames)
            if tagNames.isEmpty {
                self.userLabelBGViewHight.constant = 50
            }
            self.tableView.reloadData()
            self.userOperated()
        }
        navigationController?.pushViewController(labelVC, animated: true)
    }

    /// 显示选择图片的弹窗
    private func showChooseImageAlert() {
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
//        let cameraVC = TSImagePickerViewController.canCropCamera(cropType: .squart, finish: { [weak self] (image: UIImage) in
//            guard let weakSelf = self else {
//                return
//            }
//            weakSelf.coverImageView.image = image
//            weakSelf.model.coverImage = image
//            weakSelf.userOperated()
//        })
//        cameraVC.show()
    }

    private func openLibrary() {
        let isSuccess = TSSetUserInfoVC.PhotoLibraryPermissions()
        guard isSuccess else {
            return
        }
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
//        let albumVC = TSImagePickerViewController.canCropAlbum(cropType: .squart) { [weak self] (image) in
//            guard let weakSelf = self else {
//                return
//            }
//            weakSelf.coverImageView.image = image
//            weakSelf.model.coverImage = image
//            weakSelf.userOperated()
//        }
//        albumVC.show()
    }

    // MARK: - 系统拍照选择图片回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let infoDict: NSDictionary = (info as? NSDictionary)!
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
                lzImage.didFinishPickingImage = {(image) ->() in
                    guard let image = image else {
                        return
                    }
                    let imageName = (PHAsset().originalFilename)!
                    self.changeImageRequest(image: image, imageName: imageName, size:  CGSize(width: image.size.width, height: image.size.height))
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
            let imageName = (PHAsset().originalFilename)!
            self.changeImageRequest(image: photos[0], imageName: imageName, size:  CGSize(width: photos[0].size.width, height: photos[0].size.height))
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
        self.coverImageView.image = cropped
        self.model.coverImage = cropped
        self.userOperated()
        print("\(cropped.size)")
    }

    /// 显示创建协议
    func showBuildAgreement() {
        // 1.发起网络请求
        let alert = TSIndicatorWindowTop(state: .loading, title: "获取协议中...")
        alert.show()
        GroupNetworkManager.getBuildAgreement { [weak self] (status, message, agreement) in
            alert.dismiss()
            // 2.获取协议失败
            guard let agreementString = agreement else {
                let resultAlert = TSIndicatorWindowTop(state: .faild, title: message ?? "获取失败")
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            // 3.获取协议成功
            let ruleVC = TSWalletRuleVCViewController()
            ruleVC.title = "圈子创建协议"
            ruleVC.set(content: agreementString)
            self?.navigationController?.pushViewController(ruleVC, animated: true)
        }
    }
}

// MARK: - UITextViewDelegate
extension GroupBasicController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let noSpacingString = textView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let string = noSpacingString
        let stringLenth = string.count
        switch textView {
        case noticeTextView:
            // 1.判断是否隐藏字数提示 label
            noticeCountLabel.isHidden = !(stringLenth > showNoticeCountLabelLimit)
            // 2.限制字数
            if stringLenth > noticeLenth {
                TSAccountRegex.checkAndUplodTextFieldText(textField: textView, stringCountLimit: noticeLenth)
            }
            // 3.设置字数 label 显示内容
            noticeCountLabel.text = "\(stringLenth > noticeLenth ? noticeLenth : stringLenth)/\(noticeLenth)"

            model.notice = textView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        case introTextView:
            // 1.判断是否隐藏字数提示 label
            introCountLabel.isHidden = !(stringLenth > showIntroCountLabelLimit)
            // 2.限制字数
            if stringLenth > introLenth {
                TSAccountRegex.checkAndUplodTextFieldText(textField: textView, stringCountLimit: introLenth)
            }
            // 3.设置字数 label 显示内容
            introCountLabel.text = "\(stringLenth > introLenth ? introLenth : stringLenth)/\(introLenth)"

            model.intro = textView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        default:
            break
        }
        userOperated()
        tableView.beginUpdates()
        // 让 table view 重新计算高度
        updateTextViewHeigh(textView: textView)
        tableView.endUpdates()
        // 5.根据高度判断 textView 是否可滚动
        /// 普通权限只能看，显示完整信息
        if isJustShowInfo == false {
            textView.isScrollEnabled = false
        } else {
            textView.isScrollEnabled = textView.contentSize.height >= 90
        }
    }

    func updateTextViewHeigh(textView: UITextView) {
        let originalSize = textView.frame.size
        var newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(MAXFLOAT)))
        var fixOffset: CGFloat = newSize.height - originalSize.height
        /// 普通权限只能看，显示完整信息
        if isJustShowInfo == false {
            tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + fixOffset), animated: false)
            if textView == noticeTextView {
                noticeTextViewHeight.constant = newSize.height
            } else if textView == introTextView {
                introTextViewHeight.constant = newSize.height
            }
            return
        }
        /// 有编辑权限的用户角色会自动调整输入框高度
        newSize.height = min(newSize.height, 91)
        if originalSize.height > 91 {
            fixOffset = 0
        }
        tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + fixOffset), animated: false)
        switch textView {
        case noticeTextView:
            noticeTextViewHeight.constant = newSize.height
        case introTextView:
            introTextViewHeight.constant = newSize.height
        default:
            break
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 不允许用户输入换行符
        if text == "\n" {
            return false
        }
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        // 1.隐藏输入框上的提示信息
        switch textView {
        case noticeTextView:
            noticeMessage.isHidden = true
        case introTextView:
            introMessage.isHidden = true
        default:
            break
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // 显示公告提示信息
        if noticeTextView.text == "" {
            noticeMessage.isHidden = false
        }
        // 显示简介提示信息
        if introTextView.text == "" {
            introMessage.isHidden = false
        }
    }

}

extension GroupBasicController: TSUserInfoLabelDelegate {

    // MARK: - 标签那一行的代理
    func selfContentSizeHight(hight: CGFloat) {
        guard hight > 50 else {
            return
        }
        self.userLabelBGViewHight.constant = hight + 11
        tableView.reloadData()
    }

}
