//
//  APIRequestProtocol.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/6/8.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation

protocol APIRequestProtocol: class {
    var method: RequestType { get }
    var path: String { get }
    var parameters: [String : String] { get }
}

extension APIRequestProtocol {
    func request(with baseUrl: URL) throws -> URLRequest {
        
        var finalURL: URL = baseUrl
        
        if !path.isEmpty, !parameters.isEmpty {
            guard var component = URLComponents(url: baseUrl.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
                throw ApiError.generateRequest("Unable to create URL components.")
            }
            component.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
            
            if let url = component.url {
                finalURL = url
            } else {
                throw ApiError.url("Could not get url.")
            }
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
}
