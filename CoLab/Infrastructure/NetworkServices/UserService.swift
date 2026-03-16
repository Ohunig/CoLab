//
//  UserService.swift
//  CoLab
//
//  Created by User on 12.03.2026.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class UserService: UserServiceLogic {
    typealias Users = FirebasePaths.Users
    
    private let db = Firestore.firestore()
    
    private var userSubject = CurrentValueSubject<UserModel?, Never>(nil)
    
    private var listener: ListenerRegistration?
    
    // MARK: Use-cases
    
    func currentUserId() -> String? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return user.uid
    }
    
    func updateCurrentUserData(
        user: UserModel
    ) -> AnyPublisher<Void, UpdateUserDataError> {
        // Даже если на вход пришёл user с другим id, изменяем именно текущего юзера
        guard let id = currentUserId() else {
            // permission denied так как нет id -> пользователь не вошёл в аккаунт
            return Fail(error: .permissionDenied).eraseToAnyPublisher()
        }
        let data: [String: Any?] = [
            Users.username.path: user.username,
            Users.photoURL.path: user.photoURL
        ]
        // Убираем nil-значения
        let filtered = data.compactMapValues { $0 }
        return Future<Void, UpdateUserDataError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            self.db.collection(Users.root)
                .document(id)
                .setData(filtered, merge: true) { error in
                    if let error {
                        promise(.failure(self.decodeError(error)))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func currentUserDataPublisher() -> AnyPublisher<UserModel, Never> {
        return userSubject.eraseToAnyPublisher()
            .compactMap({ $0 })
            .eraseToAnyPublisher()
    }
    
    // MARK: Listen
    
    func startListeningChanges() {
        guard let id = currentUserId() else {
            return
        }
        listener = db.collection(Users.root)
            .document(id)
            .addSnapshotListener { [weak self] snapshot, error in
                // Если получаем ошибку, считаем что данные не менялись и ничего не делаем
                guard error == nil else { return }
                
                guard let user = try? snapshot?.decoded(UserModel.self) else {
                    return
                }
                self?.userSubject.send(user)
            }
    }
    
    func stopListeningChanges() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: Decode error
    
    private func decodeError(_ error: Error) -> UpdateUserDataError {
        guard let ns = error as NSError? else { return .unknown }
        // Попытка распознать код Firestore
        if let fsCode = FirestoreErrorCode.Code(rawValue: ns.code) {
            switch fsCode {
            case .permissionDenied:
                return .permissionDenied
            case .unavailable:
                return .network
            default:
                return .unknown
            }
        }
        return .unknown
    }
}
