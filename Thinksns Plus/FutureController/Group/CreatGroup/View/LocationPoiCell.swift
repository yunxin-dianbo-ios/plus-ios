//
//  LocationPoiCell.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  定位的POI(Point of Interest，兴趣点) Cell

import UIKit

class LocationPoiCell: UITableViewCell {

    // MARK: - Internal Property
    //static let cellHeight: CGFloat = 75
    /// 重用标识符
    static let identifier: String = "LocationPoiCellReuseIdentifier"

    var model: AMapPOI? {
        didSet {
            self.nameLabel.text = model?.name
            self.addressLabel.text = model?.address
        }
    }

    // MARK: - Private Property

    fileprivate weak var nameLabel: UILabel!
    fileprivate weak var addressLabel: UILabel!

    fileprivate let lrMargin: CGFloat = 15
    fileprivate let tbMargin: CGFloat = 15
    fileprivate let verMargin: CGFloat = 5

    // MARK: - Internal Function

    class func cellInTableView(_ tableView: UITableView) -> LocationPoiCell {
        let identifier = LocationPoiCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if nil == cell {
            cell = LocationPoiCell(style: .default, reuseIdentifier: identifier)
        }
        // 重置位置
        return cell as! LocationPoiCell
    }

    // MARK: - Initialize Function

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialUI()
    }

    // MARK: - Override Function

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        var textColor = selected ? UIColor(hex: 0x4bb893) : TSColor.main.content
        self.nameLabel.textColor = textColor
    }

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // mainView - 整体布局，便于扩展，特别是针对分割、背景色、四周间距
        let mainView = UIView()
        self.contentView.addSubview(mainView)
        self.initialMainView(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        // line
        //mainView.addLineWithSide(.inBottom, color: TSColor.normal.disabled, thickness: 0.5, margin1: 0, margin2: 0)
    }
    // 主视图布局
    private func initialMainView(_ mainView: UIView) -> Void {
        // 1.nameLabel
        let nameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15), textColor: TSColor.main.content)
        mainView.addSubview(nameLabel)
        nameLabel.numberOfLines = 0
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(mainView).offset(lrMargin)
            make.trailing.equalTo(mainView).offset(-lrMargin)
            make.top.equalTo(mainView).offset(tbMargin)
        }
        self.nameLabel = nameLabel
        // 2.addressLabel
        let addressLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 10), textColor: TSColor.normal.minor)
        mainView.addSubview(addressLabel)
        addressLabel.numberOfLines = 0
        addressLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(verMargin)
            make.bottom.equalTo(mainView).offset(-tbMargin)
        }
        self.addressLabel = addressLabel
    }

    // MARK: - Private  数据加载

    // MARK: - Private  事件响应

}
