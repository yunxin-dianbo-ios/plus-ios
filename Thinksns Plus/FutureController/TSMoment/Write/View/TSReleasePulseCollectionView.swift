//
//  TSReleaseDynamicCollectionView.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  展示图片的collectionView

import UIKit

protocol didselectCellDelegate: NSObjectProtocol {
    /// 点击了进入相册按钮 最小为0
    func didSelectCell(index: Int)

    /// 点击了付费信息按钮
    func didSelectedPayInfoBtn(btn: UIButton)
}

enum PayInfoType: Int {
    case not = 0
    case edit
    case lock
}

class TSReleasePulseCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {

    // cell个数
    let cellCount: CGFloat = 4.0
    // 间距
    let spacing: CGFloat = 5.0
    // 边框宽度
    let frameWidth: CGFloat = 0.5
    // 最大图片数量
    var maxImageCount: Int = 0
    // 代理
    weak var didselectCellDelegate: didselectCellDelegate? = nil
    var imageDatas: [AnyObject] = Array(arrayLiteral: UIImage(named: "IMG_edit_photo_frame")!)
    var imagePHAssets: [AnyObject] = Array()
    var payInfoArray: Array<TSImgPrice?>!
    /// 是否开启设置付费
    var shoudSetPayInfo: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.dataSource = self
        self.register(TSReleasePulseCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.size.width - 40 - spacing * 3
        let cellSize = width / cellCount
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing

        self.collectionViewLayout = layout
        self.reloadData()
    }

    // MARK: - CollectionViewMethod
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageDatas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TSReleasePulseCollectionViewCell
        cell?.image = imageDatas[indexPath.row]
        let payInfo = payInfoArray[indexPath.row]
        // 付费信息设置按钮点击
        cell?.payinfoSetBtn.tag = indexPath.row
        cell?.payBtnBlock = {[weak self](btn) in
            self?.didselectCellDelegate?.didSelectedPayInfoBtn(btn: btn)
        }
        if payInfo == nil || self.shoudSetPayInfo == false {
            cell?.payinfoSetBtn.isHidden = true
        } else {
            cell?.payinfoSetBtn.isHidden = false
            if payInfo?.paymentType == .not {
                cell?.payinfoSetBtn.isSelected = false
                cell?.payinfoSetBtn.setTitle("", for: .selected)
            } else if payInfo?.paymentType == .download || payInfo?.paymentType == .read {
                cell?.payinfoSetBtn.isSelected = true
                cell?.payinfoSetBtn.setTitle(String((payInfo?.sellingPrice)!), for: .selected)
            }
        }
        // 如果不是最大张数，最后一个item显示的是+按钮
        if indexPath.row == (imageDatas.count - 1) && imageDatas.count < maxImageCount {
            cell?.layer.borderColor = TSColor.inconspicuous.highlight.cgColor
            cell?.layer.borderWidth = frameWidth
            cell?.payinfoSetBtn.isHidden = true
        }
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 点击进入相册
        self.didselectCellDelegate?.didSelectCell(index: indexPath.row)
    }
}
