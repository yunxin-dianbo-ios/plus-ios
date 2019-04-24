//
//  TSConllectionAlbumsVC.swift
//  ThinkSNS +
//
//  Created by LiuYu on 2017/4/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

private let collectionCellIdentiftier = "conllectionCell"

class TSConllectionAlbumsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /// 缺省图
    private enum OccupiedType {
        case network
        case empty
    }

    var mainCollectionView: UICollectionView? = nil
    /// 数据数组
    var dataArray: [TSAlbumListModel] = [TSAlbumListModel]()
    /// 分页标记
    var maxID: Int = 0
    var limit: Int = TSAppConfig.share.localInfo.limit
    var isRefreshing: Bool = false
    /// 缺省图
    private var occupiedView: UIImageView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TSColor.inconspicuous.background
        self.creatConllectionView()
        self.mainCollectionView?.mj_header.beginRefreshing()
    }

    // MARK: - UI
    func creatConllectionView() {

        let navigationBarAndStatusBarHeight = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height

        let collectionViewLayout = UICollectionViewFlowLayout()
        self.mainCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - navigationBarAndStatusBarHeight - TSNewsTagButtonUX.buttonHeight), collectionViewLayout: collectionViewLayout)
        self.mainCollectionView?.showsVerticalScrollIndicator = false
        self.mainCollectionView?.backgroundColor = UIColor.clear
        self.mainCollectionView?.delegate = self
        self.mainCollectionView?.dataSource = self

        self.mainCollectionView?.mj_header = TSRefreshHeader(refreshingBlock: {
            self.refresh()
        })

        self.mainCollectionView?.mj_footer = TSRefreshFooter(refreshingBlock: {
            self.loadMore()
        })
        self.mainCollectionView?.mj_footer.isHidden = true

        self.mainCollectionView?.register(UINib(nibName: "TSMusicListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: collectionCellIdentiftier)
        self.view .addSubview(self.mainCollectionView!)

        /// 缺省图
        self.occupiedView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.mainCollectionView!.frame.width, height: self.mainCollectionView!.frame.height))
        self.occupiedView?.contentMode = UIViewContentMode.center
        self.occupiedView?.backgroundColor = .clear
    }
    /// 显示缺省图
    ///
    /// - Parameter type: 缺省图显示类型
    private func showOccupiedView(_ type: OccupiedType) {
        switch type {
        case .network:
            self.occupiedView?.image = UIImage(named: "IMG_img_default_internet")
        case .empty:
            self.occupiedView?.image = UIImage(named: "IMG_img_default_nothing")
        }
        if self.occupiedView?.superview == nil {
            self.mainCollectionView?.addSubview(self.occupiedView!)
        }
        if !self.dataArray.isEmpty && self.occupiedView?.superview != nil {
            self.occupiedView?.removeFromSuperview()
        }
    }
    // MARK: - Delegate
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentiftier, for: indexPath) as? TSMusicListCollectionViewCell)!
        cell.setItemData(cellData: self.dataArray[indexPath.row])
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
        let albumVC = TSAlbumsListVC()
        albumVC.albumListModel = self.dataArray[indexPath.row]
        self.navigationController?.pushViewController(albumVC, animated: true)
    }

    // MARK: - request
    func refresh() {
        self.maxID = 0
        TSMusicTaskManager().networkCollectAlbumList(maxId: self.maxID, limit: self.limit) { [weak self] (albumList, _, status) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.isRefreshing = false
            weakSelf.mainCollectionView?.mj_header.endRefreshing()

            // 网络错误，或服务器数据问题
            guard status, let albumList = albumList else {
                weakSelf.showOccupiedView(.network)
                return
            }
            weakSelf.dataArray = albumList
            if albumList.isEmpty {
                weakSelf.showOccupiedView(.empty)
                weakSelf.mainCollectionView?.mj_footer.isHidden = true
            } else {
                // 有数据
                weakSelf.mainCollectionView?.reloadData()
                // 更换页数
                weakSelf.maxID = weakSelf.dataArray.last!.id
                weakSelf.mainCollectionView?.mj_footer.isHidden = albumList.count >= weakSelf.limit ? false : true
            }

            if (weakSelf.mainCollectionView?.mj_header.isRefreshing())! {
                weakSelf.mainCollectionView?.mj_header.endRefreshing()
            }
            weakSelf.mainCollectionView?.reloadData()
        }
    }

    func loadMore() {
        if dataArray.isEmpty {
            mainCollectionView?.mj_footer.endRefreshing()
            return
        }
        TSMusicTaskManager().networkCollectAlbumList(maxId: self.maxID, limit: self.limit) { [weak self](albumList, _, status) in
            guard let weakSelf = self else {
                return
            }
            // 网络错误，或服务器数据问题
            guard status, let albumList = albumList else {
                weakSelf.mainCollectionView?.mj_footer.endRefreshingWithWeakNetwork()
                return
            }
            // 没有数据
            if albumList.count < weakSelf.limit {
                weakSelf.mainCollectionView?.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            // 有数据
            weakSelf.dataArray = weakSelf.dataArray + albumList
            weakSelf.mainCollectionView?.reloadData()
            weakSelf.mainCollectionView?.mj_footer.endRefreshing()
            // 更换页数
            weakSelf.maxID = weakSelf.dataArray.last!.id
        }
    }

    // MARK: - other
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
