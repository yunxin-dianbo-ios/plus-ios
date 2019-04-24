//
//  TSReleaseDynamicCollectionViewCell.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 发布动态图片展示cell

import UIKit
import Photos

class TSReleasePulseCollectionViewCell: UICollectionViewCell {
    var payBtnBlock: ((UIButton) -> Void)?

    /// 支付信息视图
    weak var payInfoImg: UIImageView!
    /// 蒙层
//    var coverView = UIView(frame: CGRect.zero)
    /// GIF标示
    var gifIdentityView = UIImageView(frame: CGRect.zero)
    /// 支付操作按钮
    var payinfoSetBtn = UIButton(frame: CGRect.zero)
    /// 是否显示动态图片
    var gifImageActive: Bool = false
    /// 可以直接传UIImage，但是需要提前设置好GIF表示
    /// 或者传PHAsset，但是这样子会有性能问题，刷新的时候会闪动
    public var image: AnyObject? {
        didSet {
            if image is UIImage {
                imageView.image = image as? UIImage
                if imageView.image?.TSImageMIMEType == kUTTypeGIF as String {
                    self.gifIdentityView.isHidden = false
                } else {
                    self.gifIdentityView.isHidden = true
                }
            } else {
                let asset = (self.image as? PHAsset)!
                // 判断是不是GIF
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = false
                manager.requestImageData(for: asset, options: option) { (imageData, type, orientation, info) in
                    DispatchQueue.main.async {
                        if type == kUTTypeGIF as String {
                            self.gifIdentityView.isHidden = false
                            // 动图
                            var image: UIImage!
                            if self.gifImageActive == true {
                                image = UIImage.sd_tz_animatedGIF(with: imageData)
                            } else {
                                image = UIImage(data: imageData!)
                            }
                            self.imageView.image = image
                        } else {
                            let image = UIImage.init(data: imageData!)
                            self.imageView.image = image
                            self.gifIdentityView.isHidden = true
                        }
                    }
                }
            }
        }
    }
    private var imageView: UIImageView

    override init(frame: CGRect) {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        gifIdentityView.frame = CGRect(x: self.width - 25, y: self.height - 15, width: 25, height: 15)
        gifIdentityView.backgroundColor = UIColor.clear
        gifIdentityView.image = UIImage(named: "pic_gif")
        contentView.addSubview(gifIdentityView)
        gifIdentityView.isHidden = true
        payinfoSetBtn.frame = CGRect(x: 0, y: self.height - 30, width: self.width, height: 30)
        payinfoSetBtn.backgroundColor = UIColor(white: 0, alpha: 0.2)
        payinfoSetBtn.set(font: UIFont.systemFont(ofSize: 12))
        payinfoSetBtn.setTitleColor(UIColor.white, for: .normal)
        payinfoSetBtn.isHidden = true
        payinfoSetBtn.setImage(UIImage(named: "IMG_edit_pen"), for: .normal)
        payinfoSetBtn.setTitle("设置金额", for: .normal)
        payinfoSetBtn.setImage(UIImage(named: "ico_coins"), for: .selected)
        payinfoSetBtn.setTitle("设置金额", for: .selected)
        payinfoSetBtn.addTarget(self, action: #selector(didSelectedPayInfoBtn(btn:)), for: .touchUpInside)
        contentView.addSubview(payinfoSetBtn)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.contentView.bounds
    }

    func didSelectedPayInfoBtn(btn: UIButton) {
        self.payBtnBlock?(btn)
    }
}

extension TSReleasePulseCollectionViewCell {
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        let size = CGSize(width: asset.pixelWidth / 10, height: asset.pixelHeight / 10)
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: option, resultHandler: {(result, _) -> Void in
            thumbnail = result!
        })
        return thumbnail
    }
}
