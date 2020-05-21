//
//  ApiError.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/21.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation

enum ApiError: Error {
    case parseFail(String)
    case networkingError(String)
}
