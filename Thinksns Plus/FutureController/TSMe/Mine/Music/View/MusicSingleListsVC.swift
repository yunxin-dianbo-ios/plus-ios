//
//  MusicListsVC.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  单曲列表

import UIKit

class MusicSingleListsVC: TSTableViewController {

    /// 数据
    var datas: [TSSongModel] = []
    /// 当前正在播放的歌曲
    var currentSong: TSSongModel?
    /// 是否显示付费标签
    var shouldShowPayTag = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        tableView.mj_header.beginRefreshing()
    }

    // MARK: - UI
    func setUI() {
        tableView.rowHeight = TSSongListCellUX.cellHeight
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "TSSongListCell", bundle: nil), forCellReuseIdentifier: "TSSongListCell")
    }

    // MARK: - Data

    override func refresh() {
        TSMineNetworkManager.getMySongs(maxID: nil) { [weak self](models, msg, _) in
            guard let weakSelf = self else {
                return
            }
            // 购买的音乐不显示付费标签，手动将付费标签移除
            var models = models
            if let modelsData = models {
                  let _ = modelsData.map { $0.storage?.paid = nil }
                models = modelsData
            }
            weakSelf.processRefreshData(data: models, message: msg)
        }
    }

    override func loadMore() {
        TSMineNetworkManager.getMySongs(maxID: datas.last?.id) { [weak self](models, msg, _) in
            guard let weakSelf = self else {
                return
            }
            // 购买的音乐不显示付费标签，手动将付费标签移除
            var models = models
            if let modelsData = models {
                let _ = modelsData.map { $0.storage?.paid = nil }
                models = modelsData
            }
            weakSelf.processLoadMoreData(data: models, message: msg)
        }
    }

    /// 处理下拉刷新的数据，并调整相关的交互视图
    func processRefreshData(data: [TSSongModel]?, message: String?) {
        tableView.mj_footer.resetNoMoreData()
        // 1.网络失败
        if let message = message {
            // 1.1 结束 footer 动画
            tableView.mj_header.endRefreshing()
            // 1.2 如果界面上有数据，显示 indicatorA；如果界面上没有数据，显示"网络错误"的占位图
            datas.isEmpty ? showOccupiedView(.network, isDataSourceEmpty: datas.isEmpty) : show(indicatorA: message)
            return
        }
        // 2.请求成功
        // 2.1 更新 dataSource
        if let data = data {
            datas = data
            if data.isEmpty == true {
                // 2.2 如果数据为空，显示占位图
                showOccupiedView(.empty, isDataSourceEmpty: datas.isEmpty)
            }
        }
        // 3.隐藏多余的指示器和刷新动画
        dismissIndicatorA()
        if tableView.mj_header.isRefreshing() {
            tableView.mj_header.endRefreshing()
        }
        // 4.刷新界面
        tableView.reloadData()
    }

    /// 处理上拉加载更多的数据，并调整相关的交互视图
    func processLoadMoreData(data: [TSSongModel]?, message: String?) {
        // 1.网络失败，显示"网络失败"的 footer
        if message != nil {
            tableView.mj_footer.endRefreshingWithWeakNetwork()
            return
        }
        dismissIndicatorA()
        // 2.请求成功
        if let data = data {
            datas = datas + data
            tableView.reloadData()
        }
        // 3. 判断新数据数量是否够一页。不够一页显示"没有更多"的 footer；够一页仅结束 footer 动画
        if data!.count < TSAppConfig.share.localInfo.limit {
            tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            tableView.mj_footer.endRefreshing()
        }
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MusicSingleListsVC {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !datas.isEmpty && occupiedView.superview != nil {
            occupiedView.removeFromSuperview()
        }
        if tableView.mj_footer != nil {
            tableView.mj_footer.isHidden = datas.count < TSAppConfig.share.localInfo.limit
        }
        return datas.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TSSongListCell") as! TSSongListCell
        if !self.datas.isEmpty {
            let song = self.datas[indexPath.row]
            let isPlay = self.currentSong?.storage?.id == song.storage?.id
            cell.updateCellData(song: song, isPlaying: isPlay)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let songIndex = indexPath.row
        // 进入播放页
        let playVC = TSMusicPlayVC.shareMusicPlayVC
        // TODO: MusicUpdate - 音乐模块更新中，To be removed
        //        var songObjectList = [TSSongObject]()
        //        for songModel in self.songListArray {
        //            songObjectList.append(songModel.object())
        //        }
        playVC.setData(AlbumID: 0, songIndex: songIndex, SongList: datas)
        currentSong = datas[songIndex]
        tableView.reloadData()
        navigationController?.pushViewController(playVC, animated: true)
    }
}
