//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
import Gzip

class Downloader {
    let user: String
    let password: String
    let urlString: String

    init(user: String, password: String, urlString: String) {
        self.user = user
        self.password = password
        self.urlString = urlString
    }

    private func createSession() -> URLSession {
        if !user.isEmpty {
            let config = URLSessionConfiguration.default
            let userPasswordString = "\(user):\(password)"
            let userPasswordData = userPasswordString.data(using: .utf8)
            let base64EncodedCredential = userPasswordData!.base64EncodedString()
            config.httpAdditionalHeaders = ["Authorization": "Basic \(base64EncodedCredential)"]
            let session = URLSession(configuration: config)
            return session
        } else {
            return URLSession(configuration: .default)
        }
    }

    func download(completioin: @escaping (String?) -> Void) {
        let session = createSession()
        let url = URL(string: urlString)!
        let task = session.downloadTask(with: url, completionHandler: { localURL, response, _ in
            if let localURL = localURL {
                let contentType = (response as? HTTPURLResponse)?.allHeaderFields["Content-Type"]
                if let contentType = contentType as? String {
                    switch contentType {
                    case let str where str.contains("application/gzip"):
                        guard let rawData = try? Data(contentsOf: localURL),
                              let decompressedData = try? rawData.gunzipped() else {
                            completioin(nil)
                            return
                        }
                        let unzippedStr = String(data: decompressedData, encoding: .utf8)
                        completioin(unzippedStr)
                    case let str where str.contains("text/csv"):
                        if let string = try? String(contentsOf: localURL) {
                            completioin(string)
                        }
                    default:
                        print("Unknown content type: \(contentType)")
                    }
                } else {
                    print("Unsupported content type: \(contentType ?? "")")
                }
            }
        })
        task.resume()

    }
}
