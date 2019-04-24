//
//  TSNewsTagSelectCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 14/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯投稿中标签选择的cell

import UIKit

protocol TSNewsTagSelectCellProtocol: class {
    /// 标签cell上的删除图标点击回调
    func didDeleteBtnClickIn(tagCell: TSNewsTagSelectCell) -> Void
}
extension TSNewsTagSelectCellProtocol {
    /// 标签cell上的删除图标点击回调
    func didDeleteBtnClickIn(tagCell: TSNewsTagSelectCell) -> Void {
    }
}

class TSNewsTagSelectCell: UICollectionViewCell {

    // MARK: - Internal Property
    /// 回调
    weak var delegate: TSNewsTagSelectCellProtocol?
    var deleteBtnClickAction: ((_ tagCell: TSNewsTagSelectCell) -> Void)?
    /// indexPath
    var indexPath: IndexPath?

    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    var isRemovable: Bool = false {
        didSet {
            self.removeIcon.isHidden = !isRemovable
        }
    }
    override var isSelected: Bool {
        didSet {
            let bgColor = isSelected ? TSColor.main.theme.withAlphaComponent(0.15) : UIColor(hex: 0xf5f5f5)
            self.contentView.backgroundColor = bgColor
        }
    }

    // MARK: - Private Property
    fileprivate weak var titleLabel: UILabel!       // 标题按钮
    fileprivate weak var removeIcon: UIButton!   // 可移除标记

    // MARK: - Internal Function

    // MARK: - Initialize Function
    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        self.contentView.backgroundColor = TSColor.inconspicuous.background
        // 1. titleLaebl
        let titleLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: UIColor(hex: 0x666666), alignment: .center)
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        self.titleLabel = titleLabel
        // 2. deleteIcon
        let deleteIcon = UIButton(type: .custom)
        self.contentView.addSubview(deleteIcon)
        deleteIcon.setImage(UIImage(named: "img_camera_close"), for: .normal)
        deleteIcon.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        deleteIcon.isHidden = true  // 默认隐藏
        deleteIcon.addTarget(self, action: #selector(deleteIconClick(_:)), for: .touchUpInside)
        deleteIcon.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.contentView.snp.leading)
            make.centerY.equalTo(self.contentView.snp.top)
            make.width.height.equalTo(20)   // 增大响应区域，但配合contentEdgeInsets对图片显示区域进行限定
        }
        self.removeIcon = deleteIcon
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应
    @objc fileprivate func deleteIconClick(_ button: UIButton) -> Void {
        self.delegate?.didDeleteBtnClickIn(tagCell: self)
        self.deleteBtnClickAction?(self)
    }
}
