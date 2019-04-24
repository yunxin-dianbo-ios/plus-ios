//
//  AvatarIconsView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  头像图标视图

import UIKit

class AvatarIconsView: UIView {

    /// 图标排列类型
    enum AlignmentType {
        /// 左对齐，从左往右排列
        case left
        /// 右对齐，从右往左排列
        case right
    }

    /// 图标置顶类型
    enum TopType {
        /// 最左图标排在最上面
        case left
        /// 最右图标排在最上面
        case right
    }

    /// 最大个数，默认为 5
    var avatarsCountMax = 5
    /// 排列类型
    var alignmentType: AlignmentType = .right
    /// 置顶类型
    var topType: TopType = .left
    /// 头像大小
    var avatarType = AvatarType.width20(showBorderLine: true)
    /// 是否显示白边
    var showBoardLine = true
    /// 两个头像之间交叉部分的宽度
    var avatarOverlap: CGFloat = 5

    /// 头像数组
    private var items: [AvatarView] = []
    /// 头像数据
    var datas: [TSUserInfoModel] = []

    // MARK: - Public

    /// 刷新视图
    func reloadDatas() {
        // 1.移除所有旧视图
        let _ = items.map { $0.removeFromSuperview() }
        items = []
        // 2.编辑头像数据生成头像图标
        for (index, data) in datas.enumerated() {
            let avatarFrame = getItemFrame(at: index)
            let avatar = AvatarView(frame: avatarFrame)
            avatar.showBoardLine = true
            avatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: data.sex)
            let avatarInfo = AvatarInfo()
            avatarInfo.avatarURL = TSUtil.praseTSNetFileUrl(netFile: data.avatar)
            avatarInfo.verifiedType = data.verified?.type ?? ""
            avatarInfo.verifiedIcon = data.verified?.icon ?? ""
            avatar.avatarInfo = avatarInfo
            avatar.buttonForAvatar.isUserInteractionEnabled = false
            // 保存在 items 里
            items.append(avatar)
        }
        // 3.根据界面设置信息，将头像添加在视图上
        let showingCount = min(avatarsCountMax, items.count)
        var showingItems: [AvatarView] = Array(items[0..<showingCount])
        showingItems = showingItems.sorted { $0.frame.minX < $1.frame.minX }
        if topType == .left {
            showingItems.reverse()
        }
        for item in items {
            addSubview(item)
        }
    }

    /// 计算单个 item 的 frame
    private func getItemFrame(at index: Int) -> CGRect {
        let index = CGFloat(index)
        // 头像宽度
        let avatarWidth = avatarType.width
        var x: CGFloat = 0
        switch alignmentType {
        case .left:
            x = avatarWidth - avatarOverlap
        case .right:
            x = frame.width - avatarWidth - index * (avatarWidth - 2 * avatarOverlap)
        }
        let avatarFrame = CGRect(x: x, y: (frame.height - avatarWidth) / 2, width: avatarWidth, height: avatarWidth)
        return avatarFrame
    }

}
