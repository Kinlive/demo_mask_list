//
//  MaskListCell.swift
//  DemoMaskList
//
//  Created by Kinlive on 2020/5/24.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import UIKit
import RxSwift

class MaskListCell: UITableViewCell {
  let disposeBag = DisposeBag()
    
  lazy var countyLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  lazy var maskLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  var viewModel: MaskListCellViewModel = MaskListCellViewModel(maskAdult: 0, county: "") {
    didSet {
      self.countyLabel.text = "縣市: \(viewModel.county)"
      self.maskLabel.text = "成人口罩庫存: \(viewModel.numberOfMaskAtAdult)片"
    }
  }
    
  let rx_viewModel = PublishSubject<MaskListCellViewModel>()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubview(countyLabel)
    addSubview(maskLabel)
    
    rx_viewModel
        .map { "縣市:" + $0.county }
        .bind(to: countyLabel.rx.text)
        .disposed(by: disposeBag)
    
    rx_viewModel
        .map { "成人口罩庫存: \($0.numberOfMaskAtAdult)" }
        .bind(to: maskLabel.rx.text)
        .disposed(by: disposeBag)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    setConstraints()
  }

  private func setConstraints() {
    // constraints of countyLabel
    countyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
    countyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
    countyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    countyLabel.bottomAnchor.constraint(equalTo: maskLabel.topAnchor, constant: 20).isActive = true

    // constraints of maskLabel
    maskLabel.leadingAnchor.constraint(equalTo: countyLabel.leadingAnchor).isActive = true
    maskLabel.trailingAnchor.constraint(equalTo: countyLabel.trailingAnchor).isActive = true
    maskLabel.heightAnchor.constraint(equalTo: countyLabel.heightAnchor).isActive = true
    maskLabel.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -10).isActive = true
  }

}
