//
//  BaaS-JSONDecoder.swift
//  BaaS
//
//  Created by Wesley de Groot on 04/01/2019.
//  Copyright © 2019 Wesley de Groot. All rights reserved.
//
//  Modified for usage within BaaS
//  Original content, and thanks to:
//     Saoud Rizwan
//     https://github.com/saoudrizwan/DynamicJSON
//

import Foundation

#if canImport(Aurora)
import Aurora
#endif

//
//  DynamicJSON.swift
//  DynamicJSON
//
//  Created by Saoud Rizwan on 1/1/19.
//

@dynamicMemberLookup
/// <#Description#>
public enum JSON {
    // MARK: Cases
    case dictionary(Dictionary<String, JSON>)
    case array(Array<JSON>)
    case string(String)
    case number(NSNumber)
    case bool(Bool)
    case null
    
    // MARK: Dynamic Member Lookup
    /// <#Description#>
    public subscript(index: Int) -> JSON? {
        if case .array(let arr) = self {
            return index < arr.count ? arr[index]: nil
        }
        return nil
    }
    
    /// <#Description#>
    public subscript(key: String) -> JSON? {
        if case .dictionary(let dict) = self {
            return dict[key]
        }
        return nil
    }
    
    /// <#Description#>
    public subscript(dynamicMember member: String) -> JSON? {
        if case .dictionary(let dict) = self {
            return dict[member]
        }
        return nil
    }
    
    // MARK: Initializers
    
    /// <#Description#>
    /// - Parameters:
    ///   - data: <#data description#>
    ///   - options: <#options description#>
    /// - Throws: <#description#>
    public init(data: Data, options: JSONSerialization.ReadingOptions = []) throws {
        let object = try JSONSerialization.jsonObject(with: data, options: options)
        self = JSON(object)
    }
    
    /// <#Description#>
    /// - Parameter object: <#object description#>
    public init(_ object: Any) {
        if let data = object as? Data {
            if let converted = try? JSON(data: data) {
                self = converted
            } else if let fragments = try? JSON(data: data, options: .allowFragments) {
                self = fragments
            } else {
                self = JSON.null
            }
        } else if let dictionary = object as? [String: Any] {
            self = JSON.dictionary(dictionary.mapValues { JSON($0) })
        } else if let array = object as? [Any] {
            self = JSON.array(array.map { JSON($0) })
        } else if let string = object as? String {
            self = JSON.string(string)
        } else if let bool = object as? Bool {
            self = JSON.bool(bool)
        } else if let number = object as? NSNumber {
            self = JSON.number(number)
        } else {
            self = JSON.null
        }
    }
    
    // MARK: Accessors
    
    /// <#Description#>
    public var dictionary: Dictionary<String, JSON>? {
        if case .dictionary(let value) = self {
            return value
        }
        return nil
    }
    
    /// <#Description#>
    public var array: Array<JSON>? {
        if case .array(let value) = self {
            return value
        }
        return nil
    }
    
    /// <#Description#>
    public var string: String? {
        if case .string(let value) = self {
            return value
        } else if case .bool(let value) = self {
            return value ? "true": "false"
        } else if case .number(let value) = self {
            return value.stringValue
        }
        return nil
    }
    
    /// <#Description#>
    public var number: NSNumber? {
        if case .number(let value) = self {
            return value
        } else if case .bool(let value) = self {
            return NSNumber(value: value)
        } else if case .string(let value) = self, let doubleValue = Double(value) {
            return NSNumber(value: doubleValue)
        }
        return nil
    }
    
    /// <#Description#>
    public var double: Double? {
        return number?.doubleValue
    }
    
    /// <#Description#>
    public var int: Int? {
        return number?.intValue
    }
    
    /// <#Description#>
    public var bool: Bool? {
        if case .bool(let value) = self {
            return value
        } else if case .number(let value) = self {
            return value.boolValue
        } else if case .string(let value) = self,
            (["true", "t", "yes", "y", "1"].contains {
                value.caseInsensitiveCompare($0) == .orderedSame
                }
            ) {
            return true
        } else if case .string(let value) = self,
            (["false", "f", "no", "n", "0"].contains {
                value.caseInsensitiveCompare($0) == .orderedSame
            }) {
            return false
        }
        return nil
    }
    
    
    // MARK: Helpers
    
    /// <#Description#>
    public var object: Any {
        switch self {
        case .dictionary(let value):
            return value.mapValues { $0.object }
            
        case .array(let value):
            return value.map { $0.object }
            
        case .string(let value):
            return value
            
        case .number(let value):
            return value
            
        case .bool(let value):
            return value
            
        case .null:
            return NSNull()
        }
    }
    
    /// <#Description#>
    /// - Parameter options: <#options description#>
    /// - Returns: <#description#>
    public func data(options: JSONSerialization.WritingOptions = []) -> Data {
        return (
            try? JSONSerialization.data(
                withJSONObject: self.object,
                options: options
            )
            ) ?? Data()
    }
}
