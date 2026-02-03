//
//  ColorRepository.swift
//  CoLab
//
//  Created by User on 01.02.2026.
//

import Foundation

// Хранилище цветов приложения
final class ColorRepository: ColorStorageLogic {
    
    private struct Constants {
        static let standardBackgroundColor = "#111111"
        static let standardBackgroundGradientColor = "#553D01"
        static let standardFirstGradientColor = "#D1772D"
        static let standardSecondGradientColor = "#E2A712"
        static let standardElementsBaseColor = "#4C4232"
        static let standardMainTextColor = "#FFFFFF"
        static let standardTintColor = "#7E6C4F"
    }
    
    var backgroundColor: ColorModel {
        ColorModel(hex: Constants.standardBackgroundColor)
    }
    
    var backgroundGradientColor: ColorModel {
        ColorModel(hex: Constants.standardBackgroundGradientColor)
    }
    
    var firstGradientColor: ColorModel {
        ColorModel(hex: Constants.standardFirstGradientColor)
    }
    
    var secondGradientColor: ColorModel {
        ColorModel(hex: Constants.standardSecondGradientColor)
    }
    
    var elementsBaseColor: ColorModel {
        ColorModel(hex: Constants.standardElementsBaseColor)
    }
    
    var mainTextColor: ColorModel {
        ColorModel(hex: Constants.standardMainTextColor)
    }
    
    var tintColor: ColorModel {
        ColorModel(hex: Constants.standardTintColor)
    }
    
}
