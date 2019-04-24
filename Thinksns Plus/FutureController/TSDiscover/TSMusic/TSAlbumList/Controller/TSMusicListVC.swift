//
//  TSMusicListVC.swift
//  LiusSwiftDemo
//
//  Created by LiuYu on 2017/2/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  “音乐FM”专辑列表界面

import UIKit

private let collectionCellIdentiftier = "conllectionCell"

class TSMusicListVC: TSViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var mainCollectionView: UICollectionView? = nil
    /// 数据数组
    var dataArray: [TSAlbumListModel] = [TSAlbumListModel]()
    /// 分页标记
    var maxID: Int = 0
    /// 每页个数限制
    let pageLimit: Int = TSAppConfig.share.localInfo.limit
    /// 购买的音乐按钮
    fileprivate weak var payMusicButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "音乐FM"
        self.setPayedMusicButton()
        self.creatConllectionView()
        self.loadInitialData()
    }
    // MARK: - 设置发起聊天按钮（设置右上角按钮）
    func setPayedMusicButton() {
        let payMusicItem = UIButton(type: .custom)
        payMusicItem.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.setupNavigationTitleItem(payMusicItem, title: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: payMusicItem)
        self.payMusicButton = payMusicItem
        self.payMusicButton.setImage(UIImage(named: "IMG_ico_me_music"), for: UIControlState.normal)
        self.payMusicButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.payMusicButton.width - (self.payMusicButton.currentImage?.size.width)!, bottom: 0, right: 0)
    }

    /// 调转购买的音乐
    func rightButtonClick() {
        let vc = MyMusicController()
        navigationController?.pushViewController(vc, animated: true)
    }
    // MARK: - UI
    func creatConllectionView() {

        let navigationBarAndStatusBarHeight = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height

        let collectionViewLayout = UICollectionViewFlowLayout()
        self.mainCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - navigationBarAndStatusBarHeight), collectionViewLayout: collectionViewLayout)
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
        // 判断专辑是否需要付费，以及是否已付费
        var paidFlag = true   // 付费标记，默认付费(无需付费的 视为已付费)
        if false == albumModel.paidNode?.paid {
            paidFlag = false
        }
        // 无需付费 或 已付费
        if paidFlag {
            let albumVC = TSAlbumsListVC()
            albumVC.albumListModel = albumModel
            self.navigationController?.pushViewController(albumVC, animated: true)
            return
        }
        // 去付费
        let price = albumModel.paidNode!.amount // 上面已判断，可强转
        let payAlert = TSIndicatorPayMusicAlbum(price: Double(Int(price)))
        payAlert.show(album: albumModel, success: { [weak self] in
            guard let weakSelf = self else {
                return
            }
            // 进入专辑详情页
            let albumVC = TSAlbumsListVC()
            albumVC.albumListModel = albumModel
            weakSelf.navigationController?.pushViewController(albumVC, animated: true)
        }, failure: { [weak self] () in
            guard let weakSelf = self else {
                return
            }
            /// 这里已经是先本地判断了积分是否不足了,所以这里肯定不是因为积分不足而购买失败,所以不用跳转到积分充值页面
            return
            // 进入钱包页
            let walletVC = WalletHomeController.vc()
            weakSelf.navigationController?.pushViewController(walletVC, animated: true)
        })
    }
    // MARK: - request

    /// 加载初始数据
    func loadInitialData() -> Void {
        self.loadInitialLocalData()
        // 默认上拉刷新，加载网络数据
        self.mainCollectionView?.mj_header.beginRefreshing()
    }
    func loadInitialData(_ modelList: [TSAlbumListModel]) -> Void {
        self.dataArray = modelList
        self.mainCollectionView?.mj_footer.isHidden = (self.dataArray.count >= pageLimit) ? false : true
        self.maxID = self.dataArray.last?.id ?? 0
        if self.dataArray.isEmpty {
            // 加载缺省图 - 没有数据
        }
        self.mainCollectionView?.reloadData()
    }
    /// 加载初始本地数据
    func loadInitialLocalData() -> Void {
        self.maxID = 0
        let modelList = TSDatabaseManager().music.getAlbumList(maxId: self.maxID, limit: self.pageLimit)
        self.loadInitialData(modelList)
    }
    /// 加载初始网络数据
    func loadInitialNetworkData() -> Void {
        self.maxID = 0
        TSMusicTaskManager().networkRequestAlbumList(maxId: self.maxID, limit: self.pageLimit) { [weak self] (albumList, _, status) in
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
        TSMusicTaskManager().networkRequestAlbumList(maxId: self.maxID, limit: self.pageLimit) { (albumList, _, status) in
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
