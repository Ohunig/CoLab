//
//  SendChatMessageError.swift
//  CoLab
//
//  Created by OpenAI on 26.03.2026.
//

import Foundation

enum SendChatMessageError: LocalizedError {
    private struct Constants {
        static let permissionDesc = "Нет доступа к отправке сообщения"
        static let networkDesc = "Проблемы с интернетом"
        static let emptyTextDesc = "Пустое сообщение нельзя отправить"
        static let unknownDesc = "Не удалось отправить сообщение"
    }
    
    case permissionDenied
    case emptyText
    case network
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            Constants.permissionDesc
        case .emptyText:
            Constants.emptyTextDesc
        case .network:
            Constants.networkDesc
        case .unknown:
            Constants.unknownDesc
        }
    }
}
