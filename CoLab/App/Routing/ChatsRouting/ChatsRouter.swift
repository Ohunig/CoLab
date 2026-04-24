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
        chatAvatarURL: String?,
        memberIds: [String]
    ) {
        navigationController?.pushViewController(
            ChatMessagesAssembly.build(
                chatId: chatId,
                chatTitle: chatTitle,
                chatAvatarURL: chatAvatarURL,
                memberIds: memberIds
            ),
            animated: true
        )
    }
    
    func routeToChatInfo(
        chatTitle: String,
        chatAvatarURL: String?,
        memberIds: [String]
    ) {
        navigationController?.pushViewController(
            ChatInfoAssembly.build(
                chatTitle: chatTitle,
                chatAvatarURL: chatAvatarURL,
                memberIds: memberIds
            ),
            animated: true
        )
    }
}
