//
//  MaskListViewModel.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/21.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation
import RxSwift

class MaskListViewModel {
  static let url: URL = URL(string: "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json")!
  private let disposeBag = DisposeBag()

 // MARK: - Properties
  // MARK: - Input
  public let rx_viewWillAppear: AnyObserver<Bool>
  public let rx_startFetch: AnyObserver<Void>
  public let rx_triggerError: AnyObserver<Void>
  public let rx_itemSelected: AnyObserver<IndexPath>
    
  // MARK: - Outputs
  public let rx_isLoading: Observable<Bool>
  public let rx_cellViewModels: Observable<[MaskListCellViewModel]>
  public let rx_FetchError: Observable<ApiError>
    
  /// The events triggers UIs to fresh something.
  //public let events: Events

  /// Request api service
  private let apiService: ApiServiceProtocol

  /// Output contains values for UIs display.
  //private(set) var output: Output = Output()

  // MARK: - Initialize

  /// Initiailize with dependency injection.
    init(service: ApiServiceProtocol = MaskListApiService(session: URLSession.shared, rxSession: URLSession.shared),
         url: URL = MaskListViewModel.url) {
    self.apiService = service
    
    // declare area variable use to Observable.combinLatest puts parameters for observableType and pulic variable for bind ui.
    // when fetch data error or receive another errors.
    let _fetchError = PublishSubject<ApiError>()
    rx_FetchError = _fetchError.asObservable()
    
    // control refresh and indicator start/stop animation
    let _isLoading = PublishSubject<Bool>()
    rx_isLoading = _isLoading.asObserver()
    
    // fetch data when refreshControl actions
    let _startFetch = PublishSubject<Void>()
    rx_startFetch = _startFetch.asObserver()
    
    // when viewWillAppear start fetch data
    let _viewWillAppear = PublishSubject<Bool>()
    rx_viewWillAppear = _viewWillAppear.asObserver()
    _viewWillAppear
        .compactMap { _ in () }
        .bind(to: _startFetch)
        .disposed(by: disposeBag)
    
    // manual emit an error by errorBtn
    let _triggerError = PublishSubject<Void>()
    rx_triggerError = _triggerError.asObserver()
    _triggerError
        .compactMap { ApiError.emptyData("Test bind") }
        .bind(to: _fetchError)
        .disposed(by: disposeBag)
    
    // when selected item of cell
    let _itemSelected = PublishSubject<IndexPath>()
    rx_itemSelected = _itemSelected.asObserver()
    _itemSelected
        .compactMap { ApiError.networkingError("Test selected\($0)") }
        .bind(to: _fetchError)
        .disposed(by: disposeBag)
    
    // fetch data
    rx_cellViewModels = _startFetch
        .flatMapLatest { _ -> Observable<MaskList> in
            _isLoading.onNext(true)
            return service.rx_fetchData(with: url)
               /* here's error will be emit to do(onError), use do() can let nested closure less.
                .catchError { error -> Observable<MaskList> in
                    _fetchError.onNext(.networkingError(error.localizedDescription))
                    return .empty()
                }*/
        }
        .do(onNext: { _ in _isLoading.onNext(false) })
        .do(onError: { error in
            _fetchError.onNext(.parseFail(error.localizedDescription)) })
        .map { MaskListViewModel.rx_prepareItems(of: $0) }
  }

  // MARK: - Methods
  // why it be static ? On initializing can't use property method
  static func rx_prepareItems(of models: MaskListApiService.modelT) -> [MaskListCellViewModel] {
    var dic: [String : Int] = [:]

    models.features.forEach {
      if var maskAdult = dic[$0.properties.county] {
        maskAdult += $0.properties.maskAdult
        dic[$0.properties.county] = maskAdult

      } else {
        dic[$0.properties.county] = $0.properties.maskAdult
      }
    }
    
    var cellViewModels: [MaskListCellViewModel] = []
    
    dic.forEach { cellViewModels.append(MaskListCellViewModel(maskAdult: $0.value, county: $0.key)) }
    cellViewModels.sort(by: { $0.county < $1.county })
    
    return cellViewModels
  }
    
}
