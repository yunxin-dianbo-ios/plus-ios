//
//  GroupReportTypeSelectPopView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子举报类型选择弹窗界面

import UIKit

protocol GroupReportTypeSelectPopViewProtocol: class {
    /// 背景 点击回调
    func didClickCoverInPopView(_ popView: GroupReportTypeSelectPopView) -> Void
    /// 选项 选中回调
    func popView(_ popView: GroupReportTypeSelectPopView, didSelectedType type: GroupReportManageType) -> Void
}
extension GroupReportTypeSelectPopViewProtocol {
    /// 背景 点击回调
    func didClickCoverInPopView(_ popView: GroupReportTypeSelectPopView) -> Void {
    }
}

class GroupReportTypeSelectPopView: UIView {

    // MARK: - Internal Property
    /// 回调
    weak var delegate: GroupReportTypeSelectPopViewProtocol?
    var typeSelectedAction: ((_ type: GroupReportManageType) -> Void)?

    // MARK: - Internal Function

    func show() -> Void {
        self.isHidden = false
        UIView.animate(withDuration: 0.25, animations: {
            // 背景色更改
            self.coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            // 选择视图下移
            self.typeSelectView.snp.updateConstraints({ (make) in
                make.bottom.equalTo(self.snp.top).offset(self.typeSelectViewH)
            })
            self.layoutIfNeeded()
        }) { (finish) in

        }
    }
    func dismiss() -> Void {
        UIView.animate(withDuration: 0.25, animations: {
            // 背景色更改
            self.coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0)
            // 选择视图下移
            self.typeSelectView.snp.updateConstraints({ (make) in
                make.bottom.equalTo(self.snp.top).offset(0)
            })
            self.layoutIfNeeded()
        }) { (finish) in
            self.isHidden = true
        }
    }

    // MARK: - Private Property

    fileprivate weak var coverBtn: UIButton!
    fileprivate weak var typeSelectView: UIView!

    /// 选项按钮的tag基值
    fileprivate let typeTagBase: Int = 250
    /// 单个选项的高度
    fileprivate let singltTypeViewH: CGFloat = 50
    fileprivate let typeSelectViewH: CGFloat = 200 // 50 * 4

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
        //fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // 1. coverBtn
        let coverBtn = UIButton(type: .custom)
        self.addSubview(coverBtn)
        coverBtn.addTarget(self, action: #selector(coverBtnClick(_:)), for: .touchUpInside)
        coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0)  // 默认颜色
        coverBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        self.coverBtn = coverBtn
        // 2. typeSelectView
        let typeSelectView = UIView(bgColor: UIColor.white)
        self.addSubview(typeSelectView)
        typeSelectView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self)
            // 默认位置
            //make.top.equalTo(self).offset(0)
            make.bottom.equalTo(self.snp.top).offset(0)
        }
        self.typeSelectView = typeSelectView
        // 2.x typeOptionView
        let titles = ["全部", "已处理", "未处理", "已驳回"]
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .custom)
            typeSelectView.addSubview(button)
            button.setTitle(title, for: .normal)
            button.setTitleColor(TSColor.main.content, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.tag = self.typeTagBase + index
            button.addTarget(self, action: #selector(typeBtnClick(_:)), for: .touchUpInside)
            button.addLineWithSide(.inBottom, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: 0, margin2: 0 )
            button.snp.makeConstraints({ (make) in
                make.height.equalTo(self.singltTypeViewH)
                make.leading.trailing.equalTo(typeSelectView)
                make.top.equalTo(typeSelectView).offset(CGFloat(index) * self.singltTypeViewH)
                if index == titles.count - 1 {
                    make.bottom.equalTo(typeSelectView)
                }
            })
        }
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

    /// 背景点击
    @objc fileprivate func coverBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickCoverInPopView(self)
        self.dismiss()
    }
    /// 选项按钮点击
    @objc fileprivate func typeBtnClick(_ button: UIButton) -> Void {
        self.dismiss()
        let index = button.tag - self.typeTagBase
        var type: GroupReportManageType?
        switch index {
        case 0:
            type = GroupReportManageType.all
        case 1:
            type = GroupReportManageType.accepted
        case 2:
            type = GroupReportManageType.waiting
        case 3:
            type = GroupReportManageType.rejected
        default:
            break
        }
        guard let selectedType = type else {
            return
        }
        self.delegate?.popView(self, didSelectedType: selectedType)
        self.typeSelectedAction?(selectedType)
    }

}
