//
//  UserSettingsProtocols.swift
//  CoLab
//
//  Created by User on 13.03.2026.
//

import Foundation

// Описывает бизнес логику экрана
protocol UserSettingsBusinessLogic: AnyObject {
    typealias Model = UserSettingsModels
    
    func loadStart()
}

// Описывает логику презентации
protocol UserSettingsPresentationLogic: AnyObject {
    typealias Model = UserSettingsModels
    
    func presentStart(_ response: Model.Start.Response)
}

// Описывает логику отображения
protocol UserSettingsDisplayLogic: AnyObject {
    typealias Model = UserSettingsModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
}
