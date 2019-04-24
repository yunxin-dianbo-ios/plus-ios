//
//  TSSimpleCommentTableViewCell.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  评论cell

import UIKit

protocol TSSimpleCommentTableViewCellDelegate: NSObjectProtocol {

    /// 点击重新发送按钮
    ///
    /// - Parameter commnetModel: 数据模型
    func repeatTap(cell: TSSimpleCommentTableViewCell, commnetModel: TSSimpleCommentModel)

    /// 点击了名字
    ///
    /// - Parameter userId: 用户Id
    func didSelectName(userId: Int)
}

class TSSimpleCommentTableViewCell: UITableViewCell, TSCommentLabelDelegate, TSCustomAcionSheetDelegate {

    /// 评论展示的Label
    @IBOutlet weak var commentLabel: TSCommentLabel!

    /// 重发按钮
    @IBOutlet weak var repeatButton: UIButton!
    /// 评论内容的高度
    @IBOutlet weak var commentLabelHeight: NSLayoutConstraint!
    /// 代理
    weak var cellDelegate: TSSimpleCommentTableViewCellDelegate?
    /// 父视图的宽度
    var superWidth: CGFloat?
    /// 评论的模型
    var commnetObject: TSSimpleCommentModel? {
        didSet {
            if let object = commnetObject {
                commentLabel.linesSpacing = 0
                if object.status == 1 {
                    repeatButton.isHidden = false
                } else {
                    repeatButton.isHidden = true
                }
                commentLabel.commentModel = object
                commentLabel.linesSpacing = 4
                let height = CGFloat(commentLabel.getSizeWithWidth(superWidth!).height)
                commentLabelHeight.constant = height
                commentLabel.labelDelegate = self

                // 判断一下是否需要添加置顶标签
                if object.isTop {
                    commentLabel.appendText("  ")
                    commentLabel.append(UIImage(named: "IMG_label_zhiding"))
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - 重新发送
    /// 重发按钮
    ///
    /// - Parameter sender: 按钮
    @IBAction func repeatTap(_ sender: UIButton) {
        let reTipView = TSCustomActionsheetView(titles: ["重新发送"])
        reTipView.delegate = self
        reTipView.show()
    }

    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        repeatButton.isHidden = true
        self.cellDelegate?.repeatTap(cell: self, commnetModel: commnetObject!)
    }

    /// 点击名字
    ///
    /// - Parameter didSelectId: 点击的那个Id
    func didSelect(didSelectId: Int) {
        self.cellDelegate?.didSelectName(userId: didSelectId)
    }
}
