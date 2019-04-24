//
//  TSAdvertNetworkManager.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/1.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  广告相关网络请求

import UIKit

import ObjectMapper

class TSAdvertNetworkManager {

    let space = "{space_id}"

    /// 获取所有广告位
    func getAllAdPositionId(complete: @escaping ([TSAdSpaceObject]?) -> Void) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Advert.AdPositionId.rawValue
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil) { (response: NetworkResponse?, status: Bool) in
            guard let datas = response as? [[String: Any]], status else {
                complete(nil)
                return
            }
            var objects: [TSAdSpaceObject] = []
            for data in datas {
                let object = TSAdSpaceObject.object(for: data)
                objects.append(object)
            }
            complete(objects)
        }
    }

    /// 获取某个广告位所有的广告
    func getAd(spaceId: Int, complete: @escaping ([TSAdvertObject]?) -> Void) {
        var path = TSURLPathV2.path.rawValue + TSURLPathV2.Advert.detail.rawValue
        path = path.replacingOccurrences(of: space, with: "\(spaceId)")
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (responce: NetworkResponse?, _) in
            guard let datas = responce as? [[String: Any]] else {
                complete(nil)
                return
            }
            let objects = datas.flatMap { TSAdvertModel(JSON: $0)?.object() }
            complete(objects)
        })
    }

    // 批量获取所有广告位
    func getAd(spaceIds: [Int], complete: @escaping ([TSAdvertObject]?) -> Void) {
        let spaceStringIds = spaceIds.map { String($0) }
        let spaceString = spaceStringIds.joined(separator: ",")
        TSLogCenter.log.debug(spaceString)
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Advert.multipleDetails.rawValue + "?space=" + spaceString
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (responce: NetworkResponse?, _) in
            guard let datas = responce as? [[String: Any]] else {
                complete(nil)
                return
            }
            let objects = datas.flatMap { TSAdvertModel(JSON: $0)?.object() }
            complete(objects)
        })
    }
}
