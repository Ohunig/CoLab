//
//  AuthLogic.swift
//  CoLab
//
//  Created by User on 29.01.2026.
//

import Foundation

// Логика сервиса для аутентификации пользователя
protocol AuthLogic: AnyObject {
    
    var currentUser: UserModel? { get }
    
    func logIn(
        email: String,
        password: String,
        completion: @escaping (Result<Void, LogInError>) -> Void
    )
    
    func logOut() throws
    
    func signUp(
        email: String,
        username: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
