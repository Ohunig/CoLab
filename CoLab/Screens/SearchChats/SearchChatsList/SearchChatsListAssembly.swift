//
//  SearchChatsListAssembly.swift
//  CoLab
//
//  Created by User on 24.04.2026.
//

import UIKit
import Swinject

// Сборка экрана поиска чатов
enum SearchChatsListAssembly {
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build() -> UIViewController {
        let presenter = SearchChatsListPresenter()
        
        // Подтягиваем все зависимости
        
        guard let colorRepository = CompositionRoot.container.resolve(
            ColorStorageLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let chatListService = CompositionRoot.container.resolve(
            SearchChatsListLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let avatarService = CompositionRoot.container.resolve(
            AvatarServiceLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let router = CompositionRoot.container.resolve(
            SearchChatsRoutingLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let userService = CompositionRoot.container.resolve(
            UserServiceLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        let interactor = SearchChatsListInteractor(
            presenter: presenter,
            colorRepository: colorRepository,
            chatListService: chatListService,
            router: router,
            userService: userService,
            avatarService: avatarService
        )
        
        let viewController = SearchChatsListController(
            interactor: interactor,
            tableDataProvider: presenter
        )
        presenter.controller = viewController
        return viewController
    }
}
