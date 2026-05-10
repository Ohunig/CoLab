//
//  SelectChatMemberInteractor.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import Foundation
import Combine

final class SelectChatMemberInteractor: AddChatMemberBusinessLogic {
    private enum AvatarSource: Equatable {
        case none
        case remote(String)
    }
    
    private let excludedUserIds: Set<String>
    private let presenter: AddChatMemberPresentationLogic
    private let colorRepository: ColorStorageLogic
    private let userService: UserServiceLogic
    private let avatarService: AvatarServiceLogic
    private let router: UserInfoRoutingLogic
    private let onSelectUser: (UserModel) -> Void
    
    private var usersById: [String: UserModel] = [:]
    private var avatarSourcesByUserId: [String: AvatarSource] = [:]
    private var cancellables = Set<AnyCancellable>()
    private var avatarCancellables: [String: AnyCancellable] = [:]
    
    // MARK: Lifecycle
    
    init(
        excludedUserIds: [String],
        presenter: AddChatMemberPresentationLogic,
        colorRepository: ColorStorageLogic,
        userService: UserServiceLogic,
        avatarService: AvatarServiceLogic,
        router: UserInfoRoutingLogic,
        onSelectUser: @escaping (UserModel) -> Void
    ) {
        self.excludedUserIds = Set(excludedUserIds)
        self.presenter = presenter
        self.colorRepository = colorRepository
        self.userService = userService
        self.avatarService = avatarService
        self.router = router
        self.onSelectUser = onSelectUser
    }
    
    // MARK: Use-cases
    
    func loadStart() {
        presenter.presentStart(
            Model.Start.Response(
                bg: colorRepository.backgroundColor,
                bgGradient: colorRepository.backgroundGradientColor,
                elementsBase: colorRepository.elementsBaseColor,
                tint: colorRepository.tintColor,
                textColor: colorRepository.mainTextColor
            )
        )
        presenter.presentAddingState(
            Model.AddingState.Response(isAdding: false)
        )
        
        loadFriends()
    }
    
    func loadGoBack() {
        router.routeBack()
    }
    
    func addMember(userId: String) {
        guard let user = usersById[userId] else { return }
        
        onSelectUser(user)
        router.routeBack()
    }
    
    // MARK: Loading friends
    
    private func loadFriends() {
        userService.fetchCurrentUserOnce()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.presenter.presentFriends(
                            Model.FriendsList.Response(users: [])
                        )
                        self?.presenter.presentError(
                            Model.ShowError.Response(error: error)
                        )
                    }
                },
                receiveValue: { [weak self] currentUser in
                    self?.loadFriends(for: currentUser)
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadFriends(for currentUser: UserModel) {
        let friendIds = currentUser.friendIds.filter {
            !excludedUserIds.contains($0) && $0 != currentUser.id
        }
        
        guard !friendIds.isEmpty else {
            presenter.presentFriends(
                Model.FriendsList.Response(users: [])
            )
            return
        }
        
        let orderById = Dictionary(
            uniqueKeysWithValues: friendIds.enumerated().map { ($0.element, $0.offset) }
        )
        let publishers = friendIds.map { [weak self] friendId in
            self?.userService
                .fetchUserOnce(id: friendId)
                .map { Optional($0) }
                .catch { [weak self] error -> Just<UserModel?> in
                    self?.presenter.presentError(
                        Model.ShowError.Response(error: error)
                    )
                    return Just(nil)
                }
                .eraseToAnyPublisher()
            ?? Just(nil).eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(publishers)
            .collect()
            .map { users in
                users
                    .compactMap { $0 }
                    .sorted {
                        (orderById[$0.id] ?? .max) < (orderById[$1.id] ?? .max)
                    }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?.handleLoadedFriends(users)
            }
            .store(in: &cancellables)
    }
    
    private func handleLoadedFriends(_ users: [UserModel]) {
        usersById = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
        presenter.presentFriends(
            Model.FriendsList.Response(users: users)
        )
        syncUserAvatars(for: users)
    }
    
    private func syncUserAvatars(for users: [UserModel]) {
        users.forEach { user in
            let nextSource = avatarSource(for: user)
            guard avatarSourcesByUserId[user.id] != nextSource else { return }
            
            avatarSourcesByUserId[user.id] = nextSource
            avatarCancellables[user.id]?.cancel()
            
            switch nextSource {
            case .none:
                presenter.presentAvatarUpdate(
                    Model.AvatarUpdate.Response(
                        userId: user.id,
                        avatarData: nil
                    )
                )
            case let .remote(photoURL):
                avatarCancellables[user.id] = avatarService
                    .avatarDataPublisher(photoURL: photoURL)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] avatarData in
                        self?.presenter.presentAvatarUpdate(
                            Model.AvatarUpdate.Response(
                                userId: user.id,
                                avatarData: avatarData
                            )
                        )
                    }
            }
        }
        
        let actualUserIds = Set(users.map(\.id))
        avatarCancellables.keys
            .filter { !actualUserIds.contains($0) }
            .forEach { removedUserId in
                avatarCancellables[removedUserId]?.cancel()
                avatarCancellables[removedUserId] = nil
                avatarSourcesByUserId[removedUserId] = nil
            }
    }
    
    private func avatarSource(for user: UserModel) -> AvatarSource {
        guard let photoURL = user.photoURL, !photoURL.isEmpty else {
            return .none
        }
        return .remote(photoURL)
    }
}
