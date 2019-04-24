//
//  TSAnswerDetailController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 26/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  答案详情界面
//  答案删除处理：答案删除时会代理回调、必包回调、发送删除答案的通知。

import UIKit

protocol TSAnswerDetailControllerProtocol: class {
    func didDeletedAnswer(_ answerId: Int) -> Void
}
extension Notification.Name {
    static let AnswerDeletedNotification = Notification.Name("I deleted an answer")
}

/**
 * 注：答案详情页暂时使用TSAnswerCommentController代替，等测试测试完毕后再用TSAnswerCommentController代替本页中的注释代码
 这样做，可以避免出现一些bug时，无从下手或者不好解决时，可以参照之前的代码。
 甚至出现短期解决麻烦的代码时，完全可以使用注释中的代码。因为注释中的代码是完全可用的，且评论部分也已被替换。
 **/
typealias TSAnswerDetailController = TSAnswerCommentController
