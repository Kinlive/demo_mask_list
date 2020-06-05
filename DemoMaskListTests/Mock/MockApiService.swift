//
//  MockApiService.swift
//  DemoMaskListTests
//
//  Created by Kinlive on 2020/5/24.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation
import RxSwift

@testable import DemoMaskList
class MockApiService: ApiServiceProtocol {
  typealias modelT = MaskList

  var resultClosure: ResultClosure?
  var isFetchDataCalled: Bool = false

  func fetchData(with url: URL, result: @escaping ResultClosure) {
    isFetchDataCalled = true
    resultClosure = result
  }

  func fetchError(_ error: ApiError) {
    resultClosure?(.failure(error))
  }

  func fetchSuccess(model: MaskListApiService.modelT) {
    resultClosure?(.success(model))
  }
  
  // refactor to rx use
  let rx_fetchDataCalled = PublishSubject<Bool>()
    
  var returnNext: Observable<MaskList> = .empty()
 
    
  func rx_fetchData(with url: URL) -> Observable<MaskList> {
    
    rx_fetchDataCalled.onNext(true)
    return returnNext
  }
    
}
