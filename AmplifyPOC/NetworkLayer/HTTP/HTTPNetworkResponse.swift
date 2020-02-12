//
//  HTTPNetworkResponse.swift
//  TruWork
//
//  Created by Cathal Tru on 02/07/2019.
//  Copyright © 2019 Cathal Tru. All rights reserved.
//

import Foundation

struct HTTPNetworkResponse {

    // Properly checks and handles the status code of the response
    static func handleNetworkResponse(for response: HTTPURLResponse?) -> Result<String> {

        guard let res = response else { return Result.failure(HTTPNetworkError.unwrappingError)}

        switch res.statusCode {
        case 200...299: return Result.success(HTTPNetworkError.success.rawValue)
        case 401: return Result.failure(HTTPNetworkError.authenticationError)
        case 403: return Result.failure(HTTPNetworkError.forbiddenError)
        case 404: return Result.failure(HTTPNetworkError.resourceNotFound)
        case 400...499: return Result.failure(HTTPNetworkError.badRequest)
        case 500...599: return Result.failure(HTTPNetworkError.serverSideError)
        default: return Result.failure(HTTPNetworkError.failed)
        }
    }
}
