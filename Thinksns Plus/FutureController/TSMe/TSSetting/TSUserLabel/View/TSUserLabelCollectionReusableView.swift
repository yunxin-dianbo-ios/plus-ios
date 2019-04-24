//
//  TSUserLabelCollectionReusableView.swift
//  Pods
//
//  Created by Fiction on 2017/8/1.
//
// 【选择标签】collectionView扩展视图

import UIKit

class TSUserLabelCollectionReusableView: UICollectionReusableView {
    /// 对应类别model的名字
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.titleLabel.frame = CGRect(x: 15, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.titleLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.sectionTitle.rawValue)
        self.titleLabel.textAlignment = .left
        self.titleLabel.textColor = TSColor.normal.secondary
        self.addSubview(self.titleLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 修改方法
    /// 修改头视图显示什么字符串
    func setTitle(text: String) {
        self.titleLabel.text = text
    }
}
