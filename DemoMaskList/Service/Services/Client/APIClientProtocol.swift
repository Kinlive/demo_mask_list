//
//  APIClientProtocol.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/6/8.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation
import RxSwift

protocol APIClientProtocol: class {
    static var baseURL: URL { get }
    var request: APIRequestProtocol { get }
    
    //func send<modelT: Codable>() -> Observable<modelT>
}

class MaskAPIClient: APIClientProtocol {
    
    private let disposeBag = DisposeBag()
    
    var request: APIRequestProtocol
    
    static var baseURL: URL {
        return URL(string: "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json")!
    }
    
    var sendObserver: AnyObserver<Void>
    
    var returnValue: Observable<MaskList> = .empty()
    
    var nextMask: MaskList
    
    init(request: APIRequestProtocol, nextMask: MaskList) {
        
        self.request = request
        self.nextMask = nextMask
        
        let _sendObserver = PublishSubject<Void>()
        sendObserver = _sendObserver.asObserver()
        
        /*_sendObserver
            .subscribe(onNext: { _ in
                do {
                    let genrerateRequest = try request.request(with: MaskAPIClient.baseURL)
                    self.returnValue = URLSession.shared.rx
                        .response(request: genrerateRequest)
                        .retry(3)
                        .observeOn(OperationQueueScheduler(operationQueue: .init()))
                        .map { try JSONDecoder().decode(MaskList.self, from: $0.data) }
                    
                } catch let error {
                    self.returnValue = .error(error)
                }
            })
            .disposed(by: disposeBag) */
        
        returnValue = _sendObserver
            .map { _ in try request.request(with: MaskAPIClient.baseURL) }
            //.flatMapFirst { $0 }
            .retry(3)
            .observeOn(OperationQueueScheduler(operationQueue: .init()))
            .compactMap { URLSession.shared.rx.response(request: $0) }
            .flatMapFirst { $0 }
            .observeOn(MainScheduler.instance)
            .do(onError: { print("-------\($0)")})
            .compactMap { _ in nextMask }//try JSONDecoder().decode(MaskList.self, from: $0.data) }
    }
    
}
