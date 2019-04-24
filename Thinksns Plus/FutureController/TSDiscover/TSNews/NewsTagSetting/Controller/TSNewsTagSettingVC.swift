//
//  TSNewsTagSettingVC.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/9.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  资讯栏目编辑界面
//  资讯编辑界面作为资讯主控制器的子控制器存在

import UIKit

private struct TSNewsTagSettingVCUX {
    /// 顶部功能按钮区域的高度
    static let toolHeight: CGFloat = 44
    /// item的间距
    static let collectionItemSpace: CGFloat = 15
    /// item的宽度
    static let collectionItemWidth: CGFloat = (ScreenSize.ScreenWidth - (TSNewsTagSettingVCUX.collectionItemSpace * 5)) / 4
    /// item的高度
    static let collectionItemHeight: CGFloat = TSNewsTagSettingVCUX.collectionItemWidth * 0.4
    /// 功能按钮的宽度
    static let buttonWidth: CGFloat = 44
    /// 功能按钮的高度
    static let buttonHeight: CGFloat = TSNewsTagSettingVCUX.toolHeight
    /// 按钮之间的距离
    static let ButtonSpace: CGFloat = 10
}

private let makedIdentifier = "makeCell"
private let HeaderIndentifier = "header"

protocol TSNewsTagSettingVCDelegate: class {
    /// 完成修改
    func tagSettingVC(settingVC: TSNewsTagSettingVC, finishedModifyTags tags: TSNewsAllTagsModel)
}

class TSNewsTagSettingVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /// 主控制器 （传入这个主要是为了获取navigationBar的高度）
    weak var rootVC: UIViewController? = nil
    /// 记录视图展开的高度
    var viewMaxHeight: CGFloat = 0.0
    /// 代理
    weak var delegate: TSNewsTagSettingVCDelegate? = nil
    /*-------- UI相关 ---------*/
    /// 顶部提示语
    var hintLable: TSLabel? = nil
    /// 编辑开关
    var editableChangeButton: TSTextButton? = nil
    /// 收起视图按钮
    var closeButton: TSTextButton? = nil

    var conllectionView: UICollectionView? = nil
    /// 正在被拖动的item
    var dragingItem: TSNewsTagSettingCollectionViewCell? = nil
    /// 正在被拖动的item的IndexPath
    var dragingIndexPath: IndexPath? = nil
    /// 目标IndexPath
    var targetIndexPath: IndexPath? = nil
    /// 是否处于编辑状态
    var eidtEnable = false

    /*-------- 数据相关 ---------*/
    /// 已订阅
    var markedTags: [TSNewsTagObject] = []
    /// 未订阅
    var unmarkedTags: [TSNewsTagObject] = []

    init(WithRootViewController viewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.rootVC = viewController
        let navigationBarAndStatusBarHeight = (self.rootVC?.navigationController?.navigationBar.frame.height)! + 20
        self.viewMaxHeight = ScreenSize.ScreenHeight - navigationBarAndStatusBarHeight
        self.view.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: 1)
        /// 标记
        self.view.tag = 9_999
        self.view.clipsToBounds = true
        self.view.backgroundColor = TSColor.inconspicuous.background
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.layouBaseUI()
    }
    // MARK: - UI
    func layouBaseUI() {
        /// 按钮 - 收起视图
        self.closeButton = TSTextButton.initWith(putAreaType: .normal)
        self.closeButton?.frame = CGRect(x: ScreenSize.ScreenWidth - TSNewsTagSettingVCUX.buttonWidth - TSNewsTagSettingVCUX.collectionItemSpace, y: 0, width: TSNewsTagSettingVCUX.buttonWidth, height: TSNewsTagSettingVCUX.buttonHeight)
        self.closeButton?.setTitle("收起".localized, for: UIControlState.normal)
        self.closeButton?.addTarget(self, action: #selector(hiddenView), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.closeButton!)

        /// 按钮 - 编辑状态开关
        self.editableChangeButton = TSTextButton.initWith(putAreaType: .normal)
        self.editableChangeButton?.frame = CGRect(x: (self.closeButton?.frame.minX)! - TSNewsTagSettingVCUX.ButtonSpace - TSNewsTagSettingVCUX.buttonWidth, y: 0, width: TSNewsTagSettingVCUX.buttonWidth, height: TSNewsTagSettingVCUX.buttonHeight)
        self.editableChangeButton?.setTitle("编辑".localized, for: UIControlState.normal)
        self.editableChangeButton?.addTarget(self, action: #selector(changeEditStatus), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.editableChangeButton!)

        /// 提示语
        self.hintLable = TSLabel(frame: CGRect(x: TSNewsTagSettingVCUX.collectionItemSpace, y: 0, width: (self.editableChangeButton?.frame.minX)! - TSNewsTagSettingVCUX.collectionItemSpace, height: TSNewsTagSettingVCUX.toolHeight))
        self.hintLable?.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        self.hintLable?.text = "长按可编辑".localized
        self.view.addSubview(self.hintLable!)

        let collectionViewLayout = UICollectionViewFlowLayout()
        self.conllectionView = UICollectionView(frame: CGRect(x: 0, y: TSNewsTagSettingVCUX.toolHeight, width: ScreenSize.ScreenWidth, height: self.viewMaxHeight - TSNewsTagSettingVCUX.toolHeight), collectionViewLayout: collectionViewLayout)
        self.conllectionView?.backgroundColor = .white
        self.conllectionView?.collectionViewLayout = collectionViewLayout
        self.conllectionView?.delegate = self
        self.conllectionView?.dataSource = self
        /// 注册collection的cell
        self.conllectionView!.register(UINib(nibName: "TSNewsTagSettingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: makedIdentifier)
        /// 注册headerView
        self.conllectionView?.register(TSNewsTagSettingVCReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderIndentifier)

        /// 添加长按事件
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handlelongGesture(gesture:)))
        self.conllectionView?.addGestureRecognizer(longPress)

        self.view.addSubview(self.conllectionView!)

        /// 初始化跟随手指移动的视图
        self.dragingItem = Bundle.main.loadNibNamed("TSNewsTagSettingCollectionViewCell", owner: nil, options: nil)?.first as! TSNewsTagSettingCollectionViewCell?
        self.dragingItem?.frame = CGRect(x: 0, y: 0, width: TSNewsTagSettingVCUX.collectionItemWidth, height: TSNewsTagSettingVCUX.collectionItemHeight)
        self.dragingItem?.isHidden = true
        self.conllectionView?.addSubview(self.dragingItem!)

    }
// MARK: - UICollenctionViewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.markedTags.count
        default:
            return self.unmarkedTags.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderIndentifier, for: indexPath) as! TSNewsTagSettingVCReusableView
        if indexPath.section == 0 {
            headerView.setTitle(text: "我的订阅".localized)
        } else {
            headerView.setTitle(text: "更多订阅".localized)
        }
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: makedIdentifier, for: indexPath) as? TSNewsTagSettingCollectionViewCell)!
        cell.titleLabel.backgroundColor = TSColor.inconspicuous.background

        if indexPath.section == 0 {
            cell.updateData(title: self.markedTags[indexPath.row].name)
            cell.setEditEnable(canEdite: self.eidtEnable)
            if indexPath.row == 0 {
                cell.defaultTypeForFirstItem(isEdit: self.eidtEnable)
            }
        } else {
            cell.updateData(title: self.unmarkedTags[indexPath.row].name)
            cell.setEditEnable(canEdite: false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 && indexPath.section == 0 {
            return
        }

        if self.eidtEnable == false && indexPath.section == 0 {
            return
        }

        if self.eidtEnable == false && indexPath.section != 0 {
            self.eidtEnable = true
            self.setEditStyleUI()
            let time: TimeInterval = 0.05
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                //code
                let item = self.conllectionView?.cellForItem(at: indexPath) as! TSNewsTagSettingCollectionViewCell

                if indexPath.section == 0 {
                    let obj = self.markedTags[indexPath.row]
                    self.markedTags.remove(at: indexPath.row)
                    self.unmarkedTags.insert(obj, at: 0)
                    self.conllectionView?.moveItem(at: indexPath, to: IndexPath(row: 0, section: 1))
                    item.setEditEnable(canEdite: false)
                } else if indexPath.section == 1 {
                    let obj = self.unmarkedTags[indexPath.row]
                    self.unmarkedTags.remove(at: indexPath.row)
                    self.markedTags.append(obj)
                    self.conllectionView?.moveItem(at: indexPath, to: IndexPath(row: self.markedTags.count - 1, section: 0))
                    item.setEditEnable(canEdite: true)
                }
            }
            return
        }

        let item = self.conllectionView?.cellForItem(at: indexPath) as! TSNewsTagSettingCollectionViewCell

        if indexPath.section == 0 {
            let obj = self.markedTags[indexPath.row]
            self.markedTags.remove(at: indexPath.row)
            self.unmarkedTags.insert(obj, at: 0)
            self.conllectionView?.moveItem(at: indexPath, to: IndexPath(row: 0, section: 1))
            item.setEditEnable(canEdite: false)
        } else if indexPath.section == 1 {
            let obj = self.unmarkedTags[indexPath.row]
            self.unmarkedTags.remove(at: indexPath.row)
            self.markedTags.append(obj)
            self.conllectionView?.moveItem(at: indexPath, to: IndexPath(row: self.markedTags.count - 1, section: 0))
            item.setEditEnable(canEdite: true)
        }
    }

    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: TSNewsTagSettingVCUX.collectionItemWidth, height: TSNewsTagSettingVCUX.collectionItemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: TSNewsTagSettingVCUX.collectionItemSpace, left: TSNewsTagSettingVCUX.collectionItemSpace, bottom: TSNewsTagSettingVCUX.collectionItemSpace, right: TSNewsTagSettingVCUX.collectionItemSpace)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: ScreenSize.ScreenWidth, height: 40)
    }
// MARK: - Public

    func showView() {
        UIView.animate(withDuration: 0.4) {
            self.view.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: self.viewMaxHeight)
        }
    }

    func hiddenView() {
        UIView.animate(withDuration: 0.4, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: 0)
        }) { (_) in
            self.view.removeFromSuperview()
        }
    }
    func setDatas(data: TSNewsAllTagsModel) {
        self.markedTags = data.markedTags
        self.unmarkedTags = data.unmarkedTags
        self.conllectionView?.reloadData()
    }

// MARK: - Actions
    func handlelongGesture(gesture: UILongPressGestureRecognizer) {
        /// 长按进入编辑模式 （可移动、可删除与订阅）
        if self.eidtEnable == false {
            self.longPressChangeTheEditStatus()
            return
        }

        let point = gesture.location(in: self.conllectionView)
        switch gesture.state {
        case UIGestureRecognizerState.began:
            self.dragBegin(WithPoint: point)
            break
        case UIGestureRecognizerState.changed:
            self.dragChanged(WithPoint: point)
            break
        case UIGestureRecognizerState.ended:
            self.dragEnd()
            break
        default:
            print("other")
            break
        }
    }

    /// 点击编辑按钮改变编辑状态
    func changeEditStatus() {
        self.eidtEnable = !self.eidtEnable
        self.setEditStyleUI()
        if self.eidtEnable == false {
            TSNewsTaskManager().star(collectionTags: self.markedTags, unCollectionTags: self.unmarkedTags, complete: { (msg, status) in
                if status {
                    // 请求成功
                    if self.delegate != nil {
                        let model = TSNewsAllTagsModel()
                        model.markedTags = self.markedTags
                        model.unmarkedTags = self.unmarkedTags
                        self.delegate?.tagSettingVC(settingVC: self, finishedModifyTags: model)
                    }
                } else {
                    // 请求失败展示处理
                    let alert = TSIndicatorWindowTop(state: .faild, title: msg)
                    alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                }
            })
        }
    }

    /// 长按改变编辑状态
    func longPressChangeTheEditStatus() {
        self.eidtEnable = true
        self.setEditStyleUI()
    }

    func setEditStyleUI() {

        if self.eidtEnable {
            self.hintLable?.text = "点击可删除".localized
            self.editableChangeButton?.setTitle("完成".localized, for: UIControlState.normal)
        } else {
            self.hintLable?.text = "长按可编辑".localized
            self.editableChangeButton?.setTitle("编辑".localized, for: UIControlState.normal)
        }
        self.conllectionView?.reloadData()
    }
// MARK: - private

    /// 开始拖动
    ///
    /// - Parameter point: 开始拖动的位置
    func dragBegin(WithPoint point: CGPoint) {
        self.dragingIndexPath = self.getDragingIndexPath(WithPoint: point)
        if dragingIndexPath == nil {
            return
        }
        /// “推荐”栏目不可移动 不可删除订阅
        if dragingIndexPath?.row == 0 && dragingIndexPath?.section == 0 {
            return
        }

        self.conllectionView?.bringSubview(toFront: self.dragingItem!)
        let item = self.conllectionView?.cellForItem(at: self.dragingIndexPath!) as! TSNewsTagSettingCollectionViewCell
        item.setMoveStatus(isMoveing: true)
        self.dragingItem?.isHidden = false
        self.dragingItem?.frame = item.frame
        self.dragingItem?.setEditEnable(canEdite: true)
        self.dragingItem?.updateData(title: item.titleLabel.text!)
        self.dragingItem?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }

    /// 拖动中调用的方法
    ///
    /// - Parameter point: 长按手势当前移动到的位置
    func dragChanged(WithPoint point: CGPoint) {
        if self.dragingIndexPath == nil {
            return
        }
        self.dragingItem?.center = point
        self.targetIndexPath = self.getTargetIndexPath(WithPoint: point)
        if self.targetIndexPath != nil {
            self.rearrangementDataArray()
            self.conllectionView?.moveItem(at: self.dragingIndexPath!, to: self.targetIndexPath!)
            self.dragingIndexPath = self.targetIndexPath
        }
    }
    func dragEnd() {
        if self.dragingIndexPath == nil {
            return
        }
        let endFrame = self.conllectionView?.cellForItem(at: self.dragingIndexPath!)?.frame
        UIView.animate(withDuration: 0.3, animations: {
            self.dragingItem?.frame = endFrame!
        }) { (_) in
            self.dragingItem?.isHidden = true
            self.dragingItem?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            let item = self.conllectionView?.cellForItem(at: self.dragingIndexPath!) as! TSNewsTagSettingCollectionViewCell
            item.setMoveStatus(isMoveing: false)
        }
    }
// MARK: 工具方法
    /// 获取被拖动的Item的IndexPath
    ///
    /// - Parameter Point: 点的位置
    /// - Returns: IndexPath (可能为空)
    func getDragingIndexPath(WithPoint Point: CGPoint) -> IndexPath? {
        /// 订阅的只有一个不排序
        if self.conllectionView?.numberOfItems(inSection: 0) == 1 {
            return nil
        }
        for indexPath in (self.conllectionView?.indexPathsForVisibleItems)! {
            /// 未订阅的不参与排序
            if indexPath.section > 0 {
                continue
            }
            /// “推荐”栏目不参与排序
            if indexPath.section == 0 && indexPath.row == 0 {
                continue
            }
            /// 传入的点是否在collection的某个item上
            if (self.conllectionView?.cellForItem(at: indexPath)?.frame)!.contains(Point) {
                return indexPath
            }
        }
        return nil
    }

    /// 获取目标IndexPath
    ///
    /// - Parameter Point: 当前点坐标
    /// - Returns: IndexPath （可能为空）
    func getTargetIndexPath(WithPoint Point: CGPoint) -> IndexPath? {

        for indexPath in (self.conllectionView?.indexPathsForVisibleItems)! {
            /// 是自己就不排序
            if indexPath == self.dragingIndexPath {
                continue
            }
            /// 未订阅不排序
            if indexPath.section > 0 {
                continue
            }
            /// “推荐”栏目不参与排序
            if indexPath.section == 0 && indexPath.row == 0 {
                continue
            }
            /// 传入的点是否在collection的某个item上
            if (self.conllectionView?.cellForItem(at: indexPath)?.frame)!.contains(Point) {
                return indexPath
            }
        }
        return nil
    }

    /// 拖动完毕后对数组重新排序
    func rearrangementDataArray() {
        let obj = self.markedTags[(self.dragingIndexPath?.row)!]
        self.markedTags.remove(at: (self.dragingIndexPath?.row)!)
        self.markedTags.insert(obj, at: (self.targetIndexPath?.row)!)
    }

// MARK: - other
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
