//
//  TSUserInterfacePrinciples.swift
//  ThinkSNS +
//
//  Created by lip on 2017/7/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

struct ScreenSize {
    static let ScreenWidth = UIScreen.main.bounds.size.width
    static let ScreenHeight = UIScreen.main.bounds.size.height
    static let ScreenMaxlength = max(ScreenSize.ScreenWidth, ScreenSize.ScreenHeight)
}

public let fengeLineHeight: CGFloat = 0.5
public let ScreenWidth: CGFloat = UIScreen.main.bounds.size.width
public let ScreenHeight: CGFloat = UIScreen.main.bounds.size.height
/// 状态栏高度
public let TSStatusBarHeight: CGFloat = TSUserInterfacePrinciples.share.getTSStatusBarHeight()
/// 刘海高度
public let TSLiuhaiHeight: CGFloat = TSUserInterfacePrinciples.share.getTSLiuhaiHeight()
/// tabbar高度
public let TSTabbarHeight: CGFloat = TSUserInterfacePrinciples.share.getTSTabbarHeight()
/// 底部安全区域高度
public let TSBottomSafeAreaHeight: CGFloat = TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight()
/// 导航栏高度
public let TSNavigationBarHeight: CGFloat = TSUserInterfacePrinciples.share.getTSNavigationBarHeight()
/// 自动布局顶部偏移量,部分页面贴顶布局在iPhoneX下需要向下移动20pt
public let TSTopAdjustsScrollViewInsets: CGFloat = TSUserInterfacePrinciples.share.getTSTopAdjustsScrollViewInsets()

class TSUserInterfacePrinciples: NSObject {
    static let share = TSUserInterfacePrinciples()

    private override init() {
        super.init()
    }
    // 判断是否为iPhoneX系列
    func isiphoneX() -> Bool {
        var systemInfo = utsname()
        uname(&systemInfo)
        var identifier = NSString(bytes: &systemInfo.machine, length:Int(_SYS_NAMELEN), encoding:String.Encoding.utf8.rawValue)! as String
        identifier = identifier.replacingAll(matching: "\0", with: "")
        if identifier == "i386" || identifier == "x86_64" {
            // 模拟器根据屏幕尺寸判断
            // iPhoneX, iPhoneXs CGSizeMake(375, 812)
            // iPhoneXs Max, iPhoneXR CGSize(width: 414, height: 896)
            if UIScreen.main.bounds.size.equalTo(CGSize(width: 375, height: 812)) || UIScreen.main.bounds.size.equalTo(CGSize(width: 812, height: 375)) || UIScreen.main.bounds.size.equalTo(CGSize(width: 414, height: 896)) ||
                UIScreen.main.bounds.size.equalTo(CGSize(width: 896, height: 414)) {
                return true
            } else {
                return false
            }
            /// iPhoneX "iPhone10,3" "iPhone10,6"
            /// iPhoneXs "iPhone11,2"
            /// iPhoneXs Max "iPhone11,6"
            /// iPhoneXR "iPhone11,8"
        } else if identifier == "iPhone10,3" || identifier == "iPhone10,6" || identifier == "iPhone11,2" || identifier == "iPhone11,6" || identifier == "iPhone11,8" {
            return true
        } else {
            return false
        }
    }

    /// 获取状态栏高度
    func getTSStatusBarHeight() -> CGFloat {
        if self.isiphoneX() == true {
            return 44.0
        } else {
            return 20.0
        }
    }
    /// 获取刘海高度
    func getTSLiuhaiHeight() -> CGFloat {
        if self.isiphoneX() == true {
            return 30.0
        } else {
            return 0
        }
    }
    /// 获取tabbar高度
    func getTSTabbarHeight() -> CGFloat {
        if self.isiphoneX() == true {
            return 49.0 + 34.0
        } else {
            return 49.0
        }
    }
    /// 获取底部安全区域高度
    func getTSBottomSafeAreaHeight() -> CGFloat {
        if self.isiphoneX() == true {
            return 34.0
        } else {
            return 0
        }
    }
    /// 获取顶部导航条
    func getTSNavigationBarHeight() -> CGFloat {
        if self.isiphoneX() == true {
            return 64.0 + 24.0
        } else {
            return 64.0
        }
    }
    /// 自动布局顶部偏移量,部分页面贴顶布局在iPhoneX下需要向下移动20pt
    func getTSTopAdjustsScrollViewInsets() -> CGFloat {
        if self.isiphoneX() == true {
            return 20.0
        } else {
            return 0
        }
    }
}
