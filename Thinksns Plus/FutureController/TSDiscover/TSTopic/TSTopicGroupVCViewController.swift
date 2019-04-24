//
//  TSTopicGroupVCViewController.swift
//  ThinkSNSPlus
//  descrebe  话题容器页
//  Created by IMAC on 2018/7/23.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import YYKit

class TSTopicGroupVCViewController: UIViewController, UIScrollViewDelegate {

    /// 导航栏右边视图
    let rightNavView = TopicNavRightView()
    var hotVC: TopicHotListVCViewController!
    var newVC: TopicNewListVC!
    /// 顶部选择分类背景视图
    var topBgView: UIView!
    let hotButton = UIButton(type: .custom)
    let newButton = UIButton(type: .custom)
    var grayLine: UIView!
    var blueLine: UIView!
    var bgScrollView: UIScrollView!

    var mark: NSInteger = 0
    var scrollViewLastContentOffset: CGFloat = 0

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        initBgScrollView()
        // Do any additional setup after loading the view.
    }

    // MARK: - UI
    func setUI() {
        title = "话题"
        // 2.1导航栏右边视图
        rightNavView.searchButton.addTarget(self, action: #selector(searchButtonTaped), for: .touchUpInside)
        rightNavView.buildButton.addTarget(self, action: #selector(buildButtonTaped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
        // 2.2 导航栏左侧按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "IMG_topbar_back"), style: .plain, target: self, action: #selector(backItemClick))

        topBgView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 120, height: 45))
        self.view.addSubview(topBgView)

        hotButton.frame = CGRect(x:topBgView.width / 4.0, y: 0, width: topBgView.width / 4.0, height: 43)
        hotButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        hotButton.setTitleColor(UIColor(hex: 0x333333), for: .selected)
        hotButton.setTitleColor(UIColor(hex: 0x999999), for: .normal)
        hotButton.setTitle("热门", for: .normal)
        hotButton.tag = 666
        hotButton.addTarget(self, action: #selector(hotOrNewButtonClick(sender:)), for: UIControlEvents.touchUpInside)

        newButton.frame = CGRect(x: topBgView.width / 2.0, y: 0, width: topBgView.width / 4.0, height: 43)
        newButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        newButton.setTitleColor(UIColor(hex: 0x333333), for: .selected)
        newButton.setTitleColor(UIColor(hex: 0x999999), for: .normal)
        newButton.setTitle("最新", for: .normal)
        newButton.tag = 999
        newButton.addTarget(self, action: #selector(hotOrNewButtonClick(sender:)), for: UIControlEvents.touchUpInside)

        blueLine = UIView(frame: CGRect(x: 0, y: 42, width: 36, height: 3))
        blueLine.backgroundColor = TSColor.main.theme
        blueLine.centerX = hotButton.centerX
        hotButton.isSelected = true
        newButton.isSelected = false

        topBgView.addSubview(hotButton)
        topBgView.addSubview(newButton)
        topBgView.addSubview(blueLine)

        navigationItem.titleView = topBgView
    }

    // MARK: - 创建 scrollview 背景视图
    func initBgScrollView() {
        // 顶部分割线
        let titleLine = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 1))
        titleLine.backgroundColor = TSColor.inconspicuous.highlight
        self.view.addSubview(titleLine)
        // 翻页内容
        bgScrollView = UIScrollView(frame: CGRect(x: 0, y: 1, width: ScreenWidth, height: ScreenHeight))
        bgScrollView.backgroundColor = UIColor.white
        bgScrollView.delegate = self
        bgScrollView.contentSize = CGSize(width: ScreenWidth * 2, height: 0)
        bgScrollView.isPagingEnabled = true
        bgScrollView.showsHorizontalScrollIndicator = false
        bgScrollView.isScrollEnabled = true
        self.view.addSubview(bgScrollView)
        creatSubVC()
    }

    // MARK: - 创建子视图
    func creatSubVC() {
        if mark == 0 {
            if hotVC == nil {
                hotVC = TopicHotListVCViewController()
                self.addChildViewController(hotVC)
                hotVC.didMove(toParentViewController: self)
                bgScrollView.addSubview(hotVC.view)
            }
        } else {
            if newVC == nil {
                newVC = TopicNewListVC()
                newVC.view.left = ScreenWidth
                self.addChildViewController(newVC)
                newVC.didMove(toParentViewController: self)
                bgScrollView.addSubview(newVC.view)
            }
        }
    }

    // MARK: - Action
    /// 点击了创建圈子按钮
    func buildButtonTaped() {
        // 游客触发登录
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }

        let creatVC = CreatTopicVC()
        self.navigationController?.pushViewController(creatVC, animated: true)
    }

    /// 点击了搜索按钮
    func searchButtonTaped() {
        // 游客触发登录
        if !TSCurrentUserInfo.share.isLogin {
            TSRootViewController.share.guestJoinLoginVC()
            return
        }
        let searchVC = TopicSearchVC.vc()
        navigationController?.pushViewController(searchVC, animated: true)
    }

    /// 点击了左侧返回按钮
    @objc fileprivate func backItemClick() -> Void {
        self.navigationController?.popViewController(animated: true)
    }

    func hotOrNewButtonClick(sender: UIButton) {
        blueLine.centerX = sender.centerX
        if sender.tag == 666 {
            hotButton.isSelected = true
            newButton.isSelected = false
            mark = 0
            bgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else {
            hotButton.isSelected = false
            newButton.isSelected = true
            mark = 1
            bgScrollView.setContentOffset(CGPoint(x: ScreenWidth, y: 0), animated: true)
        }
        creatSubVC()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewLastContentOffset = scrollView.contentOffset.x
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollViewLastContentOffset > scrollView.contentOffset.x {
            hotButton.isSelected = true
            newButton.isSelected = false
            blueLine.centerX = hotButton.centerX
            mark = 0
            creatSubVC()
        } else {
            hotButton.isSelected = false
            newButton.isSelected = true
            blueLine.centerX = newButton.centerX
            mark = 1
            creatSubVC()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
