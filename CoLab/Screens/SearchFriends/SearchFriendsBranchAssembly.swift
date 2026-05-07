//
//  SearchFriendsBranchAssembly.swift
//  CoLab
//
//  Created by User on 05.05.2026.
//

import UIKit
import Swinject

enum SearchFriendsBranchAssembly {
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build() -> UINavigationController {
        let navController = UINavigationController(
            rootViewController: SearchFriendsListAssembly.build()
        )
        
        navController.navigationBar.isHidden = true
        
        guard let router = CompositionRoot.container.resolve(
            SearchFriendsRoutingLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        router.navigationController = navController
        
        return navController
    }
}
