//
//  TSMomentCommentController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 14/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  动态评论页，即动态详情页。
//  之前的动态详情页是TSCommetDetailTableView: TSMomentDetailVC
//  修正完毕后，重新使用TSMomentDetailController取代之前的TSCommetDetailTableView

import UIKit

class TSMomentCommentController: TSCommentListController {

    let momentId: Int

    // MARK: - Initialize Function

    init(momentId: Int, userId: Int) {
        self.momentId = momentId
        super.init(type: .momment, sourceId: momentId)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
