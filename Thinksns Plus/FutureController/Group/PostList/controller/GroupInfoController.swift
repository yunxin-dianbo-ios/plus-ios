//
//  GroupInfoController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/13.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  圈子详情 视图控制器

import UIKit
import ObjectMapper

/// 圈子管理类型
enum GroupManagerType: String {
    /// 圈主，开放所有信息的设置权限
    case master = "圈主"
    /// 管理员，管理员只可修改简介与公告
    case manager = "管理员"
    /// 普通成员，只能看
    case member = "成员"
    /// 不是圈子的成员
    case unjoined = "未加入"
    /// 黑名单
    case black = "黑名单"
}

class GroupInfoController: GroupBasicController {

    /// 圈子
    var groupId = 0 {
        didSet {
            loadData()
        }
    }
    /// 修改圈子信息结束
    var finishChangeBlock: ((BuildGroupModel) -> Void)?

    /// 旧的圈子数据
    fileprivate var oldModel = BuildGroupModel()

    /// 管理类型
    fileprivate var managerType = GroupManagerType.member {
        didSet {
            changeControlPrivilege()
        }
    }
    /// 是否是首次进入初始化UI，如果是需要滚动到顶部
    /// 以为填充底部的公告等信息，会导致tableview的偏移量不正常
    /// 所有手动滚动到顶部
    fileprivate var shouldScrollToTop: Bool = true

    class func vc(managerType: GroupManagerType, groupId: Int) -> GroupInfoController {
        GroupBasicController.type = .groupInfo
        let sb = UIStoryboard(name: "GroupBasicController", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! GroupBasicController
        let subVC = vc as! GroupInfoController
        subVC.managerType = managerType
        subVC.groupId = groupId
        return subVC
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldScrollToTop {
            shouldScrollToTop = false
            tableView.scrollToTop()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loading()
        shouldScrollToTop = true
    }

    // MARK: - UI
    override func setUI() {
        super.setUI()
        title = "圈子详情"
        automaticallyAdjustsScrollViewInsets = false
        // 导航栏右方按钮
        rightButton.setTitle("保存", for: .normal)
        rightButton.sizeToFit()
        rightButton.addTarget(self, action: #selector(rightButtonTaped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.isEnabled = false
    }

    /// 根据 managerType 修改界面的对用户开放的设置权限
    ///
    /// - Note: 圈主，开放所有信息的设置权限；管理员，管理员只可修改简介与公告；普通成员，只能看
    func changeControlPrivilege() {
        // 1.根据管理类型，来设置控件的显示，和控件的操作权限
        switch managerType {
        case .master: // 开放所有权限
            coverMessage.text = "更改圈子头像"
        case .manager:
            // 禁用除了 简介 和 公告 的所有操作
            coverMessage.text = "圈子封面"
            nameLab.isHidden = false
            nameTextField.isHidden = true
            nameTextField.isUserInteractionEnabled = false
            cellUserInteraction = [Bool](repeating: false, count: 14)
            feedSwitch.isUserInteractionEnabled = false
            privateSwitch.isUserInteractionEnabled = false
            cellHeights[13] = 0
        case .member, .unjoined, .black:
            title = "详细信息"
            coverMessage.text = "圈子封面"
            // 隐藏占位文字
            noticeMessage.text = ""
            introMessage.text = ""
            // 隐藏导航栏右边按钮
            rightButton.isHidden = true
            nameLab.isHidden = false
            nameTextField.isHidden = true
            // 禁止普通成员的所有操作
//            tableView.isUserInteractionEnabled = false
            // 隐藏"同步至动态", "设置私密圈子"等可操作的 cell
            for index in 9...11 {
                cellHeights[index] = 0
            }
            justShowPayCountLab.text = ""
            cellHeights[13] = 0
            isJustShowInfo = false
            /// 隐藏所有的可编辑图标
            headerArrowIcon.isHidden = true
            userLabArrowIcon.isHidden = true
            locationArrowIcon.isHidden = true
            typeArrowIcon.isHidden = true
        }
    }

    /// 加载圈子数据
    func loadData() {
        GroupNetworkManager.getGroupInfo(groupId: groupId) { [weak self] (model, message, status) in
            guard let model = model else {
                self?.loadFaild(type: .network)
                return
            }
            self?.endLoading()
            let groupInfoModel = BuildGroupModel(groupModel: model)
            self?.oldModel = groupInfoModel
            self?.model = BuildGroupModel(groupModel: model)
            self?.load(model: groupInfoModel)
        }
    }

    // 将 model 的数据，加载
    func load(model: BuildGroupModel) {
        guard let localInfo = model.locationInfo else {
            return
        }
        // 1.设置封面图片
        coverImageView.kf.setImage(with: URL(string: model.coverImageUrl))
        // 2.设置圈子名称
        nameTextField.text = model.name
        nameLab.text = model.name
        // 3.设置分类标签
        set(categoryName: model.categoryName)
        // 4.设置圈子标签
        selectedTags = model.getTagModels()
        userInfoLabelCollectionView.setData(data: model.tagNames)
        // 5.设置位置信息
        switch localInfo {
        case .unshow:
            set(locationInfo: "不显示位置")
        case .location(let local, _, _, _):
            set(locationInfo: local)
        }
        // 6.设置简介
        introTextView.text = model.intro.count > 0 ? model.intro : "暂无简介"
        textViewDidBeginEditing(introTextView)
        textViewDidChange(introTextView)
        textViewDidEndEditing(introTextView)
        // 7.设置“同步动态”开关
        feedSwitch.isOn = model.allowFeed
        // 8.设置收费入圈等信息
        // 注：入圈权限只能缩小，不能放大。(开放——>私密，开放免费——>开放收费，但不能反着来)
        switch model.mode {
        case "private":
            privateSwitch.isOn = true
            chooseFreeButton.isSelected = true
            choosePaidButton.isSelected = false
            paidTextField.isHidden = true
            paidUnitLabel.isHidden = true
            if isJustShowInfo == false {
                justShowGroupPayTypeLab.textColor = TSColor.normal.minor
                justShowFeedSynLab.textColor = TSColor.normal.minor
                justShowGroupPayTypeLab.text = "私密圈子"
                justShowPayCountLab.text = "免费入圈"
                justShowPayCountLab.isHidden = false
                privateSwitch.isHidden = true
            }

        // 公开圈子——免费入圈：允许修正为私密圈子
        case "public":
            // 私有圈子——私密圈子：可以设置为付费
            privateSwitch.isOn = false
            privateSwitch.isEnabled = true
            if isJustShowInfo == false {
                justShowGroupPayTypeLab.text = "公开圈子"
                justShowGroupPayTypeLab.textColor = TSColor.normal.minor
                justShowFeedSynLab.textColor = TSColor.normal.minor
                justShowGroupPayTypeLab.isHidden = false
                justShowPayCountLab.isHidden = true
                privateSwitch.isHidden = true
            }
        // 收费圈子：不可设置
        case "paid":
            privateSwitch.isOn = true
            chooseFreeButton.isSelected = false
            choosePaidButton.isSelected = true
            paidTextField.isHidden = false
            paidUnitLabel.isHidden = false
            paidTextField.text = "\(model.money)"
            privateSwitch.isEnabled = false
            chooseFreeButton.isEnabled = false
            paidTextField.isEnabled = false
            if isJustShowInfo == false {
                justShowGroupPayTypeLab.text = "私密圈子"
                justShowGroupPayTypeLab.textColor = TSColor.normal.minor
                justShowFeedSynLab.textColor = TSColor.normal.minor
                justShowPayCountLab.text = "\(model.money) \(TSAppConfig.share.localInfo.goldName)"
                justShowPayCountLab.isHidden = false
                privateSwitch.isHidden = true
            }
        default:
            break
        }
        // 9.设置公告信息
        noticeTextView.text = model.notice.count > 0 ? model.notice : "暂无公告"
        textViewDidBeginEditing(noticeTextView)
        textViewDidChange(noticeTextView)
        textViewDidEndEditing(noticeTextView)
        // 刷新界面
        tableView.reloadData()
        tableView.scrollsToTop = true
    }

    // MARK: - Action

    /// 用户操作了界面
    override func userOperated() {
        // 对比旧数据，如果用户改变了，就让修改按钮可以点击
        rightButton.isEnabled = isUserChangeGroupInfo() && model.canBuildGroup()
    }

    /// 点击了修改按钮
    func rightButtonTaped() {
        view.endEditing(true)
        // 1.获取改变的数据模型
        let changeModel = ChangeGroupModel(oldModel: oldModel, newModel: model)
        // 2.获取定位数据
        var localInfo: (String, String, String, String)?
        if let locationInfo = changeModel.locationInfo {
            switch locationInfo {
            case .unshow:
                localInfo = ("", "", "", "")
            case .location(let location, let latitude, let longtitude, let geohash):
                localInfo = (location, latitude, longtitude, geohash)
            }
        } else {
            localInfo = ("", "", "", "")
        }
        // 3.发起网络请求
        let alert = TSIndicatorWindowTop(state: .loading, title: "修改中...")
        alert.show()
        GroupNetworkManager.changeGroup(groupId: groupId, cover: changeModel.coverImage, name: changeModel.name, tags: changeModel.tagIds, mode: changeModel.mode, intro: changeModel.intro, notice: changeModel.notice, money: changeModel.money, allowFeed: changeModel.allowFeed, locationInfo: localInfo) { [weak self] (message, status, groupDict) in
            alert.dismiss()
            let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: message)
            resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            guard let weakself = self, status else {
                return
            }
            // 更新详情页的信息
            // GroupModel
            let groupDictData: NSData! = try? JSONSerialization.data(withJSONObject: groupDict, options: []) as NSData!
            let groupDictJson = NSString(data:groupDictData as Data, encoding: String.Encoding.utf8.rawValue)
            let groupModel = Mapper<GroupModel>().map(JSONString: groupDictJson! as String)
            NotificationCenter.default.post(name: NSNotification.Name.Group.uploadGroupInfo, object: ["groupId": weakself.groupId, "type": "editGroupInfo", "groupModel": groupModel as? GroupModel])
            self?.finishChangeBlock?(weakself.model)
            self?.navigationController?.popViewController(animated: true)
        }
    }

    /// 判断用户是否更改了圈子数据
    func isUserChangeGroupInfo() -> Bool {
        if oldModel.name != model.name {
            return true
        }
        if oldModel.coverImage != model.coverImage {
            return true
        }
        if oldModel.categoryId != model.categoryId {
            return true
        }
        if Set(oldModel.tagIds) != Set(model.tagIds) {
            return true
        }
        if let oldLocal = oldModel.locationInfo, let newLocal = model.locationInfo, !oldLocal.isEqual(to: newLocal) {
            return true
        }
        if oldModel.intro != model.intro {
            return true
        }
        if oldModel.allowFeed != model.allowFeed {
            return true
        }
        if oldModel.mode != model.mode {
            return true
        }
        if oldModel.money != model.money {
            return true
        }
        if oldModel.notice != model.notice {
            return true
        }
        return false
    }

    // MARK: - <UITableViewDelegate>
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        view.endEditing(true)
        // 1.检查一下操作权限
        guard cellUserInteraction[indexPath.row] else {
            return
        }
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        var promptMsg: String = ""
        var isShowMsg: Bool = false
        switch oldModel.mode {
        // 私有圈子——私密圈子：不能再修正为私密圈子，但可修正为收费圈子
        case "private":
            switch cell {
            case groupTypeCell:
                isShowMsg = true
                promptMsg = "私有圈子不能改成公开圈子"
            case paidInfoCell:
                fallthrough
            case freeInfoCell:
                fallthrough
            default:
                super.tableView(tableView, didSelectRowAt: indexPath)
            }
        // 收费圈子：不可设置
        case "paid":
            switch cell {
            case groupTypeCell:
                isShowMsg = true
                promptMsg = "收费圈子不能改成公开或私有圈子"
            case paidInfoCell:
                break
            case freeInfoCell:
                isShowMsg = true
                promptMsg = "收费圈子不能改成公开或私有圈子"
            default:
                super.tableView(tableView, didSelectRowAt: indexPath)
            }
            break
            // 公开圈子——免费入圈：可任意设置
        case "public":
            fallthrough
        default:
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
        if isShowMsg {
            let alert = TSIndicatorWindowTop(state: .faild, title: promptMsg)
            alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
        }
    }

}

extension GroupInfoController: LoadingViewDelegate {

    // 点击了重新加载视图
    func reloadingButtonTaped() {
        loadData()
    }

    // 点击了返回按钮
    func loadingBackButtonTaped() {
        navigationController?.popViewController(animated: true)
    }
}

/// 这个类和 BuildGroupModel 的属性名是完全一样的，只是所有属性都是可选的，如果属性有值，表示该属性需要更改，为 nil 表示该属性不需要更改
class ChangeGroupModel {
    /// 封面图
    var coverImage: UIImage?
    /// 圈名
    var name: String?
    /// 分类
    var categoryId: Int?
    /// 分类名称
    var categoryName: String?
    /// 标签
    var tagIds: [Int]?
    /// 位置信息
    var locationInfo: BuildGroupModel.LocationInfo?
    /// 简介
    var intro: String?
    /// 同步到动态
    var allowFeed: Bool?
    /// 圈子类型
    var mode: String?
    /// 入圈付费积分金额，当 mode = "paid"
    var money: Int?
    /// 公告
    var notice: String?

    init() {
    }

    init(oldModel: BuildGroupModel, newModel model: BuildGroupModel) {
        if oldModel.name != model.name {
            name = model.name
        }
        if oldModel.coverImage != model.coverImage {
            coverImage = model.coverImage
        }
        if oldModel.categoryId != model.categoryId {
            categoryId = model.categoryId
        }
        if Set(oldModel.tagIds) != Set(model.tagIds) {
            tagIds = model.tagIds
        }
        if let oldLocal = oldModel.locationInfo, let newLocal = model.locationInfo, !oldLocal.isEqual(to: newLocal) {
            locationInfo = model.locationInfo
        } else {
            locationInfo = oldModel.locationInfo
        }
        if oldModel.intro != model.intro {
            intro = model.intro
        }
        if oldModel.allowFeed != model.allowFeed {
            allowFeed = model.allowFeed
        }
        if oldModel.mode != model.mode {
            mode = model.mode
        }
        if oldModel.money != model.money {
            money = model.money
        }
        if oldModel.notice != model.notice {
            notice = model.notice
        }
    }
}
