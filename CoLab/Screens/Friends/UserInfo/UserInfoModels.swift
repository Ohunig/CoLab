//
//  UserInfoModels.swift
//  CoLab
//
//  Created by User on 08.05.2026.
//

import Foundation

struct UserInfoModels {
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
