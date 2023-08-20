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
    private var parameters: [String : Any]

    static let shared = OneSignalClient()

    fileprivate init(
        parameters: [String : Any] = [
            "app_id": "4500c6ba-85dc-4990-bdc3-7e95aea9dd2f",
            "include_player_ids": ["a2908161-9c4c-4a2e-adf8-b61e71c24291"] // TODO: somehow get subscription ids.
        ] as [String : Any]
    ) {
        self.parameters = parameters
    }

    struct OneSignalError: Codable {
        let errors: [String]
    }

    func sendPush(with message: String, title: String) {
        parameters.updateValue(
            ["en": title],
            forKey: "headings"
        )
        parameters.updateValue(
            ["en": message],
            forKey: "contents"
        )
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])

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
