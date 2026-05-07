//
//  FriendsServiceLogic.swift
//  CoLab
//
//  Created by User on 06.05.2026.
//

import Foundation
import Combine

protocol FriendsServiceLogic: AnyObject {
    func addFriend(userId: String) -> AnyPublisher<Void, FetchUserError>
    
    func removeFriend(userId: String) -> AnyPublisher<Void, FetchUserError>
}
