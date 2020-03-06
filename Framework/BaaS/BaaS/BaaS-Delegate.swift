//
//  Baas_Delegate.swift
//  BaaS
//
//  Created by Wesley de Groot on 23/11/2018.
//  Copyright © 2018 Wesley de Groot. All rights reserved.
//

import Foundation

/**
 * **B**ackend **a**s **a** **S**ervice (_BaaS_)
 *
 * This protocol is used for the BaaS Server Interface.
 */
@objc
public protocol BaaSDelegate {
    /**
     * testForReturn(withDataAs: String)
     *
     */
    @objc optional func testForReturn(withDataAs: String)
    @objc optional func receivedChatMessage(messageID: Int, message: String, nsfwScore: Int, from: String, verifiedUser: Bool)
}

// To make things optional.
extension BaaSDelegate {
    func testForReturn(withDataAs: String) { }
    func receivedChatMessage(messageID: Int, message: String, nsfwScore: Int, from: String, verifiedUser: Bool) { }
}
