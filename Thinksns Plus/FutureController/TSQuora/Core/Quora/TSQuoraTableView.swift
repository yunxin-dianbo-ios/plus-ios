//
//  TSQuoraTableController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答列表
//
//  纯 UI 展示，所有交互事件由代理抛出
//
/*
 示例代码:
 
 let table = TSQuoraTableView(frame: labelCollectView.collection.bounds, tableIdentifier: "all")
 // 1.设置刷新操作代理事件
 table.refreshDelegate = self
 // 2.设置用户交互代理事件
 table.interactionDelegate = self
 
 // 3.获取数据
 let dataModel: TSQuoraDetailModel! // 网络请求获取 dataModel
 let cellModel = TSQuoraTableCellModel(model: dataModel)
 let newDatas = [cellModel1, cellModel2, ...]
 // 4.刷新界面
 table.processRefresh(newDatas: newDatas, errorMessage: message) // 用 newDatas 替换所有的旧数据
 table.processLoadMore(newDatas: newDatas, errorMessage: message) // 将 newDatas 加在旧数据中展示
 
 */

import UIKit

/// 问答列表刷新代理
@objc protocol TSQuoraTableRefreshDelegate: class {
    /// 下拉刷新
    @objc optional func table(_ table: TSQuoraTableView, refreshingDataOf tableIdentifier: String)
    /// 上拉加载
    @objc optional func table(_ table: TSQuoraTableView, loadMoreDataOf tableIdentifier: String)
}

/// 问答列表用户交互事件代理
@objc protocol TSQuoraTableViewDelegate: class {
    /// 点击了 cell 的标题部分
    @objc optional func table(_ table: TSQuoraTableView, didSelectTitleAt indexPath: IndexPath, with cellModel: TSQuoraTableCellModel)
    /// 点击了 cell 的回答部分
    @objc optional func table(_ table: TSQuoraTableView, didSelectAnswerAt indexPath: IndexPath, with cellModel: TSQuoraTableCellModel)
    /// 点击了 cell 的图片部分
    @objc optional func table(_ table: TSQuoraTableView, didSelectImageAt indexPath: IndexPath, with cellModel: TSQuoraTableCellModel)
    /// 点击了 cell 的底部按钮部分
    @objc optional func table(_ table: TSQuoraTableView, didSelectBottomAt indexPath: IndexPath, with cellModel: TSQuoraTableCellModel)
    /// 点击了关注按钮
    @objc optional func table(_ table: TSQuoraTableView, didSelectedFollow button: UIButton, at indexPath: IndexPath, of cell: QuoraStackBottomButtonsCell, with cellModel: TSQuoraTableCellModel)
    /// 点击了回答按钮
    @objc optional func table(_ table: TSQuoraTableView, didSelectedAnswer button: UIButton, at indexPath: IndexPath, of cell: QuoraStackBottomButtonsCell, with cellModel: TSQuoraTableCellModel)
    /// 点击了悬赏按钮
    @objc optional func table(_ table: TSQuoraTableView, didSelectedReward button: UIButton, at indexPath: IndexPath, of cell: QuoraStackBottomButtonsCell, with cellModel: TSQuoraTableCellModel)

}

class TSQuoraTableView: TSTableView {

    /// 数据类型，默认为 all
    var tableIdentifier = ""
    /// 数据源
    var datas: [TSQuoraTableCellModel] = []
    /// 刷新事件代理
    weak var refreshDelegate: TSQuoraTableRefreshDelegate?
    /// 用户交互代理事件
    weak var interactionDelegate: TSQuoraTableViewDelegate?
    /// 单页条数
    var listLimit = TSAppConfig.share.localInfo.limit

    /// 是否需要在刚显示时自动刷新
    var shouldAutoRefresh = true

    // MARK: - Lifecycle

    /// 初始化
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - identifier: table 区分标识符，当多个 TSQuoraTableView 同时存在同一个界面时区分彼此
    ///   - shouldAutoRefresh: 是否需要在刚显示时自动刷新
    init(frame: CGRect, tableIdentifier identifier: String, shouldAutoRefresh shouldRefresh: Bool) {
        super.init(frame: frame, style: .plain)
        tableIdentifier = identifier
        shouldAutoRefresh = shouldRefresh
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Custom user interface
    func setUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAnSwerLookStatus(notice:)), name: NSNotification.Name(rawValue: "reloadAnSwerLookStatus"), object: nil)
        delegate = self
        dataSource = self
        estimatedRowHeight = 500
        separatorStyle = .none
        backgroundColor = TSColor.inconspicuous.disabled
        // 注册标题 cell
        register(QuoraStackTitleCell.self, forCellReuseIdentifier: QuoraStackTitleCell.identifier)
        // 注册内容 cell
        register(QuoraStackAvatarContentCell.self, forCellReuseIdentifier: QuoraStackAvatarContentCell.identifier)
        // 注册图片 cell
        register(QuoraStackFullImageCell.self, forCellReuseIdentifier: QuoraStackFullImageCell.identifier)
        // 注册 关注/回答/悬赏/时间 cell
        register(QuoraStackBottomButtonsCell.self, forCellReuseIdentifier: QuoraStackBottomButtonsCell.identifier)
        // 注册分割线 cell
        register(StackSeperatorCell.self, forCellReuseIdentifier: StackSeperatorCell.identifier)
        if shouldAutoRefresh {
            mj_header.beginRefreshing()
        }
    }

    func reloadAnSwerLookStatus(notice: Notification) {
        guard let questionid = notice.userInfo?["questionid"] else {
            return
        }
        let queID: Int = questionid as! Int
        var reload = false
        for (index,item) in datas.enumerated() {
            if item.id == queID {
                item.contentModel?.shouldHiddenContent = false
                let answerUserName = (item.contentModel?.isAnonymity)! ? "匿名用户" : (item.contentModel?.user?.name ?? "")
                let answer = notice.userInfo?["bodyText"] as! String
                item.contentModel?.content = answerUserName  + "：" + answer
                reload = true
                break
            }
        }
        if reload {
            self.reloadData()
        }
    }

    // MARK: Data
    override func refresh() {
        refreshDelegate?.table?(self, refreshingDataOf: tableIdentifier)
    }

    override func loadMore() {
        refreshDelegate?.table?(self, loadMoreDataOf: tableIdentifier)
    }

    /// 处理下拉刷新的数据的界面刷新
    func processRefresh(newDatas: [TSQuoraTableCellModel]?, errorMessage: String?) {
        // 隐藏指示器
        dismissIndicatorA()
        if mj_header.isRefreshing() {
            mj_header.endRefreshing()
        }
        mj_footer.resetNoMoreData()
        // 获取数据失败，显示占位图或者 A 指示器
        if let message = errorMessage {
            datas.isEmpty ? show(placeholderView: .network) : show(indicatorA: message)
            return
        }
        // 获取数据成功，更新数据
        guard let newDatas = newDatas else {
            return
        }
        datas = newDatas
        // 如果数据为空，显示占位图
        if datas.isEmpty {
            show(placeholderView: .empty)
        }
        // 刷新界面
        reloadData()
    }

    /// 处理上拉加载的数据的界面刷新
    func processLoadMore(newDatas: [TSQuoraTableCellModel]?, errorMessage: String?) {
        // 获取数据失败，显示"网络失败"的 footer
        if errorMessage != nil {
            mj_footer.endRefreshingWithWeakNetwork()
            return
        }
        // 隐藏 A 指示器
        dismissIndicatorA()
        // 请求成功
        // 更新 datas，并刷新界面
        guard let newDatas = newDatas else {
            mj_footer.endRefreshing()
            return
        }
        datas = datas + newDatas
        // 判断新数据数量是否够一页。不够一页显示"没有更多"的 footer；够一页仅结束 footer 动画
        if newDatas.count < listLimit {
            mj_footer.endRefreshingWithNoMoreData()
        } else {
            mj_footer.endRefreshing()
        }
        reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TSQuoraTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = datas[indexPath.section].dataArray[indexPath.row]
        guard let model = data as? QuoraStackCellModel else {
            return 0
        }
        return model.cellHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = datas[indexPath.section].dataArray[indexPath.row]
        guard let model = data as? QuoraStackCellModel else {
            return 0
        }
        return model.cellHeight
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if !datas.isEmpty {
            removePlaceholderViews()
        }
        if mj_footer != nil {
            mj_footer.isHidden = datas.count < listLimit
        }
        return datas.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datas.isEmpty {
            return 0
        }
        return datas[section].dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1.获取 cell 数据
        let sectionData = datas[indexPath.section]
        let cellData = sectionData.dataArray[indexPath.row]
        // 2.判断数据模型的类型，加载对应的 cell
        var cell: UITableViewCell!
        // 2.1 加载标题 cell
        if var model = cellData as? QuoraStackTitleCellModel {
            let titleCell = QuoraStackTitleCell.cellForm(table: tableView, at: indexPath, with: &model)
            cell = titleCell
            datas[indexPath.section].titleModel = model
        }
        // 2.2 加载图片 cell
        if let model = cellData as? QuoraStackFullImageCellModel {
            let imageCell = QuoraStackFullImageCell.cellForm(table: tableView, at: indexPath, with: model)
            cell = imageCell
        }
        // 2.3 加载内容 cell
        if var model = cellData as? QuoraStackAvatarContentCellModel {
            let contentCell = QuoraStackAvatarContentCell.cellForm(table: tableView, at: indexPath, with: &model)
            cell = contentCell
            datas[indexPath.section].contentModel = model
        }
        // 2.4 加载 关注/回答/悬赏/时间 cell
        if var model = cellData as? QuoraStackBottomButtonsCellModel {
            let bottomInfoCell = QuoraStackBottomButtonsCell.cellForm(table: tableView, at: indexPath, with: &model)
            bottomInfoCell.delegate = self
            cell = bottomInfoCell
            datas[indexPath.section].bottomInfoModel = model
        }
        // 2.5 加载分割线 cell
        if let model = cellData as? StackSeperatorCellModel {
            let seperatorCell = StackSeperatorCell.cellForm(table: tableView, at: indexPath, with: model)
            cell = seperatorCell
        }
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = datas[indexPath.section]
        let cell = tableView.cellForRow(at: indexPath)
        // 点击了标题
        if cell is QuoraStackTitleCell {
            interactionDelegate?.table?(self, didSelectTitleAt: indexPath, with: data)
        }
        // 点击了回答
        if cell is QuoraStackAvatarContentCell {
            interactionDelegate?.table?(self, didSelectAnswerAt: indexPath, with: data)
        }
        // 点击了图片
        if cell is QuoraStackFullImageCell {
            interactionDelegate?.table?(self, didSelectImageAt: indexPath, with: data)
        }
        // 点击了底部
        if cell is QuoraStackBottomButtonsCell {
            interactionDelegate?.table?(self, didSelectBottomAt: indexPath, with: data)
        }
    }
}

extension TSQuoraTableView: QuoraStackBottomButtonsCellDelegate {
    /// 点击了关注按钮
    func bottomCell(_ cell: QuoraStackBottomButtonsCell, didSelectedFollow button: UIButton) {
        let indexPath = self.indexPath(for: cell)!
        interactionDelegate?.table?(self, didSelectedFollow: button, at: indexPath, of: cell, with: datas[indexPath.section])
    }
    /// 点击了回答按钮
    func bottomCell(_ cell: QuoraStackBottomButtonsCell, didSelectedAnswer button: UIButton) {
        let indexPath = self.indexPath(for: cell)!
        interactionDelegate?.table?(self, didSelectedAnswer: button, at: indexPath, of: cell, with: datas[indexPath.section])
    }
    /// 点击了悬赏按钮
    func bottomCell(_ cell: QuoraStackBottomButtonsCell, didSelectedReward button: UIButton) {
        let indexPath = self.indexPath(for: cell)!
        interactionDelegate?.table?(self, didSelectedReward: button, at: indexPath, of: cell, with: datas[indexPath.section])
    }
}
