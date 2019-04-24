//
//  TSDataBaseTest.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/23.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import XCTest
import Nimble
import RealmSwift
@testable import Thinksns_Plus

class TSDataBaseTest: TSTestCase {

    override func setUp() {
        super.setUp()
        TSDatabaseManager().chat.deleteAll()
        TSDatabaseManager().user.deleteAll()
    }

    override func tearDown() {
        super.tearDown()
        TSDatabaseManager().chat.deleteAll()
        TSDatabaseManager().user.deleteAll()
    }

    func testSave() {
        let object = TSMessageObject()
        object.messageContent = "mock"
        object.timeStamp = 111
        TSDatabaseManager().chat.save(message: object)
        let savedObject = TSDatabaseManager().chat.getMessageObject(with: 111)
        expect(savedObject?.messageContent).to(equal("mock"))
    }

}
