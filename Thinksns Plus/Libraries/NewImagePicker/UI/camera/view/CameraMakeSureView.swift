//
//  CameraMakeSureView.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/27.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit

class CameraMakeSureView: UIView {

    @IBOutlet weak var imageView: UIImageView!

    /// 确认按钮
    @IBOutlet weak var buttonForConfirm: UIButton!
    /// 取消按钮
    @IBOutlet weak var buttonForCancel: UIButton!

    /// 自定义初始化方法
    class func viewForConfirm() -> CameraMakeSureView {
        let sureView = Bundle.main.loadNibNamed("CameraMakeSureView", owner: nil, options: nil)?.first as! CameraMakeSureView
        return sureView
    }

}
