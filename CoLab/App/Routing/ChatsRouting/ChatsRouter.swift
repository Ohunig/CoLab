//
//  ChatsRouter.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import Foundation
import UIKit

// Навигация внутри ветки чатов
final class ChatsRouter: ChatsRoutingLogic {
    
    private weak var navController: UINavigationController?
    
    var navigationController: UINavigationController? {
        get { navController }
        set { navController = newValue }
    }
    
    func routeToChatMessages(
        chatId: String,
        chatTitle: String,
        chatDescription: String?,
        chatAvatarURL: String?,
        memberIds: [String]
    ) {
        navigationController?.pushViewController(
            ChatMessagesAssembly.build(
                chatId: chatId,
                chatTitle: chatTitle,
                chatDescription: chatDescription,
                chatAvatarURL: chatAvatarURL,
                memberIds: memberIds
            ),
            animated: true
        )
    }
    
    func routeToChatInfo(
        chatId: String,
        chatTitle: String,
        chatDescription: String?,
        chatAvatarURL: String?,
        memberIds: [String]
    ) {
        navigationController?.pushViewController(
            ChatInfoAssembly.build(
                chatId: chatId,
                chatTitle: chatTitle,
                chatDescription: chatDescription,
                chatAvatarURL: chatAvatarURL,
                memberIds: memberIds
            ),
            animated: true
        )
    }
    
    func routeToAddChatMember(
        chatId: String,
        memberIds: [String]
    ) {
        navigationController?.pushViewController(
            AddChatMemberAssembly.build(
                chatId: chatId,
                memberIds: memberIds
            ),
            animated: true
        )
    }
    
    func routeToUserChats() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func routeBack() {
        navigationController?.popViewController(animated: true)
    }
}
