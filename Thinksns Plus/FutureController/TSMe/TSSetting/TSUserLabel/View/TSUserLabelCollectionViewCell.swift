//
//  TSUserLabelCollectionViewCell.swift
//  date
//
//  Created by Fiction on 2017/7/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
/// 【选择标签】collectionViewcell

import UIKit

protocol TSUserLabelCollectionViewCellProtocol: class {
    /// 用户标签Cell上的delete按钮点击回调
    func didDeleteBtnClickInLabelCell(_ labelCell: TSUserLabelCollectionViewCell) -> Void
}
extension TSUserLabelCollectionViewCellProtocol {
    /// 用户标签Cell上的delete按钮点击回调
    func didDeleteBtnClickInLabelCell(_ labelCell: TSUserLabelCollectionViewCell) -> Void {
    }
}

class TSUserLabelCollectionViewCell: UICollectionViewCell {
    /// 展示的标签的label
    let contentViewLabel: UILabel = UILabel()
    /// 展示删除按钮的图片
    let deleteImage: UIButton = UIButton(type: .custom)
    /// indexPath
    var indexPath: IndexPath?
    /// 回调
    weak var delegate: TSUserLabelCollectionViewCellProtocol?
    var delteBtnClickAction: ((_ labelCell: TSUserLabelCollectionViewCell) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = TSColor.inconspicuous.background

        contentViewLabel.font = UIFont.systemFont(ofSize: TSFont.Button.keyboardRight.rawValue)
        contentViewLabel.textColor = TSColor.normal.content
        contentViewLabel.textAlignment = .center
        deleteImage.setImage(#imageLiteral(resourceName: "img_camera_close"), for: .normal)
        deleteImage.setImage(#imageLiteral(resourceName: "img_camera_close"), for: .highlighted)
        deleteImage.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        deleteImage.addTarget(self, action: #selector(deleteImageBtnClick(_:)), for: .touchUpInside)

        self.contentView.addSubview(contentViewLabel)
        self.contentView.addSubview(deleteImage)

        contentViewLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        deleteImage.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.contentView.snp.left)
            make.centerY.equalTo(self.contentView.snp.top)
            make.width.height.equalTo(20)   // 注：增大了响应区域，实际图片是高宽为10的显示区域(配合contentEdgeInsets)
        }
    }

    /// 是否点过这个itme，如果有就改变其颜色
    func isTouchItem(isTouch: Bool) {
        if isTouch {
            self.contentView.backgroundColor = TSColor.main.theme.withAlphaComponent(0.15)
            self.contentViewLabel.textColor = TSColor.main.theme
        } else {
            self.contentView.backgroundColor = TSColor.inconspicuous.background
            self.contentViewLabel.textColor = TSColor.normal.content
        }
    }

    /// 是否展示删除图标（在用户已选择标签才用得着）
    func deleteImageShow(isShow: Bool) {
        self.deleteImage.isHidden = !isShow
    }
    /// 删除按钮点击响应
    @objc fileprivate func deleteImageBtnClick(_ button: UIButton) -> Void {
        print("deleteImageBtnClick")
        self.delegate?.didDeleteBtnClickInLabelCell(self)
        self.delteBtnClickAction?(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
