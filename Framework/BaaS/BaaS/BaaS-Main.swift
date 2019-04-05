//
//  BaaS.swift
//  BaaS
//
//  Created by Wesley de Groot on 23/11/2018.
//  Copyright © 2018 Wesley de Groot. All rights reserved.
//

import Foundation

#if os(iOS)
import UserNotifications

extension UIColor
{
    public class var BaaS: UIColor
    {
        return UIColor(red: 0, green: 212/255, blue: 255/255, alpha: 1.0)
    }
}
#endif
#if os(macOS)
extension NSColor
{
    private class var BaaS: NSColor
    {
        return NSColor(red: 0, green: 212/255, blue: 255/255, alpha: 1.0)
    }
}
#endif

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
    /// This is the delegate where it calls back to.
    public weak var delegate: BaaSDelegate?
    
    /// The API Key which the user provides
    private var apiKey: String = "DEVELOPMENT_UNSAFE_KEY"
    
    /// The URL of the backend server (BaaS Server)
    private var serverAddress: URL = URL.init(string: "https://wdgwv.com")!
    
    /// Maximum time before the BaaS Controller gives a timeout.
    private var serverTimeout: Int = 30
    
    
    #if !targetEnvironment(simulator)
    /// Should we debug right now?
    private let debug = _isDebugAssertConfiguration()
    #else
    /// Should we debug right now? (always)
    private let debug = true
    #endif

    /// Last row ID
    private var lastRowID = 0
    
    /**
     * Shared (instance)
     *
     * Init this for all your calls.
     */
    public static var shared: BaaS = BaaS()
    
    /// BaaS Version number
    private let version = "1.0"
    
    /// BaaS Build number
    private let build = "20190323"
    
    /// Server's public key hash
    var publicKeyHash = ""
    
    /// Server's certificate hash
    var certificateHash = ""
  
    /// The user's session ID
    var sessionID = ""
    
    #if !targetEnvironment(simulator)
    /// notificationCenter to send notifications
    let notificationCenter = UNUserNotificationCenter.current()
    #endif
    
    /**
     * BaaS Color
     *
     * BaaS Color (hex, rgb, hsv, cmyk)
     */
    public enum BaaS_Color: String {
        /// Official BaaS color in hex
        case hex = "#00d4ff"

        /// Official BaaS color in rgb
        case rgb = "0,212,255"

        /// Official BaaS color in r, y, k
        case r, y, k = "0"

        /// Official BaaS color in g
        case g = "212"

        /// Official BaaS color in b
        case b = "255"

        /// Official BaaS color in hsv
        case hsv = "190,100,100"

        /// Official BaaS color in h
        case h = "190"

        /// Official BaaS color in s, v, c
        case s, v, c = "100"

        /// Official BaaS color in cmyk
        case cmyk = "100,17,0,0"

        /// Official BaaS color in m
        case m = "17"
    }
    
    /**
     * Init
     *
     * We're live.
     */
    public init() {
        #if os(iOS) && !targetEnvironment(simulator)
        
        // Ask every quarter if there are new notifications
        UIApplication.shared.setMinimumBackgroundFetchInterval(
            UIApplication.backgroundFetchIntervalMinimum
        )
        
        // Request authorization to send push messages
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if !granted {
                // Acces not granted
                self.log("[Notification center] Status not granted")
            } else {
                // Access granted
                self.log("[Notification center] Status granted")
            }
        }
        
        switch(UIApplication.shared.backgroundRefreshStatus) {
        case .available:
            self.log("Background refresh available")
            break;
        case .restricted:
            self.log("Background refresh restructed")
            break;
        case .denied:
            self.log("Background refresh disabled for us")
        }
        #endif
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
    
    public func checkForNotificationsInBackground() -> UIBackgroundFetchResult {
        self.fireNotification(withTitle: "Test for notifications", Description: "Cool!")
        // Notifications
        return .newData
        
        // No notifications
//        return .noData
    }
    
    private func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String(
            (0...(length - 1)).map {
                _ in letters.randomElement()!
            }
        )
    }

    private func fireNotification(withTitle: String, Description: String) {
        #if os(iOS) && !targetEnvironment(simulator)
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                self.log("Not authorized to send notifications")
                return
            }
        }
        
        /// Generate a identifier for the notification
        let identifier = self.generateRandomString(length: 10)
        
        /// create a timer interfal trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        /// make notification contents
        let content = UNMutableNotificationContent()
            content.title = withTitle
            content.body = Description
            content.sound = .default
        
        /// make a notification request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                self.log("Unexpected error \(error)")
            }
        })
        #endif
    }
    
    private func resetNotifications() {
        #if os(iOS) && !targetEnvironment(simulator)
        notificationCenter.removeAllPendingNotificationRequests()
        #endif
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
     * Set hash of the server's certificate
     *
     * This saves the hash of the server's certificate
     *
     * - parameter certificateHash: Server's certificate hash
     */
    public func set(certificateHash: String) -> Void {
        self.certificateHash = certificateHash
    }
    
    /**
     * Set hash of the server's public key
     *
     * This saves the hash of the server's public key
     *
     * - parameter publicKeyHash: Server's public key hash
     */
    public func set(publicKeyHash: String) -> Void {
        self.publicKeyHash = publicKeyHash
    }
    
    /**
     * Get hash of the server's certificate
     *
     * This gets the hash of the server's certificate
     *
     * - returns Server's certificate hash
     */
    public func getCertificateHash() -> String {
        return self.certificateHash
    }
    
    /**
     * Get hash of the server's public key
     *
     * This gets the hash of the server's public key
     *
     * - returns Server's public key hash
     */
    public func getPublicKeyHash() -> String {
        return self.publicKeyHash
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
     * BaaS possible status
     *
     *     success
     *     failed
     *     warning
     */
    public enum BaaS_Status: String, CodingKey {
        case Success
        case Failed, Fail
        case Warning
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

        /**
         * BaaS Response: Details
         *
         * This is the Details of the BaaS Server call
         */
        var Details: String?
        
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
         * BaaS Response: File
         *
         * Is the file found?
         */
        var File: String?
        
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
        
        /**
         * BaaS Response: Debug
         *
         * This a Debug message thrown by the BaaS Server call
         */
        var Debug: String?
        
        /**
         * BaaS Response: FilePath
         *
         * The FilePath is not writeable error thrown by the BaaS Server call
         */
        var FilePath: String?

        /**
         * BaaS Response: Session ID
         *
         * The Session ID
         */
        var SessionID: String?

        /**
         * BaaS Response: User ID
         *
         * The User ID
         */
        var UserID: String?
        
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
                Details = try values.decode(String.self, forKey: .Details)
            }
            catch {
                Details = "N/A"
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
                File = try values.decodeIfPresent(String.self, forKey: .File)
            }
            catch {
                File = "N/A"
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
            
            do {
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
            
            do {
                FilePath = try values.decodeIfPresent(String.self, forKey: .FilePath)
            }
            catch {
                FilePath = "N/A"
            }
            
            do {
                SessionID = try values.decodeIfPresent(String.self, forKey: .SessionID)
            }
            catch {
                SessionID = "N/A"
            }
            
            do {
                UserID = try values.decodeIfPresent(String.self, forKey: .UserID)
            }
            catch {
                UserID = "N/A"
            }
            
            // This looks like the weirdest if, which has ever lived.
            if (
                Status == "Error" &&
                    Details == "N/A" &&
                    Error == "Unable to parse JSON" &&
                    Fix == "Please send valid JSON" &&
                    Exception == "N/A" &&
                    ReqURI == "N/A" &&
                    Table == "N/A" &&
                    Data == "N/A" &&
                    File == "N/A" &&
                    Where == "N/A" &&
                    Method == "N/A" &&
                    Info == "N/A" &&
                    RowID == "N/A" &&
                    Debug == "N/A" &&
                    FilePath == "N/A" &&
                    SessionID == "N/A" &&
                    UserID == "N/A"
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
        
        let task = self.networkRequest(
            "\(serverAddress)/table.create/\(createWithName)",
            [
                "APIKey": self.apiKey,
                "Fields": data
            ]
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
        let task = self.networkRequest(
            "\(serverAddress)/table.exists/\(existsWithName)",
            [
                "APIKey": self.apiKey
            ]
        )
        
        log(String.init(data: task, encoding: .utf8)!)
        
        return false
    }
    
    /**
     * user Login
     *
     * - parameter username: The username
     * - parameter password: The password
     * - returns: Boolean
     */
    public func userLogin(username: String, password: String) -> Bool {
        let task = self.networkRequest(
            "\(serverAddress)/user.login",
            [
                "APIKey": self.apiKey,
                "username": username,
                "password": password
            ]
        )
        
        log(String.init(data: task, encoding: .utf8)!)
        
        let response = BaaS_Response_Decoder(jsonData: task)

        if let sessionID = response.SessionID {
            self.sessionID = sessionID
        }

        return response.Status == "Success"
    }
    
    /**
     * user Create
     *
     * - parameter username: The username
     * - parameter password: The password
     * - parameter email: The email
     * - returns: Boolean
     */
    public func userCreate(username: String, password: String, email: String) -> Bool {
        let task = self.networkRequest(
            "\(serverAddress)/user.create",
            [
                "APIKey": self.apiKey,
                "username": username,
                "password": password,
                "email": email
            ]
        )
        
        log(String.init(data: task, encoding: .utf8)!)
        
        let response = BaaS_Response_Decoder(jsonData: task)
        return response.Status == "Success"
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
     * - returns: Bool
     */
    public func create(values: [String: String], inDatabase: String) -> Bool {
        let task = self.networkRequest(
            "\(serverAddress)/row.create/\(inDatabase)",
            [
                "APIKey": self.apiKey,
                "values": values
            ]
        )
        
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
        let task = self.networkRequest(
            "\(serverAddress)/table.rename/\(from)/\(to)",
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
        let task = self.networkRequest(
            "\(serverAddress)/table.empty/\(table)",
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
        let task = self.networkRequest(
            "\(serverAddress)/table.remove/\(table)",
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
    
    /**
     * Upload file
     *
     * - parameter data: File data
     * - parameter saveWithFileID: Preffered file ID
     * - returns: [Boolean, FileID]
     */
    public func fileUpload(data fileData: Data, saveWithFileID fileID: String) -> Any {
        guard let compressedData = fileData.deflate() else {
            return false
        }
        
        guard let postSafeFileData = String.init(data: compressedData.base64EncodedData(), encoding: .utf8) else {
            return false
        }
        
        let task = self.networkRequest(
            "\(serverAddress)/file.upload/\(fileID)",
            [
                "APIKey": self.apiKey,
                "fileData": postSafeFileData
            ]
        )
        
        return String.init(data: task, encoding: .utf8)!
    }
    
    /**
     * File Exists
     *
     * - parameter withFileID: The file identifier
     * - returns: Boolean
     */
    public func fileExists(withFileID fileID: String) -> Bool {
        let task = self.networkRequest(
            "\(serverAddress)/file.exists/\(fileID)",
            [
                "APIKey": self.apiKey
            ]
        )
        
        return BaaS_Response_Decoder(jsonData: task).File == "Found"
    }
    
    
    public func fileDownload(withFileID fileID: String) -> Data {
        let task = self.networkRequest(
            "\(serverAddress)/file.download/\(fileID)",
            [
                "APIKey": self.apiKey
            ]
        )
        
        log(String.init(data: task, encoding: .utf8)!)
        
        guard let stringData = JSON(task).filedata?.string else {
            //            return BaaS_Response_Decoder(jsonData: task).Data
            log("Failed to decode filedata!")
            return "" . data(using: .utf8)!
        }
        
        let compressedFile = Data(base64Encoded: stringData)
        
        if let unCompressedFile = compressedFile?.inflate() {
            log("returning uncompressed file")
            return unCompressedFile
        }
        
        log("Something went wrong")
        return task
    }
    
    @discardableResult
    public func fileDelete(withFileID fileID: String) -> Any {
        let task = self.networkRequest(
            "\(serverAddress)/file.delete/\(fileID)",
            [
                "APIKey": self.apiKey
            ]
        )
        
        return String.init(data: task, encoding: .utf8)!
    }
    
    internal func value(where whereStr: [[String]], inDatabase: String) -> Any {
        let task = self.networkRequest(
            "\(serverAddress)/row.get/\(inDatabase)",
            [
                "APIKey": self.apiKey,
                "where": whereStr
            ]
        )
        
        return String.init(data: task, encoding: .utf8)!
    }
    
    public func noop(_ any: Any) { }
    @available(*, deprecated)
    internal func deprecated_placeholder() { }
}
