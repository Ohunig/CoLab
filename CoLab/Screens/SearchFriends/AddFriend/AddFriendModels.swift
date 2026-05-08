//
//  AddFriendModels.swift
//  CoLab
//
//  Created by User on 06.05.2026.
//

import Foundation

struct AddFriendModels {
    enum Start {
        struct Response {
            let bg: ColorModel
            let bgGradient: ColorModel
            let elementsBase: ColorModel
            let tint: ColorModel
            let textColor: ColorModel
            let firstGradient: ColorModel
            let secondGradient: ColorModel
        }
        
        struct ViewModel {
            let bg: (hex: String, a: CGFloat)
            let bgGradient: (hex: String, a: CGFloat)
            let elementsBase: (hex: String, a: CGFloat)
            let tint: (hex: String, a: CGFloat)
            let textColor: (hex: String, a: CGFloat)
            let firstGradient: (hex: String, a: CGFloat)
            let secondGradient: (hex: String, a: CGFloat)
        }
    }
    
    enum UserData {
        struct Response {
            let avatarData: Data?
            let isAvatarLoading: Bool
            let username: String
        }
        
        struct ViewModel {
            let avatarData: Data?
            let isAvatarLoading: Bool
            let username: String
        }
    }
    
    enum AddButtonState {
        struct Response {
            let isLoading: Bool
            let isFriend: Bool
            let isSelf: Bool
        }
        
        struct ViewModel {
            let title: String
            let isEnabled: Bool
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
