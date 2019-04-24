//
//  TSPersonalPreviewVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import Kingfisher

class TSPersonalPreviewVC: UITableViewController {
    /// 真实姓名
    @IBOutlet weak var labelForName: UILabel!
    /// 身份证号码
    @IBOutlet weak var labelForIdcard: UILabel!
    /// 手机号
    @IBOutlet weak var labelForPhone: UILabel!
    /// 认证描述
    @IBOutlet weak var labelForDescription: UILabel!
    @IBOutlet weak var imageA: UIImageView!
    @IBOutlet weak var imageB: UIImageView!

    /// 是否显示提示信息
    var isShowPrompt = false

    /// 数据模型
    private var _model = TSUserCertificateObject()
    var model: TSUserCertificateObject {
        set(newValue) {
            _model = newValue

            // 为了防止视图尚未初始化，延迟 0.3s
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.labelForName.text = newValue.name
                weakSelf.labelForIdcard.text = newValue.number
                weakSelf.labelForPhone.text = newValue.phone
                weakSelf.labelForDescription.text = newValue.desc
                weakSelf.imageA.kf.setImage(with: URL(string: newValue.files.first!.storageIdentity.imageUrl()))
                weakSelf.imageB.kf.setImage(with: URL(string: newValue.files.last!.storageIdentity.imageUrl()))
                weakSelf.tableView.reloadData()
            }
        }
        get {
            return _model
        }
    }

    // MARK: - Lifecycle
    class func previewVC() -> TSPersonalPreviewVC {
        let sb = UIStoryboard(name: "TSPersonalCertification", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TSPersonalPreviewVC") as! TSPersonalPreviewVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    @IBAction func buttonAAction(_ sender: UIButton) {
        guard let imageObj = model.files.first else {
            return
        }
        guard let imageObj2 = model.files.last else {
            return
        }
        let frameA = imageA.convert(imageA.bounds, to: nil)
        let frameB = imageB.convert(imageB.bounds, to: nil)
        let picturePreview = TSPicturePreviewVC(objects: [imageObj, imageObj2], imageFrames: [frameA, frameB], images: [imageA.image, imageB.image], At: 0)
        picturePreview.show()
    }

    @IBAction func buttonBAction(_ sender: UIButton) {
        guard let imageObj = model.files.first else {
            return
        }
        guard let imageObj2 = model.files.last else {
            return
        }
        let frameA = imageA.convert(imageA.bounds, to: nil)
        let frameB = imageB.convert(imageB.bounds, to: nil)
        let picturePreview = TSPicturePreviewVC(objects: [imageObj, imageObj2], imageFrames: [frameA, frameB], images: [imageA.image, imageB.image], At: 1)
        picturePreview.show()
    }

    // MARK: - Custom user interface
    func setUI() {
        title = "个人认证"
        view.backgroundColor = UIColor.white
        tableView.mj_header = nil
        tableView.mj_footer = nil
        tableView.estimatedRowHeight = 54

        imageA.contentScaleFactor = UIScreen.main.scale
        imageA.contentMode = .scaleAspectFill
        imageA.autoresizingMask = UIViewAutoresizing.flexibleHeight
        imageA.clipsToBounds = true

        imageB.contentScaleFactor = UIScreen.main.scale
        imageB.contentMode = .scaleAspectFill
        imageB.autoresizingMask = UIViewAutoresizing.flexibleHeight
        imageB.clipsToBounds = true
    }
    // MARK: - Delegate

    // MARK: UITableViewDelegate, UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 判断是否需要隐藏提示信息
        if !isShowPrompt && indexPath.row == 0 {
            return 0
        }
        if indexPath.row == 5 {
            return (UIScreen.main.bounds.width - 130) * 0.5 * 3 / 4 + 40
        }
        return UITableViewAutomaticDimension
    }

}
