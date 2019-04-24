//
//  MusicAlbumListView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/12.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  音乐列表
//
//  改编自 TSMusicListVC 的代码

import UIKit

private let collectionCellIdentiftier = "conllectionCell"

class MusicAlbumListVC: TSViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var mainCollectionView: TSCollectionView? = nil
    /// 数据数组
    var dataArray: [TSAlbumListModel] = [TSAlbumListModel]()
    /// 分页标记
    var maxID: Int = 0
    /// 每页个数限制
    let pageLimit: Int = TSAppConfig.share.localInfo.limit

    override func viewDidLoad() {
        super.viewDidLoad()
        self.creatConllectionView()
        self.loadInitialData()
    }

    // MARK: - UI
    func creatConllectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        self.mainCollectionView = TSCollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64), collectionViewLayout: collectionViewLayout)
        self.mainCollectionView?.showsVerticalScrollIndicator = false
        self.mainCollectionView?.backgroundColor = UIColor.white
        self.mainCollectionView?.delegate = self
        self.mainCollectionView?.dataSource = self

        self.mainCollectionView?.mj_header = TSRefreshHeader(refreshingBlock: {
            // 上拉刷新 应考虑加载本地数据的情况，根据网络情况来判定
            self.loadInitialNetworkData()
        })

        self.mainCollectionView?.mj_footer = TSRefreshFooter(refreshingBlock: {
            // 上拉刷新 应考虑加载本地数据的情况，根据网络情况来判定
            self.loadMoreNetworkData()
        })
        self.mainCollectionView?.mj_footer.isHidden = true

        self.mainCollectionView?.register(UINib(nibName: "TSMusicListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: collectionCellIdentiftier)
        self.view .addSubview(self.mainCollectionView!)
    }

    // MARK: - Delegate
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentiftier, for: indexPath) as? TSMusicListCollectionViewCell)!
        cell.setItemData(cellData: self.dataArray[indexPath.row])
        self.reloadItemAtIndex(index: indexPath.row)
        return cell
    }
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.size.width - (10 * 3)) / 2, height: ((UIScreen.main.bounds.size.width - (10 * 3)) / 2) * 1.38)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let albumModel = self.dataArray[indexPath.row]
        // 进入专辑详情页
        let albumVC = TSAlbumsListVC()
        albumVC.albumListModel = albumModel
        navigationController?.pushViewController(albumVC, animated: true)
    }

    // MARK: - request

    /// 加载初始数据
    func loadInitialData() -> Void {
        // 默认上拉刷新，加载网络数据
        self.mainCollectionView?.mj_header.beginRefreshing()
    }
    func loadInitialData(_ modelList: [TSAlbumListModel]) -> Void {
        self.dataArray = modelList
        self.mainCollectionView?.mj_footer.isHidden = (self.dataArray.count >= pageLimit) ? false : true
        self.maxID = self.dataArray.last?.id ?? 0
        if self.dataArray.isEmpty {
            // 加载缺省图 - 没有数据
            self.mainCollectionView?.showPlaceHolder(PlaceHolder.nothing)
        } else {
            self.mainCollectionView?.hiddenPlaceHolder()
        }
        self.mainCollectionView?.reloadData()
    }

    /// 加载初始网络数据
    func loadInitialNetworkData() -> Void {
        TSMineNetworkManager.getMyMusicAlbums(maxID: nil) { [weak self] (albumList, _, status) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.mainCollectionView?.mj_header.endRefreshing()
            weakSelf.endLoading()
            // 结果处理
            guard status, let albumList = albumList else {
                // 请求失败，或服务器返回数据异常
                // 初始网络数据请求失败时，可根据是否有本地的数据而进行不同的展示：头部展示与默认图展示
                weakSelf.loadFaild(type: .network)
                return
            }
            // 请求成功，且列表有数据
            // 购买的音乐不显示付费标签，手动将付费标签移除
            let _ = albumList.map { $0.paidNode = nil }
            weakSelf.loadInitialData(albumList)
        }
    }

    /// 加载更多
    func loadMoreData(_ list: [TSAlbumListModel]?) -> Void {
        guard let list = list else {
            self.mainCollectionView?.mj_footer.endRefreshing()
            return
        }
        self.dataArray += list
        self.maxID = (nil == list.last) ? self.maxID : list.last!.id
        // 没有更多数据了
        if self.dataArray.count < self.pageLimit {
            self.mainCollectionView?.mj_footer.endRefreshingWithNoMoreData()
        } else {
            self.mainCollectionView?.mj_footer.endRefreshing()
        }
        self.mainCollectionView?.reloadData()
    }
    /// 加载更多网络数据
    func loadMoreNetworkData() -> Void {
        TSMineNetworkManager.getMyMusicAlbums(maxID: maxID) { (albumList, _, status) in
            // 购买的音乐不显示付费标签，手动将付费标签移除
            var albumList = albumList
            if let modelsData = albumList {
                let _ = modelsData.map { $0.paidNode = nil }
                albumList = modelsData
            }
            self.loadMoreData(albumList)
            if !status {
                // 网络出错，应给予展示
            }
        }
    }

    /// 屏蔽动画效果的刷新方法
    /// note: - 在cellforItem方法里调用
    ///
    /// - Parameter index: 刷新的位置
    func reloadItemAtIndex(index: Int) {
        UIView.setAnimationsEnabled(false)
        self.mainCollectionView?.performBatchUpdates({
            self.mainCollectionView?.reloadItems(at: [IndexPath(item: index, section: 0)])
        }, completion: { (_) in
            UIView.setAnimationsEnabled(true)
        })
    }

    // MARK: - other
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
