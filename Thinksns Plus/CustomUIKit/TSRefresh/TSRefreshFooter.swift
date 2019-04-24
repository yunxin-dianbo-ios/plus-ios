//
//  TSRefreshFooter.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  上拉加载更多 footer

import UIKit
import MJRefresh

class TSRefreshFooter: MJRefreshAutoFooter {
    var detailInfoLabel: UILabel!
    var imageView: UIImageView!
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .noMoreData:
                detailInfoLabel.textAlignment = .center
                detailInfoLabel.text = "提示信息_没有更多数据".localized
                detailInfoLabel.sizeToFit()
                imageView.isHidden = true
                imageView.stopAnimating()
                layoutIfNeeded()
            case .idle:
                detailInfoLabel.textAlignment = .center
                detailInfoLabel.text = "提示信息_上拉加载".localized
                detailInfoLabel.sizeToFit()
                imageView.isHidden = true
                imageView.stopAnimating()
                layoutIfNeeded()
            default:
                imageView.isHidden = false
                imageView.startAnimating()
                detailInfoLabel.textAlignment = .right
                detailInfoLabel.text = "提示信息_加载中".localized
                detailInfoLabel.sizeToFit()
                layoutIfNeeded()
            }
        }
    }

    // MARK: - Lifecycle
    override func prepare() {
        super.prepare()
        self.mj_h = 36

        let detailInfoLabel = UILabel(text: "提示信息_加载中".localized, font: UIFont.systemFont(ofSize: 12), textColor: UIColor(hex: 0xb3b3b3))
        addSubview(detailInfoLabel)
        self.detailInfoLabel = detailInfoLabel
        var images = [UIImage]()
        for index in 0...9 {
            let image = UIImage(named: "IMG_default_grey00\(index)")
            if let image = image {
                images.append(image)
            }
        }
        let imageView = UIImageView()
        imageView.animationImages = images
        imageView.animationDuration = Double(images.count) * 1.5 / 30
        imageView.animationRepeatCount = 0
        imageView.contentMode = .center
        imageView.startAnimating()
        addSubview(imageView)
        self.imageView = imageView
        self.backgroundColor = UIColor.white
        let noticeLabelTap = UITapGestureRecognizer(target: self, action: #selector(footerDidTap))
        addGestureRecognizer(noticeLabelTap)
    }

    override func placeSubviews() {
        super.placeSubviews()
        // 宽度是 自多宽度加上 动态图多宽度加上间距10
        detailInfoLabel.frame = CGRect(x: 0, y: 0, width: detailInfoLabel.frame.width + 25 + 10, height: detailInfoLabel.frame.height)
        detailInfoLabel.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 36 / 2)
        imageView.frame = CGRect(x: detailInfoLabel.frame.minX, y: (36 - 25) / 2, width: 25, height: 25)
    }
    func footerDidTap() {
        beginRefreshing()
    }
}

extension MJRefreshFooter {
    /// 网络异常
    func endRefreshingWithWeakNetwork() {
        endRefreshing()
    }
}
