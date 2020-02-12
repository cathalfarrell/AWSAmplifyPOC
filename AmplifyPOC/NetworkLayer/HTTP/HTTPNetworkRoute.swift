//
//  HTTPNetworkRoute.swift
//  TruWork
//
//  Created by Cathal Tru on 02/07/2019.
//  Copyright © 2019 Cathal Tru. All rights reserved.
//

import Foundation

public enum HTTPNetworkRoute: String {
    case assets = "org/assets"
    case asset = "org/assets/:id"
    case faqs = "org/faqs"
    case faq = "org/faqs/:id"
    case steps = "work/step-types"
    case users = "user/users"
    case user = "user/users/me"
}
