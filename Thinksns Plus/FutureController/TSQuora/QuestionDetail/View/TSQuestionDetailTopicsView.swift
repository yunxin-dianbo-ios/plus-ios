//
//  TSQuestionDetailTopicsView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 29/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题详情中的话题视图
//  无需换行时，竖直方向居中展示；需要换行时，上下间距一致，中间有单独间距。

import UIKit

/// 话题视图的回调
protocol TSQuestionDetailTopicsViewProtocol: class {
    /// 选中选中的回调
    func topicView(_ topicView: TSQuestionDetailTopicsView, didClickTopic topic: TSQuoraTopicModel) -> Void
}

class TSQuestionDetailTopicsView: UIView {
    // MARK: - Internal
    weak var delegate: TSQuestionDetailTopicsViewProtocol?
    var topics: [TSQuoraTopicModel]? {
        didSet {
            guard let topics = topics else {
                self.removeAllSubViews()
                self.currentHeight = self.minHeight
                return
            }
            _ = self.setupWithTopics(topics, showMax: 5, topicLrMargin: 12)
        }
    }
    func heightWithTopics(_ topics: [TSQuoraTopicModel]) -> Float {
        return TSQuestionDetailTopicsView(width: self.maxWidth, minHeight: self.minHeight).setupWithTopics(topics, showMax: 5, topicLrMargin: 12)
    }
    /// 加载话题列表并返回高度
    private func loadTopics(_ topics: [TSQuoraTopicModel], maxCount: Int = 5) -> Float {
        return self.setupWithTopics(topics, showMax: maxCount, topicLrMargin: 12)
    }
    /// 当前高度
    private(set) var currentHeight: Float

    // MARK: - Private Property

    private let maxWidth: Float        // 视图宽度
    private let minHeight: Float    // 控件最小的高度
    private let contentMargin: Float = 5    // tag控件之间的间距
    private let tbMargin: Float = 13        // tag控件上下的间距
    private let kTopicTagBase: Int = 250    // 话题的tag基值

    // MARK: - Initialize Function
    init(width: Float, minHeight: Float) {
        self.maxWidth = width
        self.minHeight = minHeight
        self.currentHeight = minHeight
        super.init(frame: CGRect(x: 0, y: 0, width: CGFloat(maxWidth), height: CGFloat(minHeight)))
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {

    }

    // MARK: - Private  数据加载

    /// 数据加载
    /// Topics: 数据模型、showMax：最大展示个数、topicLrMargin：话题左右两侧的间距
    private func setupWithTopics(_ topics: [TSQuoraTopicModel], showMax: Int = Int.max, topicLrMargin: Float = 10) -> Float {
        self.removeAllSubViews()
        // 判空处理
        if topics.isEmpty {
            self.currentHeight = self.minHeight
            return self.minHeight
        }
        // 是否需要换行判断
        let linebreakFlag = self.setupNeedLineBreakWithTopics(topics, showMax: showMax, topicLrMargin: topicLrMargin)
        let topicMaxW: Float = self.maxWidth
        let topicH: Float = 20      // 单个topic控件的高度
        // 动态标记
        var lastRightX: Float = 0
        var lastTopY: Float = tbMargin
        var height: Float = self.minHeight
        // 遍历添加
        for (index, topic) in topics.enumerated() {
            // 超出最大展示数限定
            if index >= showMax {
                break
            }
            // 单个话题添加展示
            let topicW: Float = TSNewsSelectedSingleTagView.widthWithTitle(topic.name, lrMargin: topicLrMargin)
            var leftMargin: Float = lastRightX + ((index == 0) ? 0 : contentMargin)
            var topMargin: Float = lastTopY
            let topicView = TSNewsSelectedSingleTagView(title: topic.name)
            self.addSubview(topicView)
            topicView.backgroundColor = TSColor.main.theme.withAlphaComponent(0.15)
            topicView.layer.cornerRadius = CGFloat(topicH) * 0.5
            topicView.addTarget(self, action: #selector(topicControlClick(_:)), for: .touchUpInside)
            topicView.tag = self.kTopicTagBase + index
            // 换行处理
            if linebreakFlag && leftMargin + topicW + contentMargin > topicMaxW {
                leftMargin = 0
                topMargin = lastTopY + topicH + contentMargin
            }
            topicView.snp.makeConstraints({ (make) in
                make.width.equalTo(topicW)
                make.height.equalTo(topicH)
                make.leading.equalTo(self).offset(leftMargin)
                // 会换行与不会换行的竖直方向的约束处理
                if linebreakFlag {
                    make.top.equalTo(self).offset(topMargin)
                    // 最后一个底部进行特殊约束
                    if index == showMax - 1 || index == topics.count - 1 {
                        make.bottom.equalTo(self).offset(-tbMargin)
                    }
                } else {
                    make.centerY.equalTo(self)
                }
            })
            // 标记更新
            lastRightX = leftMargin + topicW
            if linebreakFlag {
                lastTopY = topMargin
            }
            // 高度修正
            if linebreakFlag && (index == showMax - 1 || index == topics.count - 1) {
                height = lastTopY + topicH + tbMargin
            }
        }
        self.currentHeight = height
        return height
    }
    /// 加载内容时判断是否需要换行展示
    func setupNeedLineBreakWithTopics(_ topics: [TSQuoraTopicModel], showMax: Int = Int.max, topicLrMargin: Float = 10) -> Bool {
        var linebreakFlag: Bool = false
        var currentW: Float = 0
        for (index, topic) in topics.enumerated() {
            if index >= showMax {
                break
            }
            currentW += contentMargin + TSNewsSelectedSingleTagView.widthWithTitle(topic.name, lrMargin: topicLrMargin)
            // 换行
            if currentW > self.maxWidth {
                linebreakFlag = true
                break
            }
        }
        return linebreakFlag
    }

    // MARK: - Private  事件响应

    /// 话题点击响应
    @objc fileprivate func topicControlClick(_ control: UIControl) -> Void {
        guard let topics = self.topics else {
            return
        }
        let index = control.tag - self.kTopicTagBase
        if index > topics.count - 1 {
            return
        }
        self.delegate?.topicView(self, didClickTopic: topics[index])
    }
}
