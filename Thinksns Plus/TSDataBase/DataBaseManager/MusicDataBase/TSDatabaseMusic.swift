//
//  TSDatabaseMusic.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//  音乐模块数据库相关
//

import UIKit
import RealmSwift

class TSDatabaseMusic {

    fileprivate let realm: Realm!

    // MARK: - Lifecycle
    convenience init() {
        let realm = try! Realm()
        self.init(realm)
    }

    /// 可以替换掉内部数据的初始化方法,用于测试
    ///
    /// - Parameter realm: 数据库
    init(_ realm: Realm) {
        self.realm = realm
    }

    // MAKR: - 删除所有音乐相关的数据库
    func deleteAll() {
        // 删除专辑列表
        self.deleteAllAlbumList()
        // 删除专辑详情
        self.deleteAllAlbumDetail()
        // 删除歌曲
        self.deleteAllSong()
    }
}

// MARK: - 专辑

extension TSDatabaseMusic {
    // MARK: - 资源重定向

    /// 保存音乐资源重定向后的地址
    ///
    /// - Parameter urlPath: 重定向的地址
    func save(musicRedirectionURLPath urlPath: String, musicID id: Int) {
        try! realm.write {
            realm.create(TSMusicSourceRedirectionUrlObject.self, value: ["musicStorage": id, "redirectionPath": urlPath], update: true)
        }
    }

    /// 查询数据库中保存的重定向地址
    ///
    /// - Parameters:
    ///   - id: 音乐资源id
    ///   - complate: 结果
    func select(musicRedirectionURLPathWithMusicID id: Int, complate:@escaping(_ urlPath: String?) -> Void) {
        var object = realm.objects(TSMusicSourceRedirectionUrlObject.self)
        object = object.filter("musicStorage = \(id)")
        if object.isEmpty {
            complate(nil)
            return
        }
        complate(object.first?.redirectionPath)
    }

    // MARK: - 专辑列表

    /// 获取专辑列表
    func getAlbumList(maxId: Int, limit: Int = TSAppConfig.share.localInfo.limit) -> [TSAlbumListModel] {
        // 默认id降序方式
        var objects = realm.objects(TSAlbumListObject.self).sorted(byKeyPath: "id", ascending: false)
        if maxId > 0 {
            objects = objects.filter("id < \(maxId)")
        }
        var modelList = [TSAlbumListModel]()
        var i: Int = 0
        for object in objects {
            if i < limit {
                modelList.append(TSAlbumListModel(object: object))
            }
            i += 1
        }
        return modelList
    }

    /// 存储专辑列表
    func saveAlbumList(_ list: [TSAlbumListModel]) -> Void {
        // 方案1：构建objectList，使用下面的重载方法
        // 方案2：遍历，单个model -> object，再存储
        for model in list {
            realm.beginWrite()
            realm.add(model.object(), update: true)
            try! realm.commitWrite()
        }
    }
    /// 重载 存储专辑列表
    func saveAlbumList(_ list: [TSAlbumListObject]) -> Void {
        realm.beginWrite()
        realm.add(list, update: true)
        try! realm.commitWrite()
    }

    /// 修改单个专辑列表模型
    func updateAlbumList(wtih model: TSAlbumListModel) -> Void {
        self.updateAlbumList(with: model.object())
    }
    func updateAlbumList(with object: TSAlbumListObject) -> Void {
        realm.beginWrite()
        realm.add(object, update: true)
        try! realm.commitWrite()
    }

    /// 删除所有的专辑列表数据
    func deleteAllAlbumList() -> Void {
        let objects = realm.objects(TSAlbumListObject.self)
        try! realm.write {
            realm.delete(objects)
        }
    }

    // MARK: - 专辑详情

    /// 获取指定专辑详情
    func getAlbumDetail(with albumId: Int) -> TSAlbumDetailModel? {
        if let object = realm.object(ofType: TSAlbumDetailObject.self, forPrimaryKey: albumId) {
            let model = TSAlbumDetailModel(object: object)
            return model
        }
        return nil
    }

    /// 增加专辑详情
    func addAlbumDetail(_ model: TSAlbumDetailModel) -> Void {
        self.addAlbumDetail(model.object())
    }
    func addAlbumDetail(_ object: TSAlbumDetailObject) -> Void {
        realm.beginWrite()
        realm.add(object, update: true)
        try! realm.commitWrite()
    }

    /// 修改专辑详情
    func updateAlbumDetail(_ model: TSAlbumDetailModel) -> Void {
        self.addAlbumDetail(model)
    }
    func updateAlbumDetail(_ object: TSAlbumDetailObject) -> Void {
        self.addAlbumDetail(object)
    }

    /// 删除指定的专辑详情
    func deleteAlbumDetail(with albumId: Int) -> Void {
        guard let object = realm.object(ofType: TSAlbumDetailObject.self, forPrimaryKey: albumId) else {
            return
        }
        try! realm.write {
            realm.delete(object)
        }
    }

    /// 删除所有的专辑详情
    func deleteAllAlbumDetail() -> Void {
        let objects = realm.objects(TSAlbumDetailObject.self)
        try! realm.write {
            realm.delete(objects)
        }
    }

}

// MARK: - 歌曲/音乐

extension TSDatabaseMusic {
    /// 获取指定专辑下的歌曲列表
    func getSongList(with albumId: Int) -> [TSSongModel]? {
        return self.getAlbumDetail(with: albumId)?.musics
    }

    /// 获取指定歌曲
    func getSong(with musicId: Int) -> TSSongModel? {
        guard let object = realm.object(ofType: TSSongObject.self, forPrimaryKey: musicId) else {
            return nil
        }
        return TSSongModel(object: object)
    }

    /// 新增歌曲
    func addSong(_ model: TSSongModel) -> Void {
        self.addSong(model.object())
    }
    func addSong(_ object: TSSongObject) -> Void {
        realm.beginWrite()
        realm.add(object, update: true)
        try! realm.commitWrite()
    }

    /// 修改歌曲
    func updateSong(_ model: TSSongModel) -> Void {
        self.addSong(model)
    }
    func updateSong(_ object: TSSongObject) -> Void {
        self.addSong(object)
    }

    /// 删除指定的歌曲
    func deleteSong(with songId: Int) -> Void {
        guard let object = realm.object(ofType: TSSongObject.self, forPrimaryKey: songId) else {
            return
        }
        try! realm.write {
            realm.delete(object)
        }
    }

    /// 删除所有的歌曲
    func deleteAllSong() -> Void {
        let objects = realm.objects(TSSongObject.self)
        try! realm.write {
            realm.delete(objects)
        }
    }

}
