//
//  UserSettingsAssembly.swift
//  CoLab
//
//  Created by User on 13.03.2026.
//

import UIKit
import Swinject

// Сборка экрана
enum UserSettingsAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build() -> UIViewController {
        let presenter = UserSettingsPresenter()
        
        guard let colorRepository = CompositionRoot.container.resolve(
            ColorStorageLogic.self
        ) else {
            // Специально сделано чтобы приложение падало с ошибкой так как без всех зарегестрированных зависимостей не может нормально работать
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let router = CompositionRoot.container.resolve(
            SettingsRoutingLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        // Получаем нужные сервисы
        guard let authService = CompositionRoot.container.resolve(
            AuthLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        guard let userService = CompositionRoot.container.resolve(
            UserServiceLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        guard let avatarService = CompositionRoot.container.resolve(
            AvatarServiceLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        let interactor = UserSettingsInteractor(
            presenter: presenter,
            router: router,
            colorRepository: colorRepository,
            authService: authService,
            userService: userService,
            avatarService: avatarService
        )
        
        let viewController = UserSettingsController(
            interactor: interactor
        )
        presenter.controller = viewController
        return viewController
    }
}
