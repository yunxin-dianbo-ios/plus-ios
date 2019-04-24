//
//  TSNewsContributeController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 17/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯发布界面——封面上传

import UIKit

extension Notification.Name {
    /// 投稿中的资讯修改成功的通知
    static var ContributingNewsUpdated = Notification.Name("I updated a news")
}

class TSNewsContributeController: TSViewController {

    // MARK: - Internal Property
    // 发布模型
    var contributeModel: TSNewsContributeModel?

    // MARK: - Private Property

    /// 封面上传按钮
    fileprivate weak var coverBtn: UIButton!
    /// 提交按钮
    fileprivate weak var submitBtn: UIButton!

    // MARK: - Initialize Function
    // MARK: - Internal Function
    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
        
        // 把文章第一张图加载成封面
        if let model = self.contributeModel, let imageid = model.firstImageId {
            let strPrefixUrl = TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue
            let imageUrl = String(format: "%@/%d", strPrefixUrl, imageid)
            UIImageView().kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "IMG_icon"), options: nil, progressBlock: nil) { (image, _, _, _) in
                if let image = image {
                    self.coverBtn.setBackgroundImage(image, for: .normal)
                    self.coverBtn.setImage(nil, for: .normal)
                    self.coverBtn.setTitle(nil, for: .normal)
                }
            }
        }
    }

    // MARK: - Private  UI

    private func initialUI() -> Void {
        let lrMargin: Float = 15
        let coverW: Float = 100
        self.view.backgroundColor = UIColor.white
        // navigation bar
        self.navigationItem.title = "标题_上传封面".localized
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "显示_封面重置".localized, style: .plain, target: self, action: #selector(resetCoverItemClick))
        // 1. coverBtn 上传封面按钮
        let coverBtn = UIButton(type: .custom)
        self.view.addSubview(coverBtn)
        coverBtn.addTarget(self, action: #selector(coverBtnClick(_:)), for: .touchUpInside)
        coverBtn.backgroundColor = UIColor(hex: 0xf4f5f5)
        let image = UIImage(named: "IMG_ico_camera")
        coverBtn.setImage(image, for: .normal)
        let title = "显示_点击上传封面".localized
        let font = UIFont.systemFont(ofSize: 10)
        coverBtn.setTitle(title, for: .normal)
        coverBtn.titleLabel?.font = font
        coverBtn.setTitleColor(UIColor(hex: 0xcccccc), for: .normal)
        coverBtn.contentMode = .scaleAspectFill
        coverBtn.clipsToBounds = true
        //使图片和文字水平居中显
        coverBtn.contentHorizontalAlignment = .center
        let imageSize = image!.size
        let titleSize = title.size(maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), font: font)
        // 竖直方向上的间距
        let verMargin: CGFloat = 10
        //文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
        coverBtn.titleEdgeInsets = UIEdgeInsets(top: imageSize.height + verMargin, left: -imageSize.width, bottom: 0, right: 0)
        //图片距离右边框距离减少文字的宽度，其它不动
        coverBtn.imageEdgeInsets = UIEdgeInsets(top: -verMargin, left: 0, bottom: 0, right: -titleSize.width)
        coverBtn.snp.makeConstraints { (make) in
            make.width.equalTo(coverW)
            make.height.equalTo(70)
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view).offset(40)
        }
        self.coverBtn = coverBtn
        // 2. coverPromptLabel 封面上传提示Label
        let promptLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 13), textColor: UIColor(hex: 0xb3b3b3), alignment: .center)
        self.view.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { (make) in
            make.top.equalTo(coverBtn.snp.bottom).offset(25)
            make.leading.trailing.equalTo(self.view)
        }
        // 3. submitBtn 支付并发布文章按钮
        let submitBtn = UIButton(cornerRadius: 6)
        self.view.addSubview(submitBtn)
        submitBtn.addTarget(self, action: #selector(submitBtnClick(_:)), for: .touchUpInside)
        submitBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        submitBtn.setTitleColor(UIColor.white, for: .normal)
        submitBtn.backgroundColor = TSColor.main.theme
        submitBtn.snp.makeConstraints { (make) in
            make.height.equalTo(45)
            make.top.equalTo(promptLabel.snp.bottom).offset(40)
            make.leading.equalTo(self.view).offset(lrMargin)
            make.trailing.equalTo(self.view).offset(-lrMargin)
        }
        self.submitBtn = submitBtn
        // 4. Localized
        promptLabel.text = "显示_资讯封面上传提示".localized
        var submitTitle: String = ""
        if nil != self.contributeModel?.newsId {
            submitTitle = "显示_资讯修改提交".localized
        } else {
            submitTitle = TSAppConfig.share.localInfo.newsContributePay ? "显示_资讯支付发布提交".localized : "显示_资讯无支付发布提交".localized
        }
        submitBtn.setTitle(submitTitle, for: .normal)
    }

    // MARK: - Private  数据处理与加载

    private func initialDataSource() -> Void {
        // 数据加载
        if nil != self.contributeModel {
            self.setupWithContributeModel(self.contributeModel!)
        }
    }
    // 数据加载
    private func setupWithContributeModel(_ model: TSNewsContributeModel) -> Void {
        // 封面处理
        guard let coverFileId = model.coverFileId else {
            return
        }
        let url = TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue
        let imageUrl = url + "/" + "\(coverFileId)"
        self.coverBtn.kf.setBackgroundImage(with: URL(string: imageUrl), for: .normal)
        self.coverBtn.setImage(nil, for: .normal)
        self.coverBtn.setTitle(nil, for: .normal)
    }

    // 提交前的判断
    private func couldSubmit() -> Bool {
        var submitFlag: Bool = true
        if nil == self.contributeModel {
            submitFlag = false
        }
        // 正文没有图片，也没有封面缩略图时，也可以提价
        // 其他内容判断处理
        return submitFlag
    }

    // MARK: - Private  事件响应

    /// 重置封面按钮点击响应
    @objc private func resetCoverItemClick() -> Void {
        self.contributeModel?.coverFileId = nil
        // 当前展示修正
        let image = UIImage(named: "IMG_ico_camera")
        self.coverBtn.setImage(image, for: .normal)
        let title = "显示_点击上传封面".localized
        self.coverBtn.setTitle(title, for: .normal)
        self.coverBtn.setBackgroundImage(nil, for: .normal)
    }
    /// 上传封面按钮点击响应
    @objc private func coverBtnClick(_ button: UIButton) -> Void {
        // 显示相册与照相
        let customAction = TSCustomActionsheetView(titles: ["选择_相册".localized, "选择_相机".localized])
        customAction.tag = 10
        customAction.delegate = self
        customAction.show()
    }
    /// 提交按钮点击响应
    @objc private func submitBtnClick(_ button: UIButton) -> Void {
        // 提交判断
        if !self.couldSubmit() {
            // 提交提示
            let resultAlert = TSIndicatorWindowTop(state: .faild, title: "请完善相关信息")
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: nil)
            return
        }
        // 判断是提交投稿 还是 修改投稿
        if nil == self.contributeModel?.newsId {
            // 发布投稿处理 - 注：发布投稿，有支付处理
            self.publishNewsContributeProcess()
        } else {
            // 修改投稿
            self.updateNewsContribute()
        }
    }
    /// 发布资讯投稿处理
    private func publishNewsContributeProcess() -> Void {
        // 判断是否需要支付
        let configInfo = TSAppConfig.share.localInfo
        if configInfo.newsContributePay {
            // 投稿需要支付
            let payPrice = configInfo.newsContributeAmount
            let payAlert = TSIndicatorPayNewsContributeView(price: Double(payPrice))
            payAlert.show {
                self.PublishNewsContribute()
            }
        } else {
            // 投稿不需要支付
            self.PublishNewsContribute()
        }
    }
    /// 发布资讯投稿
    fileprivate func PublishNewsContribute() -> Void {
        // 提交请求
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_提交中".localized)
        loadingAlert.show()
        self.submitBtn.isEnabled = false
        TSNewsNetworkManager().submitNews(newsContribute: self.contributeModel!) { [weak self](message, status) in
            self?.submitBtn.isEnabled = true
            loadingAlert.dismiss()
            /// 支付需要密码弹窗
            if TSAppConfig.share.localInfo.shouldShowPayAlert {
                if status {
                    TSUtil.dismissPwdVC()
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                    return
                }
            }
            if status {
                // 提交成功，移除图片缓存
                if let fileIds = self?.contributeModel?.content_markdown?.ts_getCustomMarkdownImageId() {
                    TSWebEditorImageManager.default.deleteImages(fileIds: fileIds)
                }
                // 提交成功处理
                let resultAlert = TSIndicatorWindowTop(state: .success, title: "提示信息_投稿请求成功".localized)
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval) {
                    // 返回到进入资讯修改的界面
                    self?.barckToFront()
                }
            } else {
                // 提交失败处理
                let resultAlert = TSIndicatorWindowTop(state: .faild, title: String(format: "%@: %@", "提示信息_提交失败".localized, message ?? ""))
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: nil)
            }
        }
    }
    /// 修改资讯投稿
    private func updateNewsContribute() -> Void {
        guard let contributeModel = self.contributeModel else {
            return
        }
        // 提交请求
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_提交中".localized)
        loadingAlert.show()
        self.submitBtn.isEnabled = false
        TSNewsNetworkManager.updateNews(news: contributeModel) { [weak self] (msg, status) in
            self?.submitBtn.isEnabled = true
            loadingAlert.dismiss()
            if status {
                // 修改成功，移除图片缓存
                if let fileIds = self?.contributeModel?.content_markdown?.ts_getCustomMarkdownImageId() {
                    TSWebEditorImageManager.default.deleteImages(fileIds: fileIds)
                }
                // 提交成功处理
                let resultAlert = TSIndicatorWindowTop(state: .success, title: "提示信息_投稿请求成功".localized)
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval) {
                    // 返回到进入资讯修改的界面
                    self?.barckToFront()
                }
                // 发送修改资讯成功的通知
                NotificationCenter.default.post(name: NSNotification.Name.ContributingNewsUpdated, object: contributeModel.newsId)
            } else {
                // 提交失败处理
                let resultAlert = TSIndicatorWindowTop(state: .faild, title: String(format: "%@: %@", "提示信息_提交失败".localized, msg ?? ""))
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: nil)
            }
        }
    }

    /// 返回到进入资讯修改的界面
    fileprivate func barckToFront() -> Void {
        if var childVCList = self.navigationController?.childViewControllers {
            for (index, childVC) in childVCList.enumerated() {
                if childVC is TSNewsWebEditorController {
                    childVCList.replaceSubrange(Range<Int>(uncheckedBounds: (lower: index, upper: childVCList.count)), with: [])
                    break
                }
            }
            self.navigationController?.setViewControllers(childVCList, animated: true)
        }
    }

    // MARK: - Delegate Function

    // MARK: - Notification
}

// MARK: - Extension - 封面点击图片获取

extension TSNewsContributeController {
    fileprivate func openCamera() {
        let isSuccess = TSSetUserInfoVC.checkCamearPermissions()
        guard isSuccess else {
            return
        }
        let cameraVC = TSImagePickerViewController.canCropCamera(cropType: .rectangle, finish: { [weak self] (image: UIImage) in
            self?.insertImage(image)
        })
        cameraVC.show()
    }
    fileprivate func openLibrary() {
        let isSuccess = TSSetUserInfoVC.PhotoLibraryPermissions()
        guard isSuccess else {
            return
        }
        let albumVC = TSImagePickerViewController.canCropAlbum(cropType: .rectangle) { [weak self] (image) in
            self?.insertImage(image)
        }
        albumVC.show()
    }

    /// 插入图片处理
    fileprivate func insertImage(_ image: UIImage) -> Void {
        // 上传图片网络请求
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "提示信息_封面上传中".localized)
        loadingAlert.show()
        TSUploadNetworkManager().uploadImage(image: image) { (fileId, _, status) in
            loadingAlert.dismiss()
            guard status, let fileId = fileId else {
                // 图片上传失败处理，待完成
                let faildAlert = TSIndicatorWindowTop(state: .faild, title: "提示信息_封面上传失败".localized)
                faildAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                return
            }
            // 图片上传成功
            self.contributeModel?.coverFileId = fileId
            let resultAlert = TSIndicatorWindowTop(state: .success, title: "提示信息_封面上传成功".localized)
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
        }
        // 当前展示修正
        // 使用backgroundImage，则需对image和title重置为nil；
        // 使用用iamge则需要对title重置为nil，且还需要对imageEdgeInsets和titleEdgeInsets进行归零处置
        self.coverBtn.setBackgroundImage(image, for: .normal)
        self.coverBtn.setImage(nil, for: .normal)
        self.coverBtn.setTitle(nil, for: .normal)
    }

}

// MARK: - TSCustomAcionSheetDelegate

extension TSNewsContributeController: TSCustomAcionSheetDelegate {
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
    }
}
