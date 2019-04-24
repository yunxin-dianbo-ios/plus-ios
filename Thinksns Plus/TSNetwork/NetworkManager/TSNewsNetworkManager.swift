//
//  TSNewsNetworkManager.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import ObjectMapper

import Alamofire

class TSNewsNetworkManager: NSObject {

    // MARK: - 资讯栏目
    /// 从接口获取所有的栏目数据
    ///
    /// - Parameter complate: 结果
    func getNewsAllTags(complete: @escaping((_ data: TSNewsAllTagsModel?, _ result: Bool?) -> Void)) {
        /// 无参数
        let requestPath = TSURLPathV2.path.rawValue + TSURLPathV2.newsCates.rawValue
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: nil, complete: { (networkResponse, result) in
            // 请求失败
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkSuccessMessage(with: networkResponse)
                complete(nil, false)
                return
            }
            // 服务器数据异常
            guard let dic = networkResponse as? [String:Any] else {
                complete(nil, false)
                return
            }
            // 正常数据解析
            let model = TSNewsAllTagsModel()
            model.setData(json: dic)
            complete(model, nil)
        })
    }

    /// 订阅资讯栏目
    ///
    /// - Parameters:
    ///   - id: 栏目id的拼接字符串
    ///   - complate: 结果
    func markTags(tagids id: String, complete: @escaping((_ msg: String?, _ status: Bool) -> Void)) {
        var params: [String:Any] = Dictionary()
        params["follows"] = id

        var request = TSNewsNetworkRequest().followsCategor
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = params

        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(let data):
                complete(data.message, true)
            }
        }
    }
    // MARK: - 资讯列表

    /// 获取资讯列表数据,搜索资讯列表
    ///
    /// - Parameters:
    ///   - tagID: 栏目id.在isCheckCommend 为true时,该id无效
    ///   - maxID: 末尾数据id （用于加载更多）
    ///   - isCheckCommend: 是否抓取推荐信息
    ///   - searchKey: 搜索关键字,可以和tagID,maxID,isCheckCommend等组合搜索
    ///   - complate: 结果
    class func getNewsListData(tagID: Int, maxID: Int?, limit: Int?, isCheckCommend: Bool = false, searchKey: String? = nil, complete: @escaping((_ info: [NewsModel]?, _ error: Error?) -> Void)) {
        let requestMethod = TSNewsNetworkRequest().getNews
        var parameter: Dictionary<String, Any> = [:]
        parameter["cate_id"] = tagID
        if let maxID = maxID {
            parameter["after"] = maxID
        }
        if let limit = limit {
            parameter["limit"] = limit
        }
        if isCheckCommend == true {
            // 当检索推荐信息时,撤销别的请求参数,保证返回所有的推荐信息,组成推荐页面
            parameter.removeValue(forKey: "cate_id")
            parameter.removeValue(forKey: "key")
            parameter["recommend"] = 1
        }
        if let searchKey = searchKey {
            // 当搜索资讯时,撤销别的请求参数,保证搜索所有的信息,组成搜索页面
            parameter.removeValue(forKey: "cate_id")
            parameter.removeValue(forKey: "recommend")
            parameter["key"] = searchKey
        }
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: parameter, complete: { (networkResponse, result) in
            guard result else {
                complete(nil, TSErrorCenter.create(With: .networkError))
                return
            }
            guard let newsModels = Mapper<NewsModel>().mapArray(JSONObject: networkResponse) else {
                assert(false, "返回了无法解析的数据")
                complete(nil, TSErrorCenter.create(With: .networkError))
                return
            }
            complete(newsModels, nil)
        })
    }

    /// 获取置顶资讯信息
    class func getTopNewsListData(tagID: Int, complete: @escaping((_ info: [TopNewsModel]?, _ error: Error?) -> Void)) {
        let requestMethod = TSNewsNetworkRequest().getTopNews
        var parameter: Dictionary<String, Any> = [:]
        parameter["cate_id"] = tagID
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: parameter, complete: { (networkResponse, result) in
            guard result else {
                complete(nil, TSErrorCenter.create(With: .networkError))
                return
            }
            guard let newsModels = Mapper<TopNewsModel>().mapArray(JSONObject: networkResponse) else {
                assert(false, "返回了无法解析的数据")
                complete(nil, TSErrorCenter.create(With: .networkError))
                return
            }
            complete(newsModels, nil)
        })
    }

    /// 获取单条资讯的详情
    ///
    /// - Parameters:
    ///   - id: 资讯id
    ///   - complate: 结果
    func requesetNews(newsID id: Int, complete: @escaping((_ data: NewsDetailModel?, _ error: Error?, _ code: Int?) -> Void)) {
        let requestMethod = TSNewsNetworkRequest().newsDetail

        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(id)"), parameter: nil, complete: { (networkResponse, result, code) in
            guard result else {
                complete(nil, TSErrorCenter.create(With: .networkError), code)
                return
            }
            guard let newsModels = Mapper<NewsDetailModel>().map(JSONObject: networkResponse) else {
                assert(false, "返回了无法解析的数据")
                complete(nil, TSErrorCenter.create(With: .networkError), code)
                return
            }
            complete(newsModels, nil, code)
        })
    }

    /// 获取相关资讯
    ///
    /// - Parameters:
    ///   - newsID: 资讯标识
    ///   - limit: 获取资讯条数
    ///   - complete: 获取结果
    func requestCorrelative(newsID: Int, limit: Int, complete: @escaping((_ data: [NewsModel]?, _ error: Error?) -> Void)) {
        let requestMethod = TSNewsNetworkRequest().newsCorrelative
        var parameter = [String: Any]()
        parameter["limit"] = limit

        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replacers: ["\(newsID)"]), parameter: parameter, complete: { (networkResponse, result) in
            guard result else {
                complete(nil, TSErrorCenter.create(With: .networkError))
                return
            }
            guard let models = Mapper<NewsModel>().mapArray(JSONObject: networkResponse) else {
                assert(false, "返回了无法解析的数据")
                complete(nil, TSErrorCenter.create(With: .networkError))
                return
            }
            complete(models, nil)
        })
    }

    // MARK: - 收藏
    /// 收藏/取消收藏某条动态
    ///
    /// - Parameters:
    ///   - status: true 收藏, false 取消收藏
    ///   - newsId: 资讯标识
    ///   - complete: 响应结果
    func colloction(_ newState: Bool, newsID id: Int, _ complete: @escaping((_ message: String?, _ error: NSError?) -> Void)) {
        let requestPath = TSNewsNetworkRequest().collection
        let type = newState == true ? HTTPMethod.post : HTTPMethod.delete
        try! RequestNetworkData.share.textRequest(method: type, path: requestPath.fullPathWith(replace: "\(id)"), parameter: nil, complete: { (networkResponse, result) in
            if result == true, let response = networkResponse as? String {
                complete(response, nil)
                return
            }
            complete(nil, TSErrorCenter.create(With: .networkError))
        })
    }

    /// 获取收藏资讯
    ///
    /// - Parameters:
    ///   - MaxID: 分页标记
    ///   - limit: 数据量
    ///   - complate: 结果
    func request(conllectionNews maxID: Int?, limit: Int?, complete:@escaping(_ datas: [NewsModel]?, _ error: Error?) -> Void) {
        let requestMethod = TSNewsNetworkRequest().collectionList
        var parameter: Dictionary<String, Any> = [:]
        if let maxID = maxID {
            parameter["after"] = maxID
        }
        if let limit = limit {
            parameter["limit"] = limit
        }

        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: parameter, complete: { (networkResponse, result) in
            guard result else {
                complete(nil, TSErrorCenter.create(With: .networkError))
                return
            }
            guard let newsModels = Mapper<NewsModel>().mapArray(JSONObject: networkResponse) else {
                assert(false, "返回了无法解析的数据")
                complete(nil, TSErrorCenter.create(With: .networkError))
                return
            }
            complete(newsModels, nil)
        })
    }

    // MARK: - 点赞/取消点赞
    /// 点赞,取消赞接口
    ///
    /// - Parameters:
    ///   - status: true 点赞, false 取消赞
    ///   - newsId: 资讯标识
    ///   - complete: 响应结果
    func like(_ status: Bool, newsId: Int, complete: @escaping((_ success: Bool) -> Void)) {
        let request = TSNewsNetworkRequest().like
        let method: HTTPMethod = status == true ? .post : .delete
        try! RequestNetworkData.share.textRequest(method: method, path: request.fullPathWith(replacers: ["\(newsId)"]), parameter: nil, complete: { (_, result) in
            complete(result)
        })
    }

    func likeList(newsId: Int, after: Int = 0, limit: Int = TSAppConfig.share.localInfo.limit, complete: @escaping((_ data: [TSLikeUserModel]?, _ error: NetworkError?) -> Void)) {
        let requestMethod = TSNewsNetworkRequest().likeList
        var parameter = [String: Any]()
        parameter["limit"] = limit
        parameter["after"] = after

        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replacers: ["\(newsId)"]), parameter: parameter) { (datas: NetworkResponse?, status: Bool) in
            guard status == true else {
                complete(nil, .networkErrorFailing)
                return
            }

            guard let likeList = datas as? [Dictionary<String, Any>] else {
                complete(nil, .networkErrorFailing)
                return
            }
            let users = Mapper<TSLikeUserModel>().mapArray(JSONArray: likeList)
            complete(users, nil)
        }
    }

    // MARK: - 打赏
    func reward(price: Int, newsId: Int, complete: @escaping((_ message: String?, _ result: Bool) -> Void)) {
        guard price > 0 else {
            assert(false, "打赏金额小于0")
            return
        }
        let requestMethod = TSNewsNetworkRequest().reward
        var parameter: [String : Any] = ["amount": price]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parameter.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }

        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(newsId)"), parameter: parameter, complete: { (networkResponse, result) in
            // 请求失败处理
            guard result else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                complete(message, result)
                return
            }
            // 请求成功处理
            let message = TSCommonNetworkManager.getNetworkSuccessMessage(with: networkResponse) ?? "打赏成功"
            complete(message, result)
        })
    }

    // 打赏列表
    func rewardList(newsID: Int, maxID: Int?, complete: @escaping((_ data: [TSNewsRewardModel]?, _ result: Bool) -> Void)) {
        guard newsID > 0 else {
            assert(false, "打赏金额小于0")
            return
        }
        let requestMethod = TSNewsNetworkRequest().rewardList
        var parameter: Dictionary<String, Any> = ["limit": 10]
        if let maxID = maxID {
            parameter["since"] = maxID
        }
        parameter["order"] = "desc"
        parameter["order_type"] = "date"
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(newsID)"), parameter: parameter, complete: { (networkResponse, result) in
            guard result == true else {
                complete(nil, false)
                return
            }
            let data = Mapper<TSNewsRewardModel>().mapArray(JSONObject: networkResponse)
            complete(data, true)
        })
    }

    // 打赏统计
    func rewardCount(newsID: Int, complete: @escaping((_ data: TSNewsRewardCountModel?, _ result: Bool) -> Void)) {
        guard newsID > 0 else {
            assert(false, "打赏金额小于0")
            return
        }
        let requestMethod = TSNewsNetworkRequest().rewardsCount
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(newsID)"), parameter: nil, complete: { (networkResponse, result) in
            guard result == true else {
                complete(nil, false)
                return
            }
            let data = Mapper<TSNewsRewardCountModel>().map(JSONObject: networkResponse)
            complete(data, true)
        })
    }
}

// MARK: - API重构

extension TSNewsNetworkManager {
    /// 获取所有的栏目数据/资讯分类列表
    func getAllNewsCategory(complete: @escaping ((_ subscribedCategoryList: [TSNewsCategoryModel]?, _ unsubscribedCategoryList: [TSNewsCategoryModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        let requestPath = TSURLPathV2.path.rawValue + TSURLPathV2.newsCates.rawValue
        // 2. 请求
        try! RequestNetworkData.share.textRequest(method: .get, path: requestPath, parameter: nil, complete: { (data, status) in
            var message: String?
            guard status else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, nil, message, status)
                return
            }
            guard let dataDic = data as? [String: Any] else {
                message = "服务器返回数据异常"
                complete(nil, nil, message, false)
                return
            }
            let subscribedCategoryList = Mapper<TSNewsCategoryModel>().mapArray(JSONObject: dataDic["my_cates"])
            let unsubscribedCategoryList = Mapper<TSNewsCategoryModel>().mapArray(JSONObject: dataDic["more_cates"])
            complete(subscribedCategoryList, unsubscribedCategoryList, message, status)
        })
    }

    /// 获取所有的用户标签
    func getAllUserTags(complete: @escaping ((_ tagCategoryList: [TSTagCategoryModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        let requestMethod = TSUserlabelRequest().allTagsList
        // 2. request
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPath(), parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                let tagCategoryList = Mapper<TSTagCategoryModel>().mapArray(JSONObject: data)
                complete(tagCategoryList, message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, status)
            }
        })
    }
}

// MARK: - 资讯投稿相关

extension TSNewsNetworkManager {

    /// 提交资讯投稿——模型方式
    func submitNews(newsContribute: TSNewsContributeModel, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        let model = newsContribute
        // 内容判断
        guard let categoryId = model.selectedCategory?.id, let title = model.title, let markdown = model.content_markdown, let content = model.content_text, let tags = model.selectedTagList else {
            complete("资讯投稿参数不全", false)
            return
        }
        // 封面判断获取
        var coverId: Int?
        if let coverFileId = model.coverFileId {
            coverId = coverFileId
        } else if let firstImageId = model.firstImageId {
            coverId = firstImageId
        }
        // 标签
        var tagList: [Int] = [Int]()
        for tag in tags {
            tagList.append(tag.id)
        }
        self.submitNews(categoryId: categoryId, title: title, abstract: model.abstract, content_markdown: markdown, content_text: content, coverId: coverId, tags: tagList, source: model.source, author: model.author, complete: complete)
    }
    /// 提交资讯投稿——数据方式
    func submitNews(categoryId: Int, title: String, abstract: String?, content_markdown: String, content_text: String, coverId: Int?, tags: [Int], source: String?, author: String?, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 0. 异常判断
        if tags.isEmpty {
            complete("资讯投稿 - 标签数组不能为空", false)
            return
        }
        // 1. url
        let requestMethod = TSNewsContributeNetworkMethod().submitNews
        // 2. 参数拼接
        var parmas: [String: Any] = [String: Any]()
        // 必填参数
        parmas.updateValue(title, forKey: "title")
        parmas.updateValue(tags.convertToString()!, forKey: "tags")
        parmas.updateValue(content_markdown, forKey: "content")
        parmas.updateValue(content_text, forKey: "text_content")
        // 摘要不为空时的处理
        if nil != abstract && abstract! != "" {
            parmas.updateValue(abstract! as String, forKey: "subject")
        }
        // 封面缩略图 可以不传
        if let coverId = coverId {
            parmas.updateValue(coverId, forKey: "image")
        }
        // 选填参数
        if let source = source {
            parmas.updateValue(source, forKey: "from")
        }
        if let author = author {
            parmas.updateValue(author, forKey: "author")
        }
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parmas.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        // 3. 请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(categoryId)"), parameter: parmas, complete: { (data, status) in
            var message: String?
            if status {
                message = TSCommonNetworkManager.getNetworkSuccessMessage(with: data)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

    /// 修改资讯投稿
    class func updateNews(news: TSNewsContributeModel, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. 各个选项处理
        let model = news
        guard let newsId = model.newsId, let categoryId = model.selectedCategory?.id, let title = model.title, let markdown = model.content_markdown, let content = model.content_text, let tags = model.selectedTagList else {
            complete("修改资讯投稿参数不全", false)
            return
        }
        // 封面判断获取
        var coverId: Int?
        if let coverFileId = model.coverFileId {
            coverId = coverFileId
        } else if let firstImageId = model.firstImageId {
            coverId = firstImageId
        }
//        // 封面没有改变，则不需要传入封面字段
//        if coverId == model.originCoverId {
//            coverId = nil
//        }
        // 标签
        var tagList: [Int] = [Int]()
        for tag in tags {
            tagList.append(tag.id)
        }
        // 2. request
        self.updateNews(newsId: newsId, categoryId: categoryId, title: title, abstract: model.abstract, content_markdown: markdown, content_text: content, coverId: coverId, tags: tagList, source: model.source, author: model.author, complete: complete)
    }
    /// 重载修改资讯投稿的请求
    class func updateNews(newsId: Int, categoryId: Int, title: String, abstract: String?, content_markdown: String, content_text: String, coverId: Int?, tags: [Int], source: String?, author: String?, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 0. 异常判断
        if tags.isEmpty {
            complete("资讯投稿 - 标签数组不能为空", false)
            return
        }
        // 1. url
        var request = TSNewsNetworkRequest.updateNews
        request.urlPath = request.fullPathWith(replacers: ["\(categoryId)", "\(newsId)"])
        // 2. 参数拼接
        var parmas: [String: Any] = [String: Any]()
        // 必填参数
        parmas.updateValue(title, forKey: "title")
        parmas.updateValue(tags.convertToString()!, forKey: "tags")
        parmas.updateValue(content_markdown, forKey: "content")
        parmas.updateValue(content_text, forKey: "text_content")
        // 摘要不为空时的处理
        if nil != abstract && abstract! != "" {
            parmas.updateValue(abstract! as String, forKey: "subject")
        }
        // 封面缩略图 可以不传
        if let coverId = coverId {
            parmas.updateValue(coverId, forKey: "image")
        }
        // 选填参数
        if let source = source {
            parmas.updateValue(source, forKey: "from")
        }
        if let author = author {
            parmas.updateValue(author, forKey: "author")
        }
        request.parameter = parmas
        // 3. 请求
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete("网络请求错误", false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(let data):
                complete(data.message, true)
            }
        }
    }
}

// MARK: - 资讯评论置顶
extension TSNewsNetworkManager {
    /// 申请资讯评论置顶
    func applyCommentTop(newsId: Int, commentId: Int, day: Int, amount: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.url
        let requestMethod = TSNewsCommentNetworkMethod().applyCommentTop
        // 2.params
        var parametars: [String: Any] = ["day": day, "amount": amount]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parametars.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        // 3.request
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(newsId)/comments/\(commentId)"), parameter: parametars, complete: { (data, status) in
            var message: String?
            // 处理后台返回数据
            if status {
                message = TSCommonNetworkManager.getNetworkSuccessMessage(with: data)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

    /// 同意资讯评论置顶
    /// 拒绝资讯评论置顶
    /// 查看资讯中申请置顶的评论列表
    /// 取消置顶
}

extension TSNewsNetworkManager {
    /// 申请置顶资讯
    ///
    /// - Parameters:
    ///   - newsID: 资讯标识
    ///   - day: 置顶天数
    ///   - amount: 置顶价格
    ///   - complete: 响应数据
    func newsApplyToTop(newsID: Int, day: Int, amount: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) {
        let requestMethod = TSNewsNetworkRequest().newsApplyTop
        var parametars: [String: Any] = ["day": day, "amount": amount]
        if TSAppConfig.share.localInfo.shouldShowPayAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                parametars.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replacers: ["\(newsID)"]), parameter: parametars, complete: { (data, status) in
            var message: String?
            // 处理后台返回数据
            if status {
                message = TSCommonNetworkManager.getNetworkSuccessMessage(with: data)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

    func deletePostNews(newsId: Int, category: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) {
        let requestMethod = TSNewsNetworkRequest().deletePostNews

        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(category)/news/\(newsId)"), parameter: nil, complete: { (data, status) in
            var message: String?
            // 处理后台返回数据
            if status {
                message = TSCommonNetworkManager.getNetworkSuccessMessage(with: data)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

    // MARK: - 管理员删除资讯
    func managerDeletePostNews(newsId: Int, category: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) {
        let requestMethod = TSNewsNetworkRequest().managerDeletePostNews
        
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(newsId)"), parameter: nil, complete: { (data, status) in
            var message: String?
            // 处理后台返回数据
            if status {
                message = TSCommonNetworkManager.getNetworkSuccessMessage(with: data)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }
}
