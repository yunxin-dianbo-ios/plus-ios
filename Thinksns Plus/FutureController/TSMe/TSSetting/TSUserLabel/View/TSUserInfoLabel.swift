//
//  TSUserInfoLabl.swift
//  date
//
//  Created by Fiction on 2017/8/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  个人信息修改页面，标签collectionview

import UIKit

protocol TSUserInfoLabelDelegate: NSObjectProtocol {
    /// 返回collectionview的ContentSizeHight
    // 注：该回调必须在加载内容后，而不是再加载前。如果用在一些别的视图上的时候，特别是需要先预知高度的如tableView的时候，很无力。
    func selfContentSizeHight(hight: CGFloat)
}

class TSUserInfoLabel: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - 配置
    var userInfoLabeldataSource: Array<String> = []
    weak var TSUserInfoLabelDelegate: TSUserInfoLabelDelegate?
    /// 提示（在没有数据时使用）
    let tipsLabel = UILabel()
    /// item高度
    let itemHeight: CGFloat = 24

    /// 高度计算
    class func heightWithData(_ labelList: [String], layout: UICollectionViewFlowLayout) -> CGFloat {
        let height: CGFloat = 50
        if labelList.isEmpty {
            return height
        }
        // 高度计算
        let itemHeight = TSUserInfoLabel(frame: CGRect.zero, collectionViewLayout: layout).itemHeight
        var calcH: CGFloat = layout.sectionInset.top
        let actualW: CGFloat = ScreenWidth - layout.sectionInset.left - layout.sectionInset.right
        var lineContentW: CGFloat = 0
        for (index, label) in labelList.enumerated() {
            // 判断添加这个后是否换行
            let str = label + "占"   // 加一个占位符，请参考TSUserInfoLabel内部的布局代码
            let width = str.sizeOfString(usingFont: UIFont.systemFont(ofSize: TSFont.Button.keyboardRight.rawValue)).width
            // 首个标签处理
            if 0 == index {
                lineContentW = width
                calcH += itemHeight
                continue
            }
            // 换行判断处理
            if lineContentW + layout.minimumInteritemSpacing + width > actualW {
                calcH += layout.minimumLineSpacing + itemHeight
                lineContentW = width
            } else {
                lineContentW += layout.minimumInteritemSpacing + width
            }
        }
        calcH += layout.sectionInset.bottom
        // 保留最小高度50
        let realH: CGFloat = max(height, calcH)
        return realH
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setData(data: Array<String>) {
        self.userInfoLabeldataSource = data
        self.reloadData()
    }

    func setUI() {
        self.backgroundColor = UIColor.clear
        self.dataSource = self
        self.delegate = self
        self.register(TSUserInfoCollectionViewCell.self, forCellWithReuseIdentifier: "UserInfoLabel")
        tipsLabel.text = "标题_选择标签".localized
        tipsLabel.textColor = TSColor.normal.disabled
        tipsLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        self.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(8)
            make.left.equalTo(self).offset(12)
            make.height.equalTo(14)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = userInfoLabeldataSource.count
        self.tipsLabel.isHidden = userInfoLabeldataSource.isEmpty == true ?  false : true

        return userInfoLabeldataSource.isEmpty == true ? 0 : count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserInfoLabel", for: indexPath) as? TSUserInfoCollectionViewCell
        cell?.contentViewLabel.text = userInfoLabeldataSource[indexPath.row]
        let height = self.contentSize.height
        self.TSUserInfoLabelDelegate?.selfContentSizeHight(hight: height)
        return cell!
    }

    // 计算item宽度，多占一个字符要好看一点
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var str = ""
        var width: CGFloat = 0
        str = userInfoLabeldataSource[indexPath.row] + "占"
        width = str.sizeOfString(usingFont: UIFont.systemFont(ofSize: TSFont.Button.keyboardRight.rawValue)).width
        return CGSize(width: width, height: itemHeight)
    }
}
