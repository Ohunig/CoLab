//
//  AddChatMemberInteractor.swift
//  CoLab
//
//  Created by User on 07.05.2026.
//

import Foundation
import Combine

final class AddChatMemberInteractor: AddChatMemberBusinessLogic {
    private enum AvatarSource: Equatable {
        case none
        case remote(String)
    }
    
    private let chatId: String
    private let memberIds: Set<String>
    private let presenter: AddChatMemberPresentationLogic
    private let colorRepository: ColorStorageLogic
    private let userService: UserServiceLogic
    private let avatarService: AvatarServiceLogic
    private let chatService: ChatLogic
    private let router: ChatsRoutingLogic
    
    private var isAdding = false
    private var avatarSourcesByUserId: [String: AvatarSource] = [:]
    private var cancellables = Set<AnyCancellable>()
    private var avatarCancellables: [String: AnyCancellable] = [:]
    
    // MARK: Lifecycle
    
    init(
        chatId: String,
        memberIds: [String],
        presenter: AddChatMemberPresentationLogic,
        colorRepository: ColorStorageLogic,
        userService: UserServiceLogic,
        avatarService: AvatarServiceLogic,
        chatService: ChatLogic,
        router: ChatsRoutingLogic
    ) {
        self.chatId = chatId
        self.memberIds = Set(memberIds)
        self.presenter = presenter
        self.colorRepository = colorRepository
        self.userService = userService
        self.avatarService = avatarService
        self.chatService = chatService
        self.router = router
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
    
    func addMember(userId: String) {
        guard !isAdding else { return }
        guard !memberIds.contains(userId) else {
            router.routeBack()
            return
        }
        
        isAdding = true
        presenter.presentAddingState(
            Model.AddingState.Response(isAdding: true)
        )
        
        chatService.addUser(userId, toChat: chatId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    
                    if case let .failure(error) = completion {
                        self.isAdding = false
                        self.presenter.presentAddingState(
                            Model.AddingState.Response(isAdding: false)
                        )
                        self.presenter.presentError(
                            Model.ShowError.Response(error: error)
                        )
                    }
                },
                receiveValue: { [weak self] in
                    self?.router.routeBack()
                }
            )
            .store(in: &cancellables)
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
            !memberIds.contains($0) && $0 != currentUser.id
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
    }
    
    private func avatarSource(for user: UserModel) -> AvatarSource {
        guard let photoURL = user.photoURL, !photoURL.isEmpty else {
            return .none
        }
        return .remote(photoURL)
    }
}
