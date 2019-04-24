//
//  TSAdvertHelper.swift
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/5/25.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
enum TSAdvertType {
    // 详情页小广告
    case normal
    // 轮播图广告
    case banner
    // 启动图广告
    case launchSreen
}

class TSAdvertHelper: NSObject {

    static let share = TSAdvertHelper()
    /*
     广告图片样式规则
     1020x180(单张) 502x180(两张) 340x180(三张) 最多三张
     注意item间距以及边距
     // 边距 10，间距5
     */

    func getAdvertHeight(advertType: TSAdvertType, Advertwith: CGFloat, itemCount: Int) -> CGFloat {
        if itemCount == 0 {
            return 0
        }
        return self.getAdvertItemSize(advertType: advertType, Advertwith: Advertwith, itemCount: itemCount).height + 10 * 2
    }

    func getAdvertItemSize(advertType: TSAdvertType, Advertwith: CGFloat, itemCount: Int) -> CGSize {
        if itemCount == 0 {
            return CGSize(width: 0.01, height: 0.01)
        }
        var itemLineCount = CGFloat(itemCount)
        var itemSpaceCount = CGFloat(itemLineCount - 1)
        if itemCount > 3 {
            itemSpaceCount = 2
            itemLineCount = 3
        }
        let width: CGFloat = (Advertwith - self.getSpacing(advertType: advertType) * 2 - itemSpaceCount * getItemSpacing(advertType: advertType)) / itemLineCount
        let height: CGFloat = 90
        return CGSize(width: width, height: height)
    }
    func getSpacing(advertType: TSAdvertType) -> CGFloat {
        switch advertType {
        case .normal:
            return 10
        default:
            return 0
        }
    }
    func getItemSpacing(advertType: TSAdvertType) -> CGFloat {
        switch advertType {
        case .normal:
            return 5
        default:
            return 0
        }
    }
}
