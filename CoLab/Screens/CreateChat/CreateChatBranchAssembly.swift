//
//  CreateChatBranchAssembly.swift
//  CoLab
//
//  Created by User on 09.05.2026.
//

import UIKit
import Swinject

// Сборка отдельной ветки создания чата
enum CreateChatBranchAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
        static let modalTopSafeAreaCompensation: CGFloat = 30
    }
    
    static func build() -> UINavigationController {
        let rootController = CreateChatAssembly.build()
        applyModalCompensation(to: rootController)
        
        let navController = UINavigationController(
            rootViewController: rootController
        )
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .coverVertical
        
        guard let router = CompositionRoot.container.resolve(
            CreateChatRoutingLogic.self
        ) else {
            // Специально сделано чтобы приложение падало с ошибкой так как без всех зарегестрированных зависимостей не может нормально работать
            fatalError(Constants.notAllServicesRegistered)
        }
        router.navigationController = navController
        
        return navController
    }
    
    private static func applyModalCompensation(to viewController: UIViewController) {
        (viewController as? ModalTopSafeAreaCompensating)?
            .setModalTopSafeAreaCompensation(
                Constants.modalTopSafeAreaCompensation
            )
    }
}
