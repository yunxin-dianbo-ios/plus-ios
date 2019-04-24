//
//  TSErrorTipActionsheetView.swift
//  Thinksns Plus
//
//  Created by 法正磊 on 2017/3/26.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  错误提示的脚视图
//  调用set方法，传入头，内容以及确定取消等等数组文字

import UIKit

class TSErrorTipActionsheetView: UIView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    typealias Datas = (Int) -> Void?
    /// 头视图字符串和边框的边距（单边）
    let headerTitleWithSuperViewOfLeftMargin: CGFloat = 30
    /// 提示内容的上边距
    let contentWithSuperViewOfTopMargin: CGFloat = 25
    /// 通用间距
    let allMargin: CGFloat = 15
    /// 分割线高度
    let cutLineHeight: CGFloat = 5
    /// 按钮们
    var buttons: [String]?
    /// 展示用的列表
    var actionSheetTableView: UITableView?
    /// 参数回调闭包
    var complete: Datas?

    /// MARK: - Life
    init() {
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// MARK: - 设置内容
    public func setWith(title: String, TitleContent: String, doneButtonTitle: [String], complete: @escaping (Int) -> Void) {
        self.complete = complete
        self.setBGView()
        buttons = doneButtonTitle
        self.actionSheetTableView = UITableView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 0), style: .plain)
        self.actionSheetTableView?.tableHeaderView = setHeaderView(headerTitle: title, headerContent: TitleContent)
        self.actionSheetTableView?.delegate = self
        self.actionSheetTableView?.dataSource = self
        actionSheetTableView?.isScrollEnabled = false
        self.actionSheetTableView?.register(UINib(nibName: "TSCustomActionsheetTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.addSubview(self.actionSheetTableView!)
        self.actionSheetTableView?.bounds.size = CGSize(width: UIScreen.main.bounds.size.width, height: (self.actionSheetTableView?.tableHeaderView?.bounds.size.height)! + CGFloat((buttons?.count)!) * 45.0)
        self.actionSheetTableView?.reloadData()
        showTableView()
    }

    /// 设置展示头视图
    ///
    /// - Parameters:
    ///   - headerTitle: 抬头
    ///   - headerContent: 内容
    /// - Returns: 返回头视图
    func setHeaderView(headerTitle: String, headerContent: String) -> UIView {
        let headerView = UIView()
        let width = UIScreen.main.bounds.size.width - headerTitleWithSuperViewOfLeftMargin * 2
        let headerTitleHeight = headerTitle.heightWithConstrainedWidth(width: width, height: CGFloat(MAXFLOAT), font: UIFont.systemFont(ofSize: TSFont.Button.navigation.rawValue)).height
        let headerContentHeight = headerContent.heightWithConstrainedWidth(width: width, height: CGFloat(MAXFLOAT), font: UIFont.systemFont(ofSize: TSFont.Button.navigation.rawValue)).height

        let titlelabel = UILabel(frame: CGRect(x: headerTitleWithSuperViewOfLeftMargin, y: contentWithSuperViewOfTopMargin, width: width, height: headerTitleHeight))
        titlelabel.text = headerTitle
        titlelabel.font = UIFont.systemMediumFont(ofSize: 16)
        titlelabel.numberOfLines = 0
        titlelabel.textAlignment = NSTextAlignment.center
        titlelabel.textColor = TSColor.normal.blackTitle
        headerView.addSubview(titlelabel)

        let contentLabel = UILabel(frame: CGRect(x: headerTitleWithSuperViewOfLeftMargin, y: titlelabel.frame.maxY + allMargin, width: width, height: headerContentHeight))
        contentLabel.text = headerContent
        contentLabel.numberOfLines = 0
        contentLabel.font = UIFont.systemFont(ofSize: TSFont.Button.navigation.rawValue)
        contentLabel.textAlignment = .center
        contentLabel.textColor = TSColor.normal.content
        headerView.addSubview(contentLabel)

        let lineView = UIView(frame: CGRect(x: 0, y: contentLabel.frame.maxY + contentWithSuperViewOfTopMargin, width: UIScreen.main.bounds.size.width, height: cutLineHeight))
        lineView.backgroundColor = TSColor.inconspicuous.background
        headerView.addSubview(lineView)

        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: contentWithSuperViewOfTopMargin * 2 + headerTitleHeight + allMargin + headerContentHeight + cutLineHeight)
        headerView.backgroundColor = UIColor.white

        return headerView
    }

    /// MARK: - tableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (buttons?.count)!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TSCustomActionsheetTableViewCell
        if (cell?.responds(to:#selector(setter: UIView.layoutMargins)))! {
            cell?.layoutMargins = UIEdgeInsets.zero
        }
        if (cell?.responds(to: #selector(setter: UITableViewCell.separatorInset)))! {
            cell?.separatorInset = UIEdgeInsets.zero
        }
        cell?.describeText = buttons?[indexPath.row]
        return cell!
    }

    /// MARK: - tableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row + 1 == buttons?.count {
            tapBg()
            return
        }
        self.complete!(indexPath.row)
        tapBg()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }

    /// 设置背景视图
    ///
    /// - Returns: 返回背景视图
    private func setBGView() {
        let window = UIApplication.shared.keyWindow
        self.frame = (window?.bounds)!
        self.backgroundColor = UIColor(hex: 0x000000, alpha: 0.0)
        window?.addSubview(self)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapBg))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }

    // MARK: - 设置点击位置
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchView = touch.view
        if  (touchView?.isEqual(self))! {
            return true
        } else {
            return false
        }
    }

    /// 显示
    func showTableView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundColor = TSColor.normal.transparentBackground
            self.actionSheetTableView?.frame.origin.y = UIScreen.main.bounds.height - (self.actionSheetTableView?.bounds.size.height)! - TSBottomSafeAreaHeight
        })
    }
    /// 点击背景视图
    func tapBg() {
        UIView.animate(withDuration: 0.2, animations: {
            // 消失
            self.backgroundColor = UIColor(hex: 0x000000, alpha: 0.0)
            self.actionSheetTableView?.frame.origin.y = UIScreen.main.bounds.height
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}
