//
//  TSQuoraDetailBottomBar.swift
//  ThinkSNS +
//
//  Created by 小唐 on 26/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问答详情底部工具栏
//  注1：分为两种状态：发布者查看状态 和 普通的人查看状态

import UIKit

/// 工具栏类型
enum TSQuoraDetailToolBarType {
    /// 普通的
    case normal
    /// 发布者
    case publisher
    case manager
}

/// 工具栏协议
protocol TSQuoraDetailToolBarProtocol: class {
    ///  评论点击回调
    func didClickCommentItem(in bar: TSQuoraDetailToolBar) -> Void
    /// 分享点击回调
    func didClickShareItem(in bar: TSQuoraDetailToolBar) -> Void
    /// 编辑点击回调
    func didClickEditItem(in bar: TSQuoraDetailToolBar) -> Void
    /// 更多点击回调
    func didClickMoreItem(in bar: TSQuoraDetailToolBar) -> Void
}

/// 问答详情底部工具栏
class TSQuoraDetailToolBar: UIView {

    // MARK: - Internal Property
    var type: TSQuoraDetailToolBarType = .normal {
        didSet {
            switch type {
            case .normal:
                self.normalBar.isHidden = false
                self.publisherBar.isHidden = true
            case .publisher:
                self.normalBar.isHidden = true
                self.publisherBar.isHidden = false
            case .manager:
                self.normalBar.isHidden = false
                self.publisherBar.isHidden = true
            }
        }
    }
    weak var barDelegate: TSQuoraDetailToolBarProtocol?

    // MARK: - Private Property
    // 为了能动态切换，设计2种bar
    fileprivate weak var normalBar: TSToolbarView!
    fileprivate weak var publisherBar: TSToolbarView!

    // MARK: - Internal Function

    // MARK: - Initialize Function
    init() {
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 48 - TSBottomSafeAreaHeight, width: UIScreen.main.bounds.width, height: 48 + TSBottomSafeAreaHeight)
        super.init(frame: frame)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Private  UI
    private func initialUI() -> Void {
        // 1. bar
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48 + TSBottomSafeAreaHeight)
        let commentItem = TSToolbarItemModel(image: "IMG_home_ico_comment_normal", title: "评论", index: 0)
        let shareItem = TSToolbarItemModel(image: "IMG_detail_ico_share_normal", title: "分享", index: 1)
        let editItem = TSToolbarItemModel(image: "IMG_ico_quora_edit_normal", title: "编辑", index: 2)
        let normalMoreItem = TSToolbarItemModel(image: "IMG_home_ico_more", title: "更多", index: 2)
        let publisherMoreItem = TSToolbarItemModel(image: "IMG_home_ico_more", title: "更多", index: 3)
        let normalBar = TSToolbarView(frame: frame, type: .top, items: [commentItem, shareItem, normalMoreItem])
        let publisherBar = TSToolbarView(frame: frame, type: .top, items: [commentItem, shareItem, editItem, publisherMoreItem])
        normalBar.delegate = self
        publisherBar.delegate = self
        self.addSubview(normalBar)
        self.addSubview(publisherBar)
        self.normalBar = normalBar
        self.publisherBar = publisherBar
        // 2. line
        let line = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        line.backgroundColor = TSColor.inconspicuous.disabled
        addSubview(line)
        // 3. 默认展示
        self.type = .normal
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

}

// MARK: - TSToolbarViewDelegate

extension TSQuoraDetailToolBar: TSToolbarViewDelegate {
    /// 点击了工具栏
    func toolbar(_ toolbar: TSToolbarView, DidSelectedItemAt index: Int) {
        switch index {
        case 0: // 评论
            self.barDelegate?.didClickCommentItem(in: self)
        case 1: // 分享
            self.barDelegate?.didClickShareItem(in: self)
        case 2: // publisher:编辑 + normal:更多
            switch self.type {
            case .normal:
                self.barDelegate?.didClickMoreItem(in: self)
            case .publisher:
                self.barDelegate?.didClickEditItem(in: self)
            case .manager:
                self.barDelegate?.didClickMoreItem(in: self)
            }
        case 3: // 更多
            self.barDelegate?.didClickMoreItem(in: self)
        default:
            break
        }
    }
}
