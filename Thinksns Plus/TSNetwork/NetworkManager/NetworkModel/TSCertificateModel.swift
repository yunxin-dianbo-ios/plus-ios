//
//  TSCertificateModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import ObjectMapper

struct TSCertificateFileModel: Mappable {
    var file: Int = 0
    var size: CGSize = CGSize.zero
    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        file <- map["file"]
        size <- (map["size"], CGSizeTransform())
    }
}

struct TSCertificateModel: Mappable {

    /// 认证类型
    var type = ""
    /// 认证状态: 0 - 待审核, 1 - 通过, 2 - 拒绝
    var status = -1
    /// 姓名
    var name = ""
    /// 电话
    var phone = ""
    /// 数字
    var number = ""
    /// 描述
    var desc = ""
    /// 图片
    var files: [Int] {
        var ints = [Int]()
        for file in FileModel {
            ints.append(file.file)
        }
        return ints
    }
    /// 图片原始尺寸
    var fileSizes: [CGSize] {
        var sizes = [CGSize]()
        for file in FileModel {
            sizes.append(file.size)
        }
        return sizes
    }
    /// 企业名称
    var orgName: String?
    /// 企业地址
    var orgAddress: String?
    /// 图片信息
    var FileModel: [TSCertificateFileModel] = []

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        type <- map["certification_name"]
        status <- map["status"]
        name <- map["data.name"]
        phone <- map["data.phone"]
        number <- map["data.number"]
        desc <- map["data.desc"]
        FileModel <- map["files"]
        orgName <- map["data.org_name"]
        orgAddress <- map["data.org_address"]
    }

    func object() -> TSUserCertificateObject {
        let object = TSUserCertificateObject()
        object.type = type
        object.status = status
        object.name = name
        object.phone = phone
        object.number = number
        object.desc = desc
        for (index, file) in files.enumerated() {
            let image = TSImageObject()
            image.storageIdentity = file
            if fileSizes.isEmpty == false {
                image.width = fileSizes[index].width
                image.height = fileSizes[index].height
            }
            object.files.append(image)
        }
        object.orgName = orgName ?? ""
        object.orgAddress = orgAddress ?? ""
        return object
    }
}
