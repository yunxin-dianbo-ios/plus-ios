//
//  CustomPHPreViewVC.swift
//  ImagePicker
//
//  Created by GorCat on 2017/7/8.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import Photos

class CustomPHPreViewVC: UIViewController, TSSettingImgPriceVCDelegate {

    /// 当前的下标
    var currentIndex = 0
    /// 初始化下标
    var initialIndex = 0

    // collection
    let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: PHPreviewCollectionLayout())

    // 图片 数据源
    var allAssets: [PHAsset] = []
    // 已选择的图片
    var selectedAssets: [PHAsset] = []
    // 是否显示支付配置按钮
    var isShowSettingPay = false
    // 支付配置信息
    var payInfo = [TSImgPrice]()
    // 导航栏右侧按钮
    let navRightBtn = TSTextButton.initWith(putAreaType: .top)

    /// 结束操作
    var finishBlock: (() -> Void)?
    /// 选择操作
    var chooseBlock: (() -> Void)?
    /// 页面消失
    var dismissBlock: (() -> Void)?

    // 工具栏
    let toolbar = PHPreviewToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - TSImagePickerUX.toolBarHeight - TSNavigationBarHeight - TSBottomSafeAreaHeight, width: UIScreen.main.bounds.width, height: TSImagePickerUX.toolBarHeight))

    // MARK: - Lifecycle
    init(currentIndex index: Int, assets: [PHAsset], isShowSettingPay: Bool, payInfo: [TSImgPrice]) {
        super.init(nibName: nil, bundle: nil)
        initialIndex = index
        allAssets = assets
        selectedAssets = assets
        self.isShowSettingPay = isShowSettingPay
        self.payInfo = payInfo
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        dismissBlock?()
        super.viewWillDisappear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // 滚动到指定位置
        collection.scrollToItem(at: IndexPath(item: initialIndex, section: 0), at: .left, animated: false)
        updateToolbar()
    }

    // MARK: - Custom user interface
    func setUI() {
        // 1.设置背景颜色
        view.backgroundColor = UIColor.white
        // 2.设置 collection
        setCollcetionUI()
        // 3.设置工具栏
        setToolbarUI()
        // 设置导航栏按钮
        if isShowSettingPay {
            setupNavRightBtn()
        }
    }

    func setupNavRightBtn() {
        let frameView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        navRightBtn.setTitle("收费选项", for: .normal)
        navRightBtn.addTarget(self, action: #selector(pushToPaySetting), for: .touchUpInside)
        frameView.addSubview(navRightBtn)
        // 6pt 设计尺寸
        let rightItem = UIBarButtonItem(customView: frameView)
        self.navigationItem.rightBarButtonItem = rightItem
        navRightBtn.frame = CGRect(x: 25, y: 0, width: navRightBtn.frame.width, height: navRightBtn.frame.height)
    }

    func updateToolbar() {
        // 1.设置 选择按钮
        let cell = collection.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? PreviewCollectionCell
        if let cell = cell {
            toolbar.buttonForChoose.isSelected = cell.isImageSelected
        }
        // 2.设置 完成按钮
        toolbar.buttonForFinish.setTitle("(\(selectedAssets.count)/\(allAssets.count))完成", for: .normal)

    }

    // MARK: - Data

    func setInfo(collectonCellModel: [PhotoCollectionCellModel], currentIndex index: Int) {
        currentIndex = index
    }

    // MARK: - 转场动画
    func showAnimation(cellFrame: CGRect, image: UIImage) {

    }

    func dismissAnimation() {

    }

    // MARK: - Public

    /// 设置完成操作
    func setFinish(operation: (() -> Void)?) {
        finishBlock = operation
    }

    /// 设置选择操作
    func setChoose(operation: (() -> Void)?) {
        chooseBlock = operation
    }

    /// 设置视图消失操作
    func setDismiss(operation: (() -> Void)?) {
        dismissBlock = operation
    }

    // MARK: - Delegate

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 1.计算当前坐标
        let newIndex = Int(round(scrollView.contentOffset.x / collection.frame.width))
        // 2.如果坐标和记录的不一样，就更新界面
        guard currentIndex != newIndex else {
            return
        }
        currentIndex = newIndex
        updateToolbar()
    }
}
