//
//  GroupIncomeDetailController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  圈子收益主界面(收益总览)

import UIKit

class GroupIncomeDetailController: TSViewController {
    // MARK: - Internal Property

    let groupId: Int
    var groupModel: GroupModel?

    // MARK: - Internal Function
    // MARK: - Private Property

    fileprivate let lrMargin: CGFloat = 15

    /// 总输入名称Label - 用于更换货币单位
    fileprivate weak var incomeNameLabel: UILabel!
    /// 总输入数值
    fileprivate weak var incomeNumLabel: UILabel!
    /// 成员费 数值
    fileprivate weak var memberIncomeNumLabel: UILabel!
    /// 置顶收益 数值
    fileprivate weak var pinnedIncomNumLabel: UILabel!

    /// 列表子项的tag基值
    fileprivate let incomeOptionTagBase: Int = 250

    // MARK: - Initialize Function

    init(groupId: Int, groupModel: GroupModel?) {
        self.groupId = groupId
        self.groupModel = groupModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

}

// MARK: - UI

extension GroupIncomeDetailController {
    /// 页面布局
    fileprivate func initialUI() -> Void {

        // topView
        let topView = UIView(bgColor: TSColor.main.theme)
        self.view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self.view)
        }
        self.initialTopView(topView)
        // incomeListView
        let incomeListView = UIView(bgColor: UIColor.white)
        self.view.addSubview(incomeListView)
        incomeListView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.equalTo(self.view)
        }
        self.initialIncomelistView(incomeListView)

    }

    /// 顶部视图初始化
    fileprivate func initialTopView(_ topView: UIView) -> Void {
        // 1. 自定义导航栏
        let barView = UIView()
        topView.addSubview(barView)
        self.initialCustomNavigationBarView(barView)
        barView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(topView)
            make.top.equalTo(topView).offset(TSStatusBarHeight)
            make.height.equalTo(44)
        }
        // 2. 总收益
        // 2.1 总收益标题
        let incomeNameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: UIColor(hex: 0xb3ffff))
        topView.addSubview(incomeNameLabel)
        incomeNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(barView.snp.bottom).offset(28)
            make.leading.equalTo(self.lrMargin)
        }
        self.incomeNameLabel = incomeNameLabel
        // 2.2 总收益数字
        let incomeNumLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 50), textColor: UIColor.white)
        topView.addSubview(incomeNumLabel)
        incomeNumLabel.snp.makeConstraints { (make) in
            make.top.equalTo(incomeNameLabel.snp.bottom).offset(40)
            make.bottom.equalTo(topView).offset(-28)
            make.leading.equalTo(incomeNameLabel)
        }
        self.incomeNumLabel = incomeNumLabel
    }
    /// 自定义导航栏视图初始化
    fileprivate func initialCustomNavigationBarView(_ barView: UIView) -> Void {
        // MARK: - 导航栏应考虑能兼容音乐按钮的那个  或者 写个能通用的公用组件

        // 1. 导航栏返回按钮
        let leftBtn = UIButton(type: .custom)
        barView.addSubview(leftBtn)
        leftBtn.setImage(#imageLiteral(resourceName: "IMG_topbar_back_white"), for: .normal)
        leftBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        leftBtn.addTarget(self, action: #selector(leftBarItemClick), for: .touchUpInside)
        leftBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(barView)
            make.leading.equalTo(barView).offset(lrMargin - 5)
        }
        // 2. 导航栏标题
        let titleLabel = UILabel(text: "标题_圈子_圈子收益".localized, font: UIFont.systemFont(ofSize: 18), textColor: UIColor.white, alignment: .center)
        barView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(barView)
        }
        // 3. 导航栏右侧按钮
        let rightBtn = UIButton(type: .custom)
        barView.addSubview(rightBtn)
        rightBtn.setTitle("显示_明细".localized, for: .normal)
        rightBtn.setTitleColor(UIColor.white, for: .normal)
        rightBtn.contentHorizontalAlignment = .right
        rightBtn.addTarget(self, action: #selector(rightBarItemClick), for: .touchUpInside)
        rightBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(barView)
            make.trailing.equalTo(barView).offset(-lrMargin)
        }
    }

    /// 收入列表视图初始化
    fileprivate func initialIncomelistView(_ listView: UIView) -> Void {
        let controlH: CGFloat = 50
        let titles = ["显示_成员费".localized, "显示_置顶收益".localized]
        for (index, title) in titles.enumerated() {
            let control = UIControl()
            listView.addSubview(control)
            control.backgroundColor = UIColor.white
            control.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
            control.addTarget(self, action: #selector(incomeControlClick(_:)), for: .touchUpInside)
            control.tag = self.incomeOptionTagBase + index
            control.snp.makeConstraints({ (make) in
                make.leading.trailing.equalTo(listView)
                make.top.equalTo(listView).offset(CGFloat(index) * controlH)
                make.height.equalTo(controlH)
                if index == titles.count - 1 {
                    make.bottom.equalTo(listView)
                }
            })
            let rightLabel = self.initialSingleIncomeView(control, title: title)
            if 0 == index {
                self.memberIncomeNumLabel = rightLabel
            } else if 1 == index {
                self.pinnedIncomNumLabel = rightLabel
            }
        }
    }
    /// 初始化单项收入视图，并返回右侧标题
    fileprivate func initialSingleIncomeView(_ incomeView: UIView, title: String) -> UILabel {
        // 1. leftLabel
        let leftLabel = UILabel(text: title, font: UIFont.systemFont(ofSize: 16), textColor: TSColor.main.content)
        incomeView.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(incomeView)
            make.leading.equalTo(incomeView).offset(lrMargin)
        }
        // 2. rightArrow
        let rightArrow = UIImageView(image: #imageLiteral(resourceName: "IMG_ic_arrow_smallgrey"))
        incomeView.addSubview(rightArrow)
        rightArrow.snp.makeConstraints { (make) in
            make.centerY.equalTo(incomeView)
            make.trailing.equalTo(incomeView).offset(-lrMargin)
        }
        // 3. rightLabel
        let rightLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 16), textColor: UIColor(hex: 0xfca308), alignment: .right)
        incomeView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(incomeView)
            make.trailing.equalTo(rightArrow.snp.leading).offset(-8)
        }
        return rightLabel
    }
}

// MARK: - 数据处理与加载

extension GroupIncomeDetailController {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        // 如果不传入圈子详情模型，则请求圈子详情信息
        let goldName = TSAppConfig.share.localInfo.goldName
        self.incomeNameLabel.text =  "显示_总收益".localized + "(\(goldName))"
        if let groupModel = self.groupModel {
            self.setupWithModel(groupModel)
            return
        }
        // 网络请求 获取圈子信息
        GroupNetworkManager.getGroupInfo(groupId: groupId) { [weak self] (model, message, status) in
            guard let model = model else {
                self?.loadFaild(type: .network)
                return
            }
            self?.groupModel = model
            self?.setupWithModel(model)
        }
    }
    fileprivate func setupWithModel(_ model: GroupModel) -> Void {
        self.memberIncomeNumLabel.text = "\(model.joinIncomeCount)"
        self.pinnedIncomNumLabel.text = "\(model.pinnedIncomeCount)"
        self.incomeNumLabel.text = "\(model.joinIncomeCount + model.pinnedIncomeCount)"
    }
}

// MARK: - 事件响应

extension GroupIncomeDetailController {

    /// 导航栏左侧按钮 点击响应
    @objc fileprivate func leftBarItemClick() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }
    /// 导航栏右侧按钮 点击响应
    @objc fileprivate func rightBarItemClick() -> Void {
        let incomeListVC = GroupIncomeListController(groupId: self.groupId, type: .all)
        self.navigationController?.pushViewController(incomeListVC, animated: true)
    }
    /// 收入子项control 点击响应
    @objc fileprivate func incomeControlClick(_ control: UIControl) -> Void {
        let index = control.tag - self.incomeOptionTagBase
        switch index {
        case 0:
            /// 成员费
            let incomeListVC = GroupIncomeListController(groupId: self.groupId, type: .join)
            self.navigationController?.pushViewController(incomeListVC, animated: true)
        case 1:
            /// 置顶收益
            let incomeListVC = GroupIncomeListController(groupId: self.groupId, type: .pinned)
            self.navigationController?.pushViewController(incomeListVC, animated: true)
        default:
            break
        }
    }

}

// MARK: - Notification

extension GroupIncomeDetailController {

}

// MARK: - Delegate Function
