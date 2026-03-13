//
//  TabBarScreenModels.swift
//  CoLab
//
//  Created by User on 07.03.2026.
//

import Foundation

// Модели для передачи данных между слоями экрана
struct TabBarScreenModels {
    
    enum Start {
        struct Response {
            let firstGradient: ColorModel
            let secondGradient: ColorModel
            let buttonsColor: ColorModel
            let wrapperColor: ColorModel
        }
        struct ViewModel {
            let firstGradient: (hex: String, a: CGFloat)
            let secondGradient: (hex: String, a: CGFloat)
            let buttonsColor: (hex: String, a: CGFloat)
            let wrapperColor: (hex: String, a: CGFloat)
        }
    }
}
