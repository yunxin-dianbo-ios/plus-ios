//
//  TSViewController.swift
//  Thinksns Plus
//
//  Created by lip on 2016/12/30.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  抽象类

import UIKit
import Kingfisher

struct TSViewRightCustomViewUX {
    /// 最大宽度 （有音乐图标时）
    static let MaxWidth: CGFloat = 75
    /// 最小宽度 （无音乐图标时）
    static let MinWidth: CGFloat = 44
    /// 高度
    static let Height: CGFloat = 44
}

struct PlaceHolder {
    static let nothing = PlaceHolder(image: #imageLiteral(resourceName: "IMG_img_default_nothing"))
    static let nobody = PlaceHolder(image: #imageLiteral(resourceName: "IMG_img_default_nobody"))
    static let delete = PlaceHolder(image: #imageLiteral(resourceName: "IMG_img_default_delete"))
    static let internet = PlaceHolder(image: #imageLiteral(resourceName: "IMG_img_default_internet"))
    static let search = PlaceHolder(image: #imageLiteral(resourceName: "IMG_img_default_search"))

    let image: UIImage
    let title: String
    init(image: UIImage, title: String = "") {
        self.image = image
        self.title = title
    }
}

class TSViewController: UIViewController {

    let placeHolderView: UIView = UIView(bgColor: TSColor.inconspicuous.background)

    /// 是否是第一显示的视图
    var isShowing: Bool = false
    /// 导航栏右边按钮的区域
    var rightButtonCunstomView: UIView? = nil
    /// 导航栏右边的按钮
    var rightButton: UIButton? = nil

    /// 动态被删除后的占位图
    let deletedOccupiedView = UIView(frame: UIScreen.main.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        addNotic()

        self.view.addSubview(placeHolderView)
        placeHolderView.isHidden = true
        placeHolderView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(0)
            make.leading.trailing.bottom.equalTo(self.view)
        }
    }

    deinit {
        removeNotic()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isShowing = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        isShowing = false
    }

    func showPlaceHolder(_ placeHolder: PlaceHolder, topMargin: CGFloat = 0) -> Void {
        self.placeHolderView.isHidden = false
        self.view.bringSubview(toFront: self.placeHolderView)
        self.placeHolderView.snp.updateConstraints { (make) in
            make.top.equalTo(self.view).offset(topMargin)
        }
        // PlaceHolderView应单独提取个控件出来
        let imageView = UIImageView(image: placeHolder.image)
        placeHolderView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalTo(self.placeHolderView)
        }
    }
    func hiddenPlaceHolder() -> Void {
        self.placeHolderView.isHidden = true
    }
}

extension TSViewController {
    fileprivate func customSetup() {
        view.backgroundColor = TSColor.inconspicuous.background
    }
}

/// 占位图相关
extension TSViewController {

    // 显示动态被删除后的占位图
    func showDeleteOccupiedView() {
        if deletedOccupiedView.superview == nil {
            deletedOccupiedView.backgroundColor = TSColor.inconspicuous.disabled
            // “内容被删除” 按钮
            let messageButton = TSButton(type: .custom)
            let faildImage = UIImage(named: "IMG_img_default_delete")!
            messageButton.frame = CGRect(x: (UIScreen.main.bounds.width - faildImage.size.width) / 2, y: (UIScreen.main.bounds.height - faildImage.size.height) / 2, width: faildImage.size.width, height: faildImage.size.height)
            messageButton.setImage(faildImage, for: .normal)
            // 返回按钮
            let backButton = TSImageButton(frame: CGRect(x: 0, y: 20, width: 0, height: 0))
            backButton.setImage(UIImage(named: "IMG_topbar_back"), for: .normal)
            backButton.addTarget(self, action: #selector(loadingBackButtonTaped), for: .touchUpInside)
            deletedOccupiedView.addSubview(messageButton)
            deletedOccupiedView.addSubview(backButton)
            view.addSubview(deletedOccupiedView)
            view.bringSubview(toFront: deletedOccupiedView)
        }
    }
}

// MARK: - LoadingViewDelegate: loading view 的代理事件
extension TSViewController: LoadingViewDelegate {

    // 点击了加载视图的重新加载按钮
    func reloadingButtonTaped() {
        fatalError("必须重写该方法,执行加载视图重点击新加载按钮的逻辑")
    }

    // 点击了加载视图的返回按钮
    func loadingBackButtonTaped() {
        navigationController?.popViewController(animated: true)
    }
}

/// 添加音乐入口点击的监听
extension TSViewController {

    func addNotic() {
        /// 音乐暂停后等待一段时间 视图自动消失的通知
        NotificationCenter.default.addObserver(self, selector: #selector(setRightCustomViewWidthMin), name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
    }

    func removeNotic() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
    }
}

/// 导航栏右边按钮相关
extension TSViewController {

    /// 设置右边按钮
    /// 增加导航栏右边按钮
    ///
    /// - Note: 在 viewWillAppear 和 viewDidLoad 各写一次，一共写两次
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - img: 图片
    func setRightButton(title: String?, img: UIImage?) {

        if self.navigationController == nil {
            return
        }

        if rightButtonCunstomView == nil {
            initRightCustom()
        }

        rightButton?.setImage(img, for: UIControlState.normal)
        rightButton?.setTitle(title, for: UIControlState.normal)

        setRightCustomViewWidth(Max: TSMusicPlayStatusView.shareView.isShow)
    }

    /// 初始化右边的按钮区域
    func initRightCustom() {
        self.rightButtonCunstomView = UIView()
        self.rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: TSViewRightCustomViewUX.MinWidth, height: 44))
        self.rightButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        self.rightButton?.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        self.rightButton?.addTarget(self, action: #selector(rightButtonClicked), for: UIControlEvents.touchUpInside)
        self.rightButton?.setTitleColor(TSColor.main.theme, for: UIControlState.normal)
        self.rightButton?.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.navigation.rawValue)
        self.rightButtonCunstomView?.addSubview(self.rightButton!)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightButtonCunstomView!)
    }

    /// 设置按钮标题颜色
    ///
    /// - Parameter color: 颜色
    func setRightButtonTextColor(color: UIColor) {
        self.rightButton?.setTitleColor(color, for: UIControlState.normal)
    }

    /// 设置按钮是否可以点击
    ///
    /// - Parameter enable: 是否可以点击
    func rightButtonEnable(enable: Bool) {
        self.rightButton?.isEnabled = enable
        self.rightButton?.setTitleColor(enable ? TSColor.main.theme : TSColor.normal.disabled, for: UIControlState.normal)
    }

    /// 设置按钮区域的宽度
    ///
    /// - Parameter Max: 是否是最大宽度
    func setRightCustomViewWidth(Max: Bool) {

        if isShowing == false {
            return
        }

        if self.rightButtonCunstomView == nil {
            return
        }

        let width = Max ? TSViewRightCustomViewUX.MaxWidth: TSViewRightCustomViewUX.MinWidth

        if self.rightButtonCunstomView?.frame.width == width {
            return
        }

        self.rightButtonCunstomView!.frame = CGRect(x: 0, y: 0, width: width, height: TSViewRightCustomViewUX.Height)
    }

    /// 设置为最小宽度 （用于音乐图标自动消失时重置宽度）
    func setRightCustomViewWidthMin() {
        setRightCustomViewWidth(Max: false)
    }

    /// 按钮点击方法
    func rightButtonClicked() {
        fatalError("请重写此方法实现右边按钮的点击事件")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageCache.default.clearMemoryCache()
    }
}

// MARK: - 导航栏
extension TSViewController {
    // 配置导航栏的文字按钮
    //
    // 快捷设置按钮,适合添加到导航栏
    func setupNavigationTitleItem(_ button: UIButton, title: String?) -> Void {
        let font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(TSColor.main.theme, for: .normal)
        button.titleLabel?.font = font
        button.setTitle(title, for: .normal)
        // Remark: - 关于这里的长度，应重新设计一下，特别是牵扯到右侧可能有音乐图标时
        // 音乐图标包括在内,导航栏右侧按钮做多只能出现3个
        if let size = title?.size(maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), font: font) {
            button.bounds = CGRect(x: 0, y: 0, width: size.width + 10, height: 44)
        } else {
            button.bounds = CGRect(x: 0, y: 0, width: TSViewRightCustomViewUX.MaxWidth, height: 44)
        }
    }
}
