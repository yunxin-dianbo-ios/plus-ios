//
//  QUStretchTableHeader.swift
//  Kingfisher
//
//  Created by GorCat on 2017/11/27.
//
//  具有拉伸效果的 table header 视图

import UIKit
import Kingfisher

// MARK: - header model
class StretchTableHeaderModel {

    /// 背景图显示效果
    enum BackgroudImageDisplay {
        /// 普通显示效果
        case none
        /// 毛玻璃效果
        case blur
    }

    /// 背景图片链接
    var backgroundUrl: String?
    /// 每次加载背景图片之前，是否需要清除图片缓存
    var shouldCleanCache = false
    /// 加载图片的占位图
    var placeholderImage: UIImage?

    /// 需要固定在 Header 底部的视图
    var fixedView: UIView?
    /// header 所在的 table 视图
    var tableView = UITableView()

    /// header 视图最小高度
    var headerHeightMin: CGFloat = 300
    /// 背景视图最小高度
    var bgHeightMin: CGFloat = 150
    /// 背景图显示效果
    var bgDisplay = BackgroudImageDisplay.none

    init() {
    }

    /// 初始化帖子列表的 header model
    init(postList: Any) {
    }

}

// MARK: - header
class StretchTableHeader: UIView {

    /// 数据模型
    var stretchModel = StretchTableHeaderModel()
    /// 固定视图的 tag
    let fixedViewTag = 1_343

    /// 高斯模糊视图
    lazy var blurView: UIVisualEffectView = {
        let blureffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blureffect)
        return blurView
    }()
    /// 背景视图
    var bgImageView = UIImageView()
    let topMaskView = UIImageView(image: UIImage(named: "pic_mask"))
    let bottomMaskView = UIImageView()

    init() {
        super.init(frame: .zero)
        if let image = UIImage(named: "pic_mask"), let cgImage = image.cgImage {
            let maskImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: UIImageOrientation.downMirrored)
            bottomMaskView.image = maskImage
        }
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    func setUI() {
        topMaskView.frame = CGRect(x: 0, y: -20, width: UIScreen.main.bounds.width, height: 44)
        bottomMaskView.frame = CGRect(x: 0, y: UIScreen.main.bounds.width / 2 - 44, width: UIScreen.main.bounds.width, height: 44)

        addSubview(bgImageView)
        addSubview(topMaskView)
        addSubview(bottomMaskView)
    }

    /// 加载背景视图
    func loadBgImageView() {
        // 1.更新显示设置
        bgImageView.frame = CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: stretchModel.bgHeightMin)
        bgImageView.backgroundColor = .gray
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.isUserInteractionEnabled = true
        bgImageView.clipsToBounds = true

        // 2.加载背景图片
        set(bgImageUrl: stretchModel.backgroundUrl, placeholderImage: stretchModel.placeholderImage, shouldCleanCache: stretchModel.shouldCleanCache)
    }

    /// 加载固定视图
    func loadFixedView() {
        // 1.获取旧的固定视图
        let oldFixedView = viewWithTag(fixedViewTag)
        // 2.如果新的固定视图不存在，仅移除
        guard let fixedView = stretchModel.fixedView else {
            oldFixedView?.removeFromSuperview()
            return
        }
        // 3.如果新的固定视图存在，且和旧的固定视图不相同，就更新固定视图
        if !(oldFixedView === fixedView) {
            oldFixedView?.removeFromSuperview()
            addSubview(fixedView)
        }
        // 4.刷新 fixedView 的位置
        fixedView.tag = fixedViewTag
        fixedView.frame = CGRect(origin: CGPoint(x: 0, y: stretchModel.bgHeightMin - fixedView.frame.size.height), size: fixedView.frame.size)
    }

    /// 加载特殊的效果
    func loadDisplay() {
        switch stretchModel.bgDisplay {
        case .none:
            blurView.removeFromSuperview()
        case .blur:
            blurView.frame = CGRect(origin: .zero, size: bgImageView.frame.size)
            if blurView.superview == nil {
                bgImageView.addSubview(blurView)
            }
        }
    }

    func loadTable() {
        frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: stretchModel.headerHeightMin))
        stretchModel.tableView.insertSubview(self, at: 0)
        stretchModel.tableView.contentInset = UIEdgeInsets(top: stretchModel.headerHeightMin, left: stretchModel.tableView.contentInset.left, bottom: stretchModel.tableView.contentInset.bottom, right: stretchModel.tableView.contentInset.right)
        if let feedListView = stretchModel.tableView as? FeedListView {
            feedListView.headerViewInsets = UIEdgeInsets(top:  -stretchModel.headerHeightMin + 64, left: 0, bottom: 0, right: 0)
        }
        if let feedListView = stretchModel.tableView as? GroupDetailRootTableView {
            feedListView.headerViewInsets = UIEdgeInsets(top:  -stretchModel.headerHeightMin + TSUserInterfacePrinciples.share.getTSNavigationBarHeight(), left: 0, bottom: 0, right: 0)
        }
    }

}

extension StretchTableHeader {

    /// 加载 header 视图的配置设置
    open func load(stretchModel: StretchTableHeaderModel) {
        self.stretchModel = stretchModel
        // 1.加载背景视图
        loadBgImageView()
        // 2.加载固定视图
        loadFixedView()
        // 3.加载特殊的效果
        loadDisplay()
        // 4.在 frame 更新后，加载 table 相关
        loadTable()

        // 更新 frame
        frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: stretchModel.headerHeightMin))
    }

    /// 设置背景视图
    open func set(backgroundImage: UIImage?) {
        bgImageView.image = backgroundImage
    }

    /// 设置(更换)背景图
    ///
    /// - Parameters:
    ///   - bgImageUrl: 背景图 url
    ///   - placeholderImage: 占位图
    ///   - shouldCleanCache: 是否需要清空 url 对应的图片的旧缓存
    open func set(bgImageUrl: String?, placeholderImage: UIImage?, shouldCleanCache: Bool = false) {
        guard let bgUrl = bgImageUrl else {
            bgImageView.image = placeholderImage
            return
        }
        if shouldCleanCache {
            ImageCache.default.removeImage(forKey: bgUrl)
        }
        bgImageView.kf.setImage(with: URL(string: bgUrl), placeholder: stretchModel.placeholderImage, options: nil, progressBlock: nil, completionHandler: nil)
    }

    /// 刷新子视图的 frame
    ///
    /// - Parameter offset: table 在 y 轴上的偏移量
    open func updateChildviews(tableOffset offset: CGFloat) {
        // 由于scrollView 向下拖拽的content
        let offset = -(stretchModel.headerHeightMin + offset)
        // 如果是向上拖动 返回.
        if offset < 0 {
            return
        }
        let orignalWidth = UIScreen.main.bounds.width
        // 1.更新 header 的 frame
        frame = CGRect(x: 0, y: -(stretchModel.headerHeightMin + offset), width: orignalWidth, height: stretchModel.headerHeightMin + offset)
        // 2.更新背景视图的 frame
        let bgWidth = (stretchModel.bgHeightMin + offset) * 2.5
        bgImageView.frame = CGRect(x: -(bgWidth - orignalWidth) / 2, y: 0, width: bgWidth, height: stretchModel.bgHeightMin + offset)
        bottomMaskView.frame = CGRect(x: 0, y:  bgImageView.frame.maxY - 44, width: UIScreen.main.bounds.width, height: 44)
        // 如果有高斯模糊层
        if stretchModel.bgDisplay == .blur {
            blurView.frame = bgImageView.bounds
        }
        // 3.更新固定视图的 frame
        if let fixedView = stretchModel.fixedView {
            stretchModel.fixedView?.frame = CGRect(origin: CGPoint(x: 0, y: frame.height - fixedView.frame.height), size: fixedView.frame.size)
        }
    }

}
