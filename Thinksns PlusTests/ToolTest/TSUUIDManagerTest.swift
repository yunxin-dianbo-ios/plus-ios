//
//  TSUUIDManagerTest.swift
//  Thinksns Plus
//
//  Created by lip on 2017/1/5.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  TSUUIDManagerTest

@testable import Thinksns_Plus
import Nimble

class TSUUIDManagerTest: TSTestCase {

    override func setUp() {
        super.setUp()
        TSUUIDManager().resetUUID()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        TSUUIDManager().resetUUID()
    }

    func testBeforeSave() {
        let readUUID = TSUUIDManager().readUUID()
        expect(readUUID).to(beNil())
    }

    func testSave() {
        TSUUIDManager().saveUUID(UUID: "123")
        let readUUID = TSUUIDManager().readUUID()
        expect(readUUID).to(equal("123"))
    }

}
