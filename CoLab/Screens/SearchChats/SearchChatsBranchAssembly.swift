//
//  SearchChatsBranchAssembly.swift
//  CoLab
//
//  Created by User on 24.04.2026.
//

import UIKit
import Swinject

// Сборка ветки поиска чатов
enum SearchChatsBranchAssembly {
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build() -> UINavigationController {
        let navController = UINavigationController(
            rootViewController: SearchChatsListAssembly.build()
        )
        
        navController.navigationBar.isHidden = true
        
        // Настраиваем корневой контроллер у роутера
        guard let router = CompositionRoot.container.resolve(
            SearchChatsRoutingLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        router.navigationController = navController
        
        return navController
    }
}
