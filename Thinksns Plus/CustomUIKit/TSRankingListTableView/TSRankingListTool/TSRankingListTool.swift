//
//  TSRankingListTool.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  TSRanking的工具类

import UIKit

class TSRankingListTool: NSObject {

    let formatConversion: CGFloat = 9_999

    let rankNumberHeight: CGFloat = 11.0

    /// 换算格式
    ///
    /// - Parameter value: 赞的数量
    /// - Returns: 返回转换后的String
    func conversionPraiseNumber(value: Int) -> String {
        if CGFloat(value) >= formatConversion {
            return String(format: "%.1fW", CGFloat(value) / formatConversion)
        } else {
            return "\(value)"
        }
    }

    /// 切割圆角
    ///
    /// - Parameters:
    ///   - corner: 角度
    ///   - rect: 尺寸
    /// - Returns: 返回遮罩层
    func drawCorner(corner: CGFloat, rect: CGRect) -> CAShapeLayer {
        let maskPath = UIBezierPath(roundedRect: rect, cornerRadius: corner)
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        maskLayer.frame = rect
        return maskLayer
    }

    /// 计算排名View的宽度
    ///
    /// - Parameter str: 字符串
    /// - Returns: 返回宽度
    func calculationRankNumberViewWidth(str: String) -> CGFloat {
        let combStr = str + "-" + "-"
      let size = combStr.heightWithConstrainedWidth(width: CGFloat(MAXFLOAT), height: rankNumberHeight, font: UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue))
        return size.width
    }
}
