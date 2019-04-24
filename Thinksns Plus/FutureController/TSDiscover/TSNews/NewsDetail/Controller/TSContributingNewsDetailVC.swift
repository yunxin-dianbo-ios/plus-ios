//
//  TSContributingNewsDetailVC.swift
//  ThinkSNS +
//
//  Created by 小唐 on 09/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  投稿中的资讯详情界面
//  注：为了便于兼容正常的资讯详情页，使用资讯详情视图NewsDetailHeaderView代替之前的NewsDetailHeaderVC
/**
 注：投稿中的资讯详情页 与 正常的资讯详情页有很大却别：
 1. 没有底部工具栏；
 2. 没有列表(相关、广告、评论、标签)
 3. 仅头部资讯详情部分差不多，但又没有打赏相关的
 */

import Foundation
import UIKit

class TSContributingNewsDetailVC: TSViewController {
    // MARK: - Internal Property
    let newsId: Int
    // MARK: - Internal Function
    // MARK: - Private Property

    fileprivate weak var scrollView: UIScrollView!
    /// 资讯详情视图
    fileprivate weak var newsDetailView: TSNewsDetailView!
    /// 资讯详情
    fileprivate var newsDetail: NewsDetailModel?

    // MARK: - Initialize Function

    init(newsId: Int) {
        self.newsId = newsId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }

}

// MARK: - UI

extension TSContributingNewsDetailVC {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        self.view.backgroundColor = UIColor.white
        // 1. navigation bar
        self.navigationItem.title = "资讯详情"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backItemClick))
        // 2. scrollView
        let scrollView = UIScrollView()
        self.view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.scrollView = scrollView
        // 3. newsDetailView
        let newsDetailView = TSNewsDetailView(type: .contributing)
        scrollView.addSubview(newsDetailView)
        newsDetailView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.width.equalTo(ScreenWidth)
        }
        self.newsDetailView = newsDetailView
    }
}

// MARK: - 数据处理与加载

extension TSContributingNewsDetailVC {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        self.requestData(.initial)
    }
    /// 下拉刷新
    @objc fileprivate func refresh() -> Void {
        self.requestData(.refresh)
    }
    /// 请求数据
    fileprivate func requestData(_ type: TSListDataLoadType) -> Void {
        switch type {
        case .initial:
            self.loading()
            fallthrough
        case .refresh:
            // 请求详情页数据
            TSNewsNetworkManager().requesetNews(newsID: self.newsId) { [weak self](newsDetailModel, _, code) in
                if code == 404 {
                    self?.loadFaild(type: .delete)
                    return
                }
                guard let newsDetailModel = newsDetailModel else {
                    switch type {
                    case .initial:
                        self?.endLoading()
                        self?.loadFaild(type: .network)
                    case .refresh:
                        self?.scrollView.mj_header.endRefreshing()
                    default:
                        break
                    }
                    return
                }
                // 加载markdown
                self?.newsDetail = newsDetailModel
                self?.newsDetailView.loadModel(newsDetailModel, complete: { (_) in
                    switch type {
                    case .initial:
                        self?.endLoading()
                    case .refresh:
                        self?.scrollView.mj_header.endRefreshing()
                    default:
                        break
                    }
                })
            }
        default:
            break
        }
    }

}

// MARK: - 事件响应

extension TSContributingNewsDetailVC {
    @objc fileprivate func backItemClick() -> Void {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
}
