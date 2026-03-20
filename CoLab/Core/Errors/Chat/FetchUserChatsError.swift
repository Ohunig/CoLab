//
//  FetchUserChatsError.swift
//  CoLab
//
//  Created by User on 19.03.2026.
//

import Foundation

enum FetchUserChatsError: LocalizedError {
    private struct Constants {
        static let permissionDesc = "Нет доступа к чатам"
        static let networkDesc = "Проблемы с интернетом"
        static let unknownDesc = "Не удалось загрузить чаты"
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
