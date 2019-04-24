//
//  TSDraftController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 23/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  草稿箱页面

import UIKit

/// 草稿类型
enum TSDraftType: Int {
    /// 提问
    case question = 0
    /// 答案
    case answer
    /// 圈子帖子
    case post
}

class TSDraftController: TSViewController {

    // MARK: - Internal Property
    // MARK: - Private Property

    /// 当前展示的(选中的)草稿类型
    fileprivate var currentType: TSDraftType = .question
    fileprivate weak var currentTypeBtn: UIButton?
    fileprivate weak var currentTableView: TSTableView?

    /// draftTypeSelectView
    fileprivate weak var typeSelectView: UIView!
    fileprivate weak var slider: UIView!
    /// draftScrollView
    fileprivate weak var draftScrollView: UIScrollView!

    /// typeSelect
    fileprivate let typeSelectH: CGFloat = 44
    fileprivate let lrMargin: CGFloat = 20
    fileprivate var btnWidth: CGFloat {
        return (ScreenWidth - self.lrMargin * 2.0) / CGFloat(titles.count)
    }

    fileprivate var tagbase: Int = 250

    /// types
    fileprivate let titles = ["显示_提问".localized, "显示_回答".localized, "显示_帖子".localized]

    /// 数据源列表
    fileprivate var questionList: [TSQuestionDraftModel] = [TSQuestionDraftModel]()
    fileprivate var answerList: [TSAnswerDraftModel] = [TSAnswerDraftModel]()
    fileprivate var postList: [TSPostDraftModel] = [TSPostDraftModel]()

    /// 当前弹窗响应的indexPath
    fileprivate var currentIndexPath: IndexPath?

    // MARK: - Initialize Function
    // MARK: - Internal Function
    // MARK: - Override Function

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
        self.currentTypeBtn = self.typeSelectView.viewWithTag(self.tagbase) as? UIButton
        self.currentTypeBtn?.isSelected = true
    }

    // MARK: - Private  UI

    fileprivate func initialUI() -> Void {
        self.view.backgroundColor = UIColor.white
        // 1. navigationbar
        self.navigationItem.title = "标题_草稿箱".localized
        // 2. typeSelectView
        let selectView = UIView()
        self.view.addSubview(selectView)
        self.initialTypeSelectView(selectView)
        selectView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.view)
            make.height.equalTo(self.typeSelectH)
        }
        self.typeSelectView = selectView
        // 3. typeScrollView
        let scrollView = UIScrollView()
        self.view.addSubview(scrollView)
        self.initialDraftScrollView(scrollView)
        scrollView.delegate = self
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(selectView.snp.bottom)
            make.leading.trailing.bottom.equalTo(self.view)
        }
        self.draftScrollView = scrollView
    }
    /// 类型选择视图
    fileprivate func initialTypeSelectView(_ selectView: UIView) -> Void {
        // buttons
        for (index, title) in self.titles.enumerated() {
            let button = UIButton(type: .custom)
            selectView.addSubview(button)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.setTitleColor(TSColor.normal.minor, for: .normal)
            button.setTitleColor(TSColor.main.content, for: .selected)
            button.tag = self.tagbase + index
            button.addTarget(self, action: #selector(draftTypeBtnClick(_:)), for: .touchUpInside)
            button.snp.makeConstraints({ (make) in
                make.top.bottom.equalTo(selectView)
                make.width.equalTo(self.btnWidth)
                make.leading.equalTo(selectView).offset(lrMargin + self.btnWidth * CGFloat(index))
            })
        }
        // 小滑块
        let slider = UIView(bgColor: TSColor.button.normal)
        selectView.addSubview(slider)
        slider.snp.makeConstraints { (make) in
            make.height.equalTo(1.5)
            make.width.equalTo(45)
            make.bottom.equalTo(selectView).offset(-0.5)
            make.centerX.equalTo(selectView.snp.leading).offset(lrMargin + self.btnWidth * 0.5) // 动画
        }
        self.slider = slider
        // bottomLine
        selectView.addLineWithSide(.inBottom, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: 0, margin2: 0)
    }
    /// 草稿箱
    fileprivate func initialDraftScrollView(_ scrollView: UIScrollView) -> Void {
        // 1. scrollView
        scrollView.backgroundColor = UIColor.white
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        // 2. typeTableView
        for (index, _) in self.titles.enumerated() {
            let tableView = TSTableView(frame: CGRect.zero, style: .plain)
            scrollView.addSubview(tableView)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .none
            tableView.tableFooterView = UIView()
            tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
            tableView.mj_footer = nil
            tableView.estimatedRowHeight = 250
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.backgroundColor = TSColor.normal.background
            tableView.tag = self.tagbase + index
            tableView.snp.makeConstraints({ (make) in
                make.width.equalTo(ScreenWidth)
                make.height.equalTo(ScreenHeight - 64.0 - self.typeSelectH)
                make.top.bottom.equalTo(scrollView)
                make.leading.equalTo(scrollView).offset(CGFloat(index) * ScreenWidth)
                if index == self.titles.count - 1 {
                    make.trailing.equalTo(scrollView)
                }
            })
        }
        self.currentTableView = scrollView.viewWithTag(self.tagbase + 0) as! TSTableView
    }

    // MARK: - Private  数据处理与加载

    fileprivate func initialDataSource() -> Void {
        // 加载3个列表
        for (index, _) in self.titles.enumerated() {
            let type = TSDraftType(rawValue: index)!
            self.loadDataWithType(type)
        }
    }

    /// 加载type类型的草稿数据
    fileprivate func loadDataWithType(_ type: TSDraftType) -> Void {
        var count: Int = 0
        switch type {
        case .question:
            self.questionList = TSDatabaseManager().draft.getQuestionDraftList()
            count = self.questionList.count
        case .answer:
            self.answerList = TSDatabaseManager().draft.getAnswerDraftList()
            count = self.answerList.count
        case .post:
            self.postList = TSDatabaseManager().draft.getPostDraftList()
            count = self.postList.count
        }
        if let tableView = self.draftScrollView.viewWithTag(self.tagbase + type.rawValue) as? TSTableView {
            if count.isEqualZero {
                tableView.show(placeholderView: .empty)
            } else {
                tableView.removePlaceholderViews()
            }
            tableView.reloadData()
        }
    }

    @objc fileprivate func refresh() -> Void {
        /// 刷新当前列表
        self.loadDataWithType(self.currentType)
        self.currentTableView?.mj_header.endRefreshing()
    }

    // MARK: - Private  事件响应

    /// 草稿箱类型按钮 点击
    @objc fileprivate func draftTypeBtnClick(_ button: UIButton) -> Void {
        let index = button.tag - self.tagbase
        // type
        self.currentTypeBtn?.isSelected = false
        button.isSelected = true
        self.currentTypeBtn = button
        self.currentType = TSDraftType(rawValue: index)!
        self.currentTableView = self.draftScrollView.viewWithTag(button.tag) as! TSTableView
        // 小滑块
        UIView.animate(withDuration: 0.25) {
            let offset = self.lrMargin + self.btnWidth * (CGFloat(index) + 0.5)
            self.slider.snp.updateConstraints { (make) in
                make.centerX.equalTo(self.typeSelectView.snp.leading).offset(offset)
            }
            self.view.layoutIfNeeded()
        }
        // scrollView
        let point = CGPoint(x: CGFloat(index) * ScreenWidth, y: 0)
        self.draftScrollView.setContentOffset(point, animated: true)
    }

    // MARK: - Notification
}

// MARK: - UIScrollViewDelegate

extension TSDraftController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 避免tableView滚动回调造成干扰
        if scrollView != self.draftScrollView {
            return
        }
        // 获取当前选中的页
        let page = Int(scrollView.contentOffset.x / ScreenWidth)
        // type
        self.currentType = TSDraftType(rawValue: page)!
        self.currentTypeBtn?.isSelected = false
        self.currentTypeBtn = self.typeSelectView.viewWithTag(self.tagbase + page) as? UIButton
        self.currentTypeBtn?.isSelected = true
        self.currentTableView = self.draftScrollView.viewWithTag(self.tagbase + page) as? TSTableView
        // 小滑块
        UIView.animate(withDuration: 0.25) {
            let offset = self.lrMargin + self.btnWidth * (CGFloat(page) + 0.5)
            self.slider.snp.updateConstraints { (make) in
                make.centerX.equalTo(self.typeSelectView.snp.leading).offset(offset)
            }
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource

extension TSDraftController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount: Int = 0
        let draftType = TSDraftType(rawValue: tableView.tag - self.tagbase)!
        switch draftType {
        case .question:
            rowCount = self.questionList.count
        case .answer:
            rowCount = self.answerList.count
        case .post:
            rowCount = self.postList.count
        }
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let draftType = TSDraftType(rawValue: tableView.tag - self.tagbase)!
        switch draftType {
        case .question:
            // 问题草稿
            let model = self.questionList[indexPath.row]
            let cell = TSQuestionDraftCell.cellInTableView(tableView)
            cell.model = model
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        case .answer:
            // 答案草稿
            let model = self.answerList[indexPath.row]
            let cell = TSAnswerDraftCell.cellInTableView(tableView)
            cell.model = model
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        case .post:
            // 帖子草稿
            let model = self.postList[indexPath.row]
            let cell = TSPostDraftCell.cellInTableView(tableView)
            cell.model = model
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension TSDraftController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let index = tableView.tag - self.tagbase
        let type = TSDraftType(rawValue: index)!
        // 只有答案草稿才是点击进入草稿编辑界面
         self.updateDraft(type: type, index: indexPath.row)
//        if type == .answer {
//
//        }
    }
}

// MARK: - TSQuestionDraftCellProtocol
/// 问题草稿cell代理回调
extension TSDraftController: TSQuestionDraftCellProtocol {
    /// 问题草稿cell的更多响应
    func didClickMoreBtnInQuestionDraftCell(_ cell: TSQuestionDraftCell) -> Void {
        guard let indexPath = cell.indexPath, let tableView = self.currentTableView else {
            return
        }
        self.currentIndexPath = indexPath
        let rectInTableView = tableView.rectForRow(at: indexPath)
        let rect = tableView.convert(rectInTableView, to: self.view)
        //let popView = TSQuoraDraftMorePopView(topMargin: rect.origin.y + rectInTableView.size.height, rightMargin: 20, type: .question)
        let popView = TSDraftMorePopView(topMargin: rect.origin.y + rectInTableView.size.height, rightMargin: 20, type: .question)
        self.view.addSubview(popView)
        popView.delegate = self
        popView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}

// MARK: - TSAnswerDraftCellProtocol
/// 答案草稿cell代理回调
extension TSDraftController: TSAnswerDraftCellProtocol {
    func didClickMoreBtnInAnswerDraftCell(_ cell: TSAnswerDraftCell) -> Void {
        guard let indexPath = cell.indexPath, let tableView = self.currentTableView else {
            return
        }
        self.currentIndexPath = indexPath
        let rectInTableView = tableView.rectForRow(at: indexPath)
        let rect = tableView.convert(rectInTableView, to: self.view)
        //let popView = TSQuoraDraftMorePopView(topMargin: rect.origin.y + rectInTableView.size.height, rightMargin: 20, type: .answer)
        let popView = TSDraftMorePopView(topMargin: rect.origin.y + rectInTableView.size.height, rightMargin: 20, type: .answer)
        self.view.addSubview(popView)
        popView.delegate = self
        popView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}

// MARK: - TSAnswerDraftCellProtocol
/// 帖子草稿cell代理回调
extension TSDraftController: TSPostDraftCellProtocol {
    func didClickMoreBtnInPostDraftCell(_ cell: TSPostDraftCell) {
        guard let indexPath = cell.indexPath, let tableView = self.currentTableView else {
            return
        }
        self.currentIndexPath = indexPath
        let rectInTableView = tableView.rectForRow(at: indexPath)
        let rect = tableView.convert(rectInTableView, to: self.view)
        //let popView = TSQuoraDraftMorePopView(topMargin: rect.origin.y + rectInTableView.size.height, rightMargin: 20, type: .answer)
        let popView = TSDraftMorePopView(topMargin: rect.origin.y + rectInTableView.size.height, rightMargin: 20, type: .post)
        self.view.addSubview(popView)
        popView.delegate = self
        popView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}

// MARK: - TSDraftMorePopViewProtocol
// 草稿更多弹窗回调
extension TSDraftController: TSDraftMorePopViewProtocol {
    /// 编辑草稿点击回调
    func didClicKUpdateDraftInDraftPopView(_ popView: TSDraftMorePopView) -> Void {
        guard let indexPath = self.currentIndexPath else {
            return
        }
        self.updateDraft(type: popView.type, index: indexPath.row)
    }
    /// 删除草稿点击回调
    func didClickDeleteDraftInDraftPopView(_ popView: TSDraftMorePopView) -> Void {
        guard let indexPath = self.currentIndexPath else {
            return
        }
        self.showDraftDeleteConfirmAlert(type: popView.type, index: indexPath.row)
    }
    /// 查看问题点击回调
    func didClickViewQuestionInDraftPopView(_ popView: TSDraftMorePopView) -> Void {
        guard let indexPath = self.currentIndexPath else {
            return
        }
        self.viewQuestion(index: indexPath.row)
    }
    /// 遮罩点击回调
    func didClickCoverInDraftPopView(_ popView: TSDraftMorePopView) -> Void {
        self.currentIndexPath = nil
    }
}

// 扩展，主要是草稿cell的更多选项里的回调响应
extension TSDraftController {

    /// 删除指定草稿的二次确认弹窗显示
    fileprivate func showDraftDeleteConfirmAlert(type: TSDraftType, index: Int) -> Void {
        let alertVC = TSAlertController.deleteConfirmAlert(deleteActionTitle: "删除草稿") {
            self.deleteDraft(type: type, index: index)
        }
        self.present(alertVC, animated: false, completion: nil)
    }

    /// 删除指定草稿响应
    fileprivate func deleteDraft(type: TSDraftType, index: Int) -> Void {
        var fileIds: [Int]?
        // 数据库删除、数据源删除
        switch type {
        case .question:
            let model = self.questionList.remove(at: index)
            TSDatabaseManager().draft.deleteQuestionDraft(draftId: model.draftId)
            if self.questionList.isEmpty {
                self.currentTableView?.show(placeholderView: .empty)
            }
            fileIds = model.content?.ts_getCustomMarkdownImageId()
        case .answer:
            let model = self.answerList.remove(at: index)
            TSDatabaseManager().draft.deleteAnswerDraft(draftId: model.draftId)
            if self.answerList.isEmpty {
                self.currentTableView?.show(placeholderView: .empty)
            }
            fileIds = model.markdown.ts_getCustomMarkdownImageId()
        case .post:
            let model = self.postList.remove(at: index)
            TSDatabaseManager().draft.deletePostDraft(draftId: model.draftId)
            if self.postList.isEmpty {
                self.currentTableView?.show(placeholderView: .empty)
            }
            fileIds = model.markdown?.ts_getCustomMarkdownImageId()
        }
        self.currentTableView?.reloadData()
        // 缓存图片移除
        if let fileIds = fileIds {
            TSWebEditorImageManager.default.deleteImages(fileIds: fileIds)
        }
    }
    /// 修改指定草稿响应
    fileprivate func updateDraft(type: TSDraftType, index: Int) -> Void {
        switch type {
        case .question:
            // 进入问题编辑界面
            var model = self.questionList[index]
            let questionEditVC = TSQuestionTitleEditController()
            questionEditVC.type = .draft
            questionEditVC.draftModel = model
            questionEditVC.saveDraftAction = { [weak self](draftModel) in
                if model.draftId == draftModel.draftId {
                    model = draftModel
                    self?.currentTableView?.reloadData()
                }
            }
            self.navigationController?.pushViewController(questionEditVC, animated: true)
        case .answer:
            // 进入答案草稿的编辑界面
            // 注：问题草稿的更多按钮有编辑问题选项，但答案草稿的更多按钮没有编辑答案选项。
            var model = self.answerList[index]
            let editVC = TSPublishAnswerController(draft: model)
            editVC.saveDraftAction = { [weak self] (draftModel) in
                if draftModel.draftId == model.draftId {
                    model = draftModel
                    self?.currentTableView?.reloadData()
                }
            }
            self.navigationController?.pushViewController(editVC, animated: true)
        case .post:
            // 进入帖子编辑界面
            var model = self.postList[index]
            let postEditVC = PostPublishController(draft: model)
            postEditVC.saveDraftAction = { [weak self] (draftModel) in
                if draftModel.draftId == model.draftId {
                    model = draftModel
                    self?.currentTableView?.reloadData()
                }
            }
            self.navigationController?.pushViewController(postEditVC, animated: true)
        }
    }
    /// 查看问题 - 进入问题详情
    fileprivate func viewQuestion(index: Int) -> Void {
        // 只有答案草稿的更多弹窗里才有 查看问题选项
        let model = self.answerList[index]
        let questionDetailVC = TSQuestionDetailController()
        questionDetailVC.questionId = model.questionId
        self.navigationController?.pushViewController(questionDetailVC, animated: true)
    }
}
