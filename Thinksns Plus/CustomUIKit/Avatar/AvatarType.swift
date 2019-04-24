//
//  AvatarConfig.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

// 常用头像类型
enum AvatarType {

    case custom(avatarWidth: CGFloat, showBorderLine: Bool)

    /// 头像 size
    var size: CGSize {
        switch self {
        case .custom(avatarWidth: let width, showBorderLine: _):
            return CGSize(width: width, height: width)
        }
    }

    /// 头像宽度
    var width: CGFloat {
        return size.width
    }

    /// 是否显示白边
    var showBorderLine: Bool {
        switch self {
        case .custom(avatarWidth: _, showBorderLine: let showBorderLine):
            return showBorderLine
        }
    }
}

// MARK: - 常用的头像类型
extension AvatarType {

    static func width70(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 70, showBorderLine: showBorderLine)
    }

    static func width60(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 60, showBorderLine: showBorderLine)
    }

    static func width43(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 43, showBorderLine: showBorderLine)
    }

    static func width38(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 38, showBorderLine: showBorderLine)
    }

    static func width26(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 26, showBorderLine: showBorderLine)
    }

    static func width20(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 20, showBorderLine: showBorderLine)
    }
}
