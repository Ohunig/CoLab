//
//  UIColorFromColorModelExtension.swift
//  CoLab
//
//  Created by User on 30.01.2026.
//

import Foundation
import UIKit

extension UIColor {
    
    // Конструктор из ColorModel
    convenience init(_ color: ColorModel) {
        self.init(
            red: color.red,
            green: color.green,
            blue: color.blue,
            alpha: color.alpha
        )
    }
}
