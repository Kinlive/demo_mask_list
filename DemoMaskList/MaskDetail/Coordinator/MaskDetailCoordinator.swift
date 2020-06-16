//
//  MaskDetailCoordinator.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/6/15.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import UIKit
import RxSwift

class MaskDetailCoordinator: BaseCoordinator<String> {
    
  private let presenter: UINavigationController
  private let maskDetailViewController: MaskDetailViewController
    
  init(presenter: UINavigationController) {
    self.presenter = presenter
    maskDetailViewController = MaskDetailViewController()
  }
    
//    override func start() -> Observable<String> {
//        presenter.pushViewController(maskDetailViewController, animated: true)
//
//        return Observable.from()
//    }
}
