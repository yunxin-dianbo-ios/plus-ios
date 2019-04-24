//
//  TSGifManagerTool.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2019/3/14.
//  Copyright © 2019年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSGifManagerTool: NSObject {

    static let gifManager = TSGifManagerTool()
    private override init() {
    }
    /// 当前用户的信息
    internal var _currentTable: FeedListView?
    var currentTable: FeedListView? {
        set {
            if newValue != nil {
                _currentTable = newValue
            }
        }
        get {
            return _currentTable
        }
    }
    var currentFeedCell: FeedListCell?
    var gifIndexArr: [TimeInterval] = []
    var currentIndexGif: Int = 0
    var cycyleTimer : Timer?
    var currentTime: TimeInterval = 0.0
    var totalTime: TimeInterval = 0.0
    var shoulStop = false

    /// 获取当前列表里面可视feedcell里面第一个有gif动图的cell。将这个cell里面的动图拿出来开始循环播放
    func getFirstGifCell() {
        totalTime = 0
        currentIndexGif = 0
        currentTime = 0.0
        gifIndexArr.removeAll()
        var hasGif = false
        if currentTable != nil && currentTable?.visibleCells != nil {
            if (currentTable?.visibleCells.count)! > 0 {
                for (index, item) in (currentTable?.visibleCells.enumerated())! {
                    for (index1, item1) in (item as! FeedListCell).picturesView.models.enumerated() {
                        if item1.mimeType == "image/gif" {
                            hasGif = true
                            currentFeedCell = (item as! FeedListCell)
                            break
                        }
                    }
                }
            }
        }
        if hasGif && currentFeedCell != nil {
            /// 取出当前cell里面的所有图片（暂时不考虑当前cell被遮挡的动图）
            for (index1, item1) in currentFeedCell!.picturesView.pictureViews.enumerated() {
                if index1 > (currentFeedCell?.picturesView.models.count)! - 1 {
                    break
                }
                if item1.model.mimeType == "image/gif" {
                    if item1.pictureView.animationImages != nil {
                        var totalGifTime: TimeInterval = 0
                        for (index2, item2) in (item1.pictureView.animationImages?.enumerated())! {
                            totalGifTime = totalGifTime + item2.duration
                        }
                        gifIndexArr.append(totalGifTime)
                        totalTime = totalTime + totalGifTime
                    }
                } else {
                    gifIndexArr.append(TimeInterval(0))
                }
            }
            if let timer = cycyleTimer {
//                timer.invalidate()
            } else {
                cycyleTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
            }
//            cycyleTimer?.fire()
        }
    }

    func playGif() {
        if shoulStop {
            return
        }
        var shouldTime: TimeInterval = 0.0
        for (index, item) in gifIndexArr.enumerated() {
            shouldTime = shouldTime + item
            if index >= currentIndexGif {
                break
            }
        }
        if currentTime < shouldTime {
        } else {
            if currentIndexGif >= gifIndexArr.count - 1 {
                currentIndexGif = 0
            } else {
                currentIndexGif = currentIndexGif + 1
            }
        }
        if currentFeedCell != nil {
            for (index1, item1) in currentFeedCell!.picturesView.pictureViews.enumerated() {
                if index1 > (currentFeedCell?.picturesView.models.count)! - 1 {
                    break
                }
                if index1 != currentIndexGif {
                    item1.pictureView.stopAnimating()
                }
            }
            if currentTime < shouldTime {

            } else {
                currentFeedCell!.picturesView.pictureViews[currentIndexGif].pictureView.startAnimating()
            }
        }
        if currentFeedCell!.picturesView.pictureViews[currentIndexGif].pictureView.animationImages != nil {
            var totalGifTime: TimeInterval = 0
            for (index2, item2) in (currentFeedCell!.picturesView.pictureViews[currentIndexGif].pictureView.animationImages?.enumerated())! {
                totalGifTime = totalGifTime + item2.duration
            }
            self.perform(#selector(playGif), afterDelay: totalGifTime)
        } else {
            self.perform(#selector(playGif), afterDelay: 0)
        }
    }

    func updateCurrentTime() {
        if currentTime >= totalTime {
            currentTime = 0.0
        } else {
            currentTime = currentTime + 1
        }
    }

    func stopGif() {
        shoulStop = true
        if let timer = cycyleTimer {
//            timer.invalidate()
        }
        if currentFeedCell != nil {
            for (index1, item1) in currentFeedCell!.picturesView.pictureViews.enumerated() {
                if index1 > (currentFeedCell?.picturesView.models.count)! - 1 {
                    break
                }
                item1.pictureView.stopAnimating()
            }
        }
    }

    func starGif() {
        shoulStop = false
        playGif()
    }
}
