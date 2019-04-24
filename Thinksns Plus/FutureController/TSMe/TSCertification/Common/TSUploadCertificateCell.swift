//
//  TSUploadCertificateCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import Photos
import TZImagePickerController

protocol TSUploadCertificateCellDelegate: class {
    /// 返回按钮点击事件
    func imageChoose(selectRow: Int)
}

class TSUploadCertificateCell: UITableViewCell {

    static let identifier = "TSUploadCertificateCell"

    /// 代理
    weak var delegate: TSUploadCertificateCellDelegate?
    var currentRow: Int = -1
    /// 提示信息
    @IBOutlet weak var labelForPrompt: UILabel!
    /// 图片按钮
    @IBOutlet weak var buttonForImage: UIButton!
    /// 图片选择完成事件
    var operation: ((UIImage) -> Void)?
    /// 图片选择器
    var imagePicker: TSImagePickerViewController?
    /// 选择出来的照片数据
    var phAsset: [PHAsset]?

    /// 点击了图片按钮
    @IBAction func imageButtonTaped() {
        let isSuccess = TSSetUserInfoVC.PhotoLibraryPermissions()
        guard isSuccess else {
            return
        }
        if let delegate = delegate {
            delegate.imageChoose(selectRow: currentRow)
        }
    }
}
