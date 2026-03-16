//
//  SettingsRouter.swift
//  CoLab
//
//  Created by User on 13.03.2026.
//

import Foundation
import UIKit

// Навигация между экранами настроек
final class SettingsRouter: SettingsRoutingLogic {
    
    private weak var navController: UINavigationController?
    
    // Так как нужен переход на AuthMainScreen
    private let authRouter: AuthRoutingLogic
    
    // MARK: Lifecycle
    
    init(authRouter: AuthRoutingLogic) {
        self.authRouter = authRouter
    }
    
    // MARK: Computed properties
    
    var navigationController: UINavigationController? {
        get { navController }
        set { navController = newValue }
    }
    
    // MARK: Routing
    
    func routeToAuth() {
        authRouter.routeToAuthBranch()
    }
}
