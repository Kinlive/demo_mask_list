//
//  AppCoordinator.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/6/11.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import UIKit
import RxSwift

class AppCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    private let rootViewController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        rootViewController = UINavigationController()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        
    }
    
    override func start() -> Observable<Void> {
        let maskListCoordinator = MaskListCoordinator(window: window, presenter: rootViewController)
        
        return coordinator(to: maskListCoordinator)
    }
}
