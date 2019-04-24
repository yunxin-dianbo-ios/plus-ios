//
//  TSEnterprisePreviewVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  企业认证

import UIKit
import Kingfisher

class TSEnterprisePreviewVC: TSTableViewController {

    /// 机构名称
    @IBOutlet weak var labelForName: UILabel!
    /// 机构地址
    @IBOutlet weak var labelForAdress: UILabel!
    /// 负责人
    @IBOutlet weak var labelForManager: UILabel!
    /// 身份证号码
    @IBOutlet weak var labelForIdcard: UILabel!
    /// 负责人电话
    @IBOutlet weak var labelForPhone: UILabel!
    /// 认证描述
    @IBOutlet weak var labelForDescription: UILabel!

    @IBOutlet weak var imageViewB: UIImageView!
    @IBOutlet weak var imageViewA: UIImageView!
    /// 是否显示提示信息
    var isShowPrompt = false

    /// 数据模型
    var model = TSUserCertificateObject() {
        didSet {
            // 为了防止视图尚未初始化，延迟 0.3s
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.labelForName.text = weakSelf.model.orgName
                weakSelf.labelForAdress.text = weakSelf.model.orgAddress
                weakSelf.labelForManager.text = weakSelf.model.name
                weakSelf.labelForIdcard.text = weakSelf.model.number
                weakSelf.labelForPhone.text = weakSelf.model.phone
                weakSelf.labelForDescription.text = weakSelf.model.desc
                weakSelf.imageViewA.kf.setImage(with: URL(string: weakSelf.model.files.first!.storageIdentity.imageUrl()))
                weakSelf.imageViewB.kf.setImage(with: URL(string: weakSelf.model.files.last!.storageIdentity.imageUrl()))
                weakSelf.tableView.reloadData()
            }
        }
    }

    // MARK: - Lifecycle
    class func previewVC() -> TSEnterprisePreviewVC {
        let sb = UIStoryboard(name: "TSEnterpriseCertification", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TSEnterprisePreviewVC") as! TSEnterprisePreviewVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    @IBAction func imageBtnAAction(_ sender: UIButton) {
        guard let imageObj = model.files.first else {
            return
        }
        guard let imageObj2 = model.files.last else {
            return
        }
        let frameA = imageViewA.convert(imageViewA.bounds, to: nil)
        let frameB = imageViewB.convert(imageViewB.bounds, to: nil)
        let picturePreview = TSPicturePreviewVC(objects: [imageObj, imageObj2], imageFrames: [frameA, frameB], images: [imageViewA.image, imageViewB.image], At: 0)
        picturePreview.show()
    }

    @IBAction func imageBtnBAction(_ sender: UIButton) {
        guard let imageObj = model.files.first else {
            return
        }
        guard let imageObj2 = model.files.last else {
            return
        }
        let frameA = imageViewA.convert(imageViewA.bounds, to: nil)
        let frameB = imageViewB.convert(imageViewB.bounds, to: nil)
        let picturePreview = TSPicturePreviewVC(objects: [imageObj, imageObj2], imageFrames: [frameA, frameB], images: [imageViewA.image, imageViewB.image], At: 1)
        picturePreview.show()
    }

    // MARK: - Custom user interface
    func setUI() {
        title = "企业认证"
        view.backgroundColor = UIColor.white
        tableView.mj_header = nil
        tableView.mj_footer = nil
        tableView.estimatedRowHeight = 54

        imageViewA.contentScaleFactor = UIScreen.main.scale
        imageViewA.contentMode = .scaleAspectFill
        imageViewA.autoresizingMask = UIViewAutoresizing.flexibleHeight
        imageViewA.clipsToBounds = true

        imageViewB.contentScaleFactor = UIScreen.main.scale
        imageViewB.contentMode = .scaleAspectFill
        imageViewB.autoresizingMask = UIViewAutoresizing.flexibleHeight
        imageViewB.clipsToBounds = true
    }

    // MARK: - Delegate

    // MARK: UITableViewDelegate, UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 判断是否需要隐藏提示信息
        if !isShowPrompt && indexPath.row == 0 {
            return 0
        }
        if indexPath.row == 7 {
            return (UIScreen.main.bounds.width - 130) * 0.5 * 3 / 4 + 40
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}
