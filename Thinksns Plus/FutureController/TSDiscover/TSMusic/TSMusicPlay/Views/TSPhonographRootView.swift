//
//  TSPhonographRootView.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/2/18.
//  Copyright © 2017年 LeonFa. All rights reserved.
//  黑蝶唱片主视图

import UIKit

private struct TSPhonograpRootViewUX {
    /// 主视图宽度
    static let rootViewWidth = ScreenSize.ScreenWidth
    /// 操作按钮的高度
    static let buttonHeight: CGFloat = 44
    /// 操作按钮宽度
    static let buttonWidth: CGFloat = 44
    /// 最边上的按钮距屏幕的距离
    static let buttonSpacingMargin: CGFloat = 55
    /// 按钮之间的间距
    static let buttonSpacing: CGFloat = (TSPhonograpRootViewUX.rootViewWidth - (TSPhonograpRootViewUX.buttonSpacingMargin * 2) - (TSPhonograpRootViewUX.buttonWidth * 4)) / 3
}
/// 显示歌词视图的通知
public let showTSMusicLyricsView = "ThinksnsPlus.TSMusicPlayVC.ShowTSMusicLyricsView"

protocol TSPhonographRootViewDelegate: class {
    /// 滑动唱片 切换了歌曲
    func didChangedSong(isNext next: Bool)
    /// 点击了评论按钮
    func clickedComment(songID id: Int)
    /// 点击了点赞按钮
    // 使用song而不是sondId，是为了避免尾部更换歌曲时点赞时的songId和点赞请求结果时的song不一致
    func didClickDiggBtn(song: TSSongModel) -> Void
}

class TSPhonographRootView: UIView, UIScrollViewDelegate {
    /// 代理
    weak var delegate: TSPhonographRootViewDelegate? = nil
    /// 是否需要执行代理方法 （点击播放界面上的切换按钮而引起的切换不需要执行）
    private var isNeedDelegateMethod: Bool = false
    /// 底部滑动视图
    private let rootScorllView = UIScrollView()
    /// 有碟片转动的视图
    private lazy var leftPhonographView: TSPhonographView? = nil
    private lazy var centerPhonographView: TSPhonographView? = nil
    private lazy var rightPhonographView: TSPhonographView? = nil

    /// 唱针
    private lazy var needleView: UIImageView? = nil

    /// 按钮
    private lazy var shareButton: UIButton? = nil
    private lazy var starButton: UIButton? = nil
    private lazy var commentButton: UIButton? = nil
    private lazy var listButton: UIButton? = nil

    /// 评论数
    private lazy var commentCount: UILabel? = nil

    /* ----------- 循环滑动相关 -------------*/
    /// scorllview的当前页
    private var currentPage: Int = 0
    // TODO: MusicUpdate - 音乐模块更新中，To be removed
//    // 歌曲数据数组
//    private var songsDataArray: [TSSongObject]? = nil
//    /// 当前播放的歌曲
//    private var currentSong: TSSongObject? = nil
    // 歌曲数据数组
    private var songsDataArray: [TSSongModel]? = nil
    /// 当前播放的歌曲
    private var currentSong: TSSongModel? = nil
    /* ----------- 唱针动画相关 -------------*/
    /// 唱针的初始位置
    private var needDefaultTransfrom: CGAffineTransform? = nil

    private let imageView: UIImageView = UIImageView()
    // MARK: - lifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Internal Function

    // MARK: - UI
    func setUI(frame: CGRect) {
        self.frame = frame
        self.backgroundColor = .clear
        self.layoutRootScorllViewSubviews()
        self.layoutNeedleView()
        self.layoutButtons()
        self.addNotificationObserver()
        self.addTapAction()
    }

    // MARK: scorlliew
    func layoutRootScorllViewSubviews() {

        self.rootScorllView.frame = CGRect(x: 0, y: 0, width: TSPhonograpRootViewUX.rootViewWidth, height: frame.height - TSPhonograpRootViewUX.buttonHeight)
        self.rootScorllView.delegate = self
        self.rootScorllView.isPagingEnabled = true
        self.rootScorllView.showsHorizontalScrollIndicator = false
        self.addSubview(self.rootScorllView)

        self.rootScorllView.contentSize = CGSize(width: TSPhonograpRootViewUX.rootViewWidth * 3, height: 0)
        self.rootScorllView.setContentOffset(CGPoint(x: TSPhonograpRootViewUX.rootViewWidth, y: 0), animated: false)

        self.leftPhonographView = TSPhonographView(scorllViewHeight: self.rootScorllView.frame.height, viewDirection: TSPhonographView.phonographViewDirection.left)
        self.centerPhonographView = TSPhonographView(scorllViewHeight: self.rootScorllView.frame.height, viewDirection: TSPhonographView.phonographViewDirection.center)
        self.rightPhonographView = TSPhonographView(scorllViewHeight: self.rootScorllView.frame.height, viewDirection: TSPhonographView.phonographViewDirection.right)

        self.rootScorllView .addSubview(self.leftPhonographView!)
        self.rootScorllView .addSubview(self.centerPhonographView!)
        self.rootScorllView .addSubview(self.rightPhonographView!)
    }

    /// 设置唱片数据
    ///
    /// - Parameters:
    ///   - list: 歌单
    ///   - insdex: 播放的歌曲位置
    ///   - need: 是否需要更新歌单
    func setData(SongList list: [TSSongModel], SongIndex index: Int, isNeedReloadAll need: Bool) {

        let object = list[index]
        if need {
            self.songsDataArray = list
        }

        if self.currentSong?.storage?.id == object.storage?.id {
            if TSMusicPlayerHelper.sharePlayerHelper.player.status == .Paused {
                self.centerPhonographView?.resumeAnimation()
                self.rotateToPhonograph()
            }
            return
        }

        self.currentPage = index
        self.currentSong = object
        reSetCenterView()
        self.rotateToPhonograph()
    }

    // MARK: buttons
    func layoutButtons() {
        for index in 0...3 {
            self .addSubview(self.makeButtons(index: index))
        }
    }

    func makeButtons(index: Int) -> TSImageButton {
        /* 
         * 注意：TSImageButton 内部自定了此类Button的size【44 * 44】
         *      但是 Origin需要自行定义 【默认（0，0）】
         */
        let button = TSImageButton(frame: CGRect.zero)
        button.frame.origin = CGPoint(x: TSPhonograpRootViewUX.buttonSpacingMargin + (CGFloat(index) * (TSPhonograpRootViewUX.buttonWidth + TSPhonograpRootViewUX.buttonSpacing)), y: self.rootScorllView.frame.maxY)
        button.tag = index
        button .addTarget(self, action: #selector(buttonAction(sender:)), for: UIControlEvents.touchUpInside)
        switch index {
        case 0:
            button.setImage(UIImage(named: "IMG_music_ico_share_black"), for: UIControlState.normal)
            self.shareButton = button
        case 1:
            button.setImage(UIImage(named: "IMG_music_ico_like_normal"), for: UIControlState.normal)
            button.setImage(UIImage(named: "IMG_music_ico_like_high"), for: UIControlState.selected)
            self.starButton = button
        case 2:
            self.commentButton = button
            self.commentButton?.setImage(UIImage(named: "IMG_music_ico_comment_complete"), for: UIControlState.normal)
            self.addCommentCountLabel()
        case 3:
            button.setImage(UIImage(named: "IMG_music_ico_lyrics"), for: UIControlState.normal)
            self.listButton = button
        default:
            break
        }
        return button
    }

    func addCommentCountLabel() {
        self.commentCount = UILabel(frame: CGRect(x: TSPhonograpRootViewUX.buttonWidth - 16, y: TSPhonograpRootViewUX.buttonHeight - 39, width: 50, height: 12))
        self.commentCount?.font = UIFont.systemFont(ofSize: TSFont.SubInfo.statisticsNumberOfWords.rawValue)
        self.commentCount?.textAlignment = NSTextAlignment.left
        self.commentCount?.textColor = TSColor.normal.blackTitle
        self.commentButton?.addSubview(self.commentCount!)
        self.commentButton?.clipsToBounds = false
    }

    // MARK: needle
    func layoutNeedleView() {
        self.needleView = UIImageView(frame: CGRect(x: TSPhonograpRootViewUX.rootViewWidth - 175 - 20, y: self.rootScorllView.frame.height * 0.8, width: 175, height: 37))
        self.needleView!.image = UIImage(named: "IMG_music_pic_phonograph_02")
        self.needDefaultTransfrom = self.needleView!.transform
        self.setAnchorPoint(anchorPoint: CGPoint(x: 0.875, y: 0.5), forView: self.needleView!)
        self .addSubview(self.needleView!)
    }

    // MARK: - delegate
    // MARK: scorllViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset: CGPoint = scrollView.contentOffset
        var isNext = false
        if offset.x > TSPhonograpRootViewUX.rootViewWidth {
            /// 向右边滑 过去 了
            isNext = false
            self.currentPage = (self.currentPage + 1) % (self.songsDataArray?.count)!
            self.currentSong = self.songsDataArray?[self.currentPage]
        } else if offset.x < TSPhonograpRootViewUX.rootViewWidth {
            /// 向左边滑 过去 了
            isNext = true
            self.currentPage = (self.currentPage + self.songsDataArray!.count - 1) % (self.songsDataArray?.count)!
            self.currentSong = self.songsDataArray?[self.currentPage]
        } else {
            /// 只是移动了下 没有切换下一首或上一首
            /// 暂停状态下 不恢复动画
            if TSMusicPlayerHelper.sharePlayerHelper.player.status != .Paused {
                self.centerPhonographView?.resumeAnimation()
                self.rotateToPhonograph()
            }
            return
        }
        reSetCenterView()

        /// 执行代理
        if self.delegate != nil && self.isNeedDelegateMethod {
            self.delegate?.didChangedSong(isNext: isNext)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isNeedDelegateMethod = true
        self.centerPhonographView?.pauseAnimation()
        self.rotateAwayFromPhonograph()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }

    // MARK: - animations
    /// 唱针移动到唱片上
    func rotateToPhonograph() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.needleView!.transform = CGAffineTransform(rotationAngle: CGFloat(.pi / 6.5))
        })
    }

    /// 唱针复位
    func rotateAwayFromPhonograph() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.needleView!.transform = self.needDefaultTransfrom!
        })
    }

    /// 根据设置的anchorPoint 计算出 postion
    ///
    /// - Parameters:
    ///   - anchorPoint: 锚点坐标
    ///   - view: 对象视图
    func setAnchorPoint(anchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)

        newPoint = __CGPointApplyAffineTransform(newPoint, view.transform)
        oldPoint = __CGPointApplyAffineTransform(oldPoint, view.transform)

        var postion = view.layer.position
        postion.x -= oldPoint.x
        postion.x += newPoint.x

        postion.y -= oldPoint.y
        postion.y += newPoint.y

        view.layer.position = postion
        view.layer.anchorPoint = anchorPoint
    }

    // MARK: - 额外事件添加
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(showSelf), name: NSNotification.Name(rawValue: ShowTSPhonographRootView), object: nil)
    }

    func addTapAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
    }

    // MARK: - actions
    func buttonAction(sender: UIButton) {
        guard let object = self.currentSong else {
            return
        }
        switch sender.tag {
        case 0:
            /// 分享
            let shareTitle = self.currentSong?.title != "" ? self.currentSong?.title : TSAppSettingInfoModel().appDisplayName + " " + "音乐"
            var defaultContent = "默认分享内容".localized
            defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
            let shareContent = self.currentSong?.singer?.name != "" ? self.currentSong?.singer?.name : defaultContent

            let shareView = ShareView()
            imageView.kf.setImage(with: TSURLPath.imageURLPath(storageIdentity: self.currentSong?.singer?.cover?.id, compressionRatio: 50), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, _, _, _) in
                 shareView.show(URLString: TSAppConfig.share.rootServerAddress + TSURLPath.application.developPage.rawValue, image: image, description: shareContent, title: shareTitle)
            })
            break
        case 1:
            /// 点赞
//            self.starButton?.setImage(UIImage(named: self.currentSong!.isLiked ? "IMG_music_ico_like_high" : "IMG_music_ico_like_normal"), for: UIControlState.normal)
            /// 代理回调
            self.delegate?.didClickDiggBtn(song: object)
            break
        case 2:
            /// 评论
            self.delegate?.clickedComment(songID: object.id)
            break
        case 3:
            /// 显示歌词
            tapAction()
            break
        default:
            break
        }
    }

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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: showTSMusicLyricsView), object: nil)
    }

    func songChanged(scale: Int) {
        self.isNeedDelegateMethod = false
        self.centerPhonographView?.pauseAnimation()
        self.rotateAwayFromPhonograph()
        self.rootScorllView.setContentOffset(CGPoint(x: TSPhonograpRootViewUX.rootViewWidth * CGFloat(scale), y: 0), animated: true)

        self.currentPage = TSMusicPlayerHelper.sharePlayerHelper.currentIndex
        self.currentSong = TSMusicPlayerHelper.sharePlayerHelper.currentSong
        reSetCenterView()
        self.reSetSongInfo()
    }

    func reSetCenterView() {
        if self.currentSong?.isLiked == true {
            self.starButton?.setImage(UIImage(named: "IMG_music_ico_like_high"), for: .normal)
        } else {
            self.starButton?.setImage(UIImage(named: "IMG_music_ico_like_normal"), for: .normal)
        }

        let number = self.currentSong!.commentCount
        if number != 0 {
            self.commentButton?.setImage(UIImage(named: "IMG_music_ico_comment_incomplete"), for: UIControlState.normal)
            self.commentCount?.isHidden = false
            self.commentCount?.text = "\(number)"
        } else {
            self.commentButton?.setImage(UIImage(named: "IMG_music_ico_comment_complete"), for: UIControlState.normal)
            self.commentCount?.isHidden = true
        }

        /// 移除原有动画
        self.centerPhonographView?.removeRotate()

        /// 更新视图数据
        self.centerPhonographView?.updateViewData(songInfo: (self.songsDataArray?[currentPage])!.object())

        let leftPage = (self.currentPage + self.songsDataArray!.count - 1) % (self.songsDataArray?.count)!
        let rightPage = (self.currentPage + 1) % (self.songsDataArray?.count)!

        self.leftPhonographView?.updateViewData(songInfo: (songsDataArray?[leftPage])!.object())
        self.rightPhonographView?.updateViewData(songInfo: (songsDataArray?[rightPage])!.object())

        /// scrollview复位
        self.rootScorllView.setContentOffset(CGPoint(x: TSPhonograpRootViewUX.rootViewWidth, y: 0), animated: false)

        /// 添加新动画
        let time: TimeInterval = 0.05
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            self.centerPhonographView?.addRotate()
            self.centerPhonographView?.resumeAnimation()
            self.rotateToPhonograph()
        }
    }

    func autoPalyChange() {
        self.currentPage = TSMusicPlayerHelper.sharePlayerHelper.currentIndex
        reSetCenterView()
    }

    func pasueAnimation() {
        self.centerPhonographView?.pauseAnimation()
        self.rotateAwayFromPhonograph()
    }

    func reStarAnimation() {
        self.centerPhonographView?.resumeAnimation()
        self.rotateToPhonograph()
    }
    func reSetSongInfo() {
        if let objetc = self.currentSong {
            self.starButton?.setImage(UIImage(named: objetc.isLiked == true ? "IMG_music_ico_like_high" : "IMG_music_ico_like_normal"), for: .normal)

            let number = objetc.commentCount
            if number != 0 {
                self.commentButton?.setImage(UIImage(named: "IMG_music_ico_comment_incomplete"), for: UIControlState.normal)
                self.commentCount?.isHidden = false
                self.commentCount?.text = "\(number)"
            } else {
                self.commentButton?.setImage(UIImage(named: "IMG_music_ico_comment_complete"), for: UIControlState.normal)
                self.commentCount?.isHidden = true
            }
        }
    }
}
