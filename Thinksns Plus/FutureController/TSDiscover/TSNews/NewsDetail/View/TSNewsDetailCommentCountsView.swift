//
//  TSNewsDetailCommentCountsView.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

struct CommentCountsViewUX {
    /// 整个视图的高度 （可供外部访问）
    static let viewHeight: CGFloat = 50
    /// 视图顶部间距
    static let top: CGFloat = 5
    /// 文字距左间距
    static let left: CGFloat = 15

    static let blueLineHeight: CGFloat = 2
}

class DemoTableHeaderView: UITableViewHeaderFooterView {

    // MARK: - Internal Property
    static let headerHeight: CGFloat = 75
    static let identifier: String = "DemoTableHeaderViewReuseIdentifier"

    // MARK: - Internal Function

    class func headerInTableView(_ tableView: UITableView) -> DemoTableHeaderView {
        let identifier = self.identifier
        var headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if nil == headerFooterView {
            headerFooterView = DemoTableHeaderView(reuseIdentifier: identifier)
        }
        // 重置位置
        return headerFooterView as! DemoTableHeaderView
    }

    // MARK: - Private Property

    // MARK: - Initialize Function

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {

    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

}

class TSNewsDetailCommentCountsView: UITableViewHeaderFooterView {
    /// 灰色背景
    let grayView = UIView()
    /// 白色背景
    let whiteBGView = UIView()
    /// 文本
    let CountLabel = UILabel()
    /// 蓝色提示线
    let blueLine = UIView()
    /// 灰色分割线
    let grayLine = UIView()
    /// 标签视图
    var userInfoLabel: TSUserInfoLabel!
    /// 标签数据源
    var userInfoLabelDataSource: [String] = [] {
        didSet {
            if userInfoLabelDataSource.isEmpty {
                userInfoLabel.isHidden = true
            } else {
                userInfoLabel.isHidden = false
                userInfoLabel.setData(data: userInfoLabelDataSource)
            }
        }
    }
    // 布局管理器
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

    // MARK: - Internal Property
    static let identifier: String = "TSNewsDetailCommentCountsViewReuseIdentifier"

    // MARK: - Internal Function

    class func headerInTableView(_ tableView: UITableView) -> TSNewsDetailCommentCountsView {
        let identifier = self.identifier
        var headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if nil == headerFooterView {
            headerFooterView = TSNewsDetailCommentCountsView(reuseIdentifier: identifier)
        }
        // 重置位置
        return headerFooterView as! TSNewsDetailCommentCountsView
    }

    // MARK: - Initialize Function
    init() {
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        super.init(reuseIdentifier: nil)
    }
    override init(reuseIdentifier: String?) {
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        super.init(reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        self.contentView.backgroundColor = TSColor.main.white
        self.setUI()
    }

    // MARK: - UI
    func setUI() {
        self.grayView.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: 5)
        self.grayView.backgroundColor = TSColor.inconspicuous.background
        self.contentView.addSubview(self.grayView)
        self.whiteBGView.frame = CGRect(x: 0, y:self.grayView.bottom, width: ScreenSize.ScreenWidth, height: CommentCountsViewUX.viewHeight - CommentCountsViewUX.top)
        self.whiteBGView.backgroundColor = TSColor.main.white
        self.contentView.addSubview(self.whiteBGView)

        self.grayLine.frame = CGRect(x: 0, y: CommentCountsViewUX.viewHeight - 1, width: ScreenSize.ScreenWidth, height: 1)
        self.grayLine.backgroundColor = TSColor.inconspicuous.background
        self.contentView.addSubview(self.grayLine)

        self.CountLabel.frame = CGRect(x: CommentCountsViewUX.left, y: 0, width: ScreenSize.ScreenWidth - (CommentCountsViewUX.left * 2), height: self.whiteBGView.frame.height)
        self.CountLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.sectionTitle.rawValue)
        self.whiteBGView.addSubview(self.CountLabel)

        self.blueLine.frame = CGRect(x: CommentCountsViewUX.left - 5, y: CommentCountsViewUX.viewHeight - CommentCountsViewUX.blueLineHeight, width: 1, height: CommentCountsViewUX.blueLineHeight)
        self.blueLine.backgroundColor = TSColor.main.theme

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 0, right: 10)
        let userInfoLabel = TSUserInfoLabel(frame: CGRect.zero, collectionViewLayout: layout)
        self.userInfoLabel = userInfoLabel

        self.contentView.addSubview(userInfoLabel)
        self.contentView.addSubview(self.blueLine)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if userInfoLabelDataSource.isEmpty {
//            self.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: CommentCountsViewUX.viewHeight)
            self.contentView.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: CommentCountsViewUX.viewHeight)
        } else {
//            userInfoLabel.frame = CGRect(x: 0, y: self.blueLine.frame.maxY, width: ScreenSize.ScreenWidth, height: 50)
//            self.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: 50 + CommentCountsViewUX.viewHeight)
            // 上面为之前的方式，没有处理换行问题。
            // 注：请保留上面的注释代码，因为如果直接修改外界tableView里这里的布局高度，而这里不同步更改的话，会显示的是空白视图，而根本不知道原因在哪里。
            let height = TSUserInfoLabel.heightWithData(self.userInfoLabelDataSource, layout: self.layout)
            userInfoLabel.frame = CGRect(x: 0, y: self.blueLine.frame.maxY, width: ScreenSize.ScreenWidth, height: height)
//            self.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: height + CommentCountsViewUX.viewHeight)
            self.contentView.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: height + CommentCountsViewUX.viewHeight)
        }
    }

    // MARK: - public
    func uploadCount(CommentCount count: String) {
        let countText = "\(count)条评论"
        let textWidth = countText.sizeOfString(usingFont: self.CountLabel.font).width
        var frameBlue = self.blueLine.frame
        frameBlue.size.width = textWidth + 10
        self.blueLine.frame = frameBlue
        self.CountLabel.text = countText
    }

    func uploadString(_ string: String) {
        let countText = string
        let textWidth = countText.sizeOfString(usingFont: self.CountLabel.font).width
        var frameBlue = self.blueLine.frame
        frameBlue.size.width = textWidth + 10
        self.blueLine.frame = frameBlue
        self.CountLabel.text = countText
    }
}
