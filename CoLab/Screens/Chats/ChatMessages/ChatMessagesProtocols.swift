//
//  ChatMessagesProtocols.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import Foundation

// Описывает бизнес логику экрана сообщений
protocol ChatMessagesBusinessLogic: AnyObject {
    typealias Model = ChatMessagesModels
    
    // Начальные настройки экрана
    func loadStart()
    
    // Первая загрузка последних сообщений
    func loadInitialMessages()
    
    // Запуск live updates по активности чата
    func startUpdates()
    
    // Подтягиваем аватар текущего чата для верхней панели экрана
    func listenChatAvatar()
    
    // Остановка live updates при уходе с экрана
    func stopUpdates()
    
    func stopListeningChatAvatar()
    
    // Догрузка старых сообщений при пагинации вверх
    func loadPreviousMessages()
    
    // Отправка нового текстового сообщения
    func sendMessage(text: String)
}

// Даёт контроллеру уже подготовленные данные для конкретной ячейки
protocol ChatMessagesCollectionDataLogic: AnyObject {
    typealias Model = ChatMessagesModels
    
    func messageIds() -> [String]
    
    func item(for messageId: String) -> Model.MessagesList.ViewModel.MessageItem?
}

// Описывает логику презентации
protocol ChatMessagesPresentationLogic: AnyObject {
    typealias Model = ChatMessagesModels
    
    func presentStart(_ response: Model.Start.Response)
    
    func presentChatAvatar(_ response: Model.ChatAvatar.Response)
    
    func presentMessages(_ response: Model.MessagesList.Response)
    
    func presentError(_ response: Model.ShowError.Response)
}

// Описывает логику отображения
protocol ChatMessagesDisplayLogic: AnyObject {
    typealias Model = ChatMessagesModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayChatAvatar(_ viewModel: Model.ChatAvatar.ViewModel)
    
    func displayMessages(_ viewModel: Model.MessagesList.ViewModel)
    
    func displayError(_ viewModel: Model.ShowError.ViewModel)
}
