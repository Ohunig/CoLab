//
//  CreateChatModels.swift
//  CoLab
//
//  Created by User on 09.05.2026.
//

import Foundation

// Модели для передачи данных между слоями экрана
struct CreateChatModels {
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
                let isAvatarLoading: Bool
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
    
    // Модели для отображения аватара чата
    enum ChatAvatar {
        struct Response {
            let avatarData: Data?
        }
        
        struct ViewModel {
            let avatarData: Data?
        }
    }
    
    // Модели для валидации
    enum Validation {
        struct Request {
            let title: String
            let description: String
        }
        
        struct Response {
            let isValid: Bool
        }
        
        struct ViewModel {
            let isValid: Bool
        }
    }
    
    // Модели для создания чата
    enum CreateChat {
        struct Request {
            let title: String
            let description: String
            let isPublic: Bool
            let avatarData: Data?
        }
    }
    
    // Модели для отображения состояния создания чата
    enum CreatingState {
        struct Response {
            let isCreating: Bool
        }
        
        struct ViewModel {
            let isCreating: Bool
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
