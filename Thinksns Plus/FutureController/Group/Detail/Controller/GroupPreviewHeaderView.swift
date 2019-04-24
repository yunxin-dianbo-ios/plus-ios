//
//  GroupPreviewHeaderView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/9/7.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class GroupPreviewHeaderView: UIView {
    fileprivate var coverImageView = UIImageView()
    fileprivate var titleLab = UILabel()
    fileprivate var tagsBgView = UIView()
    fileprivate var memberCountLab = UILabel()
    fileprivate var postCountLab = UILabel()
    fileprivate var recommendPostCountLab = UILabel()
    let memeberBgView = UIView()
    let postsBgView = UIView()
    let recommendPostsBgView = UIView()
    /// 除去标签栏的高度
    let hedearBaseHeight: CGFloat = 100 + 60
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        creatUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func creatUI() {
        addSubview(coverImageView)
        addSubview(titleLab)
        addSubview(tagsBgView)
        addSubview(memeberBgView)
        addSubview(postsBgView)
        addSubview(recommendPostsBgView)

        memeberBgView.addSubview(memberCountLab)
        postsBgView.addSubview(postCountLab)
        recommendPostsBgView.addSubview(recommendPostCountLab)
        memberCountLab.font = UIFont.boldSystemFont(ofSize: 18)
        memberCountLab.textColor = UIColor.black
        memberCountLab.textAlignment = .center
        postCountLab.font = UIFont.boldSystemFont(ofSize: 18)
        postCountLab.textColor = UIColor.black
        postCountLab.textAlignment = .center
        recommendPostCountLab.font = UIFont.boldSystemFont(ofSize: 18)
        recommendPostCountLab.textColor = UIColor.black
        recommendPostCountLab.textAlignment = .center
        memeberBgView.snp.makeConstraints { (make) in
            make.top.equalTo(tagsBgView.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.width.equalTo(self.width / 3.0)
            make.height.equalTo(33)
        }
        postsBgView.snp.makeConstraints { (make) in
            make.top.equalTo(tagsBgView.snp.bottom).offset(10)
            make.leading.equalTo(memeberBgView.snp.trailing)
            make.width.equalTo(self.width / 3.0)
            make.height.equalTo(33)
        }
        recommendPostsBgView.snp.makeConstraints { (make) in
            make.top.equalTo(tagsBgView.snp.bottom).offset(10)
            make.leading.equalTo(postsBgView.snp.trailing)
            make.trailing.equalToSuperview()
            make.width.equalTo(self.width / 3.0)
            make.height.equalTo(33)
        }
        memberCountLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(16)
        }
        postCountLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(16)
        }
        recommendPostCountLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(16)
        }
        let memeberLab = UILabel()
        memeberLab.textColor = TSColor.normal.minor
        memeberLab.font = UIFont.systemFont(ofSize: 12)
        memeberLab.text = "成员"
        memeberLab.textAlignment = .center
        memeberBgView.addSubview(memeberLab)
        memeberLab.snp.makeConstraints { (make) in
            make.top.equalTo(memberCountLab.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(12)
        }
        let postsLab = UILabel()
        postsLab.textColor = TSColor.normal.minor
        postsLab.font = UIFont.systemFont(ofSize: 12)
        postsLab.text = "帖子"
        postsLab.textAlignment = .center
        postsBgView.addSubview(postsLab)
        postsLab.snp.makeConstraints { (make) in
            make.top.equalTo(postCountLab.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(12)
        }
        let recommendPostLab = UILabel()
        recommendPostLab.textColor = TSColor.normal.minor
        recommendPostLab.font = UIFont.systemFont(ofSize: 12)
        recommendPostLab.text = "精华帖"
        recommendPostLab.textAlignment = .center
        recommendPostsBgView.addSubview(recommendPostLab)
        recommendPostLab.snp.makeConstraints { (make) in
            make.top.equalTo(recommendPostCountLab.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(12)
        }
        coverImageView.backgroundColor = TSColor.inconspicuous.background
        coverImageView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        titleLab.font = UIFont.boldSystemFont(ofSize: 16)
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = .center
        titleLab.snp.remakeConstraints { (make) in
            make.top.equalTo(coverImageView.snp.bottom).offset(20)
            make.height.equalTo(15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
//        tagsBgView.backgroundColor = UIColor.blue
        tagsBgView.snp.remakeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(50)
        }
        tagsBgView.width = frame.width - 10 * 2
        let bottomSpView = UIView()
        addSubview(bottomSpView)
        bottomSpView.backgroundColor = TSColor.inconspicuous.background
        bottomSpView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.bottom).offset(-10)
            make.height.equalTo(10)
            make.leading.trailing.equalToSuperview()
        }
    }
    func updateUI(detailModel: GroupModel) {
        if let url = detailModel.avatar?.url {
            coverImageView.setImageWith(URL(string: url), placeholder: nil)
        } else {
            coverImageView.setImageWith(nil, placeholder: nil)
        }
        titleLab.text = detailModel.name
        memberCountLab.text = TSAppConfig.share.pageViewsString(number: detailModel.userCount)
        postCountLab.text = TSAppConfig.share.pageViewsString(number: detailModel.postCount)
        recommendPostCountLab.text = TSAppConfig.share.pageViewsString(number: detailModel.excellenPostsCount)
        creatTagsView(bgView: tagsBgView, tags: detailModel.tags, isCenterAlignment: true)
    }
    func creatTagsView(bgView: UIView, tags: [GroupTagModel], isCenterAlignment: Bool) {
        var tagTitles: [String] = []
        for tagModel in tags {
            tagTitles.append(tagModel.name)
        }
        var lastBtnMaxX: CGFloat = 0
        var lastBtnMaxY: CGFloat = 0
        let spaceX: CGFloat = 5
        let spaceY: CGFloat = 5
        let btnHeight: CGFloat = 20
        var uploadBegainIndex: Int = 0
        var uploadEndIndex: Int = 0
        var tagsHeight: CGFloat = 0
        for (index, tag) in tagTitles.enumerated() {
            let btn = UIButton()
            btn.setTitle(tag, for: .normal)
            btn.layer.cornerRadius = 3
            btn.tag = index + 1_000
            btn.backgroundColor = TSColor.inconspicuous.background
            btn.setTitleColor(TSColor.main.content, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 11)
            bgView.addSubview(btn)
            let btnW: CGFloat = tag.size(maxSize: CGSize(width: bgView.width - spaceX * 2, height: 20), font: (btn.titleLabel?.font)!).width + 10
            if lastBtnMaxX + btnW + 2 * spaceX > bgView.width {
                if isCenterAlignment == true {
                    // 重新更新一次上一行的间距，并布局
                    uploadEndIndex = index - 1
                    var tempSp: CGFloat = 0
                    var totalBtnW: CGFloat = 0
                    for uploadIndex in uploadBegainIndex ... uploadEndIndex {
                        if let view = bgView.viewWithTag(uploadIndex + 1_000), let addBtn = view as? UIButton {
                            totalBtnW = addBtn.width + totalBtnW
                        }
                    }
                    tempSp = (bgView.width - totalBtnW) / CGFloat(uploadEndIndex - uploadBegainIndex + 2)
                    // 重新布局该行
                    var lastMaxX: CGFloat = 0
                    for uploadIndex in uploadBegainIndex ... uploadEndIndex {
                        if let view = bgView.viewWithTag(uploadIndex + 1_000), let addBtn = view as? UIButton {
                            addBtn.left = lastMaxX + tempSp
                            lastMaxX = addBtn.right
                        }
                    }
                    uploadBegainIndex = uploadEndIndex + 1
                }
                lastBtnMaxX = 0
                lastBtnMaxY = lastBtnMaxY + spaceY + btnHeight
            }
            btn.frame = CGRect(x: lastBtnMaxX + spaceX, y: lastBtnMaxY + spaceY, width: btnW, height: btnHeight)
            lastBtnMaxX = btn.frame.maxX
            if index == tagTitles.count - 1 {
                if isCenterAlignment == true {
                    // 重新更新一次上一行的间距，并布局
                    uploadEndIndex = index
                    var tempSp: CGFloat = 0
                    var totalBtnW: CGFloat = 0
                    var uploadOffsetX: CGFloat = 0
                    for uploadIndex in uploadBegainIndex ... uploadEndIndex {
                        if let view = bgView.viewWithTag(uploadIndex + 1_000), let addBtn = view as? UIButton {
                            totalBtnW = addBtn.width + totalBtnW
                        }
                    }
                    tempSp = (bgView.width - totalBtnW) / CGFloat(uploadEndIndex - uploadBegainIndex + 2)
                    if tempSp > spaceX * 2 {
                        tempSp = spaceX * 2
                        uploadOffsetX = (bgView.width - totalBtnW - tempSp * CGFloat(uploadEndIndex - uploadBegainIndex + 2)) / 2.0
                    }
                    // 最后一行重新布局
                    var lastMaxX: CGFloat = 0
                    var isFirstBtn: Bool = true
                    for uploadIndex in uploadBegainIndex ... uploadEndIndex {
                        if let view = bgView.viewWithTag(uploadIndex + 1_000), let addBtn = view as? UIButton {
                            addBtn.left = isFirstBtn ? uploadOffsetX : 0 + lastMaxX + tempSp
                            lastMaxX = addBtn.right
                            isFirstBtn = false
                            if uploadIndex == uploadEndIndex {
                                tagsHeight = addBtn.frame.maxY + 10
                            }
                        }
                    }
                    uploadBegainIndex = uploadEndIndex + 1
                }
            }
        }
        bgView.snp.updateConstraints { (make) in
            make.height.equalTo(tagsHeight)
        }
        /// 更新整个heaser的高度
        self.height = hedearBaseHeight + tagsHeight + 25 + 10
    }
}
