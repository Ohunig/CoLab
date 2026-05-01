//
//  AddChatLogic.swift
//  CoLab
//
//  Created by User on 02.05.2026.
//

import Foundation
import Combine

// Сервис для работы с конкретным чатом из ветки поиска
protocol AddChatLogic: AnyObject {
    func chatUpdatesPublisher(
        chatId: String
    ) -> AnyPublisher<Result<ChatModel, FetchUserChatsError>, Never>
    
    func addCurrentUser(toChat chatId: String) -> AnyPublisher<Void, FetchUserChatsError>
}
