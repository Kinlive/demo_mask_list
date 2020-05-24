//
//  MaskListViewModel.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/21.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation

class MaskListViewModel {
  static let url: URL = URL(string: "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json")!

  // MARK: - Define struct
  // Events define
  struct Events {
    var onReloadData: (() -> Void)?
    var onFetchError: ((ApiError) -> Void)?
    var isLoading: ((Bool) -> Void)?
  }

  // Output define
  struct Output {
    let numberOfItems: Int
    let cellViewModels: [MaskListCellViewModel]

    func cellViewModel(at indexPath: IndexPath) -> MaskListCellViewModel {
      return cellViewModels[indexPath.row]
    }

  }

  // MARK: - Properties

  /// The events triggers UIs to fresh something.
  private let events: Events

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

  // MARK: - Initialize

  /// Initiailize with dependency injection.
  init(service: ApiServiceProtocol = MaskListApiService(session: URLSession.shared), events: Events) {
    self.apiService = service
    self.events = events
  }

  // MARK: - Methods

  // start fetch mask informations
  func startFetch(at url: URL = MaskListViewModel.url) {

    self.events.isLoading?(true)

    apiService.fetchData(with: url) { [weak self] (result) in
      guard let `self` = self else { return }

      self.events.isLoading?(false)

      switch result {
      case .success(let model):
        self.prepareIterms(of: model as! MaskListApiService.modelT)

      case .failure(let error):
        self.events.onFetchError?(error)
      }
    }
  }

  // Transfer API response model to cellViewModels
  private func prepareIterms(of models: MaskListApiService.modelT) {
    models.features.forEach { cellViewModels.append(MaskListCellViewModel(mask: $0)) }
  }

}
