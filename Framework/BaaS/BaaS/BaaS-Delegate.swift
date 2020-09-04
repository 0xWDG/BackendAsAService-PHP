//
//  Baas_Delegate.swift
//  BaaS
//
//  Created by Wesley de Groot on 23/11/2018.
//  Copyright © 2018 Wesley de Groot. All rights reserved.
//

import Foundation

#if canImport(Aurora)
import Aurora
#endif

/**
 * **B**ackend **a**s **a** **S**ervice (_BaaS_) Delegate
 *
 * This protocol is used for the BaaS Server Interface.
 */
@objc public protocol BaaSDelegate {
    /// <#Description#>
    /// - Parameter withDataAs: <#withDataAs description#>
    @objc optional func testForReturn(withDataAs: String)
}

/**
 * **B**ackend **a**s **a** **S**ervice (_BaaS_) Delegate
 *
 * This protocol is used for the BaaS Server Interface.
 */
@objc public protocol BaaSChatDelegate {
    /// <#Description#>
    /// - Parameters:
    ///   - messageID: <#messageID description#>
    ///   - message: <#message description#>
    ///   - nsfwScore: <#nsfwScore description#>
    ///   - from: <#from description#>
    ///   - verifiedUser: <#verifiedUser description#>
    func receivedChatMessage(messageID: Int, message: String, nsfwScore: Int, from: String, verifiedUser: Bool)
}

// To make things optional.
extension BaaSDelegate {
    /// <#Description#>
    /// - Parameter withDataAs: <#withDataAs description#>
    func testForReturn(withDataAs: String) { }
}
