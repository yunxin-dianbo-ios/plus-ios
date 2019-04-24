//
//  TSAnswerListHeaderView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 28/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题详情页 中 答案列表中的 Section视图

import UIKit

protocol TSAnswerListHeaderViewProtocol: class {
    func didClickOrderTyp(in header: TSAnswerListHeaderView) -> Void
}

class TSAnswerListHeaderView: UITableViewHeaderFooterView {

    // MARK: - Internal Property
    weak var delegate: TSAnswerListHeaderViewProtocol?
    var orderTypeClickAction: ((_ header: TSAnswerListHeaderView) -> Void)?

    static let headerHeight: CGFloat = 37
    var answersCount: Int = 0 {
        didSet {
            self.answersCountLabel.text = "\(answersCount) 个回答"
        }
    }
    var orderType: TSAnserOrderType = .diggCount {
        didSet {
            switch orderType {
            case .publishTime:
                self.orderTypeLabel.text = "按时间排序"
            case .diggCount:
                self.orderTypeLabel.text = "默认排序"
            }
        }
    }

    // MARK: - Private Property
    private weak var answersCountLabel: UILabel!
    private weak var orderTypeControl: UIControl!
    private weak var orderTypeLabel: UILabel!

    // MARK: - Internal Function

    class func headerInTableView(_ tableView: UITableView) -> TSAnswerListHeaderView {
        let identifier = "TSAnswerListHeaderViewViewIdentifier"
        var headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if nil == headerFooterView {
            headerFooterView = TSAnswerListHeaderView(reuseIdentifier: identifier)
        }
        // 重置位置
        return headerFooterView as! TSAnswerListHeaderView
    }

    // MARK: - Initialize Function

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        let leftMargin: CGFloat = 15
        let rightMargin: CGFloat = leftMargin
        let btnCenterMargin: CGFloat = 10
        let btnIconW: CGFloat = 15
        let btnIconH: CGFloat = 11

        self.contentView.backgroundColor = TSColor.inconspicuous.background
        // 1. answersCount
        let answersCountLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: UIColor(hex: 0x999999))
        self.contentView.addSubview(answersCountLabel)
        answersCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.contentView)
            make.leading.equalTo(self.contentView).offset(leftMargin)
        }
        self.answersCountLabel = answersCountLabel
        // 2. orderType
        // Remark：这里使用UIControl代替UIbutton，主要是控件长度不定，而文左图右时需要计算文字长度，而文字会更改，更改后需同步更改文左图右的配置
        let orderTypeControl = UIControl()
        self.contentView.addSubview(orderTypeControl)
        orderTypeControl.addTarget(self, action: #selector(orderTypeControlClick(_:)), for: .touchUpInside)
        orderTypeControl.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self.contentView)
            make.trailing.equalTo(self.contentView).offset(-rightMargin)
        }
        self.orderTypeControl = orderTypeControl
        // 2.1 icon
        let orderTypeIcon = UIImageView(image: UIImage(named: "IMG_ico_quora_question_sort"))
        orderTypeControl.addSubview(orderTypeIcon)
        orderTypeIcon.contentMode = .center
        orderTypeIcon.clipsToBounds = true
        orderTypeIcon.snp.makeConstraints { (make) in
            make.trailing.equalTo(orderTypeControl)
            make.centerY.equalTo(orderTypeControl)
            make.width.equalTo(btnIconW)
            make.height.equalTo(btnIconH)
        }
        // 2.2 text
        let orderTypeLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), textColor: UIColor(hex: 0x999999), alignment: .right)
        orderTypeControl.addSubview(orderTypeLabel)
        orderTypeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(orderTypeControl)
            make.trailing.equalTo(orderTypeIcon.snp.leading).offset(-btnCenterMargin)
            make.leading.equalTo(orderTypeControl).offset(5)
        }
        self.orderTypeLabel = orderTypeLabel
        // 3. Localized
        answersCountLabel.text = "0 个回答"
        orderTypeLabel.text = "默认排序"
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

    /// 排序方式按钮点击响应
    @objc private func orderTypeControlClick(_ control: UIControl) -> Void {
        self.delegate?.didClickOrderTyp(in: self)
        self.orderTypeClickAction?(self)
    }
}
