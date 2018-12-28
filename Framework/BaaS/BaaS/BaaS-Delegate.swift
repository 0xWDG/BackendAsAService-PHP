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
public protocol BaaSDelegate: class {
    /**
     *
     */
    func testForReturn(withDataAs: String)
}
