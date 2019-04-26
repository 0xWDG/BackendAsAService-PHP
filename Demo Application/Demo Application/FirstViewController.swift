//
//  FirstViewController.swift
//  Demo Application
//
//  Created by Wesley de Groot on 23/11/2018.
//  Copyright © 2018 Wesley de Groot. All rights reserved.
//

import UIKit
import BaaS

class FirstViewController: UIViewController, BaaSDelegate {
    /// BaaS Shared
    let db = BaaS.shared
    
    override func viewDidLoad() {
        db.delegate = self
        db.set(server: "http://127.0.0.1:8000/index.php")
        db.set(apiKey: "DEVELOPMENT_UNSAFE_KEY")
        
        let dbLayout = [
            db.database(createFieldWithName: "name", type: .text, defaultValue: "", canBeEmpty: false),
            db.database(createFieldWithName: "password", type: .text, defaultValue: "", canBeEmpty: false),
            db.database(createFieldWithName: "email", type: .text, defaultValue: "", canBeEmpty: false),
            db.database(createFieldWithName: "emailz", type: .text, defaultValue: "Pre\"tested'Filled", canBeEmpty: true),
            db.database(createFieldWithName: "emailx", type: .number, defaultValue: "1", canBeEmpty: true)

        ]
        db.noop(dbLayout)
        
//        if db.database(createWithName: "testDatabase", withFields: dbLayout) {
//            db.log("Database Created \\o/")
//        } else {
//            db.log("Database not created.")
//        }
        
        if db.userCreate(username: "test", password: "test", email: "my@email.com") {
            db.log("User created")
        } else {
            db.log("Failed to create user")
        }

        if db.userLogin(username: "test", password: "test") {
            db.log("User logged in!")
        } else {
            db.log("Failed to login")
        }

//        if db.database(existsWithName: "testDatabase") {
//            db.log("Database exists")
//        } else {
//            db.log("Database doesn't exists")
//        }
//
//        db.noop()
//
//        db.log(
//            db.value(
//                expression: [db.expression("x", .eq, "x")],
//                inDatabase: "testDatabase"
//            )
//        )
//
//        db.log(
//            db.value(
//                expression: [
//                    db.expression("x", .eq, "x"),
//                    db.expression("x", .neq, "q"),
//                    db.expression("x", .like, "x"),
//                    // Optional...
//                    // "Lat,Lon", .location, "MaxDistance"
//                    db.expression("0,0", .location, "10"),
//                    ],
//                inDatabase: "x"
//            )
//        )
//
//        //        db.log(db.test())

//        db.log(
//            db.create(
//                values: [
//                    "x": "Hello from Swift",
//                    "latitude": "123",
//                    "longitude": "321"
//                ],
//                inDatabase: "x"
//            )
//        )
        
//        db.log(
//            db.rename(from: "x", to: "y")
//        )

//        db.log(
//            db.rename(from: "y", to: "x")
//        )
    }
        
        func testForReturn(withDataAs: String) {
            db.log("Returned data=\(withDataAs)")
        }
}

