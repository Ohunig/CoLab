//
//  ChatInfoModels.swift
//  CoLab
//
//  Created by User on 14.04.2026.
//

import Foundation

// Модели для передачи данных между слоями экрана
struct ChatInfoModels {
    
    // Модели для старта экрана
    enum Start {
        struct Response {
            let bg: ColorModel
            let bgGradient: ColorModel
            let elementsBase: ColorModel
            let tint: ColorModel
            let textColor: ColorModel
        }
        
        struct ViewModel {
            let bg: (hex: String, a: CGFloat)
            let bgGradient: (hex: String, a: CGFloat)
            let elementsBase: (hex: String, a: CGFloat)
            let tint: (hex: String, a: CGFloat)
            let textColor: (hex: String, a: CGFloat)
        }
    }
    
    // Модели для обновления данных чата
    enum GetChatData {
        struct Response {
            let avatarData: Data?
            let isAvatarLoading: Bool
            let title: String
            let memberNames: [String]
        }
        
        struct ViewModel {
            let avatarData: Data?
            let isAvatarLoading: Bool
            let title: String
            let memberNames: [String]
        }
    }
    
    // Модели для отображения ошибок
    enum ShowError {
        struct Response {
            let error: Error
        }
        
        struct ViewModel {
            let errorTitle: String
            let errorDescription: String
            let buttonText: String
        }
    }
}
