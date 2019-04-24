//
//  UnpublishedNewsCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  我的投稿 - 投稿中/被驳回的投稿 cell

import UIKit

class UnpublishedNewsCell: UITableViewCell {

    static let identifier = "UnpublishedNewsCell"

    /// 封面图
    let imageViewForCover = UIImageView()
    /// 标题
    let labelForTitle = UILabel()
    /// 内容
    let labelForContent = UILabel()
    /// 中心视图
    let centerView = UIView()

    /// 数据模型
    var cellModel: NewsModel?

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
        // 中心视图
        /*
         由于设计图中，标题 label 和 内容 label 是整体居中的，故增加了中心视图来满足这种设计效果
         */
        centerView.backgroundColor = UIColor.white
        contentView.addSubview(centerView)
        centerView.snp.makeConstraints { (make) in
            make.leftMargin.rightMargin.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        // 封面图
        imageViewForCover.contentMode = .scaleAspectFill
        imageViewForCover.clipsToBounds = true
        contentView.addSubview(imageViewForCover)
        // 标题
        labelForTitle.font = UIFont.systemFont(ofSize: 16)
        labelForTitle.textColor = TSColor.inconspicuous.navTitle
        labelForTitle.numberOfLines = 2
        centerView.addSubview(labelForTitle)
        // 内容
        labelForContent.font = UIFont.systemFont(ofSize: 14)
        labelForContent.textColor = TSColor.normal.minor
        labelForContent.numberOfLines = 1
        centerView.addSubview(labelForContent)
        // 分割线
        let seperator = UIView(frame: .zero)
        seperator.backgroundColor = TSColor.inconspicuous.disabled
        contentView.addSubview(seperator)
        seperator.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    func setInfo(model: NewsDetailModel) {
        cellModel = model
        var haveCoverImage: Bool
        // 1.封面图
        if let imgInfos = model.coverInfos, imgInfos.isEmpty == false {
            haveCoverImage = true
            let imgUrl = TSURLPath.imageV2URLPath(storageIdentity: imgInfos[0].id, compressionRatio: 20, cgSize: imgInfos[0].size)
            imageViewForCover.kf.setImage(with: imgUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
            imageViewForCover.snp.remakeConstraints({ (mark) in
                mark.size.equalTo(CGSize(width: TSNewsListCellUX.imageWidth, height: TSNewsListCellUX.imageHeight))
                mark.top.equalToSuperview().offset(15)
                mark.right.equalToSuperview().offset(-10)
            })
        } else {
            haveCoverImage = false
            imageViewForCover.snp.remakeConstraints({ (mark) in
                mark.size.equalTo(CGSize.zero)
                mark.top.equalToSuperview().offset(15)
                mark.right.equalToSuperview().offset(-10)
            })
        }
        // 2.标题
        labelForTitle.text = model.title
        labelForTitle.snp.remakeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalToSuperview()
            if haveCoverImage == true {
                make.right.equalTo(-126)
            } else {
                make.right.equalTo(-15)
            }
        }
        // 3.内容
        labelForContent.text = model.subject
        labelForContent.snp.remakeConstraints { (make) in
            make.top.equalTo(labelForTitle.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.bottom.equalToSuperview()
            if haveCoverImage == true {
                make.right.equalTo(-126)
            } else {
                make.right.equalTo(-15)
            }
        }
    }
}
