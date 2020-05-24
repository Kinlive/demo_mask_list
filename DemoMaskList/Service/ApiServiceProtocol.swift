//
//  ApiServiceProtocol.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/21.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation

typealias ApiResult = Result<Codable, ApiError>
protocol ApiServiceProtocol: class {
    //associatedtype modelT
    typealias ResultClosure = (ApiResult) -> Void
    
    func fetchData(with url: URL, result: @escaping ResultClosure)
}
