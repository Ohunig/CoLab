//
//  ChangeSettingsInteractor.swift
//  CoLab
//
//  Created by User on 16.03.2026.
//

import Foundation
import Combine

final class ChangeSettingsInteractor: ChangeSettingsBusinessLogic {
    
    private struct Constants {
        static let minimalUsernameSymbols = 4
    }
    
    private let presenter: ChangeSettingsPresentationLogic
    
    private let router: SettingsRoutingLogic
    
    private let colorRepository: ColorStorageLogic
    
    private let userService: UserServiceLogic
    private let avatarService: AvatarServiceLogic
    
    private var currentUserData: UserModel? = nil
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: Lifecycle
    
    init(
        presenter: ChangeSettingsPresentationLogic,
        router: SettingsRoutingLogic,
        colorRepository: ColorStorageLogic,
        userService: UserServiceLogic,
        avatarService: AvatarServiceLogic
    ) {
        self.presenter = presenter
        self.router = router
        self.colorRepository = colorRepository
        self.userService = userService
        self.avatarService = avatarService
    }
    
    // MARK: - Use-cases
    
    func loadStart() {
        presenter.presentStart(
            Model.Start.Response(
                bg: colorRepository.backgroundColor,
                bgGradient: colorRepository.backgroundGradientColor,
                firstGradient: colorRepository.firstGradientColor,
                secondGradient: colorRepository.secondGradientColor,
                elementsBase: colorRepository.elementsBaseColor,
                tint: colorRepository.tintColor,
                textColor: colorRepository.mainTextColor
            )
        )
    }
    
    func loadUserData() {
        userService.fetchCurrentUserOnce()
            .catch { error -> Empty<UserModel, Never> in
                return Empty()
            }
            .flatMap { [weak self] user -> AnyPublisher<(UserModel, Data?), Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                
                if user.photoURL == self.currentUserData?.photoURL {
                    return Just((user, nil))
                        .eraseToAnyPublisher()
                }
                
                self.currentUserData = user
                
                return self.avatarService
                    .avatarDataPublisher(photoURL: user.photoURL ?? "")
                    .map { (user, $0) }
                    .replaceError(with: (user, nil))
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (user, avatarData) in
                self?.presenter.presentUserData(
                    Model.GetUserData.Response(
                        avatarData: avatarData,
                        userData: user
                    )
                )
            }
            .store(in: &cancellables)
    }
    
    // MARK: Update user data
    
    func updateUserData(_ request: Model.UpdateUserData.Request) {
        // Так как не можем обновить данные если их вообще нет
        guard let user = currentUserData else { return }
        // Определяем паблишера в зависимости от того есть ли данные аватара
        let updateUserPublisher: AnyPublisher<String?, Error>
        
        if let avatarData = request.avatarData {
            updateUserPublisher = avatarService
                .uploadUserAvatarData(data: avatarData, for: user.id)
                .flatMap { [weak self] photoURL -> AnyPublisher<String?, Error> in
                    guard let self else {
                        return Fail(error: CancellationError()).eraseToAnyPublisher()
                    }
                    
                    return self.userService
                        .updateCurrentUserData(
                            user: UserModel(
                                id: user.id,
                                username: request.username,
                                photoURL: photoURL
                            )
                        )
                        .map { photoURL as String? }
                        .mapError { $0 as Error }
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        } else {
            updateUserPublisher = userService
                .updateCurrentUserData(
                    user: UserModel(
                        id: user.id,
                        username: request.username,
                        photoURL: user.photoURL
                    )
                )
                .map { user.photoURL as String? }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        
        updateUserPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    self.router.routeToUserSettings()
                case .failure(let error):
                    self.presenter.presentUpdateDataResult(
                        Model.CatchError.Response(error: error)
                    )
                }
            } receiveValue: { [weak self] newPhotoURL in
                guard let self else { return }
                self.currentUserData = UserModel(
                    id: user.id,
                    username: request.username,
                    photoURL: newPhotoURL
                )
            }
            .store(in: &cancellables)
    }
    
    // MARK: Validation
    
    func loadDataValidation(_ request: Model.Validation.Request) {
        presenter.presentDataValidation(
            Model.Validation.Response(
                isValid: request.username.count >= Constants.minimalUsernameSymbols
            )
        )
    }
    
    // MARK: Route
    
    func loadGoBack() {
        router.routeToUserSettings()
    }
}
