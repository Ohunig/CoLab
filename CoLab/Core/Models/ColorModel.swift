//
//  ColorModel.swift
//  CoLab
//
//  Created by User on 30.01.2026.
//

import Foundation

// Модель цвета, чтобы не связывать бизнес-логику с UI
struct ColorModel {
    
    private enum Constants {
        static let maxColor: CGFloat = 1
        static let minColor: CGFloat = 0
        
        static let maxIntColor: Int = 255
        static let minIntColor: Int = 0
        
        static let hex = 16
        static let bitsToRed = 16
        static let bitsToGreen = 8
        static let standardAlpha: Float = 1
    }
    
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    
    // MARK: Lifecycle
    
    init(
        red: CGFloat,
        green: CGFloat,
        blue: CGFloat,
        alpha: CGFloat = Constants.maxColor
    ) {
        self.red = min(max(red, Constants.minColor), Constants.maxColor)
        self.green = min(max(green, Constants.minColor), Constants.maxColor)
        self.blue = min(max(blue, Constants.minColor), Constants.maxColor)
        self.alpha = min(max(alpha, Constants.minColor), Constants.maxColor)
    }
    
    // Конструктор из интов от 0 до 255
    init(
        red: Int,
        green: Int,
        blue: Int,
        alpha: Int = Constants.maxIntColor
    ) {
        self.red = CGFloat(
            min(max(red, Constants.minIntColor), Constants.maxIntColor)
        ) / CGFloat(Constants.maxIntColor)
        self.green = CGFloat(
            min(max(green, Constants.minIntColor), Constants.maxIntColor)
        ) / CGFloat(Constants.maxIntColor)
        self.blue = CGFloat(
            min(max(blue, Constants.minIntColor), Constants.maxIntColor)
        ) / CGFloat(Constants.maxIntColor)
        self.alpha = CGFloat(
            min(max(alpha, Constants.minIntColor), Constants.maxIntColor)
        ) / CGFloat(Constants.maxIntColor)
    }
    
    // Конструктор из Hex
    init(
        hex: String,
        alpha: Float = Constants.standardAlpha
    ) {
        let hex_int = Int(hex.suffix(hex.count - 1), radix: Constants.hex) ?? 0
        self.init(
            red: CGFloat(Float(hex_int >> Constants.bitsToRed) / Float(Constants.maxIntColor)),
            green: CGFloat(Float((hex_int >> Constants.bitsToGreen) & Constants.maxIntColor) / Float(Constants.maxIntColor)),
            blue: CGFloat(Float(hex_int & Constants.maxIntColor) / Float(Constants.maxIntColor)),
            alpha: CGFloat(alpha))
    }
}
