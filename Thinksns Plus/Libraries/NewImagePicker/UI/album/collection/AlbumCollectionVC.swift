//
//  PhotoCollectionVC.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/23.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import Photos

class AlbumCollectionVC: UIViewController, ImagePickerDataUsable {

    /// 底部工具栏
    var toolbar: AlbumCollectionToolbar? = nil

    var cameraLocalIdentifier = ""

    /// 相册 collection
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: AlbumCollectionLayout())
    /// 相册标识
    var albumIdentifier: String?
    /// 相册数据源
    var dataSource: [PHAsset] = []

    /// 转场动画代理
    let animationManager = PreviewNavigationAnimationManager()

    /// 结束操作
    var finishBlock: (([UIImage], [PHAsset]) -> Void)?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        updataToolbarFinishButtonTitle()
        navigationController?.delegate = nil
    }

    // MARK: - Custom user interface

    func setUI() {
        guard let isToolbarShow = isToolBarShow() else {
            return
        }

        // 1.添加图片选择器视图控制器
        setCollectionUI(isToolbarShow: isToolbarShow)

        // 2.添加底部工具栏
        setToolbarUI(isToolbarShow: isToolbarShow)

        // 3.添加取消按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelButtonTaped))
    }

    /// 更新工具栏的完成按钮的标题
    func updataToolbarFinishButtonTitle() {
        guard let nav = nav(), let toolbar = toolbar else {
            return
        }
        let selectCount = nav.selectedImages.count
        let maxCount = nav.maxSelectedCount
        toolbar.buttonForFinish.setTitle("(\(selectCount)/\(maxCount))完成", for: .normal)
        // 如果一张图片都没选，按钮的点击状态是不可点击
        toolbar.buttonForFinish.isEnabled = !(selectCount == 0)
    }

    // MARK: - Data
    func setInfo(albumModel model: AlbumModel) {
        // 1.设置标题
        title = model.title

        // 2.更新 collection dataSource
        updateDataSource(albumModel: model)

        // 3.刷新 collection
        collectionView.reloadData()
    }

    // MARK: - Button click

    /// 取消按钮点击事件
    func cancelButtonTaped() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Public

    /// 设置完成操作
    func setFinish(operation: (([UIImage], [PHAsset]) -> Void)?) {
        finishBlock = operation
    }

    func catchImageFinish() {
        PhotosDataManager.cover(assets: [dataSource[1]], disPlayWidth: UIScreen.main.bounds.width) { [weak self] (images: [UIImage]) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.finishBlock?(images, [weakSelf.dataSource[1]])
            weakSelf.dismiss(animated: true, completion: nil)
        }
    }

}
