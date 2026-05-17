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
    private typealias Tasks = FirebasePaths.Tasks
    
    private struct Constants {
        static let taskVoteUpdatedText = "Голосование обновлено"
    }
    
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
                    Messages.kind.path: ChatMessageKind.text.rawValue,
                    Messages.senderId.path: senderId,
                    Messages.text.path: trimmedText,
                    Messages.createdAt.path: Timestamp(date: createdAt)
                ],
                forDocument: messageRef
            )
            
            batch.setData(
                [
                    Chats.lastMessageText.path: trimmedText,
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
                            kind: .text,
                            senderId: senderId,
                            memberId: nil,
                            text: trimmedText,
                            createdAt: createdAt
                        )
                    )
                )
            }
        }
        .eraseToAnyPublisher()
    }
    
    func voteForTaskCompletion(
        messageId: String,
        taskId: String,
        isApproved: Bool,
        chatId: String,
        memberCount: Int
    ) -> AnyPublisher<ChatMessageModel, SendChatMessageError> {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return Fail(error: .permissionDenied).eraseToAnyPublisher()
        }
        
        return Future<ChatMessageModel, SendChatMessageError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            
            let chatRef = self.db.collection(Chats.root).document(chatId)
            let messageRef = chatRef.collection(Messages.root).document(messageId)
            let taskRef = chatRef.collection(Tasks.root).document(taskId)
            var updatedMessage: ChatMessageModel?
            let requiredVotes = self.minimumVotesToResolve(memberCount: memberCount)
            
            self.db.runTransaction { transaction, errorPointer in
                do {
                    let snapshot = try transaction.getDocument(messageRef)
                    guard var data = snapshot.data(),
                          let message = self.decodeMessageData(
                            data,
                            id: snapshot.documentID
                          ),
                          message.kind == .taskVote,
                          message.taskId == taskId else {
                        errorPointer?.pointee = NSError(
                            domain: "CoLab.ChatMessagesService",
                            code: -1
                        )
                        return nil
                    }
                    
                    guard !self.isResolvedTaskVote(
                        message,
                        requiredVotes: requiredVotes
                    ) else {
                        if message.isResolved {
                            updatedMessage = message
                        } else {
                            data[Messages.isResolved.path] = true
                            updatedMessage = self.decodeMessageData(
                                data,
                                id: snapshot.documentID
                            )
                            transaction.updateData(
                                [Messages.isResolved.path: true],
                                forDocument: messageRef
                            )
                        }
                        
                        if message.votesFor.count >= requiredVotes {
                            transaction.updateData(
                                [
                                    Tasks.isCompleted.path: true,
                                    Tasks.completedAt.path: FieldValue.serverTimestamp(),
                                    Tasks.activeVoteMessageId.path: FieldValue.delete()
                                ],
                                forDocument: taskRef
                            )
                        } else if message.votesAgainst.count >= requiredVotes {
                            transaction.updateData(
                                [Tasks.activeVoteMessageId.path: FieldValue.delete()],
                                forDocument: taskRef
                            )
                        }
                        
                        return nil
                    }
                    
                    var votesFor = message.votesFor
                    var votesAgainst = message.votesAgainst
                    votesFor.removeAll { $0 == currentUserId }
                    votesAgainst.removeAll { $0 == currentUserId }
                    
                    if isApproved {
                        votesFor.append(currentUserId)
                    } else {
                        votesAgainst.append(currentUserId)
                    }
                    
                    let isResolved = votesFor.count >= requiredVotes
                        || votesAgainst.count >= requiredVotes
                    data[Messages.votesFor.path] = votesFor
                    data[Messages.votesAgainst.path] = votesAgainst
                    data[Messages.isResolved.path] = isResolved
                    updatedMessage = self.decodeMessageData(
                        data,
                        id: snapshot.documentID
                    )
                    
                    transaction.updateData(
                        [
                            Messages.votesFor.path: votesFor,
                            Messages.votesAgainst.path: votesAgainst,
                            Messages.isResolved.path: isResolved
                        ],
                        forDocument: messageRef
                    )
                    
                    if votesFor.count >= requiredVotes {
                        transaction.updateData(
                            [
                                Tasks.isCompleted.path: true,
                                Tasks.completedAt.path: FieldValue.serverTimestamp(),
                                Tasks.activeVoteMessageId.path: FieldValue.delete()
                            ],
                            forDocument: taskRef
                        )
                    } else if votesAgainst.count >= requiredVotes {
                        transaction.updateData(
                            [Tasks.activeVoteMessageId.path: FieldValue.delete()],
                            forDocument: taskRef
                        )
                    }
                    
                    transaction.updateData(
                        [
                            Chats.lastMessageText.path: Constants.taskVoteUpdatedText,
                            Chats.lastMessageDate.path: FieldValue.serverTimestamp()
                        ],
                        forDocument: chatRef
                    )
                } catch {
                    errorPointer?.pointee = error as NSError
                }
                
                return nil
            } completion: { [weak self] _, error in
                if let error {
                    promise(.failure(self?.decodeSendError(error) ?? .unknown))
                    return
                }
                
                guard let updatedMessage else {
                    promise(.failure(.unknown))
                    return
                }
                
                promise(.success(updatedMessage))
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
        decodeMessageData(snapshot.data(), id: snapshot.documentID)
    }
    
    private func decodeMessageData(
        _ data: [String: Any],
        id: String
    ) -> ChatMessageModel? {
        
        guard let timestamp = data[Messages.createdAt.path] as? Timestamp else {
            return nil
        }
        
        let kind = (data[Messages.kind.path] as? String)
            .flatMap(ChatMessageKind.init(rawValue:)) ?? .text
        let senderId = data[Messages.senderId.path] as? String
        let memberId = data[Messages.memberId.path] as? String
        let text = data[Messages.text.path] as? String ?? ""
        let taskId = data[Messages.taskId.path] as? String
        let taskText = data[Messages.taskText.path] as? String
        let votesFor = data[Messages.votesFor.path] as? [String] ?? []
        let votesAgainst = data[Messages.votesAgainst.path] as? [String] ?? []
        let isResolved = data[Messages.isResolved.path] as? Bool ?? false
        
        switch kind {
        case .text:
            guard senderId != nil else { return nil }
        case .memberJoined, .memberLeft:
            guard memberId != nil else { return nil }
        case .taskVote:
            guard senderId != nil,
                  taskId != nil,
                  taskText != nil else {
                return nil
            }
        }
        
        return ChatMessageModel(
            id: id,
            kind: kind,
            senderId: senderId,
            memberId: memberId,
            text: text,
            createdAt: timestamp.dateValue(),
            taskId: taskId,
            taskText: taskText,
            votesFor: votesFor,
            votesAgainst: votesAgainst,
            isResolved: isResolved
        )
    }
    
    private func minimumVotesToResolve(memberCount: Int) -> Int {
        max(1, Int(ceil(Double(max(memberCount, 1)) / 2.0)))
    }
    
    private func isResolvedTaskVote(
        _ message: ChatMessageModel,
        requiredVotes: Int
    ) -> Bool {
        message.isResolved
            || message.votesFor.count >= requiredVotes
            || message.votesAgainst.count >= requiredVotes
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
