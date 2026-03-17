//
//  FetchUserDataError.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation

enum FetchUserError: LocalizedError {
    private struct Constants {
        static let permissionDesc = "Нет доступа к изменению данных"
        static let networkDesc = "Проблемы с интернетом"
        static let decodingDesc = "Не удалось декодировать"
        static let unknownDesc = "Неизвестная ошибка"
    }
    
    case permissionDenied
    case network
    case decoding
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            Constants.permissionDesc
        case .network:
            Constants.networkDesc
        case .decoding:
            Constants.decodingDesc
        case .unknown:
            Constants.unknownDesc
        }
    }
}
