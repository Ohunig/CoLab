//
//  SettingsBranchAssembly.swift
//  CoLab
//
//  Created by User on 13.03.2026.
//

import Foundation
import UIKit
import Swinject

// Сборка ветки настроек
enum SettingsBranchAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build() -> UINavigationController {
        let navController = UINavigationController(
            rootViewController: UserSettingsAssembly.build()
        )
        
        // Настраиваем корневой контроллер у роутера
        guard let router = CompositionRoot.container.resolve(
            SettingsRoutingLogic.self
        ) else {
            // Специально сделано чтобы приложение падало с ошибкой так как без всех зарегестрированных зависимостей не может нормально работать
            fatalError(Constants.notAllServicesRegistered)
        }
        router.navigationController = navController
        
        return navController
    }
}
