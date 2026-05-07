//
//  ChatService.swift
//  CoLab
//
//  Created by User on 02.05.2026.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class ChatService: ChatLogic {
    private typealias Chats = FirebasePaths.Chats
    private typealias Messages = FirebasePaths.Messages
    
    private struct Constants {
        static let fallbackTitle = "Chat"
        static let memberJoinedText = "Участник вошёл в чат"
        static let memberLeftText = "Участник вышел из чата"
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
            
            self.commitMemberEvent(
                kind: .memberJoined,
                senderId: userId,
                memberId: userId,
                chatId: chatId,
                memberIdsUpdate: FieldValue.arrayUnion([userId]),
                lastMessageText: Constants.memberJoinedText,
                promise: promise
            )
        }
        .eraseToAnyPublisher()
    }
    
    func addUser(
        _ userId: String,
        toChat chatId: String
    ) -> AnyPublisher<Void, FetchUserChatsError> {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return Fail(error: .permissionDenied).eraseToAnyPublisher()
        }
        
        return Future<Void, FetchUserChatsError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            
            self.commitMemberEvent(
                kind: .memberJoined,
                senderId: currentUserId,
                memberId: userId,
                chatId: chatId,
                memberIdsUpdate: FieldValue.arrayUnion([userId]),
                lastMessageText: Constants.memberJoinedText,
                promise: promise
            )
        }
        .eraseToAnyPublisher()
    }
    
    func removeCurrentUser(
        fromChat chatId: String
    ) -> AnyPublisher<Void, FetchUserChatsError> {
        guard let userId = Auth.auth().currentUser?.uid else {
            return Fail(error: .permissionDenied).eraseToAnyPublisher()
        }
        
        return Future<Void, FetchUserChatsError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            
            self.commitMemberEvent(
                kind: .memberLeft,
                senderId: userId,
                memberId: userId,
                chatId: chatId,
                memberIdsUpdate: FieldValue.arrayRemove([userId]),
                lastMessageText: Constants.memberLeftText,
                promise: promise
            )
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: Helpers
    
    private func commitMemberEvent(
        kind: ChatMessageKind,
        senderId: String,
        memberId: String,
        chatId: String,
        memberIdsUpdate: FieldValue,
        lastMessageText: String,
        promise: @escaping (Result<Void, FetchUserChatsError>) -> Void
    ) {
        let createdAt = Date()
        let chatRef = db.collection(Chats.root).document(chatId)
        let messageRef = chatRef.collection(Messages.root).document()
        let batch = db.batch()
        
        batch.updateData(
            [
                Chats.memberIds.path: memberIdsUpdate,
                Chats.lastMessageText.path: lastMessageText,
                Chats.lastMessageDate.path: FieldValue.serverTimestamp()
            ],
            forDocument: chatRef
        )
        
        batch.setData(
            [
                Messages.kind.path: kind.rawValue,
                Messages.senderId.path: senderId,
                Messages.memberId.path: memberId,
                Messages.text.path: lastMessageText,
                Messages.createdAt.path: Timestamp(date: createdAt)
            ],
            forDocument: messageRef
        )
        
        batch.commit { [weak self] error in
            if let error {
                promise(.failure(self?.decodeError(error) ?? .unknown))
            } else {
                promise(.success(()))
            }
        }
    }
    
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
        let searchKeywords = data[Chats.searchKeywords.path] as? [String] ?? []
        
        return ChatModel(
            id: id,
            title: title,
            description: description,
            isPublic: isPublic,
            lastMessageText: lastMessageText,
            lastMessageDate: lastMessageDate,
            avatarURL: avatarURL,
            memberIds: users,
            searchKeywords: searchKeywords
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
