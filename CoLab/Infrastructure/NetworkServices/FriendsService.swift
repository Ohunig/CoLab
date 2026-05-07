//
//  FriendsService.swift
//  CoLab
//
//  Created by User on 06.05.2026.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class FriendsService: FriendsServiceLogic {
    private typealias Users = FirebasePaths.Users
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    // MARK: Use-cases
    
    func addFriend(userId: String) -> AnyPublisher<Void, FetchUserError> {
        updateFriendIds(
            userId: userId,
            value: FieldValue.arrayUnion([userId])
        )
    }
    
    func removeFriend(userId: String) -> AnyPublisher<Void, FetchUserError> {
        updateFriendIds(
            userId: userId,
            value: FieldValue.arrayRemove([userId])
        )
    }
    
    // MARK: Helpers
    
    private func updateFriendIds(
        userId: String,
        value: Any
    ) -> AnyPublisher<Void, FetchUserError> {
        guard let currentUserId = auth.currentUser?.uid else {
            return Fail(error: .permissionDenied).eraseToAnyPublisher()
        }
        
        guard currentUserId != userId else {
            return Just(())
                .setFailureType(to: FetchUserError.self)
                .eraseToAnyPublisher()
        }
        
        return Future<Void, FetchUserError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            
            self.db.collection(Users.root)
                .document(currentUserId)
                .setData(
                    [Users.friendIds.path: value],
                    merge: true
                ) { error in
                    if let error {
                        promise(.failure(self.decodeError(error)))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
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
