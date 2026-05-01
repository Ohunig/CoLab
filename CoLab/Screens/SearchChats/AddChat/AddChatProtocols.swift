//
//  AddChatProtocols.swift
//  CoLab
//
//  Created by User on 01.05.2026.
//

import Foundation

// Описывает бизнес логику экрана
protocol AddChatBusinessLogic: AnyObject {
    typealias Model = AddChatModels
    
    // Начальные настройки экрана
    func loadStart()
    
    // Добавление текущего юзера в чат
    func addChat()
}

// Даёт контроллеру уже подготовленные данные для конкретной ячейки
protocol AddChatTableDataLogic: AnyObject {
    typealias Model = AddChatModels
    
    func memberIds() -> [String]
    
    func item(for memberId: String) -> Model.MembersList.ViewModel.MemberCell?
}

// Описывает логику презентации
protocol AddChatPresentationLogic: AnyObject {
    typealias Model = AddChatModels
    
    func presentStart(_ response: Model.Start.Response)
    
    func presentChatData(_ response: Model.GetChatData.Response)
    
    func presentMembers(_ response: Model.MembersList.Response)
    
    func presentAvatarUpdate(_ response: Model.AvatarUpdate.Response)
    
    func presentAddButtonState(_ response: Model.AddButtonState.Response)
    
    func presentError(_ response: Model.ShowError.Response)
}

// Описывает логику отображения
protocol AddChatDisplayLogic: AnyObject {
    typealias Model = AddChatModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayChatData(_ viewModel: Model.GetChatData.ViewModel)
    
    func displayMembers(_ viewModel: Model.MembersList.ViewModel)
    
    func displayAvatarUpdate(_ viewModel: Model.AvatarUpdate.ViewModel)
    
    func displayAddButtonState(_ viewModel: Model.AddButtonState.ViewModel)
    
    func displayError(_ viewModel: Model.ShowError.ViewModel)
}
