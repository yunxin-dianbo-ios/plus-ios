//
//  TSResourceLoader.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/1.
//  Copyright © 2017年 Lius. All rights reserved.
//

import Foundation
import AVFoundation
import MobileCoreServices

protocol TSResourceLoaderDelegate: class {
    func loader(loader: TSResourceLoader, cacheProgress progress: CGFloat)
    func loader(loader: TSResourceLoader, failLoadingWithError error: Error)
}

class TSResourceLoader: NSObject, AVAssetResourceLoaderDelegate, TSRequestTaskDelegate {
    /// 代理
    weak var delegate: TSResourceLoaderDelegate? = nil
    /// seek标识
    var seekRequired: Bool = false
    /// 缓存完成
    var cacheFinished: Bool = false
    /// 队列
    var requestList: [AVAssetResourceLoadingRequest] = []
    /// 任务
    var requestTask: TSRequestTask? = nil

    override init() {
        super.init()
    }

    func stopLoading() {
        self.requestTask?.cancel = true
    }

// MARK: - AVAssetResourceLoaderDelegate
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        self.addLoadingRequest(loadingRequest: loadingRequest)
        return true
    }
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        self.removeLoadingRequest(loadingRequest: loadingRequest)
    }
// MARK: - TSRequestTaskDelegate
    func requestTaskDidUpdateCache() {
        self.processRequestList()
        let cacheProgress = CGFloat((self.requestTask?.cacheLength)!) / (CGFloat((self.requestTask?.fileLength)!) - CGFloat((self.requestTask?.requestOffset)!))
        if let delegate = self.delegate {
            delegate.loader(loader: self, cacheProgress: cacheProgress)
        }
    }

    func requestTaskDidFinishLoading(WithCache cache: Bool) {
        self.cacheFinished = cache
    }

    func requestTaskDidFail(WithError error: Error) {
        print("error \(error)")
    }

    func requestTaskDidReceiveResponse() {
        print("TaskDidReceiveResponse")
    }

// MARK: - 处理LoadingRequest
    func addLoadingRequest(loadingRequest: AVAssetResourceLoadingRequest) {
        self.requestList.append(loadingRequest)
        objc_sync_enter(self)
        if self.requestTask != nil {
            if ((loadingRequest.dataRequest?.requestedOffset)! >= (self.requestTask?.requestOffset)!) && ((loadingRequest.dataRequest?.requestedOffset)! <= ((self.requestTask?.requestOffset)! + (self.requestTask?.cacheLength)!) ) {
                /// 数据已经缓存 直接完成
                self.processRequestList()
            } else {
                /// 数据还没缓存，则等待数据下载；如果是Seek操作，则重新请求
                if self.seekRequired {
                    self.newTask(withLoadingRequest: loadingRequest, isCache: false)
                }
            }
        } else {
            self.newTask(withLoadingRequest: loadingRequest, isCache: true)
        }
        objc_sync_exit(self)
    }

    func newTask(withLoadingRequest loadingRequest: AVAssetResourceLoadingRequest, isCache cache: Bool) {
        var fileLength: Int = 0
        if self.requestTask != nil {
            fileLength = (self.requestTask?.fileLength)!
            self.requestTask?.cancel = true
        }
        self.requestTask = TSRequestTask()
        self.requestTask?.requestUrl = loadingRequest.request.url
        self.requestTask?.requestOffset = (loadingRequest.dataRequest?.requestedOffset)!
        self.requestTask?.cache = cache
        if fileLength > 0 {
            self.requestTask?.fileLength = fileLength
        }
        self.requestTask?.star()
        self.requestTask?.delegate = self
        self.seekRequired = false
    }

    func removeLoadingRequest(loadingRequest: AVAssetResourceLoadingRequest) {
        self.requestList.remove(at: self.requestList.index(of: loadingRequest)!)
    }

    func processRequestList() {

        var finishRequestList: [AVAssetResourceLoadingRequest] = []
        for loadingRequest in self.requestList {
            if self.finishLoading(WithLoadingRequest: loadingRequest) {
                finishRequestList.append(loadingRequest)
            }
        }
        for loadRequest in finishRequestList {
            self.requestList.remove(at: self.requestList.index(of: loadRequest)!)
        }
    }

    func finishLoading(WithLoadingRequest loadingRequest: AVAssetResourceLoadingRequest) -> Bool {

        loadingRequest.contentInformationRequest?.contentType = "public.aac-audio"
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentLength = Int64(self.requestTask!.fileLength)

        let cacheLenght = self.requestTask?.cacheLength
        var requestedOffset: Int64 = (loadingRequest.dataRequest?.requestedOffset)!
        if loadingRequest.dataRequest?.currentOffset != 0 {
            requestedOffset = (loadingRequest.dataRequest?.currentOffset)!
        }
        let canReadLength = cacheLenght! - (requestedOffset - (self.requestTask?.requestOffset)!)
        let respondLength = min(canReadLength, Int64((loadingRequest.dataRequest?.requestedLength)!))
        let dataOffSet_abs = abs(requestedOffset - self.requestTask!.requestOffset)

        loadingRequest.dataRequest?.respond(with: TSFileHandle.readTempFileData(WithOffset:   UInt64(dataOffSet_abs), lenght: Int(respondLength)))

        let nowendOffset = requestedOffset + canReadLength
        let reqEndOffset = (loadingRequest.dataRequest?.requestedOffset)! + Int64((loadingRequest.dataRequest?.requestedLength)!)
        if nowendOffset >= reqEndOffset {
            loadingRequest.finishLoading()
            return true
        }
        return false
    }
}
