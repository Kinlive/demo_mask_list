//
//  MaskServiceTests.swift
//  DemoMaskListTests
//
//  Created by Thinkpower on 2020/5/22.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import DemoMaskList
class MaskServiceTests: XCTestCase {
    
    var service: MaskListApiService?
    let session = MockSession()
    let rx_session = MockRxSession()
    
    var resultOfError: ApiError?
    var resultOfModel: MaskListApiService.modelT?
    
    // rx use
    var testScheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    /// new
    var mockClient: MaskAPIClient!
    var mockRequest: MockAPIRequest!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        service = MaskListApiService(session: session, rxSession: rx_session)
        
        testScheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        mockRequest = MockAPIRequest()
        //mockClient = MaskAPIClient(request: mockRequest, nextMask: <#MaskList#>)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        service = nil
        resultOfError = nil
        resultOfModel = nil
        
        testScheduler = nil
        disposeBag = nil
        
        mockRequest = nil
        mockClient = nil
    }

    /*
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }*/
    
    func test_newClientProcess() {

       
        //let getMaskList = testScheduler.createObserver(MaskList.self)
        let stub = StubGenerator().stubOfMaskList()
        
        mockClient = MaskAPIClient(request: mockRequest, nextMask: stub)
        
         /* be fail
        mockClient.returnValue
            .bind(to: getMaskList)
            .disposed(by: disposeBag)

        testScheduler.createColdObservable([.next(20, ())])
            .bind(to: mockClient.sendObserver)
            .disposed(by: disposeBag)

        testScheduler.start()

        mockClient.returnValue
            .subscribe(onNext: { maskList in
                print("Test =============\(maskList.type)")
            })
            .disposed(by: disposeBag)

        XCTAssertEqual(getMaskList.events.first?.value.element?.features.count, 0) */
       
        // success
        let expect = self.expectation(description: "test")
        var outMaskList: MaskList?
        
        mockClient.returnValue
            .subscribe(onNext: { maskList in
                outMaskList = maskList
                expect.fulfill()
            })
            .disposed(by: disposeBag)
        
        mockClient.sendObserver.onNext(())
        
        wait(for: [expect], timeout: 5)
        
        XCTAssertNotEqual(outMaskList?.features.count, 0)
       
    }
    
    
    func test_GettingMaskService_BuildsThePath() throws {
        // arrange
        let url = URL(string: "https://com.test_url")!
        service = MaskListApiService(session: session, rxSession: rx_session)
        let expect = XCTestExpectation()
        
        // act
        service?.fetchData(with: url) { _ in
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 1)
        
        // assert to check the url passed equal with the requested url.
        XCTAssertEqual(url.path, session.lastUrl?.path)
        // assert with did dataTask had called resume()
        XCTAssertTrue(session.nextDataTask.wasResume)
        
        
        let testData = Observable<Data>.just(Data(count: 100))
        rx_session.returnTaskData = testData
        
        testScheduler.createHotObservable([.next(200, url)])
            .subscribe(onNext: { [unowned self ] url in self.service?.rx_fetchData(with: url).map { _ in url } })
            .disposed(by: disposeBag)
        
    }
    
    func test_GettingMaskService_ResponseParseFail() throws {
        
        // arrange
        let url = URL(string: "https://com.test_url")!
        let fakeData = "{fakeKey:'value'} ".data(using: .utf8)
        session.nextData = fakeData
        let expect = XCTestExpectation()
        
        service = MaskListApiService(session: session, rxSession: rx_session)
        
        // act
        service?.fetchData(with: url, result: { [weak self] (result) in
            switch result {
            case .success(let model): self?.resultOfModel = model as? MaskListApiService.modelT
            case .failure(let error): self?.resultOfError = error
            }
            expect.fulfill()
        })
        
        wait(for: [expect], timeout: 1)
        
        // assert the result error must equal to parseFail
        XCTAssertEqual(resultOfError, ApiError.parseFail(""))
        XCTAssertNil(resultOfModel)
        
        // assert always be fail with resultError type wrong.
        // XCTAssertEqual(resultOfError, ApiError.networkingError(""))
    }
    
    func test_GettingMaskService_ResponseNetworkingFail() throws {
        
        // arrange
        let url = URL(string: "test")!
        session.nextError = .networkingError("error anything")
        service = MaskListApiService(session: session, rxSession: rx_session)
        let expect = XCTestExpectation()
        
        // act
        service?.fetchData(with: url, result: { [weak self] (result) in
            switch result {
            case .success(let model): self?.resultOfModel = model as? MaskListApiService.modelT
            case .failure(let error): self?.resultOfError = error
            }
            expect.fulfill()
        })
        
        wait(for: [expect], timeout: 1)
        
        // assert
        XCTAssertEqual(resultOfError, ApiError.networkingError(""))
    }
    
    func test_GettingMaskService_ResponseDataEmptyFail() throws {
        // arrange
        let url = URL(string: "test")!
        session.nextData = Data()
        service = MaskListApiService(session: session, rxSession: rx_session)
        let failDataEmpty = expectation(description: #function)
        
        // act
        service?.fetchData(with: url, result: { [weak self] (result) in
            switch result {
            case .success(let model): self?.resultOfModel = model as? MaskListApiService.modelT
            case .failure(let error): self?.resultOfError = error
            }
            failDataEmpty.fulfill()
        })
        
        wait(for: [failDataEmpty], timeout: 1)
        
        // assert error must be data empty
        XCTAssertEqual(resultOfError, ApiError.emptyData(""))
    }
    
    func test_GettingMaskService_RequestedDataSuccess() throws {
        // arrange
        let truelyUrl = URL(string: "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json")!
        
        service = MaskListApiService(session: URLSession.shared, rxSession: rx_session)
        let didFetched = expectation(description: #function)
        
        // act
        service?.fetchData(with: truelyUrl, result: { [weak self] (result) in
            switch result {
            case .success(let model): self?.resultOfModel = model as? MaskListApiService.modelT
            case .failure(let error): self?.resultOfError = error
            }
            didFetched.fulfill()
        })
        
        wait(for: [didFetched], timeout: 3)
        
        // assert to check model must not to be nil
        XCTAssertNotNil(resultOfModel)
        
        // assert error always nil
        XCTAssertNil(resultOfError)
        
    }

}
