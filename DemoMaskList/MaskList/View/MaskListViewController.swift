//
//  MaskListViewController.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/21.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MaskListViewController: UIViewController, UITableViewDelegate {

  let disposeBag = DisposeBag()
    
  lazy var tableView: UITableView = {
    let table = UITableView(frame: .zero)
    table.register(MaskListCell.self, forCellReuseIdentifier: String(describing: MaskListCell.self))
    table.translatesAutoresizingMaskIntoConstraints = false
    return table
  }()

  lazy var indicatorView: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .large)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.color = .darkGray
    return view
  }()

  lazy var errorButton: UIButton = {
    let btn = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.backgroundColor = .lightGray
    btn.layer.cornerRadius = 25
    btn.layer.masksToBounds = true
    btn.setTitle("Error", for: .normal)

    return btn
  }()
    
  var rx_showAlert: Binder<ApiError> {
        
    return Binder(UIAlertController(title: "",
                                    message: "",
                                    preferredStyle: .alert),
                  scheduler: MainScheduler.instance) { [weak self] (alert, error: ApiError) in
    
        guard let `self` = self else { return }
        alert.title = "Fetch Error"
        alert.message = error.localizedDescription

        let ok = UIAlertAction(title: "確認", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
  }
    
  let refreshControl = UIRefreshControl()

  let viewModel = MaskListViewModel()

  override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.
    view.addSubview(tableView)
    view.addSubview(indicatorView)
    view.addSubview(errorButton)
    
    setupUI()
    setupBindings()
  }

  func setupUI() {
    tableView.rowHeight = 100
    tableView.estimatedRowHeight = 150
    tableView.insertSubview(refreshControl, at: 0)
    tableView.delegate = nil
    tableView.dataSource = nil
  }
    
  func setConstraints() {
    tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

    indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

    errorButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
    errorButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
    errorButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    errorButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
  }
    
  func setupBindings() {
    // First request binding to viewDidAppear
    rx.viewDidAppear
        .subscribe { [unowned self] _ in self.refreshControl.sendActions(for: .valueChanged) }
        .disposed(by: disposeBag)
    
    rx.viewDidLayoutSubviews
        .subscribe { [unowned self] _ in self.setConstraints() }
        .disposed(by: disposeBag)

    // bind ui
    refreshControl.rx.controlEvent(.valueChanged)
        .asObservable()
        .bind(to: viewModel.rx_startFetch)
        .disposed(by: disposeBag)

    errorButton.rx.tap
        .subscribe(onNext: { _ in self.viewModel.events.rx_FetchError
                                        .onNext(.parseFail("Test parse failed")) })
        .disposed(by: disposeBag)
    
    
//    tableView.rx.modelSelected(MaskListCellViewModel.self)
//        .subscribe(onNext: { model in self.rx_showAlert.onNext(.emptyData("selected model:\(model)"))})
//        .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
        .subscribe(onNext: { index in self.rx_showAlert.on(.next(.emptyData("selected \(index)")))})
        .disposed(by: disposeBag)

    
    // bind viewModel.outputs.
    viewModel.output.rx_cellViewModels
        .bind(to: tableView.rx.items(cellIdentifier: String(describing: MaskListCell.self))) { (index, cellViewModel, cell: MaskListCell) in
            cell.rx_viewModel.onNext(cellViewModel)
    }
        .disposed(by: disposeBag)
    
    viewModel.output.rx_cellViewModels
        .map { _ in false }
        .bind(to: refreshControl.rx.isRefreshing)
        .disposed(by: disposeBag)
    
    // bind viewModel.events.
    viewModel.events.rx_isLoading
        .bind(to: self.indicatorView.rx.isAnimating)
        .disposed(by: disposeBag)
    
    viewModel.events.rx_FetchError
        .subscribe(onNext: { self.rx_showAlert.onNext($0) })
        .disposed(by: disposeBag)
  }

}


// MARK: - Extension Reactive with UIViewController life cycle.
extension Reactive where Base: UIViewController {
    public var viewDidLoad: ControlEvent<Void> {
        return ControlEvent(events: self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in })
    }
    
    public var viewWillAppear: ControlEvent<Bool> {
        return ControlEvent(events: self.methodInvoked(#selector(Base.viewWillAppear(_:))).map { $0.first as? Bool ?? false })
    }
    
    public var viewDidAppear: ControlEvent<Bool> {
        return ControlEvent(events: self.methodInvoked(#selector(Base.viewDidAppear(_:))).map { $0.first as? Bool ?? false })
    }
    
    public var viewDidLayoutSubviews: ControlEvent<Void> {
        return ControlEvent(events: self.methodInvoked(#selector(Base.viewDidLayoutSubviews)).map { _ in })
    }
}


extension Reactive where Base: UIRefreshControl {
    public var sendAction: ControlEvent<UIControl.Event> {
        return ControlEvent(events: self.methodInvoked(#selector(Base.sendActions(for:))).map { event in event.first as? UIControl.Event ?? UIControl.Event.touchUpInside })
    }
    
}
