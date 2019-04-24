//
//  TSEditorSyncMomentTopView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 27/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  web帖子编辑器工具栏上 同步至动态的顶部视图

import UIKit

/// 同步至动态的顶部视图
class TSEditorSyncMomentTopView: UIView {

    /// 是否同步至动态
    var syncMoment: Bool {
        get {
            return self.syncBtn.isSelected
        }
        set {
            self.syncBtn.isSelected = syncMoment
        }
    }

    /// 子控件
    fileprivate weak var syncBtn: UIButton!
    fileprivate weak var promptLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialUI(self)
    }
    init() {
        super.init(frame: CGRect.zero)
        self.initialUI(self)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI(self)
    }

    /// syncMomentView布局
    fileprivate func initialUI(_ syncMomentView: UIView) -> Void {
        // 1. checkBox
        let syncBtn = UIButton(type: .custom)
        syncMomentView.addSubview(syncBtn)
        syncBtn.setImage(#imageLiteral(resourceName: "IMG_ico_circle_check"), for: .normal)
        syncBtn.setImage(#imageLiteral(resourceName: "IMG_ico_circle_checked"), for: .selected)
        syncBtn.addTarget(self, action: #selector(syncBtnClick(_:)), for: .touchUpInside)
        syncBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        syncBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(syncMomentView)
            make.leading.equalTo(syncMomentView).offset(15)
        }
        self.syncBtn = syncBtn
        // 2. promptLabel
        let promptLabel = UILabel(text: "显示_同步至动态".localized, font: UIFont.systemFont(ofSize: 14), textColor: TSColor.normal.minor)
        syncMomentView.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(syncMomentView)
            make.leading.equalTo(syncBtn.snp.trailing).offset(0) // btnRightMargin
        }
    }

    /// 同步按钮点击响应
    @objc fileprivate func syncBtnClick(_ button: UIButton) -> Void {
        button.isSelected = !button.isSelected
    }

}
