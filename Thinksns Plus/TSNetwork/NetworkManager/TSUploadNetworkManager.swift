//
//  TSUploadNetworkManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 16/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  上传文件的网络请求
//  TODO: 上传前检查 上传文件中 分类型上"文件 图片 头像" 需要整合

import Foundation
import Kingfisher
import CryptoSwift
import Alamofire

class TSUploadNetworkManager {
    /// 默认图片压缩后最大物理体积200kb
    fileprivate static let postImageMaxSizeKb: CGFloat = 200
    /// 上传检查
    /// data: 上传的文件数据
    /// complete: 完成的回调,
    ///           existId 若文件存在则提取文件的id， isExist 文件是否存在
    private func uploadCheck(data: Data, complete: @escaping ((_ existId: Int?, _ isExist: Bool?, _ msg: String?, _ status: Bool) -> Void) ) -> Void {
        let hash = data.md5().toHexString()
        var request = ApplicationNetworkRequest().checkFile
        request.urlPath = request.fullPathWith(replacers: [hash])

        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, nil, "网络请求错误", false)
            case .failure(let response):
                if response.statusCode == 404 {
                    complete(nil, false, nil, true)
                } else {
                    complete(nil, nil, response.message, false)
                }
            case .success(let reponse):
                if let result = reponse.sourceData as? Dictionary<String, Any> {
                    let id = result["id"] as? Int
                    complete(id, true, nil, true)
                    return
                }
                assert(false, "服务器响应了无法解析的数据")
                complete(nil, nil, "网络请求错误", false)
            }
        }
    }

    /// 上传文件
    /// imageField = "file"
    // 文件或图片时传file，头像传avatar
    func uploadVideoFile(data: Data, fileField: String = "file", videoSize: CGSize, complete: @escaping ((_ fileId: Int?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 请求1. 上传检查
        self.uploadCheck(data: data) { (existId, isExist, msg, status) in
            // 请求出错
            guard status, let isExist = isExist else {
                complete(nil, msg, false)
                return
            }
            // 已存在
            if isExist {
                complete(existId!, msg, status)
                return
            }

            // 请求2. 上传文件
            // 构建请求的url
            let rootURL = TSAppConfig.share.rootServerAddress
            let requestPath: String = rootURL + TSURLPathV2.path.rawValue + TSURLPathV2.UploadFile.files.rawValue
            // 自定义header
            let authorization = TSCurrentUserInfo.share.accountToken?.token
            var coustomHeaders: HTTPHeaders = ["Accept": "application/json"]
            if let authorization = authorization {
                let token = "Bearer " + authorization
                coustomHeaders.updateValue(token, forKey: "Authorization")
            }
            // 文件传
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(data, withName: fileField, fileName: "ios-video", mimeType: "video/mp4")
                multipartFormData.append("\(videoSize.height)".data(using: String.Encoding.utf8)!, withName: "height")
                multipartFormData.append("\(videoSize.width)".data(using: String.Encoding.utf8)!, withName: "width")
            }, usingThreshold: 0, to: requestPath, method: .post, headers: coustomHeaders) { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if response.result.isSuccess {
                            let resultDic = response.result.value as! Dictionary<String, Any>
                            if let requestId = resultDic["id"] as? Int {
                                complete(requestId, nil, true)
                            } else {
                                complete(nil, "数据解析异常", false)
                            }
                        } else {
                            complete(nil, (response.result.error as NSError?)?.localizedDescription, false)
                        }
                        TSLogCenter.log.verbose("http respond info \(response)")
                    }
                case .failure(let encodingError):
                    complete(nil, (encodingError as NSError?)?.localizedDescription, false)
                    TSLogCenter.log.verbose("http respond error \(encodingError)")
                }
            }
        }
    }

    /// 兼容旧的接口
    func uploadImage(image: UIImage, complete: @escaping ((_ fileId: Int?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        let originalImageData = UIImageJPEGRepresentation(image, 1)!
        let imageData = TSUtil.compressImageData(imageData: originalImageData, maxSizeKB: TSUploadNetworkManager.postImageMaxSizeKb)
        self.uploadFile(data: imageData, complete: complete)
    }

    /// 串行上传一组图片
    func upload(images: [UIImage], index: Int, finishIDs: [Int], complete: @escaping((_ fileIDs: [Int]) -> Void)) {
        guard let imgData = UIImageJPEGRepresentation(images[index], 1) else {
            complete([Int]())
            return
        }
        var fileID: Int?
        let group = DispatchGroup()
        var fileIDs = finishIDs
        group.enter()
        self.uploadFile(data: imgData) { (imgServerID, _, _) in
            fileID = imgServerID
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            guard let newID = fileID else {
                complete([Int]())
                return
            }
            fileIDs.append(newID)
            if fileIDs.count < images.count {
                self.upload(images: images, index: index + 1, finishIDs: fileIDs, complete: complete)
            } else {
                complete(fileIDs)
            }
        }
    }

    /// 为了兼容旧代码提供的API 后续合并
    func upload(imageDatas: [Data], mimeTypes: [String], index: Int, finishIDs: [Int], complete: @escaping((_ fileIDs: [Int]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            let mimeType = mimeTypes[index]
            let uploadData: Data = imageDatas[0]
            guard uploadData.isEmpty == false else {
                assertionFailure()
                return
            }
            var fileID: Int?
            let group = DispatchGroup()
            var fileIDs = finishIDs

            group.enter()
            TSUploadNetworkManager().uploadFile(data: uploadData, mimeType: mimeType) { (imgServerID, _, _) in
                fileID = imgServerID
                group.leave()
            }
            group.notify(queue: DispatchQueue.main) {
                guard let newID = fileID else {
                    complete([Int]())
                    return
                }
                fileIDs.append(newID)
                if fileIDs.count < mimeTypes.count {
                    var datas = imageDatas
                    datas.removeFirst()
                    TSUploadNetworkManager().upload(imageDatas: datas, mimeTypes: mimeTypes, index: index + 1, finishIDs: fileIDs, complete: complete)
                } else {
                    complete(fileIDs)
                }
            }
        }
    }
    ///

    /// 上传文件
    /// filekey在文件或图片时传file，头像传avatar,背景图上传是‘image’
    func uploadFile(data: Data, filekey: String = "file", fileName: String = "ios-file", path: String = TSURLPathV2.UploadFile.files.rawValue, mimeType: String = "image/jpeg", complete: @escaping ((_ fileId: Int?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 请求1. 上传检查
        TSUploadNetworkManager().uploadCheck(data: data) { (existId, isExist, msg, status) in
            // 请求出错
            guard status, let isExist = isExist else {
                complete(nil, msg, false)
                return
            }
            // 已存在
            if isExist {
                complete(existId!, msg, status)
                return
            }

            // 请求2. 上传文件
            // 构建请求的url
            let rootURL = TSAppConfig.share.rootServerAddress
            let requestPath: String = rootURL + TSURLPathV2.path.rawValue + path
            // 自定义header
            let authorization = TSCurrentUserInfo.share.accountToken?.token
            var coustomHeaders: HTTPHeaders = ["Accept": "application/json"]
            if let authorization = authorization {
                let token = "Bearer " + authorization
                coustomHeaders.updateValue(token, forKey: "Authorization")
            }
            // 文件传
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(data, withName: filekey, fileName: fileName, mimeType: mimeType)
            }, usingThreshold: 0, to: requestPath, method: .post, headers: coustomHeaders) { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if response.result.isSuccess {
                            if let resultDic = response.result.value as? Dictionary<String, Any>, let requestId = resultDic["id"] as? Int {
                                complete(requestId, nil, true)
                            } else {
                                complete(nil, "上传成功没有成功解析响应数据", true)
                            }
                        } else {
                            complete(nil, (response.result.error as NSError?)?.localizedDescription, false)
                        }
                        TSLogCenter.log.verbose("http respond info \(response)")
                    }
                case .failure(let encodingError):
                    complete(nil, (encodingError as NSError?)?.localizedDescription, false)
                    TSLogCenter.log.verbose("http respond error \(encodingError)")
                }
            }

        }
    }

}
