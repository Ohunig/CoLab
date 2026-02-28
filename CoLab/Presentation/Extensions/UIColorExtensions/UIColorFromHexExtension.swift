//
//  UIColorFromHexExtension.swift
//  CoLab
//
//  Created by User on 26.02.2026.
//

import UIKit

extension UIColor {
    
    private enum Constants {
        static let maxIntColor: Int = 255
        static let hex = 16
        static let bitsToRed = 16
        static let bitsToGreen = 8
        static let standardAlpha: CGFloat = 1
    }
    
    convenience init(hex: String, alpha: CGFloat = Constants.standardAlpha) {
        let hex_int = Int(hex.suffix(hex.count - 1), radix: Constants.hex) ?? 0
        self.init(
            red: CGFloat(Float(hex_int >> Constants.bitsToRed) / Float(Constants.maxIntColor)),
            green: CGFloat(Float((hex_int >> Constants.bitsToGreen) & Constants.maxIntColor) / Float(Constants.maxIntColor)),
            blue: CGFloat(Float(hex_int & Constants.maxIntColor) / Float(Constants.maxIntColor)),
            alpha: alpha
        )
    }
}
