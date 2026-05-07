//
//  SearchFriendsRoutingLogic.swift
//  CoLab
//
//  Created by User on 06.05.2026.
//

import UIKit

protocol SearchFriendsRoutingLogic: AnyObject {
    var navigationController: UINavigationController? { get set }
    
    func routeToAddFriend(userId: String)
}
