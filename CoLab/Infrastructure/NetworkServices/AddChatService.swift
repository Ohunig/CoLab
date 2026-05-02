//
//  AddChatService.swift
//  CoLab
//
//  Created by User on 02.05.2026.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class AddChatService: AddChatLogic {
    private typealias Chats = FirebasePaths.Chats
    
    private struct Constants {
        static let fallbackTitle = "Chat"
    }
    
    private let db = Firestore.firestore()
    
    // MARK: Use-cases
    
    func chatUpdatesPublisher(
        chatId: String
    ) -> AnyPublisher<Result<ChatModel, FetchUserChatsError>, Never> {
        Deferred { [weak self] in
            guard let self else {
                let result: Result<ChatModel, FetchUserChatsError> = .failure(.unknown)
                return Just(result).eraseToAnyPublisher()
            }
            
            let subject = PassthroughSubject<Result<ChatModel, FetchUserChatsError>, Never>()
            
            let listener = self.db.collection(Chats.root)
                .document(chatId)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self else { return }
                    
                    if let error {
                        subject.send(.failure(self.decodeError(error)))
                        return
                    }
                    
                    guard let snapshot,
                          let chat = self.decodeChat(from: snapshot) else {
                        subject.send(.failure(.unknown))
                        return
                    }
                    
                    subject.send(.success(chat))
                }
            
            return subject
                .handleEvents(
                    receiveCancel: {
                        listener.remove()
                    }
                )
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func addCurrentUser(
        toChat chatId: String
    ) -> AnyPublisher<Void, FetchUserChatsError> {
        guard let userId = Auth.auth().currentUser?.uid else {
            return Fail(error: .permissionDenied).eraseToAnyPublisher()
        }
        
        return Future<Void, FetchUserChatsError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            
            self.db.collection(Chats.root)
                .document(chatId)
                .updateData([
                    // Не добавляет если такой id уже есть, проверки не нужны
                    Chats.memberIds.path: FieldValue.arrayUnion([userId])
                ]) { error in
                    if let error {
                        promise(.failure(self.decodeError(error)))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: Helpers
    
    private func decodeChat(from snapshot: DocumentSnapshot) -> ChatModel? {
        guard let data = snapshot.data() else { return nil }
        
        let id = snapshot.documentID
        let title = data[Chats.title.path] as? String ?? Constants.fallbackTitle
        let description = data[Chats.description.path] as? String
        let isPublic = data[Chats.isPublic.path] as? Bool ?? false
        let lastMessageText = data[Chats.lastMessageText.path] as? String
        let timestamp = data[Chats.lastMessageDate.path] as? Timestamp
        let lastMessageDate = timestamp?.dateValue()
        let avatarURL = data[Chats.avatarURL.path] as? String
        let users = data[Chats.memberIds.path] as? [String] ?? []
        
        return ChatModel(
            id: id,
            title: title,
            description: description,
            isPublic: isPublic,
            lastMessageText: lastMessageText,
            lastMessageDate: lastMessageDate,
            avatarURL: avatarURL,
            memberIds: users
        )
    }
    
    private func decodeError(_ error: Error) -> FetchUserChatsError {
        guard let ns = error as NSError? else { return .unknown }
        
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
