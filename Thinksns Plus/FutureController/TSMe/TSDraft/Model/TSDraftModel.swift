//
//  TSDraftModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 11/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  草稿箱的数据模型
//  暂时没有使用，但之后可以考虑

import Foundation

///// 草稿箱的类型
//enum TSDraftType {
//    case question
//    case answer
//    case post
////    case news
//}

class TSDraftModel {
//    var type: TSDraftType = .question

    ///  草稿箱id
    var draftId: Int = 0
    /// 创建时间
    var createDate: Date = Date()
    /// 最近的修改时间
    var updateDate: Date = Date()

    /// 问题草稿的标题 或 答案草稿时回答的问题的标题
    var questionTitle: String?

    /// 答案草稿时回答的问题的id
    var questionId: Int = 0
    /// 答案草稿的内容
    var answer: String?

}
