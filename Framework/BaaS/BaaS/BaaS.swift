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
     * lastRowID
     *
     * Last row ID
     */
    private var lastRowID = 0
    
    /**
     * Shared (instance)
     *
     * Init this for all your calls.
     */
    public static var shared: BaaS = BaaS()
    
    /**
     * Version number
     *
     * BaaS Version number
     */
    private let version = "1.0"
    
    /**
     * Build number
     *
     * BaaS Build number
     */
    private let build = "20181221"
    
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
            let x: String = String(
                (file.split(separator: "/").last)!.split(separator: ".").first!
            )
            
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
     *     name:         Field Name
     *     type:         Field Type
     *     defaultValue: Field Default Value
     *     canBeEmpty:   Field can be empty?
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
     *     searchType:   Search type (see BaaS_SearchType)
     *     expression1:  Search expression1
     *     expression2:  Search expression2
     */
    public struct BaaS_WhereExpression: Codable {
        var searchType: BaaS_SearchType.RawValue
        var expression1: String
        var expression2: String
    }
    
    /**
     * BaaS possible errors
     *
     *     parameter unableToDecodeJSON
     */
    public enum BaaS_Errors: Error {
        case unableToDecodeJSON
    }
    
    /**
     * BaaS Response JSON Field
     *
     *     Status:    This is the Status of the BaaS Server call
     *     Error:     This a Error thrown by the BaaS Server call
     *     Fix:       This a how to fix the BaaS Server call
     *     Exception: This a Exception thrown by the BaaS Server call
     *     ReqURI:    This the requested URL which the BaaS Server has received
     *     Table:     This the current table where the BaaS Server is working in
     *     Data:      This a Data string returned by the BaaS Server call
     *     Where:     This the Where cause where the BaaS Server searched on
     *     Method:    This Method is not recognized by the BaaS Server
     *     info:      This is extra information
     *     rowID:     This the row ID of the (last) inserted row
     *     Debug:     This a Debug message thrown by the BaaS Server call
     *     FilePath:  The FilePath is not writeable error thrown by the BaaS Server call
     */
    public struct BaaS_Response: Codable {
        /**
         * BaaS Response: Status
         *
         * This is the Status of the BaaS Server call
         */
        var Status: String
        
        // MARK: General errors
        /**
         * BaaS Response: Error
         *
         * This a Message thrown by the BaaS Server call
         */
        var Error: String?
        
        /**
         * BaaS Response: Fix
         *
         * This a how to fix the BaaS Server call
         */
        var Fix: String?
        
        /**
         * BaaS Response: Exception
         *
         * This a Exception thrown by the BaaS Server call
         */
        var Exception: String?
        
        /**
         * BaaS Response: ReqURI
         *
         * This the requested URL which the BaaS Server has received
         */
        var ReqURI: String?
        
        // MARK: Which table?
        /**
         * BaaS Response: Table
         *
         * This the current table where the BaaS Server is working in
         */
        var Table: String?
        
        /**
         * BaaS Response: Data
         *
         * This a Data string returned by the BaaS Server call
         */
        var Data: String?
        
        /**
         * BaaS Response: Where
         *
         * This the Where cause where the BaaS Server searched on
         */
        var Where: String?
        
        /**
         * BaaS Response: Method
         *
         * This Method is not recognized by the BaaS Server
         */
        var Method: String?
        
        // MARK: Inserted row
        /**
         * BaaS Response: info
         *
         * This is extra information
         */
        var Info: String?
        
        /**
         * BaaS Response: rowID
         *
         * This the row ID of the (last) inserted row
         */
        var RowID: String?
        
        // MARK: if in debug mode
        /**
         * BaaS Response: Debug
         *
         * This a Debug message thrown by the BaaS Server call
         */
        var Debug: String?
        
        // MARK: Error at IP-Blocking
        /**
         * BaaS Response: FilePath
         *
         * The FilePath is not writeable error thrown by the BaaS Server call
         */
        var FilePath: String?
        
        /**
         * Initialize from a decoder.
         *
         * - parameter from: Decoder
         * - returns: `BaaS_Response_JSON`
         */
        public init(from decoder: Decoder) throws {
            // Decode CodingKeys
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            do {
                Status = try values.decode(String.self, forKey: .Status)
            }
            catch {
                Status = "Error"
            }
            
            do {
                Error = try values.decodeIfPresent(String.self, forKey: .Error)
            }
            catch {
                Error = "Unable to parse JSON"
            }
            
            do {
                Fix = try values.decodeIfPresent(String.self, forKey: .Fix)
            }
            catch {
                Fix = "Please send valid JSON"
            }
            
            do {
                Exception = try values.decodeIfPresent(String.self, forKey: .Exception)
            }
            catch {
                Exception = "N/A"
            }
            
            do {
                ReqURI = try values.decodeIfPresent(String.self, forKey: .ReqURI)
            }
            catch {
                ReqURI = "N/A"
            }
            
            do {
                Table = try values.decodeIfPresent(String.self, forKey: .Table)
            }
            catch {
                Table = "N/A"
            }
            
            do {
                Data = try values.decodeIfPresent(String.self, forKey: .Data)
            }
            catch {
                Data = "N/A"
            }
            
            do {
                Where = try values.decodeIfPresent(String.self, forKey: .Where)
            }
            catch {
                Where = "N/A"
            }
            
            do {
                Method = try values.decodeIfPresent(String.self, forKey: .Method)
            }
            catch {
                Method = "N/A"
            }
            
            do{
                Info = try values.decodeIfPresent(String.self, forKey: .Info)
            }
            catch {
                Info = "N/A"
            }
            
            do{
                RowID = try values.decodeIfPresent(String.self, forKey: .RowID)
            }
            catch{
                RowID = "N/A"
            }
            
            do {
                Debug = try values.decodeIfPresent(String.self, forKey: .Debug)
            }
            catch{
                Debug = "N/A"
            }
            
            do{
                FilePath = try values.decodeIfPresent(String.self, forKey: .FilePath)
            }
            catch {
                FilePath = "N/A"
            }
            
            // This looks like the weirdest if, which has ever lived.
            if (
                Status == "Error" &&
                    Error == "Unable to parse JSON" &&
                    Fix == "Please send valid JSON" &&
                    Exception == "N/A" &&
                    ReqURI == "N/A" &&
                    Table == "N/A" &&
                    Data == "N/A" &&
                    Where == "N/A" &&
                    Method == "N/A" &&
                    Info == "N/A" &&
                    RowID == "N/A" &&
                    Debug == "N/A" &&
                    FilePath == "N/A"
                ) {
                throw BaaS_Errors.unableToDecodeJSON
            }
        }
        
        /**
         * Initialize a error.
         *
         * - parameter Status: Response Status
         * - parameter Error: Response Error
         * - returns: `BaaS_Response_JSON`
         */
        public init(Status s_Status: String, Error s_Error: String) {
            Status = s_Status
            Error = s_Error
        }
    }
    
    /**
     * Translate BaaS_Response_JSON to something understandable
     *
     * - parameter jsonData: JSON Data
     * - returns: `BaaS_Response`
     */
    private func BaaS_Response_Decoder(jsonData: Data) -> BaaS_Response {
        var decoded: BaaS_Response? = nil
        
        do {
            let decoder = JSONDecoder()
            decoded = try decoder.decode(BaaS_Response.self, from: jsonData)
        }
        catch {
            decoded = BaaS_Response.init(
                Status: "Incorrect",
                Error: "Incorrect BaaS Return String"
            )
        }
        
        self.log("Data=\(String.init(data: jsonData, encoding: .utf8)!)\nDecoded=\(decoded!)")
        return decoded!
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
        type: BaaS_dbFieldType = .text,
        defaultValue: String = "",
        canBeEmpty: Bool = true
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
            data.append(
                [
                    "name": field.name,
                    "type": field.type,
                    "defaultValue": field.defaultValue,
                    "canBeEmpty": field.canBeEmpty ? "yes" : "no"
                ]
            )
        }
        
        let JSON: [String: Any] = [
            "APIKey": self.apiKey,
            "Fields": data
        ]
        
        let task = self.urlTask(
            dbURL,
            JSON
        )
        
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
        let task = self.urlTask(
            dbURL,
            [
                "APIKey": self.apiKey
            ]
        )
        
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
            flatArray.append(
                [
                    item.expression1,
                    item.searchType,
                    item.expression2
                ]
            )
        }
        
        return self.value(
            where: flatArray,
            inDatabase: inDatabase
        )
    }
    
    /**
     * Create data
     *
     * - parameter values: Which values?
     * - parameter inDatabase: Which database?
     * - returns: BaaS.BaaS_Response_JSON
     */
    public func create(values: [String: String], inDatabase: String) -> Bool {
        let dbURL = "\(serverAddress)/row.create/\(inDatabase)"
        let task = self.urlTask(
            dbURL,
            [
                "APIKey": self.apiKey,
                "values": values
            ])
        
        if let integer: Int = Int(BaaS_Response_Decoder(jsonData: task).RowID ?? "0") {
            self.lastRowID = integer
        }
        
        return BaaS_Response_Decoder(jsonData: task).Status == "Success"
    }
    
    /**
     * Rename table
     *
     * - parameter from: Old name
     * - parameter to: New name
     * - returns: Bool
     */
    public func rename(from: String, to: String) -> Bool {
        let dbURL = "\(serverAddress)/table.rename/\(from)/\(to)"
        let task = self.urlTask(
            dbURL,
            [
                "APIKey": self.apiKey,
                ]
        )
        
        return BaaS_Response_Decoder(jsonData: task).Status == "Success"
    }
    
    /**
     * Empty table
     *
     * - parameter table: The table
     * - returns: Bool
     */
    public func empty(table: String) -> Bool {
        let dbURL = "\(serverAddress)/table.empty/\(table)"
        let task = self.urlTask(
            dbURL,
            [
                "APIKey": self.apiKey,
                ]
        )
        
        return BaaS_Response_Decoder(jsonData: task).Status == "Success"
    }
    
    /**
     * Remove table
     *
     * - parameter table: The table
     * - returns: Bool
     */
    public func remove(table: String) -> Bool {
        let dbURL = "\(serverAddress)/table.remove/\(table)"
        let task = self.urlTask(
            dbURL,
            [
                "APIKey": self.apiKey,
                ]
        )
        
        return BaaS_Response_Decoder(jsonData: task).Status == "Success"
    }
    
    /**
     * Get last Row ID
     *
     * - returns: Last row ID
     */
    public func getLastRowID() -> Int {
        return self.lastRowID
    }
    
    public func fileUpload(data fileData: Data, saveWithFileID fileID: String) -> Any {
        let dbURL = "\(serverAddress)/file.upload/\(fileID)"
        
        guard let postSafeFileData = String.init(data: fileData.base64EncodedData(), encoding: .utf8) else {
            return false
        }
        
        let task = self.urlTask(
            dbURL,
            [
                "APIKey": self.apiKey,
                "fileData": postSafeFileData
            ]
        )
        
        return String.init(data: task, encoding: .utf8)!
    }
    
    public func fileExists(withFileID fileID: String) -> Bool {
        let dbURL = "\(serverAddress)/file.exists/\(fileID)"
        let task = self.urlTask(
            dbURL,
            [
                "APIKey": self.apiKey
            ]
        )
        
        //        return String.init(data: task, encoding: .utf8)!
        return false
    }
    
    public func fileDownload(withFileID fileID: String) -> Data {
        let dbURL = "\(serverAddress)/file.get/\(fileID)"
        let task = self.urlTask(
            dbURL,
            [
                "APIKey": self.apiKey
            ]
        )
        
        //        return String.init(data: task, encoding: .utf8)!
        return task
    }
    
    public func fileDelete(withFileID fileID: String) -> Any {
        let dbURL = "\(serverAddress)/file.delete/\(fileID)"
        let task = self.urlTask(
            dbURL,
            [
                "APIKey": self.apiKey
            ]
        )
        
        return String.init(data: task, encoding: .utf8)!
    }
    
    internal func value(where whereStr: [[String]], inDatabase: String) -> Any {
        let dbURL = "\(serverAddress)/row.get/\(inDatabase)"
        let task = self.urlTask(
            dbURL,
            [
                "APIKey": self.apiKey,
                "where": whereStr
            ]
        )
        
        return String.init(data: task, encoding: .utf8)!
    }
    
    @available(*, deprecated)
    internal func deprecated_placeholder() { }
    
}
