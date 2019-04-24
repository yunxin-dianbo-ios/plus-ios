//
//  TSSongListCell.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

struct TSSongListCellUX {
    /// 歌手名的字体
    static let SingerTextFont = UIFont.systemFont(ofSize: TSFont.SubUserName.singer.rawValue)
    /// 歌名的字体
    static let SongNameTextFont = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
    /// 歌手名的字体颜色
    static let SingerTextColor = TSColor.normal.secondary
    /// cell的高度
    static let cellHeight: CGFloat = 40
}

class TSSongListCell: UITableViewCell {

//    var object: TSSongObject? = nil
    var song: TSSongModel?

    /// 歌曲描述
    @IBOutlet weak var SongInfoLabel: UILabel!
    /// 付费标记
    @IBOutlet weak var payIcon: UIImageView!
    /// 歌曲信息Label左侧距离ContentView的约束 隐藏与显示payIcon时需对songInfoLabel进行显示修正，即修正这里的约束
    @IBOutlet weak var songLabelLeftConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.SongInfoLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.SongInfoLabel.textColor = TSColor.normal.content
        self.selectionStyle = .none
    }

    // TODO: MusicUpdate - 音乐模块更新中，To be removed
//    func updateCellData(songObject object: TSSongObject, isPlaying: Bool) {
//        self.object = object
//        let songName = object.title as NSString
//        let singer = (object.singer?.name ?? "") as NSString
//        var songNameColor = TSColor.normal.content
//        var singerColor = TSColor.normal.secondary
//        if isPlaying {
//            songNameColor = TSColor.main.theme
//            singerColor = TSColor.main.theme
//        }
//        self.SongInfoLabel.attributedText = NSMutableAttributedString().differentColorAndSizeString(first: (songName, songNameColor, TSFont.ContentText.text.rawValue), second: (singer, singerColor, TSFont.SubUserName.singer.rawValue))
//    }
    func updateCellData(song: TSSongModel, isPlaying: Bool) {
        self.song = song
        let songName = song.title as NSString
        var singer: NSString = ""
        if let singerName = song.singer?.name {
            singer = ("-" + singerName) as NSString
        }
        var songNameColor = TSColor.normal.content
        var singerColor = TSColor.normal.secondary
        if isPlaying {
            songNameColor = TSColor.main.theme
            singerColor = TSColor.main.theme
        }
        self.SongInfoLabel.attributedText = NSMutableAttributedString().differentColorAndSizeString(first: (songName, songNameColor, TSFont.ContentText.text.rawValue), second: (singer, singerColor, TSFont.SubUserName.singer.rawValue))
        // 付费标记
        let hiddenPayIconFlag: Bool = (nil == song.storage?.paid) ? true : false
        self.payIcon.isHidden = hiddenPayIconFlag
        self.songLabelLeftConstraint.constant = hiddenPayIconFlag ? 15 : 50
    }
}
