//
//  CreateChatRoutingLogic.swift
//  CoLab
//
//  Created by User on 09.05.2026.
//

import Foundation

// Логика навигации внутри ветки создания чата
protocol CreateChatRoutingLogic: UserInfoRoutingLogic {
    // Переход к выбору участника из списка друзей
    func routeToSelectChatMember(
        excludedUserIds: [String],
        onSelectUser: @escaping (UserModel) -> Void
    )
    
    // Закрытие ветки после создания чата
    func routeAfterChatCreated()
}
