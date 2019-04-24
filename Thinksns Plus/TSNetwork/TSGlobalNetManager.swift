//
//  TSGlobalNetManager.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/9/8.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TSGlobalNetManager: NSObject {
    /// 上传图片
    class func uploadImage(data: Data, fileName: String = "plus.jpeg", mimeType: String = "image/jpeg", channel: String = "public", complete: @escaping ((_ node: String?, _ msg: String?, _ status: Bool) -> Void) ) {
        TSGlobalNetManager().uploadRequest(data: data, fileName: fileName, mimeType: mimeType, channel: channel) { (node, msg, status) in
            complete(node, msg, status)
        }
    }
    /// 上传文件
    class func uploadFile(data: Data, fileName: String = "plus.jpeg", mimeType: String = "image/jpeg", channel: String = "public", complete: @escaping ((_ node: String?, _ msg: String?, _ status: Bool) -> Void)) {
        TSGlobalNetManager().uploadRequest(data: data, fileName: fileName, mimeType: mimeType, channel: channel) { (node, msg, status) in
            complete(node, msg, status)
        }
    }
    /// 创建上传任务并完整data上传
    /// data: 上传的文件数据，先创建一个上传任务，然后根据上传任务进行上传
    /// complete: 完成的回调,
    fileprivate func uploadRequest(data: Data, fileName: String = "plus.jpeg", mimeType: String = "image/jpeg", channel: String = "public", complete: @escaping ((_ node: String?, _ msg: String?, _ status: Bool) -> Void)) {
        let hash = data.md5().toHexString()
        var request = Request<Empty>(method: .post, path: "storage", replacers: [])
        request.urlPath = request.fullPathWith(replacers: [])
        var params: [String:Any] = [:]
        params.updateValue(fileName, forKey: "filename")
        params.updateValue(hash, forKey: "hash")
        params.updateValue(data.count, forKey: "size")
        params.updateValue(mimeType, forKey: "mime_type")
        params.updateValue(["channel": channel], forKey: "storage")
        request.parameter = params
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "网络请求错误", false)
            case .failure(let response):
                if response.statusCode == 404 {
                    complete(nil, "网络请求错误", false)
                } else {
                    complete(nil, response.message, false)
                }
            case .success(let reponse):
                if let result = reponse.sourceData as? Dictionary<String, Any> {
                    if let uri = result["uri"] as? String, let method = result["method"] as? String, let headers = result["headers"] as? Dictionary<String, Any> {
                        var requestMethod: HTTPMethod = .put
                        if method == "PUT" {
                            requestMethod = .put
                        } else if method == "POST" {
                            requestMethod = .post
                        } else if method == "PATCH" {
                            requestMethod = .patch
                        } else {
                            complete(nil, "上传方式不支持", false)
                        }
                        //
                        //  "form": null, // 上传时候的表单，如果是 NULL 则表示整个 Body 是二进制文件流，如果是对象，则构造 `application/form-data` 表单对象
                        //  "file_key": null, // 如果存在 `form` 表单信息，文件流所使用的 key 名称
                        if let fileKey = result["file_key"] as? String, let form = result["form"] as? Dictionary<String, Any> {
                            /*
                             Alamofire.upload(multipartFormData
                             */
                            TSLogCenter.log.debug(fileKey)
                            TSLogCenter.log.debug(form)
                            complete(nil, "上传类型不支持", false)
                        } else {
                            /// header必须是[String,String]类型，但是服务器返回的字段中有Int的value，所以需要转换一下
                            var coustomHeaders: HTTPHeaders = [:]
                            for key in headers.keys {
                                if let Headervalue = headers[key] as? String {
                                    coustomHeaders.updateValue(Headervalue, forKey: key)
                                } else if let Headervalue = headers[key] as? Int {
                                    coustomHeaders.updateValue(String(Headervalue), forKey: key)
                                }
                            }
                            let uploadRequest = Alamofire.upload(data, to: uri, method: requestMethod, headers: coustomHeaders)
                            /// 上传进度
                            uploadRequest.uploadProgress(closure: { (progress) in
                                TSLogCenter.log.debug(progress)
                            })
                            uploadRequest.responseString(completionHandler: { (response) in
                                TSLogCenter.log.debug(response)
                                let responseResult = response.result
                                if responseResult.isSuccess {
                                    let resResult = response.value
                                    let jsonData = resResult?.data(using: String.Encoding.utf8, allowLossyConversion: false)
                                    if let jsonData = jsonData {
                                        let jsonObj = JSON(data: jsonData)
                                        if let resultDic = jsonObj.dictionary, let node = resultDic["node"]?.rawString() {
                                            complete(node, "上传成功", true)
                                        }
                                    } else {
                                        complete(nil, "返回node为空", false)
                                    }
                                } else {
                                    complete(nil, "网络请求错误", false)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
}
