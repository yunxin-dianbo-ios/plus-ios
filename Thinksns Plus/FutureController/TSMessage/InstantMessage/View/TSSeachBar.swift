//
//  TSSeachBar.swift
//  ThinkSNSPlus
//
//  Created by 曹林 on 2018/6/27.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSSeachBar: UIView {
    @IBOutlet weak var seachButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    class  func seachBarHeadView() -> TSSeachBar {
        let nib = UINib(nibName: "TSSeachBar", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! TSSeachBar
        return view
    }
    override func awakeFromNib() {
         super.awakeFromNib()
          bgView.layer.cornerRadius = 5
          bgView.clipsToBounds = true
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
