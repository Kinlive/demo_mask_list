//
//  MaskListApiService.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/21.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation

class MaskListApiService: ApiServiceProtocol {
    
    typealias modelT = [MaskList]
    
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    // implement ApiServiceProtocol method.
    func fetchData(with url: URL, result: @escaping ResultClosure) {
        let task = session.task(with: url) { (data, response, error) in
            if let error = error {
                result(.failure(.networkingError(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                result(.failure(.emptyData("Data empty.")))
                return
            }
            
            do {
                let model = try JSONDecoder().decode(modelT.self, from: data)
                result(.success(model))
                
            } catch let error {
                result(.failure(.parseFail(error.localizedDescription)))
            }
        }
        
        task.resume()
    }
    
}
