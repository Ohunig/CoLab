//
//  SearchFriendsBranchAssembly.swift
//  CoLab
//
//  Created by User on 05.05.2026.
//

import UIKit

enum SearchFriendsBranchAssembly {
    static func build() -> UINavigationController {
        let navController = UINavigationController(
            rootViewController: SearchFriendsListAssembly.build()
        )
        
        navController.navigationBar.isHidden = true
        return navController
    }
}
