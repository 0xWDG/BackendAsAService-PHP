//
//  BaaS-NetworkRequests.swift
//  BaaS
//
//  Created by Wesley de Groot on 28/12/2018.
//  Copyright © 2018 Wesley de Groot. All rights reserved.
//

// Just for iOS
import Foundation

// For Certificate/Public Key-Pinning
import Security

#if !targetEnvironment(simulator)
// For supporting SHA256
import CommonCrypto
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
extension BaaS {
    /**
     * networkRequest
     *
     * Start a network request
     *
     * - parameter url: The url to be parsed
     * - parameter posting: What do you need to post
     * - returns: the data we've got from the server
     */
    public func networkRequest(
        _ url: String,
        _ posting: Dictionary<String, Any>? = ["nothing": "send"]
        ) -> Data {
        /// Check if the URL is valid
        guard let myURL = URL(string: url) else {
            return "Error: \(url) doesn't appear to be an URL".data(using: String.Encoding.utf8)!
        }
        
        /// Create a new post dict, for the JSON String
        var newPosting: Dictionary<String, String>?
        
        // Try
        do {
            /// Create JSON
            let JSON = try JSONSerialization.data(
                withJSONObject: posting as Any,
                options: .sortedKeys
            )
            
            // set NewPosting
            newPosting = ["JSON": String.init(data: JSON,encoding: .utf8)!]
        }
            
        /// Catch errors
        catch let error as NSError {
            return "Error: \(error.localizedDescription)".data(using: String.Encoding.utf8)!
        }
        
        /// We are waiting for data
        var waiting: Bool = true
        
        /// Setup a fake, empty data
        var data: Data? = "" . data(using: .utf8)
        
        /// Setup a reuseable noData dataset
        let noData: Data = "" . data(using: .utf8)!
        
        /// Create a URL Request
        var request = URLRequest(url: myURL)
        
        // With method POST
        request.httpMethod = "POST"
        
        // And custom Content-Type
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )
        
        /// Create a empty httpBody
        var httpPostBody = ""
        
        /// Index = 0
        var idx = 0
        
        /// Check if we can unwrap the post fields.
        guard let postFields = newPosting else {
            return noData
        }
        
        // Walk trough the post Fields
        for (key, val) in postFields {
            /// Check if we need to preAppend
            let preAppend = (idx == 0) ? "" : "&"
            
            /// Encode the value
            let encodedValue = val.addingPercentEncoding(
                withAllowedCharacters: .urlHostAllowed
            )!
            
            // Append to httpPostBody
            httpPostBody.append(
                contentsOf: "\(preAppend)\(key)=\(encodedValue)"
            )
            
            // Increase our index
            idx += 1
        }
        
        // Log, if we are in debugmode.
        self.log("url: \(url)\npost body (escaped): \(httpPostBody)\npost body (unescaped): \(httpPostBody.removingPercentEncoding!)")
        
        // Set the httpBody
        request.httpBody = httpPostBody.data(using: .utf8)
        
        /// Create a pinned URLSession
        var session = URLSession.init(
            // With default configuration
            configuration: .ephemeral,
            
            // With our pinning delegate
            delegate: URLSessionPinningDelegate(),
            
            // with no queue
            delegateQueue: nil
        )
        
        // Check if we have a public key, or certificate hash.
        if (self.publicKeyHash.count == 0 ||
            self.certificateHash.count == 0) {
            // Show a error, only on debug builds
            log(
                "[WARNING] No Public key pinning/Certificate pinning\n" +
                "           Improve your security to enable this!\n"
            )
            // Use a non-pinned URLSession
            session = URLSession.shared
        }
        
        // Start our datatask
        session.dataTask(with: request) { (sitedata, response, error) in
            /// Check if we got any useable site data
            guard let sitedata = sitedata else {
                data = "Error" . data(using: .utf8)
                waiting = false
                return
            }
            
            // save the sitedata
            data = sitedata
            
            // stop waiting
            waiting = false
        }.resume()
        
        // Dirty way to create a blocking function.
        while (waiting) { }
        
        /// Unwrap our data
        guard let unwrappedData = data else {
            return "Error while unwrapping data" . data(using: .utf8)!
        }
        
        // Return the data.
        return unwrappedData
    }
}

// See: https://www.bugsee.com/blog/ssl-certificate-pinning-in-mobile-applications/
class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    /// Hash of the pinned certificate
    let pinnedCertificateHash: String
    
    /// Hash of the pinned public key
    let pinnedPublicKeyHash: String
    
    override init() {
        pinnedCertificateHash = BaaS.shared.getCertificateHash()
        pinnedPublicKeyHash = BaaS.shared.getPublicKeyHash()
        
        super.init()
    }
    
    /// RSA2048 Asn1 Header
    let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d,
        0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05,
        0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]
    
    private func sha256(data : Data) -> String {
        #if !targetEnvironment(simulator)
        /// Key header
        var keyWithHeader = Data(bytes: rsa2048Asn1Header)
        keyWithHeader.append(data)
        
        /// Hash
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        keyWithHeader.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
        }
        
        
        return Data(hash).base64EncodedString()
        #else
        return data.base64EncodedString()
        #endif
    }
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void
        ) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            /// Server trust
            if let serverTrust = challenge.protectionSpace.serverTrust {
                /// server trust
                var secresult = SecTrustResultType.invalid
                
                /// status
                let status = SecTrustEvaluate(serverTrust, &secresult)
                
                if(errSecSuccess == status) {
                    // print(SecTrustGetCertificateCount(serverTrust))
                    /// Server certificate
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        
                        if (pinnedCertificateHash.count > 2) {
                            /// Certificate pinning
                            let serverCertificateData: NSData = SecCertificateCopyData(
                                serverCertificate
                            )
                            
                            /// Get hash
                            let certHash = sha256(
                                data: serverCertificateData as Data
                            )
                            
                            if (certHash == pinnedCertificateHash) {
                                // Success! This is our server
                                completionHandler(
                                    .useCredential,
                                    URLCredential(
                                        trust: serverTrust
                                    )
                                )
                                return
                            }
                        }
                        
                        if (pinnedPublicKeyHash.count > 2) {
                            /// Public key pinning
                            let serverPublicKey = SecCertificateCopyKey(
                                serverCertificate
                            )
                            
                            /// Public key data
                            let serverPublicKeyData: NSData = SecKeyCopyExternalRepresentation(
                                serverPublicKey!,
                                nil
                                )!
                            
                            /// Key hash
                            let keyHash = sha256(
                                data: serverPublicKeyData as Data
                            )
                            
                            if (keyHash == pinnedPublicKeyHash) {
                                // Success! This is our server
                                completionHandler(
                                    .useCredential,
                                    URLCredential(trust:serverTrust)
                                )
                                return
                            }
                        }
                    }
                }
            }
        }
        
        // Pinning failed
        completionHandler(
            .cancelAuthenticationChallenge,
            nil
        )
    }
}
