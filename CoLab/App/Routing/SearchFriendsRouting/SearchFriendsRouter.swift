//
//  SearchFriendsRouter.swift
//  CoLab
//
//  Created by User on 06.05.2026.
//

import UIKit

final class SearchFriendsRouter: SearchFriendsRoutingLogic {
    private weak var navController: UINavigationController?
    
    var navigationController: UINavigationController? {
        get { navController }
        set { navController = newValue }
    }
    
    func routeToAddFriend(userId: String) {
        navigationController?.pushViewController(
            AddFriendAssembly.build(userId: userId),
            animated: true
        )
    }
}
