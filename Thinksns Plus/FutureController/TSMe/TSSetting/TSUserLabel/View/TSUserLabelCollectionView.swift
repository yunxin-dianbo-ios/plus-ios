//
//  TSUserLabelCollectionView.swift
//  date
//
//  Created by Fiction on 2017/7/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 【选择标签】collectionView

import UIKit

protocol TSUserLabelCollectionViewDelegate: NSObjectProtocol {
    /// 返回savedataSource是否为空
    func dataSourceIsEmpty(isEmpty: Bool)
}

class TSUserLabelCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - 需要传入的数据
    /// 需要显示的标签（所有的）
    var userLabelDataSource: Array<TSCategoryTagModel> = []
    /// 需要保存（上传服务器的）标签
    var savedataSource: Array<TSCategoryIdTagModel> = []
    // MARK: - 代理
    /// 代理，判断右上角navgation按钮（下一步 or 跳过）
    weak var TSUserLabelCollectionViewDelegate: TSUserLabelCollectionViewDelegate? = nil
    // MARK: - 配置
    let ChooseQuantity: Int = 5

    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, data: Array<TSCategoryTagModel>, savedata: Array<TSCategoryIdTagModel>?) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.userLabelDataSource = data
        guard savedata != nil else {
            return
        }
        self.savedataSource = savedata!
        self.initialDataSource()
        setUI()
    }
    /// 初始数据处理，避免之前因为重用中还没有到显示位置而没有对数据进行配置处理，竟而因为点击已选中时因强制解析而崩溃
    fileprivate func initialDataSource() -> Void {
        if self.savedataSource.isEmpty {
            return
        }
        for savedTag in savedataSource {
            for (index, category) in userLabelDataSource.enumerated() {
                for (jndex, tagItem) in category.idTags!.enumerated() {
                    if savedTag.tagId == tagItem.tagId {
                        savedTag.isTouchedItem = IndexPath(row: jndex, section: index + 1)
                        tagItem.isTouch = true
                    }
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        self.backgroundColor = UIColor.clear
        self.dataSource = self
        self.delegate = self
        self.register(TSUserLabelCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.register(TSUserLabelCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        self.showsVerticalScrollIndicator = false
        self.reloadData()
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 1.单独区分计算numberOfItemsInSection
        // 2.返回代理，用户是否有选择标签数据
        if section == 0 {
            self.TSUserLabelCollectionViewDelegate?.dataSourceIsEmpty(isEmpty: savedataSource.isEmpty == true ? true : false)
            return savedataSource.count
        }
        let idModel = userLabelDataSource[section - 1]
        return (idModel.idTags?.count)!
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        /// 因为需要预留一个所以+1
        return userLabelDataSource.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TSUserLabelCollectionViewCell
        if indexPath.section == 0 {
            if savedataSource.isEmpty {
                return cell!
            } else {
                // 单独配置一个section的显示
                // 1.显示内容
                // 2.不显示有点击后的效果
                // 3.显示带有删除图标
                let model = savedataSource[indexPath.row]
                cell?.contentViewLabel.text = model.tagName
                cell?.isTouchItem(isTouch: false)
                cell?.deleteImageShow(isShow: true)
                cell?.indexPath = indexPath
                cell?.delegate = self
                return cell!
            }
        } else {
            let idModel = userLabelDataSource[indexPath.section - 1]
            let arry = idModel.idTags
            let idTagsModel = arry![indexPath.row]
            idTagsModel.isTouchedItem = indexPath
            // 判断如果有用户tags，修改对应的数据
            // 1.用户tags为空跳过
            // 2.给用户tag添加上indexPath(不然没发判断取消的是哪个item)
            // 3.给对应数据的isTouch修改为true（为了显示所有数据中已经选择的item）
            if !savedataSource.isEmpty {
                for item in savedataSource {
                    if item.tagId == idTagsModel.tagId {
                        item.isTouchedItem = indexPath
                        idTagsModel.isTouch = true
                    }
                }
            }
            cell?.contentViewLabel.text = idTagsModel.tagName
            cell?.isTouchItem(isTouch: idTagsModel.isTouch)
            cell?.deleteImageShow(isShow: false)
            cell?.delegate = self
            cell?.indexPath = indexPath
            return cell!
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! TSUserLabelCollectionReusableView
        if indexPath.section == 0 {
            let count = savedataSource.count
            headerView.setTitle(text: "显示_可以选择5个标签，已选择".localized + "\(count)" + "显示_个标签".localized)
        } else {
            let idModel = userLabelDataSource[indexPath.section - 1]
            headerView.setTitle(text: idModel.idName!)
        }
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        TSLogCenter.log.debug(self.savedataSource)
        if indexPath.section == 0 {
            // 根据savedataSource中的indexpath修改对应的userLabelDataSource。
            let chagedItem = savedataSource[indexPath.row]
            if let chagedIndexPath = chagedItem.isTouchedItem {
                // ↑ 获得indexpath
                let idModel = userLabelDataSource[chagedIndexPath.section - 1]
                let arry = idModel.idTags!
                let item = arry[chagedIndexPath.row]
                // ↑ 获得对应的itme
                item.isTouch = false
                // ↑ 修改itme
                self.savedataSource.remove(at: indexPath.row)
                self.reloadData()
            }
        } else {
            let idModel = userLabelDataSource[indexPath.section - 1]
            let arry = idModel.idTags!
            let item = arry[indexPath.row]
            // 屏蔽重复点击
            guard !item.isTouch else {
                return
            }
            // 限制用户选择数量
            if savedataSource.count < ChooseQuantity {
                item.isTouch = true
                self.savedataSource.append(item)
                self.reloadData()
            }
        }

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == userLabelDataSource.count {
            return CGSize(width: self.bounds.width, height: 20)
        }
        return CGSize(width: self.bounds.width, height: 0.01)
    }
}

// MARK: - TSUserLabelCollectionViewCellProtocol

extension TSUserLabelCollectionView: TSUserLabelCollectionViewCellProtocol {
    /// 用户标签cell上的删除按钮点击回调
    func didDeleteBtnClickInLabelCell(_ labelCell: TSUserLabelCollectionViewCell) {
        guard let indexPath = labelCell.indexPath else {
            return
        }
        /// 删除按钮只存在section==0，即已选择的地方
        if indexPath.section != 0 {
            return
        }
        self.collectionView(self, didSelectItemAt: indexPath)
    }
}
