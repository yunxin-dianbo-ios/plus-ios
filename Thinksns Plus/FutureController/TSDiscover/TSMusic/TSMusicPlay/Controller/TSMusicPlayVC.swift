//
//  TSMusicPlayVC.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/2/15.
//  Copyright © 2017年 LeonFa. All rights reserved.
//  音乐播放界面

import UIKit
import AVFoundation
import MediaPlayer

class TSMusicPlayVC: UIViewController, UIScrollViewDelegate, TSPhonographRootViewDelegate {
    /// 底部背景图片
    @IBOutlet weak var BGImageView: UIImageView!
    /// ---------
    /// 播放、下一曲等按钮以及进度条的父视图
    @IBOutlet weak var PalyView: UIView!
    /// 缓存进度
    @IBOutlet weak var progressView: UIProgressView!
    /// 播放进度
    @IBOutlet weak var musicSliderView: UISlider!
    /// 已播放时间
    @IBOutlet weak var progressTime: UILabel!
    /// 歌曲总时长
    @IBOutlet weak var durationTime: UILabel!
    /// 暂停/播放按钮
    @IBOutlet weak var playButton: UIButton!
    /// 下一曲
    @IBOutlet weak var nextButton: UIButton!
    /// 上一曲
    @IBOutlet weak var lastButton: UIButton!
    /// 循坏模式
    @IBOutlet weak var roundTypeButton: UIButton!

    /// 唱片展示视图
    var phonogarphRootView: TSPhonographRootView? = nil
    /// 歌词视图
    var lyricView: TSMusicLyricsView? = nil
    /// 导航栏标题视图
    var titleView: TSMusicNavigationTitleView? = nil
    /// 歌曲列表弹出视图
    let songListView = TSPlaySongListView.shareInstance
    /// 当前播放的专辑
    var albumID: Int = -1
    /// 歌曲列表
    // TODO: MusicUpdate - 音乐模块更新中，To be removed
//    var songList: [TSSongObject] = []
    var songList: [TSSongModel] = [TSSongModel]()
    /// 是否在拖动中
    var isSeeking: Bool = false
    /// 单例对象
    static let shareMusicPlayVC = TSMusicPlayVC(nibName: "TSMusicPlayVC", bundle: nil)

    /// 当前播放的歌曲
    // TODO: MusicUpdate - 音乐模块更新中，To be removed
//    var currentSong: TSSongObject? = nil
    var currentSong: TSSongModel? = nil
    /// 当前播放的歌曲位置
    var currentSongIndex: Int = 0
    /// 是否需要更新歌单 （从另一个专辑进入播放界面）
    var needUploadSongList: Bool = false

    // MARK: - lifeCycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        TSMusicPlayStatusView.shareView.dismiss()
        if self.phonogarphRootView != nil {
            phonogarphRootView?.reSetSongInfo()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TSMusicPlayStatusView.shareView.showView()
        TSMusicPlayStatusView.shareView.setAnimation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarTitleLable()
        self.setSliderStyle()
        self.addMusicObservers()
        self.setPhonographViewData()
        self.createlyricView()
        self.songListView.delegate = self   // 列表界面的代理
    }

    deinit {
        removeMusicObservers()
        UIApplication.shared.endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }

    // MARK: - UI

    func setPhonographViewData() {
        let navgationBarAndStatusBarHeight = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height
        let screenHeightWithoutNavigationBar = ScreenSize.ScreenHeight - navgationBarAndStatusBarHeight
        self.phonogarphRootView = TSPhonographRootView(frame: CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: screenHeightWithoutNavigationBar * (1 - (1 / 4))))
        self.phonogarphRootView?.delegate = self
        self.view.addSubview(self.phonogarphRootView!)

        self.phonogarphRootView?.setData(SongList: self.songList, SongIndex: self.currentSongIndex, isNeedReloadAll: needUploadSongList)

        self.updateBGImage(imageUrl: TSURLPath.imageURLPath(storageIdentity: self.currentSong?.singer?.cover?.id, compressionRatio: 30)!)
    }

    func setSliderStyle() {
        self.progressTime.textColor = TSColor.normal.content
        self.durationTime.textColor = TSColor.normal.content
        self.musicSliderView.setThumbImage(UIImage(named: "IMG_music_pic_progressbar_circle"), for: UIControlState.normal)
    }

    func createlyricView() {
        let navgationBarAndStatusBarHeight = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height
        let screenHeightWithoutNavigationBar = ScreenSize.ScreenHeight - navgationBarAndStatusBarHeight
        self.lyricView = TSMusicLyricsView(frame: CGRect(x: 20, y: 0, width: ScreenSize.ScreenWidth - 40, height: screenHeightWithoutNavigationBar * (1 - (1 / 4))), LyricsData: "暂无歌词")
        self.lyricView?.isHidden = true
        self.view .addSubview(self.lyricView!)
        // 没有歌词或歌词内容为空时，都使用默认设置——暂无歌词
        guard let lyric = self.currentSong?.lyric else {
            return
        }
        if !lyric.isEmpty {
            self.lyricView?.upDateLyric(lyric: lyric)
        }
    }

    func setNavigationBarTitleLable() {
        if self.titleView == nil {
            self.titleView = TSMusicNavigationTitleView(frame: CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth - 120, height: 35), type: .Song)
            self.navigationItem.titleView = self.titleView
        }
        self.titleView?.setText(marqueeText: (self.currentSong?.title)!, subTitle: self.currentSong?.singer?.name)
    }

    // MARK: - Public Method
    func setData(AlbumID id: Int, songIndex index: Int, SongList list: [TSSongModel]) {
        let songObject = list[index]

        self.playButton?.isSelected = true

        self.currentSong = songObject
        self.currentSongIndex = index
        self.needUploadSongList = (self.albumID != id)
        if needUploadSongList {
            self.songList = list
            self.albumID = id
        }

        if self.phonogarphRootView != nil {
            self.phonogarphRootView?.setData(SongList: self.songList, SongIndex: self.currentSongIndex, isNeedReloadAll: needUploadSongList)
        }

        if self.BGImageView != nil {
            self.updateBGImage(imageUrl: TSURLPath.imageURLPath(storageIdentity: self.currentSong?.singer?.cover?.id, compressionRatio: 30)!)
        }

        if self.lyricView != nil {
            self.lyricView?.upDateLyric(lyric: (self.currentSong?.lyric)!)
        }

        if self.titleView != nil {
            self.titleView?.setText(marqueeText: (self.currentSong?.title)!, subTitle: self.currentSong?.singer?.name)
        }

        TSMusicPlayerHelper.sharePlayerHelper.setData(list: list, songIndex: index, needReloadSongList: needUploadSongList)
    }

    // MARK: - private Method

    /// 更新UI

    /// 切换歌曲后更新VC保存的当前歌曲信息
    ///
    /// - Parameter isNext: 是否是下一曲的操作
    private func uploadCurrent() {
        self.currentSongIndex = TSMusicPlayerHelper.sharePlayerHelper.currentIndex
        self.playButton.isSelected = true
        self.currentSong = self.songList[self.currentSongIndex]
        updateUI()
    }

    func updateUI() {
        self.updateBGImage(imageUrl: TSURLPath.imageURLPath(storageIdentity: self.currentSong?.singer?.cover?.id, compressionRatio: 30)!)
        // 歌词展示
        var showLyric = "暂无歌词"
        if let lyric = self.currentSong?.lyric {
            if !lyric.isEmpty {
                showLyric = lyric
            }
        }
        self.lyricView?.upDateLyric(lyric: showLyric)
        self.titleView?.setText(marqueeText: (self.currentSong?.title)!, subTitle: self.currentSong?.singer?.name)
    }

    /// 更新背景图
    private func updateBGImage(imageUrl: URL) {

        UIView.animate(withDuration: 0.3, animations: {
            self.BGImageView.alpha = 0.1
        }) { (_) in
            self.BGImageView.kf.setImage(with: imageUrl, placeholder: nil, options: nil, progressBlock: nil) { (image, _, _, _) in
                if image != nil {
                    self.BGImageView.image = UIImage.getGrayImage(image: image!)
                    UIView.animate(withDuration: 0.2) {
                        self.BGImageView.alpha = 1.0
                    }
                }
            }
        }
    }

    // MARK: - 播放器的操作
    // MARK: 播放/暂停
    @IBAction func playOrStop(_ sender: Any) {
        self.playButton.isSelected ? TSMusicPlayerHelper.sharePlayerHelper.pause() : TSMusicPlayerHelper.sharePlayerHelper.play()
        self.playButton.isSelected ? phonogarphRootView?.pasueAnimation() : phonogarphRootView?.reStarAnimation()
        setLockViewWhenPaused(paused: self.playButton.isSelected)
        self.playButton.isSelected = !self.playButton.isSelected
    }

    // MARK: 下一首
    @IBAction func nextSong(_ sender: UIButton) {
        TSMusicPlayerHelper.sharePlayerHelper.next()
        self.phonogarphRootView?.songChanged(scale: 2)
        uploadCurrent()
    }

    // MARK: 上一首
    @IBAction func lastSong(_ sender: UIButton) {
        TSMusicPlayerHelper.sharePlayerHelper.last()
        self.phonogarphRootView?.songChanged(scale: 0)
        uploadCurrent()
    }

    func autoPlay() {
        TSMusicPlayerHelper.sharePlayerHelper.auto()
        self.phonogarphRootView?.autoPalyChange()
        uploadCurrent()
    }

    func playsong(index: Int) {
        TSMusicPlayerHelper.sharePlayerHelper.playSongObject(index: index)
        self.phonogarphRootView?.autoPalyChange()
        self.currentSongIndex = index
        self.playButton.isSelected = true
        self.currentSong = self.songList[self.currentSongIndex]
        updateUI()
    }

    // MARK: 显示歌曲列表
    @IBAction func showSongList(_ sender: UIButton) {
        self.songListView.showList()
    }

    // MARK: 设置播放模式
    @IBAction func changWropMode(_ sender: UIButton) {
        switch TSMusicPlayerHelper.sharePlayerHelper.mode {
        case .circulation:
            sender.setImage(UIImage(named: "IMG_music_ico_random"), for: UIControlState.normal)
            break
        case .random:
            sender.setImage(UIImage(named: "IMG_music_ico_single"), for: UIControlState.normal)
            break
        case .single:
            sender.setImage(UIImage(named: "IMG_music_ico_inorder"), for: UIControlState.normal)
            break
        }
        TSMusicPlayerHelper.sharePlayerHelper.setWrapMode()
    }

    // MARK: 开始拖动进度条
    @IBAction func didSliderValueChanged(_ sender: Any) {
        self.isSeeking = true
        let slider = sender as! UISlider
        self.progressTime.text = TSMusicPlayerHelper.sharePlayerHelper.getSeekingTimeStr(value: CGFloat(slider.value))
    }

    // MARK: 拖动进度条
    @IBAction func seekSlider(_ sender: UISlider) {
        TSMusicPlayerHelper.sharePlayerHelper.seekToTime(seconds: CGFloat(sender.value))
        self.isSeeking = false
    }

    // MARK: - 通知
    func addMusicObservers() {
        /// 缓存进度
        NotificationCenter.default.addObserver(self, selector: #selector(cacheProgress(noti:)), name: NSNotification.Name(rawValue: TSMusicCacheProgressName), object: nil)
        /// 播放进度
        NotificationCenter.default.addObserver(self, selector: #selector(playProgress(noti:)), name: NSNotification.Name(rawValue: TSMusicPlayProgressName), object: nil)
        /// 停止播放 （重置进度条、播放进度等）
        NotificationCenter.default.addObserver(self, selector: #selector(reSetProgress), name: NSNotification.Name(rawValue: TSMusicPlayStopName), object: nil)
        /// 自动播放下一曲
        NotificationCenter.default.addObserver(self, selector: #selector(autoPlay), name: NSNotification.Name(rawValue: TSMusicAutoNextName), object: nil)
    }

    func removeMusicObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: 通知触发事件
    /// 开始播放音乐
    func musicPlayBegin() {
        self.playButton.isSelected = true
    }

    func cacheProgress(noti: Notification) {
        let progressValue: CGFloat = noti.object as! CGFloat
        self.progressView.setProgress(Float(progressValue), animated: false)
    }

    func playProgress(noti: Notification) {
        if self.isSeeking == true {
            return
        }
        let datadDic = noti.userInfo as! [String:Any]
        self.musicSliderView.setValue(datadDic["progress"] as! Float, animated: false)
        self.durationTime.text = datadDic["total"] as! String?
        self.progressTime.text = datadDic["current"] as! String?
    }

    func reSetProgress() {
        self.musicSliderView.setValue(0.0, animated: false)
        self.durationTime.text = "00:00"
        self.progressTime.text = "00:00"
    }

    /// 远程控制（音乐锁屏）
    ///
    /// - Parameter event: 动作
    override func remoteControlReceived(with event: UIEvent?) {
        if event?.type != UIEventType.remoteControl {
            return
        }
        switch event!.subtype {
        case UIEventSubtype.remoteControlPlay:
            TSMusicPlayerHelper.sharePlayerHelper.play()
            phonogarphRootView?.reStarAnimation()
            self.playButton.isSelected = true
            setLockViewWhenPaused(paused: false)
            break
        case UIEventSubtype.remoteControlPause:
            TSMusicPlayerHelper.sharePlayerHelper.pause()
            phonogarphRootView?.pasueAnimation()
            self.playButton.isSelected = false
            setLockViewWhenPaused(paused: true)
            break
        case UIEventSubtype.remoteControlNextTrack:
            TSMusicPlayerHelper.sharePlayerHelper.next()
            self.phonogarphRootView?.songChanged(scale: 2)
            uploadCurrent()
            break
        case UIEventSubtype.remoteControlPreviousTrack:
            TSMusicPlayerHelper.sharePlayerHelper.last()
            self.phonogarphRootView?.songChanged(scale: 0)
            uploadCurrent()
            break
        default:
            break
        }
    }

    /// 暂停或再次播放时 更新锁屏信息
    func setLockViewWhenPaused(paused: Bool) {
        if let lockDic = TSMusicPlayerHelper.sharePlayerHelper.lockDic {
            var lockDicFix = lockDic
            let rate = paused ? 0.0 : 1.0
            lockDicFix[MPNowPlayingInfoPropertyPlaybackRate]  = rate
            lockDicFix[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds((TSMusicPlayerHelper.sharePlayerHelper.player.currentItem?.currentTime())!)
            TSMusicPlayerHelper.sharePlayerHelper.lockDic = lockDicFix
            MPNowPlayingInfoCenter.default().nowPlayingInfo = lockDicFix
        }
    }

    // MARK: - TSPhonographRootViewDelegate
    func didChangedSong(isNext next: Bool) {
        next ? TSMusicPlayerHelper.sharePlayerHelper.next() : TSMusicPlayerHelper.sharePlayerHelper.last()
        uploadCurrent()
    }

    func clickedComment(songID id: Int) {
        guard let songModel = self.currentSong else {
            return
        }
        let songCommentVC = TSMusicCommentVC(musicType: .song, sourceId: id, introModel: TSMusicCommentIntroModel(song: songModel))
        self.navigationController?.pushViewController(songCommentVC, animated: true)
    }
    // 点赞按钮点击回调
    func didClickDiggBtn(song: TSSongModel) {
        let songId: Int = song.id
        let currentDiggState: Bool = song.isLiked
        // 发起点赞相关网络请求
        TSMusicNetworkManager().songDigg(songId: songId, currentDigg: currentDiggState) { (_, status) in
            if status {
                song.isLiked = !song.isLiked
                self.phonogarphRootView?.reSetSongInfo()
                TSDatabaseManager().music.updateSong(song)
            } else {
                // 点赞相关操作失败，提示并修正
                TSLogCenter.log.debug("点赞相关操作失败")
            }
        }
    }
    // MARK: - other
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/// 支付列表的代理
extension TSMusicPlayVC: TSPlaySongListViewProtocol {
    // 支付失败的回调，进入钱包界面
    func didPaySongFail() {
        // 进入钱包页
        let walletVC = WalletHomeController.vc()
        self.navigationController?.pushViewController(walletVC, animated: true)
    }
}
//class TSMusicPlayVC: UIViewController, UIScrollViewDelegate, TSPhonographRootViewDelegate {
