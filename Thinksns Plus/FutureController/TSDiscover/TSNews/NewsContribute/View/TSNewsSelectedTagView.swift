//
//  TSNewsSelectedTagView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 16/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯模块中选中的标签视图
//  注1：无需换行时，竖直方向居中展示；需要换行时，上下间距一致，中间有单独间距。(所以需传入宽度和最小高度)
//  注2：本视图有默认占位标签视图，位于右侧部分。
//  之后根据需要，若能公用，则可重命名为TSSelectedTagView
//  TODO: - 这里在赋值标签数组的时候应该返回新的高度，因为可能再别的地方使用时需要具体高度，比如tableView中
//          或者增加一个当前高度，并提供一个根据标签数组计算高度的方法

import UIKit

class TSNewsSelectedTagView: UIView {

    // MARK: - Internal Property
    /// 选中的标签数组
    var selectedTagList: [TSTagModel]? {
        didSet {
            self.setupWithTags(selectedTagList)
        }
    }
    var placeHolder: String? {
        didSet {
            self.tagsPlaceLabel.text = placeHolder
        }
    }
    // MARK: - Private Property
    private let maxWidth: Float        // 视图宽度
    private let minHeight: Float    // 控件最小的高度
    private weak var tagsView: UIView!
    private weak var tagsPlaceLabel: UILabel!

    private let contentMargin: Float = 5    // tag控件之间的间距
    private let tbMargin: Float = 13        // tag控件上下的间距
//    let tbMargin: Float = 13
//    let contentMargin: Float = 5

    private let maxSelectedCount: Int = 5       // 最大选中个数

    // MARK: - Internal Function

    // MARK: - Initialize Function
    init(width: Float, minHeight: Float) {
        self.maxWidth = width
        self.minHeight = minHeight
        super.init(frame: CGRect.zero)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        self.maxWidth = Float(UIScreen.main.bounds.size.width)
        self.minHeight = 50
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // 1. tagsView
        let tagsView = UIView()
        self.addSubview(tagsView)
        tagsView.isUserInteractionEnabled = false
        tagsView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        self.tagsView = tagsView
        // 2. placeLabel
        let placeLabel = UILabel(text: "占位符_请选择标签".localized, font: UIFont.systemFont(ofSize: 15), textColor: UIColor(hex: 0xcccccc), alignment: .right)
        self.addSubview(placeLabel)
        placeLabel.snp.makeConstraints { (make) in
            make.leading.trailing.centerY.equalTo(self)
        }
        self.tagsPlaceLabel = placeLabel
    }

    // MARK: - Private  数据加载

    /// 数据加载
    private func setupWithTags(_ tags: [TSTagModel]?) -> Void {
        self.tagsView.removeAllSubViews()
        // 判空处理
        self.tagsPlaceLabel.isHidden = true
        guard let tagList = tags else {
            self.tagsPlaceLabel.isHidden = false
            return
        }
        if tagList.isEmpty {
            self.tagsPlaceLabel.isHidden = false
            return
        }

        let linebreakFlag = self.setupNeedLineBreakWithTags(tagList)
        let tagsMaxW: Float = self.maxWidth

        let tagH: Float = 24            // 单个tag控件的高度
        // 动态标记
        var lastRightX: Float = 0
        var lastTopY: Float = tbMargin
        // 根据内容判断是否需要换行
        for (index, tag) in tagList.enumerated() {
            // 超出最大展示数限定
            if index >= maxSelectedCount {
                break
            }
            // 当个标签添加
            let tagW: Float = TSNewsSelectedSingleTagView.widthWithTitle(tag.name)
            let singleTagView = TSNewsSelectedSingleTagView(title: tag.name)
            self.tagsView.addSubview(singleTagView)
            var leftMargin: Float = lastRightX + contentMargin
            var topMargin: Float = lastTopY
            // 换行处理
            if linebreakFlag && leftMargin + tagW + contentMargin > tagsMaxW {
                leftMargin = contentMargin
                topMargin = lastTopY + tagH + contentMargin
            }
            singleTagView.snp.makeConstraints({ (make) in
                make.width.equalTo(tagW)
                make.height.equalTo(tagH)
                if linebreakFlag {
                    make.top.equalTo(self.tagsView).offset(topMargin)
                    make.leading.equalTo(self.tagsView).offset(leftMargin)
                    // 最后一个底部进行特殊约束
                    if index == maxSelectedCount - 1 || index == tagList.count - 1 {
//                        make.bottom.lessThanOrEqualTo(self.tagsView).offset(-tbMargin)
                        make.bottom.equalTo(self.tagsView).offset(-tbMargin)
                    }
                } else {
                    make.leading.equalTo(self.tagsView).offset(leftMargin)
                    make.centerY.equalTo(self.tagsView)
                }
            })
            // 标记更新
            if linebreakFlag {
                lastRightX = leftMargin + tagW
                lastTopY = topMargin
            } else {
                lastRightX = leftMargin + tagW
            }
        }
    }

    /// 加载内容时判断是否需要换行展示
    func setupNeedLineBreakWithTags(_ tags: [TSTagModel]) -> Bool {
        var linebreakFlag: Bool = false
        var currentW: Float = 0
        for tag in tags {
            currentW += contentMargin + TSNewsSelectedSingleTagView.widthWithTitle(tag.name)
            // 换行
            if currentW > self.maxWidth {
                linebreakFlag = true
                break
            }
        }
        return linebreakFlag
    }

    // MARK: - Private  事件响应

}
