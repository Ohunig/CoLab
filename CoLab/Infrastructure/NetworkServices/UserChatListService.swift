//
//  UserChatListService.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class UserChatListService: UserChatListLogic {
    typealias Chats = FirebasePaths.Chats
    
    private struct Constants {
        
        static let fallbackTitle = "Chat"
    }
    
    private let db = Firestore.firestore()
    
    // Паблишер верхнего диапазона списка.
    // Ошибки тоже идут через него как Result, без завершения потока.
    private let updatesSubject = PassthroughSubject<Result<[ChatModel], FetchUserChatsError>, Never>()
    
    private var liveListener: ListenerRegistration?
    private var liveLimit: Int = 0
    private var lastUid: String?
    
    // MARK: - Live updates
    
    func userChatsUpdatesPublisher() -> AnyPublisher<Result<[ChatModel], FetchUserChatsError>, Never> {
        updatesSubject.eraseToAnyPublisher()
    }
    
    func setLiveUpdatesLimit(_ limit: Int) {
        let normalized = max(0, limit)
        let currentUid = currentUserId()
        let didUserChange = lastUid != currentUid
        
        guard let uid = currentUid, normalized > 0 else {
            resetLiveUpdatesState()
            updatesSubject.send(.success([]))
            return
        }
        
        guard didUserChange || normalized != liveLimit else { return }
        
        liveLimit = normalized
        lastUid = uid
        
        liveListener?.remove()
        liveListener = db.collection(Chats.root)
            .whereField(Chats.memberIds.path, arrayContains: uid)
            .order(by: Chats.lastMessageDate.path, descending: true)
            .order(by: FieldPath.documentID(), descending: true)
            .limit(to: normalized)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error {
                    let currentUid = self.currentUserId()
                    if currentUid == nil || currentUid != self.lastUid {
                        self.resetLiveUpdatesState()
                        self.updatesSubject.send(.success([]))
                        return
                    }
                    
                    self.updatesSubject.send(.failure(self.decodeError(error)))
                    self.resetLiveUpdatesState()
                    return
                }
                
                let docs = snapshot?.documents ?? []
                let chats = docs.compactMap { self.decodeChat(from: $0) }
                
                self.updatesSubject.send(.success(chats))
            }
    }
    
    deinit {
        liveListener?.remove()
    }
    
    // MARK: - Private
    
    private func currentUserId() -> String? {
        Auth.auth().currentUser?.uid
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
    
    private func resetLiveUpdatesState() {
        liveListener?.remove()
        liveListener = nil
        liveLimit = 0
        lastUid = nil
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
