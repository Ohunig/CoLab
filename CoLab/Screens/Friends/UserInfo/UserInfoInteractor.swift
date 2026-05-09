//
//  UserInfoInteractor.swift
//  CoLab
//
//  Created by User on 08.05.2026.
//

import Foundation
import Combine

final class UserInfoInteractor: UserInfoBusinessLogic {
    private struct Constants {
        static let unknownUsername = "..."
    }
    
    private let userId: String
    private let presenter: UserInfoPresentationLogic
    private let colorRepository: ColorStorageLogic
    private let userService: UserServiceLogic
    private let avatarService: AvatarServiceLogic
    private let router: UserInfoRoutingLogic
    
    private var username = Constants.unknownUsername
    private var avatarURL: String?
    private var currentAvatarData: Data?
    private var isAvatarLoading = true
    
    private var cancellables = Set<AnyCancellable>()
    private var avatarCancellable: AnyCancellable?
    
    // MARK: Lifecycle
    
    init(
        userId: String,
        presenter: UserInfoPresentationLogic,
        colorRepository: ColorStorageLogic,
        userService: UserServiceLogic,
        avatarService: AvatarServiceLogic,
        router: UserInfoRoutingLogic
    ) {
        self.userId = userId
        self.presenter = presenter
        self.colorRepository = colorRepository
        self.userService = userService
        self.avatarService = avatarService
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
        
        loadUser()
    }
    
    func closeScreen() {
        router.routeBack()
    }
    
    // MARK: Loading
    
    private func loadUser() {
        userService.fetchUserOnce(id: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    
                    if case let .failure(error) = completion {
                        self.isAvatarLoading = false
                        self.presentUserData()
                        self.presenter.presentError(
                            Model.ShowError.Response(error: error)
                        )
                    }
                },
                receiveValue: { [weak self] user in
                    self?.handleUser(user)
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleUser(_ user: UserModel) {
        username = user.username
        updateAvatar(user.photoURL)
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
}
