//
//  ChatsRoutingLogic.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import Foundation
import UIKit

// Логика навигации внутри ветки чатов
protocol ChatsRoutingLogic: AnyObject {
    
    var navigationController: UINavigationController? { get set }
    
    func routeToChatMessages(
        chatId: String,
        chatTitle: String,
        chatDescription: String?,
        chatAvatarURL: String?,
        memberIds: [String]
    )
    
    func routeToChatInfo(
        chatTitle: String,
        chatDescription: String?,
        chatAvatarURL: String?,
        memberIds: [String]
    )
}
