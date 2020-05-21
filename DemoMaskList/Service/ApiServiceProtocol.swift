//
//  ApiServiceProtocol.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/21.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation


protocol ApiServiceProtocol: class {
    associatedtype modelT
    typealias ApiResult = Result<modelT, ApiError>
    typealias ResultClosure = (ApiResult) -> Void
    
    func fetchData(with url: URL, result: @escaping ResultClosure)
}
