//
//  TSQuestionPublishTopicAddCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 06/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问答发布里话题添加的cell

import UIKit

class TSQuestionPublishTopicAddCell: UITableViewCell {

    // MARK: - Internal Property
    static let cellHeight: CGFloat = 70
    /// 重用标识符
    static let identifier: String = "TSQuestionPublishTopicAddCellReuseIdentifier"
    /// 数据模型
    var model: TSQuoraTopicModel? {
        didSet {
            self.setupWithModel(model)
        }
    }

    // MARK: - Private Property

    /// 头像
    private weak var iconView: UIImageView!
    /// 标题
    private weak var titleLabel: UILabel!
    /// 描述
    private weak var descLabel: UILabel!

    // MARK: - Internal Function

    class func cellInTableView(_ tableView: UITableView) -> TSQuestionPublishTopicAddCell {
        let identifier = TSQuestionPublishTopicAddCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = TSQuestionPublishTopicAddCell(style: .default, reuseIdentifier: identifier)
        }
        // 重置位置
        return cell as! TSQuestionPublishTopicAddCell
    }

    // MARK: - Initialize Function

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Override Function

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // mainView - 整体布局，便于扩展，特别是针对分割、背景色、四周间距
        let mainView = UIView()
        self.contentView.addSubview(mainView)
        self.initialMainView(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }
    // 主视图布局
    private func initialMainView(_ mainView: UIView) -> Void {
        let iconLeftMargin: CGFloat = 15
        let iconWH: CGFloat = 40
        let titleleftMargin: CGFloat = 15
        let titleRightMargin: CGFloat = 15
        let titleTopMargin: CGFloat = 17
        let descBottomMargin: CGFloat = 18
        // 1. iconView
        let iconView = UIImageView()
        mainView.addSubview(iconView)
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        iconView.backgroundColor = TSColor.normal.imagePlaceholder
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(iconWH)
            make.centerY.equalTo(mainView)
            make.leading.equalTo(mainView).offset(iconLeftMargin)
        }
        self.iconView = iconView
        // 2. titleLabel
        let titleLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15), textColor: TSColor.main.content)
        mainView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(iconView.snp.trailing).offset(titleleftMargin)
            make.trailing.equalTo(mainView).offset(-titleRightMargin)
            make.top.equalTo(mainView).offset(titleTopMargin)
        }
        self.titleLabel = titleLabel
        // 3. descLabel
        let descLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.minor)
        mainView.addSubview(descLabel)
        descLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalTo(mainView).offset(-descBottomMargin)
        }
        self.descLabel = descLabel
        // 4. bottomLine
        mainView.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
    }

    // MARK: - Private  数据加载

    /// 加载数据
    private func setupWithModel(_ model: TSQuoraTopicModel?) -> Void {
        guard let model = model else {
            return
        }
        self.titleLabel.text = model.name
        self.descLabel.text = model.description
        if let avatar = TSUtil.praseTSNetFileUrl(netFile: model.avatar) {
            self.iconView.kf.setImage(with: URL(string: avatar ?? ""))
        }
    }

}
