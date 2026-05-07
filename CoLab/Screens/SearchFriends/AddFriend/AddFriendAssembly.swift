//
//  AddFriendAssembly.swift
//  CoLab
//
//  Created by User on 06.05.2026.
//

import UIKit
import Swinject

enum AddFriendAssembly {
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build(userId: String) -> UIViewController {
        let presenter = AddFriendPresenter()
        
        guard let colorRepository = CompositionRoot.container.resolve(
            ColorStorageLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        guard let friendsService = CompositionRoot.container.resolve(
            FriendsServiceLogic.self
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
        
        let interactor = AddFriendInteractor(
            userId: userId,
            presenter: presenter,
            colorRepository: colorRepository,
            friendsService: friendsService,
            userService: userService,
            avatarService: avatarService
        )
        
        let viewController = AddFriendController(interactor: interactor)
        presenter.controller = viewController
        return viewController
    }
}
