//
//  SearchFriendsListInteractor.swift
//  CoLab
//
//  Created by User on 05.05.2026.
//

import Foundation
import Combine

final class SearchFriendsListInteractor: SearchFriendsListBusinessLogic {
    private struct Constants {
        static let pageLimit = 20
    }
    
    private enum AvatarSource: Equatable {
        case none
        case remote(String)
    }
    
    private let presenter: SearchFriendsListPresentationLogic
    private let colorRepository: ColorStorageLogic
    private let friendsListService: SearchFriendsListLogic
    private let userService: UserServiceLogic
    private let avatarService: AvatarServiceLogic
    
    private var orderedUsers: [UserModel] = []
    private var canLoadMore = false
    private var isLoadingPage = false
    private var searchText: String?
    private var currentUserAvatarURL: String?
    private var avatarSourcesByUserId: [String: AvatarSource] = [:]
    
    private var pageCancellables = Set<AnyCancellable>()
    private var avatarCancellables: [String: AnyCancellable] = [:]
    private var currentUserAvatarCancellable: AnyCancellable?
    
    // MARK: Lifecycle
    
    init(
        presenter: SearchFriendsListPresentationLogic,
        colorRepository: ColorStorageLogic,
        friendsListService: SearchFriendsListLogic,
        userService: UserServiceLogic,
        avatarService: AvatarServiceLogic
    ) {
        self.presenter = presenter
        self.colorRepository = colorRepository
        self.friendsListService = friendsListService
        self.userService = userService
        self.avatarService = avatarService
    }
    
    deinit {
        pageCancellables.removeAll()
        avatarCancellables.values.forEach { $0.cancel() }
        currentUserAvatarCancellable?.cancel()
        userService.stopListeningChanges()
    }
    
    // MARK: Use cases
    
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
    }
    
    func listenCurrentUserAvatar() {
        userService.startListeningChanges()
        
        guard currentUserAvatarCancellable == nil else { return }
        
        currentUserAvatarCancellable = userService.currentUserDataPublisher()
            .flatMap { [weak self] user -> AnyPublisher<Data?, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                
                guard let photoURL = user.photoURL, !photoURL.isEmpty else {
                    self.currentUserAvatarURL = nil
                    return Just(nil).eraseToAnyPublisher()
                }
                
                guard photoURL != self.currentUserAvatarURL else {
                    return Empty().eraseToAnyPublisher()
                }
                
                self.currentUserAvatarURL = photoURL
                return self.avatarService.avatarDataPublisher(photoURL: photoURL)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avatarData in
                self?.presenter.presentCurrentUserAvatar(
                    Model.CurrentUserAvatar.Response(avatarData: avatarData)
                )
            }
    }
    
    func stopListeningCurrentUserAvatar() {
        currentUserAvatarCancellable?.cancel()
        currentUserAvatarCancellable = nil
        currentUserAvatarURL = nil
        userService.stopListeningChanges()
    }
    
    func loadInitialUsers() {
        guard orderedUsers.isEmpty else { return }
        guard !isLoadingPage else { return }
        
        canLoadMore = false
        friendsListService.reset()
        avatarSourcesByUserId.removeAll()
        avatarCancellables.values.forEach { $0.cancel() }
        avatarCancellables.removeAll()
        
        loadPage(
            friendsListService.fetchFirstPage(
                limit: Constants.pageLimit,
                searchText: searchText
            ),
            replacingCurrentUsers: true
        )
    }
    
    func loadNextPage() {
        guard canLoadMore else { return }
        guard !isLoadingPage else { return }
        
        loadPage(
            friendsListService.fetchNextPage(
                limit: Constants.pageLimit,
                searchText: searchText
            ),
            replacingCurrentUsers: false
        )
    }
    
    func updateSearchText(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let nextSearchText = trimmedText.isEmpty ? nil : trimmedText
        
        guard searchText != nextSearchText else { return }
        
        searchText = nextSearchText
        reloadUsers()
    }
    
    // MARK: Helpers
    
    private func reloadUsers() {
        pageCancellables.removeAll()
        isLoadingPage = false
        orderedUsers.removeAll()
        canLoadMore = false
        friendsListService.reset()
        
        avatarSourcesByUserId.removeAll()
        avatarCancellables.values.forEach { $0.cancel() }
        avatarCancellables.removeAll()
        
        presenter.presentUsers(
            Model.UsersList.Response(users: [])
        )
        loadInitialUsers()
    }
    
    private func loadPage(
        _ publisher: AnyPublisher<SearchFriendsPage, FetchUserError>,
        replacingCurrentUsers: Bool
    ) {
        isLoadingPage = true
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.isLoadingPage = false
                    
                    if case let .failure(error) = completion {
                        self.presenter.presentError(
                            Model.ShowError.Response(error: error)
                        )
                    }
                },
                receiveValue: { [weak self] page in
                    self?.handleLoadedPage(
                        page,
                        replacingCurrentUsers: replacingCurrentUsers
                    )
                }
            )
            .store(in: &pageCancellables)
    }
    
    private func handleLoadedPage(
        _ page: SearchFriendsPage,
        replacingCurrentUsers: Bool
    ) {
        canLoadMore = page.hasMore
        
        if replacingCurrentUsers {
            orderedUsers = page.users
        } else {
            let existingIds = Set(orderedUsers.map(\.id))
            orderedUsers.append(
                contentsOf: page.users.filter { !existingIds.contains($0.id) }
            )
        }
        
        presenter.presentUsers(
            Model.UsersList.Response(users: orderedUsers)
        )
        
        syncUserAvatars(for: page.users)
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
