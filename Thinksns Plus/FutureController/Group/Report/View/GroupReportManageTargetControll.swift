//
//  GroupReportManageTargetControll.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子举报管理列表Cell中的举报对象的控件

import UIKit

class GroupReportManageTargetControll: UIControl {

    // MARK: - Internal Property

    /// 举报评论时 举报用户名 按钮
    let userBtn: UIButton = UIButton(type: .custom)

    ///
    var model: GroupReportModel? {
        didSet {
            self.setupWithModel(model)
        }
    }
    /// 举报对象的显示类型
    enum ShowType {
        ///
        case none
        /// 评论
        case comment
        /// 帖子 - 带图片展示
        case post_icon
        /// 帖子 - 不带图片展示
        case post_noIcon
        /// 帖子 - 资源被删除
        case post_none
    }
    /// 根据数据获取显示类型
    class func showTypeWithModel(_ model: GroupReportModel) -> ShowType {
        var showType: ShowType = .none
        guard let type = model.type else {
            return showType
        }
        switch type {
        case .comment:
            showType = .comment
        case .post:
            // 判断资源是否还存在 - 帖子是否被删除
            showType = .post_none
            if let post = model.post {
                showType = .post_noIcon
                if post.body.ts_customMarkdownToStandard().ts_standardMarkdownIsContainImage() {
                    showType = .post_icon
                }
            }
        }
        return showType
    }
    class func heightWithModel(model: GroupReportModel) -> CGFloat {
        let showType = self.showTypeWithModel(model)
        var height: CGFloat = 28
        if showType == .post_icon {
            height = 38
        }
        return height
    }

    // MARK: - Private Property

    /// 举报帖子时 展示的头像 - 可能并不存在头像
    fileprivate let iconView: UIImageView = UIImageView(cornerRadius: 0)
    /// 举报帖子时 展示的标题
    fileprivate let titleLabel: UILabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.minor)

    // MARK: - Initialize Function

    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Internal Function
    // MARK: - Override Function

    // MARK: - Private  UI

    private func initialUI() -> Void {
        // userBtn配置
        userBtn.contentHorizontalAlignment = .left
        userBtn.setTitleColor(TSColor.main.content, for: .normal)
        userBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        userBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 3)
    }

    // MARK: - Private  数据
    /// 数据加载
    fileprivate func setupWithModel(_ model: GroupReportModel?) -> Void {
        guard let model = model else {
            return
        }
        let showType = GroupReportManageTargetControll.showTypeWithModel(model)
        self.setupWith(showType: showType, model: model)
    }
    /// 根据 模型和展示类型 加载数据
    fileprivate func setupWith(showType: ShowType, model: GroupReportModel) {
        self.removeAllSubViews()
        self.titleLabel.text = nil
        self.iconView.image = nil
        self.userBtn.setTitle(nil, for: .normal)
        let iconWH: CGFloat = 28
        let iconMargin: CGFloat = 5
        // 不显示图片时的左侧间距
        let leftMargin: CGFloat = 8
        let rightMargin: CGFloat = 10
        switch showType {
        case .none:
            break
        case .comment:
            self.addSubview(self.userBtn)
            self.addSubview(titleLabel)
            self.userBtn.snp.makeConstraints({ (make) in
                make.centerY.equalTo(self)
                make.leading.equalTo(self).offset(leftMargin)
            })
            self.titleLabel.snp.makeConstraints({ (make) in
                make.centerY.equalTo(self)
                make.leading.equalTo(self.userBtn.snp.trailing)
                make.trailing.lessThanOrEqualTo(self).offset(-rightMargin)
            })
            let userTitle = String(format: "%@:", model.targetUser?.name ?? "")
            self.userBtn.setTitle(userTitle, for: .normal)
            self.titleLabel.text = model.comment?.body
        case .post_icon:
            self.addSubview(self.iconView)
            self.addSubview(titleLabel)
            self.iconView.snp.makeConstraints({ (make) in
                make.width.height.equalTo(iconWH)
                make.centerY.equalTo(self)
                make.leading.equalTo(self).offset(iconMargin)
            })
            self.titleLabel.snp.makeConstraints({ (make) in
                make.centerY.equalTo(self)
                make.leading.equalTo(iconView.snp.trailing).offset(iconMargin)
                make.trailing.lessThanOrEqualTo(self).offset(-rightMargin)
                make.trailing.equalTo(self).offset(-rightMargin)
            })
            if let imageStr = model.post?.body.ts_customMarkdownToStandard().ts_getMarkdownImageUrl().first {
                self.iconView.kf.setImage(with: URL(string: imageStr))
            }
            self.titleLabel.text = model.post?.title
        case .post_noIcon:
            self.addSubview(self.titleLabel)
            self.titleLabel.snp.makeConstraints({ (make) in
                make.centerY.equalTo(self)
                make.leading.equalTo(self).offset(leftMargin)
                make.trailing.equalTo(self).offset(-rightMargin)
            })
            self.titleLabel.text = model.post?.title
        case .post_none:
            self.addSubview(self.titleLabel)
            self.titleLabel.snp.makeConstraints({ (make) in
                make.centerY.equalTo(self)
                make.leading.equalTo(self).offset(leftMargin)
                make.trailing.equalTo(self).offset(-rightMargin)
            })
            self.titleLabel.text = "该帖子已删除"
        }

    }

    // MARK: - Private  事件响应

    // MARK: - Private  事件响应

}
