//
//  SearchChatsListService.swift
//  CoLab
//
//  Created by User on 24.04.2026.
//

import Foundation
import Combine
import FirebaseFirestore

final class SearchChatsListService: SearchChatsListLogic {
    private typealias Chats = FirebasePaths.Chats
    
    private struct Constants {
        static let fallbackTitle = "Chat"
    }
    
    private let db = Firestore.firestore()
    private var lastDocument: QueryDocumentSnapshot?
    
    // MARK: Use-cases
    
    func fetchFirstPage(
        limit: Int
    ) -> AnyPublisher<SearchChatsPage, FetchUserChatsError> {
        reset()
        return fetchPage(after: nil, limit: limit)
    }
    
    func fetchNextPage(
        limit: Int
    ) -> AnyPublisher<SearchChatsPage, FetchUserChatsError> {
        guard let lastDocument else {
            return Just(SearchChatsPage(chats: [], hasMore: false))
                .setFailureType(to: FetchUserChatsError.self)
                .eraseToAnyPublisher()
        }
        
        return fetchPage(after: lastDocument, limit: limit)
    }
    
    func reset() {
        lastDocument = nil
    }
    
    // MARK: Helpers
    
    private func fetchPage(
        after document: QueryDocumentSnapshot?,
        limit: Int
    ) -> AnyPublisher<SearchChatsPage, FetchUserChatsError> {
        Deferred { [weak self] in
            let subject = PassthroughSubject<SearchChatsPage, FetchUserChatsError>()
            
            guard let self else {
                return Fail<SearchChatsPage, FetchUserChatsError>(error: .unknown)
                    .eraseToAnyPublisher()
            }
            
            let fetchPage = { [weak self] (source: FirestoreSource) in
                guard let self else {
                    subject.send(completion: .failure(.unknown))
                    return
                }
                
                let normalizedLimit = max(1, limit)
                var query: Query = self.db.collection(Chats.root)
                    .order(by: FieldPath.documentID(), descending: true)
                
                if let document {
                    query = query.start(afterDocument: document)
                }
                
                query
                    .limit(to: normalizedLimit)
                    .getDocuments(source: source) { snapshot, error in
                        if let error {
                            if source == .server {
                                subject.send(
                                    completion: .failure(self.decodeError(error))
                                )
                            }
                            return
                        }
                        
                        let docs = snapshot?.documents ?? []
                        if let lastDocument = docs.last {
                            self.lastDocument = lastDocument
                        } else if document == nil, source == .server {
                            self.lastDocument = nil
                        }
                        
                        if source == .cache, docs.isEmpty {
                            return
                        }
                        
                        subject.send(
                            SearchChatsPage(
                                chats: docs.compactMap(self.decodeChat(from:)),
                                hasMore: docs.count == normalizedLimit
                            )
                        )
                        
                        if source == .server {
                            subject.send(completion: .finished)
                        }
                    }
            }
            
            // Сначала пытаемся подгружать данные из кэша
            fetchPage(.cache)
            fetchPage(.server)
            
            return subject.eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    private func decodeChat(from snapshot: QueryDocumentSnapshot) -> ChatModel? {
        let data = snapshot.data()
        
        let id = snapshot.documentID
        let title = data[Chats.title.path] as? String ?? Constants.fallbackTitle
        let lastMessageText = data[Chats.lastMessageText.path] as? String
        let timestamp = data[Chats.lastMessageDate.path] as? Timestamp
        let lastMessageDate = timestamp?.dateValue()
        let avatarURL = data[Chats.avatarURL.path] as? String
        let users = data[Chats.memberIds.path] as? [String] ?? []
        
        return ChatModel(
            id: id,
            title: title,
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
