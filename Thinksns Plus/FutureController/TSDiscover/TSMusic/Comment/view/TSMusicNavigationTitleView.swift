//
//  TSMusicNavigationTitleView.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

private struct titleViewUX {
    /// 字体颜色 专辑详情样式 （白色）
    static let TextColor_AlbumType = TSColor.main.white
    /// 字体颜色 音乐播放样式 （黑色）
    static let TextColor_SongType = TSColor.main.content
    /// 跑马灯字体大小
    static let marqueeTextFontSize = TSFont.Navigation.subTitle
    /// 歌手名字体大小
    static let nameTextFontSize = TSFont.SubUserName.singer
}

class TSMusicNavigationTitleView: UIView {

    /// 布局类型
    ///
    /// - Album: 专辑详情页的样式
    /// - Song: 音乐播放页的样式
    enum ViewType {
        case Album
        case Song
    }

    /// 跑马灯控件
    private var marqueeLabel = TSMarqueeLabel()
    /// 歌手名
    private let nameLabel = UILabel()
    /// 布局样式
    var viewType: ViewType = .Album
    /// 跑马文本框文本
    var marqueeText: String? = nil
    /// 副标题
    var subTitle: String? = nil

    init(frame: CGRect, type: ViewType) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.viewType = type
        self.nameLabel.textAlignment = NSTextAlignment.center
        self.nameLabel.textColor = titleViewUX.TextColor_SongType
        self.nameLabel.font = UIFont.systemFont(ofSize: titleViewUX.nameTextFontSize.rawValue)
        switch viewType {
        case .Album:
            self.nameLabel.isHidden = true
            self.marqueeLabel.LabelFrame = self.bounds
            self.marqueeLabel.textColor = titleViewUX.TextColor_AlbumType
            break
        case .Song:
            self.marqueeLabel.LabelFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - 14)
            self.marqueeLabel.textColor = titleViewUX.TextColor_SongType
            self.nameLabel.isHidden = false
            self.nameLabel.frame = CGRect(x: 0, y: self.marqueeLabel.frame.maxY, width: self.frame.width, height: 14)
            break
        }
        self.marqueeLabel.textFontSize = titleViewUX.marqueeTextFontSize.rawValue
        self.marqueeLabel.text = self.marqueeText
        self.addSubview(self.marqueeLabel)
        self.addSubview(self.nameLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Method
    func setText(marqueeText: String, subTitle: String?) {
        self.marqueeLabel.reSetTitle(title: marqueeText)
        self.nameLabel.text = subTitle
    }
}
