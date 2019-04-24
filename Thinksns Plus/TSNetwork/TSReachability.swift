//
//  TSReachability.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/6.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  网络连接性检查器
//  该类基于 ReachabilitySwift 检查应用的网络状况,每当网络状况变化时发出通知,通知名称查看`TSNotifications.swift`
//  为了保证保证TS + 的统一性,也为了方便后期替换网络监测状况,故编写了该类
//  从应用启动开始,将开始监控整个网络状态

import UIKit
import ReachabilitySwift

enum TSReachabilityStatus {
    case WIFI
    case Cellular
    case NotReachable
}

class TSReachability: NSObject {
    let reachability = Reachability()!
    var reachabilityStatus = TSReachabilityStatus.NotReachable
    static let share = TSReachability()
    private override init() {}

    func startNotifier() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: ReachabilityChangedNotification, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            assert(false, "could not start reachability notifier")
        }
    }

    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as? Reachability

        if (reachability?.isReachable)! {
            if (reachability?.isReachableViaWiFi)! {
                reachabilityStatus = .WIFI
            } else {
                reachabilityStatus = .Cellular
            }
        } else {
            reachabilityStatus = .NotReachable
        }
        //  [warning] 只有网络变动才会发送通知
        NotificationCenter.default.post(name: Notification.Name.Reachability.Changed, object: self)
    }
}
