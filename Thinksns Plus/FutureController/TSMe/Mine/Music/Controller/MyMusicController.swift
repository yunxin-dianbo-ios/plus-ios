//
//  MyMusicController.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/12.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  购买的音乐

import UIKit

class MyMusicController: TSLabelViewController {

    /// 专辑列表
    let albumListVC = MusicAlbumListVC()
    /// 单曲列表
    let songVC = MusicSingleListsVC()

    // MARK: - Lifecycle
    init() {
        super.init(labelTitleArray: ["单曲", "专辑"], scrollViewFrame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.size.height)))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        add(childViewController: songVC, At: 0)
        add(childViewController: albumListVC, At: 1)
    }
}
