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
            let bgColor: ColorModel
            let bgGradientColor: ColorModel
            let firstGradientColor: ColorModel
            let secondGradientColor: ColorModel
            let elementsBaseColor: ColorModel
            let tintColor: ColorModel
            let textColor: ColorModel
        }
        struct ViewModel {
            let bgColor: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
            let bgGradientColor: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
            let firstGradientColor: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
            let secondGradientColor: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
            let elementsBaseColor: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
            let tintColor: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
            let textColor: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
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
