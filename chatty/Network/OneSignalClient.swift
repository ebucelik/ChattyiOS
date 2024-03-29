//
//  OneSignalClient.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 20.08.23.
//

import Foundation

class OneSignalClient {
    private let headers = [
      "accept": "application/json",
      "Authorization": "Basic OWQ2MWVlZGMtYThjNy00YTgzLTkxMzMtNzA2YTQyNmM3NzMw",
      "content-type": "application/json"
    ]

    static let shared = OneSignalClient()

    static let appId = "4500c6ba-85dc-4990-bdc3-7e95aea9dd2f"

    fileprivate init() {}

    struct OneSignalError: Codable {
        let errors: [String]
    }

    func sendPush(with message: String,
                  username: String = "",
                  title: String,
                  accountId: Int) {

        let oneSignalPush = OneSignalPush(
            appId: OneSignalClient.appId,
            includeAliases: OneSignalPush.ExternalId(
                externalId: ["\(accountId)"]
            ),
            targetChannel: "push",
            headings: [
                "en": title,
                "de": title
            ],
            contents: [
                "en": username + message,
                "de": username + message.localize(defaultLanguage: "de")
            ]
        )
        
        do {
            let postData = try JSONEncoder().encode(oneSignalPush)

            let request = NSMutableURLRequest(
                url: NSURL(string: "https://onesignal.com/api/v1/notifications")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0
            )
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data

            let session = URLSession.shared
            let dataTask = session.dataTask(
                with: request as URLRequest,
                completionHandler: { (data, response, error) -> Void in
                    if (error != nil) {
                        print(error as Any)
                    } else {
                        if let data = data {
                            do {
                                print(try JSONDecoder().decode(OneSignalError.self, from: data))
                            } catch {
                                print("error")
                            }
                        }
                    }
                }
            )

            dataTask.resume()
        } catch {
            print("Error")
        }
    }
}
