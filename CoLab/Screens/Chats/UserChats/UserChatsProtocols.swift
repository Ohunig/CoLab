//
//  UserChatsProtocols.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation

protocol UserChatsBusinessLogic: AnyObject {
    typealias Model = UserChatsModels
    
    func loadStart()
    
    func listenCurrentUserAvatar()
    
    func stopListeningCurrentUserAvatar()
    
    /// Первая страница чатов
    func loadInitialChats()
    
    /// Загрузка следующей страницы (если есть что грузить)
    func loadNextPage()
    
    func loadChatMessagesScreen(
        chatId: String,
        chatTitle: String,
        chatAvatarURL: String?,
        memberIds: [String]
    )
}

protocol UserChatsTableDataLogic: AnyObject {
    typealias Model = UserChatsModels
    
    func chatIds() -> [String]
    
    func item(for chatId: String) -> Model.ChatsList.ViewModel.ChatCell?
}

protocol UserChatsPresentationLogic: AnyObject {
    typealias Model = UserChatsModels
    
    func presentStart(_ response: Model.Start.Response)
    
    func presentCurrentUserAvatar(_ response: Model.CurrentUserAvatar.Response)
    
    func presentChats(_ response: Model.ChatsList.Response)
    
    func presentAvatarUpdate(_ response: Model.AvatarUpdate.Response)
    
    func presentError(_ response: Model.ShowError.Response)
}

protocol UserChatsDisplayLogic: AnyObject {
    typealias Model = UserChatsModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayCurrentUserAvatar(_ viewModel: Model.CurrentUserAvatar.ViewModel)
    
    func displayChats(_ viewModel: Model.ChatsList.ViewModel)
    
    func displayAvatarUpdate(_ viewModel: Model.AvatarUpdate.ViewModel)
    
    func displayError(_ viewModel: Model.ShowError.ViewModel)
}
