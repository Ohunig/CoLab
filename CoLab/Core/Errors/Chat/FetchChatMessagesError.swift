//
//  FetchChatMessagesError.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import Foundation

enum FetchChatMessagesError: LocalizedError {
    private struct Constants {
        static let permissionDesc = "Нет доступа к сообщениям"
        static let networkDesc = "Проблемы с интернетом"
        static let unknownDesc = "Не удалось загрузить сообщения"
    }
    
    case permissionDenied
    case network
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            Constants.permissionDesc
        case .network:
            Constants.networkDesc
        case .unknown:
            Constants.unknownDesc
        }
    }
}
