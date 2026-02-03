//
//  ColorRepository.swift
//  CoLab
//
//  Created by User on 01.02.2026.
//

import Foundation

// Логика хранилища цветов для всего приложения
protocol ColorStorageLogic: AnyObject {
    
    var backgroundColor: ColorModel { get }
    
    var backgroundGradientColor: ColorModel { get }
    
    var firstGradientColor: ColorModel { get }
    
    var secondGradientColor: ColorModel { get }
    
    var elementsBaseColor: ColorModel { get }
    
    var mainTextColor: ColorModel { get }
    
    var tintColor: ColorModel { get }
}
