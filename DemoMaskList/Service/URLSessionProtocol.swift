//
//  URLSessionProtocol.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/21.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation
import RxSwift

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


protocol RxURLSessionProtocol: class {
    func task(with url: URL) -> Observable<Data>
}

extension URLSession: RxURLSessionProtocol {
    func task(with url: URL) -> Observable<Data> {
        return rx.data(request: URLRequest(url: url)).flatMap { Observable.just($0) }
    }
    
}

protocol RxURLSessionDataTaskProtocol: class {
    func resume()
}
