//
//  TSRequestTask.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/1.
//  Copyright © 2017年 Lius. All rights reserved.
//

import Foundation

protocol TSRequestTaskDelegate: class {

    func requestTaskDidUpdateCache() /// 缓冲进度更新

    func requestTaskDidReceiveResponse()
    func requestTaskDidFinishLoading(WithCache cache: Bool)
    func requestTaskDidFail(WithError error: Error)
}

class TSRequestTask: NSObject, NSURLConnectionDataDelegate, URLSessionDataDelegate {
    /// 会话对象
    var session: URLSession? = nil
    /// 任务
    var task: URLSessionDataTask? = nil
    /// 代理
    weak var delegate: TSRequestTaskDelegate? = nil
    /// 请求地址
    var requestUrl: URL? = nil
    /// 请求起始位置
    var requestOffset: Int64 = 0
    /// 文件长度
    var fileLength: Int = 0
    /// 缓冲长度
    var cacheLength: Int64 = 0
    /// 是否缓存文件
    var cache: Bool = false
    /// 是否取消请求
    var cancel: Bool = false

    override init() {
        super.init()
        _ = TSFileHandle.createTempFile()
    }
    /// 开始任务
    func star() {
        let request = NSMutableURLRequest(url: (self.requestUrl?.musicOriginalSchemeURL())!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10.0)
        if self.requestOffset > 0 {
            request.addValue("bytes=" + String(describing: self.requestOffset) + "-" + String(self.fileLength - 1), forHTTPHeaderField: "Range")
        }
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        self.task = self.session?.dataTask(with: request as URLRequest)
        self.task?.resume()
    }
    /// 取消任务
    func setCancel(cancel: Bool) {
        self.cancel = cancel
        self.task?.cancel()
        self.session?.invalidateAndCancel()
    }
// MARK: - NSURLSessionDataDelegate
// MARK: 服务器响应
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if self.cancel {
            return
        }
        print("response: \(response)")
        completionHandler(URLSession.ResponseDisposition.allow)
        let httpResponse = response as? HTTPURLResponse
        let contentRange = httpResponse?.allHeaderFields["Content-Range"] as? String
        if contentRange != nil {
            let fileLength: String? = contentRange?.components(separatedBy: "/").last
            if fileLength == nil {
                self.fileLength = Int(response.expectedContentLength)
            } else if Int(fileLength!)! > 0 {
                self.fileLength = Int(fileLength!)!
            }
        } else {
            self.fileLength = Int(response.expectedContentLength)
        }
        if let delegate = self.delegate {
            delegate.requestTaskDidReceiveResponse()
        }
    }
// MARK: 服务器返回数据 （可能会多次调用）
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if self.cancel {
            return
        }
        TSFileHandle.writeTempFileData(data: data)
        self.cacheLength = self.cacheLength + Int64(data.count)
        if let delegate = self.delegate {
            delegate.requestTaskDidUpdateCache()
        }
    }
// MARK: 请求完成
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if self.cancel {
            /// 取消下载
        } else {
            if error != nil {
                if let delegate = self.delegate {
                    delegate.requestTaskDidFail(WithError: error!)
                }
            } else {
                if self.cache {
                    TSFileHandle.cacheTempFile(WithFileName: String.musicfileNameWithURL(url: self.requestUrl!))
                }
                if let delegate = self.delegate {
                    delegate.requestTaskDidFinishLoading(WithCache: self.cache)
                }
            }
        }
    }
}
