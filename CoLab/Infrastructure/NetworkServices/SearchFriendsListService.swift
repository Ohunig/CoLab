//
//  SearchFriendsListService.swift
//  CoLab
//
//  Created by User on 05.05.2026.
//

import Foundation
import Combine
import FirebaseFirestore

final class SearchFriendsListService: SearchFriendsListLogic {
    private typealias Users = FirebasePaths.Users
    
    private struct Constants {
        static let fallbackUsername = "User"
    }
    
    private let db = Firestore.firestore()
    private let searchKeywordsBuilder: SearchKeywordsBuilder
    private var lastDocument: QueryDocumentSnapshot?
    
    // MARK: Lifecycle
    
    init(searchKeywordsBuilder: SearchKeywordsBuilder) {
        self.searchKeywordsBuilder = searchKeywordsBuilder
    }
    
    // MARK: Use-cases
    
    func fetchFirstPage(
        limit: Int,
        searchText: String?
    ) -> AnyPublisher<SearchFriendsPage, FetchUserError> {
        reset()
        return fetchPage(
            after: nil,
            limit: limit,
            searchText: searchText
        )
    }
    
    func fetchNextPage(
        limit: Int,
        searchText: String?
    ) -> AnyPublisher<SearchFriendsPage, FetchUserError> {
        guard let lastDocument else {
            return Just(SearchFriendsPage(users: [], hasMore: false))
                .setFailureType(to: FetchUserError.self)
                .eraseToAnyPublisher()
        }
        
        return fetchPage(
            after: lastDocument,
            limit: limit,
            searchText: searchText
        )
    }
    
    func reset() {
        lastDocument = nil
    }
    
    // MARK: Helpers
    
    private func fetchPage(
        after document: QueryDocumentSnapshot?,
        limit: Int,
        searchText: String?
    ) -> AnyPublisher<SearchFriendsPage, FetchUserError> {
        Deferred { [weak self] in
            let subject = PassthroughSubject<SearchFriendsPage, FetchUserError>()
            
            guard let self else {
                return Fail<SearchFriendsPage, FetchUserError>(error: .unknown)
                    .eraseToAnyPublisher()
            }
            
            let fetchPage = { [weak self] (source: FirestoreSource) in
                guard let self else {
                    subject.send(completion: .failure(.unknown))
                    return
                }
                
                let normalizedLimit = max(1, limit)
                var query: Query = self.db.collection(Users.root)
                
                let searchWords = self.searchKeywordsBuilder.queryWords(
                    for: searchText
                )
                
                if searchWords.count == 1, let searchWord = searchWords.first {
                    query = query.whereField(
                        Users.searchKeywords.path,
                        arrayContains: searchWord
                    )
                } else if !searchWords.isEmpty {
                    query = query.whereField(
                        Users.searchKeywords.path,
                        arrayContainsAny: searchWords
                    )
                }
                
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
                            SearchFriendsPage(
                                users: docs.map(self.decodeUser(from:)),
                                hasMore: docs.count == normalizedLimit
                            )
                        )
                        
                        if source == .server {
                            subject.send(completion: .finished)
                        }
                    }
            }
            
            fetchPage(.cache)
            fetchPage(.server)
            
            return subject.eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    private func decodeUser(from snapshot: QueryDocumentSnapshot) -> UserModel {
        let data = snapshot.data()
        
        return UserModel(
            id: snapshot.documentID,
            username: data[Users.username.path] as? String ?? Constants.fallbackUsername,
            photoURL: data[Users.photoURL.path] as? String,
            friendIds: data[Users.friendIds.path] as? [String] ?? []
        )
    }
    
    private func decodeError(_ error: Error) -> FetchUserError {
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
