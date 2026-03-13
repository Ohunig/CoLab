//
//  UpdateUserDataError.swift
//  CoLab
//
//  Created by User on 12.03.2026.
//

import Foundation

// Ошибка изменения данных пользователя
enum UpdateUserDataError: LocalizedError {
    private struct Constants {
        static let permissionDesc = "Нет доступа к изменению данных"
        static let networkDesc = "Проблемы с интернетом"
        static let unknownDesc = "Неизвестная ошибка"
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
