//
//  ChatTasksService.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class ChatTasksService: ChatTasksLogic {
    private typealias Chats = FirebasePaths.Chats
    private typealias Messages = FirebasePaths.Messages
    private typealias Tasks = FirebasePaths.Tasks
    
    private struct Constants {
        static let taskVoteText = "Голосование по задаче"
        static let activeVoteExistsErrorCode = -2
    }
    
    private let db = Firestore.firestore()
    private let tasksSubject = PassthroughSubject<Result<[ChatTaskModel], ChatTasksError>, Never>()
    private let activeTaskVotesSubject = PassthroughSubject<Result<Set<String>, ChatTasksError>, Never>()
    
    private var tasksListener: ListenerRegistration?
    private var activeTaskVotesListener: ListenerRegistration?
    private var listenedChatId: String?
    private var listenedActiveVotesChatId: String?
    private var listenedActiveVotesMemberCount = 0
    
    // MARK: Use-cases
    
    func taskUpdatesPublisher() -> AnyPublisher<Result<[ChatTaskModel], ChatTasksError>, Never> {
        tasksSubject.eraseToAnyPublisher()
    }
    
    func activeTaskVoteUpdatesPublisher() -> AnyPublisher<Result<Set<String>, ChatTasksError>, Never> {
        activeTaskVotesSubject.eraseToAnyPublisher()
    }
    
    func startListeningTasks(chatId: String) {
        guard listenedChatId != chatId || tasksListener == nil else { return }
        
        stopListeningTasks()
        listenedChatId = chatId
        
        tasksListener = tasksCollection(for: chatId)
            .order(by: Tasks.createdAt.path, descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                guard self.listenedChatId == chatId else { return }
                
                if let error {
                    self.tasksSubject.send(.failure(self.decodeError(error)))
                    return
                }
                
                let tasks = (snapshot?.documents ?? [])
                    .compactMap(self.decodeTask(from:))
                self.tasksSubject.send(.success(tasks))
            }
    }
    
    func stopListeningTasks() {
        tasksListener?.remove()
        tasksListener = nil
        listenedChatId = nil
    }
    
    func startListeningActiveTaskVotes(
        chatId: String,
        memberCount: Int
    ) {
        guard listenedActiveVotesChatId != chatId
                || listenedActiveVotesMemberCount != memberCount
                || activeTaskVotesListener == nil else {
            return
        }
        
        stopListeningActiveTaskVotes()
        listenedActiveVotesChatId = chatId
        listenedActiveVotesMemberCount = memberCount
        let requiredVotes = minimumVotesToResolve(memberCount: memberCount)
        
        activeTaskVotesListener = messagesCollection(for: chatId)
            .whereField(
                Messages.kind.path,
                isEqualTo: ChatMessageKind.taskVote.rawValue
            )
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                guard self.listenedActiveVotesChatId == chatId else { return }
                
                if let error {
                    self.activeTaskVotesSubject.send(.failure(self.decodeError(error)))
                    return
                }
                
                let activeTaskIds = Set(
                    (snapshot?.documents ?? []).compactMap {
                        self.activeTaskVoteTaskId(
                            from: $0,
                            requiredVotes: requiredVotes
                        )
                    }
                )
                self.activeTaskVotesSubject.send(.success(activeTaskIds))
            }
    }
    
    func stopListeningActiveTaskVotes() {
        activeTaskVotesListener?.remove()
        activeTaskVotesListener = nil
        listenedActiveVotesChatId = nil
        listenedActiveVotesMemberCount = 0
    }
    
    func createTask(
        text: String,
        chatId: String
    ) -> AnyPublisher<Void, ChatTasksError> {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return Fail(error: .emptyText).eraseToAnyPublisher()
        }
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return Fail(error: .permissionDenied).eraseToAnyPublisher()
        }
        
        return Future<Void, ChatTasksError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            
            let taskRef = self.tasksCollection(for: chatId).document()
            taskRef.setData(
                [
                    Tasks.text.path: trimmedText,
                    Tasks.createdBy.path: currentUserId,
                    Tasks.isCompleted.path: false,
                    Tasks.createdAt.path: Timestamp(date: Date())
                ]
            ) { [weak self] error in
                if let error {
                    promise(.failure(self?.decodeError(error) ?? .unknown))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func sendTaskVoteMessage(
        task: ChatTaskModel,
        chatId: String
    ) -> AnyPublisher<Void, ChatTasksError> {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return Fail(error: .permissionDenied).eraseToAnyPublisher()
        }
        
        return Future<Void, ChatTasksError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            
            let createdAt = Date()
            let chatRef = self.db.collection(Chats.root).document(chatId)
            let messageRef = chatRef.collection(Messages.root).document()
            let taskRef = chatRef.collection(Tasks.root).document(task.id)
            
            self.db.runTransaction { transaction, errorPointer in
                do {
                    let taskSnapshot = try transaction.getDocument(taskRef)
                    let data = taskSnapshot.data() ?? [:]
                    let isCompleted = data[Tasks.isCompleted.path] as? Bool ?? false
                    let activeVoteMessageId = data[Tasks.activeVoteMessageId.path] as? String
                    
                    guard !isCompleted,
                          activeVoteMessageId == nil else {
                        errorPointer?.pointee = NSError(
                            domain: "CoLab.ChatTasksService",
                            code: Constants.activeVoteExistsErrorCode
                        )
                        return nil
                    }
                    
                    transaction.setData(
                        [
                            Messages.kind.path: ChatMessageKind.taskVote.rawValue,
                            Messages.senderId.path: currentUserId,
                            Messages.taskId.path: task.id,
                            Messages.taskText.path: task.text,
                            Messages.text.path: Constants.taskVoteText,
                            Messages.votesFor.path: [],
                            Messages.votesAgainst.path: [],
                            Messages.isResolved.path: false,
                            Messages.createdAt.path: Timestamp(date: createdAt)
                        ],
                        forDocument: messageRef
                    )
                    
                    transaction.updateData(
                        [Tasks.activeVoteMessageId.path: messageRef.documentID],
                        forDocument: taskRef
                    )
                    
                    transaction.setData(
                        [
                            Chats.lastMessageText.path: Constants.taskVoteText,
                            Chats.lastMessageDate.path: FieldValue.serverTimestamp()
                        ],
                        forDocument: chatRef,
                        merge: true
                    )
                } catch {
                    errorPointer?.pointee = error as NSError
                }
                
                return nil
            } completion: { [weak self] _, error in
                if let error {
                    promise(.failure(self?.decodeError(error) ?? .unknown))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: Deinit
    
    deinit {
        stopListeningTasks()
        stopListeningActiveTaskVotes()
    }
    
    // MARK: Collection
    
    private func tasksCollection(for chatId: String) -> CollectionReference {
        db.collection(Chats.root)
            .document(chatId)
            .collection(Tasks.root)
    }
    
    private func messagesCollection(for chatId: String) -> CollectionReference {
        db.collection(Chats.root)
            .document(chatId)
            .collection(Messages.root)
    }
    
    // MARK: Decode
    
    private func decodeTask(
        from snapshot: QueryDocumentSnapshot
    ) -> ChatTaskModel? {
        let data = snapshot.data()
        
        guard let text = data[Tasks.text.path] as? String,
              let createdBy = data[Tasks.createdBy.path] as? String,
              let createdAt = data[Tasks.createdAt.path] as? Timestamp else {
            return nil
        }
        
        let isCompleted = data[Tasks.isCompleted.path] as? Bool ?? false
        let completedAt = (data[Tasks.completedAt.path] as? Timestamp)?.dateValue()
        let activeVoteMessageId = data[Tasks.activeVoteMessageId.path] as? String
        
        return ChatTaskModel(
            id: snapshot.documentID,
            text: text,
            createdBy: createdBy,
            isCompleted: isCompleted,
            createdAt: createdAt.dateValue(),
            completedAt: completedAt,
            activeVoteMessageId: activeVoteMessageId
        )
    }
    
    private func activeTaskVoteTaskId(
        from snapshot: QueryDocumentSnapshot,
        requiredVotes: Int
    ) -> String? {
        let data = snapshot.data()
        guard let taskId = data[Messages.taskId.path] as? String else {
            return nil
        }
        
        let votesFor = data[Messages.votesFor.path] as? [String] ?? []
        let votesAgainst = data[Messages.votesAgainst.path] as? [String] ?? []
        let isResolved = data[Messages.isResolved.path] as? Bool ?? false
        guard !isResolved,
              votesFor.count < requiredVotes,
              votesAgainst.count < requiredVotes else {
            return nil
        }
        
        return taskId
    }
    
    private func minimumVotesToResolve(memberCount: Int) -> Int {
        max(1, Int(ceil(Double(max(memberCount, 1)) / 2.0)))
    }
    
    private func decodeError(_ error: Error) -> ChatTasksError {
        guard let ns = error as NSError? else { return .unknown }
        guard ns.code != Constants.activeVoteExistsErrorCode else {
            return .activeVoteExists
        }
        
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
