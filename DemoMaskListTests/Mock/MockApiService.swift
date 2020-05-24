//
//  MockApiService.swift
//  DemoMaskListTests
//
//  Created by Kinlive on 2020/5/24.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation

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

}
