//
//  ChatInfoProtocols.swift
//  CoLab
//
//  Created by User on 14.04.2026.
//

import Foundation

// Описывает бизнес логику экрана
protocol ChatInfoBusinessLogic: AnyObject {
    typealias Model = ChatInfoModels
    
    // Начальные настройки экрана
    func loadStart()
}

// Даёт контроллеру уже подготовленные данные для конкретной ячейки
protocol ChatInfoTableDataLogic: AnyObject {
    typealias Model = ChatInfoModels
    
    func memberIds() -> [String]
    
    func item(for memberId: String) -> Model.MembersList.ViewModel.MemberCell?
}

// Описывает логику презентации
protocol ChatInfoPresentationLogic: AnyObject {
    typealias Model = ChatInfoModels
    
    func presentStart(_ response: Model.Start.Response)
    
    func presentChatData(_ response: Model.GetChatData.Response)
    
    func presentMembers(_ response: Model.MembersList.Response)
    
    func presentAvatarUpdate(_ response: Model.AvatarUpdate.Response)
    
    func presentError(_ response: Model.ShowError.Response)
}

// Описывает логику отображения
protocol ChatInfoDisplayLogic: AnyObject {
    typealias Model = ChatInfoModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayChatData(_ viewModel: Model.GetChatData.ViewModel)
    
    func displayMembers(_ viewModel: Model.MembersList.ViewModel)
    
    func displayAvatarUpdate(_ viewModel: Model.AvatarUpdate.ViewModel)
    
    func displayError(_ viewModel: Model.ShowError.ViewModel)
}
