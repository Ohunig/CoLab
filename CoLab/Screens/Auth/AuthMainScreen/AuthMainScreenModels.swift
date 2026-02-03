//
//  AuthMainScreenModels.swift
//  CoLab
//
//  Created by User on 03.02.2026.
//

import Foundation

// Модели передачи данных между слоями
struct AuthMainScreenModels {
    
    enum Start {
        struct Response {
            let bgColor: ColorModel
            let bgGradientColor: ColorModel
            let firstGradientColor: ColorModel
            let secondGradientColor: ColorModel
        }
        struct ViewModel {
            let bgColor: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
            let bgGradientColor: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
            let firstGradientColor: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
            let secondGradientColor: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
        }
    }
}
