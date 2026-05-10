//
//  SelectChatMemberAssembly.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import UIKit
import Swinject

enum SelectChatMemberAssembly {
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build(
        excludedUserIds: [String],
        router: UserInfoRoutingLogic,
        onSelectUser: @escaping (UserModel) -> Void
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
        
        let interactor = SelectChatMemberInteractor(
            excludedUserIds: excludedUserIds,
            presenter: presenter,
            colorRepository: colorRepository,
            userService: userService,
            avatarService: avatarService,
            router: router,
            onSelectUser: onSelectUser
        )
        
        let controller = AddChatMemberController(
            interactor: interactor,
            tableDataProvider: presenter
        )
        presenter.controller = controller
        return controller
    }
}
