//
//  PhotoCollectionVC+UICollectionView.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/25.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

extension AlbumCollectionVC:  UICollectionViewDataSource, UICollectionViewDelegate, AlbumCollectionCellDelegate {

    // MARK: - UI

    /// 设置 collection 视图
    func setCollectionUI(isToolbarShow: Bool) {
        // 1.计算 collection 的 frame
        let toolbarHeight = isToolbarShow ? TSImagePickerUX.toolBarHeight : 0
        let width = view.frame.width
        let height = view.frame.height - toolbarHeight - 64
        collectionView.frame = CGRect(x: 0, y: 0, width: width, height: height)

        // 2.设置其它属性
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UINib(nibName: "AlbumCollectionCell", bundle: nil), forCellWithReuseIdentifier: AlbumCollectionCell.identifer)
        collectionView.register(UINib(nibName: "CameraCell", bundle: nil), forCellWithReuseIdentifier: CameraCell.identifer)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self

        if collectionView.superview == nil {
            view.addSubview(collectionView)
        }
    }

    // MARK: - Data

    // 更新 collection dataSource
    func updateDataSource(albumModel: AlbumModel) {
        dataSource = []
        // 保存相册 identity
        albumIdentifier = albumModel.identifier

        // 将 PHFetchResult<PHAsset> 转换成 [PHAsset]
        guard let assets = albumModel.imageAssets else {
            return
        }
        for i in 0..<assets.count {
            let asset = assets[i]
            dataSource.append(asset)
        }
        dataSource.reverse()

        // 判断相册是不是“所有图片”，如果是，增加一个“相机图片”的数据
        if albumModel.title == "所有图片" {
            let cameraAsset = PHAsset()
            cameraLocalIdentifier = cameraAsset.localIdentifier
            dataSource.insert(cameraAsset, at: 0)
        }

        collectionView.reloadData()
    }

    // MARK: - Delegate

    // MARK: - AlbumCollectionCellDelegate

    /// 点击了选择按钮
    func cell(_ cell: AlbumCollectionCell, didClickSelectButton selectButton: UIButton) {
        let indexPath = collectionView.indexPath(for: cell)
        guard let index = indexPath?.row, let nav = nav() else {
            return
        }
        guard nav.selectedImages.count < nav.maxSelectedCount || selectButton.isSelected == true else {
            CGLog(message: "已经选择了\(nav.selectedImages.count)张")
            return
        }
        // 1.更改按钮的选中状态
        selectButton.isSelected = !selectButton.isSelected
        // 2.获取图片的信息
        let asset = dataSource[index]

        if selectButton.isSelected {
            // 3.如果是选中状态，保存图片
            nav.selectedImages.append(asset)
        } else {
            // 4.如果是非选中状态，就移除图片
            let selectedIndex = nav.selectedImages.index(of: asset)
            nav.selectedImages.remove(at: selectedIndex!)
        }

        // 5.更新工具栏完成按钮的标题
        updataToolbarFinishButtonTitle()
    }

    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let asset = dataSource[indexPath.row]

        // 1.第一个 cell 显示相机图标
        if asset.localIdentifier == cameraLocalIdentifier {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraCell.identifer, for: indexPath)
            return cell
        }

        // 2.其他 cell 显示相册图片
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCollectionCell.identifer, for: indexPath) as! AlbumCollectionCell

        cell.setInfo(asset)
        cell.delegate = self

        // 2.1 设置勾勾选择按钮
        if let isToolBarShow = isToolBarShow() {
            // 只用选择一张图时，不显示勾勾选择按钮
            cell.buttonForSelect.isHidden = !isToolBarShow
        }
        if let nav = nav() {
            // 判断图片是否已经被选择了
            let isSelected = nav.selectedImages.filter { $0 == asset }
            cell.buttonForSelect.isSelected = !isSelected.isEmpty
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let asset = dataSource[indexPath.row]

        // 1.如果是相机按钮，跳转相机
        if asset.localIdentifier == cameraLocalIdentifier {
            pushToCamera()
            return
        }

        // 2.通过是否显示 toolbar 判断图片的选择张数（只能选单张图时，不显示 toolbar）
        guard let nav = nav() else {
            return
        }

        if nav.isToolBarShow == true {
            // 3.可选择多张图，跳转到预览视图

            // 3.1 剔除相机
            let previewData = dataSource.filter { $0.localIdentifier != cameraLocalIdentifier}

            // 3.2 计算选中图片的坐标
            let currentIndex = previewData.index(of: asset)!

            let preview = PHPreviewVC(currentIndex: currentIndex, assets: previewData)
            preview.setFinish(operation: finishBlock)
            navigationController?.delegate = animationManager
            navigationController?.pushViewController(preview, animated: true)
        } else {

            // 4.只能选一张图，执行结束操作
//            var selectedImage: UIImage?
//            print(asset.localIdentifier)
            // 4.1 获取选中的图片
            PhotosDataManager.conver(asset: asset, disPlayWidth: view.frame.width, complete: { [weak self] (image) in
                guard let image = image else {
                    return
                }
                // 4.2 执行返回操作
                self?.finishBlock?([image], [asset])
            })
        }
    }

    // MARK: - 跳转
    func pushToCamera() {
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
        case .notDetermined:
            // 3.还没有授权，可以询问一次
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                print("camera", granted)
            })
        case .authorized:
            // 4.有授权，前往相机
            // 4.1 创建相机视图
            let camera = CameraVC.camera()
            camera.saveImage = true
            camera.superVC = self

            // 4.2 设置 相机 结束操作
            camera.setFinish { [weak self, weak camera] (catchImage) in
                guard let weakSelf = self, let weakCamera = camera else {
                    return
                }
                // 5. 更新数据
                // 5.1 获取相册数据管理类
                guard let dataManager = weakSelf.dataManager(), let albumIdentifier = weakSelf.albumIdentifier else {
                    return
                }

                // 5.2 刷新相册数据
                dataManager.updateAlbumListData()
                let album = dataManager.albums?.filter { $0.identifier == albumIdentifier }.first
                guard let albumModel = album else {
                    return
                }

                // 5.3 更新 dataSource
                weakSelf.updateDataSource(albumModel: albumModel)
                weakCamera.dismiss(animated: true, completion: {
                    weakCamera.superVC?.catchImageFinish()
                })
            }
            present(camera, animated: true, completion: nil)
        }
    }

}

class AlbumCollectionLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()

        // 1.定义常量
        let spacing: CGFloat = 5 // item 间隔
        let lineCount = 4 // 每行 item 的个数

        // 2.计算item的宽度和高度,以及设置item的宽度和高度
        let itemWidth = (collectionView!.bounds.width - spacing * CGFloat(lineCount - 1)) / CGFloat(lineCount)
        itemSize = CGSize(width: itemWidth, height: itemWidth)

        // 3.设置其他属性
        minimumInteritemSpacing = spacing
        minimumLineSpacing = spacing

        // 4.设置内边距
        sectionInset = UIEdgeInsets(top: spacing, left: 0, bottom: spacing, right: 0)
    }

}
