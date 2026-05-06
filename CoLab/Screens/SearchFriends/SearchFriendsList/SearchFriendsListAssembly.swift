//
//  SearchFriendsListAssembly.swift
//  CoLab
//
//  Created by User on 05.05.2026.
//

import UIKit
import Swinject

enum SearchFriendsListAssembly {
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build() -> UIViewController {
        let presenter = SearchFriendsListPresenter()
        
        guard let colorRepository = CompositionRoot.container.resolve(
            ColorStorageLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let friendsListService = CompositionRoot.container.resolve(
            SearchFriendsListLogic.self
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
        
        let interactor = SearchFriendsListInteractor(
            presenter: presenter,
            colorRepository: colorRepository,
            friendsListService: friendsListService,
            userService: userService,
            avatarService: avatarService
        )
        
        let viewController = SearchFriendsListController(
            interactor: interactor,
            tableDataProvider: presenter
        )
        presenter.controller = viewController
        return viewController
    }
}
