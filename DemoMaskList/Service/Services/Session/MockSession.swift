//
//  MockSession.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/22.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation

class MockSession: URLSessionProtocol {
    
    private(set) var lastUrl: URL?
    
    var nextDataTask = MockSessionDataTask()
    var nextData: Data?
    var nextError: ApiError?
    
    func successHttpUrlResponse(request: URLRequest) -> URLResponse? {
        guard let url = request.url else { return nil }
        return HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
    }
    
    func task(with url: URL, completionHandler: @escaping TaskResult) -> URLSessionDataTaskProtocol {
        lastUrl = url
        
        let request = URLRequest(url: url)
        
        completionHandler(nextData, successHttpUrlResponse(request: request), nextError)
        
        return nextDataTask
    }

}

class MockSessionDataTask: URLSessionDataTaskProtocol {
    
    private(set) var wasResume: Bool = false
    
    func resume() {
        
        wasResume = true
    }
    
    
}
