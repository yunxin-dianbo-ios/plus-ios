//
//  QuoraQuestionsNormalListView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

class QuoraListView: TSQuoraTableView {

    /*
     继承了纯 UI 的 TSQuoraTableView，在显示问答列表的 UI 基础上， QuoraListView 处理了问答列表的常用点击事件
    */

    override func setUI() {
        super.setUI()
        interactionDelegate = self
    }

}

// MARK: - TSQuoraTableViewDelegate: 问答列表的用户交互事件
extension QuoraListView: TSQuoraTableViewDelegate {

    /// 点击了 cell 的标题部分
    func table(_ table: TSQuoraTableView, didSelectTitleAt indexPath: IndexPath, with cellModel: TSQuoraTableCellModel) {
        guard isLogined() else {
            return
        }
        pushToQuoraDetailVC(at: indexPath)
    }

    /// 点击了 cell 的回答部分
    func table(_ table: TSQuoraTableView, didSelectAnswerAt indexPath: IndexPath, with cellModel: TSQuoraTableCellModel) {
        guard isLogined() else {
            return
        }
        answerTaped(at: indexPath)
    }

    /// 点击了 cell 的图片部分
    func table(_ table: TSQuoraTableView, didSelectImageAt indexPath: IndexPath, with cellModel: TSQuoraTableCellModel) {
        guard isLogined() else {
            return
        }
        answerTaped(at: indexPath)
    }

    /// 点击了 cell 的底部按钮部分
    func table(_ table: TSQuoraTableView, didSelectBottomAt indexPath: IndexPath, with cellModel: TSQuoraTableCellModel) {
        guard isLogined() else {
            return
        }
        pushToQuoraDetailVC(at: indexPath)
    }

    /// 点击了关注按钮
    func table(_ table: TSQuoraTableView, didSelectedFollow button: UIButton, at indexPath: IndexPath, of cell: QuoraStackBottomButtonsCell, with cellModel: TSQuoraTableCellModel) {
        guard isLogined() else {
            return
        }
        pushToQuoraDetailVC(at: indexPath)
    }

    /// 点击了回答按钮
    func table(_ table: TSQuoraTableView, didSelectedAnswer button: UIButton, at indexPath: IndexPath, of cell: QuoraStackBottomButtonsCell, with cellModel: TSQuoraTableCellModel) {
        guard isLogined() else {
            return
        }
        pushToQuoraDetailVC(at: indexPath)
    }

    /// 点击了悬赏按钮
    func table(_ table: TSQuoraTableView, didSelectedReward button: UIButton, at indexPath: IndexPath, of cell: QuoraStackBottomButtonsCell, with cellModel: TSQuoraTableCellModel) {
        guard isLogined() else {
            return
        }
        pushToQuoraDetailVC(at: indexPath)
    }
}

// MARK: - 各种操作
extension QuoraListView {

    /// 是否登录
    ///
    /// - Note: 判断是否处于游客模式，如果是，拦截点击操作
    ///
    /// - Returns: true，用户登录了；false，游客模式
    func isLogined() -> Bool {
        if TSCurrentUserInfo.share.isLogin == false {
            TSRootViewController.share.guestJoinLoginVC()
        }
        return TSCurrentUserInfo.share.isLogin
    }

    /// 跳转到问题详情页面
    func pushToQuoraDetailVC(at indexPath: IndexPath) {
        let cellModel = datas[indexPath.section]
        let quoraDetailVC = TSQuoraDetailController()
        quoraDetailVC.questionId = cellModel.id
        parentViewController?.navigationController?.pushViewController(quoraDetailVC, animated: true)
    }

    /// 点击了回答
    ///
    /// - Note: 如果答案需要围观，那么弹出围观付费弹窗；如果不需要围观，跳转到回答详情页面
    func answerTaped(at indexPath: IndexPath) {
//        let cellModel = datas[indexPath.section]
//        // 0.判断是否需要围观付费
//        guard let shouldPay = cellModel.contentModel?.shouldHiddenContent else {
//            return
//        }
//
//        // 过滤掉答案 id 为 nil 的情况
//        guard let answerId = cellModel.answerId else {
//            return
//        }
//        if shouldPay {
//            // 1.需要付费围观，显示付费弹窗
//            TSQuoraHelper.processAnswerOutlook(answerId: answerId, payComplete: { [weak self] (_, answerDetail) in
//                guard let answerDetail = answerDetail else {
//                    return
//                }
//                // 付费成功，更新数据，刷新界面
//                cellModel.contentModel = TSQuoraTableCellModel.getContentModel(from: answerDetail.toListModel())
//                self?.datas[indexPath.section] = cellModel
//                self?.reloadData()
//            })
//        } else {
//            // 2.不需要付费围观，进入答案详情页
//            let answerDetailVC = TSAnswerDetailController(answerId: answerId)
//            parentViewController?.navigationController?.pushViewController(answerDetailVC, animated: true)
//        }
        let cellModel = datas[indexPath.section]
        let quoraDetailVC = TSQuoraDetailController()
        quoraDetailVC.questionId = cellModel.id
        parentViewController?.navigationController?.pushViewController(quoraDetailVC, animated: true)
    }
}
