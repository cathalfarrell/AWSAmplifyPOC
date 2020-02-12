//
//  UserService.swift
//  AmplifyPOC
//
//  Created by Cathal Tru on 02/07/2019.
//  Copyright © 2019 Cathal Tru. All rights reserved.
//

import Foundation

struct APIResponseAssets: Decodable {

    var status: Int
    var version: String
    var success: Bool
    var data: [Asset]
    var currentPage: Int
    var pageSize: Int
    var numPages: Int
    var totalCount: Int

    enum CodingKeys: String, CodingKey {
        //If the api keys need converting from snake case to camelcase used in swift - do it here
        case status, version, success, data
        case currentPage = "current_page", pageSize = "page_size", numPages = "num_pages", totalCount =
        "total_count"
    }
}

struct APIResponseSingleAsset: Decodable {

    var status: Int
    var version: String
    var success: Bool
    var data: Asset

    enum CodingKeys: String, CodingKey {
        //If the api keys need converting from snake case to camelcase used in swift - do it here
        case status, version, success, data
    }
}

struct Asset: Decodable {

}

struct AssetService {

    static let shared = AssetService()
    let session = URLSession(configuration: .default)

    // NOTE : NOT ALL Request requires parameters.
    // You can pass nil in the configureHTTPRequest() method for the parameter argument.

    func getAssets(_ completion: @escaping (Result<APIResponseAssets>) -> Void) {

        let headers = HTTPHeaders([
            "Accept": "application/json",
            "Content-Type": "application/json",
            "authorization": gCognitoToken])!

        let parameters = [ "order_by": "created_at",
                           "order_direction": "asc",
                           "page_size": "20",
                           "page_number": "1"
        ]

        do {
            let request = try HTTPNetworkRequest.configureHTTPRequest(from: .assets,
                                                                      with: parameters,
                                                                      includes: headers,
                                                                      contains: nil, and: .get)
            print("😀 Making this request: \(request) METHOD:\(request.httpMethod ?? "")")
            print("😀 HEADERS: \(String(describing: headers))")

            session.dataTask(with: request) { (data, res, err) in

                if let response = res as? HTTPURLResponse, let unwrappedData = data {

                    let result = HTTPNetworkResponse.handleNetworkResponse(for: response)
                    switch result {

                    case .success:

                        do {
                            let jsonResult = try JSONDecoder().decode(APIResponseAssets.self, from: unwrappedData)
                            print("✅ RESULT: \(String(describing: jsonResult))")
                            completion(Result.success(jsonResult))
                        } catch let err {
                            print("🛑 Unable to parse JSON response: \(err.localizedDescription)")
                            completion(Result.failure(err))
                        }

                        //self.printAPIResponse(data: unwrappedData)

                    case .failure (let err):
                        print("🛑 FAILED: \(result) error:\(err)")
                        completion(Result.failure(err))
                    }
                }

                if let err = err {
                    print("🛑  ERROR: \(err.localizedDescription)")
                    completion(Result.failure(err))
                }

                }.resume()
        } catch let err {

            completion(Result.failure(err))
        }
    }

    func getSingleAsset(identifier: String, _ completion: @escaping (Result<APIResponseSingleAsset>) -> Void) {

        let headers = HTTPHeaders([
        "Accept": "application/json",
        "Content-Type": "application/json",
        "authorization": gCognitoToken])!

        do {
            let request = try HTTPNetworkRequest.configureHTTPRequest(identifier,
                                                                      from: .asset,
                                                                      with: nil,
                                                                      includes: headers,
                                                                      contains: nil,
                                                                      and: .get)

            print("😀 Making this request: \(request) METHOD:\(request.httpMethod ?? "")")
            print("😀 HEADERS: \(String(describing: headers))")

            session.dataTask(with: request) { (data, res, err) in

                if let response = res as? HTTPURLResponse, let unwrappedData = data {

                    let result = HTTPNetworkResponse.handleNetworkResponse(for: response)
                    switch result {

                    case .success:

                        do {
                            let jsonResult = try JSONDecoder().decode(APIResponseSingleAsset.self, from: unwrappedData)
                            print("✅ RESULT: \(String(describing: jsonResult))")
                            completion(Result.success(jsonResult))
                        } catch let err {
                            print("🛑 Unable to parse JSON response: \(err.localizedDescription)")
                            completion(Result.failure(err))
                        }

                        //self.printAPIResponse(data: unwrappedData)

                    case .failure(let err):
                        print("🛑 FAILED: \(result) error:\(err)")
                        completion(Result.failure(err))
                    }
                }

                if let err = err {
                    print("🛑  ERROR: \(err.localizedDescription)")
                    completion(Result.failure(err))
                }

                }.resume()
        } catch let err {

            completion(Result.failure(err))
        }
    }

    func printAPIResponse(data: Data) {
        //Just for test print purposes
         do {
         let resultObject = try JSONSerialization.jsonObject(with: data, options: [])
             print("✅ Results from request:\n\(resultObject)")
         } catch let err {
            print("🛑 Unable to parse JSON response: \(err.localizedDescription)")
         }

    }
}
