//
//  ChatScrollView.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2018/1/5.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class ChatScrollView: UIScrollView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // lbh 的解决消息页面上下左右同时滑动的问题的方案
        if let result = otherGestureRecognizer.view?.superview?.isKind(of: UITableView.self) {
            return result
        } else {
            return false
        }
    }
}
