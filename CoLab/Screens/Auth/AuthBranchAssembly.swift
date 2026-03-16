//
//  AuthBranchAssembly.swift
//  CoLab
//
//  Created by User on 16.03.2026.
//

import UIKit
import Swinject

// Сборка ветки аутентификации
enum AuthBranchAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build(on navController: UINavigationController) {
        // Настраиваем корневой контроллер у роутера
        guard let router = CompositionRoot.container.resolve(
            AuthRoutingLogic.self
        ) else {
            // Специально сделано чтобы приложение падало с ошибкой так как без всех зарегестрированных зависимостей не может нормально работать
            fatalError(Constants.notAllServicesRegistered)
        }
        router.navigationController = navController
    }
}
