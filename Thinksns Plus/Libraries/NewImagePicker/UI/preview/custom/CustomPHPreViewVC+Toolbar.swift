//
//  CustomPHPreViewVC+Toolbar.swift
//  ImagePicker
//
//  Created by GorCat on 2017/7/8.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit

extension CustomPHPreViewVC {

    func setToolbarUI() {
        if toolbar.superview == nil {
            let toolbarBgView = UIView(frame: CGRect(x: 0, y: toolbar.frame.origin.y, width: toolbar.frame.size.width, height: toolbar.frame.size.height + TSBottomSafeAreaHeight))
            toolbarBgView.backgroundColor = UIColor.white
            view.addSubview(toolbarBgView)
            toolbar.frame = CGRect(x: 0, y: 0, width: toolbar.width, height: toolbar.height)
            toolbarBgView.addSubview(toolbar)
        }
        toolbar.buttonForChoose.addTarget(self, action: #selector(selectedButtonTaped(_:)), for: .touchUpInside)
        toolbar.buttonForFinish.addTarget(self, action: #selector(finishButtonTaped), for: .touchUpInside)
    }

    // MARK: - Button click
    // 点击了收费配置按钮
    func pushToPaySetting() {
        // 读取旧的支付信息，然后传递给支付页面
        let setsPayInfo = payInfo[currentIndex]
        let settingPriceVC = TSSettimgPriceViewController(imagePrice: setsPayInfo)
        settingPriceVC.delegate = self
        self.navigationController?.pushViewController(settingPriceVC, animated: true)
    }

    /// setting img price delegate
    func setsPrice(price: TSImgPrice, index: Int) {
        // 更新配置状态
        payInfo[currentIndex] = price
    }

    /// 点击了选择按钮
    func selectedButtonTaped(_ sender: UIButton) {
        // 更新按钮状态
        let cell = collection.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as! PreviewCollectionCell
        cell.isImageSelected = !cell.isImageSelected
        if cell.isImageSelected {
            // 添加了未定义的价格
            let imgPrice = TSImgPrice(paymentType: .not, sellingPrice: 0)
            payInfo.append(imgPrice)
            // 保存图片
            selectedAssets.append(allAssets[currentIndex])
        } else {
            // 移除图片
            let index = selectedAssets.index(of: allAssets[currentIndex])
            selectedAssets.remove(at: index!)
            payInfo.remove(at: index!)
        }
        // TODO: 当用户操作了选择按钮后，添加或者移除支付配置
        updateToolbar()
        chooseBlock?()
    }

    /// 点击了完成按钮
    func finishButtonTaped() {
        finishBlock?()
    }
}
