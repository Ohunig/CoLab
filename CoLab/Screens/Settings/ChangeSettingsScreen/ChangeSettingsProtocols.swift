//
//  ChangeSettingsProtocols.swift
//  CoLab
//
//  Created by User on 16.03.2026.
//

import Foundation

// Описывает бизнес логику экрана
protocol ChangeSettingsBusinessLogic: AnyObject {
    typealias Model = ChangeSettingsModels
    
    // Начальные настройки
    func loadStart()
    
    // Подгрузка данных о пользователе
    func loadUserData()
    
    // Обновление данных пользователя
    func updateUserData(_ request: Model.UpdateUserData.Request)
    
    // Валидация установленных значений
    func loadDataValidation(_ request: Model.Validation.Request)
    
    // Выход из экрана
    func loadGoBack()
}

// Описывает логику презентации
protocol ChangeSettingsPresentationLogic: AnyObject {
    typealias Model = ChangeSettingsModels
    
    func presentStart(_ response: Model.Start.Response)
    
    func presentUserData(_ response: Model.GetUserData.Response)
    
    func presentDataValidation(_ response: Model.Validation.Response)
    
    func presentUpdateDataResult(_ response: Model.CatchError.Response)
}

// Описывает логику отображения
protocol ChangeSettingsDisplayLogic: AnyObject {
    typealias Model = ChangeSettingsModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayUserData(_ viewModel: Model.GetUserData.ViewModel)
    
    func displayDataValidation(_ viewModel: Model.Validation.ViewModel)
    
    func displayUpdateDataResult(_ viewModel: Model.CatchError.ViewModel)
}
