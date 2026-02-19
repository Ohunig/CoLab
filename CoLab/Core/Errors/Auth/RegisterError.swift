//
//  RegisterError.swift
//  CoLab
//
//  Created by User on 19.02.2026.
//

import Foundation

// Ошибка регистрации
enum RegisterError: LocalizedError {
    private struct Constants {
        static let emailAlreadyInUseDesc = "Аккаунт с такой почтой уже существует"
        static let invalidEmailDesc = "Некорректный email"
        static let networkError = "Проблемы с интернетом"
        static let unknown = "Неизвестная ошибка"
    }
    
    case emailAlreadyInUse
    case invalidEmail
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse:
            Constants.emailAlreadyInUseDesc
        case .invalidEmail:
            Constants.invalidEmailDesc
        case .networkError:
            Constants.networkError
        case .unknown:
            Constants.unknown
        }
    }
}
