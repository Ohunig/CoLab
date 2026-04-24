//
//  ChatMessagesService.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class ChatMessagesService: ChatMessagesLogic {
    
    private typealias Chats = FirebasePaths.Chats
    private typealias Messages = FirebasePaths.Messages
    
    private let db = Firestore.firestore()
    
    private var chatListener: ListenerRegistration?
    private var listenedChatId: String?
    
    private let chatActivitySubject = PassthroughSubject<Result<Date?, FetchChatMessagesError>, Never>()
    
    
    // MARK: Use cases
    
    func chatLastMessageDatePublisher() -> AnyPublisher<Result<Date?, FetchChatMessagesError>, Never> {
        chatActivitySubject.eraseToAnyPublisher()
    }
    
    func startListeningChat(chatId: String) {
        // Проверяем чтобы не перезапускать того же слушателя
        guard listenedChatId != chatId || chatListener == nil else { return }
        
        stopListeningChat()
        listenedChatId = chatId
        
        chatListener = db.collection(Chats.root)
            .document(chatId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                // Так как если чат сменился, не нужно реагировать на обновления из других чатов
                guard self.listenedChatId == chatId else { return }
                
                if let error {
                    self.chatActivitySubject.send(.failure(self.decodeError(error)))
                    return
                }
                
                let timestamp = snapshot?.data()?[Chats.lastMessageDate.path] as? Timestamp
                self.chatActivitySubject.send(.success(timestamp?.dateValue()))
            }
    }
    
    func stopListeningChat() {
        chatListener?.remove()
        chatListener = nil
        listenedChatId = nil
    }
    
    func fetchLatestMessages(
        chatId: String,
        limit: Int
    ) -> AnyPublisher<[ChatMessageModel], FetchChatMessagesError> {
        Future<[ChatMessageModel], FetchChatMessagesError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            
            // Получаем последние limit сообщений
            self.messagesCollection(for: chatId)
                .order(by: Messages.createdAt.path, descending: true)
                .order(by: FieldPath.documentID(), descending: true)
                .limit(to: limit)
                .getDocuments { snapshot, error in
                    if let error {
                        promise(.failure(self.decodeError(error)))
                        return
                    }
                    
                    let messages = (snapshot?.documents ?? [])
                        .compactMap(self.decodeMessage(from:))
                        .reversed()
                    promise(.success(Array(messages)))
                }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchMessages(
        before message: ChatMessageModel,
        chatId: String,
        limit: Int
    ) -> AnyPublisher<[ChatMessageModel], FetchChatMessagesError> {
        Future<[ChatMessageModel], FetchChatMessagesError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            
            self.messagesCollection(for: chatId)
                .order(by: Messages.createdAt.path, descending: true)
                .order(by: FieldPath.documentID(), descending: true)
                .start(after: [
                    Timestamp(date: message.createdAt),
                    message.id
                ])
                .limit(to: limit)
                .getDocuments { snapshot, error in
                    if let error {
                        promise(.failure(self.decodeError(error)))
                        return
                    }
                    
                    let messages = (snapshot?.documents ?? [])
                        .compactMap(self.decodeMessage(from:))
                        .reversed()
                    promise(.success(Array(messages)))
                }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchMessages(
        after message: ChatMessageModel,
        chatId: String
    ) -> AnyPublisher<[ChatMessageModel], FetchChatMessagesError> {
        Future<[ChatMessageModel], FetchChatMessagesError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            
            self.messagesCollection(for: chatId)
                .whereField(
                    Messages.createdAt.path,
                    isGreaterThanOrEqualTo: Timestamp(date: message.createdAt)
                )
                .order(by: Messages.createdAt.path, descending: false)
                .order(by: FieldPath.documentID(), descending: false)
                .getDocuments { snapshot, error in
                    if let error {
                        promise(.failure(self.decodeError(error)))
                        return
                    }
                    
                    let messages = (snapshot?.documents ?? [])
                        .compactMap { self.decodeMessage(from: $0) }
                    promise(.success(messages))
                }
        }
        .eraseToAnyPublisher()
    }
    
    func sendMessage(
        text: String,
        chatId: String
    ) -> AnyPublisher<ChatMessageModel, SendChatMessageError> {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return Fail(error: .emptyText).eraseToAnyPublisher()
        }
        
        guard let senderId = Auth.auth().currentUser?.uid else {
            return Fail(error: .permissionDenied).eraseToAnyPublisher()
        }
        
        return Future<ChatMessageModel, SendChatMessageError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            
            let createdAt = Date()
            let messageRef = self.messagesCollection(for: chatId).document()
            let chatRef = self.db.collection(Chats.root).document(chatId)
            let batch = self.db.batch()
            
            batch.setData(
                [
                    Messages.senderId.path: senderId,
                    Messages.text.path: trimmedText,
                    Messages.createdAt.path: Timestamp(date: createdAt)
                ],
                forDocument: messageRef
            )
            
            batch.setData(
                [
                    Chats.lastMessageText.path: trimmedText,
                    // summary дата у чата должна идти от сервера, иначе
                    // порядок списка может ломаться из-за локального времени устройства.
                    Chats.lastMessageDate.path: FieldValue.serverTimestamp()
                ],
                forDocument: chatRef,
                merge: true
            )
            
            batch.commit { error in
                if let error {
                    promise(.failure(self.decodeSendError(error)))
                    return
                }
                
                promise(
                    .success(
                        ChatMessageModel(
                            id: messageRef.documentID,
                            senderId: senderId,
                            text: trimmedText,
                            createdAt: createdAt
                        )
                    )
                )
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: Deinit
    
    deinit {
        stopListeningChat()
    }
    
    // MARK: Collection
    
    private func messagesCollection(
        for chatId: String
    ) -> CollectionReference {
        db.collection(Chats.root)
            .document(chatId)
            .collection(Messages.root)
    }
    
    // MARK: Decode
    
    private func decodeMessage(
        from snapshot: QueryDocumentSnapshot
    ) -> ChatMessageModel? {
        let data = snapshot.data()
        
        guard let senderId = data[Messages.senderId.path] as? String,
              let text = data[Messages.text.path] as? String,
              let timestamp = data[Messages.createdAt.path] as? Timestamp else {
            return nil
        }
        
        return ChatMessageModel(
            id: snapshot.documentID,
            senderId: senderId,
            text: text,
            createdAt: timestamp.dateValue()
        )
    }
    
    private func decodeError(_ error: Error) -> FetchChatMessagesError {
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
    
    private func decodeSendError(_ error: Error) -> SendChatMessageError {
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
