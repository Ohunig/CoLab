//
//  ChatsServiceLogic.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation
import Combine

// Сервис для работы с чатами текущего пользователя
protocol UserChatListLogic: AnyObject {

    // Непрерывные обновления по чатам
    func userChatsUpdatesPublisher() -> AnyPublisher<Result<[ChatModel], FetchUserChatsError>, Never>
    
    // Устанавливает окно живых обновлений: сервис будет слушать топ-N чатов, отсортированных по времени последнего сообщения.
    func setLiveUpdatesLimit(_ limit: Int)
}
