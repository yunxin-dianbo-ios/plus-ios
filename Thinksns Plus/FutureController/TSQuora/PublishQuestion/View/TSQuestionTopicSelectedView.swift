//
//  TSQuestionTopicSelectedView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 07/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题发布 - 话题选择的视图(可点击取消选中 并消失)

import UIKit

protocol TSQuestionTopicSelectedViewProtocol: class {
    /// 删除按钮点击响应
    func topicView(_ topicView: TSQuestionTopicSelectedView, didDeleteBtnClickWith cancelTopic: TSQuoraTopicModel) -> Void
}

class TSQuestionTopicSelectedView: UIView {

    // MARK: - Internal Property
    /// 代理
    weak var delegate: TSQuestionTopicSelectedViewProtocol?
    /// 数据模型列表
    var topics: [TSQuoraTopicModel]? {
        didSet {
            self.setupWithTopicList(topics)
        }
    }
    /// 当前高度(加载数据后会更新)
    private(set) var currentHeight: CGFloat = 0

    // MARK: - Internal Function

    // MARK: - Private Property

    /// 左侧间距
    private let leftMargin: CGFloat = 15
    /// 右侧间距
    private let rightMargin: CGFloat = 15
    /// 顶部间距
    private let topMargin: CGFloat = 10
    /// 底部间距
    private let bottomMargin: CGFloat = 10
    /// 水平中间间距
    private let horCenterMargin: CGFloat = 7
    /// 竖直中间间距
    private let verCenterMargin: CGFloat = 10
    /// tag基值
    private let tagBase: Int = 250

    // MARK: - Initialize Function
    init() {
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
        //fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {

    }

    // 加载数据
    private func setupWithTopicList(_ topicList: [TSQuoraTopicModel]?) -> Void {
        self.removeAllSubViews()
        self.currentHeight = 0
        guard let topicList = topicList else {
            return
        }
        if topicList.isEmpty {
            return
        }
        // 遍历加载
        var topMargin: CGFloat = self.topMargin
        var leftMargin: CGFloat = self.leftMargin
        for (index, topic) in topicList.enumerated() {
            let singleTopicView = TSQuestionSingleTopicSelectedView()
            self.addSubview(singleTopicView)
            singleTopicView.cancelBtn.addTarget(self, action: #selector(cancelBtnClick(_:)), for: .touchUpInside)
            singleTopicView.cancelBtn.tag = index + tagBase
            singleTopicView.titleLabel.text = topic.name
            var width = TSQuestionSingleTopicSelectedView.widthWithTitle(topic.name)
            // 判断是否超过最大宽度
            if width > ScreenWidth - self.leftMargin - self.rightMargin {
                width = ScreenWidth - self.leftMargin - self.rightMargin
                // 判断当前是否刚换行
                if abs(leftMargin - self.leftMargin) > 0.1 {
                    leftMargin = self.leftMargin
                    topMargin += TSQuestionSingleTopicSelectedView.defaultH + self.verCenterMargin
                }
            }
            // 判断不超过最大宽度的情况下 是否换行
            else if leftMargin + width + rightMargin > ScreenWidth {
                // 换行
                leftMargin = self.leftMargin
                topMargin += TSQuestionSingleTopicSelectedView.defaultH + self.verCenterMargin
            }
            singleTopicView.snp.makeConstraints({ (make) in
                make.width.equalTo(width)
                make.height.equalTo(TSQuestionSingleTopicSelectedView.defaultH)
                make.leading.equalTo(self).offset(leftMargin)
                make.top.equalTo(self).offset(topMargin)
                if index == topicList.count - 1 {
                    make.bottom.equalTo(self).offset(-self.bottomMargin)
                }
            })
            // 标记修正
            leftMargin += width + horCenterMargin
        }
        self.currentHeight = topMargin + TSQuestionSingleTopicSelectedView.defaultH + self.bottomMargin
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

    /// 取消按钮点击响应
    @objc private func cancelBtnClick(_ button: UIButton) -> Void {
        let index = button.tag - tagBase
        let topic = self.topics![index]
        self.delegate?.topicView(self, didDeleteBtnClickWith: topic)
    }
}
