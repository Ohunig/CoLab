//
//  AvatarUploadError.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation

enum AvatarUploadError: LocalizedError {
    private struct Constants {
        static let permissionDesc = "Нет доступа к загрузке аватара"
        static let networkDesc = "Проблемы с интернетом"
        static let unknownDesc = "Не удалось загрузить аватар"
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

