//
//  TSAlbumHeaderview.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/2/13.
//  Copyright © 2017年 LeonFa. All rights reserved.
//

import UIKit
import SnapKit

protocol TSAlbumHeaderviewDelegate: class {

    /// 点击评论
    ///
    /// - Parameter id: 专辑id
    func clickComment(AlbumID id: Int)
    /// 点击收藏
    func clickCollection(albumId: Int, collectState: Bool) -> Void
}

class TSAlbumHeaderview: UIView, TSToolbarViewDelegate {
// MARK: - 控件
    // 头像
    private var avatar: UIImageView!
    // 专辑名
    private var albumName: UILabel!
    // 专辑简介
    private var albumIntro: UILabel!
    // 工具栏
    public  var toolView: TSToolbarView!
    /// 音乐专辑简要信息object
    var model: TSAlbumListModel?
    /// 代理
    weak var delegate: TSAlbumHeaderviewDelegate? = nil

    // MARK: - 属性
    // 头像高度
    private let AvatarHeight: CGFloat = 80
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI
    func setUI(frame: CGRect) {

        let avatarframe = CGRect(x: (frame.size.width - AvatarHeight) / 2, y: 0, width: AvatarHeight, height: AvatarHeight)
        self.avatar = UIImageView(frame: avatarframe)
        self.avatar.layer.borderWidth = 2
        self.avatar.layer.borderColor = UIColor.white.cgColor
        self.avatar.contentMode = UIViewContentMode.scaleAspectFill
        self.avatar.clipsToBounds = true
        self .addSubview(self.avatar)

        self.albumName = UILabel(frame: CGRect(x: 0, y: self.avatar.frame.maxY + 20, width: frame.width, height: 18))
        self.albumName.font = UIFont.systemFont(ofSize: TSFont.Title.pulse.rawValue)
        self.albumName.textColor = UIColor.white
        self.albumName.textAlignment = NSTextAlignment.center
        self .addSubview(self.albumName)

        self.albumIntro = UILabel(frame: CGRect(x: 0, y: self.albumName.frame.maxY + 5, width: frame.width, height: 16))
        self.albumIntro.font = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        self.albumIntro.textColor = UIColor.white
        self.albumIntro.textAlignment = NSTextAlignment.center
        self .addSubview(self.albumIntro)

        self.creatToolView()
    }

    public func updateHeaderData(model: TSAlbumListModel) {
        self.model = model
        self.albumName.text = model.title
        self.albumIntro.text = model.intro
        self.avatar.kf.setImage(with: TSURLPath.imageV2URLPath(storageIdentity: model.storage?.id, compressionRatio: 20, size: model.storage?.size))
        self.toolView.setTitle("\(model.tasteCount)", At: 0)
        self.toolView.setTitle("\(model.shareCount)", At: 1)
        self.toolView.setTitle("\(model.commentCount)", At: 2)
        self.toolView.setTitle("\(model.collectCount)", At: 3)
        self.toolView.setImage(model.isCollectd ? "IMG_detail_ico_collect" : "IMG_music_ico_collect", At: 3)
    }

    func creatToolView() {
        // 设置 item 数据 model
        let listenCount = TSToolbarItemModel(image: "IMG_music_ico_playvolume", title: "0", index: 0)
        let shareCount = TSToolbarItemModel(image: "IMG_music_ico_share", title: "0", index: 1)
        let commentCount = TSToolbarItemModel(image: "IMG_music_ico_comment", title: "0", index: 2)
        let startCount = TSToolbarItemModel(image: "IMG_music_ico_collect", title: "0", index: 3)
        // 创建 toolbar
        self.toolView = TSToolbarView(frame: CGRect(x: 0, y: self.frame.height - 45, width: self.frame.width, height: 45), type: .top, items: [listenCount, shareCount, commentCount, startCount])
        self.toolView.delegate = self
        self.toolView.setItemTintColor(.white)
        self.toolView.backgroundColor = UIColor.clear
        self.addSubview(self.toolView!)
    }

    // MARK: - TSToolbarViewDelegate
    func toolbar(_ toolbar: TSToolbarView, DidSelectedItemAt index: Int) {
        guard let model = self.model else {
            return
        }
        let isLogin = TSCurrentUserInfo.share.isLogin
        switch index {
        case 1:
            /// 分享
            if isLogin == false {
                TSRootViewController.share.guestJoinLoginVC()
                break
            }
            /// 分享
            let shareTitle = self.model?.title != "" ? self.model?.title : TSAppSettingInfoModel().appDisplayName + " " + "音乐"
            var defaultContent = "默认分享内容".localized
            defaultContent.replaceAll(matching: "kAppName", with: TSAppSettingInfoModel().appDisplayName)
            let shareContent = self.model?.intro != "" ? self.model?.intro : defaultContent

            let shareView = ShareView()
            shareView.show(URLString: TSAppConfig.share.rootServerAddress + TSURLPath.application.developPage.rawValue, image: self.avatar.image, description: shareContent, title: shareTitle)
        case 2:
            /// 跳转评论
            if isLogin == false {
                TSRootViewController.share.guestJoinLoginVC()
                break
            }
            if self.delegate != nil {
                self.delegate?.clickComment(AlbumID: (self.model?.id)!)
            }
        case 3:
            /// 收藏
            if isLogin == false {
                TSRootViewController.share.guestJoinLoginVC()
                break
            }
            let count = model.isCollectd ? model.collectCount - 1 : model.collectCount + 1
            self.toolView.setTitle("\(count)", At: 3)
            //self.toolView.setImage(model.isCollectd ? "IMG_detail_ico_collect" : "IMG_music_ico_collect", At: 3)
            self.toolView.setImage(model.isCollectd ? "IMG_music_ico_collect" : "IMG_detail_ico_collect", At: 3)
            self.delegate?.clickCollection(albumId: model.id, collectState: model.isCollectd)
            // 发起任务
//            TSMusicTaskManager().start(collect: self.object!)
        default:
            break
        }
    }
}
