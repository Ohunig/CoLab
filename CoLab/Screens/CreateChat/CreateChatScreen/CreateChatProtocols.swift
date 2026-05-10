//
//  CreateChatProtocols.swift
//  CoLab
//
//  Created by User on 09.05.2026.
//

import Foundation

// Описывает бизнес логику экрана
protocol CreateChatBusinessLogic: AnyObject {
    typealias Model = CreateChatModels
    
    // Начальные настройки экрана
    func loadStart()
    
    // Подгрузка стандартного аватара чата
    func loadDefaultAvatar()
    
    // Подгрузка текущего пользователя как первого участника
    func loadCurrentUser()
    
    // Валидация введённых данных
    func loadDataValidation(_ request: Model.Validation.Request)
    
    // Открытие экрана выбора участника
    func loadAddMemberScreen()
    
    // Открытие экрана информации о пользователе
    func loadUserInfoScreen(userId: String)
    
    // Создание чата
    func createChat(_ request: Model.CreateChat.Request)
    
    // Выход из экрана
    func loadGoBack()
}

// Даёт контроллеру уже подготовленные данные для конкретной ячейки
protocol CreateChatTableDataLogic: AnyObject {
    typealias Model = CreateChatModels
    
    func memberIds() -> [String]
    
    func item(for memberId: String) -> Model.MembersList.ViewModel.MemberCell?
}

// Описывает логику презентации
protocol CreateChatPresentationLogic: AnyObject {
    typealias Model = CreateChatModels
    
    func presentStart(_ response: Model.Start.Response)
    
    func presentMembers(_ response: Model.MembersList.Response)
    
    func presentAvatarUpdate(_ response: Model.AvatarUpdate.Response)
    
    func presentChatAvatar(_ response: Model.ChatAvatar.Response)
    
    func presentDataValidation(_ response: Model.Validation.Response)
    
    func presentCreatingState(_ response: Model.CreatingState.Response)
    
    func presentError(_ response: Model.ShowError.Response)
}

// Описывает логику отображения
protocol CreateChatDisplayLogic: AnyObject {
    typealias Model = CreateChatModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayMembers(_ viewModel: Model.MembersList.ViewModel)
    
    func displayAvatarUpdate(_ viewModel: Model.AvatarUpdate.ViewModel)
    
    func displayChatAvatar(_ viewModel: Model.ChatAvatar.ViewModel)
    
    func displayDataValidation(_ viewModel: Model.Validation.ViewModel)
    
    func displayCreatingState(_ viewModel: Model.CreatingState.ViewModel)
    
    func displayError(_ viewModel: Model.ShowError.ViewModel)
}
