//
//  QuoraTopicDetailExpertsCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  话题详情 专家头像 cell

import UIKit

class QuoraTopicDetailExpertsCell: UITableViewCell {

    /// 分割线
    let separatorLine = UIView()
    /// 专家人数
    let labelForExpertsCount = UILabel()
    /// 专家头像
    var expertsAvatars = AvatarIconsView(frame: CGRect(x: UIScreen.main.bounds.width - 110, y: 14, width: 110, height: 28))

    /// 话题简介数据
    var model: QuoraTopicDetailExpertsCellModel? {
        didSet {
            setInfo()
        }
    }

    static let identifier = "QuoraTopicDetailExpertsCell"

    class func cellForm(table: UITableView, at indexPath: IndexPath, with data: QuoraTopicDetailExpertsCellModel) -> QuoraTopicDetailExpertsCell {
        let cell = table.dequeueReusableCell(withIdentifier: QuoraTopicDetailExpertsCell.identifier, for: indexPath) as! QuoraTopicDetailExpertsCell
        cell.model = data
        return cell
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    func setUI() {
        // 分割线
        separatorLine.backgroundColor = TSColor.inconspicuous.disabled
        contentView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
        }
        // 专家人数 label
        labelForExpertsCount.font = UIFont.systemFont(ofSize: 14)
        labelForExpertsCount.numberOfLines = 0
        labelForExpertsCount.textColor = TSColor.normal.minor
        contentView.addSubview(labelForExpertsCount)
        labelForExpertsCount.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-125)
            make.topMargin.equalTo(22)
            make.bottomMargin.equalTo(-22)
        }
        // 专家头像 view
        expertsAvatars.avatarType = AvatarType.width26(showBorderLine: true)
        contentView.addSubview(expertsAvatars)
        expertsAvatars.snp.makeConstraints { (make) in
            make.size.equalTo(expertsAvatars.frame.size)
            make.centerY.equalTo(labelForExpertsCount.snp.centerY)
            make.rightMargin.equalTo(-15)
        }
    }

    func setInfo() {
        guard let cellModel = model else {
            return
        }
        // 专家人数 label
        labelForExpertsCount.text = "\(cellModel.expertsCount)位相关专家"
        // 专家头像
        expertsAvatars.datas = cellModel.experts
        expertsAvatars.reloadDatas()
    }
}
