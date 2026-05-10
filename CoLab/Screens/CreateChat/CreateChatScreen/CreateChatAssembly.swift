//
//  CreateChatAssembly.swift
//  CoLab
//
//  Created by User on 09.05.2026.
//

import UIKit
import Swinject

// Сборка экрана создания чата
enum CreateChatAssembly {
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build() -> UIViewController {
        let presenter = CreateChatPresenter()
        
        guard let router = CompositionRoot.container.resolve(
            CreateChatRoutingLogic.self
        ) else {
            // Специально сделано чтобы приложение падало с ошибкой так как без всех зарегестрированных зависимостей не может нормально работать
            fatalError(Constants.notAllServicesRegistered)
        }
        
        // Получаем нужные сервисы
        guard let colorRepository = CompositionRoot.container.resolve(
            ColorStorageLogic.self
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
        
        guard let chatService = CompositionRoot.container.resolve(
            ChatLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        let interactor = CreateChatInteractor(
            presenter: presenter,
            router: router,
            colorRepository: colorRepository,
            userService: userService,
            avatarService: avatarService,
            chatService: chatService
        )
        
        let controller = CreateChatController(
            interactor: interactor,
            tableDataProvider: presenter
        )
        presenter.controller = controller
        return controller
    }
}
