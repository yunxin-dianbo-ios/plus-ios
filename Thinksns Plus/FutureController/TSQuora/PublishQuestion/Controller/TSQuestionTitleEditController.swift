//
//  TSQuestionTitleEditController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 04/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问答发布 - 标题编辑界面
//  注1：进入编辑界面应传入编辑类型，且修改需传入问题详情，且每次往下传时也需要传入编辑类型
//  注2：从不页面进入，需要传入对应所需的数据类型，具体参考TSQuoraEditType
//  注3: 关于优化的一个思路：提供不同的改造方法传参，而不是通过init()然后对其他属性赋值的方案。

import UIKit
import Alamofire

///  问答编辑类型
enum TSQuoraEditType {
    // 发布分为2种类型的原因：正常发布 和 +号发布 取消发布时/发布成功进入详情页返回 这里的处理是不一样的。因为来源不一样
    /// 正常发布：从问答主页TSQuoraHomeController中进入
    case normalPublish
    /// +号发布：从标签栏上的+号按钮点击进入
    case addPublish
    /// 话题发布: 从话题详情页进入，注：需传入当前话题
    case topicPublish
    /// 搜索发布：从搜索页进入，注：需传入当前搜索的关键字作为当前问题的标题使用
    case searchPublish
    /// 修改问答：传入问题详情
    case update
    /// 草稿: 草稿既可能是发布问题的，也可能是修改问题的
    case draft
}

protocol TSQuestionTitleEditControllerProtocol: class {
    /// 保存草稿的回调
    func didSaveDraft(_ draft: TSQuestionDraftModel) -> Void
}

class TSQuestionTitleEditController: TSViewController {

    // MARK: - Internal Property
    /// 回调
    weak var delegate: TSQuestionTitleEditControllerProtocol?
    var saveDraftAction: ((_ draft: TSQuestionDraftModel) -> Void)?
    /// 编辑类型
    var type: TSQuoraEditType = .normalPublish
    /// 当前编辑模型
    var contributeModel: TSQuestionContributeModel?
    /// 待编辑的问题详情
    var updatedQuestion: TSQuestionDetailModel?
    /// 当前话题模型，从话题详情页进入需要传入
    var currentTopic: TSQuoraTopicModel?
    /// 搜索发布时，传入的搜索关键字
    var searchKeyword: String?
    /// 草稿修改时，传入的草稿
    var draftModel: TSQuestionDraftModel?

    // MARK: - Internal Function
    // MARK: - Private Property

    fileprivate var sourceList: [TSQuoraDetailModel] = [TSQuoraDetailModel]()

    /// 导航栏上的下一步按钮
    private weak var nextBtn: UIButton!
    fileprivate weak var tableView: TSTableView!
    fileprivate weak var titleInputView: TSOriginalCenterOneInputView!

    /// 标题的最大长度
    fileprivate let titleMaxLen: Int = 50
    /// 标题的最小长度，暂未使用
    fileprivate let titleMinLen: Int = 20

    /// 问题标题联想时每次请求的限制条数
    private let limit: Int = TSAppConfig.share.localInfo.limit
    /// 联想相关的偏移
    private var offset: Int = 0
    /// 上一个联想请求
    private var lastRequest: DataRequest?

    /// 当前搜索框中标题
    fileprivate var currentTitle: String? {
        return self.titleInputView.text
    }

    // MARK: - Initialize Function

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }

    // MARK: - Private  UI

    private func initialUI() -> Void {
        self.view.backgroundColor = UIColor.white
        // navigation bar
        self.navigationItem.title = "标题_发布问题".localized
        let backItem = UIButton(type: .custom)
        backItem.addTarget(self, action: #selector(backItemClick), for: .touchUpInside)
        self.setupNavigationTitleItem(backItem, title: "显示_导航栏_返回".localized)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backItem)
        let nextItem = UIButton(type: .custom)
        nextItem.addTarget(self, action: #selector(nextItemClick), for: .touchUpInside)
        self.setupNavigationTitleItem(nextItem, title: "显示_下一步".localized)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextItem)
        nextItem.setTitleColor(UIColor.lightGray, for: .disabled)
        self.nextBtn = nextItem
        // titleInputView - 标题输入框不属于tableView的header，不跟着滑动，有最大字数限定
        let font = UIFont.systemFont(ofSize: 17)
        let titleInputView = TSOriginalCenterOneInputView(viewWidth: ScreenWidth, font: font, maxLine: 5, showTextMinCount: 15, maxTextCount: 50, lrMargin: 15, tbMargin: (50.0 - font.lineHeight) / 2.0)
        self.view.addSubview(titleInputView)
        titleInputView.delegate = self
        titleInputView.placeHolder = "占位符_请输入问题并以问号结尾".localized
        titleInputView.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
        titleInputView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.view)
            make.height.equalTo(50)
        }
        self.titleInputView = titleInputView
        // tableView
        let tableView = TSTableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self.view)
            make.top.equalTo(titleInputView.snp.bottom)
        }
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        // 暂定需求：展示20条相关问题
        tableView.mj_footer = nil
        self.tableView = tableView
    }

    // MARK: - Private  数据处理与加载

    private func initialDataSource() -> Void {
        // 直接发布的
        self.contributeModel = TSQuestionContributeModel()
        // 配置各自类型下的contributeModel
        switch self.type {
        case .addPublish:
            fallthrough
        case .normalPublish:
            break
        case .searchPublish:
            self.contributeModel?.title = self.searchKeyword
        case .topicPublish:
            self.contributeModel?.topics = [self.currentTopic!]
        case .update:
            // 根据问答详情配置contributeModel，待完成
            if let quoraDetail = self.updatedQuestion {
                self.contributeModel = TSQuestionContributeModel(quora: quoraDetail)
            }
        case .draft:
            /// 草稿模型，就是问题发布模型
            if let draftModel = self.draftModel {
                self.contributeModel = draftModel
            }
        }
        self.titleInputView.text = self.contributeModel?.title
        self.couldNextProcess()
        self.requestData(type: .initial)
    }
    /// 刷新数据
    @objc private func refresh() -> Void {
        self.requestData(type: .refresh)
    }
    /// 加载更多
    /// 注：根据需求，展示20条相关问题，所以不需要上拉加载更多
    @objc private func loadMore() -> Void {
        self.requestData(type: .loadmore)
    }
    /// 数据加载
    fileprivate func requestData(type: TSListDataLoadType) -> Void {
        guard let title = self.titleInputView.text else {
            return
        }
        // 当输入框内容为空时，展示空白
        if title.isEmpty || title == "" {
            self.sourceList.removeAll()
            self.offset = self.sourceList.count
            self.tableView.reloadData()
            return
        }
        switch type {
        case .initial:
            fallthrough
        case .refresh:
            self.offset = 0
        case .loadmore:
            break
        }
        // 取消掉上一次请求，并重新请求
        self.lastRequest?.cancel()
        self.lastRequest = TSQuoraNetworkManager.getRelativeQuoras(subject: title, offset: self.offset, complete: { (searchTitle, questionList, _, status) in
            switch type {
            case .initial:
                self.sourceList.removeAll()
                break
            case .refresh:
                self.tableView.mj_header.endRefreshing()
            case .loadmore:
                self.tableView.mj_footer.endRefreshing()
            }
            // 这里应判断搜索字段是否与当前字段一致
            guard status, let questionList = questionList, self.currentTitle == searchTitle else {
                self.tableView.reloadData()
                return
            }
            // 数据加载处理
            switch type {
            case .initial:
                fallthrough
            case .refresh:
                self.sourceList = questionList
            case .loadmore:
                self.sourceList += questionList
            }
            self.offset = self.sourceList.count
            self.tableView.reloadData()
        })
    }

    /// next按钮是否可用/next操作是否可执行
    private func couldNext() -> Bool {
        var nextFlag: Bool = true
        guard let title = self.titleInputView.text else {
            return false
        }
        // 标题判空
        if title.isEmpty {
            nextFlag = false
        }
        // 待完成：标题是否有最小值
        return nextFlag
    }
    /// next按钮是否可用的判断与处理
    fileprivate func couldNextProcess() -> Void {
        self.nextBtn.isEnabled = self.couldNext()
    }
    /// 返回之前的页面
    fileprivate func backToFront() -> Void {
        if self.type == .addPublish {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Private  事件响应

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)  // 键盘关闭
    }
    /// 导航栏 取消按钮 点击响应
    @objc private func backItemClick() -> Void {
        self.view.endEditing(true)  // 键盘关闭
        // 判断是直接返回 还是 弹窗确认是否编辑过
        let title = self.titleInputView.text
        var popFlag: Bool = false   // 是否弹窗标记
        // 先判断当前输入框内是否有值
        if nil != title && !title!.isEmpty {
            popFlag = true
        }
        // 当前输入框内没有值，则判断发布模型
        if !popFlag, let model = self.contributeModel {
            if !model.isEmptyExceptTitle() {
                popFlag = true
            }
        }
        if popFlag {
            // 弹窗提示 是否放弃编辑
            var titles: [String] = ["选择_放弃编辑".localized]
            if self.type != .update {
                // 注：编辑问题，不保存草稿
                titles.append("选择_保存至草稿箱".localized)
            }
            let customAction = TSCustomActionsheetView(titles: titles)
            customAction.tag = 250
            customAction.delegate = self
            customAction.show()
        } else {
            self.backToFront()  // 返回之前的界面
        }
    }
    /// 导航栏 下一步按钮 点击响应
    @objc private func nextItemClick() -> Void {
        self.view.endEditing(true)  // 键盘关闭
        guard var title = self.titleInputView.text else {
            return
        }
        // 判断是不是只是问号 —— 只是?时点击下一步进行提示
        var couldFlag: Bool = true
        if title.isEmpty || title.trimmingCharacters(in: .whitespaces) == "" || title == "?" || title == "？" {
            couldFlag = false
        }
        if !couldFlag {
            let alert = TSIndicatorWindowTop(state: .faild, title: "提示信息_请输入正确的标题".localized)
            alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            return
        }
        // 判断问题是不是以问号结尾
        if !title.hasSuffix("?") && !title.hasSuffix("？") {
          title.append("?")
        }

        // 问题模型更新
        self.contributeModel?.title = title
        // 进入问题详情编辑界面
        UserDefaults.standard.set("question", forKey: "webEditorType")
        UserDefaults.standard.synchronize()
        let detailEditVC = TSQuestionWebEditorController(type: self.type)
        detailEditVC.contributeModel = self.contributeModel
        self.navigationController?.pushViewController(detailEditVC, animated: true)
    }

    // MARK: - Notification

}

// MARK: - Delegate Function

// MARK: - UITableViewDataSource

extension TSQuestionTitleEditController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sourceList.isEmpty ? 0 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TSQuestionRelativeCell.cellInTableView(tableView)
        cell.question = self.sourceList[indexPath.row].title
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TSQuestionTitleEditController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        // 推荐问题选中，进入问题详情页
        let quoraModel = self.sourceList[indexPath.row]
        let questionDetailVC = TSQuestionDetailController()
        questionDetailVC.questionId = quoraModel.id
        self.navigationController?.pushViewController(questionDetailVC, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

// MARK: - TSOriginalCenterOneInputViewProtocol

extension TSQuestionTitleEditController: TSOriginalCenterOneInputViewProtocol {
    func inputView(_ inputView: TSOriginalCenterOneInputView, didLoadedWith minHeight: CGFloat) {
        let height: CGFloat = minHeight > 50.0 ? minHeight : 50.0
        self.titleInputView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        self.view.layoutIfNeeded()
    }
    func inputView(_ inputView: TSOriginalCenterOneInputView, didTextValueChanged newText: String) {
        // 下一步按钮的可用性判断
        self.couldNextProcess()
        // 联想请求
        self.requestData(type: .initial)
    }
    func inputView(_ inputView: TSOriginalCenterOneInputView, didHeightChanged newHeight: CGFloat) {
        let height: CGFloat = newHeight > 50.0 ? newHeight : 50.0
        self.titleInputView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        self.view.layoutIfNeeded()
    }
}

// MARK: - TSCustomAcionSheetDelegate

extension TSQuestionTitleEditController: TSCustomAcionSheetDelegate {
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if view.tag == 250 {     // tag == 250，放弃编辑
            switch index {
            case 0:
                // 放弃编辑
                // 如果不是编辑草稿箱/二次编辑问题就需要清楚图片缓存，这两种情况保留
                if self.type != .draft && self.type != .update {
                    if let fileIds = self.contributeModel?.content?.ts_getCustomMarkdownImageId() {
                        // 移除缓存图片
                        TSWebEditorImageManager.default.deleteImages(fileIds: fileIds)
                    }
                }

                self.backToFront()  // 返回之前的界面
            case 1:
                // 保存到草稿箱
                // 注：目前暂定的需求为 不保存发布问题的编辑，即发布问题的编辑返回时不提示保存草稿箱.
                guard let model = self.contributeModel else {
                    self.backToFront()  // 返回之前的界面
                    return
                }
                if self.type == .draft {
                    // 编辑旧的草稿
                    model.title = self.currentTitle
                    TSDatabaseManager().draft.updateQuestionDraft(model)
                    self.delegate?.didSaveDraft(model)
                    self.saveDraftAction?(model)
                } else {
                    // 添加新草稿
                    model.title = self.currentTitle
                    TSDatabaseManager().draft.addQuestionDraft(model)
                }
                self.backToFront()  // 返回之前的界面
            default:
                break
            }
        }
    }
}
