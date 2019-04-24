//
//  TSKBQuestionInputAccessoryView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 05/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题详情编辑时的辅助视图
//  注：在TSKBNewsInputAccessoryView的基础上添加了匿名提问

import UIKit

protocol TSKBQuestionInputAccessoryViewProtocol: class {
    /// 关闭键盘按钮点击回调
    func didClickDownBtn() -> Void
    /// 图片按钮点击回调
    func didClickPicBtn() -> Void
    /// 匿名提问开关状态被更改
    func didChangedAnonymousStatus(_ anonymousSwitch: UISwitch) -> Void
}

class TSKBQuestionInputAccessoryView: UIView {

    // MARK: - Internal Property
    // 回调处理
    weak var delegate: TSKBQuestionInputAccessoryViewProtocol?
    var downBtnClickAction: (() -> Void)?
    var picBtnClickAction: (() -> Void)?
    var anonymousSwitchChangedAction: ((_ anonymousSwitch: UISwitch) -> Void)?
    // MARK: - Private Property
    private let defaultH: CGFloat = 90

    private(set) weak var anonymousView: TSAnonymousSwitchView!

    // MARK: - Internal Function

    // MARK: - Initialize Function
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialUI()
    }
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: defaultH))
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: defaultH)
        self.initialUI()
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        self.backgroundColor = UIColor.white
        // 1. kbTool
        let kbTool = UIView()
        self.addSubview(kbTool)
        self.initialKbToolView(kbTool)
        kbTool.snp.makeConstraints { (make) in
//            make.leading.trailing.top.equalTo(self)
            make.top.leading.width.equalTo(self)
            make.height.equalTo(40)
        }
        // 2. anonymousView
        let anonymousView = TSAnonymousSwitchView()
        self.addSubview(anonymousView)
        anonymousView.switchView.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        anonymousView.snp.makeConstraints { (make) in
            make.bottom.leading.width.equalTo(self)
            make.height.equalTo(50)
        }
        self.anonymousView = anonymousView
    }

    /// 初始化键盘工具栏
    private func initialKbToolView(_ toolView: UIView) -> Void {
        let iconWH = 40
        let lrMargin: Float = 5
        // 1. left downBtn
        let downBtn = UIButton(type: .custom)
        toolView.addSubview(downBtn)
        downBtn.setImage(UIImage(named: "IMG_sec_nav_arrow"), for: .normal)
        downBtn.addTarget(self, action: #selector(downBtnClick(_:)), for: .touchUpInside)
        downBtn.clipsToBounds = true
        downBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(iconWH)
            make.left.equalTo(toolView).offset(lrMargin)
            make.centerY.equalTo(toolView)
        }
        // 2. right picBtn
        let picBtn = UIButton(type: .custom)
        toolView.addSubview(picBtn)
        picBtn.setImage(UIImage(named: "IMG_icon_picture_grey"), for: .normal)
        picBtn.setImage(UIImage(named: "IMG_icon_picture_blue"), for: .selected)
        picBtn.addTarget(self, action: #selector(picBtnClick(_:)), for: .touchUpInside)
        picBtn.clipsToBounds = true
        picBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(iconWH)
            make.right.equalTo(toolView).offset(-lrMargin)
            make.centerY.equalTo(toolView)
        }
        // 3. topLine
        self.addLineWithSide(.inTop, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

    // 关闭键盘按钮点击响应
    @objc private func downBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickDownBtn()
        self.downBtnClickAction?()
    }
    // 图片按钮点击响应
    @objc private func picBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickPicBtn()
        self.picBtnClickAction?()
    }
    /// switch开关响应
    @objc private func switchValueChanged(_ switchView: UISwitch) -> Void {
        self.delegate?.didChangedAnonymousStatus(switchView)
        self.anonymousSwitchChangedAction?(switchView)
    }

}
