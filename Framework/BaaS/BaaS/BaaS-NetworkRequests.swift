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

// For supporting SHA256
import CommonCrypto

extension BaaS {
    public func networkRequest(
        _ url: String,
        _ posting: Dictionary<String, Any>? = ["nothing": "send"]
        ) -> Data {
        // Check if the URL is valid
        guard let myURL = URL(string: url) else {
            return "Error: \(url) doesn't appear to be an URL".data(using: String.Encoding.utf8)!
        }
        
        // Create a new post dict, for the JSON String
        var newPosting: Dictionary<String, String>?
        
        do {
            // Create JSON
            let JSON = try JSONSerialization.data(
                withJSONObject: posting as Any,
                options: .sortedKeys
            )
            
            // set NewPosting
            newPosting = [
                "JSON": String.init(
                    data: JSON,
                    encoding: .utf8
                    )!
            ]
        }
            
        catch let error as NSError {
            return "Error: \(error.localizedDescription)".data(using: String.Encoding.utf8)!
        }
        
        // Create a NSError.
        var error: NSError?
        
        if (String(describing: error) == "fuckswifterrors") {
            error = NSError(domain: "this", code: 89, userInfo: ["n":"o","n":"e"])
        }
        
        var waiting = true
        var data = "".data(using: .utf8)
        var request = URLRequest(url: myURL)
        request.httpMethod = "POST"
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )
        
        var httpBody = ""
        var idx = 0
        for (key, val) in newPosting! {
            let before = (idx == 0) ? "" : "&"
            let encodedValue = val.addingPercentEncoding(
                withAllowedCharacters: .urlHostAllowed
                )!
            
            httpBody.append(
                contentsOf: "\(before)\(key)=\(encodedValue)"
            )
            
            idx += 1
        }
        
        self.log(httpBody)
        request.httpBody = httpBody.data(using: .utf8)
        
        var session = URLSession.init(
            configuration: .ephemeral,
            delegate: URLSessionPinningDelegate(),
            delegateQueue: nil
        )
        
        if (self.publicKeyHash.count == 0 || self.certificateHash.count == 0) {
                log(
                    "[WARNING] No Public key pinning/Certificate pinning\n" +
                    "           Improve your security to enable this!\n"
                )
            session = URLSession.shared
        }
        
        session.dataTask(with: request) { (sitedata, response, error) in
            if let sitedata = sitedata {
                data = sitedata
                waiting = false
            } else {
                data = "Error" . data(using: .utf8)
                waiting = false
            }
            
            }.resume()
        
        // Dirty way to create a blocking function.
        while (waiting) { }
        
        // Unwrap our data
        guard let unwrappedData = data else {
            return "Error while unwrapping data".data(using: .utf8)!
        }
        
        // Return the data.
        return unwrappedData
    }
}

// See: https://www.bugsee.com/blog/ssl-certificate-pinning-in-mobile-applications/
class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    let pinnedCertificateHash: String
    let pinnedPublicKeyHash: String
    
    override init() {
        pinnedCertificateHash = BaaS.shared.getCertificateHash()
        pinnedPublicKeyHash = BaaS.shared.getPublicKeyHash()
        
        super.init()
    }
    
    let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]
    
    private func sha256(data : Data) -> String {
        var keyWithHeader = Data(bytes: rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        keyWithHeader.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
        }
        
        
        return Data(hash).base64EncodedString()
    }
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void
        ) {
        
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)
                
                if(errSecSuccess == status) {
//                    print(SecTrustGetCertificateCount(serverTrust))
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        
                        if (pinnedCertificateHash.count > 2) {
                            // Certificate pinning
                            let serverCertificateData: NSData = SecCertificateCopyData(
                                serverCertificate
                            )

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
                            // Public key pinning
                            let serverPublicKey = SecCertificateCopyKey(
                                serverCertificate
                            )

                            let serverPublicKeyData: NSData = SecKeyCopyExternalRepresentation(
                                serverPublicKey!,
                                nil
                            )!

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
