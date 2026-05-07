//
//  AddChatMemberAssembly.swift
//  CoLab
//
//  Created by User on 07.05.2026.
//

import UIKit
import Swinject

enum AddChatMemberAssembly {
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build(
        chatId: String,
        memberIds: [String]
    ) -> UIViewController {
        let presenter = AddChatMemberPresenter()
        
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
        
        guard let router = CompositionRoot.container.resolve(
            ChatsRoutingLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        let interactor = AddChatMemberInteractor(
            chatId: chatId,
            memberIds: memberIds,
            presenter: presenter,
            colorRepository: colorRepository,
            userService: userService,
            avatarService: avatarService,
            chatService: chatService,
            router: router
        )
        
        let controller = AddChatMemberController(
            interactor: interactor,
            tableDataProvider: presenter
        )
        presenter.controller = controller
        return controller
    }
}
