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
    let db = BaaS.shared
    
    override func viewDidLoad() {
        db.delegate = self
        db.set(server: "http://127.0.0.1:8000/index.php")
        db.set(apiKey: "§§DEVELOPMENT_UNSAFE_KEY§§")
        
        let dbLayout = [
            db.database(createFieldWithName: "name", type: .text, defaultValue: "", canBeEmpty: false),
            db.database(createFieldWithName: "password", type: .text, defaultValue: "", canBeEmpty: false),
            db.database(createFieldWithName: "email", type: .text, defaultValue: "", canBeEmpty: false)
        ]
        
        if db.database(createWithName: "testDatabase", withFields: dbLayout) {
            db.log("Database Created \\o/")
        } else {
            db.log("Database not created.")
        }
        
        if db.database(existsWithName: "testDatabase") {
            db.log("Database exists")
        } else {
            db.log("Database doesn't exists")
        }
        
        db.noop()
        
        db.log(
            db.value(
                expression: [db.expression("x", .eq, "x")],
                inDatabase: "testDatabase"
            )
        )
        
        db.log(
            db.value(
                expression: [
                    db.expression("x", .eq, "x"),
                    db.expression("x", .neq, "q"),
                    db.expression("x", .like, "x"),
                    // Optional...
                    // "Lat,Lon", .location, "MaxDistance"
                    db.expression("0,0", .location, "10"),
                    ],
                inDatabase: "x"
            )
        )
        
        //        db.log(db.test())
        db.log(
            db.insert(
                values: [
                    "x": "Hello from Swift"
                ],
                inDatabase: "x"
            )
        )
    }
        
        func testForReturn(withDataAs: String) {
            db.log("Returned data=\(withDataAs)")
        }
}

