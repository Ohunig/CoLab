//
//  AddChatAssembly.swift
//  CoLab
//
//  Created by User on 01.05.2026.
//

import UIKit
import Swinject

// Сборка экрана добавления чата
enum AddChatAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build(
        chatId: String
    ) -> UIViewController {
        let presenter = AddChatPresenter()
        
        // Получаем нужные сервисы. Без них экран не сможет работать корректно
        guard let colorRepository = CompositionRoot.container.resolve(
            ColorStorageLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let addChatService = CompositionRoot.container.resolve(
            AddChatLogic.self
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
        
        let interactor = AddChatInteractor(
            chatId: chatId,
            presenter: presenter,
            colorRepository: colorRepository,
            addChatService: addChatService,
            userService: userService,
            avatarService: avatarService
        )
        
        let controller = AddChatController(
            interactor: interactor,
            tableDataProvider: presenter
        )
        presenter.controller = controller
        
        return controller
    }
}
