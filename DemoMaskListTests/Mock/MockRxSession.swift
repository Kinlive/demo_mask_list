//
//  MockRxSession.swift
//  DemoMaskListTests
//
//  Created by Thinkpower on 2020/6/4.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation
import RxSwift

@testable import DemoMaskList
class MockRxSession: RxURLSessionProtocol {
    
    // input
    var returnTaskData: Observable<Data> = .empty()
    
    
    // output
    private(set) var rx_lastUrl: PublishSubject<URL> = .init()
    private(set) var lastUrl: URL?
    
    func task(with url: URL) -> Observable<Data> {
        lastUrl = url
        
        return returnTaskData
        
    }
    
}

