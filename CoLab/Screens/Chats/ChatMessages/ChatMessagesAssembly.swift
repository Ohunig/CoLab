//
//  ChatMessagesAssembly.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import UIKit
import Swinject

// Сборка экрана сообщений
enum ChatMessagesAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    // MARK: Build
    
    static func build(
        chatId: String,
        chatTitle: String,
        chatDescription: String?,
        chatAvatarURL: String?,
        memberIds: [String]
    ) -> UIViewController {
        let presenter = ChatMessagesPresenter()
        
        // Получаем все нужные сервисы. Без них экран не сможет работать корректно
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
        
        guard let messagesService = CompositionRoot.container.resolve(
            ChatMessagesLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let router = CompositionRoot.container.resolve(
            ChatsRoutingLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        let interactor = ChatMessagesInteractor(
            chatId: chatId,
            chatTitle: chatTitle,
            chatDescription: chatDescription,
            chatAvatarURL: chatAvatarURL,
            memberIds: memberIds,
            presenter: presenter,
            router: router,
            colorRepository: colorRepository,
            userService: userService,
            avatarService: avatarService,
            messagesService: messagesService
        )
        
        let controller = ChatMessagesController(
            chatTitle: chatTitle,
            interactor: interactor,
            collectionDataProvider: presenter
        )
        // Presenter хранит уже подготовленные item'ы для collectionView
        presenter.controller = controller
        
        return controller
    }
}
