//
//  TSAppConfig.swift
//  ThinkSNS +
//
//  Created by lip on 2017/4/10.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  应用配置信息

import UIKit
import ObjectMapper
import ReachabilitySwift

private let klaunchKey = "com.zhiyicx.launch"

class TSAppConfig: NSObject {
    static let share = TSAppConfig()
    private override init() {
        super.init()
        self.environment = self.loadEnvironment()
        self.localInfo = self.loadLocalInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
    }

    /// 启动配置参数
    var launchInfo: TSAppSettingInfoModel?
    /// 本地配置参数
    var localInfo: TSAppSettingInfoModel = TSAppSettingInfoModel()
    /// 钱包配置参数
    var walletInfo = TSWalletConfigModel()
    /// 环境信息
    ///
    /// - Note: 历史原因,分享相关配置记录在 ShareConfig.plist 内,后续会写入该处 2017年10月17日11:26:35
    var environment: AppEnvironmentModel = AppEnvironmentModel()
    /// 当前网络环境
    var reachabilityStatus: TSReachabilityStatus = TSReachabilityStatus.NotReachable

    /// 服务器根地址
    var rootServerAddress: String {
        return self.environment.serverAddress
    }
    // MARK: - 参数配置
    /// 更新本地配置参数
    ///
    /// - Note: 如果要单独更新单个参数,需要将旧本地的参数复制一份,然后修改单个参数,再整个更新即可,避免出现写入单个导致整个配置为空的情况
    func updateLocalInfo() {
        guard let realLaunchInfo = launchInfo else {
            assert(false, "没有获取到服务器配置时,写入无效")
            return
        }
        // 转 dic 然后写入文件下次启动APP会从文件载入配置信息
        let dic = realLaunchInfo.toJSON()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let path = documentsDirectory.appending("/AppConfig.plist")
        if let _ = NSMutableDictionary(contentsOfFile: path) {
            let muDic = NSMutableDictionary(dictionary: dic)
            _ = muDic.write(to: URL(fileURLWithPath: path), atomically: false)
        } else {
            fatalError("读取文件时,读取文件的路径配置错误")
        }
        // 配置信息更
        self.localInfo = self.loadLocalInfo()
    }

    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as? Reachability
        TSCurrentUserInfo.share.isAgreeUserCelluarWatchShortVideo = false
        if (reachability?.isReachable)! {
            if (reachability?.isReachableViaWiFi)! {
                reachabilityStatus = .WIFI
            } else {
                reachabilityStatus = .Cellular
            }
        } else {
            reachabilityStatus = .NotReachable
        }
    }
    // MARK: - 全局浏览量/阅读量统一转换
    func pageViewsString(number: Int) -> String {
        if number > 9_999 {
            if number >= 100_000 {
                return "\(number / 10_000)万"
            } else {
                return "\(number / 10_000).\((number - number / 10_000 * 10_000) / 1_000)万"
            }
        } else {
            return  "\(number)"
        }
    }
    private func loadEnvironment() -> AppEnvironmentModel {
        if let bundlePath = Bundle.main.path(forResource: "AppEnvironment", ofType: "plist") {
            let dicData = NSDictionary(contentsOfFile: bundlePath) as! Dictionary<String, Any>
            if let model = Mapper<AppEnvironmentModel>().map(JSON: dicData) {
                return model
            }
            fatalError("默认环境配置文件格式错误,查看文档 ./Thinksns Plus Document/应用配置说明.md")
        } else {
            fatalError("默认环境配置文件格式错误,查看文档 ./Thinksns Plus Document/应用配置说明.md")
        }
    }

    /// 应用配置表
    ///
    /// - Returns: 配置信息
    /// - Note: 应用信息配置在`AppConfig.plist`文件内
    private func loadLocalInfo() -> TSAppSettingInfoModel {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let path = documentsDirectory.appending("/AppConfig.plist")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) == false {
            if let bundlePath = Bundle.main.path(forResource: "AppConfig", ofType: "plist") {
                do {
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                } catch let error as NSError {
                    TSLogCenter.log.debug(error)
                }
            } else {
                fatalError("默认环境配置文件格式错误,查看文档 ./Thinksns Plus Document/应用配置说明.md")
            }
        }
        let dicData = NSDictionary(contentsOfFile: path) as! Dictionary<String, Any>
        if let model = Mapper<TSAppSettingInfoModel>().map(JSON: dicData) {
            return model
        } else {
            // 如果复制的文件被修改来导致转换错误,就使用 plist 文件生成默认配置
            if let bundlePath = Bundle.main.path(forResource: "AppConfig", ofType: "plist") {
                let dicData = NSDictionary(contentsOfFile: bundlePath) as! Dictionary<String, Any>
                return Mapper<TSAppSettingInfoModel>().map(JSON: dicData)!
            }
            fatalError("默认环境配置文件格式错误,查看文档 ./Thinksns Plus Document/应用配置说明.md")
        }
    }
}
