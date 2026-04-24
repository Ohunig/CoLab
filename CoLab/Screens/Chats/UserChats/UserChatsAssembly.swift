//
//  UserChatsAssembly.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import UIKit
import Swinject

enum UserChatsAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build() -> UIViewController {
        let presenter = UserChatsPresenter()
        
        guard let colorRepository = CompositionRoot.container.resolve(
            ColorStorageLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let chatListService = CompositionRoot.container.resolve(
            UserChatListLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let avatarService = CompositionRoot.container.resolve(
            AvatarServiceLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let router = CompositionRoot.container.resolve(
            ChatsRoutingLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let userService = CompositionRoot.container.resolve(
            UserServiceLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        let interactor = UserChatsInteractor(
            presenter: presenter,
            colorRepository: colorRepository,
            chatListService: chatListService,
            router: router,
            userService: userService,
            avatarService: avatarService
        )
        
        let viewController = UserChatsController(
            interactor: interactor,
            tableDataProvider: presenter
        )
        presenter.controller = viewController
        return viewController
    }
}
