//
//  GroupDatePickerView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 14/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//

import UIKit

protocol GroupDatePickerViewProtocol: class {
    /// 背景 点击回调
    func didCoverClickInDatePickerView(_ pickerView: GroupDatePickerView) -> Void
    /// 取消 点击回调
    func didClickCancelBtnInDatePickerView(_ pickerView: GroupDatePickerView) -> Void
    /// 确定 点击回调
    func datePickerView(_ pickerView: GroupDatePickerView, didClickDoneWith date: Date) -> Void
}
extension GroupDatePickerViewProtocol {
    /// 背景 点击回调
    func didCoverClickInDatePickerView(_ pickerView: GroupDatePickerView) -> Void {
    }
    /// 取消 点击回调
    func didClickCancelBtnInDatePickerView(_ pickerView: GroupDatePickerView) -> Void {
    }
}

class GroupDatePickerView: UIView {

    // MARK: - Internal Property

    /// 回调
    weak var delegate: GroupDatePickerViewProtocol?
    var doneClickAction: ((_ selectedDate: Date) -> Void)?

    private(set) weak var datePicker: UIDatePicker?

    // MARK: - Internal Function

    func show(completion: (() -> Void)? = nil) -> Void {
        self.isHidden = false
        UIView.animate(withDuration: 0.25, animations: {
            // 背景色更改
            self.coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            // bottomView上移
            self.bottomView.snp.updateConstraints({ (make) in
                make.bottom.equalTo(self).offset(0)
            })
            self.layoutIfNeeded()
        }) { (finish) in
            if finish {
                completion?()
            }
        }
    }
    func dismiss(completion: (() -> Void)? = nil) -> Void {
        UIView.animate(withDuration: 0.25, animations: {
            // 背景色更改
            self.coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0)
            // bottomView下移
            self.bottomView.snp.updateConstraints({ (make) in
                make.bottom.equalTo(self).offset(self.bottomViewH)
            })
            self.layoutIfNeeded()
        }) { (finish) in
            if finish {
                self.isHidden = true
                completion?()
            }
        }
    }

    // MARK: - Private Property

    fileprivate let pickerToolH: CGFloat = 44
    fileprivate let bottomViewH: CGFloat = 250
    fileprivate weak var coverBtn: UIButton!
    fileprivate weak var bottomView: UIView!
    fileprivate let lrMargin: CGFloat = 15

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
        // 2. bottomView - 一起做动画
        let bottomView = UIView(bgColor: UIColor.white)
        self.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.height.equalTo(self.bottomViewH)
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(self).offset(self.bottomViewH)  // 默认在下方
        }
        self.bottomView = bottomView
        // 2.2 pickerToolView
        let pickerToolView = UIView()
        bottomView.addSubview(pickerToolView)
        self.initialPickerToolView(pickerToolView)
        pickerToolView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(bottomView)
            make.height.equalTo(self.pickerToolH)
        }
        // 2.1 pickerView
        let datePicker = UIDatePicker()
        bottomView.addSubview(datePicker)
        datePicker.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(bottomView)
            make.top.equalTo(pickerToolView.snp.bottom)

        }
        self.datePicker = datePicker
    }
    /// picker上方的工具栏布局
    fileprivate func initialPickerToolView(_ toolView: UIView) -> Void {
        // 1. rightBtn - doneBtn
        let rightBtn = UIButton(type: .custom)
        toolView.addSubview(rightBtn)
        rightBtn.setTitle("确定", for: .normal)
        rightBtn.setTitleColor(TSColor.main.theme, for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        rightBtn.addTarget(self, action: #selector(rightBtnClick(_:)), for: .touchUpInside)
        rightBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(toolView)
            make.trailing.equalTo(toolView).offset(-lrMargin)
        }
        // 2. leftBtn - cancelBtn
        let leftBtn = UIButton(type: .custom)
        toolView.addSubview(leftBtn)
        leftBtn.setTitle("取消", for: .normal)
        leftBtn.setTitleColor(TSColor.normal.minor, for: .normal)
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        leftBtn.addTarget(self, action: #selector(leftBtnClick(_:)), for: .touchUpInside)
        leftBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(toolView)
            make.leading.equalTo(toolView).offset(lrMargin)
        }
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

    /// 背景点击
    @objc fileprivate func coverBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didCoverClickInDatePickerView(self)
        self.dismiss()
    }

    /// 右侧按钮点击响应
    @objc fileprivate func rightBtnClick(_ button: UIButton) -> Void {
        self.dismiss()
        if let date = self.datePicker?.date {
            self.delegate?.datePickerView(self, didClickDoneWith: date)
            self.doneClickAction?(date)
        }
    }
    /// 左侧按钮点击响应
    @objc fileprivate func leftBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickCancelBtnInDatePickerView(self)
        self.dismiss()
    }

}
