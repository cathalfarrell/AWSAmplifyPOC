//
//  UserService.swift
//  AmplifyPOC
//
//  Created by Cathal Tru on 03/07/2019.
//  Copyright © 2019 Cathal Tru. All rights reserved.
//

import Foundation

struct APIResponseUsers: Decodable {
    var status: Int
    var version: String
    var success: Bool
    var data: [User]
    enum CodingKeys: String, CodingKey {
        //If the api keys need converting from snake case to camelcase used in swift - do it here
        case status, version, success, data
    }
}

struct APIResponseUser: Decodable {
    var status: Int
    var version: String
    var success: Bool
    var data: User
    enum CodingKeys: String, CodingKey {
        //If the api keys need converting from snake case to camelcase used in swift - do it here
        case status, version, success, data
    }
}

struct User: Decodable {
    var userId: String
    var givenName: String
    var familyName: String
    var nickname: String
    var fullName: String
    var email: String
    var organisationId: String

    enum CodingKeys: String, CodingKey {
        //If the api keys need converting from snake case to camelcase used in swift - do it here
        case nickname, email
        case userId = "id", givenName = "given_name", familyName = "family_name", fullName = "full_name"
        case organisationId = "organisation_id"
    }
}

struct UserService {
    static let shared = UserService()
    let session = URLSession(configuration: .default)

    // NOTE : NOT ALL Request requires parameters. You can pass nil in the configureHTTPRequest()
    // method for the parameter argument.

    func getUser(_ completion: @escaping (Result<APIResponseUser>) -> Void) {

        AuthenticationService.sharedInstance.getAuthToken { (token) in

            guard let token = token else {
                print("🛑 Missing Token")
                return
            }

            let headers = HTTPHeaders([
                "Accept": "application/json",
                "Content-Type": "application/json",
                "authorization": token])!

            //let parameters = [ "key": "value"]

            do {
                let request = try HTTPNetworkRequest.configureHTTPRequest(from: .user,
                                                                          with: nil,
                                                                          includes: headers,
                                                                          contains: nil,
                                                                          and: .get)
                print("😀 Making this request: \(request) METHOD:\(request.httpMethod ?? "")")
                print("😀 HEADERS: \(String(describing: headers))")

                self.session.dataTask(with: request) { (data, res, err) in

                    if let response = res as? HTTPURLResponse, let unwrappedData = data {

                        let result = HTTPNetworkResponse.handleNetworkResponse(for: response)
                        switch result {

                        case .success:

                            do {
                                let jsonResult = try JSONDecoder().decode(APIResponseUser.self, from: unwrappedData)
                                print("✅ RESULT: \(String(describing: jsonResult))")
                                completion(Result.success(jsonResult))
                            } catch let error {
                                print("🛑 Unable to parse JSON response: \(error.localizedDescription)")
                                completion(Result.failure(error))
                            }

                            //self.printAPIResponse(data: unwrappedData)

                        case .failure(let error):
                            print("🛑 FAILED: \(result) error:\(error)")
                            completion(Result.failure(error))
                        }
                    }

                    if let error = err {
                        print("🛑  ERROR: \(error.localizedDescription)")
                        completion(Result.failure(error))
                    }

                    }.resume()
            } catch let err {

                completion(Result.failure(err))
            }
        }
    }

    func getUsers(_ completion: @escaping (Result<APIResponseUsers>) -> Void) {

        AuthenticationService.sharedInstance.getAuthToken { (token) in

            guard let token = token else {
                print("🛑 Missing Token")
                return
            }

            let headers = HTTPHeaders([
                "Accept": "application/json",
                "Content-Type": "application/json",
                "authorization": token])!

            //let parameters = [ "key": "value"]

            do {
                let request = try HTTPNetworkRequest.configureHTTPRequest(from: .users,
                                                                          with: nil,
                                                                          includes: headers,
                                                                          contains: nil,
                                                                          and: .get)
                print("😀 Making this request: \(request) METHOD:\(request.httpMethod ?? "")")
                print("😀 HEADERS: \(String(describing: headers))")

                self.session.dataTask(with: request) { (data, res, err) in

                    if let response = res as? HTTPURLResponse, let unwrappedData = data {

                        let result = HTTPNetworkResponse.handleNetworkResponse(for: response)
                        switch result {

                        case .success:

                            do {
                                let jsonResult = try JSONDecoder().decode(APIResponseUsers.self, from: unwrappedData)
                                print("✅ RESULT: \(String(describing: jsonResult))")
                                completion(Result.success(jsonResult))
                            } catch let error {
                                print("🛑 Unable to parse JSON response: \(error.localizedDescription)")
                                completion(Result.failure(error))
                            }

                            //self.printAPIResponse(data: unwrappedData)

                        case .failure(let error):
                            print("🛑 FAILED: \(result) error:\(error)")
                            completion(Result.failure(error))
                        }
                    }

                    if let error = err {
                        print("🛑  ERROR: \(error.localizedDescription)")
                        completion(Result.failure(error))
                    }

                    }.resume()
            } catch let err {

                completion(Result.failure(err))
            }
        }
    }

    func printAPIResponse(data: Data) {
        //Just for test print purposes
        do {
            let resultObject = try JSONSerialization.jsonObject(with: data, options: [])
            print("✅ Results from request:\n\(resultObject)")
        } catch let error {
            print("🛑 Unable to parse JSON response: \(error.localizedDescription)")
        }
    }
}
