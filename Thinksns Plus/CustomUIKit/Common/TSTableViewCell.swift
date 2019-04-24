//
//  TSTableViewCell.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  基础类,表格的单元格

import UIKit

class TSTableViewCell: UITableViewCell {

    lazy var shapeLayer: CAShapeLayer = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: self.contentView.bounds.size.height - 0.5))
        bezierPath.addLine(to: CGPoint(x: (self.superview?.bounds.size.width)!, y: self.contentView.bounds.size.height - 0.5))
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = TSColor.inconspicuous.disabled.cgColor
        shapeLayer.lineWidth = 0.5
        shapeLayer.path = bezierPath.cgPath
        return shapeLayer
    }()
    // MARK: - lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: setup
    func setupUI() {
        // 关闭点击效果
        self.selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if self.shapeLayer.superlayer == nil {
            self.contentView.layer.addSublayer(self.shapeLayer)
        } else {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0, y: self.contentView.bounds.size.height - 0.5))
            bezierPath.addLine(to: CGPoint(x: (self.superview?.bounds.size.width)!, y: self.contentView.bounds.size.height - 0.5))
            self.shapeLayer.path = bezierPath.cgPath
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
