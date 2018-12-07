//
//  BaaS.swift
//  BaaS
//
//  Created by Wesley de Groot on 23/11/2018.
//  Copyright © 2018 Wesley de Groot. All rights reserved.
//

import Foundation

/**
 * **B**ackend **a**s **a** **S**ervice (_BaaS_)
 *
 * This class is used for the BaaS Server Interface.
 *
 * .
 *
 * **Simple usage**
 *
 *      class myClass: UIViewController, BaaSDelegate {
 *          let db = BaaS.shared
 *
 *          override func viewDidLoad() {
 *              db.delegate = self
 *              db.set(apiKey: "YOURAPIKEY")
 *              db.set(server: "https://yourserver.tld/BaaS")
 *          }
 *      }
 */
open class BaaS {
    /**
     * Delegate of the Backend to return
     *
     * This is the delegate where it calls back to.
     */
    public weak var delegate: BaaSDelegate?

    /**
     * The API Key which the user provides
     *
     * This is the API key as you have set in index.php
     */
    private var apiKey: String = "§§DEVELOPMENT_UNSAFE_KEY§§"
    
    /**
     * The URL of the backend server (BaaS Server)
     *
     * This should be your servers address
     */
    private var serverAddress: URL = URL.init(string: "https://wdgwv.com")!
    
    /**
     * Maximum server timeout
     *
     * Maximum time before the BaaS Controller gives a timeout.
     */
    private var serverTimeout: Int = 30
    
    /**
     * Debugmode
     *
     * Should we debug right now?
     */
    private let debug = true
    
    /**
     * Shared (instance)
     *
     * Init this for all your calls.
     */
    public static var shared: BaaS = BaaS()
    
    /**
     * Init
     *
     * We're live.
     */
    public init() {
        // We're live.
        delegate?.testForReturn(withDataAs: "ABC")
    }
    
    /**
     * Log
     *
     * This is used to send log messages with the following syntax
     *
     *     [BaaS] Filename:line functionName(...):
     *      Message
     *
     * - parameter message: the message to send
     * - parameter file: the filename
     * - parameter line: the line
     * - parameter function: function name
     */
    @discardableResult
    open func log(_ message: Any, file: String = #file, line: Int = #line, function: String = #function) -> Bool {
        if (debug) {
            let x: String = String((file.split(separator: "/").last)!.split(separator: ".").first!)
            Swift.print("[BaaS] \(x):\(line) \(function):\n \(message)\n")
        }
        
        return true
    }
    
    /**
     * NOOP (**NO** **OP**eration)
     *
     * This performs nothing.
     */
    public func noop() {
        if let del = delegate {
            del.testForReturn(withDataAs: "ABC")
        } else {
            log("No delegate?")
        }
    }

    /**
     * Set the API key
     *
     * This saves your API key
     *
     * - parameter apiKey: Your personal API key
     */
    public func set(apiKey: String) -> Void {
        self.apiKey = apiKey
    }
    
    /**
     * Set server URL
     *
     * - parameter server: Server URL (_Without /_)
     */
    @discardableResult
    public func set(server: String) -> Bool {
        if let unwrappedURL = URL.init(string: server) {
            self.serverAddress = unwrappedURL
            return true
        }
        
        return false
    }
    
    /**
     * Set server URL
     *
     * - parameter server: Server URL (_Without /_)
     */
    public func set(server: URL) -> Void {
        self.serverAddress = server
    }
    
    /**
     * Set server maximum Timeout
     *
     * - parameter timeout: Maximum timeout
     */
    public func set(timeout: Int) -> Void {
        self.serverTimeout = timeout
    }
    
    /**
     * BaaS database Field
     *
     *     parameter name:         Field Name
     *     parameter type:         Field Type
     *     parameter defaultValue: Field Default Value
     *     parameter canBeEmpty:   Field can be empty?
     */
    public struct BaaS_dbField: Codable {
        var name: String
        var type: String
        var defaultValue: String
        var canBeEmpty: Bool
    }

    /**
     * BaaS database Field Type
     *
     *
     * **.text**
     *
     * For text fields
     *
     * **.number**
     *
     * For numberic fields
     */
    public enum BaaS_dbFieldType: String {
        case text = "text"
        case number = "number"
    }
    
    /**
     * BaaS database Search Type
     *
     *
     * For Equal (==) ___
     * **.value**, **.equals**, **.eq**
     *
     * For not Equal (!=)
     * **.notValue**, **.notEquals**, **.neq**
     *
     * For like (~=) _____
     * **.like**
     *
     * For in range: _____
     * **.location**
     *
     *     valueWhere("lat,lon", .location, "distanceInMeters")
     *
     * see: `BaaS_SearchType`
     */
    public enum BaaS_SearchType: String {
        case value, equals, eq = "="
        case notValue, notEquals, neq = "!="
        case like = "LIKE"
        case location = "location"
    }

    /**
     * BaaS expression Field
     *
     *     parameter searchType:   Search type (see BaaS_SearchType)
     *     parameter expression1:  Search expression1
     *     parameter expression2:  Search expression2
     */
    public struct BaaS_WhereExpression: Codable {
        var searchType: BaaS_SearchType.RawValue
        var expression1: String
        var expression2: String
    }
    
    /**
     * Create Database Field
     *
     * - parameter createFieldWithName: Field name
     * - parameter type: Field type (.text / .number)
     * - parameter defaultValue: Fields default value
     * - parameter canBeEmpty: Can the field be empty?
     * - returns: `BaaS_dbField`
     */
    public func database(
        createFieldWithName: String,
        type: BaaS_dbFieldType,
        defaultValue: String,
        canBeEmpty: Bool
    ) -> BaaS_dbField {
        return BaaS_dbField.init(
            name: createFieldWithName,
            type: type.rawValue,
            defaultValue: defaultValue,
            canBeEmpty: canBeEmpty
        )
    }
    
    /**
     * Create Database
     *
     * - parameter createWithName: Table name
     * - parameter withFields: Table fields
     * - returns: Boolean
     */
    public func database(createWithName: String, withFields: [BaaS_dbField]) -> Bool {
        print(withFields)
        let dbURL = "\(serverAddress)/table.create/\(createWithName)"
        var data: [[String: String]] = []

        for field in withFields {
            data.append([
                "name": field.name,
                "type": field.type,
                "defaultValue": field.defaultValue,
                "canBeEmpty": field.canBeEmpty ? "yes" : "no"
            ])
        }

        let JSON: [String: Any] = [
            "APIKey": self.apiKey,
            "Data": data
        ]
        
        let task = self.urlTask(dbURL, JSON)
        log(String.init(data: task, encoding: .utf8)!)
        
        return false
    }
    
    /**
     * Database Exists?
     *
     * - parameter existsWithName: Table name
     * - returns: Boolean
     */
    public func database(existsWithName: String) -> Bool {
        let dbURL = "\(serverAddress)/table.exists/\(existsWithName)"
        let task = self.urlTask(dbURL, [
            "APIKey": self.apiKey
        ])
        log(String.init(data: task, encoding: .utf8)!)

        return false
    }
    
    /**
     * database Expression
     *
     * - parameter expression1: Expression #1
     * - parameter searchType: **.eq**, **.neq**, **.like**, **.location** (See `BaaS_SearchType`)
     * - parameter expression2: Expression #2
     * - returns: `BaaS_WhereExpression`
     */
    public func expression(
        _ expression1: String,
        _ searchType: BaaS_SearchType,
        _ expression2: String
    ) -> BaaS_WhereExpression {
        return BaaS_WhereExpression.init(
            searchType: searchType.rawValue,
            expression1: expression1.replacingOccurrences(of: "`", with: "\\`"),
            expression2: expression2.replacingOccurrences(of: "'", with: "\\'")
        )
    }
    
    public func value(expression: [BaaS_WhereExpression], inDatabase: String) -> Any {
        var flatArray: [[String]] = []
        
        for item in expression {
            flatArray.append([
                item.expression1,
                item.searchType,
                item.expression2
            ])
        }
        
        return self.value(
            where: flatArray,
            inDatabase: inDatabase
        )
    }

    /**
     * Insert data
     *
     * - parameter values: Which values?
     * - parameter inDatabase: Which database?
     * - returns: Any
     */
    public func insert(values: [String: String], inDatabase: String) -> Any {
        let dbURL = "\(serverAddress)/row.insert/\(inDatabase)"
        let task = self.urlTask(dbURL, [
            "APIKey": self.apiKey,
            "values": values
        ])
        
        return String.init(data: task, encoding: .utf8)!
    }
    
    internal func value(where whereStr: [[String]], inDatabase: String) -> Any {
        let dbURL = "\(serverAddress)/row.get/\(inDatabase)"
        let task = self.urlTask(dbURL, [
            "APIKey": self.apiKey,
            "where": whereStr
        ])
        
        return String.init(data: task, encoding: .utf8)!
    }
}
