//
//  TSMusicLyricsView.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/2/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

private struct TSMusicLyricsViewUX {
    /// 歌词视图与主视图的上间隔
    static let lyricVerticalMarginTop: CGFloat = 60
    /// 歌词视图与主视图的上间隔
    static let lyricVerticalMarginBottom: CGFloat = 30
}
/// 显示黑胶唱片视图的通知
public let ShowTSPhonographRootView = "ThinksnsPlus.TSMusicPlayVC.ShowTSPhonographRootView"

class TSMusicLyricsView: UIView {
    /// 歌词滚动视图
    let lyricsScorllView = UIScrollView()
    /// 歌词文本视图
    let lyricsTextlabel = UILabel()
    /// 歌曲名
    let songName = UILabel()
    /// 歌手名
    let singerName = UILabel()
    /// 歌词数据 【现在是假数据】
    var lyricText: String? = nil

    // MARK: - lifeCycle
    init(frame: CGRect, LyricsData: Any) {
        super.init(frame: frame)
        self.lyricText = String(describing: LyricsData)
        self.layoutViews(frame: frame)
        self.addTapAction()
        self.addNotificationObserver()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: UI
    func layoutViews(frame: CGRect) {

        self.lyricsScorllView.frame = CGRect(x: 0, y:TSMusicLyricsViewUX.lyricVerticalMarginTop, width: frame.width, height: frame.height - (TSMusicLyricsViewUX.lyricVerticalMarginTop + TSMusicLyricsViewUX.lyricVerticalMarginBottom))
        self.lyricsScorllView.showsVerticalScrollIndicator = false
        self .addSubview(self.lyricsScorllView)

        self.layoutScorllViewSubView()
    }

    func layoutScorllViewSubView() {

        self.lyricsTextlabel.backgroundColor = .clear
        self.lyricsTextlabel.numberOfLines = 0
        self.lyricsTextlabel.textAlignment = NSTextAlignment.center
        self.lyricsTextlabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        upDateLyric(lyric: self.lyricText!)
        self.lyricsScorllView .addSubview(self.lyricsTextlabel)
    }

    // MARK: 额外事件添加
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(showSelf), name: NSNotification.Name(rawValue: showTSMusicLyricsView), object: nil)
    }

    func addTapAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
    }

    func upDateLyric(lyric: String) {
        self.lyricText = lyric
        let lyricsString = String.setStyleAttributeString(string: lyric, font: self.lyricsTextlabel.font, lineSpacing: 20, textAlignment: NSTextAlignment.center)
        self.lyricsTextlabel.attributedText = lyricsString
        let textHeight = String.getAttributeStringHeight(attributeString: lyricsString, maxWidth: ScreenSize.ScreenWidth, maxHeight: CGFloat(MAXFLOAT))
        self.lyricsTextlabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: textHeight)
        self.lyricsScorllView.contentSize = CGSize(width: 0, height: textHeight)
    }

    // MARK: - 动作
    func showSelf() {
        self.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1.0
        }) { (_) in
        }
    }

    func tapAction() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.1
        }) { (_) in
            self.isHidden = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ShowTSPhonographRootView), object: nil)
    }
}
