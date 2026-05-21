//
//  ChatsRoutingLogic.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import Foundation

// Логика навигации внутри ветки чатов
protocol ChatsRoutingLogic: UserInfoRoutingLogic {
    func routeToChatMessages(
        chatId: String,
        chatTitle: String,
        chatDescription: String?,
        chatAvatarURL: String?,
        memberIds: [String]
    )
    
    func routeToChatInfo(
        chatId: String,
        chatTitle: String,
        chatDescription: String?,
        chatAvatarURL: String?,
        memberIds: [String]
    )
    
    func routeToAddChatMember(
        chatId: String,
        memberIds: [String]
    )
    
    func routeToChatTasks(
        chatId: String,
        memberIds: [String]
    )
    
    func routeToUserChats()
}
