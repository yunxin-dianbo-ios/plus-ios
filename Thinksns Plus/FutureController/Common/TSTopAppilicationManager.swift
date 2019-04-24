//
//  TSTopAppilicationManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  置顶的管理器，构造生成各种所需的置顶界面，并完成相应的响应
//  注：有置顶类型后，其实可以考虑使用TSToApplicationVC来完成对应的响应了

import UIKit

class TSTopAppilicationManager {

    /// 获取帖子置顶视图控制器
    class func postTopVC(postId: Int) -> TSToApplicationVC {
        let bntName: Array<String> = ["显示_1天".localized, "显示_5天".localized, "显示_10d".localized]
        let vc = TSToApplicationVC(type: .post, days: bntName)
        vc.setFinish { [weak vc] (day: Int, sumPrice: Int) in
            guard vc != nil else {
                return
            }
            // 显示加载中动画
            let alert = TSIndicatorWindowTop(state: .loading, title: "正在获取用户信息")
            alert.show()
            // 1.更新用户信息
            TSWalletTaskQueue.updateUserInfo(complete: { [weak vc] (isSuccess: Bool) in
                guard isSuccess, vc != nil else {
                    alert.dismiss()
                    return
                }
                alert.set(title: "正在发起申请")
                // 2.发起置顶申请
                GroupNetworkManager.topPost(postId: postId, amount: sumPrice, day: day, complete: { [weak vc] (status, message) in
                    alert.dismiss()
                    guard vc != nil else {
                        return
                    }
                    /// 支付需要密码弹窗
                    if TSAppConfig.share.localInfo.shouldShowPayAlert {
                        if status {
                            TSUtil.dismissPwdVC()
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                            return
                        }
                    }
                    let resultAlert = TSIndicatorWindowTop(state: status ? .success: .faild, title: message)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    _ = vc?.navigationController?.popViewController(animated: true)
                })
            })
        }
        return vc
    }

    /// 获取帖子评论置顶视图控制器
    class func postCommentTopVC(commentId: Int) -> TSToApplicationVC {
        let bntName: Array<String> = ["显示_1天".localized, "显示_5天".localized, "显示_10d".localized]
        let vc = TSToApplicationVC(type: .postComment, days: bntName)
        vc.setFinish { [weak vc] (day: Int, sumPrice: Int) in
            guard vc != nil else {
                return
            }
            // 显示加载中动画
            let alert = TSIndicatorWindowTop(state: .loading, title: "正在获取用户信息")
            alert.show()
            // 1.获取用户信息
            TSWalletTaskQueue.updateUserInfo(complete: { [weak vc] (isSuccess: Bool) in
                guard isSuccess, vc != nil else {
                    alert.dismiss()
                    return
                }
                alert.set(title: "正在发起申请")
                // 2.发起置顶申请
                GroupNetworkManager.topComment(commentId: commentId, amount: sumPrice, day: day, complete: { [weak vc] (status, message) in
                    alert.dismiss()
                    guard vc != nil else {
                        return
                    }
                    /// 支付需要密码弹窗
                    if TSAppConfig.share.localInfo.shouldShowPayAlert {
                        if status {
                            TSUtil.dismissPwdVC()
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                            return
                        }
                    }
                    let resultAlert = TSIndicatorWindowTop(state: status ? .success: .faild, title: message)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    _ = vc?.navigationController?.popViewController(animated: true)
                })
            })
        }
        return vc
    }

    /// 获取动态评论置顶视图控制器
    class func commentTopVC(comment: Int, feed: Int) -> TSToApplicationVC {
        let bntName: Array<String> = ["显示_1天".localized, "显示_5天".localized, "显示_10d".localized]
        let vc = TSToApplicationVC(type: .feedComment, days: bntName)
        vc.setFinish { [weak vc] (day: Int, sumPrice: Int) in
            guard vc != nil else {
                return
            }
            // 显示加载中动画
            let alert = TSIndicatorWindowTop(state: .loading, title: "正在获取用户信息")
            alert.show()
            // 1.更新用户信息
            TSWalletTaskQueue.updateUserInfo(complete: { [weak vc] (isSuccess: Bool) in
                guard isSuccess, vc != nil else {
                    alert.dismiss()
                    return
                }
                alert.set(title: "正在发起申请")
                // 2.发起置顶申请
                TSCommentNetWorkManager().set(comment: comment, ofFeed: feed, toTopDuring: day, withMoney: sumPrice, complete: { [weak vc] (status: Bool, message: String?) in
                    alert.dismiss()
                    guard vc != nil else {
                        return
                    }
                    /// 支付需要密码弹窗
                    if TSAppConfig.share.localInfo.shouldShowPayAlert {
                        if status {
                            TSUtil.dismissPwdVC()
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                            return
                        }
                    }
                    let resultAlert = TSIndicatorWindowTop(state: status ? .success: .faild, title: message)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    _ = vc?.navigationController?.popViewController(animated: true)
                })
            })
        }
        return vc
    }

    /// 获取动态置顶视图控制器
    class func momentTopVC(feedId: Int) -> TSToApplicationVC {
        let bntName: Array<String> = ["显示_1天".localized, "显示_5天".localized, "显示_10d".localized]
        let vc = TSToApplicationVC(type: .moment, days: bntName)
        vc.setFinish { [weak vc] (day: Int, sumPrice: Int) in
            guard vc != nil else {
                return
            }
            // 显示加载中动画
            let alert = TSIndicatorWindowTop(state: .loading, title: "正在获取用户信息")
            alert.show()
            // 1.更新用户信息
            TSWalletTaskQueue.updateUserInfo(complete: { [weak vc] (isSuccess: Bool) in
                guard isSuccess, vc != nil else {
                    alert.dismiss()
                    return
                }
                alert.set(title: "正在发起申请")
                // 2.发起置顶申请
                TSMomentNetworkManager().set(feed: feedId, toTopDuring: day, withMoney: sumPrice, complete: { [weak vc] (status: Bool, message: String?) in
                    alert.dismiss()
                    guard vc != nil else {
                        return
                    }
                    /// 支付需要密码弹窗
                    if TSAppConfig.share.localInfo.shouldShowPayAlert {
                        if status {
                            TSUtil.dismissPwdVC()
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                            return
                        }
                    }
                    let resultAlert = TSIndicatorWindowTop(state: status ? .success: .faild, title: message)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    _ = vc?.navigationController?.popViewController(animated: true)
                })
            })
        }
        return vc
    }

    /// 获取资讯评论置顶的视图控制器
    class func newsCommentTopVC(newsId: Int, commentId: Int) -> TSToApplicationVC {
        let bntName: Array<String> = ["显示_1天".localized, "显示_5天".localized, "显示_10d".localized]
        let vc = TSToApplicationVC(type: .newsComment, days: bntName)
        vc.setFinish { [weak vc] (day: Int, sumPrice: Int) in
            guard vc != nil else {
                return
            }
            // 显示加载中动画
            let alert = TSIndicatorWindowTop(state: .loading, title: "正在获取用户信息")
            alert.show()
            // 1.更新用户信息
            TSWalletTaskQueue.updateUserInfo(complete: { [weak vc] (isSuccess: Bool) in
                guard isSuccess, vc != nil else {
                    alert.dismiss()
                    return
                }
                alert.set(title: "正在发起申请")
                // 2.发起置顶申请
                TSNewsNetworkManager().applyCommentTop(newsId: newsId, commentId: commentId, day: day, amount: sumPrice, complete: { (message, status) in
                    alert.dismiss()
                    guard vc != nil else {
                        return
                    }
                    /// 支付需要密码弹窗
                    if TSAppConfig.share.localInfo.shouldShowPayAlert {
                        if status {
                            TSUtil.dismissPwdVC()
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                            return
                        }
                    }
                    let resultAlert = TSIndicatorWindowTop(state: status ? .success: .faild, title: message)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    _ = vc?.navigationController?.popViewController(animated: true)
                })
            })
        }
        return vc
    }

    /// 获取资讯置顶的视图控制器
    class func newsTopVC(newsId: Int) -> TSToApplicationVC {
        let bntName: Array<String> = ["显示_1天".localized, "显示_5天".localized, "显示_10d".localized]
        let vc = TSToApplicationVC(type: .news, days: bntName)
        vc.setFinish { [weak vc] (day: Int, sumPrice: Int) in
            guard vc != nil else {
                return
            }
            // 显示加载中动画
            let alert = TSIndicatorWindowTop(state: .loading, title: "正在获取用户信息")
            alert.show()
            // 1.更新用户信息
            TSWalletTaskQueue.updateUserInfo(complete: { [weak vc] (isSuccess: Bool) in
                guard isSuccess, vc != nil else {
                    alert.dismiss()
                    return
                }
                alert.set(title: "正在发起申请")
                // 2.发起置顶申请
                TSNewsNetworkManager().newsApplyToTop(newsID: newsId, day: day, amount: sumPrice, complete: { (message, status) in
                    alert.dismiss()
                    guard vc != nil else {
                        return
                    }
                    /// 支付需要密码弹窗
                    if TSAppConfig.share.localInfo.shouldShowPayAlert {
                        if status {
                            TSUtil.dismissPwdVC()
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name.Pay.showMessage, object: nil, userInfo: ["message": message ?? "提示信息_支付验证错误默认信息".localized])
                            return
                        }
                    }
                    let resultAlert = TSIndicatorWindowTop(state: status ? .success: .faild, title: message)
                    resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    _ = vc?.navigationController?.popViewController(animated: true)
                })
            })
        }
        return vc
    }
}
