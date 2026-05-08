//
//  UserInfoAssembly.swift
//  CoLab
//
//  Created by User on 08.05.2026.
//

import UIKit
import Swinject

enum UserInfoAssembly {
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build(
        userId: String,
        router: UserInfoRoutingLogic
    ) -> UIViewController {
        let presenter = UserInfoPresenter()
        
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
        
        let interactor = UserInfoInteractor(
            userId: userId,
            presenter: presenter,
            colorRepository: colorRepository,
            userService: userService,
            avatarService: avatarService,
            router: router
        )
        
        let viewController = UserInfoController(interactor: interactor)
        presenter.controller = viewController
        return viewController
    }
}
