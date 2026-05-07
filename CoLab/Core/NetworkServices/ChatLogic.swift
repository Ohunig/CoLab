//
//  ChatLogic.swift
//  CoLab
//
//  Created by User on 02.05.2026.
//

import Foundation
import Combine

// Сервис для работы с конкретным чатом
protocol ChatLogic: AnyObject {
    func chatUpdatesPublisher(
        chatId: String
    ) -> AnyPublisher<Result<ChatModel, FetchUserChatsError>, Never>
    
    func addCurrentUser(toChat chatId: String) -> AnyPublisher<Void, FetchUserChatsError>
    
    func addUser(_ userId: String, toChat chatId: String) -> AnyPublisher<Void, FetchUserChatsError>
    
    func removeCurrentUser(fromChat chatId: String) -> AnyPublisher<Void, FetchUserChatsError>
}
