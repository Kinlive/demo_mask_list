//
//  ApiServicePortocol.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/21.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation

protocol ApiServiceProtocol: class {
    associatedtype modelT
    
    func fetchData() -> modelT
}
