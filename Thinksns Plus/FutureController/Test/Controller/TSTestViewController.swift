//
//  TSTestViewController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 21/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  测试使用
//  建议：1.从发现页进入 2.从appdelegate里直接进入

import UIKit
import ActiveLabel

class TSTestViewController: UIViewController {

    fileprivate var time: Int = 0

    fileprivate weak var activeLabel: ActiveLabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialUI()
        self.initialDataSource()
    }

    fileprivate func initialUI() -> Void {
        let titleView = TSTitleSelectControl(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        self.navigationItem.titleView = titleView
        titleView.title = "Hello"
        titleView.backgroundColor = UIColor.green
        titleView.addTarget(self, action: #selector(titleClick(_:)), for: .touchUpInside)
        self.view.backgroundColor = UIColor.lightGray

        //
        let testView = UIView()
        self.view.addSubview(testView)
        testView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.view)
            make.height.equalTo(250)
        }
        self.initialTestView(testView)
    }

    fileprivate func initialTestView(_ testView: UIView) -> Void {
        testView.backgroundColor = UIColor.yellow

        let activieLabel = ActiveLabel()
        testView.addSubview(activieLabel)
        activieLabel.numberOfLines = 3
        activieLabel.textColor = TSColor.main.content
        activieLabel.font = UIFont.systemFont(ofSize: 14)
//        activieLabel.backgroundColor = UIColor.green
        activieLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(testView).offset(15)
            make.trailing.equalTo(testView).offset(-15)
            make.top.equalTo(testView).offset(15)
        }
        self.activeLabel = activieLabel

    }

    func initialDataSource() -> Void {
        self.activeLabel.shouldAddFuzzyString = false
        self.activeLabel.attributedText = NSAttributedString(string: "你是一个城")
        self.activeLabel.sizeToFit()
    }

    func test1() -> Void {
        //let sampleVC = TSWebEditorSampleController()
        //let sampleVC = TSWebEditorChildSampleController()

        let sampleVC = TSNewsWebEditorController()
        self.navigationController?.pushViewController(sampleVC, animated: true)
    }
    func test2() -> Void {
        self.activeLabel.shouldAddFuzzyString = true
        self.activeLabel.numberOfLines = 1
//        self.activeLabel.attributedText = NSAttributedString.init(string: "我屮艸芔茻")
        self.activeLabel.attributedText = NSAttributedString(string: " ")
//        self.activeLabel.text = ""
        self.activeLabel.sizeToFit()
    }
    func test3() -> Void {
        self.activeLabel.shouldAddFuzzyString = false
        self.activeLabel.numberOfLines = 3
//        self.activeLabel.text = "你是一个城a;djfalsdjf;lasjdfl;ajdsflajsdfajdghqgjadgjalkdjglkasjdg;lkjsdlgjasldkgdlksjglsdjg;sdjg;lsdjfg;jsd;gjds;jgl;dsjjaldjg;ldjsg;ljdsg;ldjsfgljdf;hj;dfjhdfjhjdsf;hjdf;hj;dsfjh;sdjfh;sjdf;hljdfs;lhj;dfjh;slfjd;hjsdf;jhs;djfh;jfh;lsjfd;h"
        self.activeLabel.attributedText = NSAttributedString(string: "你是一个城a;djfalsdjf;lasjdfl;ajdsflajsdfajdghqgjadgjalkdjglkasjdg;lkjsdlgjasldkgdlksjglsdjg;sdjg;lsdjfg;jsd;gjds;jgl;dsjjaldjg;ldjsg;ljdsg;ldjsfgljdf;hj;dfjhdfjhjdsf;hjdf;hj;dsfjh;sdjfh;sjdf;hljdfs;lhj;dfjh;slfjd;hjsdf;jhs;djfh;jfh;lsjfd;h")
        self.activeLabel.sizeToFit()
    }

    func titleClick(_ control: TSTitleSelectControl) -> Void {

//        self.titleControlClick(control)

//        self.test1()

        control.isSelected = !control.isSelected
        if control.isSelected {
            self.test2()
        } else {
            self.test3()
        }

    }
    func titleControlClick(_ control: TSTitleSelectControl) -> Void {
        var title: String = ""
        switch self.time % 12 {
        case 0:
            title = "isSelected"
        case 1:
            title = "TSTitleSelectControl"
        case 2:
            title = "Hello, World"
        case 3:
            title = "阅读本文"
        case 4:
            title = "以下系统就直接返回"
        case 5:
            title = "我最大的写作动力"
        case 6:
            title = "欢迎各位转载"
        case 7:
            title = "同意"
        case 8:
            title = "给出作者和原文连接"
        case 9:
            title = "保留追究法律责任的权利"
        case 10:
            title = "Hello"
        case 11:
            title = "😁"
        default:
            break
        }
        self.time += 1
        control.title = title
    }

}
