//
//  AuthService.swift
//  CoLab
//
//  Created by User on 30.01.2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

// Сервис авторизации в приложении
final class AuthService: AuthLogic {
    
    private struct Constants {
        static let standardAvatarURL = "avatar.jpg"
    }
    
    lazy private var auth = Auth.auth()
    lazy private var db = Firestore.firestore()
    
    // MARK: Use-cases
    
    func logIn(
        email: String,
        password: String,
        completion: @escaping (Result<Void, LogInError>) -> Void
    ) {
        auth.signIn(
            withEmail: email,
            password: password
        ) { _, error in
            if let nsError = error as NSError? {
                // Получаем ошибку нужного типа
                let mappedError: LogInError
                
                switch nsError.code {
                case AuthErrorCode.invalidCredential.rawValue:
                    mappedError = .invalidCredential
                case AuthErrorCode.invalidEmail.rawValue:
                    mappedError = .invalidEmail
                case AuthErrorCode.networkError.rawValue:
                    mappedError = .network
                default:
                    mappedError = .unknown
                }
                completion(.failure(mappedError))
                return
            }
            completion(.success(()))
        }
    }
    
    func logOut() throws {
        try auth.signOut()
    }
    
    func signUp(
        email: String,
        username: String,
        password: String,
        completion: @escaping (Result<Void, RegisterError>) -> Void
    ) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self else {
                completion(.failure(.unknown))
                return
            }
            if let nsError = error as NSError? {
                // Получаем ошибку нужного типа
                let mappedError: RegisterError
                
                switch nsError.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    mappedError = .emailAlreadyInUse
                case AuthErrorCode.invalidEmail.rawValue:
                    mappedError = .invalidEmail
                case AuthErrorCode.networkError.rawValue:
                    mappedError = .networkError
                default:
                    mappedError = .unknown
                }
                completion(.failure(mappedError))
                return
            }
            guard let user = result?.user else {
                // Так как не можем создать аккаунт если не получили юзера обратно. На самом же деле firebase гарантирует что такая ситуация невозможна, поэтому нет нужды удалять здесь созданный аккаунт
                completion(.failure(.unknown))
                return
            }
            
            // Создаём аккаунт в firestore
            self.createAccount(userID: user.uid, username: username) { result in
                if case let .failure(error) = result {
                    // Пытаемся удалить аккаунт так как не удалось создать полностью
                    self.auth.currentUser?.delete()
                    completion(.failure(error))
                } else {
                    // Изменяем данные юзера в Authentification
                    let change = user.createProfileChangeRequest()
                    change.displayName = username
                    change.commitChanges() { _ in
                        // Так как аккаунт уже был создан в любом случае
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    // MARK: Create account
    
    // Метод для создания аккаунта в firestore
    private func createAccount(
        userID: String,
        username: String,
        completion: @escaping (Result<Void, RegisterError>) -> Void
    ) {
        typealias Users = FirebasePaths.Users
        
        db.collection(Users.root)
            .document(userID)
            .setData([
                Users.username.path: username,
                Users.photoURL.path: Constants.standardAvatarURL
            ], merge: true) { error in
                if error != nil {
                    completion(.failure(.unknown))
                    return
                }
                completion(.success(()))
            }
    }
}
