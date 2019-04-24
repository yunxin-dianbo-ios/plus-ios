//
//  TSIMMessageManager.swift
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/8/10.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSIMMessageManager: NSObject {
    class func sendMessage(message: EMMessage, UpProgress: @escaping (Int32) -> Void, complete: @escaping (EMMessage?, EMError?) -> Void) {
        EMClient.shared().chatManager.send(message, progress: { (progress) in
            UpProgress(progress)
        }) { (aMessage, error) in
            complete(aMessage, error)
        }
    }
    /// 通过PopModel和
    class func sendShareCardMessage(model: TSmessagePopModel, conversationId: String, conversationType: EMConversationType, UpProgress: @escaping (Int32) -> Void, complete: @escaping (EMMessage?, EMError?) -> Void) {
        TSIMMessageManager.sendMessage(message: TSIMMessageManager.coverSendMessage(model: model, conversationId: conversationId, conversationType: conversationType), UpProgress: { (progress) in
            UpProgress(progress)
        }) { (aMessage, error) in
            if model.noteContent.count > 0 {
                var chatType = EMChatTypeChat
                if conversationType == EMConversationTypeChat {
                    chatType = EMChatTypeChat
                } else if conversationType == EMConversationTypeGroupChat {
                    chatType = EMChatTypeGroupChat
                }
                TSIMMessageManager.sendMessage(message: EaseSDKHelper.getTextMessage(model.noteContent, to: conversationId, messageType: chatType, messageExt: nil), UpProgress: { (progress) in
                }, complete: { (aMessage, error) in
                })
            }
            complete(aMessage, error)
        }
    }
    // 分享至私信的model转换为message
    fileprivate class func coverSendMessage(model: TSmessagePopModel, conversationId: String, conversationType: EMConversationType) -> EMMessage {
        var extInfo: [String: String]!
        if model.contentType == .text {
            // 文字动态
            extInfo = ["letter": "dynamic", "letter_id": String(model.feedId), "letter_name": model.owner, "dynamic_type": "dynamic_word", "circle_id": ""]
        } else if model.contentType == .pic {
            // 图片动态
            extInfo = ["letter": "dynamic", "letter_id": String(model.feedId), "letter_name": model.owner, "dynamic_type": "dynamic_image", "circle_id": ""]
        } else if model.contentType == .video {
            // 视频动态
            extInfo = ["letter": "dynamic", "letter_id": String(model.feedId), "letter_name": model.owner, "dynamic_type": "dynamic_video", "circle_id": ""]
        } else if model.contentType == .groupPic {
            // 圈子
            extInfo = ["letter": "circle", "letter_id": String(model.feedId), "letter_name": model.owner, "letter_image": model.coverImage, "dynamic_type": "", "circle_id": ""]
        } else if model.contentType == .postText || model.contentType == .postPic {
            // 帖子 需要额外传递一个所属圈子的ID
            extInfo = ["letter": "post", "letter_id": String(model.feedId), "letter_name": model.owner, "letter_image": model.coverImage, "dynamic_type": "", "circle_id": String(model.groupId)]
        } else if model.contentType == .newsText || model.contentType == .newsPic {
            // 资讯
            extInfo = ["letter": "info", "letter_id": String(model.feedId), "letter_name": model.owner, "letter_image": model.coverImage, "dynamic_type": "", "circle_id": ""]
        } else if model.contentType == .question {
            // 问题
            extInfo = ["letter": "questions", "letter_id": String(model.feedId), "letter_name": model.owner, "letter_image": "", "dynamic_type": "", "circle_id": ""]
        } else if model.contentType == .questionAnswer {
            // 问题
            extInfo = ["letter": "question-answers", "letter_id": String(model.feedId), "letter_name": model.owner, "letter_image": "", "dynamic_type": "", "circle_id": ""]
        }
        // 已经过滤markdown格式的标签，需要判断一下是否需要截断前50字
        if model.content.count > 50 {
            model.content = model.content.substring(to: model.content.index(model.content.startIndex, offsetBy: 50))
        }
        var chatType = EMChatTypeChat
        if conversationType == EMConversationTypeChat {
            chatType = EMChatTypeChat
        } else if conversationType == EMConversationTypeGroupChat {
            chatType = EMChatTypeGroupChat
        }
        return EaseSDKHelper.getTextMessage(model.content, to: conversationId, messageType: chatType, messageExt: extInfo)
    }
}
