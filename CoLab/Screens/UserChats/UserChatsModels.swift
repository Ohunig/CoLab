//
//  UserChatsModels.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation

struct UserChatsModels {
    
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
    
    enum ChatsList {
        struct Response {
            let chats: [ChatModel]
        }
        struct ViewModel {
            struct ChatCell {
                let id: String
                let title: String
                let subtitle: String
                let time: String
                let baseColor: (hex: String, a: CGFloat)
                let textColor: (hex: String, a: CGFloat)
                let avatarURL: String?
                let avatarData: Data?
            }
            let items: [ChatCell]
            let updatedChatIds: [String]
        }
    }
    
    enum AvatarUpdate {
        struct Response {
            let chatId: String
            let avatarData: Data?
        }
        struct ViewModel {
            let chatId: String
        }
    }
    
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
