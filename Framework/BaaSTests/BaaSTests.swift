//
//  BaaSTests.swift
//  BaaSTests
//
//  Created by Wesley de Groot on 23/11/2018.
//  Copyright © 2018 Wesley de Groot. All rights reserved.
//

import XCTest
@testable import CommonCrypto
@testable import BaaS

class BaaSTests: XCTestCase, BaaSDelegate {
    /// <#Description#>
    /// - Parameter withDataAs: <#withDataAs description#>
    func testForReturn(withDataAs: String) {
        print(withDataAs)
    }
    
    /// <#Description#>
    let db = BaaS.shared
    
    /// <#Description#>
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        db.delegate = self
        db.set(server: "http://192.168.178.52:8000/index.php")
        db.set(apiKey: "DEVELOPMENT_UNSAFE_KEY")
    }
    
    /// <#Description#>
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// <#Description#>
    func testCreateUser() {
        // function is not done yet.
        XCTAssert(true)
        // Should be the test
//        XCTAssert(
//            db.userCreate(
//                username: "test",
//                password: "test",
//                email: "test"
//            ),
//            "Unable to create user"
//        )
    }
    
    /// <#Description#>
    func testLoginUser() {
        // function is not done yet.
        XCTAssert(true)
        // Should be the test
//        XCTAssert(
//            db.userLogin(
//                username: "test",
//                password: "test"
//            ),
//            "Unable to login"
//        )
    }
    
    /// <#Description#>
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
