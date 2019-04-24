//
//  TSUploadCertificateVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  上传资料

import UIKit
import TZImagePickerController
import Photos

class TSUploadCertificateVC: TSTableViewController {
    /// 数据源
    var dataSouce: [UIImage] = []
    var currentRow: Int = -1
    /// 提交按钮
    let buttonForFinish: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("提交", for: .normal)
        button.setTitleColor(TSColor.normal.minor, for: .disabled)
        button.setTitleColor(TSColor.main.theme, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.isEnabled = false
        button.sizeToFit()
        return button
    }()
    /// 提示信息
    @IBOutlet weak var labelForPrompt: UILabel!
    /// 提示信息
    var promptString = "上传身份证正反面照片"
    /// 提交按钮点击事件
    var finishOperation: (([Int], [CGSize], TSIndicatorWindowTop?) -> Void)?
    /// 需要上传的图片最小张数。如果 dataSource 中的图片少于要求的张数，提交按钮无法点击
    var imageCountMin = 1
    /// 可以上传的图片的最大张数
    var imageCountMax = 2

    // MARK: - Lifecycle
    class func uploadVC() -> TSUploadCertificateVC {
        let sb = UIStoryboard(name: "TSUploadCertificateVC", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TSUploadCertificateVC") as! TSUploadCertificateVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    // MARK: - Custom user interface
    func setUI() {
        title = "上传资料"
        tableView.mj_header = nil
        tableView.mj_footer = nil
        view.backgroundColor = UIColor.white
        // 导航栏按钮
        buttonForFinish.addTarget(self, action: #selector(finishButtonTaped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonForFinish)
        // 提示信息
        labelForPrompt.text = promptString
    }

    // MARK: - Button click

    /// 点击了提交按钮
    func finishButtonTaped() {
        let alert = TSIndicatorWindowTop(state: .loading, title: "上传中")
        alert.show()
        // 上传图片获取图片 id
        TSUploadNetworkManager().upload(images: dataSouce, index: 0, finishIDs: []) { [weak self] (filesId: [Int]) in
            guard let weakSelf = self else {
                alert.dismiss()
                return
            }
            // 将图片 id 通过 block 返回
            var imageSize = [CGSize]()
            for image in weakSelf.dataSouce {
                if let cgImage = image.cgImage {
                    let size = CGSize(width: cgImage.width, height: cgImage.height)
                    imageSize.append(size)
                } else {
                    weakSelf.finishOperation?([], [], alert)
                    return
                }
            }
            weakSelf.finishOperation?(filesId, imageSize, alert)
        }
    }

    // MARK: - Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.width * 3 / 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 1.当图片的数小于 imageCountMin 时，提交按钮不可点击。
        buttonForFinish.isEnabled = !(dataSouce.count < imageCountMin)
        // 2.每当用户选择了一张图片，增加一个新 cell 供用户选择新的图片。
        var count = dataSouce.count + 1
        // 3.当已选图片张数大于等于 imageCountMax 时，不再增加新 cell。
        count = count >= imageCountMax ? imageCountMax : count
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSUploadCertificateCell.identifier, for: indexPath) as! TSUploadCertificateCell
        cell.delegate = self
        cell.currentRow = indexPath.row
        // 1.如果 dataSource 保存得有图片，就显示图片
        if indexPath.row < dataSouce.count {
            cell.buttonForImage.imageView?.contentMode = .scaleAspectFill
            cell.buttonForImage.setImage(dataSouce[indexPath.row], for: .normal)
        }
        // 3.设置 cell 的提示信息
        cell.labelForPrompt.text = indexPath.row == 0 ? "点击上传照片" : "继续上传"
        return cell
    }
}

extension TSUploadCertificateVC: TZImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TSUploadCertificateCellDelegate {

    func imageChoose(selectRow: Int) {
        self.currentRow = selectRow
        self.openLibrary()
    }

    private func openLibrary() {
        guard let imagePickerVC = TZImagePickerController(maxImagesCountTSType: 1, columnNumber: 4, delegate: self, pushPhotoPickerVc: true, square: true, shouldPick: true, topTitle: "认证图片选择")
            else {
                return
        }
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
        let infoDict = info as NSDictionary
        let type: String = infoDict.object(forKey: UIImagePickerControllerMediaType) as! String
        if type == "public.image" {
            let photo: UIImage = infoDict.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
            let photoOrigin: UIImage = photo.fixOrientation()
            if photoOrigin != nil {
                let lzImage = LZImageCropping()
                lzImage.cropSize = CGSize(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.width - 80)
                lzImage.image = photoOrigin
                lzImage.isRound = false
                lzImage.titleLabel.text = "认证图片选择"
                lzImage.didFinishPickingImage = {(image) -> Void in
                    guard let image = image else {
                        return
                    }
                    if self.dataSouce.count > self.currentRow {
                        self.dataSouce[self.currentRow] = image
                    } else {
                        self.dataSouce.append(image)
                    }
                    // 刷新界面
                    self.tableView.reloadData()
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
            if self.dataSouce.count > self.currentRow {
                self.dataSouce[self.currentRow] = photos[0]
            } else {
                self.dataSouce.append(photos[0])
            }
            // 刷新界面
            self.tableView.reloadData()
        } else {
            let resultAlert = TSIndicatorWindowTop(state: .faild, title: "图片选择异常,请重试!")
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
        }
    }
}
