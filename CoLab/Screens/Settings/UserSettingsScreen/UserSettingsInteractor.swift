//
//  UserSettingsInteractor.swift
//  CoLab
//
//  Created by User on 13.03.2026.
//

import Foundation
import Combine

final class UserSettingsInteractor: UserSettingsBusinessLogic {
    
    private let presenter: UserSettingsPresentationLogic
    
    private let router: SettingsRoutingLogic
    
    private let colorRepository: ColorStorageLogic
    
    private let authService: AuthLogic
    private let userService: UserServiceLogic
    private let avatarService: AvatarServiceLogic
    
    private var currentUserData: UserModel? = nil
    
    private var userSubscription: AnyCancellable? = nil
    
    // MARK: Lifecycle
    
    init(
        presenter: UserSettingsPresentationLogic,
        router: SettingsRoutingLogic,
        colorRepository: ColorStorageLogic,
        authService: AuthLogic,
        userService: UserServiceLogic,
        avatarService: AvatarServiceLogic
    ) {
        self.presenter = presenter
        self.router = router
        self.colorRepository = colorRepository
        self.authService = authService
        self.userService = userService
        self.avatarService = avatarService
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
    }
    
    func listenUserData() {
        userService.startListeningChanges()
        // Нет смысла переназначать
        if userSubscription == nil {
            userSubscription = userService.currentUserDataPublisher()
                .flatMap { [weak self] user -> AnyPublisher<(UserModel, Data?), Never> in
                    guard let self else {
                        return Empty().eraseToAnyPublisher()
                    }
                    if user.photoURL == currentUserData?.photoURL {
                        return Just((user, nil)).eraseToAnyPublisher()
                    }
                    currentUserData = user
                    return avatarService.avatarDataPublisher(photoURL: user.photoURL ?? "")
                        .map { (user, $0) }
                        .eraseToAnyPublisher()
                }
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveValue: { [weak self] (user, avatarData) in
                        self?.presenter.presentUserChanges(
                            Model.GetUserData.Response(
                                avatarData: avatarData,
                                userData: user
                            )
                        )
                    })
        }
    }
    
    func stopListeningUserData() {
        userService.stopListeningChanges()
    }
    
    // MARK: Route
    
    func logOut() {
        do {
            try authService.logOut()
            // Очищаем кэш юзера при выходе из аккаунта
            userService.clearUserCache()
            avatarService.clearAvatarsCache()
            router.routeToAuth()
        } catch let error  {
            presenter.presentError(Model.ShowError.Response(error: error))
        }
    }
    
    func loadChangeDataScreen() {
        router.routeToChangeSettings()
    }
}
