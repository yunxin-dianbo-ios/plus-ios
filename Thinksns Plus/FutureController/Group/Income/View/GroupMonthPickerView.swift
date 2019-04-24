//
//  GroupMonthPickerView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 14/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//

import UIKit

protocol GroupMonthPickerViewProtocol: class {
    /// 背景 点击回调
    func didClickCoverInMonthPickerView(_ pickerView: GroupMonthPickerView) -> Void
    /// 取消 点击回调
    func didClickCancelInMonthPickerView(_ pickerView: GroupMonthPickerView) -> Void
    /// 确定 点击回调
    func monthPickerView(_ pickerView: GroupMonthPickerView, didClickDoneWithYear year: Int, month: Int) -> Void
}
extension GroupMonthPickerViewProtocol {
    /// 背景 点击回调
    func didClickCoverInMonthPickerView(_ pickerView: GroupMonthPickerView) -> Void {
    }
    /// 取消 点击回调
    func didClickCancelInMonthPickerView(_ pickerView: GroupMonthPickerView) -> Void {
    }
}

class GroupMonthPickerView: UIView {

    // MARK: - Internal Property

    /// 回调
    weak var delegate: GroupMonthPickerViewProtocol?
    var doneClickAction: ((_ year: Int, _ month: Int) -> Void)?

    // MARK: - Private Property
    fileprivate weak var pickerView: UIPickerView!

    fileprivate var yearList: [String] = [String]()
    fileprivate var monthList: [String] = [String]()

    // MARK: - Internal Function

    func show(completion: (() -> Void)? = nil) -> Void {
        self.isHidden = false
        self.pickerView.selectRow(yearList.count - 1, inComponent: 0, animated: true)
        self.pickerView.selectRow(Date().month - 1, inComponent: 1, animated: true)
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
        self.initialDataSource()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialUI()
        self.initialDataSource()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
        self.initialDataSource()
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
        let pickerView = UIPickerView()
        bottomView.addSubview(pickerView)
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(bottomView)
            make.top.equalTo(pickerToolView.snp.bottom)
        }
        self.pickerView = pickerView
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
    fileprivate func initialDataSource() -> Void {
        //self.yearList =
        // 年份： 2017 - now
        let minYear = 2_017
        let nowYear = Date().year
        if nowYear >= minYear {
            for i in minYear...nowYear {
                self.yearList.append("\(i)")
            }
        } else {
            self.yearList.append("\(nowYear)")
        }

        // 月份
        for i in 1...12 {
            self.monthList.append(String(format: "%d月", i))
        }
    }

    // MARK: - Private  事件响应

    /// 背景点击
    @objc fileprivate func coverBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickCoverInMonthPickerView(self)
        self.dismiss()
    }

    /// 右侧按钮点击响应
    @objc fileprivate func rightBtnClick(_ button: UIButton) -> Void {
        self.dismiss()
        let yearRow = self.pickerView.selectedRow(inComponent: 0)
        let yearStr = self.yearList[yearRow]
        let monthRow = self.pickerView.selectedRow(inComponent: 1)
        let month = monthRow + 1
        if let year = Int(yearStr) {
            self.delegate?.monthPickerView(self, didClickDoneWithYear: year, month: month)
            self.doneClickAction?(year, month)
        }
    }
    /// 左侧按钮点击响应
    @objc fileprivate func leftBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickCancelInMonthPickerView(self)
        self.dismiss()
    }

    // MARK: - Delegate

}

// MARK: - Delegate Function

// MARK: - Delegate <UIPickerViewDataSource>

extension GroupMonthPickerView: UIPickerViewDataSource {

    // returns the number of 'columns' to display.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    // returns the # of rows in each component..
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var rowNum: Int = 0
        if 0 == component {
            rowNum = self.yearList.count
        } else if 1 == component {
            rowNum = self.monthList.count
        }
        return rowNum
    }
}

// MARK: - Delegate <UIPickerViewDelegate>

extension GroupMonthPickerView: UIPickerViewDelegate {

    // returns width of column and height of row for each component.
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return ScreenWidth * 0.45
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }

    // these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
    // for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
    // If you return back a different object, the old one will be released. the view will be centered in the row rect
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title: String?
        if 0 == component {
            title = self.yearList[row]
        } else if 1 == component {
            title = self.monthList[row]
        }
        return title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    }
}
