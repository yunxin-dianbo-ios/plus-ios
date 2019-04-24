//
//  ATagsVeiw.swift
//  RealmTest
//
//  Created by GorCat on 2017/9/7.
//  Copyright © 2017年 GorCat. All rights reserved.
//
//  标签视图
/*
 实例代码：
 // 1.创建视图
 let tagView = ATagsVeiw()
 // 2.设置视图的宽度
 tagView.frame = CGRect(origin: CGPoint(x: 0, y: 300), size: CGSize(width: 200, height: 0))
 // 3.添加内容，这一步结束后，tagView 的高度会更新
 tagView.add(tags: ["675467456785757757842193741293047129347902374109237491dskfajsdlfjlasdjfalsdfjals;dfn sdf", "88888888", "999","43243434","341234","777","743432523577"])
 // 4.将视图添加在控制器上
 view.addSubview(tagView)
 
 */

import UIKit

class ATagsVeiw: UIView {

    /// tag 字体大小
    var tagFont: CGFloat = 10
    /// tag 字体颜色
    var tagTextColor = UIColor(hex: 0x666666)
    /// tag 背景颜色
    var tagBackgroudColor = TSColor.main.theme.withAlphaComponent(0.15)
    /// tag 圆角
    var tagRadius: CGFloat = 4
    /// tag 内边距
    var tagPadding = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)

    /// 两个 tag 之间的间距
    var tagSpacing: CGFloat = 5
    /// ATagsVeiw 内边距
    var viewPadding = UIEdgeInsets.zero
    /// AtagsView 的最大宽度
    var maxWidth = UIScreen.main.bounds.width

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        maxWidth = frame.width
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func updateSubviewsFrame() {
//        UIView.beginAnimations(nil, context: nil)
        let paddingRight = viewPadding.right
        var x = viewPadding.left
        var y = viewPadding.top
        var itemFrame = CGRect.zero
        for view in subviews {
            itemFrame = view.frame
            itemFrame.origin = CGPoint(x: x, y: y)
            if itemFrame.maxX + paddingRight > maxWidth {
                // 换行
                itemFrame.origin.x = viewPadding.left
                itemFrame.origin.y = itemFrame.maxY + tagSpacing
                y = itemFrame.origin.y
            }
            if itemFrame.maxX > maxWidth - paddingRight {
                itemFrame.size.width = frame.size.width - paddingRight - itemFrame.origin.x
            }
            x = itemFrame.maxX + tagSpacing
            view.frame = itemFrame
        }
        let viewHeight = itemFrame.maxY + viewPadding.bottom
        var viewFrame = frame
        viewFrame.size.height = viewHeight
        frame = viewFrame
//        UIView.commitAnimations()
    }

    // MARK: - UI
    func setUI() {
        backgroundColor = UIColor.white
    }

    internal func add(tag text: String, at index: Int) {
        // 获取上一个 tag 的 frame
        var lastFrame = CGRect.zero
        if let lastTag = subviews.last {
            lastFrame = lastTag.frame
        }

        let item = ATagItem()
        // 设置 tag 的整体界面相关
        item.tagPadding = tagPadding
        item.tagRadius = tagRadius
        item.backgroundColor = tagBackgroudColor
        item.tagMaxWidth = maxWidth - viewPadding.left - viewPadding.right
        // 设置 tag 的文字相关
        item.tagText = text
        item.tagFont = tagFont
        item.tagTextColor = tagTextColor

        item.tag = index
        item.frame.origin = lastFrame.origin
        addSubview(item)
    }

    // MARK: - Public

    /// 移除 tag
    func removeTag(text: String) {
        for view in subviews {
            if let tagItem = view as? ATagItem, tagItem.tagText == text {
                tagItem.removeFromSuperview()
            }
        }
    }

    /// 添加很多 tag
    func add(tags: [String]) {
        for index in 0..<tags.count {
            let text = tags[index]
            add(tag: text, at: index)
        }
        updateSubviewsFrame()
    }

    /// 移除所有 tag
    func removeAllTags() {
        let _ = subviews.map { $0.removeFromSuperview() }
    }

}
