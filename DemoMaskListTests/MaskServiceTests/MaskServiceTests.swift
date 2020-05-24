//
//  MaskServiceTests.swift
//  DemoMaskListTests
//
//  Created by Thinkpower on 2020/5/22.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import XCTest

@testable import DemoMaskList
class MaskServiceTests: XCTestCase {
    
    var service: MaskListApiService?
    let session = MockSession()
    
    var resultOfError: ApiError?
    var resultOfModel: MaskListApiService.modelT?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        service = nil
        resultOfError = nil
        resultOfModel = nil
    }

    /*
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }*/
    
    
    func test_GettingMaskService_BuildsThePath() throws {
        // arrange
        let url = URL(string: "https://com.test_url")!
        service = MaskListApiService(session: session)
        
        // act
        service?.fetchData(with: url) { _ in }
        
        // assert to check the url passed equal with the requested url.
        XCTAssertEqual(url.path, session.lastUrl?.path)
        // assert with did dataTask had called resume()
        XCTAssertTrue(session.nextDataTask.wasResume)
        
    }
    
    func test_GettingMaskService_ResponseParseFail() throws {
        
        // arrange
        let url = URL(string: "https://com.test_url")!
        let fakeData = "{fakeKey:'value'} ".data(using: .utf8)
        session.nextData = fakeData
        
        service = MaskListApiService(session: session)
        
        // act
        service?.fetchData(with: url, result: { [weak self] (result) in
            switch result {
            case .success(let model): self?.resultOfModel = model as? MaskListApiService.modelT
            case .failure(let error): self?.resultOfError = error
            }
        })
        
        sleep(1)
        
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
        service = MaskListApiService(session: session)
        
        // act
        service?.fetchData(with: url, result: { [weak self] (result) in
            switch result {
            case .success(let model): self?.resultOfModel = model as? MaskListApiService.modelT
            case .failure(let error): self?.resultOfError = error
            }
        })
        
        sleep(1)
        // assert
        XCTAssertEqual(resultOfError, ApiError.networkingError(""))
    }
    
    func test_GettingMaskService_ResponseDataEmptyFail() throws {
        // arrange
        let url = URL(string: "test")!
        session.nextData = Data()
        service = MaskListApiService(session: session)
        
        // act
        service?.fetchData(with: url, result: { [weak self] (result) in
            switch result {
            case .success(let model): self?.resultOfModel = model as? MaskListApiService.modelT
            case .failure(let error): self?.resultOfError = error
            }
        })
        
        sleep(1)
        // assert error must be data empty
        XCTAssertEqual(resultOfError, ApiError.emptyData(""))
    }
    
    func test_GettingMaskService_RequestedDataSuccess() throws {
        // arrange
        let truelyUrl = URL(string: "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json")!
        
        service = MaskListApiService(session: URLSession.shared)
        
        // act
        service?.fetchData(with: truelyUrl, result: { [weak self] (result) in
            switch result {
            case .success(let model): self?.resultOfModel = model as? MaskListApiService.modelT
            case .failure(let error): self?.resultOfError = error
            }
        })
        
        // wait for response back.
        sleep(3)
        
        // assert to check model must not to be nil
        XCTAssertNotNil(resultOfModel)
        
        // assert error always nil
        XCTAssertNil(resultOfError)
    }

}
