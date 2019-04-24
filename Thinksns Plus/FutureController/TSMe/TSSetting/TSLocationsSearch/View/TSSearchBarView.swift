//
//  TSSearchBarView.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/8/9.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSSearchBarView: UIView {

    public let searchTextFiled = UITextField()
    var rightButton: UIButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = TSColor.main.white
        setUI()
        // 1.监听音乐消失动画
        NotificationCenter.default.addObserver(self, selector: #selector(ifMusicButtonHiden), name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
        // 2.判断音乐按钮是否显示，更改音乐按的颜色
        let isMusicButtonShow = TSMusicPlayStatusView.shareView.isShow
        if isMusicButtonShow {
            TSMusicPlayStatusView.shareView.reSetImage(white: false)
            rightButton.snp.updateConstraints({ (make) in
                make.top.bottom.equalTo(searchTextFiled)
                make.right.equalTo(self).offset(-44)
            })
        }

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = TSColor.main.white
        setUI()
    }

    deinit {
    }

    func setUI() {
        searchTextFiled.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        searchTextFiled.textColor = TSColor.main.content
        searchTextFiled.placeholder = "搜索"
        searchTextFiled.backgroundColor = TSColor.normal.placeholder
        searchTextFiled.layer.cornerRadius = 5

        let searchIcon = UIImageView()
        searchIcon.image = #imageLiteral(resourceName: "IMG_search_icon_search")
        searchIcon.contentMode = .center
        searchIcon.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        searchTextFiled.leftView = searchIcon
        searchTextFiled.leftViewMode = .always

        rightButton.setTitle("取消", for: .normal)
        rightButton.setTitleColor(TSColor.main.theme, for: .normal)
        let separator = TSSeparatorView()

        self.addSubview(searchTextFiled)
        self.addSubview(rightButton)
        self.addSubview(separator)

        searchTextFiled.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(28.5)
            make.right.equalTo(rightButton.snp.left).offset(-15)
            make.left.equalTo(self).offset(15)
            make.bottom.equalTo(self).offset(-8.5)
        }
        rightButton.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(searchTextFiled)
            make.right.equalTo(self).offset(-15)
            make.width.equalTo(35)
        }
        separator.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.top.equalTo(self).offset(TSNavigationBarHeight - 0.5)
        }
    }

    func ifMusicButtonHiden() {
        UIView.animate(withDuration: 0.3) {
            self.rightButton.snp.updateConstraints({ (make) in
                make.top.bottom.equalTo(self.searchTextFiled)
                make.right.equalTo(self).offset(-15)
            })
            self.layoutIfNeeded()
        }
    }
}
