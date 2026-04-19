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
        }
        
        struct ViewModel {
            let avatarData: Data?
            let isAvatarLoading: Bool
            let title: String
        }
    }
    
    // Модели для отображения списка участников
    enum MembersList {
        struct Member {
            let id: String
            let username: String
            let avatarURL: String?
        }
        
        struct Response {
            let members: [Member]
        }
        
        struct ViewModel {
            struct MemberCell {
                let id: String
                let username: String
                let baseColor: (hex: String, a: CGFloat)
                let textColor: (hex: String, a: CGFloat)
                let tintColor: (hex: String, a: CGFloat)
                let avatarURL: String?
                let avatarData: Data?
            }
            
            let items: [MemberCell]
            let updatedMemberIds: [String]
        }
    }
    
    // Модели для точечного обновления аватаров участников
    enum AvatarUpdate {
        struct Response {
            let memberId: String
            let avatarURL: String
            let avatarData: Data?
        }
        
        struct ViewModel {
            let memberId: String
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
