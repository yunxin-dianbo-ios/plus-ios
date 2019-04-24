//
//  GroupDetailRootTableView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/9/11.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class GroupDetailRootTableView: UITableView, UIGestureRecognizerDelegate {

    var headerViewInsets = UIEdgeInsets.zero {
        didSet {
            shouldManuallyLayoutHeaderViews = headerViewInsets != .zero
            setNeedsLayout()
        }
    }
    var shouldManuallyLayoutHeaderViews = false

    override func layoutSubviews() {
        super.layoutSubviews()
        if shouldManuallyLayoutHeaderViews {
            layoutHeaderViews()
        }
    }

    func layoutHeaderViews() {
        let numberOfSections = self.numberOfSections
        let contentInset = self.contentInset
        let contentOffset = self.contentOffset
        let sectionViewMinimumOriginY = contentOffset.y + contentInset.top + headerViewInsets.top + TSStatusBarHeight - 20

        //    Layout each header view
        for section in 0 ..< numberOfSections {
            guard let sectionView = self.headerView(forSection: section) else {
                continue
            }
            let sectionFrame = rect(forSection: section)
            var sectionViewFrame = sectionView.frame
            sectionViewFrame.origin.y = sectionFrame.origin.y < sectionViewMinimumOriginY ? sectionViewMinimumOriginY : sectionFrame.origin.y
            if section < numberOfSections - 1 {
                let nextSectionFrame = self.rect(forSection: section + 1)
                if sectionViewFrame.maxY > nextSectionFrame.minY {
                    sectionViewFrame.origin.y = nextSectionFrame.origin.y - sectionViewFrame.size.height
                }
            }
            sectionView.frame = sectionViewFrame
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
