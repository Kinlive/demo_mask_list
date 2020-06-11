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
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let maskListCoordinator = MaskListCoordinator(window: window)
        
        return coordinator(to: maskListCoordinator)
    }
}
