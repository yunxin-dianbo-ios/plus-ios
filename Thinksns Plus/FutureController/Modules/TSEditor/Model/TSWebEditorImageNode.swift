//
//  TSWebEditorImageNode.swift
//  ThinkSNS +
//
//  Created by 小唐 on 24/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  web编辑器中的图片节点
/**
 关于图片节点的描述：
 web编辑器中的图片节点：一张编辑器中展示的图片对应一个图片节点，上传成功则有一个fileId。暂时上传失败则删除，之后更正为上传失败的标记。
 web编辑器中的图片缓存节点：一张缓存中的图片文件对应一个图片缓存节点，同一张图片可以有多个fileId(后台处理的)。
 
 **/

import Foundation

/// web编辑器中的图片节点
class TSWebEditorImageNode {
    /// 图片序号
    var index: Int
    /// 图片名字 - 主要用于同TSEditorCacheImageNode进行联系起来
    var name: String
    /// 图片 - 主要用于重发
    var image: UIImage
    /// 图片上传成功后的文件id
    var fileId: Int?
    /// 是否上传成功
    var uploaded: Bool = false
    /// 图片的markdown描述 "@![image][fileId]"
    var markdown: String? {
        if let fileId = self.fileId {
            return "@![image][\(fileId)]"
        }
        return nil
    }
    /// 图片描述 alt + 图片底部输入框
    var desc: String? = nil

    init(index: Int, image: UIImage, name: String) {
        self.index = index
        self.image = image
        self.name = name
    }
}
