//
//  MaskListViewModelTests.swift
//  DemoMaskListTests
//
//  Created by Kinlive on 2020/5/24.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import XCTest

@testable import DemoMaskList
class MaskListViewModelTests: XCTestCase {

  let url = URL(string: "https://test.com")!
  var events = MaskListViewModel.Events(onReloadData: nil, onFetchError: nil, isLoading: nil)

  var apiService: MockApiService!
  var session: MockSession!

  override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()

    session = MockSession()
    apiService = MockApiService()
  }

  override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.

    apiService = nil
    session = nil
    events.isLoading = nil
    events.onFetchError = nil
    events.onReloadData = nil

    try super.tearDownWithError()
  }

  /// Asserts `startFetch()` active correct.
  func test_startFetch() {

    // arrange
    let viewModel = MaskListViewModel(service: apiService, events: events)

    // act
    viewModel.startFetch(at: url)

    // assert
    XCTAssertTrue(apiService.isFetchDataCalled)
  }

  /// Asserts an error be passed correctly
  func test_fetchError() {

    // arrange
    let inputError: ApiError = .emptyData("EmptyData")
    var outputError: ApiError?

    events.onFetchError = { error in
      outputError = error
    }

    let viewModel = MaskListViewModel(service: apiService, events: events)

    // act
    viewModel.startFetch(at: url)
    apiService.fetchError(inputError)

    // assert
    XCTAssertEqual(inputError.localizedDescription, outputError?.localizedDescription)
  }

  /// Asserts MaskListCellViewModel of StubGenerator be passed to MaskListViewModell successful.
  func test_fetchSuccess() {
    // arrange
    let stubModel = StubGenerator().stubOfMaskList()
    let viewModel = MaskListViewModel(service: apiService, events: events)
    let cellViewModels = viewModel
      .groupedCounty(of: stubModel)
      .map { MaskListCellViewModel(maskAdult: $0.value, county: $0.key) }

    // act
    viewModel.startFetch(at: url)
    apiService.fetchSuccess(model: stubModel)

    // assert
    XCTAssertFalse(viewModel.output.cellViewModels.isEmpty)

    XCTAssertEqual(cellViewModels.count, viewModel.output.numberOfItems)
  }

  func test_loadingWhenFetch() {
    // arrange
    let stubModel = StubGenerator().stubOfMaskList()
    var loadingState = false
    let expect = XCTestExpectation(description: "Loading state updated")

    events.isLoading = { isLoading in
      loadingState = isLoading
      expect.fulfill()
    }

    let viewModel = MaskListViewModel(service: apiService, events: events)

    // act
    viewModel.startFetch()

    wait(for: [expect], timeout: 1)
    
    // assert service on loading
    XCTAssertTrue(loadingState)

    // act
    apiService.fetchSuccess(model: stubModel)

    // assert service loading finished
    XCTAssertFalse(loadingState)
  }

  func test_getCellViewModel() {
    // arrange
    let stubModel = StubGenerator().stubOfMaskList()
    let viewModel = MaskListViewModel(service: apiService, events: events)

    let groupedStubModels = viewModel
          .groupedCounty(of: stubModel)
          .map { MaskListCellViewModel(maskAdult: $0.value, county: $0.key) }
          .sorted(by: { $0.county < $1.county })

    let indexPathZero = IndexPath(item: 0, section: 0)
    let indexPathOne = IndexPath(item: 1, section: 0)

    let countyZero = groupedStubModels[indexPathZero.row]
    let countyOne = groupedStubModels[indexPathOne.row]

    // act
    viewModel.startFetch()
    apiService.fetchSuccess(model: stubModel)

    // assert cellViewModel's properties be set correctly

    // be tested model of item 1
    let cellViewModel = viewModel.output.cellViewModel(at: indexPathOne)

    XCTAssertEqual(countyOne.county, cellViewModel.county)
    XCTAssertEqual(countyOne.numberOfMaskAtAdult, cellViewModel.numberOfMaskAtAdult)

    XCTAssertNotEqual(countyZero.county, cellViewModel.county)
  }
}
