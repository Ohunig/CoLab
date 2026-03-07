//
//  AuthRouter.swift
//  CoLab
//
//  Created by User on 14.02.2026.
//

import Foundation
import UIKit

// Навигация между экранами аутентификации
final class AuthRouter: AuthRoutingLogic {
    
    private weak var navController: UINavigationController?
    
    var navigationController: UINavigationController? {
        get {
            navController
        }
        set {
            navController = newValue
        }
    }
    
    func routeToAuthMainScreen() {
        navController?.popToRootViewController(animated: true)
    }
    
    func routeToLogInScreen() {
        navController?.pushViewController(LogInAssembly.build(), animated: true)
    }
    
    func routeToSignUpScreen() {
        navController?.pushViewController(RegisterAssembly.build(), animated: true)
    }
    
    // Вход в приложение
    func routeToMainScreens() {
        navController?.setViewControllers([TabBarScreenAssembly.build()], animated: true)
    }
}
