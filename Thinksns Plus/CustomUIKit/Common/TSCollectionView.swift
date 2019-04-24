//
//  TSCollectionView.swift
//  ThinkSNSPlus
//
//  Created by 小唐 on 14/03/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//

import UIKit

class TSCollectionView: UICollectionView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    let placeHolderView: UIView = UIView(bgColor: TSColor.inconspicuous.background)

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupPlaceHolder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupPlaceHolder()
    }

    fileprivate func setupPlaceHolder() -> Void {
        self.addSubview(placeHolderView)
        placeHolderView.snp.makeConstraints { (make) in
            make.width.height.equalTo(self)
            make.edges.equalTo(self)
        }
    }

    func showPlaceHolder(_ placeHolder: PlaceHolder) -> Void {
        self.bringSubview(toFront: self.placeHolderView)
        self.placeHolderView.isHidden = false
        let imageView = UIImageView(image: placeHolder.image)
        placeHolderView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalTo(self.placeHolderView)
        }
    }
    func hiddenPlaceHolder() -> Void {
        self.placeHolderView.isHidden = true
    }

}
