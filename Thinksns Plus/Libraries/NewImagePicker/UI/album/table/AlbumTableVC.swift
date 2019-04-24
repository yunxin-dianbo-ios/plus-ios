//
//  TSPhotoTableVC.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/15.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import Photos

class AlbumTableVC: UITableViewController, ImagePickerDataUsable {

    /// 数据源
    var dataSource: [AlbumModel] = []

    /*
     可选多张图片时，结束操作由 AlbumCollectionVC 的工具栏或者 PHPreviewVC 的工具栏中的完成按钮触发；
     只选单张图片时，结束操作有 AlbumCollectionVC 的 cell 点击事件触发。
     */
    /// 图片选择结束操作
    var finishBlock: (([UIImage], [PHAsset]) -> Void)?

    // MARK: - Lifecycle
    class func photoTableVC() -> AlbumTableVC {
        let sb = UIStoryboard(name: "AlbumTableVC", bundle: nil)
        let table = sb.instantiateInitialViewController() as! AlbumTableVC
        return table
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loadData()
    }

    // MARK: - Custom user interface

    func setUI() {
        title = "相册"
        tableView.tableFooterView = UIView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelButtonTaped))
    }

    // MARK: - Data

    func loadData() {
        // [长期注释] 这里会导致 VM:libswiftcore.dylib 的内存泄漏，有时间的时候研究一下
        guard let dataManager = dataManager() else {
            return
        }
        dataSource = dataManager.getAlbumList()
    }

    // MARK: - Button click

    /// 取消按钮点击事件
    func cancelButtonTaped() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Public
    func setFinish(operation: (([UIImage], [PHAsset]) -> Void)?) {
        finishBlock = operation
    }
}

extension AlbumTableVC {

    // MARK: - Delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTableViewCell.identifier, for: indexPath) as! AlbumTableViewCell
        let model = dataSource[indexPath.row]
        cell.setInfo(albumModel: model)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albumDetail = AlbumCollectionVC()
        albumDetail.setInfo(albumModel: dataSource[indexPath.row])
        // 传递结束操作
        albumDetail.setFinish(operation: finishBlock)
        navigationController?.pushViewController(albumDetail, animated: true)
    }
}
