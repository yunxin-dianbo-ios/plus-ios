//
//  TSNewsTagSelectController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 14/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  资讯标签选择界面
//  参考个人标签设置界面，区别就是点击响应
//  TSUserLabelCollectionView
//  注1：标签选择也需要提取出来
//  注2：注册时的标签选择、个人资料的标签修改  也使用该界面，兼容处理
//  注3：兼容失败，因后台问题不兼容统一处理。

import UIKit

protocol TSNewsTagSelectControllerProtocol: class {
    /// 返回按钮点击响应
    func didClickBackItem(selectedTagList: [TSTagModel]?) -> Void
}

/// 标签选择的类型
enum TSTagSelectType {
    /// 资讯投稿
    case newsContribute
    /// 用户注册
    case userRegister
    /// 用户个人资料设置
    case userSetting
}

class TSNewsTagSelectController: TSViewController {

    // MARK: - Internal Property
    /// 默认选中的标签列表
    let defaultTagList: [TSTagModel]?
    /// 标签选择的类型
    let type: TSTagSelectType
    /// 回调处理
    weak var delegate: TSNewsTagSelectControllerProtocol?
    var backItemClickAction: ((_ selectedTagList: [TSTagModel]?) -> Void)?

    // MARK: - Private Property
    fileprivate weak var collectionView: UICollectionView!
    fileprivate let cellIdentifier = "CollectionViewCellReuseIdentifier"
    fileprivate let headerIdentifier = "CollectionViewHeaderReuseIdentifier"
    /// item的间距
    fileprivate let itemSpace: CGFloat = 15
    /// 每一行item的个数
    fileprivate let itemCount: Int = 3
    /// item的宽度
    fileprivate var itemWidth: CGFloat {
        return (ScreenSize.ScreenWidth - self.itemSpace * 4.0) / CGFloat(itemCount)
    }
    /// item的高度
    fileprivate var itemHeight: CGFloat = 30
    /// 数据源
    // 展示列表
    fileprivate var sourceList: [TSTagCategoryModel] = [TSTagCategoryModel]()
    // 选中的标签列表，里面的数据模型都是选中状态的
    fileprivate var selectedTagList: [TSTagModel] = [TSTagModel]()
    fileprivate let maxSelectCount: Int = 5     // 最大选择数

    // MARK: - Initialize Function
    init(type: TSTagSelectType, defaultTagList: [TSTagModel]? = nil) {
        self.defaultTagList = defaultTagList
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        self.navigationItem.title = "标题_选择标签".localized
        switch self.type {
        case .newsContribute:
            fallthrough
        case .userSetting:
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backItemClick))
        case .userRegister:
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(backItemClick))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "显示_跳过".localized, style: .plain, target: self, action: #selector(rightItemClick))
        }
        // collectionView
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TSNewsTagSelectCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(TSNewsTagSelectReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.collectionView = collectionView
    }

    // MARK: - Private  数据处理与加载

    /// 数据加载
    private func initialDataSource() -> Void {
        self.sourceList.removeAll()
        // 网络请求
        TSNewsNetworkManager().getAllUserTags { [weak self](tagCategoryList, _, status) in
            guard status, let tagCategoryList = tagCategoryList else {
                self?.loadFaild(type: .network)
                return
            }
            // 数据加载
            self?.sourceList += tagCategoryList
            // 对默认数据进行处理
            self?.setupDefaultData()
            self?.collectionView.reloadData()
            // 显示提示
            if self?.type == .userRegister {
                self?.showPrompt()
            }
        }
    }
    /// 默认数据处理
    private func setupDefaultData() -> Void {
        guard let defaultTagList = self.defaultTagList else {
            return
        }
        self.selectedTagList.removeAll()
        // 根据defaultTagList构建selectedTagList，并对展示的数据列表中数据进行修改
        for defaultTag in defaultTagList {
            for tagCategory in self.sourceList {
                if defaultTag.categoryId != tagCategory.id {
                    continue
                }
                for tag in tagCategory.tags {
                    if tag.id != defaultTag.id {
                        continue
                    }
                    if self.selectedTagList.count < self.maxSelectCount {
                        tag.isSelected = true
                        self.selectedTagList.append(tag)
                    }
                }
            }
        }
    }
    /// 右侧按钮标题修正处理，主要是用户注册的时候
    fileprivate func rightItemProcess() -> Void {
        if self.type == .userRegister {
            let title = self.selectedTagList.isEmpty ? "显示_跳过".localized : "显示_完成".localized
            self.navigationItem.rightBarButtonItem?.title = title
        }
    }

    // MARK: - Private  事件响应

    /// 返回按钮点击响应
    @objc private func backItemClick() -> Void {
        if self.type != .userRegister {
            self.delegate?.didClickBackItem(selectedTagList: self.selectedTagList)
            self.backItemClickAction?(self.selectedTagList)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    /// 右侧按钮点击响应
    @objc fileprivate func rightItemClick() -> Void {
        // 用户注册相关的
        if self.type == .userRegister {
            // 1. 判断当前是否有选中的标签
            if self.selectedTagList.isEmpty {
                // 2. 当前未选择标签，则直接跳过，进入主页
                TSRootViewController.share.show(childViewController: .tabbar)
            } else {
                // 3. 当前选择的有标签，则设置标签，设置完成后再进入主页
                // 注：因后台问题，无法在这里进行统一设置。
            }
        }
    }

}

extension TSNewsTagSelectController {
    /// 显示温馨提示
    fileprivate func showPrompt() {
        let alert = TSAlertController(title: "温馨提示", message: "标签为全局标签，选择合适的标签，系统可推荐你感兴趣的内容，方便找到相同身份或爱好的人，很重要哦！", style: .alert)
        alert.addAction(TSAlertAction(title: "知道了", style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension TSNewsTagSelectController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sourceList.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if 0 == section {
            count = self.selectedTagList.count
        } else {
            let tagCategory = self.sourceList[section - 1]
            count = tagCategory.tags.count
        }

        return count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TSNewsTagSelectCell
        var tag: TSTagModel?
        if 0 == indexPath.section {
            cell.isRemovable = true
            tag = self.selectedTagList[indexPath.row]
            cell.isSelected = false
            cell.delegate = self
            cell.indexPath = indexPath
        } else {
            cell.isRemovable = false
            let tagCategory = self.sourceList[indexPath.section - 1]
            tag = tagCategory.tags[indexPath.row]
            cell.isSelected = tag!.isSelected
        }
        cell.title = tag!.name
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier, for: indexPath) as! TSNewsTagSelectReusableView
        if 0 == indexPath.section {
            headerView.title = "显示_可以选择5个标签，已选择".localized + "\(selectedTagList.count)" + "显示_个标签".localized
        } else {
            let tagCategory = self.sourceList[indexPath.section - 1]
            headerView.title = tagCategory.name
        }
        return headerView
    }
}

// MARK: - TSNewsTagSelectCellProtocol

extension TSNewsTagSelectController: TSNewsTagSelectCellProtocol {
    /// 标签Cell上的删除按钮点击回调
    func didDeleteBtnClickIn(tagCell: TSNewsTagSelectCell) {
        guard let indexPath = tagCell.indexPath else {
            return
        }
        if indexPath.section != 0 {
            return
        }
        self.collectionView(self.collectionView, didSelectItemAt: indexPath)
    }
}

// MARK: - UICollectionViewDelegate

extension TSNewsTagSelectController: UICollectionViewDelegate {
    /// cell选中处理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 取消默认选中效果
        collectionView.deselectItem(at: indexPath, animated: false)
        // 点击已选中部分 则取消选中
        if 0 == indexPath.section {
            // 已选中列表中的移除
            let cancelTag = self.selectedTagList.remove(at: indexPath.row)
            // 对展示数据源中的选中数据标记取消
            for tagCategory in self.sourceList {
                if cancelTag.categoryId != tagCategory.id {
                    continue
                }
                for tag in tagCategory.tags {
                    if cancelTag.id == tag.id {
                        // 标记取消
                        tag.isSelected = false
                        break
                    }
                }
            }
        }
        // 点击数据列表部分
        else {
            // 判断当前位置处的选中状态
            let tagCategory = self.sourceList[indexPath.section - 1]
            let currentTag = tagCategory.tags[indexPath.row]
            // 当前未选中 的选中处理
            if !currentTag.isSelected && self.selectedTagList.count < self.maxSelectCount {
                currentTag.isSelected = true
                self.selectedTagList.append(currentTag)
            }
        }
        self.rightItemProcess()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TSNewsTagSelectController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.itemWidth, height: self.itemHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.itemSpace, left: self.itemSpace, bottom: self.itemSpace, right: self.itemSpace)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var size = CGSize(width: ScreenSize.ScreenWidth, height: 20)
        if 0 == section {
            size = CGSize(width: ScreenSize.ScreenWidth, height: 30)
        }
        return size
    }
}
