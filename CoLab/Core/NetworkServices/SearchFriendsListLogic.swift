//
//  SearchFriendsListLogic.swift
//  CoLab
//
//  Created by User on 05.05.2026.
//

import Foundation
import Combine

struct SearchFriendsPage {
    let users: [UserModel]
    let hasMore: Bool
}

protocol SearchFriendsListLogic: AnyObject {
    func fetchFirstPage(
        limit: Int,
        searchText: String?
    ) -> AnyPublisher<SearchFriendsPage, FetchUserError>
    
    func fetchNextPage(
        limit: Int,
        searchText: String?
    ) -> AnyPublisher<SearchFriendsPage, FetchUserError>
    
    func reset()
}
