//
//  ChangeSettingsAssembly.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import UIKit
import Swinject

// Сборка экрана
enum ChangeSettingsAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build() -> UIViewController {
        let presenter = ChangeSettingsPresenter()
        
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
        
        let interactor = ChangeSettingsInteractor(
            presenter: presenter,
            router: router,
            colorRepository: colorRepository,
            userService: userService,
            avatarService: avatarService
        )
        
        let viewController = ChangeSettingsController(
            interactor: interactor
        )
        presenter.controller = viewController
        return viewController
    }
}
