//
//  TSMeTableview.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/7/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  【我】的页面整体的tableview

import UIKit

protocol didMeSelectCellDelegate: NSObjectProtocol {
    /// 点击了cell
    func didSelectCell(indexPath: IndexPath)
    /// 点击了头视图哪里
    func didHeader(index: MeHeaderView)
}

class TSMeTableview: UIView, UITableViewDataSource, UITableViewDelegate, didHeaderViewDelegate {
    // MARK: - CELL显示的配置
    /// 所有cell的高度
    let cellHeight: CGFloat = 50
    /// section = 0 的头视图高度
    let cellHeaderZero: CGFloat = 206
    /// 需要显示【钱】的IndexPath
    let showMoneyLabel: IndexPath = [0, 2]
    /// 需要显示认证信息的 IndexPath
    let showCertificateLabel: IndexPath = [0, 1]
    /// 需要显示积分的 IndexPath
    var showIntegrationLabel: IndexPath = [0, 2]

    // MARK: - 创建tableview需要的数据源
    /// tableview数据源
    var dataSource: Array<Array<String>> = []
    /// tableview数据源图片
    var imageDataSource: Array<Array<UIImage>> = []
    /// tableview
    weak var meTableView: UITableView!
    // cellid
    let cellid = "meStaticCellID"
    /// tableview头视图
    let showMeHeader = TSMeTableViewHeader()

    weak var didMeSelectCellDelegate: didMeSelectCellDelegate? = nil

    init(frame: CGRect, dataSource: Array<Array<String>>, imageDataSource: Array<Array<UIImage>>) {
        super.init(frame: frame)
        self.dataSource = dataSource
        self.imageDataSource = imageDataSource
        self.backgroundColor = UIColor.clear
        if TSAppConfig.share.localInfo.showOnlyIAP {
            showIntegrationLabel = [0, 2]
        } else {
            showIntegrationLabel = [0, 3]
        }
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        let meTableView = UITableView(frame: CGRect.zero, style: .grouped)
        meTableView.backgroundColor = TSColor.inconspicuous.background
        meTableView.separatorStyle = .none
        meTableView.showsVerticalScrollIndicator = false
        meTableView.delegate = self
        meTableView.dataSource = self
        meTableView.tableFooterView = UIView()
        self.meTableView = meTableView
        self.addSubview(meTableView)
        meTableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
    }

    // MARK: - tableview delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            showMeHeader.didHeaderViewDelegate = self
            return showMeHeader
        } else {
            return nil
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowData = dataSource[section]
        return rowData.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return cellHeaderZero
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellid) as? TSMeTableViewCell
        if cell == nil {
            cell = TSMeTableViewCell(style: .default, reuseIdentifier: cellid)
        }
        let rowData = dataSource[indexPath.section]
        let imageRowData = imageDataSource[indexPath.section]

        if indexPath.row == (rowData.count - 1) {
            cell?.separator.isHidden = true
        } else {
            cell?.separator.isHidden = false
        }
        if TSAppConfig.share.localInfo.showOnlyIAP {
            if indexPath == showCertificateLabel {
                cell?.moenylabel.isHidden = false
                // 获取认证信息
                let certificateObject = TSDatabaseManager().user.getCurrentUserCertificate()
                if certificateObject?.status == 0 {
                    cell?.moenylabel.text = "待审核"
                } else if certificateObject?.status == 1 {
                    cell?.moenylabel.text = "已认证"
                } else if certificateObject?.status == 2 {
                    cell?.moenylabel.text = "被驳回"
                }
            } else if indexPath == showIntegrationLabel {
                cell?.moenylabel.isHidden = false
                let str = "\(TSCurrentUserInfo.share.userInfo?.integration?.sum ?? 0)"
                cell?.moenylabel.text = str
            } else {
                cell?.moenylabel.isHidden = true
            }
        } else {
            if indexPath == showMoneyLabel {
                cell?.moenylabel.isHidden = false
                let str = TSCurrentUserInfo.getCurrentUserGold()?.tostring() ?? "0.00"
                cell?.moenylabel.text = str
            } else if indexPath == showCertificateLabel {
                cell?.moenylabel.isHidden = false
                // 获取认证信息
                let certificateObject = TSDatabaseManager().user.getCurrentUserCertificate()
                if certificateObject?.status == 0 {
                    cell?.moenylabel.text = "待审核"
                } else if certificateObject?.status == 1 {
                    cell?.moenylabel.text = "已认证"
                } else if certificateObject?.status == 2 {
                    cell?.moenylabel.text = "被驳回"
                }
            } else if indexPath == showIntegrationLabel {
                cell?.moenylabel.isHidden = false
                let str = "\(TSCurrentUserInfo.share.userInfo?.integration?.sum ?? 0)"
                cell?.moenylabel.text = str
            } else {
                cell?.moenylabel.isHidden = true
            }
        }
        cell?.vcImage.image = imageRowData[indexPath.row]
        cell?.vcName.text = rowData[indexPath.row]
        cell?.accessory.image = #imageLiteral(resourceName: "IMG_ic_arrow_smallgrey")
        cell?.selectionStyle = .none
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didMeSelectCellDelegate?.didSelectCell(indexPath: indexPath)
    }

    func didHeaderIndex(index: MeHeaderView) {
        self.didMeSelectCellDelegate?.didHeader(index: index)
    }
}
