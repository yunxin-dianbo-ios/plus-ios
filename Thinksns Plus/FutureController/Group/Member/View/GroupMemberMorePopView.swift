//
//  GroupMemberMorePopView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 13/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子成员管理中更多弹窗

import UIKit

protocol GroupMemberMorePopViewProtocol: class {
    /// 遮罩点击回调
    func didClickCoverInQuoraDraftPopView(_ popView: GroupMemberMorePopView) -> Void
    /// 选项点击响应
    /// - 这个title应该考虑弄个别的方式处理，而不是使用字符串
    func memberPopView(_ popView: GroupMemberMorePopView, didClickOptionWith title: String) -> Void
}
extension GroupMemberMorePopViewProtocol {
    /// 遮罩点击响应
    func didClickCoverInQuoraDraftPopView(_ popView: GroupMemberMorePopView) -> Void {

    }
}

class GroupMemberMorePopView: UIView {

    // MARK: - Internal Property
    /// 回调
    weak var delegate: GroupMemberMorePopViewProtocol?
    /// 被操作的用户的角色类型
    let memberType: GroupMemberRoleType
    /// 是否是圈主(用于普通成员的判断处理)
    let isOwner: Bool
    // MARK: - Internal Function

    // MARK: - Private Property
    /// 弹窗选项的间距
    private let centerYMargin: CGFloat
    private let rightMargin: CGFloat
    private weak var coverBtn: UIButton!

    // MARK: - Initialize Function
    init(centerYMargin: CGFloat, rightMargin: CGFloat, memberType: GroupMemberRoleType, isOwner: Bool) {
        self.memberType = memberType
        self.isOwner = isOwner
        self.centerYMargin = centerYMargin
        self.rightMargin = rightMargin
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        let optionH: CGFloat = 40
        let optionW: CGFloat = 100
        // 1. coverBtn
        let coverBtn = UIButton(type: .custom)
        self.addSubview(coverBtn)
        coverBtn.addTarget(self, action: #selector(coverBtnClick(_:)), for: .touchUpInside)
        coverBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        self.coverBtn = coverBtn
        // 2. 选项框
        // 响应子选项标题，需要计算个数来算高度，所以放置到前面
        var titles: [String] = [String]()
        switch self.memberType {
        case .owner:
            break
        case .administrator:
            titles = ["移出圈管理"]
        case .member:
            // 只有圈主才可将普通成员升为管理员
            if self.isOwner {
                titles = ["设为圈管理员", "移出圈子", "加入黑名单"]
            } else {
                titles = ["移出圈子", "加入黑名单"]
            }
        case .black:
            titles = ["移出圈子", "移出黑名单"]
        }
        let optionView = UIView(cornerRadius: 5, borderWidth: 0.5, borderColor: TSColor.normal.disabled)
        coverBtn.addSubview(optionView)
        optionView.backgroundColor = UIColor.white
        optionView.snp.makeConstraints { (make) in
            make.trailing.equalTo(coverBtn).offset(-self.rightMargin)
            make.width.equalTo(optionW)
            // 根据centerYMargin与optionTotalH 对optionView的centerY进行修正
            let optionTotalH: CGFloat = optionH * CGFloat(titles.count)
            let realCenterYmargin: CGFloat = (self.centerYMargin + optionTotalH * 0.5 > ScreenHeight) ? (ScreenHeight - optionH * 0.5 - 20) : self.centerYMargin
            make.centerY.equalTo(realCenterYmargin)
        }
        // 2.x 响应子选项
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .custom)
            optionView.addSubview(button)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.setTitleColor(TSColor.normal.content, for: .normal)
            button.tag = 250 + index
            button.addTarget(self, action: #selector(optionBtnClick(_:)), for: .touchUpInside)
            // 文字距离左侧为14间距
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 0)
            button.snp.makeConstraints({ (make) in
                make.leading.trailing.equalTo(optionView)
                make.height.equalTo(optionH)
                make.top.equalTo(optionView).offset(optionH * CGFloat(index))
                if index == titles.count - 1 {
                    make.bottom.equalTo(optionView)
                }
            })
            if index != titles.count - 1 {
                button.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
            }
        }
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

    /// 遮罩点击响应
    @objc private func coverBtnClick(_ button: UIButton) -> Void {
        self.removeFromSuperview()
        self.delegate?.didClickCoverInQuoraDraftPopView(self)
    }
    // 选项点击响应
    @objc private func optionBtnClick(_ button: UIButton) -> Void {
        self.removeFromSuperview()
        guard let title = button.currentTitle else {
            return
        }
        self.delegate?.memberPopView(self, didClickOptionWith: title)
    }
}
