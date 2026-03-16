//
//  AuthRoutingLogic.swift
//  CoLab
//
//  Created by User on 14.02.2026.
//

import Foundation
import UIKit

// Логика навигации между экранами авторизации
protocol AuthRoutingLogic: AnyObject {
    
    var navigationController: UINavigationController? { get set }
    
    func routeToLogInScreen()
    
    func routeToAuthMainScreen()
    
    func routeToAuthBranch()
    
    func routeToSignUpScreen()
    
    func routeToMainScreens()
}
