//
//  File.swift
//  ThinkSNS +
//
//  Created by 小唐 on 11/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  答案草稿cell

import Foundation

protocol TSAnswerDraftCellProtocol: class {
    func didClickMoreBtnInAnswerDraftCell(_ cell: TSAnswerDraftCell) -> Void
}

class TSAnswerDraftCell: UITableViewCell {

    // MARK: - Internal Property
    /// 代理回调
    weak var delegate: TSAnswerDraftCellProtocol?
    /// 重用标识符
    static let identifier: String = "TSAnswerDraftCellReuseIdentifier"
    var model: TSAnswerDraftModel? {
        didSet {
            self.setupWithModel(model)
        }
    }
    // 当前indexPath
    var indexPath: IndexPath?

    // MARK: - Private Property
    private let leftMargin: CGFloat = 17        // 左侧间距
    private let rightMargin: CGFloat = 15       // 右侧间距
    private let titleTopMargin: CGFloat = 16    // 标题的上边距(距离整体顶部)
    private let contentTopMargin: CGFloat = 15  // 内容的上边距(距离标题底部)
    private let timeTopMargin: CGFloat = 15     // 时间的上边距(距离内容底部)
    private let timeBottomMargin: CGFloat = 16  // 时间的下边距(距离控件底部)

    /// 标题
    private weak var titleLabel: UILabel!
    /// 正文/答案
    private weak var contentLabel: UILabel!
    /// 时间
    private weak var timeLabel: UILabel!
    /// 更多
    private weak var moreBtn: UIButton!
    /// 底部线条 - 最后一个可能不展示
    private(set) weak var separateLine: UIView!

    // MARK: - Internal Function

    class func cellInTableView(_ tableView: UITableView) -> TSAnswerDraftCell {
        let identifier = TSAnswerDraftCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = TSAnswerDraftCell(style: .default, reuseIdentifier: identifier)
        }
        // 重置位置
        return cell as! TSAnswerDraftCell
    }

    // MARK: - Initialize Function

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Override Function

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // mainView - 整体布局，便于扩展，特别是针对分割、背景色、四周间距
        let mainView = UIView()
        self.contentView.addSubview(mainView)
        self.initialMainView(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }
    // 主视图布局
    private func initialMainView(_ mainView: UIView) -> Void {
        // 1. titleLabel
        let titleLabel = UILabel(text: "", font: UIFont.boldSystemFont(ofSize: 18), textColor: TSColor.main.content)
        mainView.addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(mainView).offset(titleTopMargin)
            make.leading.equalTo(mainView).offset(leftMargin)
            make.trailing.equalTo(mainView).offset(-rightMargin)
        }
        self.titleLabel = titleLabel
        // 2. contentLabel
        let contentLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15), textColor: TSColor.normal.content)
        mainView.addSubview(contentLabel)
        contentLabel.numberOfLines = 3
        contentLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(contentTopMargin)
        }
        self.contentLabel = contentLabel
        // 3. timeLabel
        let timeLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: TSColor.normal.disabled)
        mainView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(contentLabel.snp.bottom).offset(timeTopMargin)
            make.bottom.equalTo(mainView).offset(-timeBottomMargin)
        }
        self.timeLabel = timeLabel
        // 4. moreBtn
        let moreBtn = UIButton(type: .custom)
        mainView.addSubview(moreBtn)
        moreBtn.setImage(UIImage(named: "IMG_home_ico_more"), for: .normal)
        moreBtn.addTarget(self, action: #selector(moreBtnClick(_:)), for: .touchUpInside)
        moreBtn.snp.makeConstraints { (make) in
            make.bottom.trailing.equalTo(mainView)
            make.height.equalTo(12 + 15 * 2)
            make.width.equalTo(20 * 2 + 12)
        }
        self.moreBtn = moreBtn
        // 5. separeLine
        self.separateLine = mainView.addLineWithSide(.inBottom, color: TSColor.normal.placeholder, thickness: 0.5, margin1: leftMargin, margin2: 0)
    }

    // MARK: - Private  数据加载

    /// 数据模型加载
    fileprivate func setupWithModel(_ model: TSAnswerDraftModel?) -> Void {
        self.titleLabel.text = model?.questionTitle
        self.contentLabel.text = model?.content ?? model?.markdown.ts_customMarkdownToNormal()
        if let date = model?.updateDate {
            self.timeLabel.text = date.string(format: "MM-dd HH:mm", timeZone: nil)
        } else {
            self.timeLabel.text = nil
        }
    }

    // MARK: - Private  事件响应
    /// 更多按钮点击响应
    @objc private func moreBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickMoreBtnInAnswerDraftCell(self)
    }

}
