//
//  TSPhotoPreviewVC.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/15.
//  Copyright © 2017年 GorCat. All rights reserved.
//
//  预览 视图控制器

import UIKit
import Photos

class PHPreviewVC: UIViewController, ImagePickerDataUsable {

    /// 当前的下标
    var currentIndex = 0
    /// 初始化下标
    var initialIndex = 0

    // collection
    let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: PHPreviewCollectionLayout())

    // 图片 数据源
    var assetDataSource: [PHAsset] = []

    /// 结束操作
    var finishBlock: (([UIImage], [PHAsset]) -> Void)?

    // 工具栏
    let toolbar = PHPreviewToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - TSImagePickerUX.toolBarHeight, width: UIScreen.main.bounds.width, height: TSImagePickerUX.toolBarHeight))

    // MARK: - Lifecycle
    init(currentIndex index: Int, assets: [PHAsset]) {
        super.init(nibName: nil, bundle: nil)
        initialIndex = index
        assetDataSource = assets
    }

    deinit {
        print("deinit PHPreviewVC")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // 滚动到指定位置
        collection.scrollToItem(at: IndexPath(item: initialIndex, section: 0), at: .left, animated: false)
        updateToolbar()
        toolbar.frame = CGRect(x: 0, y: self.view.frame.height - TSImagePickerUX.toolBarHeight - TSBottomSafeAreaHeight, width: UIScreen.main.bounds.width, height: TSImagePickerUX.toolBarHeight)
    }

    // MARK: - Custom user interface

    func setUI() {
        // 1.设置背景颜色
        view.backgroundColor = UIColor.white

        // 2.设置 collection
        setCollcetionUI()

        // 3.设置工具栏
        setToolbarUI()

    }

    func updateToolbar() {
        guard let nav = nav() else {
            return
        }
        // 1.设置 选择按钮
        let cell = collection.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? PreviewCollectionCell
        if let cell = cell {
            toolbar.buttonForChoose.isSelected = cell.isImageSelected
        }
        // 2.设置 完成按钮
        toolbar.buttonForFinish.setTitle("(\(nav.selectedImages.count)/\(nav.maxSelectedCount))完成", for: .normal)
        // 如果一张图片都没选，按钮的点击状态是不可点击
        toolbar.buttonForFinish.isEnabled = !(nav.selectedImages.count == 0)
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
    func setFinish(operation: (([UIImage], [PHAsset]) -> Void)?) {
        finishBlock = operation
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
