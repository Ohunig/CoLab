//
//  SearchFriendsListModels.swift
//  CoLab
//
//  Created by User on 05.05.2026.
//

import Foundation

struct SearchFriendsListModels {
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
    
    enum CurrentUserAvatar {
        struct Response {
            let avatarData: Data?
        }
        
        struct ViewModel {
            let avatarData: Data?
        }
    }
    
    enum UsersList {
        struct Response {
            let users: [UserModel]
        }
        
        struct ViewModel {
            struct UserCell {
                let id: String
                let username: String
                let photoURL: String?
                let avatarData: Data?
                let baseColor: (hex: String, a: CGFloat)
                let tintColor: (hex: String, a: CGFloat)
                let textColor: (hex: String, a: CGFloat)
            }
            
            let items: [UserCell]
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
