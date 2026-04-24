//
//  ChatsBranchAssembly.swift
//  CoLab
//
//  Created by User on 23.03.2026.
//

import Foundation
import UIKit
import Swinject

// Сборка ветки чатов
enum ChatsBranchAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build() -> UINavigationController {
        let navController = UINavigationController(
            rootViewController: UserChatsAssembly.build()
        )
        
        navController.navigationBar.isHidden = true
        
        // Настраиваем корневой контроллер у роутера
        guard let router = CompositionRoot.container.resolve(
            ChatsRoutingLogic.self
        ) else {
            // Специально сделано чтобы приложение падало с ошибкой так как без всех зарегестрированных зависимостей не может нормально работать
            fatalError(Constants.notAllServicesRegistered)
        }
        router.navigationController = navController
        
        return navController
    }
}
