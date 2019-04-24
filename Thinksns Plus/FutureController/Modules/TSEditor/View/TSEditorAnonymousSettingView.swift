//
//  TSEditorSettingAnonymousView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 26/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  编辑器工具栏设置的匿名选项视图

import UIKit

protocol TSEditorAnonymousSettingViewProtocol: class {
    func didSwitchValueChanged(in anonymousSettingView: TSEditorAnonymousSettingView) -> Void
}

/// 编辑器工具栏设置的匿名选项视图
class TSEditorAnonymousSettingView: UIView {

    // MARK: - Internal Property

    /// 响应回调
    weak var delegate: TSEditorAnonymousSettingViewProtocol?
    var switchValueChangedAction: ((_ isAnonymous: Bool) -> Void)?

    let titleLabel: UILabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: TSColor.main.content, alignment: .right)
    let switchView: UISwitch = UISwitch()

    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    var isAnonymous: Bool {
        get {
            return self.switchView.isOn
        } set {
            self.switchView.isOn = isAnonymous
        }
    }

    // MARK: - Internal Function

    // MARK: - Private Property

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
        self.backgroundColor = UIColor(hex: 0xf5f5f4)
        // 同设置按钮的右侧一致
        let itemCount: Int = 8
        let itemIconW: CGFloat = 20
        let lrMargin: CGFloat = 15.0
        let rightMargin: CGFloat = lrMargin + ((ScreenWidth - lrMargin * 2) / CGFloat(itemCount) - itemIconW) * 0.5
        // 1. switchView
        self.addSubview(self.switchView)
        switchView.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        switchView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        self.switchView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-rightMargin)
        }
        // 2. titleLabel
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self.switchView.snp.leading).offset(-7)
        }
        // 3. localized
        self.titleLabel.text = "启用匿名"//"显示_匿名提问".localized
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

    @objc fileprivate func switchValueChanged(_ swithView: UISwitch) -> Void {
        self.delegate?.didSwitchValueChanged(in: self)
        self.switchValueChangedAction?(swithView.isOn)
    }

}
