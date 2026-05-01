//
//  SearchChatsListProtocols.swift
//  CoLab
//
//  Created by User on 24.04.2026.
//

import Foundation

// Бизнесс-логика экрана
protocol SearchChatsListBusinessLogic: AnyObject {
    typealias Model = SearchChatsListModels
    
    // Загрузка начального состояния экрана
    func loadStart()
    
    // Включение обновления аватара юзера
    func listenCurrentUserAvatar()
    
    // Остановка обновления аватара юзера
    func stopListeningCurrentUserAvatar()
    
    // Загрузка начальных чатов
    func loadInitialChats()
    
    // Загрузка новой страницы чатов
    func loadNextPage()
    
    // Загрузка экрана добавления чата
    func loadAddChatScreen(
        chatId: String
    )
}

// Логика передачи данных в таблицу
protocol SearchChatsListTableDataLogic: AnyObject {
    typealias Model = SearchChatsListModels
    
    func chatIds() -> [String]
    
    func item(for chatId: String) -> Model.ChatsList.ViewModel.ChatCell?
}

// Логика презентации
protocol SearchChatsListPresentationLogic: AnyObject {
    typealias Model = SearchChatsListModels
    
    func presentStart(_ response: Model.Start.Response)
    
    func presentCurrentUserAvatar(_ response: Model.CurrentUserAvatar.Response)
    
    func presentChats(_ response: Model.ChatsList.Response)
    
    func presentAvatarUpdate(_ response: Model.AvatarUpdate.Response)
    
    func presentError(_ response: Model.ShowError.Response)
}

// Логика отображения
protocol SearchChatsListDisplayLogic: AnyObject {
    typealias Model = SearchChatsListModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayCurrentUserAvatar(_ viewModel: Model.CurrentUserAvatar.ViewModel)
    
    func displayChats(_ viewModel: Model.ChatsList.ViewModel)
    
    func displayAvatarUpdate(_ viewModel: Model.AvatarUpdate.ViewModel)
    
    func displayError(_ viewModel: Model.ShowError.ViewModel)
}
