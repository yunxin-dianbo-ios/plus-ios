//
//  TSDetailRewardListView.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SnapKit

protocol TSDetailRewardListViewDelegate: class {
    func tapUser()
}

class TSDetailRewardListView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    weak var rewardInfoLabel: UILabel!
    weak var rewardUserList: UICollectionView!
    weak var rewardUserListArrow: UIImageView!
    weak var delegate: TSDetailRewardListViewDelegate?
    private var showUserCount = 0
    var userListDataSource: [TSNewsRewardModel]? {
        didSet {
            if userListDataSource == nil {
                return
            }
            //[issue #2230] [动态-动态详情] 打赏人数超过10个后显示错误
            // 要求详情打赏列表头像最多显示10个
            showUserCount = (userListDataSource?.count)! > 10 ? 10 : (userListDataSource?.count)!
            self.rewardUserList.reloadData()
            self.rewardUserListArrow.isHidden = userListDataSource!.isEmpty
            self.setNeedsLayout()
        }
    }
    var rewardModel: TSNewsRewardCountModel! {
        didSet {
            if rewardModel.count.isEqualZero {
                rewardUserListArrow.isHidden = true
            } else {
                rewardUserListArrow.isHidden = false
            }
            let amountStr: String
            if let amount = rewardModel.realAmount {
                amountStr = String(format: "%0.f", amount)
            } else {
                amountStr = "0"
            }
            let countString = "\(rewardModel.count)人打赏, 共" + amountStr + TSAppConfig.share.localInfo.goldName
            let attributeCountString = NSMutableAttributedString(string: countString)
            let nsString = countString as NSString
            let nsRange = nsString.range(of: "\(rewardModel.count)")
            let nsRange2Str = "共" + amountStr
            var nsRange2 = nsString.range(of: nsRange2Str)
            nsRange2.location = nsRange2.location + 1
            nsRange2.length = nsRange2.length - 1
            attributeCountString.addAttribute(NSForegroundColorAttributeName, value: TSColor.small.rewardText, range: nsRange)
            attributeCountString.addAttribute(NSForegroundColorAttributeName, value: TSColor.small.rewardText, range: nsRange2)
            self.rewardInfoLabel.attributedText = attributeCountString
        }
    }

    // MARK: - lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        let rewardInfoLabel = UILabel(text: nil, font: UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue), textColor: TSColor.normal.minor)
        rewardInfoLabel.textAlignment = .center
        self.rewardInfoLabel = rewardInfoLabel

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 20, height: 20)
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let rewardUserList = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        rewardUserList.dataSource = self
        rewardUserList.delegate = self
        rewardUserList.backgroundColor = UIColor.white
        rewardUserList.register(TSDetailRewardListViewCellCollectionViewCell.self, forCellWithReuseIdentifier: "TSDetailRewardListView")
        self.rewardUserList = rewardUserList

        let rewardUserListArrow = UIImageView(image: UIImage(named: "IMG_ic_arrow_smallgrey"))
        rewardUserListArrow.isHidden = true
        self.rewardUserListArrow = rewardUserListArrow

        self.addSubview(rewardInfoLabel)
        self.addSubview(rewardUserList)
        self.addSubview(rewardUserListArrow)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let userListCount = showUserCount
        self.rewardInfoLabel.snp.remakeConstraints { (mark) in
            mark.top.equalToSuperview().offset(7.5)
            mark.width.equalToSuperview()
            mark.centerX.equalToSuperview()
        }
        self.rewardUserList.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(34)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(userListCount * 20 + (userListCount + 1) * 5)
        }
        self.rewardUserListArrow.snp.remakeConstraints { (make) in
            make.size.equalTo(CGSize(width: 10, height: 20))
            make.centerY.equalTo(self.rewardUserList.snp.centerY)
            make.left.equalTo(self.rewardUserList.snp.right)
        }
    }

    // MARK: delegate & dataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showUserCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TSDetailRewardListView", for: indexPath) as! TSDetailRewardListViewCellCollectionViewCell
        cell.user = userListDataSource?[indexPath.row].user
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.tapUser()
    }
}
