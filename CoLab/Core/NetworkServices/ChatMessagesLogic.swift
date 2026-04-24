//
//  ChatMessagesLogic.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import Foundation
import Combine

protocol ChatMessagesLogic: AnyObject {
    
    func chatLastMessageDatePublisher() -> AnyPublisher<Result<Date?, FetchChatMessagesError>, Never>
    
    // Следит за изменениями чата
    func startListeningChat(chatId: String)
    
    func stopListeningChat()
    
    func fetchLatestMessages(
        chatId: String,
        limit: Int
    ) -> AnyPublisher<[ChatMessageModel], FetchChatMessagesError>
    
    func fetchMessages(
        before message: ChatMessageModel,
        chatId: String,
        limit: Int
    ) -> AnyPublisher<[ChatMessageModel], FetchChatMessagesError>
    
    func fetchMessages(
        after message: ChatMessageModel,
        chatId: String
    ) -> AnyPublisher<[ChatMessageModel], FetchChatMessagesError>
    
    func sendMessage(
        text: String,
        chatId: String
    ) -> AnyPublisher<ChatMessageModel, SendChatMessageError>
}
