//
//  UserServiceLogic.swift
//  CoLab
//
//  Created by User on 12.03.2026.
//

import Foundation
import Combine

// Cервис для работы с пользовательскими аккаунтами
protocol UserServiceLogic: AnyObject {
    
    func currentUserId() -> String?
    
    func updateCurrentUserData(user: UserModel) -> AnyPublisher<Void, UpdateUserDataError>
    
    // Метод возвращает паблишера который публекует данные юзера. Ожидается что startListening будет вызван заранее. Иначе корректное поведение не гарантируется
    func currentUserDataPublisher() -> AnyPublisher<UserModel, Never>
    
    // Метод нужен чтобы использовать в случае когда не надо следить за данными сервера долго.
    func fetchCurrentUserOnce() -> AnyPublisher<UserModel, FetchUserError>
    
    // Метод чтобы начать отслеживать изменения пользовательских данных
    func startListeningChanges()
    
    // Метод чтобы закончить отслеживание изменений
    func stopListeningChanges()
    
    // Очищает сохранённые в памяти данные юзера
    func clearUserCache()
}
