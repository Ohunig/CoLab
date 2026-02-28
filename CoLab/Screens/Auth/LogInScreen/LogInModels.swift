//
//  LogInModels.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation

// Модели для передачи данных между слоями экрана
struct LogInModels {
    
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
    
    // Модели для валидации
    enum Validation {
        struct Request {
            let email: String
            let password: String
        }
        struct Response {
            let isValid: Bool
        }
        struct ViewModel {
            let isValid: Bool
        }
    }
    
    // Модели для входа в аккаунт
    enum LogIn {
        struct Request {
            let email: String
            let password: String
        }
        struct Response {
            let error: Error?
        }
        struct ViewModel {
            let title: String?
            let errorDescription: String?
        }
    }
}
