//
//  ReceivePendingTypeSelectPopView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  审核类型选择弹窗视图

import UIKit

protocol ReceivePendingTypeSelectPopViewProtocol: class {
    /// 背景 点击回调
    func didClickCoverInPopView(_ popView: ReceivePendingTypeSelectPopView) -> Void
    /// 选项 选中回调
    func popView(_ popView: ReceivePendingTypeSelectPopView, didSelectedType type: ReceivePendingController.ShowType) -> Void
}

extension ReceivePendingTypeSelectPopViewProtocol {
    /// 背景 点击回调
    func didClickCoverInPopView(_ popView: ReceivePendingTypeSelectPopView) -> Void {
    }
}

class ReceivePendingTypeSelectPopView: UIView {

    // MARK: - Internal Property
    /// 回调
    weak var delegate: ReceivePendingTypeSelectPopViewProtocol?
    var typeSelectedAction: ((_ type: ReceivePendingController.ShowType) -> Void)?
    // 已经选中的效果
    var selectedType: ReceivePendingController.ShowType = ReceivePendingController.ShowType.momentCommentTop

    // MARK: - Internal Function

    func show() -> Void {
        self.isHidden = false
        if self.subviews.count == 0 {
            self.initialUI()
        }
        // 背景色更改
        self.coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        // 选择视图下移
        self.typeSelectView.snp.updateConstraints({ (make) in
            make.bottom.equalTo(self.snp.top).offset(self.typeSelectViewH)
        })
        self.layoutIfNeeded()
//        UIView.animate(withDuration: 0.25, animations: {
//            // 背景色更改
//            self.coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0.25)
//            // 选择视图下移
//            self.typeSelectView.snp.updateConstraints({ (make) in
//                make.bottom.equalTo(self.snp.top).offset(self.typeSelectViewH)
//            })
//            self.layoutIfNeeded()
//        }) { (finish) in
//
//        }
    }
    func dismiss() -> Void {
        UIView.animate(withDuration: 0.25, animations: {
            // 背景色更改
            self.coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0)
            // 选择视图下移
            self.typeSelectView.snp.updateConstraints({ (make) in
                make.bottom.equalTo(self.snp.top).offset(0)
            })
            self.layoutIfNeeded()
        }) { (finish) in
            self.isHidden = true
            self.removeAllSubViews()
        }
    }

    // MARK: - Private Property

    fileprivate weak var coverBtn: UIButton!
    fileprivate weak var typeSelectView: UIView!

    /// 选项按钮的tag基值
    fileprivate let typeTagBase: Int = 250
    /// 单个选项的高度
    fileprivate let singltTypeViewH: CGFloat = 50
    fileprivate let typeSelectViewH: CGFloat = 250 // 50 * 5

    // MARK: - Initialize Function
    init() {
        super.init(frame: CGRect.zero)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // 1. coverBtn
        let coverBtn = UIButton(type: .custom)
        self.addSubview(coverBtn)
        coverBtn.addTarget(self, action: #selector(coverBtnClick(_:)), for: .touchUpInside)
        coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0)  // 默认颜色
        coverBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        self.coverBtn = coverBtn
        // 2. typeSelectView
        let typeSelectView = UIView(bgColor: UIColor.white)
        self.addSubview(typeSelectView)
        typeSelectView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self)
            // 默认位置
            //make.top.equalTo(self).offset(0)
            make.bottom.equalTo(self.snp.top).offset(0)
        }
        self.typeSelectView = typeSelectView
        // 2.x typeOptionView
        let titles = ["动态评论置顶", "资讯评论置顶", "帖子评论置顶", "帖子置顶", "圈子加入申请"]
        let buttonReceiveTypes = [ReceivePendingController.ShowType.momentCommentTop, ReceivePendingController.ShowType.newsCommentTop, ReceivePendingController.ShowType.postCommentTop, ReceivePendingController.ShowType.postTop, ReceivePendingController.ShowType.groupAudit]
        let pendingCounts = [TSCurrentUserInfo.share.unreadCount.feedCommentPinned, TSCurrentUserInfo.share.unreadCount.newsCommentPinned, TSCurrentUserInfo.share.unreadCount.postCommentPinned, TSCurrentUserInfo.share.unreadCount.postPinned, TSCurrentUserInfo.share.unreadCount.groupJoinPinned]
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .custom)
            typeSelectView.addSubview(button)
            button.setTitle(title, for: .normal)
            button.receiveShowType = buttonReceiveTypes[index]
            if self.selectedType == button.receiveShowType {
                button.setTitleColor(TSColor.main.theme, for: .normal)
            } else {
                button.setTitleColor(TSColor.main.content, for: .normal)
            }
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.tag = self.typeTagBase + index
            button.addTarget(self, action: #selector(typeBtnClick(_:)), for: .touchUpInside)
            button.addLineWithSide(.inBottom, color: TSColor.inconspicuous.disabled, thickness: 0.5, margin1: 0, margin2: 0 )
            button.snp.makeConstraints({ (make) in
                make.height.equalTo(self.singltTypeViewH)
                make.leading.trailing.equalTo(typeSelectView)
                make.top.equalTo(typeSelectView).offset(CGFloat(index) * self.singltTypeViewH)
                if index == titles.count - 1 {
                    make.bottom.equalTo(typeSelectView)
                }
            })
            let redView = UIView()
            redView.backgroundColor = UIColor.red
            redView.layer.cornerRadius = 2.5
            button.titleLabel?.addSubview(redView)
            redView.snp.makeConstraints { (make) in
                make.leading.equalTo((button.titleLabel?.snp.trailing)!)
                make.bottom.equalTo((button.titleLabel?.snp.top)!)
                make.width.height.equalTo(5)
            }
            if pendingCounts[index] > 0 {
                redView.isHidden = false
            } else {
                redView.isHidden = true
            }
        }
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

    /// 背景点击
    @objc fileprivate func coverBtnClick(_ button: UIButton) -> Void {
        self.delegate?.didClickCoverInPopView(self)
        self.dismiss()
    }
    /// 选项按钮点击
    @objc fileprivate func typeBtnClick(_ button: UIButton) -> Void {
        self.dismiss()
        let index = button.tag - self.typeTagBase
        var type: ReceivePendingController.ShowType?
        switch index {
        case 0:
            type = ReceivePendingController.ShowType.momentCommentTop
        case 1:
            type = ReceivePendingController.ShowType.newsCommentTop
        case 2:
            type = ReceivePendingController.ShowType.postCommentTop
        case 3:
            type = ReceivePendingController.ShowType.postTop
        case 4:
            type = ReceivePendingController.ShowType.groupAudit
        default:
            break
        }
        guard let selectedType = type else {
            return
        }
        self.delegate?.popView(self, didSelectedType: selectedType)
        self.typeSelectedAction?(selectedType)
    }
}

var UIButtonExtensionShowTypeKey = "UIButtonExtensionShowTypeKey"
// 添加一个选择类型的扩展
extension UIButton {
    // 给图片绑定支付信息
    var receiveShowType: ReceivePendingController.ShowType {
        set {
            objc_setAssociatedObject(self, &UIButtonExtensionShowTypeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            if let rs = objc_getAssociatedObject(self, &UIButtonExtensionShowTypeKey) as? ReceivePendingController.ShowType {
                return rs
            }
            return ReceivePendingController.ShowType.momentCommentTop
        }
    }
}

