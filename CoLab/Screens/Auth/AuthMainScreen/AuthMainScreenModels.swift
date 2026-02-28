//
//  AuthMainScreenModels.swift
//  CoLab
//
//  Created by User on 03.02.2026.
//

import Foundation

// Модели передачи данных между слоями
struct AuthMainScreenModels {
    
    // Модели для старта экрана
    enum Start {
        struct Response {
            let bgColor: ColorModel
            let bgGradientColor: ColorModel
            let firstGradientColor: ColorModel
            let secondGradientColor: ColorModel
        }
        struct ViewModel {
            let bgColor: (hex: String, a: CGFloat)
            let bgGradientColor: (hex: String, a: CGFloat)
            let firstGradientColor: (hex: String, a: CGFloat)
            let secondGradientColor: (hex: String, a: CGFloat)
        }
    }
}
