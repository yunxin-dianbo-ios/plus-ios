//
//  RankListPreviewCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  排行版总览 cell

import UIKit

class RankListPreviewCell: UITableViewCell {

    static let identifier = "RankListPreviewCell"

    /// 标题
    var labelForTitle = UILabel()
    /// 全部
    var labelForDetail = UILabel()
    /// 箭头
    var imageForDetail = UIImageView()
    /// 头像+姓名 collection
    var collection: UICollectionView!

    /// 数据
    var cellModel: RankListPreviewCellModel?

    // MARK: - Lifecycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - UI
    func setUI() {
        /// 标题
        labelForTitle.font = UIFont.systemFont(ofSize: 15)
        labelForTitle.textColor = TSColor.main.content
        labelForTitle.numberOfLines = 1
        contentView.addSubview(labelForTitle)
        labelForTitle.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(15)
            make.right.equalTo(-100)
        }
        // "全部" label
        labelForDetail.text = "全部"
        labelForDetail.font = UIFont.systemFont(ofSize: 12)
        labelForDetail.textColor = TSColor.normal.minor
        contentView.addSubview(labelForDetail)
        labelForDetail.snp.makeConstraints { (make) in
            make.right.equalTo(-33)
            make.bottom.equalTo(labelForTitle.snp.bottom)
        }
        // 箭头图标
        imageForDetail.image = UIImage(named: "IMG_ic_arrow_smallgrey")
        contentView.addSubview(imageForDetail)
        imageForDetail.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.centerY.equalTo(labelForDetail.snp.centerY)
        }
        // 头像+姓名 collection
        collection = UICollectionView(frame: .zero, collectionViewLayout: RankListPreviewColletionFlowLayout())
        collection.register(RankListPreviewColletionCell.self, forCellWithReuseIdentifier: RankListPreviewColletionCell.identifier)
        collection.backgroundColor = UIColor.white
        collection.delegate = self
        collection.dataSource = self
        contentView.addSubview(collection)
        collection.snp.makeConstraints { (make) in
            make.top.equalTo(labelForTitle.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
            make.height.equalTo(RankListPreviewColletionUX.collectinSize.height)
            make.bottom.equalTo(-20)
        }
        // 分割线
        let seperator = UIView(frame: .zero)
        seperator.backgroundColor = UIColor(hex: 0xf4f5f5)
        contentView.addSubview(seperator)
        seperator.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(5)
        }
    }

    /// 加载数据，刷新界面
    internal func setInfo(model: RankListPreviewCellModel) {
        cellModel = model
        labelForTitle.text = model.title
        collection.reloadData()
    }

}

extension RankListPreviewCell: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = cellModel else {
            return 0
        }
        return model.userInfos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = cellModel else {
            return UICollectionViewCell()
        }
        let data = model.userInfos[indexPath.row]
        let cell = collection.dequeueReusableCell(withReuseIdentifier: RankListPreviewColletionCell.identifier, for: indexPath) as! RankListPreviewColletionCell
        cell.setInfo(model: data)
        return cell
    }
}

// MARK: - Collection FlowLayout
class RankListPreviewColletionFlowLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        // 1.设置item的宽度和高度
        itemSize = RankListPreviewColletionUX.itemSize

        // 3.设置其他属性
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0

        // 4.设置内边距
        sectionInset = RankListPreviewColletionUX.collectionInsets
    }
}

// MARK: - 计算控件的大小
class RankListPreviewColletionUX {

    /// 屏幕宽度
    static let screenWidth = UIScreen.main.bounds.width

    // 姓名 label 的高度
    static var nameLabelHeight: CGFloat {
        return "姓名".sizeOfString(usingFont: UIFont.systemFont(ofSize: 12)).height
    }
    /// 头像大小
    static var avatarSize: CGSize {
        let width = screenWidth * 0.132_8
        return CGSize(width: width, height: width)
    }
    // 头像之间的间距
    static var avatarSpacing: CGFloat {
        return screenWidth * 0.056
    }

    /// item 大小
    static var itemSize: CGSize {
        // 头像和姓名 label 之间的间距
        let nameSpacing: CGFloat = 10
        // 计算出 item 的宽高
        let itemWidth = avatarSize.width + avatarSpacing
        let itemHeight = avatarSize.height + nameSpacing + nameLabelHeight
        return CGSize(width: itemWidth, height: itemHeight)
    }
    /// collection 大小
    static var collectinSize: CGSize {
        return CGSize(width: screenWidth, height: itemSize.height)
    }
    /// collection 内边距
    static var collectionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: avatarSpacing / 2 - 0.5, bottom: 0, right: avatarSpacing / 2 - 0.5)
    }
}
