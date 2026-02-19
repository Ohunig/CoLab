//
//  LogInError.swift
//  CoLab
//
//  Created by User on 18.02.2026.
//

import Foundation

// Ошибка входа в аккаунт
enum LogInError: LocalizedError {
    private struct Constants {
        static let invalidCredentialDesc = "Неверный email или пароль"
        static let invalidEmailDesc = "Некорректный email"
        static let networkDesc = "Проблемы с интернетом"
        static let unknownDesc = "Неизвестная ошибка"
    }
    
    case invalidCredential
    case invalidEmail
    case network
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            Constants.invalidCredentialDesc
        case .invalidEmail:
            Constants.invalidEmailDesc
        case .network:
            Constants.networkDesc
        case .unknown:
            Constants.unknownDesc
        }
    }
}
