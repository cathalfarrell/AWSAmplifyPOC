//
//  Result.swift
//  TruWork
//
//  Created by Cathal Tru on 18/07/2019.
//  Copyright © 2019 Cathal Tru. All rights reserved.
//

import Foundation

enum Result<T> {

    case success(T)
    case failure(Error)
}
