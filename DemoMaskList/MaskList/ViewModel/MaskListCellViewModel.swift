//
//  MaskListCellViewModel.swift
//  DemoMaskList
//
//  Created by Kinlive on 2020/5/24.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation

class MaskListCellViewModel {

  let numberOfMaskAtAdult: Int
  let county: String

  init(maskAdult: Int, county: String) {
    numberOfMaskAtAdult = maskAdult
    self.county = county
  }

}
