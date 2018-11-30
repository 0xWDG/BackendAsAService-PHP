//
//  BaaS_Webhelper.swift
//  BaaS_Framework
//
//  Created by Wesley de Groot on 23/11/2018.
//  Copyright © 2018 Wesley de Groot. All rights reserved.
//

import Foundation

/**
 *
 */
extension BaaS {
    /**
     Get getDataFrom
     
     - Parameter url: the URL of the file
     
     - Returns: the contents of the webpage
     */
    public func urlTask(
        _ url: String,
        _ posting: Dictionary<String, Any>? = ["nothing": "send"]
        ) -> Data {
        log(url)
        if let myURL = URL(string: url) {
            // Create a new post dict, for the JSON String
            var newPosting: Dictionary<String, String>?
            
            do {
                // Create JSON
                let JSON = try JSONSerialization.data(withJSONObject: posting as Any, options: .sortedKeys)
                
                // set NewPosting
                newPosting = [
                    "JSON": String.init(data: JSON, encoding: .utf8)!
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
            request.setValue("application/x-www-form-urlencoded",
                             forHTTPHeaderField: "Content-Type")
            
            var httpBody = ""
            var idx = 0
            for (key, val) in newPosting! {
                if (idx == 0) {
                    httpBody.append(contentsOf:
                        "\(key)=\(val.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")
                } else {
                    httpBody.append(contentsOf:
                        "&\(key)=\(val.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")
                }
                idx += 1
            }
            self.log(httpBody)
            request.httpBody = httpBody.data(using: .utf8)
            
            let session = URLSession.shared
            session.dataTask(with: request) { (sitedata, response, error) in
                if let sitedata = sitedata {
                    data = sitedata
                    waiting = false
                } else {
                    data = "Error" . data(using: .utf8)
                    waiting = false
                }
                
                }.resume()
            
            while (waiting) {
                // print("Waiting...")
            }
            
            return data!
        } else {
            return "Error: \(url) doesn't  URL".data(using: String.Encoding.utf8)!
        }
    }
}
