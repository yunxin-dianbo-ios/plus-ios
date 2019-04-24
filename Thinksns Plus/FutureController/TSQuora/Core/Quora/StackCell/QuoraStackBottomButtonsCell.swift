//
//  QuoraStackBottomButtonsCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  问答列表 包含问答中“关注/回答/悬赏”三按钮的 cell

import UIKit
import SnapKit

protocol QuoraStackBottomButtonsCellDelegate: class {
    /// 点击了关注按钮
    func bottomCell(_ cell: QuoraStackBottomButtonsCell, didSelectedFollow button: UIButton)
    /// 点击了回答按钮
    func bottomCell(_ cell: QuoraStackBottomButtonsCell, didSelectedAnswer button: UIButton)
    /// 点击了悬赏按钮
    func bottomCell(_ cell: QuoraStackBottomButtonsCell, didSelectedReward button: UIButton)
}

class QuoraStackBottomButtonsCell: UITableViewCell {

    /// 代理
    weak var delegate: QuoraStackBottomButtonsCellDelegate?

    /// 关注
    let buttonForFollow: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(TSColor.normal.minor, for: .normal)
        return button
    }()
    /// 回答
    let buttonForAnswer: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(TSColor.normal.minor, for: .normal)
        return button
    }()
    /// 悬赏
    let buttonForReward: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    let rewardLabel: TSIconLabel = {
        let iconLabel = TSIconLabel(iconName: "IMG_ico_quora__shang", text: "")
        iconLabel.textFont = UIFont.systemFont(ofSize: 14)
        return iconLabel
    }()

    /// 时间
    let labelForTime: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = TSColor.normal.disabled
        return label
    }()

    /// 数据
    var model: QuoraStackBottomButtonsCellModel?

    static let identifier = "QuoraStackBottomButtonsCell"

    // MARK: - Lifecycle

    class func cellForm(table: UITableView, at indexPath: IndexPath, with data: inout QuoraStackBottomButtonsCellModel) -> QuoraStackBottomButtonsCell {
        let cell = table.dequeueReusableCell(withIdentifier: QuoraStackBottomButtonsCell.identifier, for: indexPath) as! QuoraStackBottomButtonsCell
        cell.setInfo(model: &data)
        return cell
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - UI

    func setUI() {
        buttonForAnswer.addTarget(self, action: #selector(answerButtonTaped(_:)), for: .touchUpInside)
        buttonForFollow.addTarget(self, action: #selector(followButtonTaped(_:)), for: .touchUpInside)
        buttonForReward.addTarget(self, action: #selector(rewardButtonTaped(_:)), for: .touchUpInside)
        contentView.addSubview(buttonForFollow)
        contentView.addSubview(buttonForAnswer)
        contentView.addSubview(buttonForReward)
        contentView.addSubview(labelForTime)
        buttonForReward.addSubview(rewardLabel)
        rewardLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(buttonForReward)
        }
        buttonForReward.snp.makeConstraints { (make) in
            make.centerY.equalTo(buttonForAnswer)
            make.leading.equalTo(buttonForAnswer.snp.trailing).offset(7)
        }
    }

    /// 点击了回答按钮
    func answerButtonTaped(_ sender: UIButton) {
        delegate?.bottomCell(self, didSelectedAnswer: sender)
    }

    /// 点击了关注按钮
    func followButtonTaped(_ sender: UIButton) {
        delegate?.bottomCell(self, didSelectedFollow: sender)
    }

    /// 点击了悬赏按钮
    func rewardButtonTaped(_ sender: UIButton) {
        delegate?.bottomCell(self, didSelectedReward: sender)
    }

    // MARK: - Public
    private func setInfo(model: inout  QuoraStackBottomButtonsCellModel) {
        self.model = model

        let screenWidth = UIScreen.main.bounds.width
        let haveReward = model.rewardNumber > 0 // 是否有悬赏金额
        // 1.设置关注按钮
        // 1.1 更新关注显示内容
        let followString = QuoraStackBottomButtonsCell.getAttributeString(texts: ["\(model.followCount)", " 关注  ·"], colors: [TSColor.main.theme, TSColor.normal.minor])
        buttonForFollow.setAttributedTitle(followString, for: .normal)
        // 1.2 更新关注显示设置
        buttonForFollow.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        // 1.3 计算关注的 frame
        buttonForFollow.sizeToFit()
        buttonForFollow.frame = CGRect(origin: CGPoint(x: model.left, y: model.top), size: buttonForFollow.frame.size)

        // 2.设置回答按钮
        // 2.1 更新回答显示内容
        let answerString = QuoraStackBottomButtonsCell.getAttributeString(texts: ["  \(model.answerCount)", haveReward ? " 回答  ·" : " 回答"], colors: [TSColor.main.theme, TSColor.normal.minor])
        buttonForAnswer.setAttributedTitle(answerString, for: .normal)
        // 2.2 更新回答显示设置
        buttonForAnswer.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        // 2.3 计算回答的 frame
        buttonForAnswer.sizeToFit()
        buttonForAnswer.frame = CGRect(origin: CGPoint(x: buttonForFollow.frame.maxX, y: model.top), size: buttonForAnswer.frame.size)

        // 3.设置悬赏按钮 更新悬赏显示内容
        self.rewardLabel.text = "\(model.rewardNumber)"
        buttonForReward.isHidden = !haveReward

        // 4.设置时间
        // 4.1 设置事件显示内容
        labelForTime.text = TSDate().dateString(.normal, nsDate: model.time)
        // 4.2 计算时间 frame
        labelForTime.sizeToFit()
        labelForTime.frame = CGRect(origin: CGPoint(x: screenWidth - labelForTime.frame.width - model.right, y: model.top), size: labelForTime.frame.size)

        // 5.计算控件的总高度
        model.buttonsHeight = buttonForFollow.frame.height
    }

    // 处理富文本
    class func getAttributeString(texts: [String], colors: [UIColor]) -> NSMutableAttributedString {
        let string = NSMutableAttributedString(string: "")
        for index in 0..<texts.count {
            let text = texts[index]
            let color = colors[index]
            let attributeString = NSMutableAttributedString(string: text)
            attributeString.addAttributes([NSForegroundColorAttributeName: color], range: NSRange(location: 0, length: attributeString.length))
            string.append(attributeString)
        }
        return string
    }
}
