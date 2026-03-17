//
//  ChangeSettingsModels.swift
//  CoLab
//
//  Created by User on 16.03.2026.
//

import Foundation

// Модели для передачи данных между слоями экрана
struct ChangeSettingsModels {
    
    // Модели для старта экрана
    enum Start {
        struct Response {
            let bg: ColorModel
            let bgGradient: ColorModel
            let firstGradient: ColorModel
            let secondGradient: ColorModel
            let elementsBase: ColorModel
            let tint: ColorModel
            let textColor: ColorModel
        }
        struct ViewModel {
            let bg: (hex: String, a: CGFloat)
            let bgGradient: (hex: String, a: CGFloat)
            let firstGradient: (hex: String, a: CGFloat)
            let secondGradient: (hex: String, a: CGFloat)
            let elementsBase: (hex: String, a: CGFloat)
            let tint: (hex: String, a: CGFloat)
            let textColor: (hex: String, a: CGFloat)
        }
    }
    
    // Модели для обновления данных о юзере
    enum GetUserData {
        struct Response {
            // nil -> аватар не менялся либо реально не пришёл
            let avatarData: Data?
            let userData: UserModel
        }
        struct ViewModel {
            let avatarData: Data?
            let username: String
        }
    }
    
    enum UpdateUserData {
        struct Request {
            let username: String
            let avatarData: Data?
        }
    }
    
    enum CatchError {
        struct Response {
            let error: Error
        }
        struct ViewModel {
            let errorTitle: String
            let errorDescription: String
        }
    }
    
    // Модели для валидации
    enum Validation {
        struct Request {
            let username: String
        }
        struct Response {
            let isValid: Bool
        }
        struct ViewModel {
            let isValid: Bool
        }
    }
}
