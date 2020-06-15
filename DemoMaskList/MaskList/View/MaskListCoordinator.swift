//
//  MaskListCoordinator.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/6/11.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import UIKit
import RxSwift



class MaskListCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    
    private let maskListViewController: MaskListViewController
    private let presenter: UINavigationController
    private let viewModel: MaskListViewModel
    
    init(window: UIWindow, presenter: UINavigationController) {
        self.window = window
        self.presenter = presenter
        
        viewModel = MaskListViewModel()
        
        maskListViewController = MaskListViewController(viewModel: viewModel)
        
    }
    
    override func start() -> Observable<Void> {
        presenter.pushViewController(maskListViewController, animated: true)
        
        return Observable.never()
    }
}
