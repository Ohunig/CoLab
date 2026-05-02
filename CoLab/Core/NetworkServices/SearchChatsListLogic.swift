//
//  SearchChatsListLogic.swift
//  CoLab
//
//  Created by User on 24.04.2026.
//

import Foundation
import Combine

struct SearchChatsPage {
    let chats: [ChatModel]
    let hasMore: Bool
}

protocol SearchChatsListLogic: AnyObject {
    func fetchFirstPage(
        limit: Int,
        searchText: String?
    ) -> AnyPublisher<SearchChatsPage, FetchUserChatsError>
    
    func fetchNextPage(
        limit: Int,
        searchText: String?
    ) -> AnyPublisher<SearchChatsPage, FetchUserChatsError>
    
    func reset()
}
