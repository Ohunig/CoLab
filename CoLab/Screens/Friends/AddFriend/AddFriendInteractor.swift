//
//  AddFriendInteractor.swift
//  CoLab
//
//  Created by User on 06.05.2026.
//

import Foundation
import Combine

final class AddFriendInteractor: AddFriendBusinessLogic {
    private struct Constants {
        static let unknownUsername = "..."
    }
    
    private let userId: String
    private let presenter: AddFriendPresentationLogic
    private let colorRepository: ColorStorageLogic
    private let friendsService: FriendsServiceLogic
    private let userService: UserServiceLogic
    private let avatarService: AvatarServiceLogic
    
    private var currentUserId: String?
    private var currentFriendIds: [String] = []
    private var username = Constants.unknownUsername
    private var avatarURL: String?
    private var currentAvatarData: Data?
    private var isAvatarLoading = false
    private var isAdding = false
    
    private var cancellables = Set<AnyCancellable>()
    private var targetUserCancellable: AnyCancellable?
    private var currentUserCancellable: AnyCancellable?
    private var avatarCancellable: AnyCancellable?
    
    // MARK: Lifecycle
    
    init(
        userId: String,
        presenter: AddFriendPresentationLogic,
        colorRepository: ColorStorageLogic,
        friendsService: FriendsServiceLogic,
        userService: UserServiceLogic,
        avatarService: AvatarServiceLogic
    ) {
        self.userId = userId
        self.presenter = presenter
        self.colorRepository = colorRepository
        self.friendsService = friendsService
        self.userService = userService
        self.avatarService = avatarService
    }
    
    deinit {
        targetUserCancellable?.cancel()
        currentUserCancellable?.cancel()
        avatarCancellable?.cancel()
        userService.stopListeningUser(id: userId)
        userService.stopListeningChanges()
    }
    
    // MARK: Use-cases
    
    func loadStart() {
        presenter.presentStart(
            Model.Start.Response(
                bg: colorRepository.backgroundColor,
                bgGradient: colorRepository.backgroundGradientColor,
                elementsBase: colorRepository.elementsBaseColor,
                tint: colorRepository.tintColor,
                textColor: colorRepository.mainTextColor,
                firstGradient: colorRepository.firstGradientColor,
                secondGradient: colorRepository.secondGradientColor
            )
        )
        
        presentUserData()
        presentAddButtonState()
        bindCurrentUser()
        bindTargetUser()
    }
    
    func addFriend() {
        guard !isAdding else { return }
        guard currentUserId != userId else {
            presentAddButtonState()
            return
        }
        guard !currentFriendIds.contains(userId) else {
            presentAddButtonState()
            return
        }
        
        isAdding = true
        presentAddButtonState()
        
        friendsService.addFriend(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    
                    if case let .failure(error) = completion {
                        self.isAdding = false
                        self.presentAddButtonState()
                        self.presenter.presentError(
                            Model.ShowError.Response(error: error)
                        )
                    }
                },
                receiveValue: { [weak self] in
                    self?.handleAddSuccess()
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: Binding
    
    private func bindTargetUser() {
        targetUserCancellable = userService
            .userUpdatesPublisher(id: userId)
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    guard let self else { return }
                    self.userService.startListeningUser(id: self.userId)
                },
                receiveCancel: { [weak self] in
                    guard let self else { return }
                    self.userService.stopListeningUser(id: self.userId)
                }
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.handleTargetUserUpdate(result)
            }
    }
    
    private func bindCurrentUser() {
        userService.startListeningChanges()
        
        currentUserCancellable = userService.currentUserDataPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.handleCurrentUserUpdate(user)
            }
    }
    
    // MARK: Updates
    
    private func handleTargetUserUpdate(
        _ result: Result<UserModel, FetchUserError>
    ) {
        switch result {
        case let .failure(error):
            presenter.presentError(Model.ShowError.Response(error: error))
        case let .success(user):
            let shouldUpdateAvatar = avatarURL != user.photoURL
            username = user.username
            
            if shouldUpdateAvatar {
                updateAvatar(user.photoURL)
            } else {
                presentUserData()
            }
        }
    }
    
    private func handleCurrentUserUpdate(_ user: UserModel) {
        currentUserId = user.id
        currentFriendIds = user.friendIds
        presentAddButtonState()
    }
    
    private func handleAddSuccess() {
        isAdding = false
        
        if !currentFriendIds.contains(userId) {
            currentFriendIds.append(userId)
        }
        
        presentAddButtonState()
    }
    
    private func updateAvatar(_ nextAvatarURL: String?) {
        avatarURL = nextAvatarURL
        avatarCancellable?.cancel()
        currentAvatarData = nil
        
        guard let nextAvatarURL, !nextAvatarURL.isEmpty else {
            isAvatarLoading = false
            presentUserData()
            return
        }
        
        isAvatarLoading = true
        presentUserData()
        
        avatarCancellable = avatarService
            .avatarDataPublisher(photoURL: nextAvatarURL)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avatarData in
                guard let self,
                      self.avatarURL == nextAvatarURL else {
                    return
                }
                
                self.currentAvatarData = avatarData
                self.isAvatarLoading = false
                self.presentUserData()
            }
    }
    
    // MARK: Present
    
    private func presentUserData() {
        presenter.presentUserData(
            Model.UserData.Response(
                avatarData: currentAvatarData,
                isAvatarLoading: isAvatarLoading,
                username: username
            )
        )
    }
    
    private func presentAddButtonState() {
        presenter.presentAddButtonState(
            Model.AddButtonState.Response(
                isLoading: isAdding,
                isFriend: currentFriendIds.contains(userId),
                isSelf: currentUserId == userId
            )
        )
    }
}
