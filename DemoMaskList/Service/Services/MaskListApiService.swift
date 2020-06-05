//
//  MaskListApiService.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/21.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation
import RxSwift

class MaskListApiService: ApiServiceProtocol {
    
    typealias modelT = MaskList
    
    private let session: URLSessionProtocol
    private let rx_session: RxURLSessionProtocol
    
    init(session: URLSessionProtocol, rxSession: RxURLSessionProtocol) {
        self.session = session
        self.rx_session = rxSession
        
    }
    
    // implement ApiServiceProtocol method.
    func fetchData(with url: URL, result: @escaping ResultClosure) {
        let task = session.task(with: url) { (data, response, error) in
            if let error = error {
                result(.failure(.networkingError(error.localizedDescription)))
                return
            }
            
            guard let data = data, !data.isEmpty else {
                result(.failure(.emptyData("Data empty.")))
                return
            }
            
            do {
                let model = try JSONDecoder().decode(modelT.self, from: data)
                result(.success(model))
                
            } catch let error {
                result(.failure(.parseFail("\n\(error.localizedDescription) \n in data: \(String(data: data, encoding: .utf8) ?? "")")))
            }
        }
        
        task.resume()
    }
    
    func rx_fetchData(with url: URL) -> Observable<MaskList> {
        return rx_session.task(with: url)
            .retry(3)
            .observeOn(OperationQueueScheduler.init(operationQueue: .init()))
            .compactMap { try JSONDecoder().decode(MaskList.self, from: $0) }
    }
    
}
