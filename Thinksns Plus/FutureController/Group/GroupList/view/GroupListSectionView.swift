//
//  GroupListSectionView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子列表 section view

import UIKit

protocol GroupListSectionViewDelegate: class {
    /// 点击了右边按钮
    func groupListSectionView(_ view: GroupListSectionView, didSelectedRightButton type: GroupListSectionViewModel.RightType)

}

class GroupListSectionView: UITableViewHeaderFooterView {

    static let identifier = "GroupListSectionView"

    /// 代理
    weak var delegate: GroupListSectionViewDelegate?
    /// 左边标题 label
    let titleLabel = UILabel()
    /// 右边按钮
    let rightButton = UIButton(type: .custom)
    /// 分割线
    let seperator = UIView()

    /// 数据
    var model = GroupListSectionViewModel() {
        didSet {
            loadModel()
        }
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(titleLabel)
        contentView.addSubview(rightButton)
        contentView.addSubview(seperator)
    }

    func loadModel() {
        // 1.标题 label
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = UIColor(hex: 0x999999)
        titleLabel.text = model.title
        titleLabel.sizeToFit()
        let titleY = (contentView.frame.height - titleLabel.size.height) / 2
        titleLabel.frame = CGRect(origin: CGPoint(x: 10, y: titleY), size: titleLabel.size)

        // 2.右边按钮
        var title = ""
        var image = ""
        rightButton.isHidden = false
        switch model.rightType {
        case .change:
            title = " 换一换"
            image = "IMG_ico_circle_exchange"
            rightButton.semanticContentAttribute = .forceLeftToRight
        case .seeAll:
            if model.cellModels.count == 0 {
                title = "查看全部圈子"
                image = "IMG_ic_arrow_smallgrey"
            } else if model.cellModels.count >= 5 {
                title = "查看更多"
                image = "IMG_ic_arrow_smallgrey"
            } else {
                title = ""
                image = ""
                rightButton.isHidden = true
            }

            rightButton.semanticContentAttribute = .forceRightToLeft
        }
        rightButton.setTitle(title, for: .normal)
        rightButton.setTitleColor(UIColor(hex: 0x999999), for: .normal)
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        rightButton.setImage(UIImage(named: image), for: .normal)
        rightButton.addTarget(self, action: #selector(rightButtonTaped(_:)), for: .touchUpInside)
        rightButton.sizeToFit()
        let rightX = UIScreen.main.bounds.width - rightButton.size.width - 10
        let rightY = (contentView.height - rightButton.size.height) / 2
        rightButton.frame = CGRect(origin: CGPoint(x: rightX, y: rightY), size: rightButton.size)

        // 3.分割线
        seperator.backgroundColor = UIColor(hex: 0xededed)
        seperator.frame = CGRect(x: 0, y: 35, width: UIScreen.main.bounds.width, height: 1)
    }

    /// 点击了右边按钮
    func rightButtonTaped(_ sender: UIButton) {
        delegate?.groupListSectionView(self, didSelectedRightButton: model.rightType)
    }

}
