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
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        
        let viewModel = MaskListViewModel()
        
        guard let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: MaskListViewController.self)) as? MaskListViewController else { return .error(NSError(domain: "Initializer MaskListViewController fail", code: 1, userInfo: nil)) }
        let navigationController = UINavigationController(rootViewController: viewController)
        
        viewController.viewModel = viewModel
        
        
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        return Observable.never()
    }
}
