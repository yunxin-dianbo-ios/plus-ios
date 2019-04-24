//
//  TSCommentHelper.swift
//  ThinkSNS +
//
//  Created by 小唐 on 08/11/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  评论助手/评论工具，用于处理一些评论相关的，但当前类型的M-V-C架构下又不大方便的

import Foundation

class TSCommentHelper {
    // 将CommentModel -> TSSimpleCommentModel
    class func convertToSimple(_ commentList: [TSCommentModel]) -> [TSSimpleCommentModel] {
        var simpleList: [TSSimpleCommentModel] = [TSSimpleCommentModel]()
        for comment in commentList {
            simpleList.append(comment.simpleModel())
        }
        return simpleList
    }
    class func convertToSimple(_ commentList: [TSFailedCommentModel]) -> [TSSimpleCommentModel] {
        var simpleList: [TSSimpleCommentModel] = [TSSimpleCommentModel]()
        for comment in commentList {
            simpleList.append(comment.simpleModel())
        }
        return simpleList
    }
    // 将CommentModel -> CommentViewModel
    class func convertToViewModel(_ commentList: [TSCommentModel]) -> [TSCommentViewModel] {
        var viewModelList: [TSCommentViewModel] = [TSCommentViewModel]()
        for comment in commentList {
            if let viewModel = comment.viewModel() {
                viewModelList.append(viewModel)
            }
        }
        return viewModelList
    }
    class func convertToViewModel(_ commentList: [TSFailedCommentModel]) -> [TSCommentViewModel] {
        var viewModelList: [TSCommentViewModel] = [TSCommentViewModel]()
        for comment in commentList {
            if let viewModel = comment.viewModel() {
                viewModelList.append(viewModel)
            }
        }
        return viewModelList
    }

    // 评论高度
    class func getCommentListHeightOld(_ commentList: [TSSimpleCommentModel], type: TSCommentLabel.ShowType) -> [CGFloat] {
        var heightList: [CGFloat] = [CGFloat]()
        for comment in commentList {
            var height: CGFloat = 0
            switch type {
            case .simple:
                // 随便乱写的
                height = 75
            case .detail:
                height = TSDetailCommentTableViewCell().setCommentHeight(comments: [comment], width: ScreenWidth)[0]
            }
            heightList.append(height)
        }
        return heightList
    }
    class func getCommentListHeight(_ commentList: [TSCommentViewModel], type: TSCommentLabel.ShowType) -> [CGFloat] {
        var heightList: [CGFloat] = [CGFloat]()
        for comment in commentList {
            var height: CGFloat = 0
            switch type {
            case .simple:
                // 随便乱写的
                height = 75
            case .detail:
                height = TSDetailCommentCell.heightWithModel(comment)
            }
            heightList.append(height)
        }
        return heightList
    }
    class func getCommentListHeightNew(_ commentList: [TSSimpleCommentModel], type: TSCommentLabel.ShowType) -> [CGFloat] {
        var heightList: [CGFloat] = [CGFloat]()
        for comment in commentList {
            var height: CGFloat = 0
            switch type {
            case .simple:
                // 随便乱写的
                height = 75
            case .detail:
                height = TSDetailCommentCell.heightWithModel(comment)
            }
            heightList.append(height)
        }
        return heightList
    }

}
