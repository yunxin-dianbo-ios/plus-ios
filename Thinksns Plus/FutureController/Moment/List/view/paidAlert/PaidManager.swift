//
//  FeedPaidAlert.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  付费弹窗

import UIKit

// MARK: - 加圈付费弹窗
extension PaidManager {

    open class func showPaidGroupAlert(price: Double, groupId: Int, groupMode mode: String, complete: @escaping () -> Void) {
        let alert = PaidAlert(price: price)
        // 设置购买按钮点击事件
        alert.setActionForBuyButton { [weak alert] in
            alert?.buttonForBuy.isEnabled = false
            // 1.申请加入圈子
            GroupNetworkManager.joinGroup(groupId: groupId, complete: { [weak alert] (isSuccess, message) in
                alert?.dissmiss()
                alert?.buttonForBuy.isEnabled = true
                /// 支付需要密码弹窗
                if TSAppConfig.share.localInfo.shouldShowPayAlert {
                    if isSuccess {
                        TSUtil.dismissPwdVC()
                    } else {
                        NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                        return
                    }
                }
                // 成功加入
                if isSuccess {
                    let successAlert = TSIndicatorWindowTop(state: .success, title: message)
                    successAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
//                    complete() 付费的圈子有审核时间，所以不需要立刻通知列表刷新界面
                } else {
                    // 加入失败
                    let faildAlert = TSIndicatorWindowTop(state: .faild, title: message ?? "加入失败")
                    faildAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            })
        }
        alert.show(type: .joinGroup)
    }
}

// MARK: - 图片付费弹窗
extension PaidManager {

    /// 显示图片付费弹窗
    ///
    /// - Parameters:
    ///   - paidPicModel: 付费图片 model
    ///   - complete: 付费结果，成功才会回调
    open class func showPaidPicAlert(imageUrl: String, paidInfo: PaidInfo, complete: @escaping () -> Void) {
        let alert = PaidAlert(price: paidInfo.price)            // 设置购买按钮点击事件
        alert.setActionForBuyButton { [weak alert] in
            alert?.buttonForBuy.isEnabled = false
            // 1.发起支付
            paid(node: paidInfo.node, price: paidInfo.price, complete: { (status, _) in
                alert?.buttonForBuy.isEnabled = true
                guard status else {
                    return
                }
                alert?.dissmiss()
                complete()
                NotificationCenter.default.post(name: NSNotification.Name.PaidImage.buyPic, object: nil, userInfo: ["url": imageUrl])
            })
        }
        alert.show(type: paidInfo.type)
    }

}

// MARK: - 动态文字付费弹窗
extension PaidManager {

    /// 显示文字付费弹窗
    ///
    /// - Parameters:
    ///   - feedId: 动态 id
    ///   - paidInfo: 付费信息
    ///   - complete: 成功才会回调
    open class func showFeedPaidTextAlert(feedId: Int, paidInfo: PaidInfo, complete: @escaping(_ newText: String) -> Void) {
        let alert = PaidAlert(price: paidInfo.price)
        // 设置购买按钮点击事件
        alert.setActionForBuyButton { [weak alert] in
            alert?.buttonForBuy.isEnabled = false
            // 1.发起支付
            paid(node: paidInfo.node, price: paidInfo.price, complete: { (status, _) in
                guard status else {
                    return
                }
                alert?.dissmiss()
                alert?.buttonForBuy.isEnabled = true
                // 2.支付成功，获取动态数据
                FeedListNetworkManager.getFeed(id: feedId, complete: { (_, model) in
                    if let data = model {
                        complete(data.moment.content)
                        /// 刷新其他已经生成的列表中对应id的数据
                        let userInfo: [String: Any] = ["feedId": feedId, "content": data.moment.content]
                        NotificationCenter.default.post(name: NSNotification.Name.Moment.paidReloadFeedList, object: nil, userInfo: userInfo)
                    }
                })
            })
        }
        alert.show(type: .text)
    }
    /// 增加支付状态回调 payStatus 取消-1 失败0 成功1
    class func showFeedPaidTextAlertCallBack(feedId: Int, paidInfo: PaidInfo, complete: @escaping(_ payStatus: Int, _ newText: String?) -> Void) {
        let alert = PaidAlert(price: paidInfo.price)
        // 设置购买按钮点击事件
        alert.setActionForBuyButton { [weak alert] in
            alert?.buttonForBuy.isEnabled = false
            // 1.发起支付
            paid(node: paidInfo.node, price: paidInfo.price, complete: { (status, _) in
                guard status else {
                    complete(0, nil)
                    return
                }
                alert?.dissmiss()
                alert?.buttonForBuy.isEnabled = true
                // 2.支付成功，获取动态数据
                FeedListNetworkManager.getFeed(id: feedId, complete: { (_, model) in
                    if let data = model {
                        complete(1, data.moment.content)
                        /// 刷新其他已经生成的列表中对应id的数据
                        let userInfo: [String: Any] = ["feedId": feedId, "content": data.moment.content]
                        NotificationCenter.default.post(name: NSNotification.Name.Moment.paidReloadFeedList, object: nil, userInfo: userInfo)
                    } else {
                        complete(0, nil)
                    }
                })
            })
        }
        alert.setActionForBackButton {
            alert.dissmiss()
            complete(-1, nil)
        }
        alert.show(type: .text)
    }
}

/// MARK: - 内部方法

/// 付费信息
class PaidInfo {
    // 付费类型枚举
    enum PaidType: String {
        /// 文字付费
        case text
        /// 图片查看付费
        case pictureSee = "read"
        /// 图片下载付费
        case pictureDownload = "download"
        /// 加入圈子
        case joinGroup
    }

    /// 付费类型
    var type = PaidType.text
    /// 付费节点
    var node = 0
    /// 付费价格（直接展示给用户看的值）
    var price = 0.0

    init() {
    }

    init(object: PiadInfoObject) {
        node = object.node
        price = object.price
        type = PaidType(rawValue: object.payType)!
    }

    // MAKR: Object
    func object() -> PiadInfoObject {
        let object = PiadInfoObject()
        object.node = node
        object.price = price
        object.payType = type.rawValue
        return object
    }
}

class PaidManager: NSObject {

    /// 发起常规付费流程
    fileprivate class func paid(node: Int, price: Double, complete: @escaping (Bool, String?) -> Void) {
        // 直接发起节点付费请求即可，支付按钮点击时会进行积分余额的判断
        paiding(node: node, complete: complete)
    }

    /// 发起付费操作
    fileprivate class func paiding(node: Int, complete: @escaping (Bool, String?) -> Void) {
        // 1.显示加载中弹窗
        let indicator = TSIndicatorWindowTop(state: .loading, title: "正在支付")
        indicator.show()
        // 2.发起网络请求
        TSPayNetworkManager.pay(node: node, complete: { (isSuccess: Bool, message: String?) in
            indicator.dismiss()
            // 3.显示结果弹窗
            if let message = message {
                if TSAppConfig.share.localInfo.shouldShowPayAlert && isSuccess == false {
                    NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message])
                } else {
                    let resultIndicator = TSIndicatorWindowTop(state: isSuccess ? .success : .faild, title: message)
                    resultIndicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            }
            if TSAppConfig.share.localInfo.shouldShowPayAlert && isSuccess {
                TSUtil.dismissPwdVC()
            }

            complete(isSuccess, message)
        })
    }

}

extension UIApplication {

}

fileprivate class PaidAlert: TSIndicatorPayBasicView {

    /// 显示付费弹窗
    ///
    /// - Parameter isRead: true 查看付费，false 下载付费
    func show(type: PaidInfo.PaidType) {
        var description = "支付弹窗_描述开头".localized + price.tostring(decimal: 0) + TSAppConfig.share.localInfo.goldName
        switch type {
        case .text:
            description += "支付弹窗_动态内容付费描述".localized
        case .pictureSee:
            description += "支付弹窗_图片查看付费描述".localized
        case .pictureDownload:
            description += "支付弹窗_图片下载付费描述".localized
        case .joinGroup:
            description += "来加入圈子"
        }
        // 设置显示内容
        labelForTitle.text = "支付弹窗_标题".localized
        setPrice(content: price.tostring(decimal: 0))
        setDescription(content: description, linkWord: nil)

        // 更新子视图布局
        updateChildViewLayout()

        // 调用父类方法
        super.show()
    }
}
