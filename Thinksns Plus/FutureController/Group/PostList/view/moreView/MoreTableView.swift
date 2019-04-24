//
//  MoreTableView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/12/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  帖子列表抽屉视图

import UIKit

protocol MoreTableViewDelegate: class {

    /// 点击了 cell
    func moreTableView(_ view: MoreTableView, didSelectedCell indexPath: IndexPath, with title: String)
}
class MoreTableView: UIView {

    /// 代理
    weak var delegate: MoreTableViewDelegate?

    /// 数据
    var datas: [MoreTableViewCellModel] = [] {
        didSet {
            table.reloadData()
        }
    }

    /// 标题
    let titleLabel = UILabel()
    /// 分割线
    let seperator = UIView()
    /// 列表
    let table = UITableView()
    /// 退出or转让按钮
    let exitButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        backgroundColor = UIColor(hex: 0x363845)

//        // 1.标题 label
//        titleLabel.text = "更多操作"
//        titleLabel.textColor = UIColor(hex: 0x4a4d5e)
//        titleLabel.font = UIFont.systemFont(ofSize: 13)
//        titleLabel.sizeToFit()
//        titleLabel.frame = CGRect(origin: CGPoint(x: 18, y: TSNavigationBarHeight ), size: titleLabel.size)
//        // 2.分割线
//        seperator.backgroundColor = UIColor(hex: 0x4a4d5e)
//        seperator.frame = CGRect(x: 20, y:titleLabel.bottom + 6, width: bounds.width - 40, height: 1)
        // 3.列表
        table.backgroundColor = UIColor(hex: 0x363845)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.rowHeight = 58
        table.frame = CGRect(x: 0, y:  TSNavigationBarHeight + 1, width: bounds.width, height: bounds.height - 84 - TSBottomSafeAreaHeight)
        table.register(UINib(nibName: "MoreTableViewCell", bundle: nil), forCellReuseIdentifier: MoreTableViewCell.identifier)
        // 4.退出or转让按钮
        exitButton.frame = CGRect(x: 20, y: UIScreen.main.bounds.height - 50 - TSBottomSafeAreaHeight, width: 160, height: 30)
        exitButton.setTitleColor(UIColor(hex: 0xcccccc), for: .normal)
        exitButton.layer.borderWidth = 0.5
        exitButton.layer.cornerRadius = 4
        exitButton.layer.borderColor = UIColor(red: 74.0 / 255.0, green: 77.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0).cgColor
        exitButton.alpha = 1
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)

//        addSubview(titleLabel)
//        addSubview(seperator)
        addSubview(table)
        addSubview(exitButton)
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MoreTableView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoreTableViewCell.identifier, for: indexPath) as! MoreTableViewCell
        cell.model = datas[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.moreTableView(self, didSelectedCell: indexPath, with: datas[indexPath.row].title)
    }
}
