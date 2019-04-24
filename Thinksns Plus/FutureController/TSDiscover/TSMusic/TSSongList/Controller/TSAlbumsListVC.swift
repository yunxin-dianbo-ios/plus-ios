//
//  TSAlbumsListVC.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/2/13.
//  Copyright © 2017年 LeonFa. All rights reserved.
//

import UIKit
import Kingfisher

class TSAlbumsListVC: TSViewController, UITableViewDelegate, UITableViewDataSource, TSAlbumHeaderviewDelegate {

    /// 头部控件
    lazy var headerView: TSAlbumHeaderview? = nil
    /// 头部可缩放背景
    lazy var headerBgView: UIImageView? = nil
    /// 高斯模糊图层
    lazy var blurView: UIVisualEffectView? = nil
    /// 导航栏高度
    lazy var navigationbarHeight: CGFloat? = nil
    /// 列表
    let tableview = UITableView()
    /// 导航栏标题
    var titleView: TSMusicNavigationTitleView? = nil
    /// 数据
    var albumListModel: TSAlbumListModel?
    var albumDetailModel: TSAlbumDetailModel?
    /// 歌曲数据
    var songListArray: [TSSongModel] = [TSSongModel]()
    /// 头部控件高度
    let headerViewHeight: CGFloat = 190
    /// 当前正在播放的歌曲
    var currentSong: TSSongModel?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        TSMusicPlayStatusView.shareView.reSetImage(white: true)
        checkCurrenSongObject()
        if nil != self.albumListModel {
            self.headerView?.updateHeaderData(model: self.albumListModel!)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        TSMusicPlayStatusView.shareView.reSetImage(white: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loading()
        self.makeViews()
//        self.loadSongList()
        self.loadAlbumData()

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setImage(UIImage(named: "IMG_topbar_back_white"), for: UIControlState.normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(popBack), for: UIControlEvents.touchUpInside)
        let backBarItem = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = backBarItem
    }

    // MARK: - UI
    func makeViews() {

        self.navigationbarHeight = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height
        self.tableview.frame = CGRect(x: 0, y: self.navigationbarHeight!, width: self.view.frame.width, height: self.view.frame.height - self.navigationbarHeight!)
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.tableFooterView = UIView()
        self.tableview.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableview.showsVerticalScrollIndicator = false
        self.tableview.backgroundColor = UIColor.clear
        self.tableview.register(UINib(nibName: "TSSongListCell", bundle: nil), forCellReuseIdentifier: "songList")

        self.headerView = TSAlbumHeaderview(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: headerViewHeight))
        self.tableview.tableHeaderView = self.headerView

        self.headerBgView = UIImageView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: self.view.frame.width, height: (headerViewHeight + self.navigationbarHeight!)))
        self.headerBgView?.contentMode = UIViewContentMode.scaleAspectFill
        self.headerBgView?.backgroundColor = TSColor.inconspicuous.disabled
        self.headerBgView?.clipsToBounds = true

        self.view .addSubview(self.headerBgView!)
        self.blurEffectForBgImageView()
        self.view .addSubview(self.tableview)

        self.setHeaderData()
    }

    func setHeaderData() {
        self.headerBgView?.kf.setImage(with: TSURLPath.imageV2URLPath(storageIdentity: self.albumListModel?.storage?.id, compressionRatio: 20, size: self.albumListModel?.storage?.size), placeholder: UIImage.create(with: TSColor.inconspicuous.disabled, size: (self.headerView?.frame.size)!), options: nil, progressBlock: nil, completionHandler: nil)
        self.headerView?.delegate = self
        if nil != self.albumListModel {
            self.headerView?.updateHeaderData(model: self.albumListModel!)
        }
        self.creatNavigationTitleView()
    }

    func creatNavigationTitleView() {
        self.titleView = TSMusicNavigationTitleView(frame: CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth - 120, height: 40), type: .Album)
        self.titleView?.marqueeText = self.albumListModel?.title
        self.navigationItem.titleView = self.titleView
        self.titleView?.isHidden = true
    }

    // MARK: 背景图片的毛玻璃效果
    func blurEffectForBgImageView() {
        let blureffect = UIBlurEffect(style: .light)
        self.blurView = UIVisualEffectView(effect: blureffect)
        self.blurView?.frame.size = (self.headerBgView?.frame.size)!
        self.headerBgView? .addSubview(self.blurView!)
    }

    // MARK: - delegate
    // MARK: TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songListArray.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let sectionHeader = UIView()
        sectionHeader.backgroundColor = .white

        let titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.frame.width, height: 40))
        let songCountStr = "(共\(self.songListArray.count)首)"
        let songInfo = NSMutableAttributedString(string: "歌曲列表" + songCountStr)
        songInfo.addAttributes([NSForegroundColorAttributeName: TSColor.normal.secondary], range: NSRange(location: 4, length: songCountStr.count))
        titleLabel.textColor = TSColor.normal.content
        titleLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        titleLabel.attributedText = songInfo
        let line = UIView(frame: CGRect(x: 0, y: titleLabel.frame.maxY - 0.5, width: titleLabel.frame.width, height: 0.5))
        line.backgroundColor = TSColor.normal.disabled
        sectionHeader .addSubview(line)
        sectionHeader .addSubview(titleLabel)
        return sectionHeader
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TSSongListCellUX.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "songList") as! TSSongListCell
        if !self.songListArray.isEmpty {
            let song = self.songListArray[indexPath.row]
            let isPlay = self.currentSong?.storage?.id == song.storage?.id
            cell.updateCellData(song: song, isPlaying: isPlay)
        }
        return cell
    }

    // MARK: tableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 未登录处理
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        // 判断该当前选中歌曲是否需要收费，以及是否已付费
        let selectedSong = self.songListArray[indexPath.row]
        var paidFlag = true // 默认已付费，无需付费视为已付费
        if false == selectedSong.storage?.paid {
            paidFlag = false
        }
        // 无需付费，进入播放界面
        if paidFlag {
            self.goPlayVC(withIndex: indexPath.row)
            return
        }
        // 去付费
        let price: Float = selectedSong.storage!.amount ?? 0
        let payAlert = TSIndicatorPayMusicSong(price: Double(Int(price)))
        payAlert.show(song: selectedSong, success: { [weak self] () in
            guard let weakSelf = self else {
                return
            }
            weakSelf.goPlayVC(withIndex: indexPath.row)
            }, failure: { [weak self] () in
                guard let weakSelf = self else {
                    return
                }
                // 进入钱包页
                let walletVC = WalletHomeController.vc()
                weakSelf.navigationController?.pushViewController(walletVC, animated: true)
        })
    }
    /// 进入播放界面
    fileprivate func goPlayVC(withIndex songIndex: Int) -> Void {
        // 进入播放页
        let playVC = TSMusicPlayVC.shareMusicPlayVC
        // TODO: MusicUpdate - 音乐模块更新中，To be removed
//        var songObjectList = [TSSongObject]()
//        for songModel in self.songListArray {
//            songObjectList.append(songModel.object())
//        }
        playVC.setData(AlbumID: (self.albumListModel?.id)!, songIndex: songIndex, SongList: self.songListArray)
        self.currentSong = self.songListArray[songIndex]
        self.tableview.reloadData()
        self.navigationController?.pushViewController(playVC, animated: true)
    }

    // MARK: scrollview Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        var headerImgVH = -offsetY + headerViewHeight + self.navigationbarHeight!
        headerImgVH = max(headerImgVH, 0)
        if offsetY < self.headerViewHeight {
            self.headerBgView?.frame.size = CGSize(width: self.view.frame.width, height: headerImgVH)
            self.blurView?.frame.size = CGSize(width: self.view.frame.width, height: headerImgVH)
            if !(self.titleView?.isHidden)! {
                self.titleView?.isHidden = true
            }
        } else {
            if (self.titleView?.isHidden)! {
                self.titleView?.isHidden = false
                self.titleView?.setText(marqueeText: (self.albumListModel?.title)!, subTitle: nil)
            }
        }
    }

    // MARK: loadingViewDelegate
    override func reloadingButtonTaped() {
//        self.loadSongList()
        self.loadAlbumData()
    }
    // MARK: TSAlbumHeaderviewDelegate
    // 点击评论
    func clickComment(AlbumID id: Int) {
        guard let albumModel = self.albumDetailModel else {
            return
        }
        let albumCommentVC = TSMusicCommentVC(musicType: .album, sourceId: id, introModel: TSMusicCommentIntroModel(album: albumModel))
        self.navigationController?.pushViewController(albumCommentVC, animated: true)
    }
    // 点击收藏
    func clickCollection(albumId: Int, collectState: Bool) {
        // 收藏相关的网络请求
        TSMusicNetworkManager().albumCollection(currentCollect: collectState, albumId: albumId) { [weak self](_, status) in
            guard let weakSelf = self else {
                return
            }
            if status {
                // 操作成功，提示并修改数据库、修改当前的数据模型
                weakSelf.albumListModel?.collectCount = weakSelf.albumListModel!.collectCount + (weakSelf.albumListModel!.isCollectd ? -1 : 1 )
                weakSelf.albumListModel?.isCollectd = !weakSelf.albumListModel!.isCollectd
                weakSelf.headerView?.updateHeaderData(model: weakSelf.albumListModel!)
            } else {
                // 操作失败，提示并修正收藏的显示
                weakSelf.headerView?.updateHeaderData(model: weakSelf.albumListModel!)
            }
        }

    }

    // 获取专辑详情
    func loadAlbumData() -> Void {
        guard let albumId = self.albumListModel?.id else {
            return
        }
        // 本地获取
        if let localAlbumDeail = TSMusicTaskManager().dbQueryAlbumDetail(with: albumId) {
            self.albumDetailModel = localAlbumDeail
            if localAlbumDeail.musics != nil {
                self.songListArray = localAlbumDeail.musics!
            }
            self.tableview.reloadData()
        }
        // 网络获取
        TSMusicTaskManager().networkRequestAlbumDetail(albumId: albumId) { [weak self](detailModel, msg, status) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.endLoading()
            guard status, let detailModel = detailModel else {
                TSLogCenter.log.verbose(msg)
                return
            }
            weakSelf.albumDetailModel = detailModel
            if detailModel.musics != nil {
                weakSelf.songListArray = detailModel.musics!
            }
            weakSelf.tableview.reloadData()
        }
    }

    func checkCurrenSongObject() {
        if let songObject = TSMusicPlayerHelper.sharePlayerHelper.currentSong {
            if self.currentSong?.storage?.id != songObject.storage?.id {
                self.currentSong = songObject
                self.tableview.reloadData()
            }
        }
    }

    func popBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    // MARK: - others
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
