//
//  TSQuestionSingleTopicSelectedView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 07/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题发布 - 话题选中的视图中 - 话题元素
//  右侧有取消选中的按钮

import UIKit

class TSQuestionSingleTopicSelectedView: UIView {

    // MARK: - Internal Property
    // 话题
    var model: TSQuoraTopicModel? {
        didSet {
            self.titleLabel.text = model?.name
        }
    }
    /// 标题
    private(set) weak var titleLabel: UILabel!
    /// 取消按钮
    private(set) weak var cancelBtn: UIButton!

    static let defaultH: CGFloat = 25

    // MARK: - Internal Function

    /// 带标题的宽度计算
    class func widthWithTitle(_ title: String) -> CGFloat {
        let temp = TSQuestionSingleTopicSelectedView()
        let fixW: CGFloat = temp.horMargin * 3.0 + temp.iconWH
        let titleW: CGFloat = title.size(maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), font: temp.titleFont, lineMargin: 0).width
        return fixW + titleW
    }

    // MARK: - Private Property
    /// 水平方向上的间距：标题左侧、标题右侧、图标右侧
    private let horMargin: CGFloat = 10
    /// 删除图标的宽高
    private let iconWH: CGFloat = 7
    /// 标题字体
    private let titleFont: UIFont = UIFont.systemFont(ofSize: 12)

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

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // 0. self
        self.backgroundColor = TSColor.main.theme.withAlphaComponent(0.15)
        self.layer.cornerRadius = TSQuestionSingleTopicSelectedView.defaultH * 0.5
        self.clipsToBounds = true
        // 2. cancelBtn
        let cancelBtn = UIButton(type: .custom)
        self.addSubview(cancelBtn)
        cancelBtn.setImage(UIImage(named: "IMG_ico_search_delete"), for: .normal)
        cancelBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self)
            make.width.equalTo(horMargin * 2.0 + iconWH)
        }
        self.cancelBtn = cancelBtn
        // 1. titleLabel
        let titleLabel = UILabel(text: "", font: titleFont, textColor: TSColor.normal.content)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(horMargin)
            make.trailing.equalTo(cancelBtn.snp.leading)
        }
        self.titleLabel = titleLabel

    }

    // MARK: - Private  数据加载

}
