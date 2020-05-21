//
//  URLSessionProtocol.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/21.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation

protocol URLSessionProtocol: class {
    typealias TaskResult = (Data?, URLResponse?, Error?) -> Void
    func task(with url: URL, completionHandler: @escaping TaskResult) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol: class {
    func resume()
}

// MARK: - conform to protocol
extension URLSession: URLSessionProtocol {
    func task(with url: URL, completionHandler: @escaping (TaskResult)) -> URLSessionDataTaskProtocol {
        return dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTaskProtocol
    }
    
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }
