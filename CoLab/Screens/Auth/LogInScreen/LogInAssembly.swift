//
//  LogInAssembly.swift
//  CoLab
//
//  Created by User on 09.02.2026.
//

import Foundation
import UIKit
import Swinject

// Сборщик экрана
enum LogInAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build() -> UIViewController {
        let presenter = LogInPresenter()
        
        // Подтягиваем нужные зависимости
        
        guard let colorRepository = CompositionRoot.container.resolve(
            ColorStorageLogic.self
        ) else {
            // Специально сделано чтобы приложение падало с ошибкой так как без всех зарегестрированных зависимостей не может нормально работать
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let authService = CompositionRoot.container.resolve(
            AuthLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let router = CompositionRoot.container.resolve(
            AuthRoutingLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        let interactor = LogInInteractor(
            presenter: presenter,
            colorRepository: colorRepository,
            authService: authService,
            router: router
        )
        let viewController = LogInViewController(
            interactor: interactor
        )
        presenter.controller = viewController
        return viewController
    }
}
