//
//  TSUserLabelSetting.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 选择标签页面

import UIKit

/// 用户标签
enum TSUserLabelType {
    /// 创建圈子
    case group
    /// 注册
    case register
    /// 设置
    case setting
}

protocol TSUserLabelSettingProtocol: class {
    /// 标签更新
    func didLabelChanged(_ labels: [TSCategoryIdTagModel]) -> Void
}
extension TSUserLabelSettingProtocol {
    /// 标签更新
    func didLabelChanged(_ labels: [TSCategoryIdTagModel]) -> Void {
    }
}

class TSUserLabelSetting: TSViewController, TSUserLabelCollectionViewDelegate {
    /// cell个数
    let cellCount: CGFloat = 3.0
    /// cell高度
    let cellHight: CGFloat = 30.0
    /// 间距
    let spacing: CGFloat = 15.0

    /// 回调
    weak var delegate: TSUserLabelSettingProtocol?
    var labelChangedAction: ((_ labels: [TSCategoryIdTagModel]) -> Void)?

    var userLabelDataSource: Array<TSCategoryTagModel> = []
    var saveLabelDataSource: Array<TSCategoryIdTagModel> = []
    weak var userlabelCollectionView: TSUserLabelCollectionView!

    /// 当前用户标签列表，用于保存刚打开页面时用户的标签列表
    var currentUserLabelIdList: [Int] = [Int]()

    let type: TSUserLabelType

    init(type: TSUserLabelType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TSColor.main.white
        self.navigationItem.title = "标题_选择标签".localized

        switch self.type {
        case .register:
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(backItemClick))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "显示_跳过".localized, style: .plain, target: self, action: #selector(rightItemClick))
            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: TSColor.main.theme], for: .normal)
        case .setting:
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backItemClick))
        case .group:
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backItemClick))
        }
        // 请求数据
        self.isObtainData()

    }
    /// 获取服务器数据，数据是实时的。如果没有数据就不显示这个页面的功能
    func isObtainData() {
        var status = false
        var showMessage: String?
        self.loading(showBackButton: false)
        TSUserLabelNetworkManager().getAllTags { (tags, message, result) in
            if !result {
                showMessage = message!
                self.setUI(status: status, message: showMessage)
            } else {
                switch self.type {
                case .group:
                    status = true
                    self.userLabelDataSource = tags!
                    self.setUI(status: status, message: showMessage)

                case .register:
                    // 注册，无需请求用户标签，直接展示
                    status = true
                    self.userLabelDataSource = tags!
                    self.setUI(status: status, message: showMessage)
                case .setting:
                    // 设置，请求用户标签
                    TSUserLabelNetworkManager().getAuthUserTags(complete: { (models) in
                        guard models != nil else {
                            return
                        }
                        status = true
                        self.saveLabelDataSource = models!
                        self.userLabelDataSource = tags!
                        self.setUI(status: status, message: showMessage)
                        if let tagList = models {
                            var tagIdList: [Int] = [Int]()
                            for tag in tagList {
                                tagIdList.append(tag.tagId)
                            }
                            self.currentUserLabelIdList = tagIdList
                        }
                    })
                }
            }
        }
    }

    func setUI(status: Bool, message: String?) {
        self.navigationController?.navigationBar.isHidden = false
        guard status else {
            print(message!)
            self.loadFaild(type: .network)
            return
        }
        self.endLoading()
        setCollectionView(saveData: saveLabelDataSource, tagsData: userLabelDataSource)
        if self.type == .register {
            self.showPrompt()
        }
    }

    func setCollectionView(saveData: Array<TSCategoryIdTagModel>?, tagsData: Array<TSCategoryTagModel>) {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.size.width - spacing * 4) / 3
        layout.itemSize = CGSize(width: width, height: cellHight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.headerReferenceSize = CGSize(width: self.view.bounds.width - 30, height: 30)
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        let userlabelCollectionView = TSUserLabelCollectionView(frame: CGRect(x:  0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height), collectionViewLayout: layout, data: tagsData, savedata: saveData)
        userlabelCollectionView.TSUserLabelCollectionViewDelegate = self
        self.userlabelCollectionView = userlabelCollectionView
        self.view.addSubview(userlabelCollectionView)
    }

    /// 隐藏导航栏左边按钮
    func hiddenLeftButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationItem.hidesBackButton = true
    }

    /// 显示温馨提示
    func showPrompt() {
        let alert = TSAlertController(title: "温馨提示", message: "标签为全局标签，选择合适的标签，系统可推荐你感兴趣的内容，方便找到相同身份或爱好的人，很重要哦！", style: .alert)
        alert.addAction(TSAlertAction(title: "知道了", style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
    }

    // MARK: - 代理方法
    func dataSourceIsEmpty(isEmpty: Bool) {
        let title = isEmpty ? "显示_跳过".localized : "显示_下一步".localized
        self.navigationItem.rightBarButtonItem?.title = title
    }
    // MARK: - Private  事件响应

    /// 返回按钮点击响应
    @objc private func backItemClick() -> Void {
        switch self.type {
        case .group:
            let savedTagList: [TSCategoryIdTagModel] = self.userlabelCollectionView.savedataSource
            delegate?.didLabelChanged(savedTagList)
            labelChangedAction?(savedTagList)
            _ = navigationController?.popViewController(animated: true)
        case .register:
            break
        case .setting:
            // 请求设置
            let currentIdList: [Int] = self.currentUserLabelIdList
            let savedTagList: [TSCategoryIdTagModel] = self.userlabelCollectionView.savedataSource
            // 构造添加标签数组 和 删除标签数组
            var addTagIdList: [Int] = [Int]()
            var deleteTagIdList: [Int] = [Int]()
            if currentIdList.isEmpty && savedTagList.isEmpty {
                // 用户标签列表为空，选择标签列表为空
                _ = self.navigationController?.popViewController(animated: true)
                return
            } else if currentIdList.isEmpty && !savedTagList.isEmpty {
                // 用户标签列表为空，选择标签列表不为空
                for selectedTag in savedTagList {
                    addTagIdList.append(selectedTag.tagId)
                }
            } else if !currentIdList.isEmpty && savedTagList.isEmpty {
                // 用户标签列表不为空，选择标签列表为空
                for deleteTagId in currentIdList {
                    deleteTagIdList.append(deleteTagId)
                }
            } else {
                // 交叉
                // 1. 处理要删除的
                for currentId in currentIdList {
                    // 遍历当前选中列表，判断是否仍存在
                    var isExistFlag: Bool = false
                    for selectedTag in savedTagList {
                        if selectedTag.tagId == currentId {
                            isExistFlag = true
                            break
                        }
                    }
                    // 选中列表中不存在，则属于待删除的标签
                    if !isExistFlag {
                        deleteTagIdList.append(currentId)
                    }
                }
                // 2. 处理新添加的
                for selectedTag in savedTagList {
                    // 遍历当前用户的，判断是否是新添加的
                    var isNewFlag: Bool = true
                    for currentId in currentIdList {
                        if currentId == selectedTag.tagId {
                            isNewFlag = false
                            break
                        }
                    }
                    // 当前用户列表中不存在，则属于新添加的
                    if isNewFlag {
                        addTagIdList.append(selectedTag.tagId)
                    }
                }
            }
            // 标签设置请求
            self.userlabelCollectionView.isUserInteractionEnabled = false
            let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "标签设置中...")
            loadingAlert.show()
            TSUserLabelNetworkManager.setUserTags(addTags: addTagIdList, deleteTags: deleteTagIdList, complete: { [weak self](msg, status) in
                //self?.userlabelCollectionView.isUserInteractionEnabled = true
                loadingAlert.dismiss()
                if status {
                    _ = self?.navigationController?.popViewController(animated: true)
                    self?.delegate?.didLabelChanged(savedTagList)
                    self?.labelChangedAction?(savedTagList)
                } else {
                    let alert: TSIndicatorWindowTop = TSIndicatorWindowTop(state: .faild, title: "标签设置出错" + (msg ?? ""))
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                        _ = self?.navigationController?.popViewController(animated: true)
                        self?.delegate?.didLabelChanged(savedTagList)
                        self?.labelChangedAction?(savedTagList)
                    })
                }
            })
        }
    }
    /// 右侧按钮点击响应
    @objc fileprivate func rightItemClick() -> Void {
        switch self.type {
        case .group:
            break
        case .setting:
            break
        case .register:
            // 标签设置请求
            let savedTagList: [TSCategoryIdTagModel] = self.userlabelCollectionView.savedataSource
            var addTagIdList: [Int] = [Int]()
            if savedTagList.isEmpty {
                // 点击跳过，进入主页
                self.gotoTabbar()
            } else {
                // 点击下一步，开始设置
                for selectedTag in savedTagList {
                    addTagIdList.append(selectedTag.tagId)
                }
                // 标签设置请求
                self.userlabelCollectionView.isUserInteractionEnabled = false
                let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "标签设置中...")
                loadingAlert.show()
                TSUserLabelNetworkManager.setUserTags(addTags: addTagIdList, deleteTags: [], complete: { [weak self](msg, status) in
                    //self?.userlabelCollectionView.isUserInteractionEnabled = true
                    loadingAlert.dismiss()
                    if status {
                        self?.gotoTabbar()
                    } else {
                        let alert: TSIndicatorWindowTop = TSIndicatorWindowTop(state: .faild, title: "标签设置出错" + (msg ?? ""))
                        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                            self?.gotoTabbar()
                        })
                    }
                })
            }
        }
    }

    /// 注册时进入主页
    fileprivate func gotoTabbar() -> Void {
        // 注：需要判断当前导航控制器页(loginVC)是通过rootVC.present出来的，还是通过rootVC.change出来的
        if nil != self.presentingViewController {
            self.dismiss(animated: true, completion: nil)
            // 发送游客注册通知 - tabbar中刷新数据
            NotificationCenter.default.post(name: NSNotification.Name.Visitor.login, object: nil)
        } else {
            TSRootViewController.share.show(childViewController: .tabbar)
        }
    }

}
