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
    
  let refreshControl = UIRefreshControl()

  lazy var viewModel: MaskListViewModel = {
    let vm = MaskListViewModel(events: .init(onReloadData: {
      //DispatchQueue.main.async {
        //self.tableView.reloadData()
      //}
    }, onFetchError: { (error) in
      //DispatchQueue.main.async {
        //self.showAlert(error: error)
      //}

    }, isLoading: { (isLoading) in
//      DispatchQueue.main.async {
//        isLoading ? self.indicatorView.startAnimating() : self.indicatorView.stopAnimating()
//      }
    }))
    
    vm.events.rx_isLoading
        .bind(to: self.indicatorView.rx.isAnimating)
        .disposed(by: disposeBag)
    
    vm.events.rx_FetchError
        .bind(to: rx_showAlert())
        .disposed(by: disposeBag)
    
    return vm
  }()

  override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.
    view.addSubview(tableView)
    view.addSubview(indicatorView)
    view.addSubview(errorButton)
    
    setupUI()
    setupBindings()
   
    refreshControl.sendActions(for: .valueChanged)
  }

  func setupUI() {
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 100
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
    
    refreshControl.rx.controlEvent(.valueChanged)
        .asObservable()
        .bind(to: viewModel.rx_startFetch)
        .disposed(by: disposeBag)
    
    viewModel.output.rx_cellViewModels
        .bind(to: tableView.rx.items(cellIdentifier: String(describing: MaskListCell.self))) { (index, cellViewModel, cell: MaskListCell) in
            cell.rx_viewModel.onNext(cellViewModel)
    }
        .disposed(by: disposeBag)
    
    errorButton.rx.tap
        .bind(to: rx_onErrorButtonTouched())
        .disposed(by: disposeBag)
    
    tableView.rx.modelSelected(MaskListCell.self)
        .subscribe(onNext: { _ in })
        .disposed(by: disposeBag)
    
    rx.viewDidLayoutSubviews
        .subscribe { [unowned self] _ in self.setConstraints() }
        .disposed(by: disposeBag)
  }
  
  func rx_showAlert() -> Binder<ApiError> {
    
    return Binder<ApiError>(UIAlertController(title: nil, message: nil, preferredStyle: .alert), scheduler: MainScheduler.instance) { [weak self] (alert, error) in
        guard let `self` = self else { return }
        alert.title = "Fetch Error"
        alert.message = error.localizedDescription

        let ok = UIAlertAction(title: "確認", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
  }

  func rx_onErrorButtonTouched() -> Binder<Void> {
    return Binder<Void>(self.errorButton) { [unowned self] (btn, _) in
        self.viewModel.events.rx_FetchError.onNext(.parseFail("Test parse failed"))
    }
  }

}

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
