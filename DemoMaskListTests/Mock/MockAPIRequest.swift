//
//  MockAPIRequest.swift
//  DemoMaskListTests
//
//  Created by Thinkpower on 2020/6/8.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation

@testable import DemoMaskList
class MockAPIRequest: APIRequestProtocol {
    var method: RequestType { .GET }
    
    var path: String { "" }
    
    var parameters: [String : String] { [:] }
    
}
