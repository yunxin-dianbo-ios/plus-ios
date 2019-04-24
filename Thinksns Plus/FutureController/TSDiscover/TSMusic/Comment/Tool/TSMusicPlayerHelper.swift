//
//  TSMusicPlayerHelper.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import MediaPlayer

/// 缓存进度通知
let TSMusicCacheProgressName = "TSMusicCacheProgressName"
/// 播放进度通知
let TSMusicPlayProgressName = "TSMusicPlayeProgressName"
/// 自动下一曲通知
let TSMusicAutoNextName = "TSMusicAutoNextName"
/// 开始播放通知
let TSMusicPlayBeginName = "TSMusicPlayBeginName"
/// 停止播放通知 （重置UI）
let TSMusicPlayStopName = "TSMusicPlayStopName"
/// 暂停播放
let TSMusicPlayPausedName = "TSMusicPlayPausedName"

class TSMusicPlayerHelper: NSObject {

    /// 歌曲循环模式
    enum  WrapMode {
        case circulation   /// 列表循环
        case single        /// 单曲循环
        case random        /// 随机播放
    }
    /// 歌曲切换方式
    private enum SwitchMode {
        case auto          /// 自动切换
        case next          /// 手动下一曲
        case last          /// 手动上一曲
    }

    /// 单例对象
    static let sharePlayerHelper = TSMusicPlayerHelper()
    /// 播放器
    let player: TSMusicPlayer = TSMusicPlayer()
    // TODO: MusicUpdate - 音乐模块更新中，To be removed
//    /// 歌单
//    var songList: [TSSongObject] = []
//    /// 当前播放的歌曲
//    var currentSong: TSSongObject? = nil
    /// 歌单
    var songList: [TSSongModel] = [TSSongModel]()
    /// 当前播放的歌曲
    var currentSong: TSSongModel? = nil
    let imageCacheView = UIImageView()
    /*-----------记录歌曲信息 用于锁屏显示------------*/
    /// 歌名
    var songName: String? = nil
    /// 歌手
    var singer: String? = nil
    /// 歌手封面图附件id
    var singer_cover: Int? = nil
    /// 锁屏信息
    var lockDic: [String:Any]? = nil
    /*--------------------END---------------------*/

    /// 当前位置
    var currentIndex: Int = 0
    /// 上次播放的歌曲位置
    var lastIndex: Int = -1
    /// 循坏模式
    var mode: WrapMode = .circulation
    /// 重定向的id （歌曲strong_id）
    var redirictionID: Int = 0

    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(setLockView), name: NSNotification.Name(rawValue: TSMusicPlayBeginName), object: nil)
        setAVAudioSession()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 更新歌单/更换播放的歌曲
    ///
    /// - Parameters:
    ///   - list: 歌单
    ///   - index: 要播放的歌曲位置
    ///   - need: 是否需要更换歌单
    func setData(list: [TSSongModel], songIndex index: Int, needReloadSongList need: Bool) {
        if need {
            /// 更换歌单
            self.songList = list
            /// 重置上次播放记录
            self.lastIndex = -1
        }
        self.currentIndex = index
        let object = list[index]
        if currentSong?.storage?.id != object.storage?.id {
            playSong(object)
        } else {
            play()
        }
    }

    // MARK: - 播放器的自主操作

    /// 播放一首歌曲
    ///
    /// - Parameter object: 歌曲object
    private func playSong(_ song: TSSongModel) {
        self.currentSong = song
        self.songName = self.currentSong?.title
        self.singer = self.currentSong?.singer?.name
        self.singer_cover = self.currentSong?.singer?.cover?.id
        getRedirectionURLPath(musicSourceID: (song.storage?.id)!)
    }

    /// 获取下一首要播放的歌曲
    ///
    /// - Parameter switchMode: 操作方式
    /// - Returns: 歌曲信息
    private func getNextSong(switchMode: SwitchMode) -> TSSongModel {
        var index: Int = 0
        switch self.mode {
        case .circulation:
            if switchMode == .last {
                index = self.getLastSongIndex()
            } else {
                index = self.getNextSongIndex()
            }
            break
        case .single:
            if switchMode == .auto {
                index = self.currentIndex
            } else if switchMode == .next {
                index = self.getNextSongIndex()
            } else {
                index = self.getLastSongIndex()
            }
            break
        case .random:
            // Remark: - 随机模式是从未播放列表中随机抽取，而不是从整个播放列表中进行随机抽取，待解决
            // 解决参考方案1：建立一个随机排序后的列表
            if switchMode == .last {
                if self.lastIndex == -1 {
                    index = Int(arc4random_uniform(UInt32(self.songList.count)))
                    while index == self.currentIndex {
                        index = Int(arc4random_uniform(UInt32(self.songList.count)))
                    }
                } else {
                    index = self.lastIndex
                }
            } else {
                index = Int(arc4random_uniform(UInt32(self.songList.count)))
                while index == self.currentIndex {
                    index = Int(arc4random_uniform(UInt32(self.songList.count)))
                }
            }
            break
        }
        /// 记录位置改变之前的位置
        self.lastIndex = currentIndex
        /// 更新当前位置
        self.currentIndex = index

        // 判断当前选中的歌曲是否已付费
        let object = self.songList[index]
        var paidFlag: Bool = true // 默认已支付，无需付费的视为已支付
        if false == object.storage?.paid {
            paidFlag = false
        }
        if paidFlag {
            // 已支付，则返回
            return object
        } else {
            // 递归调用
            return self.getNextSong(switchMode: switchMode)
            // Remark: - 如何避免无穷递归 无数据、全部都需要收费
            // 解决方案：在别处调用getNextSong的处进行判断，处理上述情况
        }
    }

    /// 获取下一首歌的脚标
    /// 如果是最后一首 则返回第一首
    ///
    /// - Returns: Int
    private func getNextSongIndex() -> Int {
        var index: Int = 0
        index = self.currentIndex + 1
        if index == self.songList.count {
            index = 0
        }
        return index
    }

    /// 获取上一首歌的脚标
    /// 如果是第一首则返回最后一首歌
    ///
    /// - Returns: Int
    private func getLastSongIndex() -> Int {
        var index: Int = 0
        index = self.currentIndex - 1
        if index < 0 {
            index = self.songList.count - 1
        }
        return index
    }

    /// 设置音乐后台播放
    private func setAVAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        } catch {
            print(error)
            return
        }
    }

    /// 设置锁屏
    func setLockView() {

        imageCacheView.kf.setImage(with: TSURLPath.imageURLPath(storageIdentity: self.singer_cover, compressionRatio: 50), placeholder: nil, options: nil, progressBlock: nil) { (image, _, _, _) in
            var setImage = UIImage(named: "IMG_music_pic_phonograph_01")
            if let image = image {
                setImage = image
            }

            var itemArtWork: MPMediaItemArtwork? = nil
            if #available(iOS 10.0, *) {
                itemArtWork = MPMediaItemArtwork(boundsSize: CGSize(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9), requestHandler: { (_) -> UIImage in
                    setImage!
                })
            } else {
                itemArtWork = MPMediaItemArtwork(image: setImage!)
            }

            let dic: [String: Any] = [
                // 歌曲名称
                MPMediaItemPropertyTitle: self.songName ?? "未知",
                // 演唱者
                MPMediaItemPropertyArtist: self.singer ?? "未知",
                // 锁屏图片
                MPMediaItemPropertyArtwork: itemArtWork!,
                //
                MPNowPlayingInfoPropertyPlaybackRate: 1.0,
                // 总时长
                MPMediaItemPropertyPlaybackDuration: CMTimeGetSeconds((self.player.currentItem?.duration)!),
                // 当前时间
                MPNowPlayingInfoPropertyElapsedPlaybackTime: CMTimeGetSeconds((self.player.currentItem?.currentTime())!)
            ]

            MPNowPlayingInfoCenter.default().nowPlayingInfo = dic
            self.lockDic = dic
        }
    }

    // MARK: - 外部调用接口
    func clearMuiscData() {
        pause()
        self.songList = []
        self.currentSong = nil
        self.currentIndex = 0
        self.lastIndex = -1
        self.mode = .circulation
    }
    /// 下一曲
    func next() {
        if !self.couldGetNextSong() {
            return
        }
        let object = getNextSong(switchMode: .next)
        playSong(object)
    }

    /// 上一曲
    func last() {
        if !self.couldGetNextSong() {
            return
        }
        let object = getNextSong(switchMode: .last)
        playSong(object)
    }

    /// 自动跳转
    func auto() {
        if !self.couldGetNextSong() {
            return
        }
        let object = getNextSong(switchMode: .auto)
        playSong(object)
    }

    /// getNextSong调用前的判断
    /// Remark：每次调用getNextSong都应调用该方法，而不是标记保存，因为歌曲可能因购买而改变支付信息
    fileprivate func couldGetNextSong() -> Bool {
        var couldFlag: Bool = false
        // 判断是否都是未支付的
        for song in self.songList {
            // 已支付 或 无需支付
            if false != song.storage?.paid {
                couldFlag = true
                break
            }
        }
        return couldFlag
    }

    /// 播放指定列表的某首歌
    func playSongObject(index: Int) {
        if self.currentIndex == index {
            return
        }
        self.currentIndex = index
        let object = self.songList[index]
        playSong(object)
    }
    /// 播放
    func play() {
        self.player.play()
    }

    /// 暂停
    func pause() {
        self.player.pause()
    }

    /// 拖动进度条
    ///
    /// - Parameter seconds: 进度位置
    func seekToTime(seconds: CGFloat) {
        if self.player.status == .Waiting || self.player.status == .Error {
            return
        }
        self.player.seekToTime(secondes: seconds)
    }

    /// 获取拖动进度条时的实时时间
    ///
    /// - Parameter value: slider的值
    /// - Returns: 格式化后的时间
    func getSeekingTimeStr(value: CGFloat) -> String {
        if self.player.status == .Waiting || self.player.status == .Error || self.player.status == nil {
            return "00:00"
        }
        guard let duration = self.player.player?.currentItem?.duration else {
            return "00:00"
        }
        let seconds = CMTimeGetSeconds(duration)
        if seconds.isNaN {
            return "00:00"
        }
        // 解决注释代码中的NaN崩溃
        //let time = value * CGFloat(CMTimeGetSeconds((self.player.player?.currentItem?.duration)!))
        let time = value * CGFloat(seconds)
        return self.player.fromateTime(timeSeconds: Double(time))
    }

    /// 设置循环模式
    func setWrapMode() {
        switch mode {
        case .circulation:
            mode = .random
            print("@@@@@@@@@@ 随机")
            break
        case .random:
            mode = .single
            print("@@@@@@@@@@ 单曲")
            break
        case .single:
            mode = .circulation
            print("@@@@@@@@@@ 循环")
            break
        }
        // [长期注释] 保存播放模式
    }
}
