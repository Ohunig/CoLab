//
//  ChatMessagesModels.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import Foundation

// Модели для передачи данных между слоями экрана сообщений
struct ChatMessagesModels {
    
    // Модели для старта экрана
    enum Start {
        struct Response {
            let bg: ColorModel
            let bgGradient: ColorModel
            let incomingBase: ColorModel
            let incomingBorder: ColorModel
            let outgoingGradientStart: ColorModel
            let outgoingGradientEnd: ColorModel
            let incomingTextColor: ColorModel
            let outgoingTextColor: ColorModel
            let senderNameColor: ColorModel
        }
        
        struct ViewModel {
            let bg: (hex: String, a: CGFloat)
            let bgGradient: (hex: String, a: CGFloat)
            let incomingBase: (hex: String, a: CGFloat)
            let incomingBorder: (hex: String, a: CGFloat)
            let outgoingGradientStart: (hex: String, a: CGFloat)
            let outgoingGradientEnd: (hex: String, a: CGFloat)
            let incomingTextColor: (hex: String, a: CGFloat)
            let outgoingTextColor: (hex: String, a: CGFloat)
            let senderNameColor: (hex: String, a: CGFloat)
        }
    }
    
    // Модели для аватара чата в верхней панели
    enum ChatAvatar {
        struct Response {
            let avatarData: Data?
        }
        
        struct ViewModel {
            let avatarData: Data?
        }
    }
    
    // Модели для отображения списка сообщений
    enum MessagesList {
        struct SenderData {
            let username: String?
            let avatarData: Data?
        }
        
        struct Response {
            let messages: [ChatMessageModel]
            let currentUserId: String?
            let senderDataById: [String: SenderData]
        }
        
        struct ViewModel {
            enum Direction: Equatable {
                case incoming
                case outgoing
            }
            
            struct MessageItem {
                let id: String
                let text: String
                let direction: Direction
                let senderName: String?
                let avatarData: Data?
                let baseColor: (hex: String, a: CGFloat)
                let borderColor: (hex: String, a: CGFloat)?
                let gradientStartColor: (hex: String, a: CGFloat)?
                let gradientEndColor: (hex: String, a: CGFloat)?
                let textColor: (hex: String, a: CGFloat)
                let senderTextColor: (hex: String, a: CGFloat)?
            }
            
            let items: [MessageItem]
            // Нужен для точечного reconfigure уже показанных ячеек
            let updatedMessageIds: [String]
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
