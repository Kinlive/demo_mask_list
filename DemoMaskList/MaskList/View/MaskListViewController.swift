//
//  MaskListViewController.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/21.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import UIKit

class MaskListViewController: UIViewController {

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

  lazy var viewModel: MaskListViewModel = {
    let vm = MaskListViewModel(events: .init(onReloadData: {
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }, onFetchError: { (error) in
      DispatchQueue.main.async {
        self.showAlert(error: error)
      }

    }, isLoading: { (isLoading) in
      DispatchQueue.main.async {
        isLoading ? self.indicatorView.startAnimating() : self.indicatorView.stopAnimating()
      }
    }))

    return vm
  }()

  override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.
    view.addSubview(tableView)
    view.addSubview(indicatorView)
    view.addSubview(errorButton)
    tableView.delegate = self
    tableView.dataSource = self

    errorButton.addTarget(self, action: #selector(onErrorButtonTouched), for: .touchUpInside)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.startFetch()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    setConstraints()
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

  func showAlert(error: ApiError) {
    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
    let ok = UIAlertAction(title: "確認", style: .default, handler: nil)
    alert.addAction(ok)
    present(alert, animated: true, completion: nil)
  }

  @objc
  func onErrorButtonTouched() {
    viewModel.events.onFetchError?(.parseFail("Test parse failed"))
  }

}

extension MaskListViewController: UITableViewDelegate, UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.output.numberOfItems
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MaskListCell.self)) as? MaskListCell else { return UITableViewCell() }

    cell.viewModel = viewModel.output.cellViewModel(at: indexPath)

    return cell

  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 120
  }

}

