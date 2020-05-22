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
    case emptyData(String)
    
    var localizedDescription: String {
        switch self {
        case .emptyData(let message):       return message
        case .networkingError(let message): return message
        case .parseFail(let message):       return message
        }
    }
}

extension ApiError: Equatable {
    static func == (lhs: ApiError, rhs: ApiError) -> Bool {
        switch (lhs, rhs) {
        case (.parseFail, .parseFail)            : return true
        case (.networkingError, .networkingError): return true
        case (.emptyData, .emptyData)            : return true
        default                                  : return false
        }
    }
}
