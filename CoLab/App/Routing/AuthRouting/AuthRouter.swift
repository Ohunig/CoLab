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
    
    private func dismissKeyboard() {
        navController?.view.endEditing(true)
    }
    
    var navigationController: UINavigationController? {
        get { navController }
        set { navController = newValue }
    }
    
    func routeToAuthMainScreen() {
        dismissKeyboard()
        navController?.popToRootViewController(animated: true)
    }
    
    func routeToAuthBranch() {
        dismissKeyboard()
        navController?.setViewControllers(
            [AuthMainScreenAssembly.build()],
            animated: true
        )
    }
    
    func routeToLogInScreen() {
        navController?.pushViewController(LogInAssembly.build(), animated: true)
    }
    
    func routeToSignUpScreen() {
        navController?.pushViewController(RegisterAssembly.build(), animated: true)
    }
    
    // Вход в приложение
    func routeToMainScreens() {
        dismissKeyboard()
        navController?.setViewControllers([TabBarScreenAssembly.build()], animated: true)
    }
}
