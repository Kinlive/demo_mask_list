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

  // MARK: - Define struct
  // Events define
  struct Events {
    var onReloadData: (() -> Void)?
    var onFetchError: ((ApiError) -> Void)?
    var isLoading: ((Bool) -> Void)?
    
    let rx_reloadData = PublishSubject<Void>()
    let rx_FetchError = PublishSubject<ApiError>()
    let rx_isLoading = PublishSubject<Bool>()
    
  }

  // Output define
  struct Output {
    /// number of counties
    let numberOfItems: Int
    
    let cellViewModels: [MaskListCellViewModel]
    
    let rx_numberOfItemrs = PublishSubject<Int>()
    let rx_cellViewModels = PublishSubject<[MaskListCellViewModel]>()
    
    
    
    func cellViewModel(at indexPath: IndexPath) -> MaskListCellViewModel {
      return cellViewModels[indexPath.row]
    }

  }

  // MARK: - Properties

  /// The events triggers UIs to fresh something.
  public let events: Events

  private(set) var cellViewModels: [MaskListCellViewModel] = [] {
    didSet {
      self.output = Output(numberOfItems: cellViewModels.count, cellViewModels: cellViewModels)
      self.events.onReloadData?()
    }
  }

  /// Request api service
  private let apiService: ApiServiceProtocol

  /// Output contains values for UIs display.
  private(set) var output: Output = Output(numberOfItems: 0, cellViewModels: [])

  var rx_startFetch: AnyObserver<Void> {
      return AnyObserver { [unowned self] _ in
          self.startFetch()
      }
  }
    
  // MARK: - Initialize

  /// Initiailize with dependency injection.
  init(service: ApiServiceProtocol = MaskListApiService(session: URLSession.shared), events: Events) {
    self.apiService = service
    self.events = events
  }

  // MARK: - Methods

  // start fetch mask informations
  func startFetch(at url: URL = MaskListViewModel.url) {

    //self.events.isLoading?(true)
    self.events.rx_isLoading.onNext(true)

    apiService.fetchData(with: url) { [weak self] (result) in
      guard let `self` = self else { return }

      //self.events.isLoading?(false)
        self.events.rx_isLoading.onNext(false)
        
      switch result {
      case .success(let model):
        self.prepareIterms(of: model as! MaskListApiService.modelT)

      case .failure(let error):
        //self.events.onFetchError?(error)
        self.events.rx_FetchError.onNext(error)
      }
    }
  }
    

  // Transfer API response model to cellViewModels
  private func prepareIterms(of models: MaskListApiService.modelT) {
    let dic = groupedCounty(of: models)

    dic.forEach { cellViewModels.append(MaskListCellViewModel(maskAdult: $0.value, county: $0.key)) }
    cellViewModels.sort(by: { $0.county < $1.county } )
    
    output.rx_cellViewModels.onNext(cellViewModels)
  }

  /// The common use to grouped with each counties and sum of mask num of adult.
  func groupedCounty(of models: MaskListApiService.modelT) -> [String : Int] {
    var dic: [String : Int] = [:]

    models.features.forEach {
      if var maskAdult = dic[$0.properties.county] {
        maskAdult += $0.properties.maskAdult
        dic[$0.properties.county] = maskAdult

      } else {
        dic[$0.properties.county] = $0.properties.maskAdult
      }
    }
    return dic
  }

}
