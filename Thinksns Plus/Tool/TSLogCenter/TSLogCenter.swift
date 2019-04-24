//
//  TSLogCenter.swift
//  Thinksns Plus
//
//  Created by GorCat on 16/12/21.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  日志中心

import UIKit
import XCGLogger

class TSLogCenter {
    private static var logLevel: XCGLogger.Level = .none

    /// 配置日志输出等级
    ///
    /// - Parameter level: 低于该等级的日志输出都会显示出现
    /// - Note: 在发布环境下所有日志都不会输出,节约资源
    public static func configLogLevel(_ level: XCGLogger.Level) {
        logLevel = level
        switch logLevel {
        case .verbose:
            RequestNetworkData.share.isShowLog = true
            break
        default:
            RequestNetworkData.share.isShowLog = false
            JPUSHService.setLogOFF()
        }
    }

    /// 生成日志
    public static var log: XCGLogger {
        let log = XCGLogger.default
        #if DEBUG
        log.setup(level: TSLogCenter.logLevel, showLogIdentifier: false, showFunctionName: true, showThreadName: false, showLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLevel: nil)
        let logDateFormatter = DateFormatter()
        logDateFormatter.dateFormat = "HH:mm:ss.SSS"
        log.dateFormatter = logDateFormatter
        #else
        log.setup(level: XCGLogger.Level.none, showLogIdentifier: false, showFunctionName: true, showThreadName: false, showLevel: false, showFileNames: true, showLineNumbers: true, showDate: false, writeToFile: nil, fileLevel: nil)
        #endif
        return log
    }
}
