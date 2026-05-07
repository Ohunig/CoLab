//
//  AddChatMemberModels.swift
//  CoLab
//
//  Created by User on 07.05.2026.
//

import Foundation

struct AddChatMemberModels {
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
    
    enum FriendsList {
        struct Response {
            let users: [UserModel]
        }
        
        struct ViewModel {
            struct FriendCell {
                let id: String
                let username: String
                let photoURL: String?
                let avatarData: Data?
                let baseColor: (hex: String, a: CGFloat)
                let tintColor: (hex: String, a: CGFloat)
                let textColor: (hex: String, a: CGFloat)
            }
            
            let items: [FriendCell]
        }
    }
    
    enum AvatarUpdate {
        struct Response {
            let userId: String
            let avatarData: Data?
        }
        
        struct ViewModel {
            let userId: String
        }
    }
    
    enum AddingState {
        struct Response {
            let isAdding: Bool
        }
        
        struct ViewModel {
            let isAdding: Bool
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
