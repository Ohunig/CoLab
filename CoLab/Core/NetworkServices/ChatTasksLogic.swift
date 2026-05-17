//
//  ChatTasksLogic.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import Foundation
import Combine

// Сервис для работы с задачами конкретного чата
protocol ChatTasksLogic: AnyObject {
    func taskUpdatesPublisher() -> AnyPublisher<Result<[ChatTaskModel], ChatTasksError>, Never>
    
    func activeTaskVoteUpdatesPublisher() -> AnyPublisher<Result<Set<String>, ChatTasksError>, Never>
    
    func startListeningTasks(chatId: String)
    
    func startListeningActiveTaskVotes(
        chatId: String,
        memberCount: Int
    )
    
    func stopListeningTasks()
    
    func stopListeningActiveTaskVotes()
    
    func createTask(
        text: String,
        chatId: String
    ) -> AnyPublisher<Void, ChatTasksError>
    
    func sendTaskVoteMessage(
        task: ChatTaskModel,
        chatId: String
    ) -> AnyPublisher<Void, ChatTasksError>
}
