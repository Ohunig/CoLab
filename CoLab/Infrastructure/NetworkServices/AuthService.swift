//
//  AuthService.swift
//  CoLab
//
//  Created by User on 30.01.2026.
//

import Foundation
import FirebaseAuth

// Сервис авторизации в приложении
final class AuthService: AuthLogic {
    
    private struct Constants {
        static let standardUsername = "UnknownUser"
    }
    
    var currentUser: UserModel? {
        get {
            guard let user = Auth.auth().currentUser else { return nil }
            return UserModel(
                uid: user.uid,
                username: user.displayName ?? Constants.standardUsername,
                photoURL: user.photoURL?.absoluteString
            )
        }
    }
    
    // MARK: Use-cases
    
    func logIn(
        email: String,
        password: String,
        completion: @escaping (Result<Void, any Error>) -> Void
    ) {
        Auth.auth().signIn(
            withEmail: email,
            password: password
        ) { _, error in
            if let error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func logOut() throws {
        try Auth.auth().signOut()
    }
    
    func signUp(
        email: String,
        username: String,
        password: String,
        completion: @escaping (Result<Void, any Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let user = result?.user else {
                // Так как если error == nil, то аккаунт уже был создан, хоть мы и получили nil в качестве user
                completion(.success(()))
                return
            }
            let change = user.createProfileChangeRequest()
            change.displayName = username
            change.commitChanges() { error in
                if let error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
        }
    }
    
}
