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
    
    // Начальные настройки
    func loadStart()
    
    // Метод позволяет начать слушать изменения данных юзера
    func listenUserData()
    
    // Метод позволяет прекратить прослушивать изменения юзера
    func stopListeningUserData()
    
    // Выход из аккаунта и переход к входу/регистрации
    func logOut()
    
    // Переход на экран изменения данных
    func loadChangeDataScreen()
}

// Описывает логику презентации
protocol UserSettingsPresentationLogic: AnyObject {
    typealias Model = UserSettingsModels
    
    func presentStart(_ response: Model.Start.Response)
    
    func presentUserChanges(_ response: Model.GetUserData.Response)
    
    func presentError(_ response: Model.ShowError.Response)
}

// Описывает логику отображения
protocol UserSettingsDisplayLogic: AnyObject {
    typealias Model = UserSettingsModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayUserChanges(_ viewModel: Model.GetUserData.ViewModel)
    
    func displayError(_ viewModel: Model.ShowError.ViewModel)
}
