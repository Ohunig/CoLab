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
    
    private let userCache: UserCacheLogic
    
    // MARK: Lifecycle
    
    init(userCache: UserCacheLogic) {
        self.userCache = userCache
    }
    
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
                        // Не обновляем кэш здесь так как придёт уведомление на currentUserPublisher.
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
    
    func fetchCurrentUserOnce() -> AnyPublisher<UserModel, FetchUserError> {
        guard let id = currentUserId() else {
            return Fail(error: .permissionDenied).eraseToAnyPublisher()
        }
        
        if let cacheData = userCache.getUser(with: id) {
            return Just(cacheData)
                .setFailureType(to: FetchUserError.self)
                .eraseToAnyPublisher()
        }
        
        return Future<UserModel, FetchUserError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            
            self.db.collection(Users.root)
                .document(id)
                .getDocument { snapshot, error in
                    if error != nil {
                        promise(.failure(.unknown))
                        return
                    }
                    
                    guard let user = try? snapshot?.decoded(UserModel.self) else {
                        promise(.failure(.decoding))
                        return
                    }
                    
                    self.userCache.update(user: user, for: id)
                    
                    promise(.success(user))
                }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: Listen
    
    func startListeningChanges() {
        guard let id = currentUserId() else {
            return
        }
        
        // Пытаемся сначала загрузить кэш
        if let cachedUser = userCache.getUser(with: id) {
            userSubject.send(cachedUser)
        }
        
        listener = db.collection(Users.root)
            .document(id)
            .addSnapshotListener { [weak self] snapshot, error in
                // Если получаем ошибку, считаем что данные не менялись и ничего не делаем
                guard error == nil else { return }
                guard let user = try? snapshot?.decoded(UserModel.self) else {
                    return
                }
                // Если данные не изменились то ничего не отправляем
                guard user != self?.userSubject.value else { return }
                // Обновляем кэш
                self?.userCache.update(user: user, for: id)
                
                self?.userSubject.send(user)
            }
    }
    
    func stopListeningChanges() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: Clear data
    
    func clearUserCache() {
        userCache.clear()
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
