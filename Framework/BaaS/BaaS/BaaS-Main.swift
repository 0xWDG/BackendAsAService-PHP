//
//  BaaS.swift
//  BaaS
//
//  Created by Wesley de Groot on 23/11/2018.
//  Copyright © 2018 Wesley de Groot. All rights reserved.
//

// swiftlint:disable file_length
import Foundation

#if os(iOS)
import UserNotifications

extension UIColor {
    public class var baas: UIColor {
        return UIColor(red: 0, green: 212/255, blue: 255/255, alpha: 1.0)
    }
}
#endif

#if os(macOS)
extension NSColor
{
    private class var baas: NSColor {
        return NSColor(red: 0, green: 212/255, blue: 255/255, alpha: 1.0)
    }
}
#endif

// swiftlint:disable type_body_length
/**
 * **B**ackend **a**s **a** **S**ervice (**BaaS**)
 *
 * This class is used for the BaaS Server Interface.
 *
 * .
 *
 * **Simple usage**
 *
 * _AppDelegate_
 *
 *     var database = BaaS.shared
 *
 *     func application(
 *          _ application: UIApplication,
 *          didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
 *          database.set(apiKey: "YOURAPIKEY")
 *          database.set(server: "https://yourserver.tld/BaaS")
 *     }
 *
 *     // To support Push Notifications
 *     func application(
 *          _ application: UIApplication,
 *          performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
 *          completionHandler(
 *              database.checkForNotificationsInBackground()
 *          )
 *     }
 *
 * _a ViewController_
 *
 *      class myViewController: UIViewController, BaaSDelegate {
 *          let db = BaaS.shared
 *
 *          override func viewDidLoad() {
 *              db.delegate = self
 *          }
 *      }
 *
 * - Copyright: [Wesley de Groot](https://wesleydegroot.nl) ([WDGWV](https://wdgwv.com)) and [Contributors](https://github.com/BackendasaService/BaaS/graphs/contributors).
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
    public let debug = _isDebugAssertConfiguration()
    #else
    /// Should we debug right now? (always)
    public let debug = true
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
    public var sessionID = ""
    
    /// Get all values
    public let all = "*"
    
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
        // swiftlint:disable identifier_name
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
        // swiftlint:enable identifier_name
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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, _) in
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
        case .restricted:
            self.log("Background refresh restructed")
        case .denied:
            self.log("Background refresh disabled for us")
        default:
            self.log("... unknow status")
        }
        #endif
        
        NetworkStatus.shared.startMonitoring()
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
    public func log(_ message: Any, file: String = #file, line: Int = #line, function: String = #function) -> Bool {
        if (debug) {
            let fileName: String = String(
                (file.split(separator: "/").last)!.split(separator: ".").first!
            )
            
            Swift.print("[BaaS] \(fileName):\(line) \(function):\n \(message)\n")
        }
        
        return true
    }
    
    public func checkForNotificationsInBackground() -> UIBackgroundFetchResult {
        self.fireNotification(withTitle: "Test for notifications", description: "Cool!")
        // Notifications
        return .newData
        
        // No notifications
        //        return .noData
    }
    
    private func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String(
            (0...(length - 1)).map { _ in letters.randomElement()! }
        )
    }
    
    private func fireNotification(withTitle: String, description: String) {
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
        content.body = description
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
     * delegate-test- (**NO** **OP**eration)
     *
     * This performs nothing.
     */
    public func delegate_test_func() {
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
    public func set(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /**
     * Set hash of the server's certificate
     *
     * This saves the hash of the server's certificate
     *
     * - parameter certificateHash: Server's certificate hash
     */
    public func set(certificateHash: String) {
        self.certificateHash = certificateHash
    }
    
    /**
     * Set hash of the server's public key
     *
     * This saves the hash of the server's public key
     *
     * - parameter publicKeyHash: Server's public key hash
     */
    public func set(publicKeyHash: String) {
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
    public func set(server: URL) {
        self.serverAddress = server
    }
    
    /**
     * Set server maximum Timeout
     *
     * - parameter timeout: Maximum timeout
     */
    public func set(timeout: Int) {
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
        case text
        case number
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
        case value, equals, eql = "="
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
        case success
        case failed, fail
        case warning
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
    public struct BaaSResponse: Codable {
        /**
         * BaaS Response: Status
         *
         * This is the Status of the BaaS Server call
         */
        var status: String
        
        /**
         * BaaS Response: Details
         *
         * This is the Details of the BaaS Server call
         */
        var details: String?
        
        // MARK: General errors
        /**
         * BaaS Response: Error
         *
         * This a Message thrown by the BaaS Server call
         */
        var error: String?
        
        /**
         * BaaS Response: Fix
         *
         * This a how to fix the BaaS Server call
         */
        var fix: String?
        
        /**
         * BaaS Response: Exception
         *
         * This a Exception thrown by the BaaS Server call
         */
        var exception: String?
        
        /**
         * BaaS Response: ReqURI
         *
         * This the requested URL which the BaaS Server has received
         */
        var reqURI: String?
        
        // MARK: Which table?
        /**
         * BaaS Response: Table
         *
         * This the current table where the BaaS Server is working in
         */
        var table: String?
        
        /**
         * BaaS Response: Data
         *
         * This a Data string returned by the BaaS Server call
         */
        var data: String?
        
        /**
         * BaaS Response: File
         *
         * Is the file found?
         */
        var file: String?
        
        /**
         * BaaS Response: Where
         *
         * This the Where cause where the BaaS Server searched on
         */
        var `where`: String?
        
        /**
         * BaaS Response: Method
         *
         * This Method is not recognized by the BaaS Server
         */
        var method: String?
        
        /**
         * BaaS Response: info
         *
         * This is extra information
         */
        var info: String?
        
        /**
         * BaaS Response: rowID
         *
         * This the row ID of the (last) inserted row
         */
        var rowID: String?
        
        /**
         * BaaS Response: Debug
         *
         * This a Debug message thrown by the BaaS Server call
         */
        var debug: String?
        
        /**
         * BaaS Response: FilePath
         *
         * The FilePath is not writeable error thrown by the BaaS Server call
         */
        var filePath: String?
        
        /**
         * BaaS Response: Session ID
         *
         * The Session ID
         */
        var sessionID: String?
        
        /**
         * BaaS Response: User ID
         *
         * The User ID
         */
        var userID: String?
        
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
                status = try values.decode(String.self, forKey: .status)
            } catch {
                status = "Error"
            }
            
            do {
                details = try values.decode(String.self, forKey: .details)
            } catch {
                details = "N/A"
            }
            
            do {
                error = try values.decodeIfPresent(String.self, forKey: .error)
            } catch {
                self.error = "Unable to parse JSON"
            }
            
            do {
                fix = try values.decodeIfPresent(String.self, forKey: .fix)
            } catch {
                fix = "Please send valid JSON"
            }
            
            do {
                exception = try values.decodeIfPresent(String.self, forKey: .exception)
            } catch {
                exception = "N/A"
            }
            
            do {
                reqURI = try values.decodeIfPresent(String.self, forKey: .reqURI)
            } catch {
                reqURI = "N/A"
            }
            
            do {
                table = try values.decodeIfPresent(String.self, forKey: .table)
            } catch {
                table = "N/A"
            }
            
            do {
                data = try values.decodeIfPresent(String.self, forKey: .data)
            } catch {
                data = "N/A"
            }
            
            do {
                file = try values.decodeIfPresent(String.self, forKey: .file)
            } catch {
                file = "N/A"
            }
            
            do {
                `where` = try values.decodeIfPresent(String.self, forKey: .where)
            } catch {
                `where` = "N/A"
            }
            
            do {
                method = try values.decodeIfPresent(String.self, forKey: .method)
            } catch {
                method = "N/A"
            }
            
            do {
                info = try values.decodeIfPresent(String.self, forKey: .info)
            } catch {
                info = "N/A"
            }
            
            do {
                rowID = try values.decodeIfPresent(String.self, forKey: .rowID)
            } catch {
                rowID = "N/A"
            }
            
            do {
                debug = try values.decodeIfPresent(String.self, forKey: .debug)
            } catch {
                debug = "N/A"
            }
            
            do {
                filePath = try values.decodeIfPresent(String.self, forKey: .filePath)
            } catch {
                filePath = "N/A"
            }
            
            do {
                sessionID = try values.decodeIfPresent(String.self, forKey: .sessionID)
            } catch {
                sessionID = "N/A"
            }
            
            do {
                userID = try values.decodeIfPresent(String.self, forKey: .userID)
            } catch {
                userID = "N/A"
            }
            
            // This looks like the weirdest if, which has ever lived.
            if (
                status == "Error" &&
                    details == "N/A" &&
                    error == "Unable to parse JSON" &&
                    fix == "Please send valid JSON" &&
                    exception == "N/A" &&
                    reqURI == "N/A" &&
                    table == "N/A" &&
                    data == "N/A" &&
                    file == "N/A" &&
                    `where` == "N/A" &&
                    method == "N/A" &&
                    info == "N/A" &&
                    rowID == "N/A" &&
                    debug == "N/A" &&
                    filePath == "N/A" &&
                    sessionID == "N/A" &&
                    userID == "N/A"
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
        public init(status serverStatus: String, error serverError: String) {
            status = serverStatus
            error = serverError
        }
    }
    
    /**
     * Translate BaaS_Response_JSON to something understandable
     *
     * - parameter jsonData: JSON Data
     * - returns: `baasResponse`
     */
    private func baasResponseDecoder(jsonData: Data) -> BaaSResponse {
        var decoded: BaaSResponse?
        
        do {
            let decoder = JSONDecoder()
            decoded = try decoder.decode(BaaSResponse.self, from: jsonData)
        } catch {
            decoded = BaaSResponse.init(
                status: "Incorrect",
                error: "Incorrect BaaS Return String"
            )
        }
        
        self.log("Data=\(String.init(data: jsonData, encoding: .utf8)!)\nDecoded=\(decoded!)")
        return decoded!
    }
    
    /**
     * Translate BaaS_Response_JSON to something understandable
     *
     * - parameter jsonData: JSON Data
     * - returns: `BaaS_Response`
     */
    private func decode(jsonData: Data) -> JSON {
        return JSON(jsonData)
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
    @discardableResult
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
        
        let response = baasResponseDecoder(jsonData: task)
        
        if let sessionID = response.sessionID {
            self.sessionID = sessionID
        }
        
        return response.status == "Success"
    }
    
    /// user Login
    /// - Parameters:
    ///   - username: The username
    ///   - password: The password
    ///   - closure: closure description
    ///     - succeed: Did the action succeed?
    ///     - sessionID: The user's session Identifier
    ///     - response: BaaS' response
    public func userLogin(
        username: String,
        password: String,
        closure: (_ succeed: Bool, _ sessionID: String, _ response: BaaSResponse) -> Void
    ) {
        let task = self.networkRequest(
            "\(serverAddress)/user.login",
            [
                "APIKey": self.apiKey,
                "username": username,
                "password": password
            ]
        )
        
        log(String.init(data: task, encoding: .utf8)!)
        
        let response = baasResponseDecoder(jsonData: task)
        
        if let sessionID = response.sessionID {
            self.sessionID = sessionID
        }
        
        if userLogin(username: username, password: password) {
            closure(true, self.sessionID, response)
            return
        }
        
        closure(false, self.sessionID, response)
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
        
        let response = baasResponseDecoder(jsonData: task)
        return response.status == "Success"
    }
    
    public func userGet(username: String) {
        
    }
    public func userGet(email: String) {
        
    }
    public func userGet(userID: Int) {
        
    }
    
    public func getUsers(
        latitude: Double,
        longitude: Double,
        distanceInMeters: Double
    ) -> JSON {
        // * valueWhere("lat,lon", .location, "distanceInMeters")
        
        let expression = self.expression(
            "\(latitude),\(longitude)",
            .location,
            "\(distanceInMeters)"
        )
        
        return JSON(
            self.value(
                expression: [expression],
                inDatabase: "BaaS_UserDB"
            ).data(using: .utf8) as Any
        )
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
    
    public func value(forKey: String, inDatabase: String) -> JSON {
        return JSON(
            self.value(
                where: [
                    [
                        forKey,
                        "LIKE",
                        "%"
                    ]
                ],
                inDatabase: inDatabase
            ).data(using: .utf8) as Any
        )
    }
    
    public func value(expression: [BaaS_WhereExpression], inDatabase: String) -> String {
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
    @discardableResult
    public func create(values: [String: String], inDatabase: String) -> Bool {
        let task = self.networkRequest(
            "\(serverAddress)/row.create/\(inDatabase)",
            [
                "APIKey": self.apiKey,
                "values": values
            ]
        )
        
        if let integer: Int = Int(baasResponseDecoder(jsonData: task).rowID ?? "0") {
            self.lastRowID = integer
        }
        
        return baasResponseDecoder(jsonData: task).status == "Success"
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
                "APIKey": self.apiKey
            ]
        )
        
        return baasResponseDecoder(jsonData: task).status == "Success"
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
                "APIKey": self.apiKey
            ]
        )
        
        return baasResponseDecoder(jsonData: task).status == "Success"
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
                "APIKey": self.apiKey
            ]
        )
        
        return baasResponseDecoder(jsonData: task).status == "Success"
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
        
        return baasResponseDecoder(jsonData: task).file == "Found"
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
    
    internal func value(where whereStr: [[String]], inDatabase: String) -> String {
        let task = self.networkRequest(
            "\(serverAddress)/row.get/\(inDatabase)",
            [
                "APIKey": self.apiKey,
                "where": whereStr
            ]
        )
        
        return String.init(data: task, encoding: .utf8)!
    }
    
    @discardableResult public func sendChatMessage(to user: String, message: String) -> Bool {
        let task = self.networkRequest(
            "\(serverAddress)/chat.send/\(user)",
            [
                "APIKey": self.apiKey,
                "message": message
            ]
        )
        
        return baasResponseDecoder(jsonData: task).status == "Success"
    }
    
    public func lisenForChatMessages(forChatID: String) {
        guard let delegate = self.delegate else {
            fatalError(
                "[BaaS] Lisening for messages without delegate, add BaaSDelegate to your main class,"
                + "and link it (BaaS.shared.delegate = self (or your other class))."
            )
        }
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(30)) {
            self.checkForChatMessages(forChatID: forChatID, withDelegate: delegate)
        }
    }
    
    internal func checkForChatMessages(forChatID: String, withDelegate: BaaSDelegate) {
        // swiftlint:disable:next line_length
        let randomChatStrings = ["The Japanese yen for commerce is still well-known.", "There was coal in his stocking and he was thrilled.", "My dentist tells me that chewing bricks is very bad for your teeth.", "They called out her name time and again, but were met with nothing but silence.", "Improve your goldfish's physical fitness by getting him a bicycle.", "We have a lot of rain in June.", "Nothing seemed out of place except the washing machine in the bar.", "Swim at your own risk was taken as a challenge for the group of Kansas City college students.", "She opened up her third bottle of wine of the night.", "There is a fly in the car with us.", "When nobody is around, the trees gossip about the people who have walked under them.", "With a single flip of the coin, his life changed forever.", "Don't put peanut butter on the dog's nose.", "The snow-covered path was no help in finding his way out of the backcountry.", "You're good at English when you know the difference between a man eating chicken and a man-eating chicken.", "His seven-layer cake only had six layers.", "At that moment she realized she had a sixth sense.", "I'm a great listener, really good with empathy vs sympathy and all that, but I hate people.", "She did her best to help him.", "As you consider all the possible ways to improve yourself and the world, you notice John Travolta seems fairly unhappy.", "There are few things better in life than a slice of pie.", "Flesh-colored yoga pants were far worse than even he feared.", "I just wanted to tell you I could see the love you have for your child by the way you look at her.", "Doris enjoyed tapping her nails on the table to annoy everyone.", "When he encountered maize for the first time, he thought it incredibly corny.", "She cried diamonds.", "This book is sure to liquefy your brain.", "Various sea birds are elegant, but nothing is as elegant as a gliding pelican.", "I hope that, when I've built up my savings, I'll be able to travel to Mexico.", "For oil spots on the floor, nothing beats parking a motorbike in the lounge.", "People who insist on picking their teeth with their elbows are so annoying!", "He wondered if she would appreciate his toenail collection.", "This is the last random sentence I will be writing and I am going to stop mid-sent", "Erin accidentally created a new universe.", "He wondered why at 18 he was old enough to go to war", "He went back to the video to see what had been recorded and was shocked at what he saw.", "Plans for this weekend include turning wine into water.", "Truth in advertising and dinosaurs with skateboards have much in common.", "Please wait outside of the house.", "My Mum tries to be cool by saying that she likes all the same things that I do.", "Don't piss in my garden and tell me you're trying to help my plants grow.", "Random words in front of other random words create a random sentence.", "It didn't make sense unless you had the power to eat colors.", "Hit me with your pet shark!", "The Tsunami wave crashed against the raised houses and broke the pilings as if they were toothpicks.", "They throw cabbage that turns your brain into emotional baggage.", "The quick brown fox jumps over the lazy dog.", "A song can make or ruin a person’s day if they let it get to them.", "There is so much to understand.", "You're unsure whether or not to trust him, but very thankful that you wore a turtle neck."]
        
        // RE-Check
        withDelegate.receivedChatMessage(
            messageID: 0,
            message: randomChatStrings.randomElement()!,
            nsfwScore: 0,
            from: "Some one for you",
            verifiedUser: false
        )
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(30)) {
            self.checkForChatMessages(forChatID: forChatID, withDelegate: withDelegate)
        }
    }
    
    public func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    /**
     * **No** **op**eration
     *
     * - parameter _: Any
     */
    public func noop(_ any: Any) { }
    
    @available(*, deprecated)
    internal func deprecated_placeholder() { }
}

// swiftlint:enable file_length type_body_length
