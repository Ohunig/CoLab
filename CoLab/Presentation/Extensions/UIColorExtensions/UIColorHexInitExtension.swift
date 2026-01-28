//
//  UIColorHexInitExtension.swift
//  CoLab
//
//  Created by User on 21.01.2026.
//

import UIKit

extension UIColor {
    
    private struct Constants {
        static let hex = 16
        static let module = 255
        
        static let bitsToRed = 16
        static let bitsToGreen = 8
        
        static let standardAlpha: Float = 1
    }
    
    // Конструктор из Hex
    convenience init(
        hex: String,
        alpha: Float = Constants.standardAlpha
    ) {
        let hex_int = Int(hex.suffix(hex.count - 1), radix: Constants.hex) ?? 0
        self.init(
            red: CGFloat(Float(hex_int >> Constants.bitsToRed) / Float(Constants.module)),
            green: CGFloat(Float((hex_int >> Constants.bitsToGreen) & Constants.module) / Float(Constants.module)),
            blue: CGFloat(Float(hex_int & Constants.module) / Float(Constants.module)),
            alpha: CGFloat(alpha))
    }
}
