//
//  TSMomentFeedModel.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态内容的数据模型

import UIKit
import SwiftyJSON

struct TSMomentFeedModel {

    // [长期注释] 为方便 v2 的数据接入，增加了初始值

    /// 动态标识
    var feedIdentity: Int = -1
    /// 动态标题
    var title: String = ""
    /// 动态内容
    var content: String = ""
    /// 创建时间
    var create: NSDate = NSDate()
    var update: NSDate? = nil
    var delete: NSDate? = nil
    /// 来源，1:pc 2:h5 3:ios 4:android 5:其他
    var from: Int = -1
    // 图片数组
    var pictures: [TSImageObject] = []
    // 短视频文件标识
    var videoID: Int?
    // 短视频封面标识
    var coverID: Int?
    // 短视频高度
    var videoHeight: Int?
    // 短视频宽度
    var videoWidth: Int?
    /// 话题信息
    var topics: [TopicListModel] = []
    /// 转发的类型
    var repostType: String? = nil
    /// 转发的ID
    var repostId: Int = 0
    /// 转发信息
    var repostModel: TSRepostModel? = nil
}
