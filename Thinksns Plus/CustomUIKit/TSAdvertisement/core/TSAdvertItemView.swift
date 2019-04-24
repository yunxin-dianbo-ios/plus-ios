//
//  TSAdvertItemView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/7/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  广告视图，此类仅负责对广告内容进行展示
//
//  使用方法：
//  1.直接使用
//  2.继承使用
//
//  注意：
//  不建议在此类中添加使用范围较小的方法或属性。

import UIKit
import Kingfisher

protocol TSAdvertItemViewDelegate: class {
    func item(view: TSAdvertItemView, didSelectedItemWithLink link: String?)
}

class TSAdvertItemView: UIView {

    /// 代理
    weak var itemDelegate: TSAdvertItemViewDelegate?

    /// 内容展示控件的 frame
    internal var _displayFrame: CGRect = .zero
    var displayFrame: CGRect {
        set(newValue) {
            _displayFrame = newValue
            // 更新子控件的 frame
            imageView.frame = newValue
            webView.frame = newValue
        }
        get {
            return _displayFrame
        }
    }

    /// model 数据
    internal var _itemModel: TSAdvertViewModel?
    var itemModel: TSAdvertViewModel? {
        set(newValue) {
            _itemModel = newValue
            set(model: newValue)
        }
        get {
            return _itemModel
        }
    }

    /// 图片广告
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    /// 图片
    internal var _image: UIImage?
    public var image: UIImage? {
        set(newValue) {
            _image = newValue
            set(image: newValue)
        }
        get {
            return _image
        }
    }

    /// 图片 URL
    internal var _imageURL: String?
    public var imageURL: String? {
        set(newValue) {
            _imageURL = newValue
            set(imageURL: newValue)
        }
        get {
            return _imageURL
        }
    }

    /// HTML 广告
    public let webView: UIWebView = {
        let web = UIWebView()
        return web
    }()

    /// HTML 字段
    internal var _htmlString: String?
    public var htmlString: String? {
        set(newValue) {
            _htmlString = newValue
            set(HTMLString: newValue)
        }
        get {
            return _htmlString
        }
    }

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 默认设置 display 的大小为 cell 的大小
        displayFrame = CGRect(origin: .zero, size: frame.size)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - UI
    internal func setUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(advertTaped))
        addGestureRecognizer(tap)

        TSLogCenter.log.debug("可以在子类，通过重写此方法，来添加其他控件")
    }

    /// 广告点击事件
    internal func advertTaped() {
        guard let delegate = itemDelegate else {
            TSAdvertTaskQueue.showDetailVC(urlString: itemModel?.link)
            return
        }
        delegate.item(view: self, didSelectedItemWithLink: itemModel?.link)
    }

    // MARK: - Public

    public func set(model: TSAdvertViewModel?) {
        _itemModel = model
        // 1.如果是图片类型的广告
        if model?.type == .image {
            // 如果有 image，就不加载 imageURL 了
            if model?.image != nil {
                image = model?.image
            } else {
                imageURL = model?.imageURL
            }
        }
        // 2.如果是 html 类型的广告
        // [长期注释] 暂时未返回 html 的数据
//        if model?.type == .html {
//            htmlString = model?.html
//        }
    }

}

extension TSAdvertItemView {

    // MARK: - 图片

    /// 设置 imageURL 的内容
    internal func set(imageURL: String?) {
        _imageURL = imageURL
        // 1.判断 imageURL 是否为 nil, 如果是，就移除图片视图
        guard let imageURL = imageURL else {
            if imageView.superview != nil {
                imageView.removeFromSuperview()
            }
            return
        }
        // 2.如果 imageURL 不为 nil, 就显示。

        imageView.kf.setImage(with: URL(string: imageURL))
        if imageView.superview == nil {
            insertSubview(imageView, at: 0)
            webView.removeFromSuperview()
        }
    }

    /// 设置图片内容
    ///
    /// - Note: 当 image 为 nil 时，将移除图片视图。
    ///
    /// - Parameter image: 图片
    internal func set(image: UIImage?) {
        _image = image
        // 1.判断 image 是否为 nil, 如果是，就移除图片视图
        guard let image = image else {
            if imageView.superview != nil {
                imageView.removeFromSuperview()
            }
            return
        }
        // 2.如果 image 不为 nil, 就显示。
        imageView.image = image
        if imageView.superview == nil {
            insertSubview(imageView, at: 0)
            webView.removeFromSuperview()
        }
    }

    // MARK: - HTML
    /// 设置 HTML 的内容
    ///
    /// - Note: 当 HTMLString 为 nil 时，将移除网页视图。
    ///
    /// - Parameter HTMLString: HTML 字段
    internal func set(HTMLString: String?) {
        _htmlString = HTMLString
        // 1.判断 HTML 字段是否为 nil, 如果是，就移除网页视图
        guard let htmlString = HTMLString else {
            if webView.superview != nil {
                webView.removeFromSuperview()
            }
            return
        }
        // 2.如果 HTML 字段不为 nil, 就加载。
        webView.loadHTMLString(htmlString, baseURL: nil)
        if webView.superview == nil {
            insertSubview(webView, at: 0)
            imageView.removeFromSuperview()
        }
    }

}
