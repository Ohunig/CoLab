//
//  SearchChatsListModels.swift
//  CoLab
//
//  Created by User on 24.04.2026.
//

import Foundation

// Модели для передачи данных между слоями экрана поиска чатов
struct SearchChatsListModels {
    // Модели для старта
    enum Start {
        struct Response {
            let bg: ColorModel
            let bgGradient: ColorModel
            let elementsBase: ColorModel
            let textColor: ColorModel
            let startGradient: ColorModel
            let endGradient: ColorModel
        }
        
        struct ViewModel {
            let bg: (hex: String, a: CGFloat)
            let bgGradient: (hex: String, a: CGFloat)
            let elementsBase: (hex: String, a: CGFloat)
            let textColor: (hex: String, a: CGFloat)
        }
    }
    
    // Модели для обновления текущего автара юзера
    enum CurrentUserAvatar {
        struct Response {
            let avatarData: Data?
        }
        
        struct ViewModel {
            let avatarData: Data?
        }
    }
    
    // Модели для обновления списка чатов
    enum ChatsList {
        struct Response {
            let chats: [ChatModel]
        }
        
        struct ViewModel {
            struct ChatCell {
                let id: String
                let title: String
                let baseColor: (hex: String, a: CGFloat)
                let textColor: (hex: String, a: CGFloat)
                let startGradientColor: (hex: String, a: CGFloat)
                let endGradientColor: (hex: String, a: CGFloat)
                let avatarURL: String?
                let memberIds: [String]
                let avatarData: Data?
            }
            
            let items: [ChatCell]
        }
    }
    
    // Модели для обновления аватара чата
    enum AvatarUpdate {
        struct Response {
            let chatId: String
            let avatarData: Data?
        }
        
        struct ViewModel {
            let chatId: String
        }
    }
    
    // Модели для отображения ошибки
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
