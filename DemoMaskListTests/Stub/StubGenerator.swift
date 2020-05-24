//
//  StubGenerator.swift
//  DemoMaskListTests
//
//  Created by Kinlive on 2020/5/24.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation

@testable import DemoMaskList
class StubGenerator {
  func stubOfMaskList() -> MaskList {
    let filePath = Bundle.main.path(forResource: "content", ofType: "json")!
    let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))

    let model = try! JSONDecoder().decode(MaskList.self, from: data)

    return model
  }
}

