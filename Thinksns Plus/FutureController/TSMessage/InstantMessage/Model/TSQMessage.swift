//
//  TSQMessage.swift
//  Thinksns Plus
//
//  Created by lip on 2017/3/17.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  显示到UI上的数据模型

import JSQMessagesViewController

class TSQMessage: JSQMessage {
    /// 发送状态
    var outgoingStatus: Bool? = nil
    /// 发送错误显示按钮的标签
    ///
    /// - Note: 发现成功前和发送成功后都使用本地的发送时间作为时间戳,方便查询数据库
    var sendErrorButtonTag: NSDate? = nil
}
