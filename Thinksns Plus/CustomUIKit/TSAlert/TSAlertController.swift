//
//  TSAlertController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 28/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  自定义的Alert弹窗，参考了UIAlertController
//  注1：该界面可以优化，将UI和数据加载分离开
//  注2：alert样式中的2个action时需要进一步判断，待完成
//  注3：一些极端情况的处理(title和message的存在、actions为空在各自style下)，待完成，
//  注4：关于动画的思考，待完成(1. 系统present没有问题；2.暂时使用present的false方式；3.自定义转场动画)

import Foundation
import UIKit

/// 弹窗响应类型
struct TSAlertActionStyle {
    //
    static var `default` = TSAlertActionStyle(titleColor: TSColor.main.content, titleFont: UIFont.systemFont(ofSize: 16))
    static var theme = TSAlertActionStyle(titleColor: TSColor.main.theme, titleFont: UIFont.systemFont(ofSize: 16))
    // destructive 毁灭性的
    static var destructive = TSAlertActionStyle(titleColor: UIColor.red, titleFont: UIFont.systemFont(ofSize: 16))
    static var alert = TSAlertActionStyle.theme
    static var actionsheet = TSAlertActionStyle.default

    var titleColor: UIColor
    var titleFont: UIFont
    init(titleColor: UIColor, titleFont: UIFont) {
        self.titleColor = titleColor
        self.titleFont = titleFont
    }
}
/// 弹窗响应
class TSAlertAction {

    var title: String
    /// titleStyle
    private(set) var style: TSAlertActionStyle
    private(set) var handler: ((_ action: TSAlertAction) -> Void)?

    init(title: String, style: TSAlertActionStyle, handler: ((_ action: TSAlertAction) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

/// 弹窗类型
enum TSAlertStyle {
    case alert
    case actionsheet
}

class TSAlertController: UIViewController {
    // MARK: - Internal Property
    private(set) var customTitle: String?
    private(set) var message: String?
    private(set) var style: TSAlertStyle
    private(set) var sheetCancelTitle: String  /// sheet-style下的默认取消选项的title

    private var _textFields: [UITextField]?
    open var textFields: [UITextField]? {
        return _textFields
    }

    /// 标记
    var tag: Int = 0

    // MARK: - Class Function

    // 删除的确认弹窗(即二次弹窗)，格式为 "删除XXX" + "取消" 2个选项
    class func deleteConfirmAlert(deleteActionTitle: String, deleteAction: @escaping (() -> Void)) -> TSAlertController {
        let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
        alertVC.addAction(TSAlertAction(title: deleteActionTitle, style: .destructive, handler: { (action) in
            deleteAction()
        }))
        return alertVC
    }

    // MARK: - Internal Function

    // 添加action
    func addAction(_ action: TSAlertAction) -> Void {
        self.actions.append(action)
    }

    // 添加 textField，目前仅支持 .alert 类型添加一个 textField，有其他需求请注意修改
    open func addTextField(configurationHandler: ((UITextField) -> Void)? = nil) {
        let _ = UIAlertController()
        if _textFields == nil {
            _textFields = []
        }
        let textField = UITextField()
        configurationHandler?(textField)
        _textFields?.append(textField)
    }

    // MARK: - Prvate Property
    fileprivate weak var alertView: UIView!
    fileprivate weak var sheetView: UIView!
    fileprivate weak var sheetTopView: UIView!
    fileprivate weak var sheetActionView: UIView!

    private(set) var actions: [TSAlertAction] = [TSAlertAction]()

    var actionsCount: Int {
        return actions.count
    }

    fileprivate let actionTagBase: Int = 250

    // MARK: - Initialize Function

    /// sheetCancelTitle，在actionSheet样式下的取消选项标题
    init(title: String?, message: String?, style: TSAlertStyle, sheetCancelTitle: String = "选择_取消".localized) {
        self.style = style
        self.customTitle = title
        self.message = message
        self.sheetCancelTitle = sheetCancelTitle
        super.init(nibName: nil, bundle: nil)
        // present后的透明展示
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }

    // MARK: - UI
    override func viewDidAppear(_ animated: Bool) {
        if let textFields = textFields {
            for item in textFields {
                if item is UITextField {
                    item.becomeFirstResponder()
                    return
                }
            }
        }
    }
    /// 页面布局
    fileprivate func initialUI() -> Void {
        self.view.backgroundColor = UIColor.clear
        // 1. cover
        let coverBtn = UIButton(type: .custom)
        self.view.addSubview(coverBtn)
        coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        coverBtn.addTarget(self, action: #selector(coverBtnClick(_:)), for: .touchUpInside)
        coverBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        // 2. alertView
        // 3. actionsheetView
        switch self.style {
        case .alert:
            self.initAlertView()
        case .actionsheet:
            self.initActionSheetView()
        }
        // 数据加载 与 UI 应分离出来，待完成

    }
    /// alert形式布局
    fileprivate func initAlertView() -> Void {
        let lrMargin: CGFloat = 25
        let tbMargin: CGFloat = 20
        let actionH: CGFloat = 50
        let alertView = UIView()
        self.view.addSubview(alertView)
        alertView.clipsToBounds = true
        alertView.layer.cornerRadius = 5
        alertView.backgroundColor = UIColor.white
        alertView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.view.centerY)
            make.leading.equalTo(self.view).offset(60)
            make.trailing.equalTo(self.view).offset(-60)
        }
        self.alertView = alertView
        // 1. topView - title
        let topView = UIView()
        alertView.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(alertView)
        }
        // 1.1 titleLabel
        let titleLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 16), textColor: TSColor.main.content, alignment: .center)
        titleLabel.numberOfLines = 2
        alertView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topView).offset(tbMargin)
            make.leading.equalTo(topView).offset(lrMargin)
            make.trailing.equalTo(topView).offset(-lrMargin)
            make.bottom.equalTo(topView).offset(-tbMargin)
        }
        // 2. separateLine
        let separateLine = UIView(bgColor: TSColor.normal.disabled)
        alertView.addSubview(separateLine)
        separateLine.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.height.equalTo(0.5)
            make.leading.equalTo(alertView).offset(lrMargin)
            make.trailing.equalTo(alertView).offset(-lrMargin)
        }
        // 3. contentView - message
        let contentView = UIView()
        alertView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(separateLine.snp.bottom)
            make.leading.trailing.equalTo(alertView)
        }
        // 3.1 contentLabel
        let messageLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: TSColor.normal.content, alignment: .center)
        contentView.addSubview(messageLabel)
        messageLabel.numberOfLines = 3
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(tbMargin)
            make.bottom.equalTo(contentView).offset(-tbMargin)
            make.leading.equalTo(contentView).offset(lrMargin)
            make.trailing.equalTo(contentView).offset(-lrMargin)
        }
        // 3.2 textFilds view
        let textFiledsView = UIView()
        alertView.addSubview(textFiledsView)
        textFiledsView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(contentView)
            make.top.equalTo(contentView.snp.bottom)
        }
        // 3. bottom - action
        let bottomView = UIView()
        alertView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(alertView)
            make.top.equalTo(textFiledsView.snp.bottom)
        }

        // 加载数据
        titleLabel.text = self.customTitle
        messageLabel.text = self.message
        // 判断title 和 messge 没有时的情况处理(分别没有、都没有)，待完成
        if nil == self.customTitle || self.customTitle!.isEmpty {
            titleLabel.snp.updateConstraints({ (make) in
                make.top.equalTo(topView).offset(0)
                make.bottom.equalTo(topView).offset(0)
            })
            separateLine.isHidden = true
        }
        if nil == self.message || self.message!.isEmpty {
            messageLabel.snp.updateConstraints({ (make) in
                make.top.equalTo(contentView).offset(0)
                make.bottom.equalTo(contentView).offset(0)
            })
        }
        // 加载 textField
        if let textFields = textFields {
            for (index, textField) in textFields.enumerated() {
                textField.font = UIFont.systemFont(ofSize: 14)
                textField.textAlignment = .center
                textField.borderStyle = .roundedRect
                textFiledsView.addSubview(textField)
                textField.snp.makeConstraints({ (make) in
                    make.leading.equalTo(textFiledsView).offset(lrMargin)
                    make.trailing.equalTo(textFiledsView).offset(-lrMargin)
                    make.height.equalTo(35)
                    make.top.equalTo(textFiledsView).offset(CGFloat(index) * 35 + 30)
                    if index == textFields.count - 1 {
                        make.bottom.equalTo(textFiledsView).offset(-30)
                    }
                })
            }
        }
        // 加载action
        if self.actions.isEmpty {
            return
        }
        bottomView.addLineWithSide(.inTop, color: TSColor.normal.disabled, thickness: 0.5, margin1: lrMargin, margin2: lrMargin)
        // 注：如果3个action则3行展示；如果两个则应判断字数再确定是单行两列还是两行展示
        // 判断是否是单行展示
        var isSingleShow: Bool = true
        if self.actions.count == 2 {
            // 注：目前不作判断处理，作为单行两列展示，判断文字长度之后待完成
            isSingleShow = false
        }
        if isSingleShow {
            // 单行展示
            for (index, action) in actions.enumerated() {
                let button = UIButton(type: .custom)
                bottomView.addSubview(button)
                button.titleLabel?.font = action.style.titleFont
                button.setTitle(action.title, for: .normal)
                button.setTitleColor(action.style.titleColor, for: .normal)
                button.tag = actionTagBase + index
                button.addTarget(self, action: #selector(actionBtnClick(_:)), for: .touchUpInside)
                button.snp.makeConstraints({ (make) in
                    make.leading.trailing.equalTo(bottomView)
                    make.height.equalTo(actionH)
                    make.top.equalTo(bottomView).offset(CGFloat(index) * actionH)
                    if index == actions.count - 1 {
                        make.bottom.equalTo(bottomView)
                    }
                })
                if index != actions.count - 1 {
                    button.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
                }
            }
        } else {
            // 单行两列展示
            for (index, action) in actions.enumerated() {
                let button = UIButton(type: .custom)
                bottomView.addSubview(button)
                button.titleLabel?.font = action.style.titleFont
                button.setTitle(action.title, for: .normal)
                button.setTitleColor(action.style.titleColor, for: .normal)
                button.tag = actionTagBase + index
                button.addTarget(self, action: #selector(actionBtnClick(_:)), for: .touchUpInside)
                button.snp.makeConstraints({ (make) in
                    make.height.equalTo(actionH)
                    make.top.bottom.equalTo(bottomView)
                    if 0 == index {
                        make.leading.equalTo(bottomView)
                        make.trailing.equalTo(bottomView.snp.centerX)
                    } else if index == actions.count - 1 {
                        make.leading.equalTo(bottomView.snp.centerX)
                        make.trailing.equalTo(bottomView)
                    }
                })
//                if 0 == index {
//                    button.addLineWithSide(.inRight, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
//                }
            }
        }

    }
    /// actionShee形式布局
    fileprivate func initActionSheetView() -> Void {

        let lrMargin: CGFloat = 25
        let tbMargin: CGFloat = 25
        let titleMsgMargin: CGFloat = 15

        let actionH: CGFloat = 45
        let verMargin: CGFloat = 5
        let sheetView = UIView()
        self.view.addSubview(sheetView)
        sheetView.backgroundColor = TSColor.inconspicuous.background
        sheetView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(self.view)
        }
        self.sheetView = sheetView
        // 1. actionView，含追加的cancelAction
        let actionView = UIView()
        sheetView.addSubview(actionView)
        actionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(sheetView)
            make.bottom.equalTo(sheetView).offset(-TSBottomSafeAreaHeight)
        }
        self.sheetActionView = actionView
        // 2. topView
        let topView = UIView(bgColor: UIColor.white)
        sheetView.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(sheetView)
            make.bottom.equalTo(actionView.snp.top).offset(-verMargin)
        }
        self.sheetTopView = topView
        // 2.1 titleLabel
        let titleLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 16), textColor: TSColor.main.content, alignment: .center)
        titleLabel.numberOfLines = 2
        topView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topView).offset(tbMargin)
            make.leading.equalTo(topView).offset(lrMargin)
            make.trailing.equalTo(topView).offset(-lrMargin)
        }
        // 2.2 messageLabel
        let messageLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: TSColor.normal.minor, alignment: .center)
        topView.addSubview(messageLabel)
        messageLabel.numberOfLines = 3
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(titleMsgMargin)
            make.bottom.equalTo(topView).offset(-tbMargin)
            make.leading.equalTo(topView).offset(lrMargin)
            make.trailing.equalTo(topView).offset(-lrMargin)
        }

        // 数据加载 - 可考虑将数据加载分离出来
        titleLabel.text = self.customTitle
        messageLabel.text = self.message
        // 判断title和message是否存在，暂仅处理都不存在的情况
        var isShowTop: Bool = true
        if (nil == self.customTitle || self.customTitle!.isEmpty) && (nil == self.message || self.message!.isEmpty) {
            isShowTop = false
            topView.removeAllSubViews()
            topView.snp.remakeConstraints({ (make) in
                make.bottom.equalTo(actionView.snp.top).offset(0)
                make.top.leading.trailing.equalTo(sheetView)
            })
        }
        topView.isHidden = !isShowTop

        // cancel
        let cancelBtn = UIButton(type: .custom)
        actionView.addSubview(cancelBtn)
        cancelBtn.setTitle(self.sheetCancelTitle, for: .normal)
        cancelBtn.titleLabel?.font = TSAlertActionStyle.default.titleFont
        cancelBtn.backgroundColor = UIColor.white
        cancelBtn.setTitleColor(TSAlertActionStyle.default.titleColor, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick(_:)), for: .touchUpInside)
        cancelBtn.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(actionView)
            make.height.equalTo(actionH)
        }
        // actionsView，不含追加的cancelAction
        let actionsView = UIView(bgColor: UIColor.white)
        actionView.addSubview(actionsView)
        actionsView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(actionView)
            if isShowTop {
                // 展示顶部，actions和追加的取消一起展示(无间隔)
                make.bottom.equalTo(cancelBtn.snp.top)
                cancelBtn.addLineWithSide(.inTop, color: TSColor.normal.background, thickness: 0.5, margin1: 0, margin2: 0)
            } else {
                // 不展示顶部，actions和追加的取消分开展示(有间隔)
                make.bottom.equalTo(cancelBtn.snp.top).offset(-verMargin)
            }
        }
        // 根据actions构造actionsView
        for (index, action) in self.actions.enumerated() {
            let button = UIButton(type: .custom)
            actionsView.addSubview(button)
            button.titleLabel?.font = action.style.titleFont
            button.setTitle(action.title, for: .normal)
            button.setTitleColor(action.style.titleColor, for: .normal)
            button.tag = actionTagBase + index
            button.addTarget(self, action: #selector(actionBtnClick(_:)), for: .touchUpInside)
            button.snp.makeConstraints({ (make) in
                make.leading.trailing.equalTo(actionsView)
                make.height.equalTo(actionH)
                make.top.equalTo(actionsView).offset(CGFloat(index) * actionH)
                if index == actions.count - 1 {
                    make.bottom.equalTo(actionsView)
                }
            })
            if index != actions.count - 1 {
                button.addLineWithSide(.inBottom, color: TSColor.normal.background, thickness: 0.5, margin1: 0, margin2: 0)
            }
        }

    }

    // MARK: - 数据处理与加载

    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {

    }

    // MARK: - 事件响应

    /// 遮罩点击响应
    @objc fileprivate func coverBtnClick(_ button: UIButton) -> Void {
        /// 兼容直接加载到presentationController的情况
        if parent != nil {
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }

    /// 按钮点击响应
    @objc fileprivate func actionBtnClick(_ button: UIButton) -> Void {
        let index = button.tag - self.actionTagBase
        let action = self.actions[index]
        /// 兼容直接加载到ParentViewController的情况
        if parent != nil {
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            action.handler?(action)
        } else {
            self.dismiss(animated: false, completion: {
                action.handler?(action)
            })
        }
    }
    @objc fileprivate func cancelBtnClick(_ button: UIButton) -> Void {
        /// 兼容直接加载到ParentViewController的情况
        if parent != nil {
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    // 处理弹窗遮挡问题
    func keyboardWillShow(noti: Notification) {
        let userInfo = noti.userInfo! as NSDictionary
        let keyboardRect = userInfo["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        self.alertView.snp.remakeConstraints { (make) in
            // alertView底部距键盘顶部的间隔
            let bottomSpaceHeight = keyboardRect.height + 25
            let centerYOffset = (ScreenHeight / 2.0 - bottomSpaceHeight - self.alertView.height / 2.0)
            make.centerY.equalTo(self.view).offset(centerYOffset)
            make.leading.equalTo(self.view).offset(60)
            make.trailing.equalTo(self.view).offset(-60)
        }
    }
}
