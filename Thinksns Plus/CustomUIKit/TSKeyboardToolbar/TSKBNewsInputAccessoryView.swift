//
//  TSKBNewsInputAccessoryView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 16/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯编辑时键盘输入控件
//  左侧关闭键盘按钮、右侧添加图片

import UIKit

protocol TSKBNewsInputAccessoryViewProtocol: class {
    /// 关闭键盘按钮点击回调
    func didClickDownBtn() -> Void
    /// 图片按钮点击回调
    func didClickPicBtn() -> Void
}

class TSKBNewsInputAccessoryView: UIView {

    // MARK: - Internal Property
    // 回调处理
    weak var delegate: TSKBNewsInputAccessoryViewProtocol?
    var downBtnClickAction: (() -> Void)?
    var picBtnClickAction: (() -> Void)?
    // MARK: - Private Property
    private let defaultH: CGFloat = 40

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
        let iconWH = defaultH
        let lrMargin: Float = 5
        // 1. left downBtn
        let downBtn = UIButton(type: .custom)
        self.addSubview(downBtn)
        downBtn.setImage(UIImage(named: "IMG_sec_nav_arrow"), for: .normal)
        downBtn.addTarget(self, action: #selector(downBtnClick(_:)), for: .touchUpInside)
        downBtn.clipsToBounds = true
        downBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(iconWH)
            make.leading.equalTo(self).offset(lrMargin)
            make.centerY.equalTo(self)
        }
        // 2. right picBtn
        let picBtn = UIButton(type: .custom)
        self.addSubview(picBtn)
        picBtn.setImage(UIImage(named: "IMG_icon_picture_grey"), for: .normal)
        picBtn.setImage(UIImage(named: "IMG_icon_picture_blue"), for: .selected)
        picBtn.addTarget(self, action: #selector(picBtnClick(_:)), for: .touchUpInside)
        picBtn.clipsToBounds = true
        picBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(iconWH)
            make.trailing.equalTo(self).offset(-lrMargin)
            make.centerY.equalTo(self)
        }
        // 3. topLine
        self.addLineWithSide(.inTop, color: UIColor.lightGray, thickness: 0.5, margin1: 0, margin2: 0)
        // 4. bottomLine
        self.addLineWithSide(.inBottom, color: UIColor.black, thickness: 0.5, margin1: 0, margin2: 0)
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

}
