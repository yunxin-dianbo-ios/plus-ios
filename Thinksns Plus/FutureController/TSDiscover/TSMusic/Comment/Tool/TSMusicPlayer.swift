//
//  TSMusicPlayer.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class TSMusicPlayer: NSObject, TSResourceLoaderDelegate {

    /// 播放器状态
    ///
    /// - Waiting: 等待加载中
    /// - Playing: 播放中
    /// - Paused: 暂停中
    /// - Stopped: 停止播放
    /// - Buffering: 缓存中
    /// - Error: 错误
    enum TSMusicStatus {
        case Waiting
        case Playing
        case Paused
        case Stopped
        case Buffering
        case Error
    }

    /// - Public
    /// 状态
    var status: TSMusicStatus? = nil

    /// 进度
    var progress: CGFloat = 0.0
    /// 播放进度
    var duration: CGFloat = 0.0
    /// 缓存进度
    var cacheProgress: CGFloat = 0.0
    /// - Private
    /// 播放链接
    private var url: URL? = nil
    /// 播放器
    var player: AVPlayer? = nil
    /// 当前播放的资源
    var currentItem: AVPlayerItem? = nil
    /// 缓存管理
    private var resourceLoader: TSResourceLoader? = nil
    /// 播放器的监听
    private var timeObersver: Any? = nil

    func reloadCurrentItem() {

        stop()

        if (url?.absoluteString.hasPrefix("https"))! {
            // 暂时屏蔽了从缓存读取音频文件的逻辑,因为无法确定相关的所有逻辑是否正确
            // [坑] 所以暂时都改为了在线获取数据播放
//            let cacheFilePath = TSFileHandle.cacheFileExists(WithURL: url!)
//            if cacheFilePath != "" {
//                /// 有缓存
//                let pathURL = URL(fileURLWithPath: cacheFilePath)
//                self.currentItem = AVPlayerItem(url: pathURL)
//            } else {
                self.resourceLoader = TSResourceLoader()
                self.resourceLoader?.delegate = self

                let asset = AVURLAsset(url: (url!.musicCustomSchemeURL()), options: nil)
                asset.resourceLoader.setDelegate(self.resourceLoader, queue: DispatchQueue.main)
                self.currentItem = AVPlayerItem(asset: asset)
//            }
        } else {
            // 这里上下都强行改成一样的加载机制（原来是只有最后一句）
            self.resourceLoader = TSResourceLoader()
            self.resourceLoader?.delegate = self
            let asset = AVURLAsset(url: (url!.musicCustomSchemeURL()), options: nil)
            asset.resourceLoader.setDelegate(self.resourceLoader, queue: DispatchQueue.main)
            self.currentItem = AVPlayerItem(asset: asset)
            /**
            self.currentItem = AVPlayerItem(url: url!)
            */
        }

        self.player = AVPlayer(playerItem: self.currentItem)
        addObserver()
        status = .Waiting
    }

    func replaceItem(WithUrl url: URL) {
        self.url = url
        reloadCurrentItem()
    }

    func play() {
        if status == .Paused || status == .Waiting {
            if #available(iOS 10.0, *) {
                self.player?.playImmediately(atRate: 1.0)
            } else {
                self.player?.play()
            }
            status = .Playing
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TSMusicPlayBeginName), object: CGFloat(1), userInfo: nil)
        }
    }

    func pause() {
        if status == .Playing {
            self.player?.pause()
            status = .Paused
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TSMusicPlayPausedName), object: nil, userInfo: nil)
        }
    }

    func stop() {
        if status == .Stopped || status == nil {
            return
        }
        self.player?.pause()
        self.resourceLoader?.stopLoading()
        self.removeObervers()
        self.resourceLoader = nil
        self.currentItem = nil
        self.player = nil
        self.progress = 0.0
        self.duration = 0.0
        status = .Stopped
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TSMusicPlayStopName), object:nil, userInfo: nil)
    }

    func seekToTime(secondes: CGFloat) {
        if status == .Playing {
            self.player?.pause()
            self.resourceLoader?.seekRequired = true
            let time = secondes * CGFloat(CMTimeGetSeconds((self.player?.currentItem?.duration)!))
            self.player?.seek(to: CMTime(seconds: Double(time), preferredTimescale: 1), completionHandler: { (_) in
                self.player?.play()
                self.status = .Playing
            })
        }

        if status == .Paused {
            self.resourceLoader?.seekRequired = true
            let time = secondes * CGFloat(CMTimeGetSeconds((self.player?.currentItem?.duration)!))
            self.player?.seek(to: CMTime(seconds: Double(time), preferredTimescale: 1), completionHandler: { (_) in
            })
        }
    }

    // MARK: - KVO

    /// 添加监听
    func addObserver() {
        let songItem = self.currentItem
        /// 播放完成
        NotificationCenter.default.addObserver(self, selector: #selector(playEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        /// 播放进度
        self.timeObersver = self.player?.addPeriodicTimeObserver(forInterval: CMTime(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0)), queue: DispatchQueue.main, using: { (time) in
            let current = CMTimeGetSeconds(time)
            let total = CMTimeGetSeconds((self.player?.currentItem?.duration)!)
            if current > 0 {
                let progress = current / total
                let playProgressDataDic: [String:Any] = ["progress": Float(progress), "current": self.fromateTime(timeSeconds: current), "total": self.fromateTime(timeSeconds: total)]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TSMusicPlayProgressName), object: nil, userInfo: playProgressDataDic)
            }
        })

        self.player?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        songItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        songItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        songItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        songItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
    }

    /// 移除监听
    func removeObervers() {
        let songItem = self.currentItem
        NotificationCenter.default.removeObserver(self)
        if self.timeObersver != nil {
            self.player?.removeTimeObserver(self.timeObersver!)
            self.timeObersver = nil
        }
        songItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        songItem?.removeObserver(self, forKeyPath: "status")
        songItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        songItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        self.player?.removeObserver(self, forKeyPath: "rate")
        self.player?.replaceCurrentItem(with: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else {
            return
        }
        if keyPath == "status" {
            switch playerItem.status {
            case AVPlayerItemStatus.unknown:
                print("未知状态")
                break
            case AVPlayerItemStatus.failed:
                print("加载失败")
                break
            case AVPlayerItemStatus.readyToPlay:
                print("可以播放了")
                if self.status == .Waiting {
                    play()
                }
                break
            }
        } else if keyPath == "loadedTimeRanges" {
            let timeRanges = playerItem.loadedTimeRanges
            let timeRange = timeRanges.first?.timeRangeValue
            let totalLoadTime = CMTimeGetSeconds((timeRange?.start)!) + CMTimeGetSeconds((timeRange?.duration)!)
            let duration = CMTimeGetSeconds((self.player?.currentItem?.duration)!)
            let scale = totalLoadTime / duration
            if scale == 1 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TSMusicCacheProgressName), object: CGFloat(scale), userInfo: nil)
            }
        } else if keyPath == "rate" {
            if self.player?.rate == 0.0 {
                status = .Paused
            } else {
                status = .Playing
            }
        }
    }

    /// 播放完成
    func playEnd() {
        self.stop()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TSMusicAutoNextName), object: nil, userInfo: nil)
    }

    /// 格式化歌曲时间（总时长和已播放时长）
    ///
    /// - Parameter timeSeconds: 获取到的时间
    /// - Returns: 格式化后的时间 <String>
    func fromateTime(timeSeconds: Float64) -> String {

        let Minute = Int((timeSeconds / 60).truncatingRemainder(dividingBy: 60))
        let seconds = Int(timeSeconds.truncatingRemainder(dividingBy: 60))

        var minuteStr: String? = nil
        if Minute < 10 {
            minuteStr = String(format: "0%d", Minute)
        } else {
            minuteStr = String(Minute)
        }

        var secondsStr: String? = nil
        if seconds < 10 {
            secondsStr = String(format: "0%d", seconds)
        } else {
            secondsStr = String(seconds)
        }
        return minuteStr! + ":" + secondsStr!
    }

    // MARK: - TSResourceLoaderDelegate
    func loader(loader: TSResourceLoader, cacheProgress progress: CGFloat) {
        self.cacheProgress = progress
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TSMusicCacheProgressName), object: progress)
    }

    func loader(loader: TSResourceLoader, failLoadingWithError error: Error) {
        /// 失败
    }

    // MARK: - cache
    func currentItemCacheState() -> Bool {
        if (self.url?.absoluteString.hasPrefix("http"))! {
            if self.resourceLoader != nil {
                return (self.resourceLoader?.cacheFinished)!
            }
            return true
        }
        return false
    }

    func currentItemCacheFilePath() -> String? {
        if !currentItemCacheState() {
            return nil
        }
        return String.musicCacheFolderPath() + String.musicfileNameWithURL(url: self.url!)
    }

    class func clearCache() -> Bool {
        return TSFileHandle.clearCache()
    }
}
