//
//  TSNewsListReviewStatusController.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  资讯列表数据查看状态控制器

import UIKit

class TSNewsViewStatusController {
    /// 已查看的资讯标识组成的数组
    lazy private var viewNews = [Int]()

    /// 添加已查看过的资讯标识
    func addViewed(newsId: Int) {
        if viewNews.contains(newsId) {
            return
        }
        viewNews.append(newsId)
    }

    func isContains(newsId: Int) -> Bool {
        return viewNews.contains(newsId)
    }

    func removeAll() {
        viewNews.removeAll()
    }
}
