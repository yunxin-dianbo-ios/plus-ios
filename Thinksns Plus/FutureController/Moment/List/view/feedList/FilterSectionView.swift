//
//  FilterSectionView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  带有过滤弹窗按钮的 section view

import UIKit

@objc protocol FilterSectionViewDelegate: class {

    /// 选中了新的内容
    func filterSectionView(_ view: FilterSectionView, didSeleteNewAtIndex index: Int)
    @objc optional func followButtonClick(_ view: FilterSectionView, button: UIButton)
}

class FilterSectionView: UITableViewHeaderFooterView {

    static let identifier = "FilterSectionView"

    /// 代理
    weak var delegate: FilterSectionViewDelegate?

    /// 数量 label
    let countLabel = UILabel()
    /// 过滤按钮
    let filterButton = UIButton(type: .custom)
    /// 当前选中坐标
    var currentIndex = 0
    /// 话题关注按钮
    let topicFollowButton = UIButton(type: .custom)
    /// 整体的高度
    var headerSectionHeight: CGFloat = 35.0

    /// 数据
    var model = FilterSectionViewModel() {
        didSet {
            loadModel()
        }
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        addSubview(countLabel)
        addSubview(filterButton)
        addSubview(topicFollowButton)
    }

    func loadModel() {
        // 1.加载数量 label
        loadCountLabel()
        // 2.加载过滤按钮
        loadFilterButton()
        // 3.加载关注话题按钮
        loadTopicButton()
    }

    /// 加载数量 label
    func loadCountLabel() {
        countLabel.font = UIFont.systemFont(ofSize: 13)
        countLabel.textColor = UIColor(hex: 0x999999)
        countLabel.text = model.countInfo
        countLabel.sizeToFit()
        countLabel.frame = CGRect(origin: CGPoint(x: 8, y: (headerSectionHeight - countLabel.size.height) / 2), size: countLabel.size)
    }

    /// 加载过滤按钮
    func loadFilterButton() {
        filterButton.isHidden = model.filterInfo.isEmpty
        if model.filterInfo.isEmpty {
            return
        }
        filterButton.setTitle(model.filterInfo[currentIndex], for: .normal)
        filterButton.setTitleColor(UIColor(hex: 0x999999), for: .normal)
        filterButton.semanticContentAttribute = .forceRightToLeft
        filterButton.setImage(UIImage(named: "IMG_ico_quora_question_sort"), for: .normal)
        filterButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        filterButton.addTarget(self, action: #selector(filterButtonTaped), for: .touchUpInside)
        filterButton.sizeToFit()
        filterButton.frame = CGRect(x: (UIScreen.main.bounds.width - filterButton.size.width - 10) - 10, y: 0, width: filterButton.size.width + 15, height: headerSectionHeight)
    }

    func loadTopicButton() {
        topicFollowButton.isHidden = model.hidFolloeButton
        if model.hidFolloeButton {
            return
        }
        topicFollowButton.isHidden = !model.filterInfo.isEmpty
        if !model.filterInfo.isEmpty {
            return
        }
        topicFollowButton.frame = CGRect(x: UIScreen.main.bounds.width - 10 - 60, y: (headerSectionHeight - 25) / 2.0, width: 60, height: 25)
        topicFollowButton.layer.cornerRadius = 2
        topicFollowButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        if model.followStatus {
            topicFollowButton.setTitleColor(TSColor.main.theme, for: .normal)
            topicFollowButton.backgroundColor = UIColor.white
            topicFollowButton.setTitle("已关注", for: .normal)
            topicFollowButton.layer.borderColor = TSColor.main.theme.cgColor
            topicFollowButton.layer.borderWidth = 0.5
        } else {
            topicFollowButton.setTitleColor(UIColor.white, for: .normal)
            topicFollowButton.backgroundColor = TSColor.main.theme
            topicFollowButton.setTitle("+ 关注", for: .normal)
        }
        topicFollowButton.addTarget(self, action: #selector(topicFollowButtonClick(sender:)), for: .touchUpInside)
    }

    /// 点击了过滤按钮
    func filterButtonTaped() {
        // 获取过滤按钮在屏幕上的位置
        let screenOriginal = contentView.convert(filterButton.frame.origin, to: UIApplication.shared.keyWindow)
        let alertTableOriginal = CGPoint(x: screenOriginal.x - 27 - 5, y: screenOriginal.y + 25 + 10)
        let filterAlert = FilterSectionViewAlert(tableOriginal: alertTableOriginal, filterInfo: model.filterInfo, selectedIndex: currentIndex) { [weak self] (seletedIndex) in
            guard let weakself = self else {
                return
            }
            // 1.更新界面
            weakself.currentIndex = seletedIndex
            weakself.loadFilterButton()
            // 2.调用代理
            weakself.delegate?.filterSectionView(weakself, didSeleteNewAtIndex: seletedIndex)
        }
        parentViewController?.present(filterAlert, animated: false, completion: nil)
    }

    func topicFollowButtonClick(sender: UIButton) {
        self.delegate?.followButtonClick?(self, button: sender)
    }

}

class FilterSectionViewAlert: UIViewController {

    /// 选择列表
    let table = UITableView()
    /// 数据
    var filterInfo: [String]
    /// 选中坐标
    var selectedIndex: Int
    /// 选中事件
    var selectedAction: (Int) -> Void
    /// 点击坐标
    var tableOriginal: CGPoint

    init(tableOriginal: CGPoint, filterInfo: [String], selectedIndex: Int, selectedAction: @escaping (Int) -> Void) {
        self.filterInfo = filterInfo
        self.selectedIndex = selectedIndex
        self.selectedAction = selectedAction
        self.tableOriginal = tableOriginal
        super.init(nibName: nil, bundle: nil)
        // present后的透明展示
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        // 1.设置背景颜色
        view.backgroundColor = UIColor(white: 0, alpha: 0.25)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAlert))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        // 2.列表
        table.register(FilterAlertCell.self, forCellReuseIdentifier: FilterAlertCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .white
        table.layer.cornerRadius = 4
        table.clipsToBounds = true
        table.rowHeight = 38
        table.frame = CGRect(origin: tableOriginal, size: CGSize(width: 100, height: 38 * filterInfo.count))
        view.addSubview(table)
    }

    func dismissAlert() {
        dismiss(animated: false, completion: nil)
    }

}

extension FilterSectionViewAlert: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: FilterAlertCell.identifier, for: indexPath) as! FilterAlertCell
        cell.load(title: filterInfo[indexPath.row], isSelected: selectedIndex == indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        table.reloadData()
        selectedAction(selectedIndex)
        dismissAlert()
    }

}

extension FilterSectionViewAlert: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view?.isDescendant(of: table) != true
    }
}

class FilterAlertCell: UITableViewCell {

    static let identifier = "FilterAlertCell"

    /// 标题
    let titleLabel = UILabel()
    /// 勾勾
    let markImageViwe = UIImageView()
    /// 分割线
    let seperator = UIView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(markImageViwe)
        contentView.addSubview(seperator)
    }

    func load(title: String, isSelected: Bool) {
        // 标题
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.text = title
        titleLabel.textColor = isSelected ? UIColor(hex: 0x666666) : UIColor(hex: 0x999999)
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(origin: CGPoint(x: 8, y: (37 - titleLabel.size.height) / 2), size: titleLabel.size)
        // 勾勾
        markImageViwe.isHidden = !isSelected
        markImageViwe.contentMode = .center
        markImageViwe.image = UIImage(named: "IMG_ico_quora_question_select")
        markImageViwe.frame = CGRect(origin: CGPoint(x: (100 - markImageViwe.size.width - 12), y: (37 - markImageViwe.size.height) / 2), size: markImageViwe.size)
        // 分割线
        seperator.backgroundColor = UIColor(hex: 0xededed)
        seperator.frame = CGRect(x: 0, y: 37, width: 100, height: 1)
    }
}
