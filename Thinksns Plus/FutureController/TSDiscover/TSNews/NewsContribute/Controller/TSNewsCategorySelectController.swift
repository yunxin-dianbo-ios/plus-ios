//
//  TSNewsCategorySelectController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 14/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯栏目选择界面
//  参考资讯栏目订阅编辑界面，区别就是无需区分已订阅或未订阅

import UIKit

protocol TSNewsCategorySelectControllerProtocol: class {
    func didSelectCategory(_ category: TSNewsCategoryModel) -> Void
}

class TSNewsCategorySelectController: TSViewController {

    // MARK: - Internal Property
    /// 默认选中的id
    var selectedId: Int?
    /// 回调处理 
    weak var delegate: TSNewsCategorySelectControllerProtocol?
    var selectCategoryAction: ((_ category: TSNewsCategoryModel) -> Void)?

    // MARK: - Private Property
    fileprivate let identifier = "CollectionViewCellReuseIdentifier"
    fileprivate weak var collectionView: UICollectionView!
    /// item的间距
    fileprivate let itemSpace: CGFloat = 15
    /// item的宽度
    fileprivate var itemWidth: CGFloat {
        return (ScreenSize.ScreenWidth - self.itemSpace * 5.0) / 4.0
    }
    /// item的高度
    fileprivate var itemHeight: CGFloat = 30

    /// 数据源
    fileprivate var sourceList: [TSNewsCategoryModel] = [TSNewsCategoryModel]()

    // MARK: - Initialize Function
    // MARK: - Internal Function
    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }

    // MARK: - Private  UI

    private func initialUI() -> Void {
        self.view.backgroundColor = UIColor.white
        // navigation bar
        self.navigationItem.title = "标题_选择栏目".localized
        // collectionView
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        //collectionView.register(TSNewsTagSettingCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.register(UINib(nibName: "TSNewsTagSettingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: identifier)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.collectionView = collectionView

    }

    // MARK: - Private  数据处理与加载

    private func initialDataSource() -> Void {

        self.sourceList.removeAll()
        // 请求资讯栏目列表
        TSNewsNetworkManager().getAllNewsCategory { [weak self](subcribedList, unsubcribedList, _, status) in
            guard let weakSelf = self else {
                return
            }
            if status {
                if subcribedList != nil {
                    weakSelf.sourceList += subcribedList!
                }
                if unsubcribedList != nil {
                    weakSelf.sourceList += unsubcribedList!
                }
                weakSelf.collectionView.reloadData()
            } else {

            }
        }

    }

    // MARK: - Private  事件响应

    // MARK: - Delegate Function

    // MARK: - Notification
}

// MARK: - UICollectionViewDataSource

extension TSNewsCategorySelectController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sourceList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? TSNewsTagSettingCollectionViewCell)!
        cell.titleLabel.backgroundColor = TSColor.inconspicuous.background
        let category = self.sourceList[indexPath.row]
        cell.title = category.name
        // cell选中状态判断
        cell.isSelected = false
        if let selectedId = self.selectedId {
            if selectedId == category.id {
                cell.isSelected = true
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TSNewsCategorySelectController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = self.sourceList[indexPath.row]
        // 回调处理
        self.delegate?.didSelectCategory(category)
        self.selectCategoryAction?(category)
        _ = self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TSNewsCategorySelectController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.itemWidth, height: self.itemHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.itemSpace, left: self.itemSpace, bottom: self.itemSpace, right: self.itemSpace)
    }
}
