//
//  TSPlaySongListView.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/11.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  播放列表弹窗

import UIKit
import SnapKit

private struct SongListViewUX {
    static let toolAreaHeight: CGFloat = 44
    static let left: CGFloat = 15
    static let imageW: CGFloat = 20
    static let buttonW: CGFloat = 44
    static let top: CGFloat = (SongListViewUX.toolAreaHeight - SongListViewUX.imageW) / 2
}

/// 播放列表弹窗的代理
protocol TSPlaySongListViewProtocol: class {
    /// 收费歌曲支付失败回调，需跳转到钱包界面
    func didPaySongFail() -> Void
}

class TSPlaySongListView: NSObject, UITableViewDelegate, UITableViewDataSource {
    /// 回调
    weak var delegate: TSPlaySongListViewProtocol?
    var paySongFailAction: (() -> Void)?

    /// 单例对象
    static let shareInstance = TSPlaySongListView()
    /// 黑色透明背景
    var BGView: UIView? = nil
    /// 歌曲列表区域（包括提示）
    var listView: UIView? = nil
    /// 模式提示图片
    var modeImage: TSImageView? = nil
    /// 歌曲数量
    var titleLabel: TSLabel? = nil
    /// 取消按钮
    var cancelButton: TSButton? = nil
    /// 列表
    var tableView: TSTableView? = nil
    // TODO: MusicUpdate - 音乐模块更新中，To be done
//    /// 歌曲数组
//    var songListArray: [TSSongObject] = []
//    /// 当前播放歌曲
//    var currentSong: TSSongObject? = nil
    /// 歌曲数组
    var songListArray: [TSSongModel] = [TSSongModel]()
    /// 当前播放歌曲
    var currentSong: TSSongModel? = nil

    private override init() {
        super.init()
        initBaseView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initBaseView() {

        BGView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: ScreenSize.ScreenHeight))
        BGView?.backgroundColor = TSColor.normal.blackTitle
        BGView?.alpha = 0.1
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenList))
        BGView?.addGestureRecognizer(tap)

        listView = UIView(frame: CGRect(x: 0, y: ScreenSize.ScreenHeight, width: ScreenSize.ScreenWidth, height: ScreenSize.ScreenHeight * 0.6))
        listView?.backgroundColor = TSColor.main.white

        modeImage = TSImageView()
        listView?.addSubview(modeImage!)
        modeImage?.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: SongListViewUX.imageW, height: SongListViewUX.imageW))
            make.left.equalTo(self.listView!.snp.left).offset(SongListViewUX.left)
            make.top.equalTo(self.listView!).offset(SongListViewUX.top)
        })

        cancelButton = TSButton()
        cancelButton?.setTitle("取消".localized, for: UIControlState.normal)
        cancelButton?.setTitleColor(TSColor.main.theme, for: UIControlState.normal)
        cancelButton?.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.keyboardRight.rawValue)
        cancelButton?.addTarget(self, action: #selector(cancel), for: UIControlEvents.touchUpInside)
        listView?.addSubview(cancelButton!)
        cancelButton?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.modeImage!.snp.centerY)
            make.size.equalTo(CGSize(width: SongListViewUX.buttonW, height: SongListViewUX.buttonW))
            make.right.equalTo(self.listView!.snp.right)
        })

        titleLabel = TSLabel()
        titleLabel?.textColor = TSColor.normal.blackTitle
        titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.sectionTitle.rawValue)
        listView?.addSubview(titleLabel!)
        titleLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.modeImage!.snp.right).offset(SongListViewUX.left)
            make.right.equalTo(self.cancelButton!.snp.left).offset(-SongListViewUX.left)
            make.centerY.equalTo(self.modeImage!.snp.centerY)
            make.height.equalTo(SongListViewUX.toolAreaHeight)
        })

        let graLine = UIView()
        graLine.backgroundColor = TSColor.inconspicuous.disabled
        listView?.addSubview(graLine)
        graLine.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.listView!)
            make.height.equalTo(1)
            make.top.equalTo(self.titleLabel!.snp.bottom)
        }

        tableView = TSTableView()
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.tableFooterView = UIView()
        tableView?.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView?.register(UINib(nibName: "TSSongListCell", bundle: nil), forCellReuseIdentifier: "listViewCell")
        tableView?.mj_header = nil
        tableView?.mj_footer = nil
        listView?.addSubview(tableView!)
        tableView?.snp.makeConstraints({ (make) in
            make.top.equalTo(graLine.snp.bottom)
            make.right.left.bottom.equalTo(self.listView!)
        })
    }

    // MARK: - tableViewDelegate && DataSource 
    // MARK: DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songListArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TSSongListCellUX.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listViewCell") as! TSSongListCell
        if !self.songListArray.isEmpty {
            let song = self.songListArray[indexPath.row]
            let isPlay = self.currentSong?.storage?.id == song.storage?.id
            cell.updateCellData(song: song, isPlaying: isPlay)
        }
        return cell
    }

    // MARK: Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // 判断当前选中歌曲是否需要付费，且是否已经付费
        let selectSong = self.songListArray[indexPath.row]
        var paidFlag: Bool = true // 付费标记，默认已付费，无需付费视为已付费
        if false == selectSong.storage?.paid {
            paidFlag = false
        }
        // 无需付费
        if paidFlag {
            TSMusicPlayVC.shareMusicPlayVC.playsong(index: indexPath.row)
            self.currentSong = self.songListArray[indexPath.row]
            self.tableView?.reloadData()
            return
        }
        // 去付费
        let price: Float = selectSong.storage!.amount ?? 0
        let payAlert = TSIndicatorPayMusicSong(price: Double(Int(price)))
        payAlert.show(song: selectSong, success: { [weak self] () in
            guard let weakSelf = self else {
                return
            }
            TSMusicPlayVC.shareMusicPlayVC.playsong(index: indexPath.row)
            weakSelf.currentSong = weakSelf.songListArray[indexPath.row]
            weakSelf.tableView?.reloadData()
            }, failure: { [weak self] () in
                guard let weakSelf = self else {
                    return
                }
                // 回调，进入钱包页
                weakSelf.delegate?.didPaySongFail()
                weakSelf.paySongFailAction?()
                // 隐藏当前界面
                weakSelf.cancel()
        })

    }

    // MARK: - Action
    @objc func cancel() {
        hiddenList()
    }
    // MARK: - data
    func getData() {
        self.songListArray = TSMusicPlayerHelper.sharePlayerHelper.songList
        self.currentSong = TSMusicPlayerHelper.sharePlayerHelper.currentSong
        switch TSMusicPlayerHelper.sharePlayerHelper.mode {
        case .circulation:
            self.modeImage?.image = UIImage(named: "IMG_music_ico_inorder_grey")
            self.titleLabel?.text = "顺序播放(\(self.songListArray.count)首)"
            break
        case .random:
            self.modeImage?.image = UIImage(named: "IMG_music_ico_random_grey")
            self.titleLabel?.text = "随机播放(\(self.songListArray.count)首)"
            break
        case .single:
            self.modeImage?.image = UIImage(named: "IMG_music_ico_single_grey")
            self.titleLabel?.text = "单曲循环"
            break
        }
        self.tableView?.reloadData()
    }

    // MARK: - animation
    func showList() {
        getData()
        if self.BGView?.superview == nil {
            UIApplication.topViewController()?.view.addSubview(BGView!)
            UIView.animate(withDuration: 0.3, animations: {
                self.BGView?.alpha = 0.7
            })
        }
        if self.listView?.superview == nil {
            UIApplication.topViewController()?.view.addSubview(listView!)
            UIView.animate(withDuration: 0.3, animations: {
                var frame = self.listView?.frame
                frame?.origin.y = ScreenSize.ScreenHeight * 0.4
                self.listView?.frame = frame!
            })
        }
    }

    func hiddenList() {
        UIView.animate(withDuration: 0.3, animations: {
            var frame = self.listView?.frame
            frame?.origin.y = ScreenSize.ScreenHeight
            self.listView?.frame = frame!
        }) { (_) in
            self.listView?.removeFromSuperview()
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.BGView?.alpha = 0.1
        }) { (_) in
            self.BGView?.removeFromSuperview()
        }
    }
}
