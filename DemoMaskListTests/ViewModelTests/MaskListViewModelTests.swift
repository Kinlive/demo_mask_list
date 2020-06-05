//
//  MaskListViewModelTests.swift
//  DemoMaskListTests
//
//  Created by Kinlive on 2020/5/24.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import DemoMaskList
class MaskListViewModelTests: XCTestCase {

  let url = URL(string: "https://test.com")!

  var apiService: MockApiService!
  var disposeBag: DisposeBag!
  var testScheduler: TestScheduler!
  var viewModel: MaskListViewModel!
  
  /// [NOTICE]: - Here is very important, it's still needs a `cellViewModels.observer`(e.g. this sample of startFetch)
  ///   to keep emit, if not provide the test will loss and will `never` fetchError or next elements.
  var cellVMObserver: TestableObserver<[MaskListCellViewModel]>!
    
  let stub = StubGenerator().stubOfMaskList()

  override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()

    apiService = MockApiService()
    disposeBag = DisposeBag()
    testScheduler = TestScheduler(initialClock: 0)
    viewModel = MaskListViewModel(service: apiService, url: url)
   
    cellVMObserver = testScheduler.createObserver([MaskListCellViewModel].self)
    
    viewModel.rx_cellViewModels
        .bind(to: cellVMObserver)
        .disposed(by: disposeBag)
  }

  override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.

    apiService = nil
    disposeBag = nil
    testScheduler = nil
    viewModel = nil
    cellVMObserver = nil
    
    try super.tearDownWithError()
  }

  /// Asserts `startFetch()` active correct.
  func test_startFetch() {
    
    // arrange
    
    // create observer for check target
    let hadFetch = testScheduler.createObserver(Bool.self)
    
    apiService.rx_fetchDataCalled
        .bind(to: hadFetch)
        .disposed(by: disposeBag)
    
    // act
    testScheduler.createColdObservable([.next(20, ())])
        .bind(to: viewModel.rx_startFetch)
        .disposed(by: disposeBag)

    testScheduler.start()

    // Assert
    XCTAssertEqual(hadFetch.events, [.next(20, true)])
    
  }

  /// Asserts an error be passed correctly
  func test_fetchError() {
    
    // arrange.  [reminder] need to modify ApiError define that can transfer to error
    apiService.returnNext = Observable.error(ApiError.parseFail("TestError"))
    
    // create observer for check target
    let fetchError = testScheduler.createObserver(ApiError.self)
    
    viewModel.rx_FetchError
        .bind(to: fetchError)
        .disposed(by: disposeBag)
    
    // act
    testScheduler.createColdObservable([.next(20, ())])
        .bind(to: viewModel.rx_startFetch)
        .disposed(by: disposeBag)

    testScheduler.start()

    // Assert
    XCTAssertEqual(fetchError.events, [.next(20, ApiError.parseFail("Test"))])
  }

  func test_loadingStateWhenFetch() {
    // arrange
    apiService.returnNext = Observable.just(stub)
    let loading: Recorded<Event<Bool>> = .next(20, true)
    let unloading: Recorded<Event<Bool>> = .next(20, false)
    
    let loadingObserver = testScheduler.createObserver(Bool.self)
    
    
    viewModel.rx_isLoading
        .bind(to: loadingObserver)
        .disposed(by: disposeBag)
    
    // act
    testScheduler.createColdObservable([.next(20, ())])
        .bind(to: viewModel.rx_startFetch)
        .disposed(by: disposeBag)
    
    testScheduler.start()
    
    // assert
    XCTAssertEqual(loadingObserver.events, [loading, unloading])
    
  }

  func test_getCellViewModel() {
    // arrange
    let stubCellViewModels = MaskListViewModel.rx_prepareItems(of: stub)
    
    apiService.returnNext = Observable.just(stub)
    
    
    // act
    testScheduler.createColdObservable([.next(20, ())])
        .bind(to: viewModel.rx_startFetch)
        .disposed(by: disposeBag)

    testScheduler.start()

    // Assert
    XCTAssertEqual(cellVMObserver.events.first?.value.element?.count, stubCellViewModels.count)
  }
  
  // Here we hadn't check which item be selected, because in our
  //   MaskListViewModel designed that selected would trigger fetchError,
  //   so final asserts there get one error.
  func test_itemSelected() {
    // arrange
    let fetchErrorObserver = testScheduler.createObserver(ApiError.self)
    
    viewModel.rx_FetchError
        .bind(to: fetchErrorObserver)
        .disposed(by: disposeBag)
    
    // act
    testScheduler.createColdObservable([.next(20, IndexPath(item: 0, section: 0))])
        .bind(to: viewModel.rx_itemSelected)
        .disposed(by: disposeBag)
    
    testScheduler.start()
    
    // assert
    XCTAssertEqual(fetchErrorObserver.events.count, 1)
    
  }
    
  func test_triggerError() {
    // arrange
    let fetchErrorObserver = testScheduler.createObserver(ApiError.self)
    
    viewModel.rx_FetchError
        .bind(to: fetchErrorObserver)
        .disposed(by: disposeBag)
    
    // act
    testScheduler.createColdObservable([.next(20, ())])
        .bind(to: viewModel.rx_triggerError)
        .disposed(by: disposeBag)
    
    testScheduler.start()
        
    // assert
    XCTAssertEqual(fetchErrorObserver.events, [.next(20, ApiError.emptyData(""))])
  }
    
  func test_onViewWillAppear_willStartFetch() {
    // arrange
    let startFetch = testScheduler.createObserver(Bool.self)
    
    apiService.rx_fetchDataCalled
        .bind(to: startFetch)
        .disposed(by: disposeBag)
    
    // act, here true send an event to viewWillAppear
    testScheduler.createColdObservable([.next(20, true)])
        .bind(to: viewModel.rx_viewWillAppear)
        .disposed(by: disposeBag)
    
    testScheduler.start()
    
    // assert
    XCTAssertEqual(startFetch.events, [.next(20, true)])
  }
    
}
