//
//  Environment.swift
//  AmplifyPOC
//
//  Created by Cathal Tru on 04/07/2019.
//  Copyright © 2019 Cathal Tru. All rights reserved.
//

import Foundation

enum Environment: String {

    // You can switch environments in the scheme environment variables
    // Note these environment variables are only effective within xcode environment

    case dev
    case test
    case uat
    case beta
    case prod

    init?(env: String) {
        switch env {
        case "dev":
            self = .dev
        case "test":
            self = .test
        case "uat":
            self = .uat
        case "beta":
            self = .beta
        default:
            self = .prod
        }
    }

    // Remember the environment variables only work within xcode environment
    static func currentEnvironment() -> Environment {
        #if DEVENV
            return .dev
        #elseif TESTENV
            return .test
        #elseif UATENV
            return .uat
        #elseif BETAENV
            return .beta
        #else
            return .prod
        #endif
    }

    // Remember for links being externally shared - we need to point to the website rather than api
    static func baseURLforAPI() -> String {
        if .prod == currentEnvironment() {
            return "PROD: PATH TO BE DETERMINED"
        } else if .test == currentEnvironment() {
            return "TEST: PATH TO BE DETERMINED"
        } else if .uat == currentEnvironment() {
            return "UAT: PATH TO BE DETERMINED"
        } else if .beta == currentEnvironment() {
            return "BETA: PATH TO BE DETERMINED"
        } else {
            //e.g. DEV
            return "https://<YOUR-URL-HERE>/api/\(apiVersion)"
        }
    }

    private static var apiVersion: String {
        return "v1"
    }
}
