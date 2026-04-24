//
//  ChatInfoAssembly.swift
//  CoLab
//
//  Created by User on 14.04.2026.
//

import UIKit
import Swinject

// Сборка экрана информации о чате
enum ChatInfoAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build(
        chatTitle: String,
        chatAvatarURL: String?,
        memberIds: [String]
    ) -> UIViewController {
        let presenter = ChatInfoPresenter()
        
        // Получаем нужные сервисы. Без них экран не сможет работать корректно
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
        
        let interactor = ChatInfoInteractor(
            chatTitle: chatTitle,
            chatAvatarURL: chatAvatarURL,
            memberIds: memberIds,
            presenter: presenter,
            colorRepository: colorRepository,
            userService: userService,
            avatarService: avatarService
        )
        
        let controller = ChatInfoController(
            interactor: interactor,
            tableDataProvider: presenter
        )
        presenter.controller = controller
        
        return controller
    }
}
